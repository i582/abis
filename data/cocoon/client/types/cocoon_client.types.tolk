/// COCOON production Client that prepays inference usage through a Proxy.
contract CocoonClient {
    author: "Telegram"
    description: "COCOON client account with token accounting, deposits, and refunds."
    storage: CocoonClientStorage
    incomingMessages: CocoonClientIncomingMessage
    outgoingMessages: CocoonClientOutgoingMessage
    forceAbiExport: CocoonClientParams
        | CocoonClientConstData
        | CocoonClientStateData
        | CocoonClientChargePayload
        | CocoonClientGrantRefundPayload
        | CocoonClientProxyTopUp
        | CocoonClientProxyRegister
        | CocoonClientProxyRefundGranted
        | CocoonClientProxyRefundForce
    thrownErrors: CocoonClientErrors
}

/// Protocol parameters copied from the Root when the Client is deployed.
struct CocoonClientParams {
    /// Persistent parameter layout revision.
    structVersion: uint8
    /// Monotonic revision of the protocol parameters.
    paramsVersion: uint32
    /// Network-specific protocol identifier.
    uniqueId: uint32
    /// Whether the configuration belongs to a test deployment.
    isTest: bool
    /// Client price per token in nanograms.
    pricePerToken: coins
    /// Worker share per token in nanograms.
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
    /// Seconds this Client waits before a forced refund can complete.
    clientDelayBeforeClose: uint32
    /// Minimum Proxy stake in nanograms.
    minProxyStake: coins
    /// Minimum Client stake in nanograms.
    minClientStake: coins
    /// Optional Proxy code retained in full Root parameter cells.
    proxyCode: cell?
    /// Optional Worker code retained in full Root parameter cells.
    workerCode: cell?
    /// Optional Client code retained in full Root parameter cells.
    clientCode: cell?
}

/// Immutable identities referenced by Client storage.
struct CocoonClientConstData {
    /// Client owner authorized to mutate owner-only state.
    ownerAddress: address
    /// Proxy that receives accounting reports and refund commands.
    proxyAddress: address
    /// Proxy enclave's Ed25519 key used to validate signed usage reports.
    proxyPublicKey: uint256
}

/// Complete persistent state of a COCOON Client.
struct CocoonClientStorage {
    /// Lifecycle state: zero normal, one closing, or two closed.
    state: uint2
    /// Remaining prepaid inference balance in nanograms.
    balance: coins
    /// Client stake retained during refund handling.
    stake: coins
    /// Highest cumulative token count accepted from the Proxy.
    tokensUsed: uint64
    /// Unix timestamp after which forced refund completion is allowed.
    unlockTs: uint32
    /// Hash used by the off-chain authorization protocol.
    secretHash: uint256
    /// Immutable owner, Proxy address, and Proxy public key.
    constData: Cell<CocoonClientConstData>
    /// Frozen protocol parameters used for accounting and delays.
    params: Cell<CocoonClientParams>
}

/// No-op envelope deliberately ignored before normal opcode dispatch.
struct (0x9a1247c0) CocoonClientDoNotProcess {
    /// Arbitrary application payload ignored by the Client.
    payload: RemainingBitsAndRefs
}

/// Signed cumulative usage update submitted by the Proxy enclave.
struct (0xbb63ff93) CocoonClientChargeSigned {
    /// Correlation identifier duplicated inside the signed payload.
    queryId: uint64
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
    /// Ed25519 signature of `signedDataCell`.
    signature: bits512
    /// Signed `CocoonClientChargePayload` cell.
    signedDataCell: cell
}

/// Signed final usage update that grants a Client refund.
struct (0xefd711e1) CocoonClientGrantRefundSigned {
    /// Correlation identifier duplicated inside the signed payload.
    queryId: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
    /// Ed25519 signature of `signedDataCell`.
    signature: bits512
    /// Signed `CocoonClientGrantRefundPayload` cell.
    signedDataCell: cell
}

/// Payload protected by `CocoonClientChargeSigned`.
struct (0xbb63ff93) CocoonClientChargePayload {
    /// Correlation identifier that must match the outer envelope.
    queryId: uint64
    /// New cumulative number of tokens consumed by this Client.
    newTokensUsed: uint64
    /// Client address protected against cross-contract replay.
    expectedMyAddress: address
}

/// Payload protected by `CocoonClientGrantRefundSigned`.
struct (0xefd711e1) CocoonClientGrantRefundPayload {
    /// Correlation identifier that must match the outer envelope.
    queryId: uint64
    /// Final cumulative number of consumed tokens.
    newTokensUsed: uint64
    /// Client address protected against cross-contract replay.
    expectedMyAddress: address
}

