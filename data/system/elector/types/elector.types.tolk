/// TON system Elector contract for validator elections, stake recovery, validator-set installation, and complaints.
contract Elector {
    author: "TON Core"
    version: "1.0"
    description: "TON system Elector ABI for storage, validator election messages, complaint voting, outgoing responses, and public getters."
    storage: ElectorStorage
    incomingMessages: ElectorIncomingMessage
    outgoingMessages: ElectorOutgoingMessage
    forceAbiExport: ElectorEmptyBody
        | ElectorComplaintVoteRequest
        | ElectorComplaintPrices
        | ElectorValidatorConfig
        | ElectorValidatorSet
        | ElectorValidatorDescr
        | ElectorValidatorDescrWithAdnl
        | ElectorNewStakeReturnReason
        | ElectorComplaintError
        | ElectorComplaintVoteStatus
    thrownErrors: ElectorErrors
}

/// Credit value returned to a masterchain wallet address hash.
type ElectorCredits = map<uint256, coins>

/// Persistent Elector state stored in the root data cell.
struct ElectorStorage {
    /// Optional current election round cell; absent when no election is open.
    currentElection: Cell<ElectorCurrentElection>?
    /// Recoverable stake credits keyed by masterchain wallet address hash.
    credits: ElectorCredits
    /// Past election rounds keyed by election start Unix time.
    pastElections: map<uint32, ElectorPastElection>
    /// Unallocated Elector grams used for active validator-set bonuses.
    grams: coins
    /// Election id for the active validator set, or zero when unknown.
    activeId: uint32
    /// Cell hash of the active validator set stored in config param 34.
    activeHash: uint256
}

/// Current election round data stored as an optional referenced root cell.
struct ElectorCurrentElection {
    /// Election start Unix time.
    electionAt: uint32
    /// Unix time after which the Elector may finalize the round.
    electionClose: uint32
    /// Minimum accepted stake for this round.
    minStake: coins
    /// Total stake submitted for this round before final selection.
    totalStake: coins
    /// Submitted member records keyed by validator public key.
    members: map<uint256, ElectorMemberParams>
    /// One-bit flag set when validator selection failed and awaits a new stake.
    failed: int1
    /// One-bit flag set after a validator set has been selected and sent to Config.
    finished: int1
}

/// Validator stake submission stored inside a current election round.
struct ElectorMemberParams {
    /// Accumulated stake attached by this validator.
    stake: coins
    /// Unix time when the current member record was last written.
    timestamp: uint32
    /// Maximum stake factor scaled by 65536.
    maxFactor: uint32
    /// Masterchain source wallet address hash allowed to own this validator key.
    sourceAddress: uint256
    /// Validator ADNL address; zero means no ADNL address is included in the validator descriptor.
    adnlAddress: uint256
}

/// Past election round data stored until its stakes can be unfrozen.
struct ElectorPastElection {
    /// Unix time when this past election can be unfrozen.
    unfreezeAt: uint32
    /// Stake hold duration in seconds.
    stakeHeld: uint32
    /// Validator-set cell hash associated with this election.
    validatorSetHash: uint256
    /// Frozen validator stake records keyed by validator public key.
    frozen: map<uint256, ElectorValidatorInRound>
    /// Total frozen validator stake remaining in the round.
    totalStake: coins
    /// Bonus grams assigned to this validator set.
    bonuses: coins
    /// Complaint status records keyed by complaint cell hash.
    complaints: map<uint256, ElectorComplaintStatus>
}

/// Frozen validator stake record for a past election round.
struct ElectorValidatorInRound {
    /// Masterchain wallet address hash receiving unfrozen stake or rewards.
    addressHash: uint256
    /// Validator-set voting weight.
    weight: uint64
    /// Frozen stake remaining after any punishment.
    stake: coins
    /// One-bit flag marking a validator whose stake is recovered by the Elector.
    banned: int1
}

/// Stored complaint status record.
struct (0x2d) ElectorComplaintStatus {
    /// Referenced validator complaint cell.
    complaint: Cell<ElectorComplaint>
    /// Vote timestamps keyed by current-validator index.
    voters: map<uint16, uint32>
    /// Validator-set cell hash whose votes are currently counted.
    validatorSetId: uint256
    /// Remaining signed voting weight before the complaint is accepted.
    weightRemaining: int64
}

