/// Ton Whales Nominators proxy contract that forwards pool and Elector messages.
contract WhalesProxy {
    author: "Ton Whales"
    version: "1.0"
    description: "Whales Nominators proxy ABI with storage and observed Elector pass-through bodies."
    storage: WhalesProxyStorage
    incomingMessages: WhalesProxyIncomingMessage
    outgoingMessages: WhalesProxyOutgoingMessage
}

/// Persistent proxy state stored in the root data cell.
struct WhalesProxyStorage {
    /// Elector address used by the proxy.
    address0: address
    /// Pool address authorized to send through the proxy.
    address1: address
    /// Stored 64-bit proxy tail value.
    tail: uint64
}

/// Elector new-stake body forwarded by the proxy.
struct (0x4e73744b) WhalesProxyElectorNewStake {
    /// Query id copied through the proxy flow.
    queryId: uint64
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp forwarded to Elector.
    stakeAt: uint32
    /// Elector max-factor value.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Elector recover-stake request forwarded by the proxy.
struct (0x47657424) WhalesProxyElectorRecoverStakeRequest {
    /// Query id copied through the proxy flow.
    queryId: uint64
}

/// Elector new-stake confirmation forwarded by the proxy.
struct (0xf374484c) WhalesProxyElectorNewStakeConfirmation {
    /// Query id copied from the Elector new-stake request.
    queryId: uint64
    /// Elector confirmation comment field.
    comment: uint32
}

/// Elector recover-stake response forwarded by the proxy.
struct (0xf96f7324) WhalesProxyElectorRecoverStakeResponse {
    /// Query id copied from the Elector recover-stake request.
    queryId: uint64
}

/// Internal message bodies accepted by the proxy when forwarding Elector traffic.
type WhalesProxyIncomingMessage =
    | WhalesProxyElectorNewStake
    | WhalesProxyElectorRecoverStakeRequest
    | WhalesProxyElectorNewStakeConfirmation
    | WhalesProxyElectorRecoverStakeResponse

/// Internal message bodies emitted by the proxy when forwarding Elector traffic.
type WhalesProxyOutgoingMessage =
    | WhalesProxyElectorNewStake
    | WhalesProxyElectorRecoverStakeRequest
    | WhalesProxyElectorNewStakeConfirmation
    | WhalesProxyElectorRecoverStakeResponse

/// Source-level exit-code catalog for Whales Nominators proxy.
enum WhalesProxyErrors {
    /// Proxy external messages are not accepted.
    InvalidMessage = 72
}
