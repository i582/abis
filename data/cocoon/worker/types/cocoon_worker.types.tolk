/// COCOON production Worker that reports cumulative inference work to a Proxy.
contract CocoonWorker {
    author: "Telegram"
    description: "COCOON worker account with signed token accounting and Proxy payouts."
    storage: CocoonWorkerStorage
    incomingMessages: CocoonWorkerIncomingMessage
    outgoingMessages: CocoonWorkerOutgoingMessage
    forceAbiExport: CocoonWorkerParams
        | CocoonWorkerPayoutPayload
        | CocoonWorkerLastPayoutPayload
        | CocoonWorkerProxyPayoutRequest
    thrownErrors: CocoonWorkerErrors
}

/// Protocol parameters copied from the Root when the Worker is deployed.
struct CocoonWorkerParams {
    /// Persistent parameter layout revision.
    structVersion: uint8
    /// Monotonic revision of the protocol parameters.
    paramsVersion: uint32
    /// Network-specific protocol identifier.
    uniqueId: uint32
    /// Whether the configuration belongs to a test deployment.
    isTest: bool
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
    /// Prompt-token multiplier in protocol fixed-point units.
    promptTokensPriceMultiplier: uint32
    /// Cached-token multiplier in protocol fixed-point units.
    cachedTokensPriceMultiplier: uint32
    /// Completion-token multiplier in protocol fixed-point units.
    completionTokensPriceMultiplier: uint32
    /// Reasoning-token multiplier in protocol fixed-point units.
    reasoningTokensPriceMultiplier: uint32
    /// Seconds a Proxy is configured to wait before close completion.
    proxyDelayBeforeClose: uint32
    /// Seconds a Client is configured to wait before refund completion.
    clientDelayBeforeClose: uint32
    /// Minimum Proxy stake in nanotons.
    minProxyStake: coins
    /// Minimum Client stake in nanotons.
    minClientStake: coins
    /// Optional Proxy code retained in full Root parameter cells.
    proxyCode: cell?
    /// Optional Worker code retained in full Root parameter cells.
    workerCode: cell?
    /// Optional Client code retained in full Root parameter cells.
    clientCode: cell?
}

/// Complete persistent state of a COCOON Worker.
struct CocoonWorkerStorage {
    /// Worker operator that receives earned payouts.
    ownerAddress: address
    /// Proxy that validates and pays this Worker.
    proxyAddress: address
    /// Proxy enclave's Ed25519 key used to validate signed usage reports.
    proxyPublicKey: uint256
    /// Lifecycle state: zero normal or two closed.
    state: uint2
    /// Highest cumulative token count accepted from the Proxy.
    tokens: uint64
    /// Frozen protocol parameters used to calculate earnings.
    params: Cell<CocoonWorkerParams>
}

/// No-op envelope deliberately ignored before normal opcode dispatch.
struct (0x9a1247c0) CocoonWorkerDoNotProcess {
    /// Arbitrary application payload ignored by the Worker.
    payload: RemainingBitsAndRefs
}

/// Signed request to account for more tokens and keep the Worker active.
struct (0xa040ad28) CocoonWorkerPayoutRequestSigned {
    /// Correlation identifier duplicated inside the signed payload.
    queryId: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
    /// Ed25519 signature of `signedDataCell`.
    signature: bits512
    /// Signed `CocoonWorkerPayoutPayload` cell.
    signedDataCell: cell
}

/// Signed final token report that closes the Worker after payout.
struct (0xf5f26a36) CocoonWorkerLastPayoutRequestSigned {
    /// Correlation identifier duplicated inside the signed payload.
    queryId: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
    /// Ed25519 signature of `signedDataCell`.
    signature: bits512
    /// Signed `CocoonWorkerLastPayoutPayload` cell.
    signedDataCell: cell
}

/// Payload protected by `CocoonWorkerPayoutRequestSigned`.
struct (0xa040ad28) CocoonWorkerPayoutPayload {
    /// Correlation identifier that must match the outer envelope.
    queryId: uint64
    /// New cumulative number of tokens produced by this Worker.
    newTokens: uint64
    /// Worker address protected against cross-contract replay.
    expectedMyAddress: address
}

/// Payload protected by `CocoonWorkerLastPayoutRequestSigned`.
struct (0xf5f26a36) CocoonWorkerLastPayoutPayload {
    /// Correlation identifier that must match the outer envelope.
    queryId: uint64
    /// Final cumulative number of tokens produced by this Worker.
    newTokens: uint64
    /// Worker address protected against cross-contract replay.
    expectedMyAddress: address
}

/// Register the Worker state with its Proxy.
struct (0x26ed7f65) CocoonWorkerRegister {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Messages accepted directly by the production Worker.
type CocoonWorkerIncomingMessage =
    | CocoonWorkerDoNotProcess
    | CocoonWorkerPayoutRequestSigned
    | CocoonWorkerLastPayoutRequestSigned
    | CocoonWorkerRegister

/// Worker state report and optional payout split sent to the Proxy.
struct (0x4d725d2c) CocoonWorkerProxyRequest {
    /// Correlation identifier copied from the incoming command.
    queryId: uint64
    /// Worker owner used by the Proxy to validate this contract's address.
    ownerAddress: address
    /// Worker lifecycle state.
    state: uint2
    /// New cumulative token count.
    tokens: uint64
    /// Optional referenced `CocoonWorkerProxyPayoutRequest` cell.
    payload: cell?
}

/// Earnings split requested through `CocoonWorkerProxyRequest`.
struct (0x08e7d036) CocoonWorkerProxyPayoutRequest {
    /// Amount in nanotons owed to the Worker owner.
    workerPart: coins
    /// Amount in nanotons retained as Proxy earnings.
    proxyPart: coins
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Acknowledge Worker registration and return unreserved value.
struct (0x2565934c) CocoonWorkerReturnExcesses {
    /// Correlation identifier copied from the registration command.
    queryId: uint64
}

/// Messages emitted directly by the production Worker.
type CocoonWorkerOutgoingMessage = CocoonWorkerProxyRequest | CocoonWorkerReturnExcesses

/// Public Worker state returned by `get_cocoon_worker_data`.
struct CocoonWorkerDataResult {
    /// Worker operator that receives earned payouts.
    ownerAddress: address
    /// Proxy that validates and pays this Worker.
    proxyAddress: address
    /// Proxy enclave's Ed25519 public key.
    proxyPublicKey: uint256
    /// Lifecycle state: zero normal or two closed.
    state: uint2
    /// Highest cumulative token count accepted from the Proxy.
    tokens: uint64
}

/// Return the complete public state of the Worker.
get fun get_cocoon_worker_data(): CocoonWorkerDataResult {
    throw 0;
}

/// Worker exit codes raised for stale, unauthorized, or invalid commands.
enum CocoonWorkerErrors {
    /// Signed token total does not advance monotonically.
    OldMessage = 1000
    /// Incoming value cannot cover the requested action and fees.
    LowMessageValue = 1003
    /// Signed payload header differs from the outer message header.
    SignedMessageFormatMismatch = 1005
    /// Worker is already closed.
    Closed = 1006
    /// Ed25519 signature validation failed.
    BadSignature = 1007
    /// Registration sender is not the configured Worker owner.
    ExpectedMessageFromOwner = 1010
    /// Incoming opcode is not supported.
    UnknownOperation = 1012
    /// Signed command targets a different Worker address.
    ExpectedMyAddress = 1015
}
