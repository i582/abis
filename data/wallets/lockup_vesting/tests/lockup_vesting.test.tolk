import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/lockup_vesting.types"
import "../wrappers/LockupVesting.gen"

const TEST_SUBWALLET_ID = 698983191
const TEST_PUBLIC_KEY = 1
const TEST_START_TIME = 1700000000
const TEST_TOTAL_DURATION = 31104000
const TEST_UNLOCK_PERIOD = 2592000
const TEST_CLIFF_DURATION = 5184000

fun zeroSignature(): bits512 {
    var signature = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 256)
        .endCell()
        .beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyOutgoingTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun lockupVestingStorage(): LockupVestingStorage {
    return {
        seqno: 0,
        subwalletId: TEST_SUBWALLET_ID,
        publicKey: TEST_PUBLIC_KEY,
        startTime: TEST_START_TIME,
        totalDuration: TEST_TOTAL_DURATION,
        unlockPeriod: TEST_UNLOCK_PERIOD,
        cliffDuration: TEST_CLIFF_DURATION,
        totalAmount: ton("100"),
        allowElector: false,
    };
}

fun deployLockupVesting(): LockupVesting {
    val sender = testing.treasury("lockup-vesting-local-deployer");
    val wallet = LockupVesting.fromStorage(lockupVestingStorage());

    val txs = wallet.deploy(sender.address, { value: ton("1"), bounce: false });
    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });

    return wallet;
}

get fun `test lockup vesting local getters through wrapper`() {
    val wallet = deployLockupVesting();
    val lockupData = wallet.getLockupData();

    expect(wallet.seqno()).toEqual(0);
    expect(wallet.getPublicKey()).toEqual(TEST_PUBLIC_KEY);
    expect(lockupData.startTime).toEqual(TEST_START_TIME);
    expect(lockupData.totalDuration).toEqual(TEST_TOTAL_DURATION);
    expect(lockupData.unlockPeriod).toEqual(TEST_UNLOCK_PERIOD);
    expect(lockupData.cliffDuration).toEqual(TEST_CLIFF_DURATION);
    expect(lockupData.totalAmount).toEqual(ton("100"));
    expect(lockupData.allowElector).toBeFalse();
}

get fun `test lockup vesting local locked amount schedule`() {
    val wallet = deployLockupVesting();

    expect(wallet.getLockedAmount(TEST_START_TIME - 1)).toEqual(ton("100"));
    expect(wallet.getLockedAmount(TEST_START_TIME + TEST_TOTAL_DURATION + 1)).toEqual(0);
}

get fun `test lockup vesting local rejects invalid external signature`() {
    val wallet = deployLockupVesting();

    val result = wallet.sendExternalLockupVestingSignedExternal(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptyOutgoingTail(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
