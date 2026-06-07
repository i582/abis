/// Airdrop Interlocker v2 contract that validates a Merkle proof and releases claim amounts across unlock periods.
contract AirdropInterlockerV2 {
    author: "Airdrop"
    version: "2.0"
    description: "Airdrop Interlocker v2 ABI for proof-backed lock-and-claim flow with unlock schedule"
    storage: AirdropInterlockerV2Storage
    incomingMessages: AirdropInterlockerV2IncomingMessage
    outgoingMessages: AirdropInterlockerV2OutgoingMessage
    thrownErrors: AirdropInterlockerV2Errors
}

/// Persistent v2 interlocker state stored in the root data cell.
struct AirdropInterlockerV2Storage {
    /// True after all remaining amount has been claimed.
    claimed: bool
    /// Merkle root used to validate the claim proof.
    merkleRoot: uint256
    /// Receiver address authorized to send `lock_and_claim`.
    receiver: address
    /// Distributor address receiving outgoing claimed amount messages.
    distributor: address
    /// Minimum incoming TON value required to cover claim commission.
    minCommission: coins
    /// True after total claim amount has been learned from a valid proof.
    amountKnown: bool
    /// Referenced total and already claimed amount counters.
    totals: Cell<AirdropInterlockerV2Totals>
    /// Referenced unlock schedule cell returned by `get_unlocks_info`.
    unlocks: cell
}

/// Claim amount counters stored in a referenced storage cell.
struct AirdropInterlockerV2Totals {
    /// Total amount allocated to this receiver.
    totalAmount: coins
    /// Amount already released to the distributor.
    claimedAmount: coins
}

/// Receiver-originated claim request with an optional Merkle proof cell.
struct (0x3a86f1a0) AirdropInterlockerV2LockAndClaim {
    /// Claim key used to select the proof dictionary entry.
    queryId: uint64
    /// Optional referenced Merkle proof cell; required until amount is known.
    proof: cell?
}

/// Claim notification emitted to the distributor after a successful unlock claim.
struct (0x013a3ca6) AirdropInterlockerV2ClaimNotification {
    /// Claim key copied from the accepted request.
    queryId: uint64
    /// Receiver address whose claim was released.
    receiver: address
    /// Amount released by this unlock claim.
    amount: coins
}

/// Internal message bodies accepted by Airdrop Interlocker v2.
type AirdropInterlockerV2IncomingMessage =
    | AirdropInterlockerV2LockAndClaim

/// Internal message bodies emitted by Airdrop Interlocker v2.
type AirdropInterlockerV2OutgoingMessage =
    | AirdropInterlockerV2ClaimNotification

/// Structured result returned by `get_distribution_info`.
struct GetDistributionInfoReply {
    /// Merkle root used to validate the claim proof.
    merkleRoot: uint256
    /// Receiver address authorized to claim.
    receiver: address
    /// Distributor address receiving outgoing claimed amount messages.
    distributor: address
    /// Minimum incoming TON value required to cover claim commission.
    minCommission: coins
}

/// Structured result returned by `get_unlocks_info`.
struct GetUnlocksInfoReply {
    /// True after all remaining amount has been claimed.
    claimed: bool
    /// Total amount allocated to this receiver.
    totalAmount: coins
    /// Amount already released to the distributor.
    claimedAmount: coins
    /// Raw unlock schedule cell.
    unlocks: cell
}

/// Airdrop Interlocker v2 exit-code catalog.
enum AirdropInterlockerV2Errors {
    /// Proof dictionary has no entry for the provided query id.
    MissingProofEntry = 404
    /// This interlocker has already processed all available claims.
    AlreadyClaimed = 405
    /// Incoming message sender is not the stored receiver.
    SenderIsNotReceiver = 406
    /// Incoming message value is below the stored minimum commission.
    InsufficientCommission = 407
    /// Unlock schedule has no currently available amount.
    NoAvailableUnlock = 409
    /// Claim request does not carry a required proof reference.
    MissingProof = 600
    /// Proof cell does not start with the expected Merkle-proof tag.
    InvalidProofTag = 601
    /// Receiver encoded in the proof does not match storage.
    ProofReceiverMismatch = 602
    /// Incoming message opcode is unsupported.
    UnknownOpcode = 65535
}

/// Return Merkle root, receiver, distributor, and minimum commission.
get fun get_distribution_info(): GetDistributionInfoReply {
    throw 0;
}

/// Return claim state, amount counters, and raw unlock schedule.
get fun get_unlocks_info(): GetUnlocksInfoReply {
    throw 0;
}

/// Return the amount currently available for claim.
get fun get_available_claim_amount(): coins {
    throw 0;
}
