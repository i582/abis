import "./tonfun_bcl_wallet_common.types"

/// TonFun bonding-curve Jetton wallet revision with an uncorrelated unlock confirmation.
contract TonFunBclWalletV1 {
    author: "TonFun"
    version: "1"
    description: "TonFun BCL Wallet V1 stores a locked Jetton balance and relays sell and unlock requests to its master."
    storage: TonFunBclWalletStorage
    incomingMessages: TonFunBclWalletV1IncomingMessage
    outgoingMessages: TonFunBclWalletV1OutgoingMessage
    forceAbiExport: TonFunBclWalletV1EmptyBody | TonFunBclWalletBouncedKnownBody
    thrownErrors: TonFunBclWalletErrors
}

/// Master confirmation that unlocks V1; all bits after the opcode are ignored.
struct (0xa8ce3fe7) TonFunBclWalletV1UnlockConfirmation {
    /// Optional legacy tail ignored by the implementation.
    remainder: RemainingBitsAndRefs
}

/// Untagged body emitted to the owner after a V1 unlock confirmation.
struct TonFunBclWalletV1EmptyBody {}

/// Internal message bodies accepted by TonFun BCL Wallet V1.
type TonFunBclWalletV1IncomingMessage =
    | TonFunBclWalletTransfer
    | TonFunBclWalletInternalTransfer
    | TonFunBclWalletBurn
    | TonFunBclWalletTopUp
    | TonFunBclWalletSell
    | TonFunBclWalletUnlock
    | TonFunBclWalletV1UnlockConfirmation

/// Tagged internal bodies emitted by TonFun BCL Wallet V1.
///
/// The untagged unlock payout is exported separately as
/// `TonFunBclWalletV1EmptyBody`.
type TonFunBclWalletV1OutgoingMessage =
    | TonFunBclWalletInternalTransfer
    | TonFunBclWalletTransferNotification
    | TonFunBclWalletExcesses
    | TonFunBclWalletBurnNotification
    | TonFunBclWalletSellNotification
    | TonFunBclWalletUnlockCallback

/// Return balance, owner, master, and current wallet code.
get fun get_wallet_data(): GetTonFunBclWalletDataReply {
    throw 0;
}

/// Return the stored four-bit lock status.
get fun get_status(): uint4 {
    throw 0;
}

/// Return true only when owner transfers are enabled.
get fun get_transfers_enabled(): bool {
    throw 0;
}
