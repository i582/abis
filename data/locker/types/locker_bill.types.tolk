/// Per-user bill contract for TON Locker deposits and withdrawal accounting.
contract LockerBill {
    author: "TON Core"
    version: "1.0"
    description: "Curated interface for the official TON locker bill contract"
    storage: LockerBillStorage
    incomingMessages: LockerBillIncomingMessage
    outgoingMessages: LockerBillOutgoingMessage
    thrownErrors: LockerBillErrors
}

/// Persistent state stored by a deterministic per-user LockerBill.
struct LockerBillStorage {
    /// Parent Locker address allowed to credit deposits and trigger withdraw requests.
    lockerAddress: address
    /// User deposit principal tracked by this bill, in nanotons.
    totalCoinsDeposit: coins
    /// User address allowed to recover accidental direct transfers to the bill.
    userAddress: address
    /// Last withdrawal timestamp recorded by this bill.
    lastWithdrawTime: uint32
}

/// Internal deposit notification accepted only from the parent Locker.
struct (0x8ad026be) LockerBillDepositToBill {
    /// Deposit principal added to this bill, in nanotons.
    amount: coins
}

/// Text-comment command accepted by LockerBill: ASCII `w` withdraw or `e` emergency recover.
struct (0x00000000) LockerBillTextCommand {
    /// Single command byte after the zero text-comment opcode.
    action: uint8
}

/// Withdrawal request emitted by LockerBill to the parent Locker.
struct (0xd6416bfe) LockerBillWithdrawFromBill {
    /// User address stored by this bill.
    userAddress: address
    /// User deposit principal tracked by this bill, in nanotons.
    totalCoinsDeposit: coins
    /// Previous withdrawal timestamp stored before this request.
    lastWithdrawTime: uint32
    /// Current timestamp captured by the bill for the locker calculation.
    nowTime: uint32
}

/// Internal message bodies accepted by LockerBill.
type LockerBillIncomingMessage =
    | LockerBillDepositToBill
    | LockerBillTextCommand

/// Outgoing message bodies emitted by LockerBill.
type LockerBillOutgoingMessage = LockerBillWithdrawFromBill

/// Structured result returned by `get_locker_bill_data`.
struct GetLockerBillDataReply {
    /// Parent Locker address allowed to send control messages to this bill.
    lockerAddress: address
    /// User deposit principal tracked by this bill, in nanotons.
    totalCoinsDeposit: coins
    /// User address associated with this deterministic bill.
    userAddress: address
    /// Last withdrawal timestamp recorded by this bill.
    lastWithdrawTime: uint32
}

/// LockerBill exit-code catalog from the official FunC source.
enum LockerBillErrors {
    /// Internal body is not a zero-op text comment when a text command is expected.
    OnlyTextCommentsSupported = 61
    /// Text command byte is not one of the accepted actions.
    InvalidComment = 62
    /// Deposit or withdraw command was not sent by the parent Locker.
    OnlyLockerAddress = 80
    /// Emergency recover command was not sent by the stored user address.
    OnlyUserAddress = 82
}

/// Return the parent locker, user deposit, user address, and last withdrawal timestamp.
get fun get_locker_bill_data(): GetLockerBillDataReply {
    throw 0;
}
