import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_pool_creator.types"
import "../../factory/types/coffee_factory.types"
import "../../factory/wrappers/CoffeeFactory.gen"

const FIXTURE_BOC_PATH = "data/coffee/pool_creator/testdata/CoffeePoolCreator.boc"
const DEPLOY_MESSAGE_BOC_PATH = "data/coffee/pool_creator/testdata/CoffeePoolCreator.deploy-message.boc"
const FACTORY_FIXTURE_BOC_PATH = "data/coffee/factory/testdata/CoffeeFactory.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xabe90e85e916317f142d0467aebc7675784f49d2a9d62790ccafd485b4f55556
const EXPECTED_FACTORY_CODE_HASH = 0x9a09f156e0aa9c01246c9a27e2ee3859efdef1191e7782652600efa86ed689d0
const EXPECTED_HISTORICAL_JETTON_HASH = 0x25769387aea5fc125a720a31a1e1449b72e7115df6a52a2457956275ebdc25aa
const PINNED_MAINNET_BLOCK = 71349505

const MAINNET_COFFEE_FACTORY_ADDRESS = "EQAsf2sDPfoo-0IjnRA7l_gJBB9jyo4zqfCG_1IFCCI_Qbef"
const HISTORICAL_POOL_CREATOR_ADDRESS = "EQAXXrMo1FT7-u9atE42HjVVsZNUlsD7HlGIUPxdcX9wWZQo"
const HISTORICAL_POOL_CREATOR_OWNER_ADDRESS = "EQDyfVQ27nmIv9bTSh2Eu5GAHp5I5IzJAQFzC6XoF2FGSR2q"

