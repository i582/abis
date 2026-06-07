import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_vault_native_v2.types"
import "../wrappers/DedustVaultNativeV2.gen"

const FIXTURE_BOC_PATH = "data/dedust/vault_native/testdata/DedustVaultNativeV2.boc"
const DATA_FIXTURE_BOC_PATH = "data/dedust/vault_native/testdata/DedustVaultNativeV2.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x875fac5e08e5062f0f7c5c9f4c989607108e35a9ad88dc563e3e4fc7a3d3e75c
const EXPECTED_VERSION = 4
const PINNED_MAINNET_BLOCK = 71186170

const MAINNET_DEDUST_NATIVE_VAULT_V2_ADDRESS = "EQDa4VOnTYlLvDJ0gZjNYm5PXfSmmtL6Vs6A_CZEtXCNICq_"
const MAINNET_DEDUST_FACTORY_V2_ADDRESS = "EQBfBWT7X2BHg9tXAxzhz2aKiNTU1tpt5NsiK0uSDW_YAJ67"

fun mainnetDedustVaultNativeV2(): DedustVaultNativeV2 {
    return DedustVaultNativeV2.fromAddress(address(MAINNET_DEDUST_NATIVE_VAULT_V2_ADDRESS));
}

fun nativeAssetCell(): cell {
    return beginCell().storeUint(0, 4).endCell();
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectNativeAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(4)).toEqual(0);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun loadDedustVaultNativeV2StorageFromFork(vault: DedustVaultNativeV2): DedustVaultNativeV2Storage {
    val account = testing.getAccountState(vault.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("DedustVaultNativeV2", FIXTURE_BOC_PATH).hash());
            return DedustVaultNativeV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Native Vault v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Native Vault v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test dedust native vault v2 storage fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("DedustVaultNativeV2", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust native vault v2 mainnet storage and getters`() {
    val vault = mainnetDedustVaultNativeV2();
    val storage = loadDedustVaultNativeV2StorageFromFork(vault);
    val proof = storage.cachedProof.load();
    val version = vault.getVersion();
    val factory = vault.getFactoryAddr();
    var asset = vault.getAsset();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();

    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(version).toEqual(EXPECTED_VERSION);
    expect(storage.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(factory).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(storage.factoryAddr).toEqual(factory);
    expect(storage.nativeBalance).toBeGreater(0);
    expect(proof.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(proof.contractType).toEqual(1);
    expect(proof.asset.toCell().hash()).toEqual(nativeAssetCell().hash());
    expect(storage.blankCode.hash()).toBeGreater(0);
    expectNativeAssetSlice(mutate asset);

    println("DEDUST_NATIVE_VAULT_V2_STORAGE_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE_ADDRESS={}", vault.address);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE_VERSION={}", storage.version);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE_FACTORY={}", storage.factoryAddr);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE_NATIVE_BALANCE={}", storage.nativeBalance);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE_CACHED_PROOF={}", proof);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE_BLANK_CODE_HASH={}", storage.blankCode.hash());
}
