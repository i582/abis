/// Historical Coffee MEV Protector ABI used by the original 2025 deployment.
contract CoffeeMevProtectorLegacy {
    author: "swap.coffee"
    version: "1.0-legacy"
    description: "Historical Coffee MEV Protector that holds swap intents and routes failed swaps back to recipients."
    storage: CoffeeMevProtectorLegacyStorage
    incomingMessages: CoffeeMevProtectorLegacyIncomingMessage
    incomingExternal: CoffeeMevProtectorLegacyIncomingExternalMessage
    outgoingMessages: CoffeeMevProtectorLegacyOutgoingMessage
    thrownErrors: CoffeeMevProtectorLegacyErrors
    forceAbiExport: CoffeeMevProtectorLegacyFailedSwapPayload
}

/// Root persistent storage of the historical protector.
struct CoffeeMevProtectorLegacyStorage {
    /// Admin authorized for administrative messages.
    adminAddress: address
    /// Highload-style wallet id required in every signed external request.
    subwalletId: uint32
    /// Processed-query lower bound used by `processed?`.
    processedUntil: uint64
    /// Public key returned by `get_public_key`.
    publicKey: uint256
    /// Dictionary of individually processed query ids.
    processedQueries: cell?
}

/// Standard Jetton transfer notification carrying a historical protector payload.
struct (0x7362d09c) CoffeeMevProtectorLegacyJettonTransferNotification {
    /// Query id copied from the Jetton wallet.
    queryId: uint64
    /// Jetton amount transferred to the notifying wallet.
    amount: coins
    /// Original owner or sender reported by the Jetton wallet.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` tail carrying the nested protector payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Hold-funds marker accepted directly and as a nested Jetton payload.
struct (0x6bc79e7e) CoffeeMevProtectorLegacyHoldFunds {
    /// Query id of the protected route.
    queryId: uint64
}

/// Failed-swap payload forwarded through a Jetton transfer.
struct (0xee51ce51) CoffeeMevProtectorLegacyFailedSwapPayload {
    /// Query id of the failed route.
    queryId: uint64
    /// Recipient for the fallback Jetton transfer.
    recipient: address
}

/// DeDust payout callback carrying a referenced failed-swap payload.
struct (0x474f86cf) CoffeeMevProtectorLegacyDedustPayout {
    /// Query id copied from the DeDust payout.
    queryId: uint64
    /// Optional referenced historical protector payload.
    payload: cell?
}

/// Admin request to replace the stored admin address.
struct (0x57861aa7) CoffeeMevProtectorLegacySetAdmin {
    /// Query id copied into the excess response.
    queryId: uint64
    /// New admin address stored in root data.
    adminAddress: address
}

/// Admin request to replace the stored public key.
struct (0xb19e2647) CoffeeMevProtectorLegacySetPublicKey {
    /// Query id copied into the excess response.
    queryId: uint64
    /// New public key stored in root data.
    publicKey: uint256
}

/// Admin request to update contract code and/or data.
struct (0x6f80872c) CoffeeMevProtectorLegacyUpdateContract {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement data cell.
    data: cell?
}

/// Admin-only native withdrawal or rescue operation.
struct (0x2bf71be6) CoffeeMevProtectorLegacyAdmin2bf71be6 {
    /// Query id copied into the excess response.
    queryId: uint64
    /// Account that receives the native transfer and excess response.
    destination: address
    /// Native amount added to the inbound value before fees are deducted.
    amount: coins
}

/// Admin-only Jetton transfer or rescue operation.
struct (0x7b4b82fe) CoffeeMevProtectorLegacyAdmin7b4b82fe {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Recipient written into both destination fields of the Jetton transfer body.
    recipient: address
    /// Jetton wallet that receives the transfer request.
    jettonWallet: address
    /// Jetton amount requested from the wallet.
    amount: coins
}

/// Standard Jetton `excesses` body accepted and emitted by protector flows.
struct (0xd53276db) CoffeeMevProtectorLegacyExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Standard Jetton transfer body emitted for failed-swap refunds.
struct (0x0f8a7ea5) CoffeeMevProtectorLegacyJettonTransfer {
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

/// Internal message bodies accepted by the historical Coffee MEV Protector.
type CoffeeMevProtectorLegacyIncomingMessage =
    | CoffeeMevProtectorLegacyJettonTransferNotification
    | CoffeeMevProtectorLegacyHoldFunds
    | CoffeeMevProtectorLegacyDedustPayout
    | CoffeeMevProtectorLegacySetAdmin
    | CoffeeMevProtectorLegacySetPublicKey
    | CoffeeMevProtectorLegacyUpdateContract
    | CoffeeMevProtectorLegacyAdmin2bf71be6
    | CoffeeMevProtectorLegacyAdmin7b4b82fe
    | CoffeeMevProtectorLegacyExcesses

/// One raw message action from the signed external batch.
struct CoffeeMevProtectorLegacySendMessageAction {
    /// Send mode passed to `send_raw_message`.
    mode: uint8
    /// Referenced outbound message cell sent without ABI-level rewriting.
    message: cell
}

/// Signed external request that executes a batch of arbitrary raw messages.
struct CoffeeMevProtectorLegacySignedBatch {
    /// Ed25519 signature over the body after this field.
    signature: bits512
    /// Wallet id required to equal the stored `subwalletId`.
    subwalletId: uint32
    /// Timestamped replay-protection query id.
    queryId: uint64
    /// Batch dictionary keyed by 16-bit message index.
    payload: map<uint16, CoffeeMevProtectorLegacySendMessageAction>
}

/// External-in body accepted by the historical Coffee MEV Protector.
type CoffeeMevProtectorLegacyIncomingExternalMessage = CoffeeMevProtectorLegacySignedBatch

/// Internal message bodies emitted by the historical Coffee MEV Protector.
type CoffeeMevProtectorLegacyOutgoingMessage =
    | CoffeeMevProtectorLegacyJettonTransfer
    | CoffeeMevProtectorLegacyExcesses

/// Exit codes produced by internal and signed external request validation.
enum CoffeeMevProtectorLegacyErrors {
    /// Signed external query id is already present in the replay dictionary.
    QueryAlreadyExecuted = 32
    /// Signed external wallet id does not match the stored wallet id.
    InvalidSubwalletId = 34
    /// Signed external query id is stale or its Ed25519 signature is invalid.
    InvalidQueryIdOrSignature = 35
    /// Message does not include a transaction payload to resend.
    EmptyTxToResend = 100
    /// DeDust payout callback does not include a nested payload.
    DedustPayloadIsEmpty = 101
    /// Jetton notification forward payload is missing or malformed.
    InvalidJettonForwardPayload = 200
    /// DeDust payout payload is not a failed-swap payload.
    InvalidDedustPayload = 201
    /// Sender is not the stored admin address.
    NotAnAdmin = 300
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return the stored public key.
get fun get_public_key(): uint256 {
    throw 0;
}

/// Return whether a query id has already been processed.
get fun `processed?`(queryId: uint64): bool {
    throw 0;
}
