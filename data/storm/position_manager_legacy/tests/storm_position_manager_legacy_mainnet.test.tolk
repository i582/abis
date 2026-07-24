import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_position_manager_legacy.types"
import "../wrappers/StormPositionManagerLegacy.gen"

const EXPECTED_LEGACY_CODE_HASH = 0x8b96b5976adb19f320ae9f5ce766d3d4e383b06703c0b1771b35d6fa5936c45f
const PINNED_MAINNET_BLOCK = 81741761
const MAINNET_LEGACY_POSITION_MANAGER_ADDRESS = "EQDtv6ZjIj1mCbeD9Agi7Ug1Rubp58w3nIn8BME8rNiwm9Wz"
const MAINNET_TRADER_ADDRESS = "EQAvCSdbLjTb2zoEvoRduNRbg1qA-W2pw6z5ZaECPGAPZZ5p"
const MAINNET_VAULT_ADDRESS = "EQDpJnZP89Jyxz3euDaXXFUhwCWtaOeRmiUJTi3jGYgF8fnj"
const MAINNET_VAMM_ADDRESS = "EQAkHkgOmtsM30Di4-w7sM9ST7UgzKArLikuc0gXvCkf-39Z"
const MAINNET_REFERRAL_ADDRESS = "EQDsxj5macZLMLOvVpzp64Po622-S9iNghQA7WRqCkuoW4x9"

fun mainnetLegacyPositionManager(): StormPositionManagerLegacy {
    return StormPositionManagerLegacy.fromAddress(address(MAINNET_LEGACY_POSITION_MANAGER_ADDRESS));
}

fun expectEmptyCell(cellValue: cell): void {
    expect(cellValue.hash()).toEqual(createEmptyCell().hash());
}

fun loadLegacyPositionManagerStorageFromFork(
    pm: StormPositionManagerLegacy,
): StormPositionManagerStorage {
    val account = testing.getAccountState(pm.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_LEGACY_CODE_HASH);
            return StormPositionManagerStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Legacy Storm PositionManager representative account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Legacy Storm PositionManager representative account is frozen");
        }
    }
}

get fun `test legacy storm position manager mainnet storage and getters`() {
    val pm = mainnetLegacyPositionManager();
    val storage = loadLegacyPositionManagerStorageFromFork(pm);
    val getterData = pm.getPositionManagerData();
    val contractData = pm.getPositionManagerContractData();

    expect(scripts.isContractDeployed(pm.address)).toBeTrue();
    expect(pm.getVersion()).toEqual(4);
    expect(pm.getIsInited()).toEqual(storage.referralData != null);

    expect(storage.traderAddress).toEqual(address(MAINNET_TRADER_ADDRESS));
    expect(storage.vaultAddress).toEqual(address(MAINNET_VAULT_ADDRESS));
    expect(storage.vammAddress).toEqual(address(MAINNET_VAMM_ADDRESS));
    expect(storage.longRecord).toBeNull();
    expect(storage.shortRecord).toBeNull();
    expect(storage.ordersDict.isEmpty()).toBeTrue();
    expect(storage.referralData).toBeNotNull();
    expect(storage.ordersBitset).toEqual(0xff);

    val referralData = storage.referralData!.load();
    expect(referralData.referralAddress).toEqual(address(MAINNET_REFERRAL_ADDRESS));
    expect(referralData.discount).toEqual(50000000);
    expect(referralData.rebate).toEqual(100000000);

    expect(getterData.traderAddress).toEqual(storage.traderAddress);
    expect(getterData.vaultAddress).toEqual(storage.vaultAddress);
    expect(getterData.vammAddress).toEqual(storage.vammAddress);
    expect(getterData.ordersBitset).toEqual(storage.ordersBitset);
    expectEmptyCell(getterData.longRecord);
    expectEmptyCell(getterData.shortRecord);
    expectEmptyCell(getterData.ordersDict);
    expect(getterData.referralData.hash()).toEqual(storage.referralData!.hash());
    expect(contractData.hash()).toBeGreater(0);

    println("STORM_POSITION_MANAGER_LEGACY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_POSITION_MANAGER_LEGACY_ADDRESS={}", pm.address);
    println("STORM_POSITION_MANAGER_LEGACY_STORAGE={}", storage);
    println("STORM_POSITION_MANAGER_LEGACY_GETTER_DATA={}", getterData);
}
