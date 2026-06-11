/// Fragment/MarketApp buy-routing proxy address attributed as `marketapp-proxy.ton`.
contract FragmentMarketappProxyKnown {
    author: "MarketApp"
    version: "1.0"
    description: "MarketApp proxy interface for signed Fragment/Telegram collectible buy routing"
    storage: FragmentMarketappProxyKnownStorage
    incomingMessages: FragmentMarketappProxyKnownIncomingMessage
    forceAbiExport: FragmentMarketappProxyKnownSignedBuyRequest
        | FragmentMarketappProxyKnownSecondarySend
    thrownErrors: FragmentMarketappProxyKnownErrors
}

/// Proxy persistent data used for Ed25519 authorization and admin raw-send control.
struct FragmentMarketappProxyKnownStorage {
    /// Ed25519 public key that signs buy-routing payload cells.
    publicKey: bits256
    /// Account authorized to send opcode `0x22b` raw-message relay commands.
    adminAddress: address
}

/// Signed direct buy request accepted by the proxy.
struct (0x3f2b92d2) FragmentMarketappProxyKnownBuy {
    /// Ed25519 signature over the referenced signed request cell hash.
    signature: bits512
    /// Referenced request cell containing destination, value, forwarded body, and variant-specific tail.
    request: Cell<FragmentMarketappProxyKnownSignedBuyRequest>
    /// Untagged extra refs used by this variant for secondary reward/referral sends.
    extra: RemainingBitsAndRefs
}

/// Request cell signed by the proxy public key.
struct FragmentMarketappProxyKnownSignedBuyRequest {
    /// Destination that receives the primary routed TON transfer.
    destination: address
    /// Nanotons sent with the primary routed transfer.
    amount: coins
    /// Body attached to the primary routed transfer.
    forwardPayload: cell
    /// Expected to be empty for this variant; retained to prove absence of trailing signed fields.
    extra: RemainingBitsAndRefs
}

/// Secondary destination/payload cell used for reward or referral sends.
struct FragmentMarketappProxyKnownSecondarySend {
    /// Destination that receives the secondary computed-value transfer.
    destination: address
    /// Body attached to the secondary transfer.
    forwardPayload: cell
    /// Reserved for variant-specific trailing fields.
    extra: RemainingBitsAndRefs
}

/// Admin raw-message relay command accepted only from the stored admin address.
struct (0x22b) FragmentMarketappProxyKnownAdminRelay {
    /// Referenced cell containing send mode followed by the raw message cell.
    command: Cell<FragmentMarketappProxyKnownAdminRelayCommand>
}

/// Admin relay command cell.
struct FragmentMarketappProxyKnownAdminRelayCommand {
    /// TVM send mode for the relayed raw message.
    sendMode: uint8
    /// Raw outbound message to pass to `send_raw_message`.
    message: cell
}

/// Internal messages accepted by the proxy.
type FragmentMarketappProxyKnownIncomingMessage =
    | FragmentMarketappProxyKnownBuy
    | FragmentMarketappProxyKnownAdminRelay

/// Exit-code catalog for the proxy.
enum FragmentMarketappProxyKnownErrors {
    /// Signature over the signed routing payload is invalid.
    InvalidSignature = 403
    /// Admin relay send mode uses a forbidden flag.
    InvalidSendMode = 400
    /// Incoming TON value is not greater than the primary routed amount.
    InsufficientMessageValue = 1001
    /// Incoming message opcode is not supported.
    UnsupportedOperation = 65535
}
