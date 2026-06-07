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

get fun `test dedust native vault v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("DedustVaultNativeV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust native vault v2 mainnet safe getters and storage`() {
    val vault = mainnetDedustVaultNativeV2();
    val storage = loadDedustVaultNativeV2StorageFromFork(vault);
    val proof = storage.cachedProof.load();
    var assetSlice = vault.getAsset();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(storage.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(storage.nativeBalance).toBeGreater(0);
    expect(proof.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(proof.contractType).toEqual(1);
    expect(proof.asset.toCell().hash()).toEqual(nativeAssetCell().hash());
    expect(storage.blankCode.hash()).toBeGreater(0);

    expect(vault.getVersion()).toEqual(EXPECTED_VERSION);
    expect(vault.getFactoryAddr()).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(assetSlice.loadUint(4)).toEqual(0);
    expect(assetSlice.remainingBitsCount()).toEqual(0);
    expect(assetSlice.remainingRefsCount()).toEqual(0);

    println("DEDUST_NATIVE_VAULT_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_NATIVE_VAULT_V2_ADDRESS={}", vault.address);
    println("DEDUST_NATIVE_VAULT_V2_STORAGE={}", storage);
    println("DEDUST_NATIVE_VAULT_V2_CACHED_PROOF={}", proof);
}
