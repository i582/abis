import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_position_manager.types"
import "../wrappers/StormPositionManager.gen"

const EXPECTED_CODE_HASH = 0x18c7ed8bf5d65996f0a19ec48e93c5f674cc0fbad210ca5b8e06ff7e03c7589e
const PINNED_MAINNET_BLOCK = 71588633

const MAINNET_POSITION_MANAGER_ADDRESS = "EQCoTFvejJcAm5J0gZYLS88Ce0PATCRV4hF5MEdfGaLZuAPm"
const MAINNET_TRADER_ADDRESS = "0:d831edf7b738514f7c7783719e1f3775ba5af00bd08226f737bb58c63db945d1"
const MAINNET_VAULT_ADDRESS = "0:33e9e84d7cbefff0d23b395875420e3a1ecb82e241692be89c7ea2bd27716b77"
const MAINNET_VAMM_ADDRESS = "0:3c9316d4a2f2b6a76d69e794bd89903499b5f798f66eb3afeb0241e2a16f6236"
const MAINNET_REFERRAL_ADDRESS = "0:ecc63e6669c64b30b3af569ce9eb83e8eb6dbe4bd88d821400ed646a0a4ba85b"

fun mainnetStormPositionManager(): StormPositionManagerLibrary {
    return StormPositionManagerLibrary.fromAddress(address(MAINNET_POSITION_MANAGER_ADDRESS));
}

fun expectEmptyCell(cellValue: cell): void {
    expect(cellValue.hash()).toEqual(createEmptyCell().hash());
}

fun loadStormPositionManagerStorageFromFork(pm: StormPositionManagerLibrary): StormPositionManagerStorage {
    val account = testing.getAccountState(pm.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return StormPositionManagerStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm PositionManager representative account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm PositionManager representative account is frozen");
        }
    }
}

get fun `test storm position manager mainnet storage and getters`() {
    val pm = mainnetStormPositionManager();
    val storage = loadStormPositionManagerStorageFromFork(pm);
    val getterData = pm.getPositionManagerData();
    val contractData = pm.getPositionManagerContractData();

    expect(scripts.isContractDeployed(pm.address)).toBeTrue();
    expect(pm.getVersion()).toEqual(4);
    expect(pm.getIsInited()).toBeTrue();

    expect(storage.traderAddress).toEqual(address(MAINNET_TRADER_ADDRESS));
    expect(storage.vaultAddress).toEqual(address(MAINNET_VAULT_ADDRESS));
    expect(storage.vammAddress).toEqual(address(MAINNET_VAMM_ADDRESS));
    expect(storage.longRecord).toBeNull();
    expect(storage.shortRecord).toBeNull();
    expect(storage.ordersDict).toBeNull();
    expect(storage.referralData).toBeNotNull();
    expect(storage.ordersBitset).toEqual(0xff);

    val referralData = storage.referralData!.load();
    expect(referralData.referralAddress).toEqual(address(MAINNET_REFERRAL_ADDRESS));

    expect(getterData.traderAddress).toEqual(storage.traderAddress);
    expect(getterData.vaultAddress).toEqual(storage.vaultAddress);
    expect(getterData.vammAddress).toEqual(storage.vammAddress);
    expect(getterData.ordersBitset).toEqual(storage.ordersBitset);
    expectEmptyCell(getterData.longRecord);
    expectEmptyCell(getterData.shortRecord);
    expectEmptyCell(getterData.ordersDict);
    expect(getterData.referralData.hash()).toEqual(storage.referralData!.hash());
    expect(contractData.hash()).toBeGreater(0);

    println("STORM_POSITION_MANAGER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_POSITION_MANAGER_ADDRESS={}", pm.address);
    println("STORM_POSITION_MANAGER_STORAGE={}", storage);
    println("STORM_POSITION_MANAGER_GETTER_DATA={}", getterData);
}
