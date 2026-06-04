import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_factory_v2.types"
import "../wrappers/DedustFactoryV2.gen"

const FIXTURE_BOC_PATH = "data/dedust/factory/testdata/DedustFactoryV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe64d0059486e3cbe14bd70572295d06d79e847cb4017eac1aa65d82009eaa20c
const EXPECTED_VERSION = 5
const PINNED_MAINNET_BLOCK = 71185104

const MAINNET_DEDUST_FACTORY_V2_ADDRESS = "EQBfBWT7X2BHg9tXAxzhz2aKiNTU1tpt5NsiK0uSDW_YAJ67"
const MAINNET_DEDUST_NATIVE_VAULT_V2_ADDRESS = "EQDa4VOnTYlLvDJ0gZjNYm5PXfSmmtL6Vs6A_CZEtXCNICq_"

fun mainnetDedustFactoryV2(): DedustFactoryV2 {
    return DedustFactoryV2.fromAddress(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
}

fun nativeAssetSlice(): slice {
    return beginCell().storeUint(0, 4).endCell().beginParse();
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadDedustFactoryV2StorageFromFork(factory: DedustFactoryV2): DedustFactoryV2Storage {
    val account = testing.getAccountState(factory.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("DedustFactoryV2", FIXTURE_BOC_PATH).hash());
            return DedustFactoryV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Factory v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Factory v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test dedust factory v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("DedustFactoryV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust factory v2 mainnet public getters`() {
    val factory = mainnetDedustFactoryV2();
    val storage = loadDedustFactoryV2StorageFromFork(factory);
    val config = storage.config.load();
    val nativeAsset = nativeAssetSlice();
    val ownership = factory.getOwnership();
    val version = factory.getVersion();
    val nativeVaultAddress = factory.getVaultAddress(nativeAsset);

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();
    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(storage.ownerAddress).toEqual(ownership.ownerAddress.castToInternal());
    expect(storage.pendingOwnerAddress).toBeNull();
    expect(ownership.pendingOwnerAddress).toBeNoneAddress();
    expect(storage.canAcceptAfter).toEqual(ownership.canAcceptAfter);
    expect(storage.blankCode.hash()).toBeGreater(0);
    expect(config.poolCodeVersion).toBeGreater(0);
    expect(config.poolCode.hash()).toBeGreater(0);
    expect(config.liquidityDepositCodeVersion).toBeGreater(0);
    expect(config.liquidityDepositCode.hash()).toBeGreater(0);
    expect(config.vaultCodeByAssetType).toBeNotNull();
    expect(config.vaultCodeByAssetType!.hash()).toBeGreater(0);
    expect(config.lpWalletCode.hash()).toBeGreater(0);
    expect(storage.operatorCodeVersion).toBeGreater(0);
    expect(storage.operatorCode).toBeNotNull();
    expect(storage.operatorCode!.hash()).toBeGreater(0);

    expect(version).toEqual(EXPECTED_VERSION);
    expect(nativeVaultAddress).toEqual(address(MAINNET_DEDUST_NATIVE_VAULT_V2_ADDRESS));

    println("DEDUST_FACTORY_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_FACTORY_V2_ADDRESS={}", factory.address);
    println("DEDUST_FACTORY_V2_STORAGE_VERSION={}", storage.version);
    println("DEDUST_FACTORY_V2_CONFIG_HASH={}", storage.config.hash());
    println("DEDUST_FACTORY_V2_POOL_CODE_HASH={}", config.poolCode.hash());
    println("DEDUST_FACTORY_V2_LIQUIDITY_DEPOSIT_CODE_HASH={}", config.liquidityDepositCode.hash());
    println("DEDUST_FACTORY_V2_OPERATOR_CODE_HASH={}", storage.operatorCode!.hash());
    println("DEDUST_FACTORY_V2_OWNERSHIP={}", ownership);
    println("DEDUST_FACTORY_V2_VERSION={}", version);
    println("DEDUST_FACTORY_V2_NATIVE_VAULT={}", nativeVaultAddress);
}

get fun `test dedust factory v2 mainnet code hash matches fixture`() {
    val factory = mainnetDedustFactoryV2();
    val account = testing.getAccountState(factory.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("DedustFactoryV2", FIXTURE_BOC_PATH).hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Factory v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Factory v2 mainnet fixture account is frozen");
        }
    }
}
