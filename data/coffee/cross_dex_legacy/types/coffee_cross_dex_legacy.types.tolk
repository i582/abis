/// Coffee CrossDex legacy interface.
contract CoffeeCrossDexLegacy {
    author: "swap.coffee"
    description: "Legacy Coffee CrossDex routing helper interface."
    storage: CoffeeCrossDexLegacyStorage
    storageAtDeployment: CoffeeCrossDexLegacyDeploymentStorage
    incomingMessages: CoffeeCrossDexLegacyIncomingMessage
    outgoingMessages: CoffeeCrossDexLegacyOutgoingMessage
    forceAbiExport: CoffeeCrossDexLegacyResend
        | CoffeeCrossDexLegacyResendJettonPayload
        | CoffeeCrossDexLegacyFailurePayload
    thrownErrors: CoffeeCrossDexLegacyErrors
}

/// Root persistent storage.
struct CoffeeCrossDexLegacyStorage {
    /// Admin authorized for administrative messages.
    adminAddress: address
}

/// Deployment storage retained until an admin update replaces root data.
struct CoffeeCrossDexLegacyDeploymentStorage {
    /// Admin authorized for administrative messages.
    adminAddress: address
    /// Trailing deployment discriminator ignored by runtime message handling.
    deploymentDiscriminator: uint32
}

/// Standard Jetton transfer notification carrying a CrossDex forward payload.
struct (0x7362d09c) CoffeeCrossDexLegacyJettonTransferNotification {
    /// Query id copied from the Jetton wallet.
    queryId: uint64
    /// Jetton amount transferred to the notifying wallet.
    amount: coins
    /// Original owner or sender reported by the Jetton wallet; `addr_none` is valid on the wire.
    sender: address?
    /// Raw TEP-74 `Either Cell ^Cell` tail carrying a nested CrossDex payload.
    forwardPayload: RemainingBitsAndRefs
}

/// DeDust vault payout callback carrying a nested CrossDex payload.
struct (0x474f86cf) CoffeeCrossDexLegacyDedustPayout {
    /// Query id copied from the DeDust payout.
    queryId: uint64
    /// Optional referenced CrossDex payload.
    payload: cell?
}

/// pTON transfer callback carrying a nested CrossDex payload.
struct (0x01f3835d) CoffeeCrossDexLegacyPtonTonTransfer {
    /// Query id copied from the pTON wallet.
    queryId: uint64
    /// Native GRAM amount reported by pTON.
    tonAmount: coins
    /// Refund address from the pTON body; `addr_none` disables an explicit refund recipient.
    refundAddress: address?
    /// Optional referenced CrossDex payload.
    forwardPayload: cell?
}

/// CrossDex resend payload accepted inside supported DEX callbacks.
struct (0x200f9086) CoffeeCrossDexLegacyResend {
    /// Query id copied through the next-hop send.
    queryId: uint64
    /// Next contract or wallet recipient.
    nextRecipient: address
    /// Referenced next-hop message body.
    next: cell
    /// Total gas budget used by the bridge.
    totalGas: coins
    /// Gas forwarded to the next hop.
    nextGas: coins
}

/// Jetton forward-payload variant carrying the next-hop body by reference.
struct (0x4ee9b106) CoffeeCrossDexLegacyResendJettonPayload {
    /// Referenced next-hop message body.
    next: cell
}

/// Failure payload forwarded through upstream DEX callbacks.
struct (0xb902e61a) CoffeeCrossDexLegacyFailurePayload {
    /// Query id of the failed route.
    queryId: uint64
    /// Recipient for the fallback Jetton transfer.
    recipient: address
}

/// Admin request to replace the stored admin address.
struct (0x57861aa7) CoffeeCrossDexLegacySetAdmin {
    /// Query id copied into the excess response.
    queryId: uint64
    /// New admin address stored in root data.
    adminAddress: address
}

/// Admin request to update contract code and/or data.
struct (0x6f80872c) CoffeeCrossDexLegacyUpdateContract {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement data cell.
    data: cell?
}

/// Admin-only native GRAM withdrawal.
struct (0x2bf71be6) CoffeeCrossDexLegacyWithdrawTon {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Recipient of the withdrawn GRAM.
    recipient: address
    /// GRAM amount added to the unreserved incoming value.
    amount: coins
}

/// Admin-only Jetton withdrawal.
struct (0x7b4b82fe) CoffeeCrossDexLegacyWithdrawJettons {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Recipient written into the outgoing Jetton transfer body.
    recipient: address
    /// Jetton wallet that receives the transfer request.
    jettonWallet: address
    /// Jetton amount requested from the wallet.
    amount: coins
}

/// Standard Jetton excess response accepted and emitted by bridge flows.
struct (0xd53276db) CoffeeCrossDexLegacyExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Standard Jetton transfer emitted for fallback or refund flows.
struct (0x0f8a7ea5) CoffeeCrossDexLegacyJettonTransfer {
    /// Query id copied from the original request.
    queryId: uint64
    /// Jetton amount.
    amount: coins
    /// Jetton recipient; `addr_none` is valid in the standard wire layout.
    destination: address?
    /// Optional response destination.
    responseDestination: address?
    /// Optional custom payload.
    customPayload: cell?
    /// Forward GRAM amount.
    forwardTonAmount: coins
    /// Raw TEP-74 forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted directly by the legacy revision.
type CoffeeCrossDexLegacyIncomingMessage =
    | CoffeeCrossDexLegacyJettonTransferNotification
    | CoffeeCrossDexLegacyDedustPayout
    | CoffeeCrossDexLegacyPtonTonTransfer
    | CoffeeCrossDexLegacySetAdmin
    | CoffeeCrossDexLegacyUpdateContract
    | CoffeeCrossDexLegacyWithdrawTon
    | CoffeeCrossDexLegacyWithdrawJettons
    | CoffeeCrossDexLegacyExcesses

/// Structured message bodies emitted by the legacy revision.
type CoffeeCrossDexLegacyOutgoingMessage =
    | CoffeeCrossDexLegacyJettonTransfer
    | CoffeeCrossDexLegacyExcesses

/// Contract-defined exit codes.
enum CoffeeCrossDexLegacyErrors {
    /// CrossDex resend payload is missing or malformed.
    InvalidPayloadToResend = 100
    /// DeDust payout callback does not include a nested payload.
    DedustPayloadIsEmpty = 101
    /// pTON transfer callback does not include a forward payload.
    PtonPayloadIsEmpty = 102
    /// Sender is not the stored admin address.
    NotAnAdmin = 200
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}
