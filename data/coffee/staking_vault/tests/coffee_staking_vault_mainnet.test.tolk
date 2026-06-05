import "@acton/build"
import "@acton/fs"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_staking_vault.types"
import "../wrappers/CoffeeStakingVault.gen"

const FIXTURE_BOC_PATH = "data/coffee/staking_vault/testdata/CoffeeStakingVault.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x99849bc5316110d1fbfd46ec823d07e17765a737c02b9ccb7fd1de3972a2a0e1

const MAINNET_COFFEE_STAKING_VAULT_ADDRESS = "EQAp-QUzk31pYQWIO5gelCfRrkEe71sI6rg_SvicSV0n31rf"
const MAINNET_COFFEE_STAKING_MASTER_ADDRESS = "EQCMtrnKhK82Yw6xHrLm_rJLkMYxeYIilhdmn6BnVGZ1PnBM"

fun mainnetCoffeeStakingVault(): CoffeeStakingVault {
    return CoffeeStakingVault.fromAddress(address(MAINNET_COFFEE_STAKING_VAULT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectOptionalCellHash(expected: cell?, actual: cell): void {
    if (expected == null) {
        expect(actual.hash()).toEqual(createEmptyCell().hash());
    } else {
        expect(actual.hash()).toEqual(expected!.hash());
    }
}

fun loadCoffeeStakingVaultStorageFromFork(vault: CoffeeStakingVault): CoffeeStakingVaultStorage {
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
            expect(code!.hash()).toEqual(build("CoffeeStakingVault", FIXTURE_BOC_PATH).hash());
            return CoffeeStakingVaultStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Staking Vault mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Staking Vault mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee staking vault code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeStakingVault", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee staking vault mainnet code hash storage and getters`() {
    val vault = mainnetCoffeeStakingVault();
    val storage = loadCoffeeStakingVaultStorageFromFork(vault);
    val storedData = vault.getStoredData();
    val masterAddress = vault.getMasterAddress();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(masterAddress).toEqual(address(MAINNET_COFFEE_STAKING_MASTER_ADDRESS));

    expect(storedData.initialized).toEqual(storage.initialized);
    expect(storedData.owner).toEqual(storage.owner);
    expectOptionalCellHash(storage.jettons, storedData.jettons);
    expectOptionalCellHash(storage.periods, storedData.periods);
    expect(storedData.masterCode.hash()).toEqual(storage.masterCode.hash());
    expect(storedData.itemCode.hash()).toEqual(storage.itemCode.hash());
}
