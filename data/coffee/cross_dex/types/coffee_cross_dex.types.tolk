/// Coffee CrossDex bridge ABI.
contract CoffeeCrossDex {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee CrossDex bridge ABI for resend payloads, upstream DEX callbacks, admin operations, and get_admin."
    storage: CoffeeCrossDexStorage
    incomingMessages: CoffeeCrossDexIncomingMessage
    outgoingMessages: CoffeeCrossDexOutgoingMessage
    forceAbiExport: CoffeeCrossDexResendJettonPayload | CoffeeCrossDexFailurePayload
}

/// Root persistent storage.
struct CoffeeCrossDexStorage {
    /// Admin authorized for administrative messages.
    adminAddress: address
}

/// Standard Jetton transfer notification carrying a Coffee CrossDex forward payload.
struct (0x7362d09c) CoffeeCrossDexJettonTransferNotification {
    /// Query id copied from the Jetton wallet.
    queryId: uint64
    /// Jetton amount transferred to the notifying wallet.
    amount: coins
    /// Original owner/sender reported by the Jetton wallet.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` tail carrying a nested CrossDex payload.
    forwardPayload: RemainingBitsAndRefs
}

/// DeDust vault payout callback carrying a nested CrossDex payload.
struct (0x474f86cf) CoffeeCrossDexDedustPayout {
    /// Query id copied from the DeDust payout.
    queryId: uint64
    /// Optional referenced CrossDex payload.
    payload: cell?
}

/// pTON ton-transfer callback carrying a nested CrossDex payload.
struct (0x01f3835d) CoffeeCrossDexPtonTonTransfer {
    /// Query id copied from the pTON wallet.
    queryId: uint64
    /// Native TON amount reported by pTON.
    tonAmount: coins
    /// Refund address from the pTON body.
    refundAddress: address
    /// Raw pTON forward-payload tail carrying a nested CrossDex payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Coffee notification wrapper carrying a nested CrossDex payload in `body`.
struct (0xc0ffee36) CoffeeCrossDexCoffeeNotification {
    /// Query id copied from the Coffee notification.
    queryId: uint64
    /// Referenced nested CrossDex payload body.
    body: cell
}

/// Bidask native transfer notification carrying a nested CrossDex payload.
struct (0x6edd65f0) CoffeeCrossDexBidaskNativeTransferNotification {
    /// Query id copied from the Bidask notification.
    queryId: uint64
    /// Native amount reported by Bidask.
    nativeAmount: coins
    /// Optional referenced CrossDex payload.
    forwardPayload: cell?
}

/// Auxiliary wrapped payload form used before CrossDex payload dispatch.
struct (0x9d142643) CoffeeCrossDexWrappedPayload {
    /// Query id copied from the wrapper.
    queryId: uint64
    /// Native amount or gas value used by the bridge path.
    amount: coins
    /// Optional referenced CrossDex payload.
    payload: cell?
}

/// Native CrossDex resend request.
struct (0x200f9086) CoffeeCrossDexResend {
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

/// Jetton forward-payload variant used inside Jetton notifications.
struct (0x4ee9b106) CoffeeCrossDexResendJettonPayload {
    /// Referenced next-hop message body.
    next: cell
}

/// Failure payload forwarded through upstream DEX callbacks.
struct (0xb902e61a) CoffeeCrossDexFailurePayload {
    /// Query id of the failed route.
    queryId: uint64
    /// Recipient for the fallback Jetton transfer.
    recipient: address
}

/// Admin request to replace the stored admin address.
struct (0x57861aa7) CoffeeCrossDexSetAdmin {
    /// Query id copied into the excess response.
    queryId: uint64
    /// New admin address stored in root data.
    adminAddress: address
}

/// Admin request to update contract code and/or data.
struct (0x6f80872c) CoffeeCrossDexUpdateContract {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement data cell.
    data: cell?
}

/// Admin-only native withdrawal/rescue operation.
struct (0x2bf71be6) CoffeeCrossDexAdminRaw2bf71be6 {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Raw native withdrawal/rescue parameters after `queryId`.
    tail: RemainingBitsAndRefs
}

/// Admin-only Jetton transfer/rescue operation.
struct (0x7b4b82fe) CoffeeCrossDexAdminRaw7b4b82fe {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Raw Jetton transfer/rescue parameters after `queryId`.
    tail: RemainingBitsAndRefs
}

/// Standard Jetton `excesses` body accepted and emitted by bridge flows.
struct (0xd53276db) CoffeeCrossDexExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Standard Jetton transfer body emitted for fallback/refund flows.
struct (0x0f8a7ea5) CoffeeCrossDexJettonTransfer {
    /// Query id copied from the original request.
    queryId: uint64
    /// Jetton amount.
    amount: coins
    /// Jetton recipient.
    destination: address
    /// Optional response destination.
    responseDestination: address?
    /// Optional custom payload.
    customPayload: cell?
    /// Forward TON amount.
    forwardTonAmount: coins
    /// Raw TEP-74 forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Coffee CrossDex.
type CoffeeCrossDexIncomingMessage =
    | CoffeeCrossDexJettonTransferNotification
    | CoffeeCrossDexDedustPayout
    | CoffeeCrossDexPtonTonTransfer
    | CoffeeCrossDexCoffeeNotification
    | CoffeeCrossDexBidaskNativeTransferNotification
    | CoffeeCrossDexWrappedPayload
    | CoffeeCrossDexResend
    | CoffeeCrossDexSetAdmin
    | CoffeeCrossDexUpdateContract
    | CoffeeCrossDexAdminRaw2bf71be6
    | CoffeeCrossDexAdminRaw7b4b82fe
    | CoffeeCrossDexExcesses

/// Internal message bodies emitted by Coffee CrossDex.
type CoffeeCrossDexOutgoingMessage =
    | CoffeeCrossDexJettonTransfer
    | CoffeeCrossDexExcesses

enum CoffeeCrossDexErrors {
    /// CrossDex resend payload is missing or malformed.
    InvalidPayloadToResend = 100
    /// DeDust payout callback does not include a nested payload.
    DedustPayloadIsEmpty = 101
    /// pTON transfer callback does not include a forward payload.
    PtonPayloadIsEmpty = 102
    /// Bidask native transfer callback does not include a forward payload.
    BidaskPayloadIsEmpty = 103
    /// Wrapped CrossDex payload does not include a nested payload.
    WrappedPayloadIsEmpty = 104
    /// Sender is not the stored admin address.
    NotAnAdmin = 200
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return the stored admin address.
get fun get_admin(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
