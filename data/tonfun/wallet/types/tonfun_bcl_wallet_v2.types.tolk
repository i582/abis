import "./tonfun_bcl_wallet_common.types"

/// TonFun bonding-curve Jetton wallet revision with query-correlated unlock excesses.
contract TonFunBclWalletV2 {
    author: "TonFun"
    version: "2"
    description: "TonFun BCL Wallet V2 adds query-correlated unlock excesses to the locked Jetton wallet interface."
    storage: TonFunBclWalletStorage
    incomingMessages: TonFunBclWalletV2IncomingMessage
    outgoingMessages: TonFunBclWalletV2OutgoingMessage
    forceAbiExport: TonFunBclWalletBouncedKnownBody
    thrownErrors: TonFunBclWalletErrors
}

/// Master confirmation that unlocks V2 and correlates the owner excess response.
struct (0xa8ce3fe7) TonFunBclWalletV2UnlockConfirmation {
    /// Query identifier copied into the excess response sent to the owner.
    queryId: uint64
}

/// Internal message bodies accepted by TonFun BCL Wallet V2.
type TonFunBclWalletV2IncomingMessage =
    | TonFunBclWalletTransfer
    | TonFunBclWalletInternalTransfer
    | TonFunBclWalletBurn
    | TonFunBclWalletTopUp
    | TonFunBclWalletSell
    | TonFunBclWalletUnlock
    | TonFunBclWalletV2UnlockConfirmation

/// Internal bodies emitted by TonFun BCL Wallet V2.
type TonFunBclWalletV2OutgoingMessage =
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
