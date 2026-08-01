/// COCOON production Proxy that accounts for Client and Worker payments.
contract CocoonProxy {
    author: "Telegram"
    description: "COCOON payment proxy connecting protocol Clients, Workers, and the Root."
    storage: CocoonProxyStorage
    incomingMessages: CocoonProxyIncomingMessage
    outgoingMessages: CocoonProxyOutgoingMessage
    forceAbiExport: CocoonProxyParams
        | CocoonProxyClientStateData
        | CocoonProxySignedCloseRequestPayload
        | CocoonProxySignedCloseCompleteRequestPayload
        | CocoonProxyWorkerPayoutRequest
        | CocoonProxyClientTopUp
        | CocoonProxyClientRegister
        | CocoonProxyClientRefundGranted
        | CocoonProxyClientRefundForce
    thrownErrors: CocoonProxyErrors
}

/// Protocol parameters copied from the Root when the Proxy is deployed.
struct CocoonProxyParams {
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

/// Complete persistent state of a COCOON Proxy.
@overflow1023_policy("suppress")
struct CocoonProxyStorage {
    /// Operator that owns the Proxy and receives accrued earnings.
    ownerAddress: address
    /// Ed25519 public key authorized to sign enclave close commands.
    proxyPublicKey: uint256
    /// COCOON Root that supplied this deployment's parameters.
    rootAddress: address
    /// Lifecycle state: zero normal, one closing, or two closed.
    state: uint2
    /// Accrued Proxy earnings in nanotons.
    balance: coins
    /// Slashable Proxy stake in nanotons.
    stake: coins
    /// Unix timestamp associated with close completion; zero when inactive.
    unlockTs: uint32
    /// Frozen protocol parameters used for address validation and accounting.
    params: Cell<CocoonProxyParams>
}

/// No-op envelope deliberately ignored before normal opcode dispatch.
struct (0x9a1247c0) CocoonProxyDoNotProcess {
    /// Arbitrary application payload ignored by the Proxy.
    payload: RemainingBitsAndRefs
}

/// Legacy text command accepted from the owner.
struct (0x00000000) CocoonProxyTextCommand {
    /// ASCII `c` closes the Proxy; ASCII `w` withdraws its earnings.
    action: uint8
}

/// Signed close request sent by an authorized enclave.
struct (0x636a4391) CocoonProxyCloseRequestSigned {
    /// Correlation identifier duplicated inside the signed payload.
    queryId: uint64
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
    /// Ed25519 signature of `signedDataCell`.
    signature: bits512
    /// Signed `CocoonProxySignedCloseRequestPayload` cell.
    signedDataCell: cell
}

/// Signed close-completion request sent by an authorized enclave.
struct (0xe511abc7) CocoonProxyCloseCompleteRequestSigned {
    /// Correlation identifier duplicated inside the signed payload.
    queryId: uint64
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
    /// Ed25519 signature of `signedDataCell`.
    signature: bits512
    /// Signed `CocoonProxySignedCloseCompleteRequestPayload` cell.
    signedDataCell: cell
}

/// Payload protected by `CocoonProxyCloseRequestSigned`.
struct (0x636a4391) CocoonProxySignedCloseRequestPayload {
    /// Correlation identifier that must match the outer envelope.
    queryId: uint64
    /// Proxy address protected against cross-contract replay.
    expectedMyAddress: address
}

/// Payload protected by `CocoonProxyCloseCompleteRequestSigned`.
struct (0xe511abc7) CocoonProxySignedCloseCompleteRequestPayload {
    /// Correlation identifier that must match the outer envelope.
    queryId: uint64
    /// Proxy address protected against cross-contract replay.
    expectedMyAddress: address
}

/// Withdraw all accrued Proxy earnings to its owner.
struct (0x7610e6eb) CocoonProxyPayoutRequest {
    /// Correlation identifier copied to emitted messages.
    queryId: uint64
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Add owner-supplied funds to the Proxy's stake.
struct (0x9713f187) CocoonProxyIncreaseStake {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Amount in nanotons to add to stake.
    amount: coins
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Begin closing the Proxy through an owner-authorized internal message.
struct (0xb51d5a01) CocoonProxyOwnerClose {
    /// Correlation identifier copied to emitted messages.
    queryId: uint64
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Worker state report and optional Proxy command.
struct (0x4d725d2c) CocoonProxyWorkerRequest {
    /// Correlation identifier used by payouts and excess acknowledgements.
    queryId: uint64
    /// Owner embedded into the deterministic Worker address.
    ownerAddress: address
    /// Worker lifecycle state.
    state: uint2
    /// Total tokens reported by the Worker.
    tokens: uint64
    /// Optional referenced `CocoonProxyWorkerPayoutRequest` command.
    payload: cell?
}

/// Worker earnings split requested through `CocoonProxyWorkerRequest`.
struct (0x08e7d036) CocoonProxyWorkerPayoutRequest {
    /// Amount in nanotons paid to the Worker owner.
    workerPart: coins
    /// Amount in nanotons retained as Proxy earnings.
    proxyPart: coins
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Client fields reported to the Proxy for deterministic address validation.
struct CocoonProxyClientStateData {
    /// Client lifecycle state.
    state: uint2
    /// Client prepaid balance in nanotons.
    balance: coins
    /// Client stake in nanotons.
    stake: coins
    /// Total tokens accounted by the Client.
    tokensUsed: uint64
    /// Hash of the Client's current authorization secret.
    secretHash: uint256
}

/// Client state report and optional Proxy command.
struct (0x65448ff4) CocoonProxyClientRequest {
    /// Correlation identifier used by payouts and excess acknowledgements.
    queryId: uint64
    /// Owner embedded into the deterministic Client address.
    ownerAddress: address
    /// Mutable Client fields used to validate the sender address.
    stateData: Cell<CocoonProxyClientStateData>
    /// Optional referenced Client-to-Proxy command.
    payload: cell?
}

/// Retain a Client top-up in the Proxy's account.
struct (0x5cfc6b87) CocoonProxyClientTopUp {
    /// Amount in nanotons transferred by the Client.
    topUpAmount: coins
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Notify the Proxy that a Client was registered.
struct (0xa35cb580) CocoonProxyClientRegister {}

/// Refund a Client from Proxy-held funds after authorization.
struct (0xc68ebc7b) CocoonProxyClientRefundGranted {
    /// Amount in nanotons to return to the Client owner.
    amount: coins
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Force a Client refund, potentially reducing the Proxy stake.
struct (0xf4c354c9) CocoonProxyClientRefundForce {
    /// Requested amount in nanotons, capped by the slashable stake.
    amount: coins
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
}

/// Messages accepted directly by the production Proxy.
type CocoonProxyIncomingMessage =
    | CocoonProxyDoNotProcess
    | CocoonProxyTextCommand
    | CocoonProxyCloseRequestSigned
    | CocoonProxyCloseCompleteRequestSigned
    | CocoonProxyPayoutRequest
    | CocoonProxyIncreaseStake
    | CocoonProxyOwnerClose
    | CocoonProxyWorkerRequest
    | CocoonProxyClientRequest

/// Acknowledge processing and return unreserved message value.
struct (0x2565934c) CocoonProxyReturnExcesses {
    /// Correlation identifier copied from the triggering command.
    queryId: uint64
}

/// Transfer Worker, Client, or Proxy funds to the appropriate owner.
struct (0xc59a7cd3) CocoonProxyPayout {
    /// Correlation identifier copied from the triggering command.
    queryId: uint64
}

/// Messages emitted by the production Proxy.
type CocoonProxyOutgoingMessage = CocoonProxyReturnExcesses | CocoonProxyPayout

/// Public Proxy state returned by `get_cocoon_proxy_data`.
struct CocoonProxyDataResult {
    /// Operator that owns the Proxy.
    ownerAddress: address
    /// Ed25519 public key authorized to sign enclave commands.
    proxyPublicKey: uint256
    /// Root address associated with this deployment.
    rootAddress: address
    /// Lifecycle state: zero normal, one closing, or two closed.
    state: uint2
    /// Accrued Proxy earnings in nanotons.
    balance: coins
    /// Current slashable stake in nanotons.
    stake: coins
    /// Close-completion Unix timestamp, or zero when inactive.
    unlockTs: uint32
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
    /// Minimum Proxy stake in nanotons.
    minProxyStake: coins
    /// Minimum Client stake in nanotons.
    minClientStake: coins
    /// Protocol parameter revision copied at deployment.
    paramsVersion: uint32
}

/// Return the complete public state and economic parameters of the Proxy.
get fun get_cocoon_proxy_data(): CocoonProxyDataResult {
    throw 0;
}

/// Proxy exit codes raised for malformed, unauthorized, or invalid commands.
enum CocoonProxyErrors {
    /// Message value cannot cover the requested operation and fees.
    LowMessageValue = 1003
    /// Signed payload header differs from the outer message header.
    SignedMessageFormatMismatch = 1005
    /// Operation is incompatible with the current lifecycle state.
    Closed = 1006
    /// Ed25519 signature validation failed.
    BadSignature = 1007
    /// Command sender is not the configured Proxy owner.
    ExpectedMessageFromOwner = 1010
    /// Close completion was requested before the unlock timestamp.
    NotUnlockedYet = 1011
    /// Incoming opcode or referenced inner opcode is not supported.
    UnknownOperation = 1012
    /// Legacy text command byte is not recognized.
    UnknownTextOperation = 1013
    /// Sender does not match the deterministic Client or Worker address.
    ContractAddressMismatch = 1014
    /// Signed command targets a different Proxy address.
    ExpectedMyAddress = 1015
}
