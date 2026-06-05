/// Coffee MEV Protector ABI.
contract CoffeeMevProtector {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee MEV Protector ABI for hold/failure payloads, upstream DEX callbacks, admin operations, public key getter, and processed-query lookup."
    storage: CoffeeMevProtectorStorage
    incomingMessages: CoffeeMevProtectorIncomingMessage
    outgoingMessages: CoffeeMevProtectorOutgoingMessage
    forceAbiExport: CoffeeMevProtectFailedSwapPayload
}

/// Root persistent storage.
struct CoffeeMevProtectorStorage {
    /// Admin authorized for administrative messages.
    adminAddress: address
    /// Protector configuration word.
    config: uint32
    /// Processed-query lower bound used by `processed?`.
    processedUntil: uint64
    /// Public key returned by `get_public_key`.
    publicKey: uint256
    /// Dictionary of individually processed query ids.
    processedQueries: cell?
}

/// Standard Jetton transfer notification carrying a MEV forward payload.
struct (0x7362d09c) CoffeeMevProtectorJettonTransferNotification {
    /// Query id copied from the Jetton wallet.
    queryId: uint64
    /// Jetton amount transferred to the notifying wallet.
    amount: coins
    /// Original owner/sender reported by the Jetton wallet.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` tail carrying a nested MEV Protector payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Hold-funds marker accepted directly and as nested Jetton payload.
struct (0x6bc79e7e) CoffeeMevProtectHoldFunds {
    /// Query id of the protected route.
    queryId: uint64
}

/// Failure payload forwarded through upstream DEX callbacks.
struct (0xee51ce51) CoffeeMevProtectFailedSwapPayload {
    /// Query id of the failed route.
    queryId: uint64
    /// Recipient for the fallback Jetton transfer.
    recipient: address
}

/// DeDust vault payout callback carrying a nested MEV payload.
struct (0x474f86cf) CoffeeMevProtectorDedustPayout {
    /// Query id copied from the DeDust payout.
    queryId: uint64
    /// Optional referenced MEV Protector payload.
    payload: cell?
}

/// Coffee notification wrapper carrying a nested MEV payload in `body`.
struct (0xc0ffee36) CoffeeMevProtectorCoffeeNotification {
    /// Query id copied from the Coffee notification.
    queryId: uint64
    /// Referenced nested MEV Protector payload body.
    body: cell
}

/// Admin request to replace the stored admin address.
struct (0x57861aa7) CoffeeMevProtectorSetAdmin {
    /// Query id copied into the excess response.
    queryId: uint64
    /// New admin address stored in root data.
    adminAddress: address
}

/// Admin request to replace the stored public key.
struct (0xb19e2647) CoffeeMevProtectorSetPublicKey {
    /// Query id copied into the excess response.
    queryId: uint64
    /// New public key stored in root data.
    publicKey: uint256
}

/// Admin request to update contract code and/or data.
struct (0x6f80872c) CoffeeMevProtectorUpdateContract {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement data cell.
    data: cell?
}

/// Admin-only native withdrawal/rescue operation.
struct (0x2bf71be6) CoffeeMevProtectorAdminRaw2bf71be6 {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Raw native withdrawal/rescue parameters after `queryId`.
    tail: RemainingBitsAndRefs
}

/// Admin-only Jetton transfer/rescue operation.
struct (0x7b4b82fe) CoffeeMevProtectorAdminRaw7b4b82fe {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Raw Jetton transfer/rescue parameters after `queryId`.
    tail: RemainingBitsAndRefs
}

/// Standard Jetton `excesses` body accepted and emitted by protector flows.
struct (0xd53276db) CoffeeMevProtectorExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Standard Jetton transfer body emitted for fallback/refund flows.
struct (0x0f8a7ea5) CoffeeMevProtectorJettonTransfer {
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

/// Internal message bodies accepted by Coffee MEV Protector.
type CoffeeMevProtectorIncomingMessage =
    | CoffeeMevProtectorJettonTransferNotification
    | CoffeeMevProtectHoldFunds
    | CoffeeMevProtectorDedustPayout
    | CoffeeMevProtectorCoffeeNotification
    | CoffeeMevProtectorSetAdmin
    | CoffeeMevProtectorSetPublicKey
    | CoffeeMevProtectorUpdateContract
    | CoffeeMevProtectorAdminRaw2bf71be6
    | CoffeeMevProtectorAdminRaw7b4b82fe
    | CoffeeMevProtectorExcesses

/// Internal message bodies emitted by Coffee MEV Protector.
type CoffeeMevProtectorOutgoingMessage =
    | CoffeeMevProtectorJettonTransfer
    | CoffeeMevProtectorExcesses

enum CoffeeMevProtectorErrors {
    /// Message does not include a transaction payload to resend.
    EmptyTxToResend = 100
    /// DeDust payout callback does not include a nested payload.
    DedustPayloadIsEmpty = 101
    /// Jetton notification forward payload is missing or malformed.
    InvalidJettonForwardPayload = 200
    /// Native Coffee notification payload is missing or malformed.
    InvalidNativePayload = 201
    /// Sender is not the stored admin address.
    NotAnAdmin = 300
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return the stored public key.
get fun get_public_key(): uint256 {
    return 0;
}

/// Return whether a query id has already been processed.
get fun `processed?`(queryId: uint64): bool {
    return false;
}