/// Validator complaint payload submitted for a past election.
struct (0xbc) ElectorComplaint {
    /// Public key of the validator being complained about.
    validatorPubkey: uint256
    /// Referenced complaint description payload.
    description: cell
    /// Unix time recorded in the stored complaint.
    createdAt: uint32
    /// Complaint severity byte.
    severity: uint8
    /// Masterchain reward wallet address hash recorded for the complaint creator.
    rewardAddress: uint256
    /// Complaint storage deposit and creation price paid by the creator.
    paid: coins
    /// Fixed fine suggested by the complaint.
    suggestedFine: coins
    /// Fractional fine part scaled by 2^32 and applied to validator stake.
    suggestedFinePart: uint32
}

/// Complaint pricing tuple read from config param 13 or defaulted by the Elector.
struct (0x1a) ElectorComplaintPrices {
    /// Base complaint deposit.
    deposit: coins
    /// Price per stored bit.
    bitPrice: coins
    /// Price per stored cell.
    cellPrice: coins
}

/// Config param 15 validator timing tuple used by election scheduling.
struct ElectorValidatorConfig {
    /// Validator-set lifetime in seconds.
    electedFor: uint32
    /// Seconds before validator-set start when elections begin.
    electionsBeginBefore: uint32
    /// Seconds before validator-set start when elections close.
    electionsEndBefore: uint32
    /// Stake hold duration in seconds after validator-set end.
    stakeHeldFor: uint32
}

/// Extended validator-set config cell emitted to the Config contract.
struct (0x12) ElectorValidatorSet {
    /// Validator-set start Unix time.
    utimeSince: uint32
    /// Validator-set end Unix time.
    utimeUntil: uint32
    /// Total number of validators in the set.
    total: uint16
    /// Number of main validators in the set.
    main: uint16
    /// Sum of validator weights.
    totalWeight: uint64
    /// Validator descriptors keyed by validator index.
    validators: map<uint16, ElectorAnyValidatorDescr>
}

/// Validator descriptor without an ADNL address.
struct (0x538e81278a) ElectorValidatorDescr {
    /// Validator Ed25519 public key.
    validatorPubkey: uint256
    /// Validator voting weight.
    validatorWeight: uint64
}

/// Validator descriptor with an ADNL address.
struct (0x738e81278a) ElectorValidatorDescrWithAdnl {
    /// Validator Ed25519 public key.
    validatorPubkey: uint256
    /// Validator voting weight.
    validatorWeight: uint64
    /// Validator ADNL address.
    adnlAddress: uint256
}

/// Validator descriptor variants stored in validator-set dictionaries.
type ElectorAnyValidatorDescr =
    | ElectorValidatorDescr
    | ElectorValidatorDescrWithAdnl

/// Accepted empty internal body; value is accounted without a command opcode.
struct ElectorEmptyBody {}

/// Text-comment body accepted as a simple value transfer.
struct (0x00000000) ElectorTextComment {
    /// Remaining comment payload ignored by the Elector.
    tail: RemainingBitsAndRefs
}

/// Request to submit or increase a validator stake for the current election.
struct (0x4e73744b) ElectorNewStake {
    /// Caller-selected query id copied into Elector responses.
    queryId: uint64
    /// Validator Ed25519 public key.
    validatorPubkey: uint256
    /// Election start Unix time being staked for.
    stakeAt: uint32
    /// Maximum stake factor scaled by 65536.
    maxFactor: uint32
    /// Validator ADNL address.
    adnlAddress: uint256
    /// Referenced Ed25519 signature over the new-stake request data.
    signature: Cell<bits512>
}

/// Request to recover an available stake credit for the sender.
struct (0x47657424) ElectorRecoverStake {
    /// Caller-selected query id copied into the Elector response.
    queryId: uint64
}

