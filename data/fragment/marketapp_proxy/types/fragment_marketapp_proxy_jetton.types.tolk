/// Fragment/MarketApp buy-routing proxy variant that also accepts Jetton transfer notifications.
contract FragmentMarketappProxyJetton {
    author: "MarketApp"
    version: "1.0"
    description: "Signed Fragment/Telegram collectible buy-routing proxy variant with Jetton transfer-notification routing"
    storage: FragmentMarketappProxyJettonStorage
    incomingMessages: FragmentMarketappProxyJettonIncomingMessage
    outgoingMessages: FragmentMarketappProxyJettonOutgoingMessage
    forceAbiExport: FragmentMarketappProxyJettonSignedBuyRequest
        | FragmentMarketappProxyJettonSecondarySend
        | FragmentMarketappProxyJettonSignedTransferPayload
        | FragmentMarketappProxyJettonTransfer
    thrownErrors: FragmentMarketappProxyJettonErrors
}

/// Proxy persistent data used for Ed25519 authorization and admin raw-send control.
struct FragmentMarketappProxyJettonStorage {
    /// Ed25519 public key that signs buy-routing payload cells.
    publicKey: bits256
    /// Account authorized to send opcode `0x22b` raw-message relay commands.
    adminAddress: address
}

/// Signed direct buy request accepted by the proxy.
struct (0x3f2b92d2) FragmentMarketappProxyJettonBuy {
    /// Ed25519 signature over the referenced signed request cell hash.
    signature: bits512
    /// Referenced request cell containing destination, value, forwarded body, and variant-specific tail.
    request: Cell<FragmentMarketappProxyJettonSignedBuyRequest>
    /// Expected empty root tail for the observed jetton-aware variant.
    extra: RemainingBitsAndRefs
}

/// Request cell signed by the proxy public key.
struct FragmentMarketappProxyJettonSignedBuyRequest {
    /// Destination that receives the primary routed TON transfer.
    destination: address
    /// Nanotons sent with the primary routed transfer.
    amount: coins
    /// Body attached to the primary routed transfer.
    forwardPayload: cell
    /// Variant-specific signed tail; observed as a false Maybe bit when no secondary send is present.
    extra: RemainingBitsAndRefs
}

/// Secondary destination/payload cell used for reward or referral sends.
struct FragmentMarketappProxyJettonSecondarySend {
    /// Destination that receives the secondary computed-value transfer.
    destination: address
    /// Body attached to the secondary transfer.
    forwardPayload: cell
    /// Reserved for variant-specific trailing fields.
    extra: RemainingBitsAndRefs
}

/// Jetton transfer-notification entrypoint accepted by this proxy variant.
struct (0x7362d09c) FragmentMarketappProxyJettonTransferNotification {
    /// Query id copied from the notifying Jetton wallet transfer.
    queryId: uint64
    /// Jetton amount reported by the notifying wallet.
    jettonAmount: coins
    /// Sender address reported by the notifying wallet.
    fromAddress: address
    /// Referenced forward payload containing a signature and signed routing request.
    forwardPayload: Cell<FragmentMarketappProxyJettonForwardPayload>
}

/// Forward payload embedded in a Jetton transfer notification.
struct FragmentMarketappProxyJettonForwardPayload {
    /// Ed25519 signature over the referenced signed payload cell hash.
    signature: bits512
    /// Referenced signed Jetton routing payload.
    payload: Cell<FragmentMarketappProxyJettonSignedTransferPayload>
}

/// Signed Jetton routing payload used by this proxy variant.
struct FragmentMarketappProxyJettonSignedTransferPayload {
    /// Address inserted as the recipient in the outgoing Jetton transfer.
    responseDestination: address
    /// Nanotons attached to the outgoing message envelope.
    messageValue: coins
    /// Jetton amount forwarded in the outgoing Jetton transfer body.
    jettonAmount: coins
    /// Query id written into the outgoing Jetton transfer body.
    queryId: uint64
    /// Forward TON amount written into the outgoing Jetton transfer body.
    forwardTonAmount: coins
    /// Forward payload referenced by the outgoing Jetton transfer body.
    forwardPayload: cell
    /// Variant-specific optional secondary-send cell.
    extra: RemainingBitsAndRefs
}

/// Admin raw-message relay command accepted only from the stored admin address.
struct (0x22b) FragmentMarketappProxyJettonAdminRelay {
    /// Referenced cell containing send mode followed by the raw message cell.
    command: Cell<FragmentMarketappProxyJettonAdminRelayCommand>
}

/// Admin relay command cell.
struct FragmentMarketappProxyJettonAdminRelayCommand {
    /// TVM send mode for the relayed raw message.
    sendMode: uint8
    /// Raw outbound message to pass to `send_raw_message`.
    message: cell
}

/// Jetton transfer body emitted by this proxy variant.
struct (0x0f8a7ea5) FragmentMarketappProxyJettonTransfer {
    /// Query id copied from the signed Jetton payload.
    queryId: uint64
    /// Jetton amount forwarded to the receiver.
    amount: coins
    /// New Jetton owner address.
    destination: address
    /// Response destination reported to the Jetton wallet.
    responseDestination: address
    /// No custom payload is emitted by the observed send site.
    customPayload: uint1
    /// Nanotons forwarded with Jetton transfer notification.
    forwardTonAmount: coins
    /// One-bit selector indicating the forward payload is stored by reference.
    forwardPayloadAsRef: uint1
    /// Forward payload reference copied from the signed Jetton payload.
    forwardPayload: cell
}

/// Internal messages accepted by this proxy variant.
type FragmentMarketappProxyJettonIncomingMessage =
    | FragmentMarketappProxyJettonBuy
    | FragmentMarketappProxyJettonTransferNotification
    | FragmentMarketappProxyJettonAdminRelay

/// Outbound bodies emitted by this proxy variant.
type FragmentMarketappProxyJettonOutgoingMessage = FragmentMarketappProxyJettonTransfer

/// Exit-code catalog for this proxy variant.
enum FragmentMarketappProxyJettonErrors {
    /// Signature over the signed routing payload is invalid.
    InvalidSignature = 403
    /// Admin relay send mode uses a forbidden flag.
    InvalidSendMode = 400
    /// Incoming TON value is not greater than the primary routed amount.
    InsufficientMessageValue = 1001
    /// Jetton notification amount is not greater than the signed forwarded Jetton amount.
    InsufficientJettonAmount = 1002
    /// Incoming message opcode is not supported.
    UnsupportedOperation = 65535
}
