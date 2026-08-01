import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/moon_pool.types"
import "../wrappers/MoonPool.gen"

const CODE_FIXTURE_BOC_PATH = "data/moon/pool/testdata/MoonPool.boc"
const DATA_FIXTURE_BOC_PATH = "data/moon/pool/testdata/MoonPool.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xf027fcc000d2961bd2bda733226b67ea08162e8807623f6056c99616ee94de87
const EXPECTED_DATA_HASH = 0xc429bb36195ce1222d329b0e373b3ccecc12353c58e7a018dc87a0e444f0726b
const PINNED_MAINNET_BLOCK = 83400035

const MAINNET_MOON_POOL_ADDRESS = "EQCMpWCnDHVhMnUspAaKxagkXuW0NGhMq6Y-HCW_BO20e-Ju"
const QUOTE_OWNER_ADDRESS = "0:26B5754C35875C92B0E999789CCFB1AEA97B46298DE33459C157AC72F284E76F"
const MAINNET_USDT_MASTER = "EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs"

struct LoadedMoonPoolStorage {
    data: cell
    storage: MoonPoolStorage
    balances: MoonPoolBalances
    assetsAndContent: MoonPoolAssetsAndContent
}

fun mainnetMoonPool(): MoonPool {
    return MoonPool.fromAddress(address(MAINNET_MOON_POOL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadMoonPoolData(data: cell): LoadedMoonPoolStorage {
    val storage = MoonPoolStorage.fromCell(data);
    val balances = storage.balances.load();
    val assetsAndContent = storage.assetsAndContent.load();
    return LoadedMoonPoolStorage { data, storage, balances, assetsAndContent };
}

fun loadMoonPoolDataFixture(): LoadedMoonPoolStorage {
    val rawBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val data = build("MoonPoolData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return loadMoonPoolData(data);
}

fun loadMoonPoolFromFork(pool: MoonPool): LoadedMoonPoolStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MoonPool", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return loadMoonPoolData(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Moon Pool mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Moon Pool mainnet account is frozen");
        }
    }
}

fun expectMoonPoolGetters(pool: MoonPool, loaded: LoadedMoonPoolStorage): void {
    val storage = loaded.storage;
    val balances = loaded.balances;
    val assets = loaded.assetsAndContent;
    val reserves = pool.getReserves();
    val assetIds = pool.getAssets();
    val wallets = pool.getWallets();
    val fees = pool.getFees();
    val collectedFees = pool.getCollectedFees();
    val jettonData = pool.getJettonData();
    val estimatedBurn = pool.getEstimatedLpBurn(1000000);
    val lpAccount = pool.getLpAccount(address(QUOTE_OWNER_ADDRESS));
    val lpWallet = pool.getWalletAddress(address(QUOTE_OWNER_ADDRESS));

    expect(reserves.asset1Reserve).toEqual(balances.asset1Reserve as int);
    expect(reserves.asset2Reserve).toEqual(balances.asset2Reserve as int);
    expect(assetIds.asset1Id).toBeNoneAddress();
    expect(reserves.asset1Id).toBeNoneAddress();
    expect(wallets.asset1Wallet).toBeNoneAddress();
    expect(assetIds.asset2Id.castToInternal()).toEqual(assets.asset2Id!);
    expect(reserves.asset2Id.castToInternal()).toEqual(assets.asset2Id!);
    expect(wallets.asset2Wallet.castToInternal()).toEqual(storage.asset2Wallet!);

    expect(fees.swapFeeBps).toEqual(storage.swapFeeBps as int);
    expect(fees.protocolFeeBps).toEqual(storage.protocolFeeBps as int);
    expect(fees.referralFeeBps).toEqual(storage.referralFeeBps as int);
    expect(collectedFees.asset1Fees).toEqual(balances.asset1ProtocolFees as int);
    expect(collectedFees.asset2Fees).toEqual(balances.asset2ProtocolFees as int);
    expect(pool.getLpTotal()).toEqual(storage.lpTotalSupply as int);

    expect(jettonData.totalSupply).toEqual(storage.lpTotalSupply as int);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress.castToInternal()).toEqual(pool.address);
    expect(jettonData.jettonContent.hash()).toEqual(assets.lpJettonContent.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.lpWalletCode.hash());
    expect(pool.getPool().hash()).toEqual(loaded.data.hash());

    expect(estimatedBurn.asset1Id).toBeNoneAddress();
    expect(estimatedBurn.asset2Id.castToInternal()).toEqual(assets.asset2Id!);
    expect(estimatedBurn.asset1Amount).toEqual(
        (1000000 * (balances.asset1Reserve as int)) / (storage.lpTotalSupply as int),
    );
    expect(estimatedBurn.asset2Amount).toEqual(
        (1000000 * (balances.asset2Reserve as int)) / (storage.lpTotalSupply as int),
    );
    expect(lpAccount.castToInternal() == lpWallet.castToInternal()).toBeFalse();
}

