/// Built-in testing treasury contract used by Acton and TON Sandbox to send batched internal messages.
contract TreasuryContract {
    author: "TON Core"
    version: "1.0"
    description: "Curated testing treasury interface with storage and external transfer body layout"
    storage: TreasuryStorage
    incomingExternal: TreasuryExternalMessage
    forceAbiExport: TreasurySendMessageAction
    thrownErrors: Errors
}

/// Persistent treasury state stored in the root data cell.
struct TreasuryStorage {
    /// Treasury subwallet id checked by every external transfer request.
    subwalletId: uint256
}

/// A single outbound message action stored in the external request dictionary.
struct TreasurySendMessageAction {
    /// Raw SENDRAWMSG mode.
    mode: uint8
    /// Referenced relaxed outbound message cell.
    message: cell
}

/// External-in body accepted by the treasury contract.
struct TreasuryExternalMessage {
    /// Treasury subwallet id expected to match storage.subwalletId.
    subwalletId: uint256
    /// Dictionary keyed by signed 16-bit index with outbound messages to send.
    messages: map<int16, TreasurySendMessageAction>
}

/// Treasury exit-code catalog from the recreated FunC source.
enum Errors {
    /// External request subwallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
}