/// Config-authorized code upgrade request.
struct (0x4e436f64) ElectorUpgradeCode {
    /// Caller-selected query id copied into the Elector response.
    queryId: uint64
    /// Replacement code cell.
    newCode: cell
    /// Optional tail that triggers the post-upgrade acknowledgement path.
    tail: RemainingBitsAndRefs
}

/// Config contract acknowledgement that the validator-set update succeeded.
struct (0xee764f4b) ElectorConfigSetAccepted {
    /// Election id copied from the validator-set install request.
    queryId: uint64
}

/// Config contract acknowledgement that the validator-set update failed.
struct (0xee764f6f) ElectorConfigSetRejected {
    /// Election id copied from the validator-set install request.
    queryId: uint64
}

/// Complaint registration request for a past election.
struct (0x52674370) ElectorNewComplaint {
    /// Caller-selected query id copied into the Elector response.
    queryId: uint64
    /// Past election id being complained about.
    electionId: uint32
    /// Complaint payload stored under its cell hash after Elector rewrites accounting fields.
    complaint: ElectorComplaint
}

/// Unsigned complaint vote request signed by a current validator.
struct (0x56744350) ElectorComplaintVoteRequest {
    /// Current validator-set index of the voting validator.
    validatorIndex: uint16
    /// Past election id containing the complaint.
    electionId: uint32
    /// Complaint cell hash being voted on.
    complaintHash: uint256
}

/// Signed complaint vote submitted to the Elector.
struct (0x56744370) ElectorSignedComplaintVote {
    /// Caller-selected query id copied into the Elector response.
    queryId: uint64
    /// Ed25519 signature over the embedded complaint vote request.
    signature: bits512
    /// Vote request whose tag and fields are covered by the signature.
    vote: ElectorComplaintVoteRequest
}

/// Internal message bodies accepted by the Elector.
type ElectorIncomingMessage =
    | ElectorTextComment
    | ElectorNewStake
    | ElectorRecoverStake
    | ElectorUpgradeCode
    | ElectorConfigSetAccepted
    | ElectorConfigSetRejected
    | ElectorNewComplaint
    | ElectorSignedComplaintVote

/// Response returning stake after a rejected new-stake request.
struct (0xee6f454c) ElectorNewStakeReturned {
    /// Query id copied from the rejected new-stake request.
    queryId: uint64
    /// New-stake return reason code.
    reason: uint32
}

/// Response confirming an accepted new-stake request.
struct (0xf374484c) ElectorNewStakeConfirmed {
    /// Query id copied from the accepted new-stake request.
    queryId: uint64
    /// Confirmation comment code.
    comment: uint32
}

/// Response returning a recovered stake credit.
struct (0xf96f7324) ElectorRecoverStakePaid {
    /// Query id copied from the recover-stake request.
    queryId: uint64
}

/// Recover-stake error response.
struct (0xfffffffe) ElectorRecoverStakeRejected {
    /// Query id copied from the recover-stake request.
    queryId: uint64
    /// Original request opcode.
    requestOpcode: uint32
}

/// Code-upgrade success response.
struct (0xce436f64) ElectorUpgradeCodeAccepted {
    /// Query id copied from the upgrade request.
    queryId: uint64
    /// Original request opcode.
    requestOpcode: uint32
}

/// Generic unsupported-query or failed-upgrade response.
struct (0xffffffff) ElectorQueryRejected {
    /// Query id copied from the rejected request.
    queryId: uint64
    /// Original request opcode.
    requestOpcode: uint32
}

/// Request emitted to the Config contract to install a validator set.
struct (0x4e565354) ElectorInstallValidatorSet {
    /// Election id used as the Config request query id.
    queryId: uint64
    /// Referenced extended validator-set cell.
    validatorSet: Cell<ElectorValidatorSet>
}