fun mainnetCoffeeFactory(): CoffeeFactory {
    return CoffeeFactory.fromAddress(address(MAINNET_COFFEE_FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun nativeAssetSlice(): slice {
    return beginCell().storeUint(0, 2).endCell().beginParse();
}

fun cesAssetSlice(): slice {
    return beginCell()
        .storeUint(1, 2)
        .storeUint(0, 8)
        .storeUint(EXPECTED_HISTORICAL_JETTON_HASH, 256)
        .endCell()
        .beginParse();
}

fun expectNativeAsset(asset: CoffeePoolCreatorAsset): void {
    match (asset) {
        CoffeePoolCreatorAssetNative => {}
        CoffeePoolCreatorAssetJetton => {
            Assert.fail("Expected native Coffee PoolCreator asset");
        }
        CoffeePoolCreatorAssetExtra => {
            Assert.fail("Expected native Coffee PoolCreator asset");
        }
    }
}

fun expectHistoricalJettonAsset(asset: CoffeePoolCreatorAsset): void {
    match (asset) {
        CoffeePoolCreatorAssetNative => {
            Assert.fail("Expected historical jetton Coffee PoolCreator asset");
        }
        CoffeePoolCreatorAssetJetton => {
            expect(asset.chain).toEqual(0);
            expect(asset.hash).toEqual(EXPECTED_HISTORICAL_JETTON_HASH);
        }
        CoffeePoolCreatorAssetExtra => {
            Assert.fail("Expected historical jetton Coffee PoolCreator asset");
        }
    }
}

fun expectFactoryNativeAsset(asset: CoffeeFactoryAsset): void {
    match (asset) {
        CoffeeFactoryNativeAsset => {}
        CoffeeFactoryJettonAsset => {
            Assert.fail("Expected native Coffee Factory asset");
        }
        CoffeeFactoryExtraAsset => {
            Assert.fail("Expected native Coffee Factory asset");
        }
    }
}

fun expectFactoryHistoricalJettonAsset(asset: CoffeeFactoryAsset): void {
    match (asset) {
        CoffeeFactoryNativeAsset => {
            Assert.fail("Expected historical jetton Coffee Factory asset");
        }
        CoffeeFactoryJettonAsset => {
            expect(asset.chain).toEqual(0);
            expect(asset.hash).toEqual(EXPECTED_HISTORICAL_JETTON_HASH);
        }
        CoffeeFactoryExtraAsset => {
            Assert.fail("Expected historical jetton Coffee Factory asset");
        }
    }
}

fun expectConstantProductAmm(amm: CoffeePoolCreatorAmm): void {
    match (amm) {
        CoffeePoolCreatorAmmConstantProduct => {}
        CoffeePoolCreatorAmmCurveFiStable => {
            Assert.fail("Expected constant-product Coffee PoolCreator AMM");
        }
    }
}

fun loadCoffeeFactoryStorageFromFork(factory: CoffeeFactory): CoffeeFactoryStorage {
    val account = testing.getAccountState(factory.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_FACTORY_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeFactory", FACTORY_FIXTURE_BOC_PATH).hash());
            return CoffeeFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Factory mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Factory mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee pool creator code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeePoolCreator", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee pool creator deploy message parses real storage`() {
    val rawDeployBoc = fs.readBytes(DEPLOY_MESSAGE_BOC_PATH);
    expect(rawDeployBoc).toBeNotNull();
    expect(hasBocMagic(rawDeployBoc!)).toBeTrue();

    val factory = mainnetCoffeeFactory();
    val factoryStorage = loadCoffeeFactoryStorageFromFork(factory);
    val codeCells = factoryStorage.codeCells.load();
    val deploy = CoffeeFactoryDeploy.fromCell(build("CoffeeFactory", DEPLOY_MESSAGE_BOC_PATH));
    val decodedStorage = CoffeePoolCreatorStorage.fromCell(deploy.data);
    val decodedInitData = decodedStorage.initDataCell.load();
    val decodedParams = decodedInitData.poolParams.load();
    val action = deploy.action!.load();
    val derivedFromFactory = factory.getPoolCreatorAddressNoSettings(
        address(HISTORICAL_POOL_CREATOR_OWNER_ADDRESS),
        nativeAssetSlice(),
        cesAssetSlice(),
        0,
    );

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();
    expect(deploy.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(deploy.code.hash()).toEqual(codeCells.poolCreatorCode.hash());
    expect(codeCells.poolCreatorCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeCells.poolCreatorCode.hash()).toEqual(
        build("CoffeePoolCreator", FIXTURE_BOC_PATH).hash(),
    );

    expect(derivedFromFactory.address).toEqual(address(HISTORICAL_POOL_CREATOR_ADDRESS));
    expect((derivedFromFactory.address as any_address).castToInternal()).toEqual(
        derivedFromFactory.address,
    );

    expect(decodedStorage.toCell().hash()).toEqual(deploy.data.hash());
    expect(decodedStorage.initCodeCell.hash()).toEqual(codeCells.initCode.hash());
    expect(decodedStorage.amount1).toEqual(0);
    expect(decodedStorage.amount2).toEqual(0);

    expect(decodedInitData.factoryAddress).toEqual(address(MAINNET_COFFEE_FACTORY_ADDRESS));
    expect(decodedInitData.contractType).toEqual(3);
    expect(decodedInitData.ownerAddress).toEqual(address(HISTORICAL_POOL_CREATOR_OWNER_ADDRESS));
    expectNativeAsset(decodedParams.asset1);
    expectHistoricalJettonAsset(decodedParams.asset2);
    expectConstantProductAmm(decodedParams.amm);
    expect(decodedParams.ammSettings).toBeNull();

    match (action) {
        CoffeeFactoryCreatePoolCreatorInternal => {
            expectFactoryHistoricalJettonAsset(action.asset);
            expect(action.amount).toBeGreater(0);
            expect(action.creationParams.hash()).toBeGreater(0);
        }
        CoffeeFactoryCreateLiquidityDepositoryInternal => {
            Assert.fail("Expected PoolCreator deploy action");
        }
        CoffeeFactoryCreatePoolInternal => {
            Assert.fail("Expected PoolCreator deploy action");
        }
        CoffeeFactoryCreateVaultInternal => {
            Assert.fail("Expected PoolCreator deploy action");
        }
    }

    println("COFFEE_POOL_CREATOR_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_POOL_CREATOR_DEPLOY_ADDRESS={}", derivedFromFactory.address);
    println("COFFEE_POOL_CREATOR_STORAGE={}", decodedStorage);
    println("COFFEE_POOL_CREATOR_INIT_DATA={}", decodedInitData);
}
