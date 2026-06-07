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
const LIQUIDITY_DEPOSIT_FIXTURE_BOC_PATH = "data/dedust/liquidity_deposit/testdata/DedustLiquidityDepositV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe64d0059486e3cbe14bd70572295d06d79e847cb4017eac1aa65d82009eaa20c
const EXPECTED_FACTORY_POOL_CODE_HASH = 0x778f0d3fe6482c50888970df5e787f40f3a4ab282170c035a5920877058c99d3
const EXPECTED_LIQUIDITY_DEPOSIT_CODE_HASH = 0x80edc8d7bbbb6526c3b06ccb7c2d02a82c20d8ccdf431bf4088b1f1470cc94cc
const EXPECTED_VERSION = 5
const PINNED_MAINNET_BLOCK = 71185104

const MAINNET_DEDUST_FACTORY_V2_ADDRESS = "EQBfBWT7X2BHg9tXAxzhz2aKiNTU1tpt5NsiK0uSDW_YAJ67"
const MAINNET_DEDUST_NATIVE_VAULT_V2_ADDRESS = "EQDa4VOnTYlLvDJ0gZjNYm5PXfSmmtL6Vs6A_CZEtXCNICq_"
const MAINNET_DEDUST_POOL_V2_VOLATILE_ADDRESS = "EQA-X_yo3fzzbDbJ_0bzFWKqtRuZFIRa1sJsveZJ1YpViO3r"
const MAINNET_DEDUST_LIQUIDITY_DEPOSIT_V2_ADDRESS = "EQCDfi69jD02bImrXQGB_PXAOq3UO95ywF1-6Bnxkh90uU9Q"
const MAINNET_DEDUST_OWNER_ADDRESS = "EQCwhpDIOXevtrSRj6MTnR-flPM_EDH-AziwiP4uAJ0e6Z6z"
const MAINNET_USDT_ASSET_HASH = 0xb113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe

fun mainnetDedustFactoryV2(): DedustFactoryV2 {
    return DedustFactoryV2.fromAddress(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
}

fun nativeAssetSlice(): slice {
    return beginCell().storeUint(0, 4).endCell().beginParse();
}

fun usdtAssetSlice(): slice {
    return beginCell()
        .storeUint(1, 4)
        .storeInt(0, 8)
        .storeUint(MAINNET_USDT_ASSET_HASH, 256)
        .endCell()
        .beginParse();
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

get fun `test dedust factory v2 storage code boc fixture is real`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();
    expect(build("DedustFactoryV2", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust factory v2 mainnet storage and getters`() {
    val factory = mainnetDedustFactoryV2();
    val storage = loadDedustFactoryV2StorageFromFork(factory);
    val config = storage.config.load();
    val ownership = factory.getOwnership();
    val version = factory.getVersion();
    val nativeVaultAddress = factory.getVaultAddress(nativeAssetSlice());
    val poolAddress = factory.getPoolAddress(0, nativeAssetSlice(), usdtAssetSlice());
    val liquidityDepositAddress = factory.getLiquidityDepositAddress(
        address(MAINNET_DEDUST_OWNER_ADDRESS),
        0,
        nativeAssetSlice(),
        usdtAssetSlice(),
    );

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();

    expect(storage.ownerAddress).toEqual(ownership.ownerAddress.castToInternal());
    expect(storage.pendingOwnerAddress).toBeNull();
    expect(ownership.pendingOwnerAddress).toBeNoneAddress();
    expect(storage.canAcceptAfter).toEqual(ownership.canAcceptAfter);
    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(version).toEqual(EXPECTED_VERSION);

    expect(storage.blankCode.hash()).toBeGreater(0);
    expect(storage.config.hash()).toBeGreater(0);
    expect(storage.operatorCodeVersion).toBeGreater(0);
    expect(storage.operatorCode).toBeNotNull();
    expect(storage.operatorCode!.hash()).toBeGreater(0);

    expect(config.poolCodeVersion).toBeGreater(0);
    expect(config.poolCode.hash()).toEqual(EXPECTED_FACTORY_POOL_CODE_HASH);
    expect(config.liquidityDepositCodeVersion).toBeGreater(0);
    expect(config.liquidityDepositCode.hash()).toEqual(EXPECTED_LIQUIDITY_DEPOSIT_CODE_HASH);
    expect(config.liquidityDepositCode.hash()).toEqual(
        build("DedustLiquidityDepositV2", LIQUIDITY_DEPOSIT_FIXTURE_BOC_PATH).hash(),
    );
    expect(config.vaultCodeByAssetType).toBeNotNull();
    expect(config.vaultCodeByAssetType!.hash()).toBeGreater(0);
    expect(config.lpWalletCode.hash()).toBeGreater(0);

    expect(nativeVaultAddress).toEqual(address(MAINNET_DEDUST_NATIVE_VAULT_V2_ADDRESS));
    expect(poolAddress).toEqual(address(MAINNET_DEDUST_POOL_V2_VOLATILE_ADDRESS));
    expect(liquidityDepositAddress).toEqual(address(MAINNET_DEDUST_LIQUIDITY_DEPOSIT_V2_ADDRESS));

    println("DEDUST_FACTORY_V2_STORAGE_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_FACTORY_V2_STORAGE_ADDRESS={}", factory.address);
    println("DEDUST_FACTORY_V2_STORAGE_VERSION={}", storage.version);
    println("DEDUST_FACTORY_V2_STORAGE_CONFIG_HASH={}", storage.config.hash());
    println("DEDUST_FACTORY_V2_POOL_CODE_VERSION={}", config.poolCodeVersion);
    println("DEDUST_FACTORY_V2_POOL_CODE_HASH={}", config.poolCode.hash());
    println(
        "DEDUST_FACTORY_V2_LIQUIDITY_DEPOSIT_CODE_VERSION={}",
        config.liquidityDepositCodeVersion,
    );
    println("DEDUST_FACTORY_V2_LIQUIDITY_DEPOSIT_CODE_HASH={}", config.liquidityDepositCode.hash());
    println("DEDUST_FACTORY_V2_OPERATOR_CODE_VERSION={}", storage.operatorCodeVersion);
    println("DEDUST_FACTORY_V2_OPERATOR_CODE_HASH={}", storage.operatorCode!.hash());
}