/// Complaint registration accepted; the creator's price was reserved.
struct (0xf2676350) ElectorComplaintAccepted {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: sender is not in the masterchain.
struct (0xf2676351) ElectorComplaintRejectedNotMasterchain {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: election id is unknown.
struct (0xf2676352) ElectorComplaintRejectedElectionNotFound {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: complaint cell depth is too large.
struct (0xf2676353) ElectorComplaintRejectedCellTooDeep {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: election is already expired.
struct (0xf2676354) ElectorComplaintRejectedAlreadyExpired {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: message value is below the computed price.
struct (0xf2676355) ElectorComplaintRejectedNotEnoughMoney {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: validator public key is absent from the frozen set.
struct (0xf2676356) ElectorComplaintRejectedValidatorNotFound {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: suggested fine exceeds the validator stake.
struct (0xf2676357) ElectorComplaintRejectedFineTooLarge {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: suggested fine does not exceed the complaint price.
struct (0xf2676358) ElectorComplaintRejectedPaidMoreThanFine {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Complaint rejected: complaint with the same hash already exists.
struct (0xf2676359) ElectorComplaintRejectedDuplicate {
    /// Query id copied from the complaint request.
    queryId: uint64
    /// Original complaint request opcode.
    requestOpcode: uint32
}

/// Vote response for an already accepted complaint from an older validator set.
struct (0xd674523d) ElectorComplaintVoteOldValidatorSet {
    /// Query id copied from the complaint-vote request.
    queryId: uint64
    /// Original complaint-vote request opcode.
    requestOpcode: uint32
}

/// Vote response for an unknown past election id.
struct (0xd674523e) ElectorComplaintVoteElectionNotFound {
    /// Query id copied from the complaint-vote request.
    queryId: uint64
    /// Original complaint-vote request opcode.
    requestOpcode: uint32
}

/// Vote response for an unknown complaint hash.
struct (0xd674523f) ElectorComplaintVoteComplaintNotFound {
    /// Query id copied from the complaint-vote request.
    queryId: uint64
    /// Original complaint-vote request opcode.
    requestOpcode: uint32
}

/// Vote response for a validator index that already voted.
struct (0xd6745240) ElectorComplaintVoteAlreadyVoted {
    /// Query id copied from the complaint-vote request.
    queryId: uint64
    /// Original complaint-vote request opcode.
    requestOpcode: uint32
}

/// Vote response for a recorded vote that has not yet accepted the complaint.
struct (0xd6745241) ElectorComplaintVoteRecorded {
    /// Query id copied from the complaint-vote request.
    queryId: uint64
    /// Original complaint-vote request opcode.
    requestOpcode: uint32
}

/// Vote response for a vote that accepted the complaint and applied punishment.
struct (0xd6745242) ElectorComplaintVoteAccepted {
    /// Query id copied from the complaint-vote request.
    queryId: uint64
    /// Original complaint-vote request opcode.
    requestOpcode: uint32
}

/// Internal message bodies emitted by the Elector.
type ElectorOutgoingMessage =
    | ElectorNewStakeReturned
    | ElectorNewStakeConfirmed
    | ElectorRecoverStakePaid
    | ElectorRecoverStakeRejected
    | ElectorUpgradeCodeAccepted
    | ElectorQueryRejected
    | ElectorInstallValidatorSet
    | ElectorComplaintAccepted
    | ElectorComplaintRejectedNotMasterchain
    | ElectorComplaintRejectedElectionNotFound
    | ElectorComplaintRejectedCellTooDeep
    | ElectorComplaintRejectedAlreadyExpired
    | ElectorComplaintRejectedNotEnoughMoney
    | ElectorComplaintRejectedValidatorNotFound
    | ElectorComplaintRejectedFineTooLarge
    | ElectorComplaintRejectedPaidMoreThanFine
    | ElectorComplaintRejectedDuplicate
    | ElectorComplaintVoteOldValidatorSet
    | ElectorComplaintVoteElectionNotFound
    | ElectorComplaintVoteComplaintNotFound
    | ElectorComplaintVoteAlreadyVoted
    | ElectorComplaintVoteRecorded
    | ElectorComplaintVoteAccepted

/// Reason codes carried by `ElectorNewStakeReturned.reason`.
enum ElectorNewStakeReturnReason {
    /// No active election, sender is not masterchain, or elections are already finished.
    NoActiveOrFinishedElection = 0
    /// Validator signature over the stake request is invalid.
    InvalidSignature = 1
    /// Stake is below the one-over-4096 total-stake threshold.
    StakeBelowTotalRatio = 2
    /// Stake targets a different election start time.
    WrongElection = 3
    /// Existing validator public key was staked from another source address.
    StakeFromDifferentAddress = 4
    /// Accumulated stake is below the configured minimum.
    BelowMinStake = 5
    /// Max-factor is below one, encoded as 65536.
    MaxFactorTooLow = 6
}

/// Error codes returned by complaint registration before response-opcode encoding.
enum ElectorComplaintError {
    /// Complaint sender is not in the masterchain.
    NotMasterchain = -1
    /// Past election id was not found.
    ElectionNotFound = -2
    /// Complaint cell depth is too large.
    CellTooDeep = -3
    /// Past election has already expired.
    AlreadyExpired = -4
    /// Message value is below the computed complaint price.
    NotEnoughMoney = -5
    /// Complained validator public key is absent from the frozen set.
    ValidatorNotFound = -6
    /// Suggested fine exceeds validator stake.
    FineTooLarge = -7
    /// Suggested fine is not greater than the complaint price.
    PaidMoreThanFine = -8
    /// Complaint hash already exists.
    DuplicateComplaint = -9
}

/// Status codes returned by complaint vote registration before response-opcode encoding.
enum ElectorComplaintVoteStatus {
    /// Complaint had already collected enough votes under an older validator set.
    OldValidatorSetAccepted = -3
    /// Past election id was not found.
    ElectionNotFound = -2
    /// Complaint hash was not found.
    ComplaintNotFound = -1
    /// Validator index already voted.
    AlreadyVoted = 0
    /// Vote was recorded but the complaint has not yet reached the threshold.
    VoteRecorded = 1
    /// Vote accepted the complaint and triggered punishment.
    ComplaintAccepted = 2
}

/// Source-level Elector exit-code catalog.
enum ElectorErrors {
    /// Invalid tagged complaint, complaint-status, or complaint-pricing cell.
    InvalidTaggedCell = 9
    /// Complaint-vote signature does not match the current validator public key.
    InvalidComplaintVoteSignature = 34
    /// Complaint-vote signed payload tag is invalid.
    InvalidComplaintVoteTag = 37
    /// Current validator-set config is not encoded as `validators_ext`.
    InvalidCurrentValidatorSet = 40
    /// Current validator descriptor or Ed25519 public-key tag is invalid.
    InvalidValidatorDescriptor = 41
    /// Accepted new-stake value is zero after validation.
    EmptyAcceptedStake = 44
    /// Selected validator total stake does not match the computed best stake.
    ValidatorSelectionStakeMismatch = 49
    /// Stored active validator-set hash does not match the past-election record.
    ActiveValidatorSetHashMismatch = 57
    /// Unfreeze accounting does not match the stored total stake or bonuses.
    UnfreezeAccountingMismatch = 59
    /// Selected validator member record is missing while building the validator set.
    MissingSelectedMember = 61
}

/// Entry returned by `participant_list`.
struct ElectorParticipantEntry {
    /// Validator public key.
    validatorPubkey: uint256
    /// Submitted stake.
    stake: coins
}

/// Nested member tuple returned by `participant_list_extended`.
struct ElectorParticipantExtendedParams {
    /// Submitted stake.
    stake: coins
    /// Maximum stake factor scaled by 65536.
    maxFactor: uint32
    /// Masterchain source wallet address hash.
    sourceAddress: uint256
    /// Validator ADNL address.
    adnlAddress: uint256
}

/// Entry returned inside `participant_list_extended`.
struct ElectorParticipantExtendedEntry {
    /// Validator public key.
    validatorPubkey: uint256
    /// Submitted member data.
    params: ElectorParticipantExtendedParams
}

/// Structured result returned by `participant_list_extended`.
struct ElectorParticipantListExtendedReply {
    /// Election start Unix time.
    electionAt: uint32
    /// Election close Unix time.
    electionClose: uint32
    /// Minimum accepted stake.
    minStake: coins
    /// Total submitted stake.
    totalStake: coins
    /// Current participants in ascending public-key order.
    participants: lisp_list<ElectorParticipantExtendedEntry>
    /// One-bit failure flag returned as an integer.
    failed: int
    /// One-bit finished flag returned as an integer.
    finished: int
}

/// Entry returned by `past_elections`.
struct ElectorPastElectionEntry {
    /// Election id.
    electionId: uint32
    /// Unfreeze Unix time.
    unfreezeAt: uint32
    /// Stake hold duration in seconds.
    stakeHeld: uint32
    /// Validator-set cell hash.
    validatorSetHash: uint256
    /// Frozen validator stake records.
    frozen: map<uint256, ElectorValidatorInRound>
    /// Total frozen stake.
    totalStake: coins
    /// Bonus grams assigned to the validator set.
    bonuses: coins
    /// Complaint status records.
    complaints: map<uint256, ElectorComplaintStatus>
}

/// Short entry returned by `past_elections_list`.
struct ElectorPastElectionShortEntry {
    /// Election id.
    electionId: uint32
    /// Unfreeze Unix time.
    unfreezeAt: uint32
    /// Validator-set cell hash.
    validatorSetHash: uint256
    /// Stake hold duration in seconds.
    stakeHeld: uint32
}

/// Unpacked complaint tuple returned by complaint getters.
struct ElectorComplaintUnpacked {
    /// Public key of the validator being complained about.
    validatorPubkey: uint256
    /// Referenced complaint description payload.
    description: cell
    /// Unix time recorded in the stored complaint.
    createdAt: uint32
    /// Complaint severity byte.
    severity: uint8
    /// Masterchain reward wallet address hash.
    rewardAddress: uint256
    /// Complaint storage deposit and creation price paid by the creator.
    paid: coins
    /// Fixed fine suggested by the complaint.
    suggestedFine: coins
    /// Fractional fine part scaled by 2^32.
    suggestedFinePart: uint32
}

/// Full complaint getter result.
struct ElectorComplaintFullInfo {
    /// Unpacked complaint fields.
    complaint: ElectorComplaintUnpacked
    /// Validator indices that voted for the complaint.
    voters: lisp_list<int>
    /// Validator-set cell hash whose votes are currently counted.
    validatorSetId: uint256
    /// Remaining signed voting weight before the complaint is accepted.
    weightRemaining: int64
}

/// Entry returned by `list_complaints`.
struct ElectorComplaintListEntry {
    /// Complaint cell hash.
    complaintHash: uint256
    /// Full complaint status information.
    info: ElectorComplaintFullInfo
}

/// Return active election id, or zero when no election is open.
get fun active_election_id(): uint32 {
    throw 0;
}

/// Return submitted stake for a validator public key in the current election, or zero.
get fun participates_in(validatorPubkey: uint256): coins {
    throw 0;
}

/// Return the list of current-election participants with stakes.
get fun participant_list(): lisp_list<ElectorParticipantEntry> {
    throw 0;
}

/// Return current-election metadata and the full participant list.
get fun participant_list_extended(): ElectorParticipantListExtendedReply {
    throw 0;
}

/// Return recoverable stake credit for a masterchain wallet address hash.
get fun compute_returned_stake(walletAddress: uint256): coins {
    throw 0;
}

/// Return past election ids.
get fun past_election_ids(): lisp_list<uint32> {
    throw 0;
}

/// Return full past election records.
get fun past_elections(): lisp_list<ElectorPastElectionEntry> {
    throw 0;
}

/// Return short past election records.
get fun past_elections_list(): lisp_list<ElectorPastElectionShortEntry> {
    throw 0;
}

/// Return raw nullable complaints dictionary for a past election.
get fun get_past_complaints(electionId: uint32): cell? {
    throw 0;
}

/// Return one complaint tuple by past election id and complaint hash, or null.
get fun show_complaint(
    electionId: uint32,
    complaintHash: uint256,
): [ElectorComplaintUnpacked, lisp_list<int>, uint256, int64]? {
    throw 0;
}

/// Return all complaints for a past election.
get fun list_complaints(electionId: uint32): lisp_list<ElectorComplaintListEntry> {
    throw 0;
}

/// Return complaint storage and creation price including the one-gram processing margin.
get fun complaint_storage_price(bits: int, refs: int, expireIn: int): coins {
    throw 0;
}