/// Add funds to a Client's prepaid balance.
struct (0xf172e6c2) CocoonClientTopUp {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Amount in nanograms credited to the Client balance.
    topUpAmount: coins
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Change the authorization secret while adding prepaid balance.
struct (0x8473b408) CocoonClientChangeSecretHashAndTopUp {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Amount in nanograms credited to the Client balance.
    topUpAmount: coins
    /// Replacement off-chain authorization hash.
    newSecretHash: uint256
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Register Client metadata with its Proxy.
struct (0xc45f9f3b) CocoonClientRegister {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Owner-selected registration nonce forwarded to the Proxy.
    nonce: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Replace the off-chain authorization secret hash.
struct (0xa9357034) CocoonClientChangeSecretHash {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Replacement off-chain authorization hash.
    newSecretHash: uint256
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Increase the amount retained as Client stake.
struct (0x6a1f6a60) CocoonClientIncreaseStake {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// New total Client stake in nanograms; it must exceed the old value.
    newStake: coins
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Withdraw prepaid balance that exceeds the retained Client stake.
struct (0xda068e78) CocoonClientWithdraw {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Start or complete the delayed Client refund process.
struct (0xfafa6cc1) CocoonClientRequestRefund {
    /// Correlation identifier copied to outgoing messages.
    queryId: uint64
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Messages accepted directly by the production Client.
type CocoonClientIncomingMessage =
    | CocoonClientDoNotProcess
    | CocoonClientChargeSigned
    | CocoonClientGrantRefundSigned
    | CocoonClientTopUp
    | CocoonClientChangeSecretHashAndTopUp
    | CocoonClientRegister
    | CocoonClientChangeSecretHash
    | CocoonClientIncreaseStake
    | CocoonClientWithdraw
    | CocoonClientRequestRefund

/// Client state embedded in every report sent to the Proxy.
struct CocoonClientStateData {
    /// Client lifecycle state.
    state: uint2
    /// Remaining prepaid balance in nanograms.
    balance: coins
    /// Client stake in nanograms.
    stake: coins
    /// Highest cumulative token count accepted from the Proxy.
    tokensUsed: uint64
    /// Current off-chain authorization secret hash.
    secretHash: uint256
}

/// State report and optional command sent from the Client to its Proxy.
struct (0x65448ff4) CocoonClientProxyRequest {
    /// Correlation identifier copied from the incoming command.
    queryId: uint64
    /// Client owner used by the Proxy to validate this contract's address.
    ownerAddress: address
    /// Mutable Client fields used in deterministic address validation.
    stateData: Cell<CocoonClientStateData>
    /// Optional referenced Client-to-Proxy command.
    payload: cell?
}

/// Ask the Proxy to retain a Client top-up.
struct (0x5cfc6b87) CocoonClientProxyTopUp {
    /// Amount in nanograms transferred from the Client.
    topUpAmount: coins
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Notify the Proxy of a Client registration.
struct (0xa35cb580) CocoonClientProxyRegister {
    /// Owner-selected registration nonce.
    nonce: uint64
}

/// Ask the Proxy to return an authorized amount to the Client owner.
struct (0xc68ebc7b) CocoonClientProxyRefundGranted {
    /// Authorized amount in nanograms.
    amount: coins
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Ask the Proxy to force a refund, potentially from Proxy stake.
struct (0xf4c354c9) CocoonClientProxyRefundForce {
    /// Requested refund amount in nanograms.
    amount: coins
    /// Account that receives any excess value.
    sendExcessesTo: address
}

/// Acknowledge processing and return unreserved message value.
struct (0x2565934c) CocoonClientReturnExcesses {
    /// Correlation identifier copied from the triggering command.
    queryId: uint64
}

/// Messages emitted directly by the production Client.
type CocoonClientOutgoingMessage = CocoonClientProxyRequest | CocoonClientReturnExcesses

/// Public Client state returned by `get_cocoon_client_data`.
struct CocoonClientDataResult {
    /// Client owner authorized to send owner-only commands.
    ownerAddress: address
    /// Proxy that receives Client state reports.
    proxyAddress: address
    /// Proxy enclave's Ed25519 public key.
    proxyPublicKey: uint256
    /// Lifecycle state: zero normal, one closing, or two closed.
    state: uint2
    /// Remaining prepaid balance in nanograms.
    balance: coins
    /// Retained Client stake in nanograms.
    stake: coins
    /// Highest cumulative token count accepted from the Proxy.
    tokensUsed: uint64
    /// Forced-refund unlock timestamp, or zero when inactive.
    unlockTs: uint32
    /// Current off-chain authorization secret hash.
    secretHash: uint256
}

/// Return the complete public state of the Client.
get fun get_cocoon_client_data(): CocoonClientDataResult {
    throw 0;
}

/// Client exit codes raised for stale, unauthorized, or invalid commands.
enum CocoonClientErrors {
    /// Signed usage total does not advance monotonically.
    OldMessage = 1000
    /// Contract balance cannot safely cover the requested action.
    LowContractBalance = 1001
    /// Incoming value cannot cover the requested action and fees.
    LowMessageValue = 1003
    /// Signed payload header differs from the outer message header.
    SignedMessageFormatMismatch = 1005
    /// Operation is incompatible with the current lifecycle state.
    Closed = 1006
    /// Ed25519 signature validation failed.
    BadSignature = 1007
    /// Command sender is not the owner required by refund operations.
    ExpectedOwner = 1009
    /// Command sender is not the configured Client owner.
    ExpectedMessageFromOwner = 1010
    /// Forced refund completion was requested before the unlock timestamp.
    NotUnlockedYet = 1011
    /// Incoming opcode is not supported.
    UnknownOperation = 1012
    /// Signed command targets a different Client address.
    ExpectedMyAddress = 1015
}
