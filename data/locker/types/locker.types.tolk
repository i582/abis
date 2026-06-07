/// Main TON locker contract that accepts deposits/rewards and coordinates per-user bill contracts.
contract Locker {
    author: "TON Core"
    version: "1.0"
    description: "Curated interface for the official TON locker contract"
    storage: LockerStorage
    incomingMessages: LockerIncomingMessage
    outgoingMessages: LockerOutgoingMessage
    thrownErrors: LockerErrors
}

/// Persistent locker campaign state stored in the root data cell.
struct LockerStorage {
    /// Total user deposit principal currently locked by the campaign, in nanotons.
    totalCoinsLocked: coins
    /// Total reward pool accumulated for depositors, in nanotons.
    totalReward: coins
    /// Unix timestamp after which deposits and reward top-ups are rejected.
    depositsEndTime: uint32
    /// Unix timestamp at which the first vesting unlock period begins.
    vestingStartTime: uint32
    /// Full vesting duration in seconds.
    vestingTotalDuration: uint32
    /// Discrete unlock step in seconds; source requires it to divide vestingTotalDuration.
    unlockPeriod: uint32
    /// Raw code cell used to derive and deploy per-user LockerBill contracts.
    billCode: cell
}

/// Internal notification sent by a LockerBill when it asks the locker to release unlocked funds.
struct (0xd6416bfe) LockerWithdrawFromBill {
    /// User address whose deterministic bill sent the request.
    userAddress: address
    /// User deposit principal tracked by the bill, in nanotons.
    totalUserDeposit: coins
    /// Previous bill withdrawal timestamp used to subtract already unlocked funds.
    lastWithdrawTime: uint32
    /// Bill-selected timestamp, normally `now()`, used by the locker vesting calculation.
    nowTime: uint32
}

/// Text-comment command accepted from users: ASCII `d` deposit, `r` reward, or `w` withdraw.
struct (0x00000000) LockerTextCommand {
    /// Single command byte after the zero text-comment opcode.
    action: uint8
}

/// Internal deposit notification emitted by Locker to a deterministic LockerBill.
struct (0x8ad026be) LockerDepositToBill {
    /// Deposit principal credited to the bill, in nanotons.
    amount: coins
}

/// Internal message bodies accepted by Locker.
type LockerIncomingMessage =
    | LockerWithdrawFromBill
    | LockerTextCommand

/// Outgoing message bodies emitted by Locker when coordinating bills.
type LockerOutgoingMessage =
    | LockerDepositToBill
    | LockerTextCommand

/// Structured result returned by `get_locker_data`.
struct GetLockerDataReply {
    /// Total user deposit principal currently locked by the campaign, in nanotons.
    totalCoinsLocked: coins
    /// Total reward pool accumulated for depositors, in nanotons.
    totalReward: coins
    /// Unix timestamp after which deposits and reward top-ups are rejected.
    depositsEndTime: uint32
    /// Unix timestamp at which the first vesting unlock period begins.
    vestingStartTime: uint32
    /// Full vesting duration in seconds.
    vestingTotalDuration: uint32
    /// Discrete unlock step in seconds.
    unlockPeriod: uint32
}

/// Locker exit-code catalog from the official FunC source.
enum LockerErrors {
    /// User withdraw command carries less than 1 TON.
    MsgValueAtLeastOneTon = 60
    /// Internal body is not a zero-op text comment when a text command is expected.
    OnlyTextCommentsSupported = 61
    /// Text command byte is not one of the accepted actions.
    InvalidComment = 62
    /// Bill-originated withdrawal request was not sent by the deterministic bill address.
    InvalidBillSender = 71
    /// Deposit or reward top-up arrived after depositsEndTime.
    DepositsTimeEnded = 72
    /// User withdraw command arrived before the first unlock period.
    WithdrawTimeNotStarted = 73
    /// Deposit command carries less than the contract's minimum deposit.
    NotEnoughCoinsForDeposit = 74
    /// Reward command carries less than the contract's minimum reward top-up.
    NotEnoughCoinsForReward = 75
    /// Stored depositsEndTime is not lower than vestingStartTime.
    InvalidStartTime = 76
    /// Stored vestingTotalDuration is not divisible by unlockPeriod.
    InvalidUnlockPeriod = 77
}

/// Return the locker campaign totals and vesting schedule.
get fun get_locker_data(): GetLockerDataReply {
    throw 0;
}

/// Return the deterministic LockerBill address for `userAddress`.
get fun get_bill_address(userAddress: address): address {
    throw 0;
}

/// Return how much of `totalAmount` is unlocked at `nowTime` under the stored vesting schedule.
get fun get_unlocked_amount(nowTime: int, totalAmount: int): coins {
    throw 0;
}

/// Return the incremental amount withdrawable by a user since `lastWithdrawTime`.
get fun get_amount_to_withdraw(nowTime: int, lastWithdrawTime: uint32, totalUserDeposit: int): coins {
    throw 0;
}
