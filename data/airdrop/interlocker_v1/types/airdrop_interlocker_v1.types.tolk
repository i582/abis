/// Airdrop Interlocker v1 contract that validates one Merkle proof and releases the claim amount to a distributor.
contract AirdropInterlockerV1 {
    author: "Airdrop"
    version: "1.0"
    description: "Airdrop Interlocker v1 ABI for one-shot lock-and-claim flow"
    storage: AirdropInterlockerV1Storage
    incomingMessages: AirdropInterlockerV1IncomingMessage
    outgoingMessages: AirdropInterlockerV1OutgoingMessage
    thrownErrors: AirdropInterlockerV1Errors
}

/// Persistent v1 interlocker state stored in the root data cell.
struct AirdropInterlockerV1Storage {
    /// True after the receiver has successfully claimed through this interlocker.
    claimed: bool
    /// Merkle root used to validate the claim proof.
    merkleRoot: uint256
    /// Receiver address authorized to send `lock_and_claim`.
    receiver: address
    /// Distributor address receiving the outgoing claimed amount message.
    distributor: address
    /// Minimum incoming TON value required to cover claim commission.
    minCommission: coins
}

/// Receiver-originated claim request with a mandatory Merkle proof cell.
struct (0x3a86f1a0) AirdropInterlockerV1LockAndClaim {
    /// Claim key used to select the proof dictionary entry.
    queryId: uint64
    /// Referenced Merkle proof cell for this receiver and query id.
    proof: cell
}

/// Claim notification emitted to the distributor after a successful claim.
struct (0x013a3ca6) AirdropInterlockerV1ClaimNotification {
    /// Claim key copied from the accepted request.
    queryId: uint64
    /// Receiver address whose claim was released.
    receiver: address
    /// Amount released by the claim proof.
    amount: coins
}

/// Internal message bodies accepted by Airdrop Interlocker v1.
type AirdropInterlockerV1IncomingMessage =
    | AirdropInterlockerV1LockAndClaim

/// Internal message bodies emitted by Airdrop Interlocker v1.
type AirdropInterlockerV1OutgoingMessage =
    | AirdropInterlockerV1ClaimNotification

/// Structured result returned by `get_contract_data`.
struct GetContractDataReply {
    /// True after the receiver has successfully claimed through this interlocker.
    isClaimed: bool
    /// Merkle root used to validate the claim proof.
    merkleRoot: uint256
    /// Receiver address authorized to claim.
    receiver: address
    /// Distributor address receiving the claimed amount message.
    distributor: address
}

/// Airdrop Interlocker v1 exit-code catalog.
enum AirdropInterlockerV1Errors {
    /// Proof dictionary has no entry for the provided query id.
    MissingProofEntry = 404
    /// This interlocker has already processed a successful claim.
    AlreadyClaimed = 405
    /// Incoming message sender is not the stored receiver.
    SenderIsNotReceiver = 406
    /// Incoming message value is below the stored minimum commission.
    InsufficientCommission = 407
    /// Claim request does not carry a proof reference.
    MissingProof = 600
    /// Proof cell does not start with the expected Merkle-proof tag.
    InvalidProofTag = 601
    /// Receiver encoded in the proof does not match storage.
    ProofReceiverMismatch = 602
    /// Incoming message opcode is unsupported.
    UnknownOpcode = 65535
}

/// Return the claim flag, Merkle root, receiver, and distributor.
get fun get_contract_data(): GetContractDataReply {
    throw 0;
}
