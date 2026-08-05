/// Signed cross-DEX executor interface for authenticated raw sends and callback-driven continuation routes.
contract SignedCrossDexExecutor {
    author: "Unknown"
    version: "1.0"
    description: "A private cross-DEX executor that authenticates an initial raw message and continues a stored route after selected contract callbacks."
    storage: SignedCrossDexExecutorStorage
    incomingMessages: SignedCrossDexExecutorIncomingMessage
    incomingExternal: SignedCrossDexExecutorIncomingExternalMessage
    thrownErrors: SignedCrossDexExecutorErrors
}

/// Persistent replay-protection and route-continuation state.
struct SignedCrossDexExecutorStorage {
    /// Greatest query id removed from the recent-query dictionary.
    lastCleanedQueryId: uint64
    /// Ed25519 public key used to authenticate external requests.
    publicKey: uint256
    /// Recently accepted query ids keyed by their full 64-bit value.
    processedQueries: map<uint64, SignedCrossDexProcessedQuery>
    /// Optional active callback route stored as a referenced cell.
    continuation: Cell<SignedCrossDexContinuation>?
}

/// Empty dictionary value marking one accepted query id.
struct SignedCrossDexProcessedQuery {}

/// Root of a callback route and its first referenced step.
struct SignedCrossDexContinuation {
    /// Number of route steps remaining, including `firstStep`.
    remainingSteps: uint8
    /// First step considered after the next matching callback.
    firstStep: Cell<SignedCrossDexContinuationStep>
}

/// End marker stored after the final continuation step.
struct (0b0) SignedCrossDexContinuationEnd {}

/// Reference to the next continuation step.
struct (0b1) SignedCrossDexContinuationNext {
    /// Next step in the callback route.
    step: Cell<SignedCrossDexContinuationStep>
}

/// One-bit continuation tail following a route step.
type SignedCrossDexContinuationTail =
    | SignedCrossDexContinuationEnd
    | SignedCrossDexContinuationNext

/// Callback condition and raw internal message emitted by one route step.
struct SignedCrossDexContinuationStep {
    /// Contract address required to send the callback that advances this step.
    expectedSender: address
    /// Callback selector: `1` accepts any body, `2` requires Jetton notification, and `3` requires excesses.
    callbackKind: uint8
    /// Reserved byte retained by the serialized route but ignored by this code revision.
    reserved: uint8
    /// Destination of the raw internal message emitted after a matching callback.
    destination: address
    /// Nanograms attached to the emitted message.
    value: coins
    /// Referenced raw body of the emitted internal message.
    body: cell
    /// End marker or reference to the next route step.
    next: SignedCrossDexContinuationTail
}

/// External-in request authenticated by an Ed25519 signature over every field after `signature`.
struct SignedCrossDexExecutorSignedRequest {
    /// Ed25519 signature over the remaining request slice.
    signature: bits512
    /// Unix timestamp after which the request is rejected.
    validUntil: uint32
    /// Timestamped 64-bit replay-protection identifier.
    queryId: uint64
    /// TVM send mode used for the first referenced raw message.
    sendMode: uint8
    /// Whether the request replaces the stored continuation instead of preserving it.
    replaceContinuation: bool
    /// Ignored signed bits, the first raw message reference, and an optional replacement continuation reference.
    payload: RemainingBitsAndRefs
}

/// External-in body accepted by the executor.
type SignedCrossDexExecutorIncomingExternalMessage = SignedCrossDexExecutorSignedRequest

/// Standard TEP-74 Jetton transfer notification used as a continuation callback.
struct (0x7362d09c) SignedCrossDexJettonTransferNotification {
    /// Query id supplied by the notifying Jetton wallet.
    queryId: uint64
    /// Jetton amount received by the notifying wallet.
    amount: coins
    /// Previous Jetton owner reported by the wallet.
    sender: address
    /// Raw TEP-74 forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excesses callback used to advance a continuation step.
struct (0xd53276db) SignedCrossDexExcesses {
    /// Query id supplied by the responding contract.
    queryId: uint64
}

/// Structured callback bodies recognized by continuation conditions.
type SignedCrossDexExecutorIncomingMessage =
    | SignedCrossDexJettonTransferNotification
    | SignedCrossDexExcesses

/// Exit codes produced while validating signed external requests.
enum SignedCrossDexExecutorErrors {
    /// Query id is already present in the replay dictionary.
    QueryAlreadyProcessed = 32
    /// Request deadline has passed or the Ed25519 signature is invalid.
    ExpiredOrInvalidSignature = 35
    /// Replacement continuation declares 16 or more steps.
    TooManyContinuationSteps = 36
    /// Query id timestamp is older than the current block time.
    StaleQueryId = 37
}

/// Compatibility getter; this code revision always returns zero.
get fun seqno(): int {
    throw 0;
}

/// Return the current continuation step count, or zero when no continuation is stored.
///
/// This synthetic name has the same CRC selector as live method id `99519`; the original source name is unknown.
get fun get_method_99519_0ybc(): int {
    throw 0;
}

/// Return `-1` for a recent processed query, `1` for a cleaned query, or `0` for an unseen query.
get fun processed(queryId: uint64): int {
    throw 0;
}
