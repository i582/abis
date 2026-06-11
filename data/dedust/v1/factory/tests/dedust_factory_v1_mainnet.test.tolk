import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_factory_v1.types"
import "../wrappers/DedustFactoryV1.gen"

const CODE_FIXTURE_BOC_PATH = "data/dedust/v1/factory/testdata/DedustFactoryV1.boc"
const DATA_FIXTURE_BOC_PATH = "data/dedust/v1/factory/testdata/DedustFactoryV1.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa17fa1eb974c6ffe435da078b233a808e0d52dad01a6905504d5fe87d6e51031
const EXPECTED_DATA_HASH = 0x96c0c339897192162140593abb1cde7ded70eb5ed4309814c969aec3ea3ed948
const EXPECTED_VERSION = 1
const PINNED_MAINNET_BLOCK = 71185104

const MAINNET_DEDUST_FACTORY_V1_ADDRESS = "EQBVZVImPUeKTtheqvT1PFmgj8GzTpnupkqc1Q2lUNF6ttt-"
const EXPECTED_OWNER_ADDRESS = "EQCX7dp6XRayRzFGZI8j1pB0EacanTCwzhoOEh26jdaF9avu"

fun mainnetDedustFactoryV1(): DedustFactoryV1 {
    return DedustFactoryV1.fromAddress(address(MAINNET_DEDUST_FACTORY_V1_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadDedustFactoryV1StorageFromFork(factory: DedustFactoryV1): DedustFactoryV1Storage {
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
            expect(code!.hash()).toEqual(build("DedustFactoryV1", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return DedustFactoryV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Factory v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Factory v1 mainnet fixture account is frozen");
        }
    }
}

fun expectDedustFactoryV1StorageCore(storage: DedustFactoryV1Storage): DedustFactoryV1Config {
    val config = storage.config.load();

    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(storage.pendingOwnerAddress).toBeNull();
    expect(storage.canAcceptAfter).toEqual(0);
    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(storage.blankCode.hash()).toBeGreater(0);
    expect(storage.config.hash()).toBeGreater(0);
    expect(storage.toCell().hash()).toEqual(EXPECTED_DATA_HASH);

    expect(config.poolCodeVersion).toBeGreater(0);
    expect(config.poolCode.hash()).toBeGreater(0);
    expect(config.liquidityDepositCodeVersion).toBeGreater(0);
    expect(config.liquidityDepositCode.hash()).toBeGreater(0);
    expect(config.vaultCodeByAssetType).toBeNotNull();
    expect(config.vaultCodeByAssetType!.hash()).toBeGreater(0);
    expect(config.lpWalletCode.hash()).toBeGreater(0);

    return config;
}

get fun `test dedust factory v1 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val codeFromFixture = build("DedustFactoryV1", CODE_FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustFactoryV1");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test dedust factory v1 wrapper creates mainnet address`() {
    val factory = mainnetDedustFactoryV1();
    expect(factory.address).toEqual(address(MAINNET_DEDUST_FACTORY_V1_ADDRESS));
}

get fun `test dedust factory v1 mainnet storage and getters`() {
    val factory = mainnetDedustFactoryV1();
    val storage = loadDedustFactoryV1StorageFromFork(factory);
    val config = expectDedustFactoryV1StorageCore(storage);
    val ownership = factory.getOwnership();
    val version = factory.getVersion();

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();
    expect(version).toEqual(EXPECTED_VERSION);
    expect(ownership.ownerAddress.castToInternal()).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(ownership.pendingOwnerAddress).toBeNoneAddress();
    expect(ownership.canAcceptAfter).toEqual(0);

    expect(storage.ownerAddress).toEqual(ownership.ownerAddress.castToInternal());
    expect(storage.canAcceptAfter).toEqual(ownership.canAcceptAfter);

    println("DEDUST_FACTORY_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_FACTORY_V1_ADDRESS={}", factory.address);
    println("DEDUST_FACTORY_V1_STORAGE_VERSION={}", storage.version);
    println("DEDUST_FACTORY_V1_DATA_HASH={}", storage.toCell().hash());
    println("DEDUST_FACTORY_V1_CONFIG_HASH={}", storage.config.hash());
    println("DEDUST_FACTORY_V1_POOL_CODE_VERSION={}", config.poolCodeVersion);
    println("DEDUST_FACTORY_V1_POOL_CODE_HASH={}", config.poolCode.hash());
    println("DEDUST_FACTORY_V1_LIQUIDITY_DEPOSIT_CODE_VERSION={}", config.liquidityDepositCodeVersion);
    println("DEDUST_FACTORY_V1_LIQUIDITY_DEPOSIT_CODE_HASH={}", config.liquidityDepositCode.hash());
    println("DEDUST_FACTORY_V1_OWNER={}", ownership.ownerAddress);
    println("DEDUST_FACTORY_V1_VERSION={}", version);
}
