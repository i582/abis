/// GRAM proof-of-work Jetton miner with adaptive mining complexity and signed administration.
contract GramMiner {
    author: "GRAM"
    version: "1.0"
    description: "GRAM Miner accepts proof-of-work submissions, adapts mining complexity, and pays successful miners through its Jetton wallet."
    storage: GramMinerStorage
    incomingMessages: GramMinerIncomingMessage
    incomingExternal: GramMinerExternalBody
    outgoingMessages: GramMinerOutgoingMessage
    forceAbiExport: GramRescaleComplexity | GramSignedAdminRequest
    thrownErrors: Errors
}

/// Persistent state of the GRAM Miner.
struct GramMinerStorage {
    /// Replay-protection sequence number for signed external administration.
    seqno: uint32
    /// Wallet id accepted by signed external requests; zero is also accepted by the contract.
    subwalletId: uint32
    /// Ed25519 public key used to authenticate administrative external messages.
    publicKey: uint256
    /// Current 128-bit proof-of-work challenge seed.
    seed: uint128
    /// Upper bound for the hash of an accepted proof.
    powComplexity: uint256
    /// Unix timestamp of the latest accepted proof or complexity rescale.
    lastSuccess: uint32
    /// Reward and adaptive-complexity parameters.
    parameters: Cell<GramMinerParameters>
}

/// Reward configuration stored in the referenced parameters cell.
struct GramMinerParameters {
    /// Jetton amount paid for a successful proof.
    rewardAmount: coins
    /// Target delay between successful proofs, in seconds.
    targetDelta: uint32
    /// Minimum allowed base-two complexity exponent.
    minComplexityExponent: uint8
    /// Maximum allowed base-two complexity exponent.
    maxComplexityExponent: uint8
    /// Jetton wallet used to send the mining reward.
    jettonWalletAddress: any_address
}

/// One-time initializer accepted while the stored Jetton wallet is `addr_none`.
struct (0x00000007) GramInitializeJettonWallet {
    /// Jetton wallet that will pay all subsequent mining rewards.
    jettonWalletAddress: address
}

/// Proof-of-work submission accepted as an internal message.
struct (0x4d696e65) GramSubmitProofOfWork {
    /// Address flags that must match the value derived from `expire`.
    flags: int8
    /// Short-lived Unix expiry used as part of the proof.
    expire: uint32
    /// Miner-selected 256-bit address material.
    whom: bits256
    /// Random proof data; must equal `rdata2`.
    rdata1: bits256
    /// Challenge seed; must equal the current storage seed.
    rseed: uint128
    /// Repeated proof data used together with `rdata1` to form the reward destination.
    rdata2: bits256
}

/// Permissionless external request that rescales complexity after prolonged inactivity.
struct (0x5253636c) GramRescaleComplexity {
    /// Timestamp newer than the last success and older than the current block time.
    expire: uint32
}

/// Signed administrative external request.
struct GramSignedAdminRequest {
    /// Ed25519 signature over all fields and action references after this signature.
    signature: bits512
    /// Stored subwallet id; zero is accepted as a wildcard value.
    subwalletId: uint32
    /// Unix timestamp after which the request is rejected.
    validUntil: uint32
    /// Sequence number expected to equal storage.seqno.
    msgSeqno: uint32
    /// Repeated send-mode bytes and raw-message references; mode 255 updates miner parameters.
    actions: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Gram Miner.
type GramMinerIncomingMessage =
    | GramInitializeJettonWallet
    | GramSubmitProofOfWork

/// Raw external body used at the contract boundary.
///
/// The first 32 signature bits are unconstrained and can equal the rescale
/// opcode, so the tagged rescale branch and untagged signed branch cannot form
/// an automatically discriminated TL-B union. Both typed variants are exported
/// separately above.
struct GramMinerExternalBody {
    /// Complete external body, including the rescale opcode or admin signature.
    body: RemainingBitsAndRefs
}

/// Standard Jetton transfer emitted to the configured Jetton wallet after a successful proof.
struct (0x0f8a7ea5) GramJettonTransfer {
    /// Always zero in mining rewards.
    queryId: uint64
    /// Configured mining reward amount.
    amount: coins
    /// Internal miner address derived from proof fields.
    destination: address
    /// Same miner address, used for any Jetton response.
    responseDestination: address
    /// No custom payload is emitted by the miner.
    customPayload: cell?
    /// Zero TON is forwarded with the Jetton transfer.
    forwardTonAmount: coins
    /// Inline `Either` selector and forward payload; mining rewards use an empty inline payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Structured outbound message bodies emitted by Gram Miner.
type GramMinerOutgoingMessage = GramJettonTransfer

/// Result of `get_pow_params`.
struct GramMinerPowParamsReply {
    /// Current proof challenge seed.
    seed: uint128
    /// Current accepted-hash upper bound.
    powComplexity: int
    /// Jetton reward amount.
    amount: coins
    /// Target delay between successful proofs.
    interval: uint32
}

/// Result of `get_contract_data`.
struct GramMinerContractDataReply {
    /// Current proof challenge seed.
    seed: uint128
    /// Current accepted-hash upper bound.
    powComplexity: int
    /// Jetton reward amount.
    amount: coins
    /// Target delay between successful proofs.
    targetDelta: uint32
    /// Minimum base-two complexity exponent.
    minComplexityExponent: uint8
    /// Maximum base-two complexity exponent.
    maxComplexityExponent: uint8
    /// Configured reward Jetton wallet.
    jettonWalletAddress: any_address
}

/// GRAM Miner exit codes.
enum Errors {
    /// Submitted body hash is not below the current complexity bound.
    InvalidProofHash = 24
    /// Seed, duplicated proof data, or proof timing relation is invalid.
    InvalidProof = 25
    /// Complexity rescale timestamp has not elapsed.
    RescaleTimestampNotElapsed = 28
    /// Complexity rescale timestamp is not newer than the last success.
    StaleRescaleTimestamp = 29
    /// The miner has not been inactive for sixteen target intervals.
    RescaleTooEarly = 30
    /// Signed administrative request sequence number is invalid.
    InvalidSeqno = 33
    /// Signed administrative request subwallet id is invalid.
    InvalidSubwalletId = 34
    /// Signed administrative request is expired or has an invalid signature.
    ExpiredOrInvalidSignature = 35
    /// Internal proof or initializer message carries less than 0.05 TON.
    InsufficientInternalValue = 44
}

/// Return the signed-administration sequence number.
get fun seqno(): uint32 {
    throw 0;
}

/// Return the stored Ed25519 administrative public key.
get fun get_public_key(): int {
    throw 0;
}

/// Return current proof-of-work parameters.
get fun get_pow_params(): GramMinerPowParamsReply {
    throw 0;
}

/// Return the complete public mining configuration.
get fun get_contract_data(): GramMinerContractDataReply {
    throw 0;
}
