import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/locker.types"
import "../types/locker_bill.types"
import "../wrappers/Locker.gen"
import "../wrappers/LockerBill.gen"

const MAINNET_LOCKER_ADDRESS = "EQDtFpEwcFAEcRe5mLVh2N6C0x-_hJEM7W61_JLnSF74p4q2"
const MAINNET_LOCKER_BILL_ADDRESS = "EQAMOAT3OoX8weD8Z4IlkEL-M2WQxg3Dz4KFeMBoWjkgSykt"
const MAINNET_LOCKER_VARIANT_ADDRESS = "EQCxTD5GdQ3IVw830nrOEfT9k8c2k1Wqm7rcCTny-cW2Kvyo"

fun mainnetLocker(): Locker {
    return Locker.fromAddress(address(MAINNET_LOCKER_ADDRESS));
}

fun mainnetLockerBill(): LockerBill {
    return LockerBill.fromAddress(address(MAINNET_LOCKER_BILL_ADDRESS));
}

fun loadLockerStorageFromFork(locker: Locker): LockerStorage {
    val account = testing.getAccountState(locker.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return LockerStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Locker mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Locker mainnet fixture account is frozen");
        }
    }
}

fun loadLockerBillStorageFromFork(bill: LockerBill): LockerBillStorage {
    val account = testing.getAccountState(bill.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return LockerBillStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("LockerBill mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("LockerBill mainnet fixture account is frozen");
        }
    }
}

get fun `test locker mainnet getters and storage`() {
    val locker = mainnetLocker();
    val storage = loadLockerStorageFromFork(locker);
    val lockerData = locker.getLockerData();
    val unlockedNow = locker.getUnlockedAmount(blockchain.now(), ton("1"));

    expect(scripts.isContractDeployed(locker.address)).toBeTrue();
    expect(lockerData.totalCoinsLocked).toEqual(storage.totalCoinsLocked);
    expect(lockerData.totalReward).toEqual(storage.totalReward);
    expect(lockerData.depositsEndTime).toEqual(storage.depositsEndTime);
    expect(lockerData.vestingStartTime).toEqual(storage.vestingStartTime);
    expect(lockerData.vestingTotalDuration).toEqual(storage.vestingTotalDuration);
    expect(lockerData.unlockPeriod).toEqual(storage.unlockPeriod);
    expect(unlockedNow).toBeGreaterOrEqual(0);

    println("LOCKER_MAINNET_ADDRESS={}", locker.address);
    println("LOCKER_MAINNET_STORAGE={}", storage);
    println("LOCKER_MAINNET_DATA={}", lockerData);
    println("LOCKER_MAINNET_UNLOCKED_NOW={}", unlockedNow);
}

get fun `test locker bill mainnet getters storage and parent relation`() {
    val bill = mainnetLockerBill();
    val billStorage = loadLockerBillStorageFromFork(bill);
    val billData = bill.getLockerBillData();
    val parentLocker = Locker.fromAddress(billData.lockerAddress);
    val parentLockerData = parentLocker.getLockerData();
    val expectedBillAddress = parentLocker.getBillAddress(billData.userAddress);
    val withdrawableNow = parentLocker.getAmountToWithdraw(
        blockchain.now(),
        billData.lastWithdrawTime,
        billData.totalCoinsDeposit,
    );

    expect(scripts.isContractDeployed(bill.address)).toBeTrue();
    expect(scripts.isContractDeployed(parentLocker.address)).toBeTrue();
    expect(billData.lockerAddress).toEqual(billStorage.lockerAddress);
    expect(billData.totalCoinsDeposit).toEqual(billStorage.totalCoinsDeposit);
    expect(billData.userAddress).toEqual(billStorage.userAddress);
    expect(billData.lastWithdrawTime).toEqual(billStorage.lastWithdrawTime);
    expect(expectedBillAddress).toEqual(bill.address);
    expect(parentLockerData.vestingTotalDuration).toBeGreater(0);
    expect(parentLockerData.unlockPeriod).toBeGreater(0);
    expect(withdrawableNow).toBeGreaterOrEqual(0);

    println("LOCKER_BILL_MAINNET_ADDRESS={}", bill.address);
    println("LOCKER_BILL_MAINNET_STORAGE={}", billStorage);
    println("LOCKER_BILL_MAINNET_DATA={}", billData);
    println("LOCKER_BILL_MAINNET_PARENT={}", parentLocker.address);
    println("LOCKER_BILL_MAINNET_WITHDRAWABLE_NOW={}", withdrawableNow);
}

get fun `test locker variant mainnet getters and storage`() {
    val locker = Locker.fromAddress(address(MAINNET_LOCKER_VARIANT_ADDRESS));
    val storage = loadLockerStorageFromFork(locker);
    val lockerData = locker.getLockerData();

    expect(scripts.isContractDeployed(locker.address)).toBeTrue();
    expect(lockerData.totalCoinsLocked).toEqual(storage.totalCoinsLocked);
    expect(lockerData.totalReward).toEqual(storage.totalReward);
    expect(lockerData.depositsEndTime).toEqual(storage.depositsEndTime);
    expect(lockerData.vestingStartTime).toEqual(storage.vestingStartTime);
    expect(lockerData.vestingTotalDuration).toEqual(storage.vestingTotalDuration);
    expect(lockerData.unlockPeriod).toEqual(storage.unlockPeriod);

    println("LOCKER_VARIANT_MAINNET_ADDRESS={}", locker.address);
    println("LOCKER_VARIANT_MAINNET_STORAGE={}", storage);
    println("LOCKER_VARIANT_MAINNET_DATA={}", lockerData);
}