get fun `test moon pool code and data fixtures match exact live cells`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("MoonPool", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("MoonPoolData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test moon pool deployment storage derives exact live address`() {
    val deploymentStorage = MoonPoolDeploymentStorage {
        adminAddress: address("EQAvQ6jA2QJhq5ebGxULLA225htp4RwykDBHimp-GCvrWnyU"),
        asset1Id: null,
        asset2Id: address(MAINNET_USDT_MASTER),
    };
    val stateInit = ContractState {
        code: build("MoonPool", CODE_FIXTURE_BOC_PATH),
        data: deploymentStorage.toCell(),
    };
    val derivedAddress = AutoDeployAddress {
        workchain: 0,
        stateInit,
    }.calculateAddress();

    expect(derivedAddress).toEqual(address(MAINNET_MOON_POOL_ADDRESS));
}

get fun `test moon pool saved storage fixture parses exact runtime layout`() {
    val loaded = loadMoonPoolDataFixture();
    expect(loaded.storage.asset1Wallet).toBeNull();
    expect(loaded.storage.asset2Wallet).toBeNotNull();
    expect(loaded.assetsAndContent.asset1Id).toBeNull();
    expect(loaded.assetsAndContent.asset2Id).toBeNotNull();
    expect(loaded.storage.lpTotalSupply).toBeGreater(0);
    expect(loaded.balances.asset1Reserve).toBeGreater(0);
    expect(loaded.balances.asset2Reserve).toBeGreater(0);
    expect(loaded.storage.toCell().hash()).toEqual(EXPECTED_DATA_HASH);

    println("MOON_POOL_STORAGE_FIXTURE={}", loaded.storage);
    println("MOON_POOL_BALANCES_FIXTURE={}", loaded.balances);
    println("MOON_POOL_ASSETS_FIXTURE={}", loaded.assetsAndContent);
}

get fun `test moon pool pinned mainnet storage and every named getter`() {
    val pool = mainnetMoonPool();
    val loaded = loadMoonPoolFromFork(pool);
    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expectMoonPoolGetters(pool, loaded);

    val nativeAmount = MoonPoolAssetAmount {
        assetId: null,
        amount: 1000000000,
    }.toCell();
    val jettonAmount = MoonPoolAssetAmount {
        assetId: loaded.assetsAndContent.asset2Id,
        amount: 1000000,
    }.toCell();
    val estimatedLp = pool.getEstimatedLp(nativeAmount, jettonAmount);
    val estimatedSwap = pool.getEstimatedSwapOut(nativeAmount);
    expect(estimatedLp).toBeGreater(0);
    expect(estimatedSwap.outputAssetId.castToInternal()).toEqual(
        loaded.assetsAndContent.asset2Id!,
    );
    expect(estimatedSwap.outputAmount).toBeGreater(0);

    println("MOON_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("MOON_POOL_MAINNET_ADDRESS={}", pool.address);
    println("MOON_POOL_STORAGE={}", loaded.storage);
    println("MOON_POOL_ESTIMATED_LP={}", estimatedLp);
    println("MOON_POOL_ESTIMATED_SWAP={}", estimatedSwap);
}
