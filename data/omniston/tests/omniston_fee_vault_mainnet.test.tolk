import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/omniston_fee_vault.types"
import "../wrappers/OmnistonFeeVault.gen"

const CODE_FIXTURE_BOC_PATH = "data/omniston/testdata/OmnistonFeeVault.boc"
const DATA_FIXTURE_BOC_PATH = "data/omniston/testdata/OmnistonFeeVault.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfc8df8be21d83d3876984d7859c078c916dfd7654bc465bf9cd64602eeb4c587
const EXPECTED_DATA_HASH = 0xcee9be20993381cfb35c26896bfa14434d3eafca6ebd622fe37af784c7cf5378
const EXPECTED_MINTER_ID = 10
const PINNED_MAINNET_BLOCK = 75037858

const MAINNET_OMNISTON_FEE_VAULT_ADDRESS = "EQCcJf2KFlH9xIx3dztytxxRFk3KQZKEYBr-f0nFIO1h3dvv"
const MAINNET_OMNISTON_ADMIN_ADDRESS = "EQCppzUtmGSMg3FIRlFLzhToqbaC0xjmjzOn0o7H4M8Aua1t"
const MAINNET_SAMPLE_OWNER = "EQAiQHPch9EQA2EibZoczqqJ0bgkm9m5sixgE7NdIXD7S3bf"
const MAINNET_SAMPLE_TOKEN_WALLET = "EQCSLWJ9fY7b0A5OI72wxUp27l4fRlc6GvRBeFf6PiPpH4p3"
const MAINNET_SAMPLE_FEE_VAULT = "EQBsRwAmHESuWRu_Nv-CdGKH_gIMR0utsgJJkwuXpgzL0jVu"

struct LoadedOmnistonFeeVaultStorage {
    data: cell
    storage: OmnistonFeeVaultStorage
}

fun mainnetOmnistonFeeVault(): OmnistonFeeVault {
    return OmnistonFeeVault.fromAddress(address(MAINNET_OMNISTON_FEE_VAULT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadOmnistonFeeVaultStorageFixture(): LoadedOmnistonFeeVaultStorage {
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawData!)).toBeTrue();

    val data = build("OmnistonFeeVaultData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return LoadedOmnistonFeeVaultStorage {
        data,
        storage: OmnistonFeeVaultStorage.fromCell(data),
    };
}

fun loadOmnistonFeeVaultStorageFromFork(vault: OmnistonFeeVault): OmnistonFeeVaultStorage {
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
            expect(code!.hash()).toEqual(build("OmnistonFeeVault").hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return OmnistonFeeVaultStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Omniston Fee-Vault Minter mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Omniston Fee-Vault Minter mainnet fixture account is frozen");
        }
    }
}

fun expectMinterDataMatchesStorage(
    minterData: OmnistonFeeVaultMinterDataReply,
    storage: OmnistonFeeVaultStorage,
): void {
    expect(minterData.id).toEqual(storage.id);
    expect(minterData.adminAddress.castToInternal()).toEqual(storage.adminAddress);
    expect(minterData.tempUpgradeUntil).toEqual(storage.tempUpgradeUntil);
    expect(minterData.tempCode.hash()).toEqual(storage.tempCode.hash());
    expect(minterData.tempData.hash()).toEqual(storage.tempData.hash());
    expect(minterData.vaultCode.hash()).toEqual(storage.vaultCode.hash());
}

get fun `test omniston fee vault code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("OmnistonFeeVault", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("OmnistonFeeVault").hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("OmnistonFeeVaultData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test omniston fee vault saved data fixture parses storage`() {
    val loaded = loadOmnistonFeeVaultStorageFixture();
    expect(loaded.storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(loaded.storage.id).toEqual(EXPECTED_MINTER_ID);
    expect(loaded.storage.adminAddress).toEqual(address(MAINNET_OMNISTON_ADMIN_ADDRESS));
    expect(loaded.storage.tempUpgradeUntil).toEqual(0);
    expect(loaded.storage.tempCode.hash()).toEqual(createEmptyCell().hash());
    expect(loaded.storage.tempData.hash()).toEqual(createEmptyCell().hash());
    expect(loaded.storage.vaultCode.hash()).toBeGreater(0);

    println("OMNISTON_FEE_VAULT_DATA_HASH={}", loaded.data.hash());
    println("OMNISTON_FEE_VAULT_STORAGE={}", loaded.storage);
}

get fun `test omniston fee vault mainnet getters storage and derived address`() {
    val vault = mainnetOmnistonFeeVault();
    val storage = loadOmnistonFeeVaultStorageFromFork(vault);
    val minterData = vault.getMinterData();
    val version = vault.getVersion();
    val derivedVault = vault.getVaultAddress(
        address(MAINNET_SAMPLE_OWNER),
        address(MAINNET_SAMPLE_TOKEN_WALLET),
    );

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expectMinterDataMatchesStorage(minterData, storage);
    expect(minterData.id).toEqual(EXPECTED_MINTER_ID);
    expect(minterData.adminAddress.castToInternal()).toEqual(address(MAINNET_OMNISTON_ADMIN_ADDRESS));
    expect(minterData.tempUpgradeUntil).toEqual(0);

    expect(version.major).toEqual(0);
    expect(version.minor).toEqual(4);
    expect(version.development).toEqual("beta2.0");

    expect(derivedVault.castToInternal()).toEqual(address(MAINNET_SAMPLE_FEE_VAULT));

    println("OMNISTON_FEE_VAULT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("OMNISTON_FEE_VAULT_ADDRESS={}", vault.address);
    println("OMNISTON_FEE_VAULT_MINTER_DATA={}", minterData);
    println("OMNISTON_FEE_VAULT_VERSION={}", version);
    println("OMNISTON_FEE_VAULT_DERIVED_ADDRESS={}", derivedVault);
}
