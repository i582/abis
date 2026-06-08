import "@stdlib/lisp-lists"

/// TON system Config contract for network parameters, validator-set installation, and config governance.
contract Config {
    author: "TON Core"
    version: "1.0"
    description: "Mainnet TON Config contract interface for network configuration governance."
    incomingMessages: ConfigIncomingInternalMessage
    incomingExternal: ConfigIncomingExternalMessage
    outgoingMessages: ConfigOutgoingMessage
    storage: ConfigStorage
    thrownErrors: ConfigErrors
}

/// Config contract exit codes.
enum ConfigErrors {
    /// Validator set cell tag or descriptor is invalid.
    InvalidValidatorSet = 9
    /// External signed action opcode is not supported.
    UnknownExternalAction = 32
    /// External signed message seqno does not match storage.
    BadExternalSeqno = 33
    /// External or validator vote signature is invalid.
    InvalidSignature = 34
    /// External signed message validity timestamp has expired.
    ExternalMessageExpired = 35
    /// Internal message body opcode or payload is invalid.
    InvalidInternalMessage = 37
    /// External signed body depth exceeds the accepted limit.
    ExternalBodyTooDeep = 39
    /// Current validator set config cell is invalid.
    InvalidCurrentValidatorSet = 40
    /// Current validator descriptor is invalid.
    InvalidValidatorDescription = 41
    /// Proposal, proposal status, or voting setup cell tag is invalid.
    InvalidProposalOrVotingCell = 44
}

/// Config parameter dictionary keyed by signed parameter id.
type ConfigParamDict = map<int32, cell>

/// Active voting proposal statuses keyed by proposal cell hash.
type ConfigVoteDict = map<uint256, ConfigProposalStatus>

/// Validator vote timestamps keyed by validator index inside a proposal status.
type ConfigVotersDict = map<uint16, uint32>

/// Store the referenced config parameter dictionary root.
fun ConfigParamDict.packToBuilder(self, mutate b: builder) {
    val dictRoot = self.toLowLevelDict();
    b.storeRef(dictRoot!);
}

/// Load the referenced config parameter dictionary root.
fun ConfigParamDict.unpackFromSlice(mutate s: slice): ConfigParamDict {
    return createMapFromLowLevelDict(s.loadRef());
}

/// Persistent data root: config dictionary ref, external seqno, master public key, and proposal vote dict.
struct ConfigStorage {
    /// Config parameter cells keyed by signed parameter id.
    config: ConfigParamDict
    /// External signed-message sequence number modulo 2^32.
    storedSeqno: uint32
    /// Master Ed25519 public key authorized for signed external config actions.
    publicKey: uint256
    /// Proposal statuses keyed by proposal cell hash.
    voteDict: ConfigVoteDict
}

/// Signed config proposal stored in proposal refs and proposal-status refs.
struct (0xf3) ConfigProposal {
    /// Signed config parameter id to set, clear, or route to a special governance action.
    paramId: int32
    /// Optional reference to the new parameter cell; absence clears a non-mandatory parameter.
    paramValue: cell?
    /// Optional expected current parameter hash; absence is reported by getters as -1.
    ifHashEqual: uint256?
}

/// Voting setup for normal or critical proposals stored in config parameter 11 refs.
struct (0x36) ConfigProposalSetup {
    /// Minimum total validator-set rounds before a proposal can complete.
    minTotalRounds: uint8
    /// Maximum total validator-set rounds before a proposal is discarded.
    maxTotalRounds: uint8
    /// Required winning rounds for acceptance.
    minWins: uint8
    /// Maximum losing rounds before discard.
    maxLosses: uint8
    /// Minimum paid storage duration in seconds.
    minStoreSec: uint32
    /// Maximum paid storage duration in seconds.
    maxStoreSec: uint32
    /// Per-bit storage price component with the contract's proposal overhead.
    bitPrice: uint32
    /// Per-cell storage price component with the contract's proposal overhead.
    cellPrice: uint32
}

/// Config parameter 11 voting setup with normal and critical proposal setup refs.
struct (0x91) ConfigVotingSetup {
    /// Rules for non-critical config proposals.
    normalParams: Cell<ConfigProposalSetup>
    /// Rules for critical config proposals.
    criticalParams: Cell<ConfigProposalSetup>
}

/// Stored voting status for one proposal hash.
struct (0xce) ConfigProposalStatus {
    /// Absolute Unix expiration time.
    expires: uint32
    /// Reference to the signed proposal cell.
    proposal: Cell<ConfigProposal>
    /// True when the proposal uses critical voting rules.
    isCritical: bool
    /// Validator vote timestamps keyed by validator index.
    voters: ConfigVotersDict
    /// Remaining validator weight needed in the current round.
    remainingWeight: int64
    /// Cell hash of the validator set round this status belongs to.
    validatorSetId: uint256
    /// Remaining validator-set rounds before discard.
    roundsRemaining: uint8
    /// Winning rounds counted by stored status.
    wins: uint8
    /// Losing rounds counted by stored status.
    losses: uint8
}

/// Getter proposal parameter tuple.
type ConfigProposalParameterTuple = [int32, cell?, int]

/// Getter proposal status tuple.
type ConfigProposalTuple = [
    uint32,
    bool,
    ConfigProposalParameterTuple,
    uint256,
    lisp_list<int>,
    int64,
    uint8,
    uint8,
    uint8,
]

/// Entry returned by `list_proposals`.
type ConfigProposalListEntry = [uint256, ConfigProposalTuple]

/// validators_ext#12 cell used by ConfigSetNextValidatorSetRequest.
struct (0x12) ConfigValidatorSetExt {
    /// Validator-set validity start time.
    utimeSince: uint32
    /// Validator-set validity end time.
    utimeUntil: uint32
    /// Total validators in the dictionary.
    total: uint16
    /// Main validators count.
    main: uint16
    /// Total validator weight.
    totalWeight: uint64
    /// Validator descriptors keyed by validator index.
    validators: map<uint16, ConfigAnyValidatorDescr>
}

/// Validator descriptor without ADNL address.
struct (0x53) ConfigValidatorDescr {
    /// Ed25519 public-key constructor tag.
    pubkeyTag: uint32
    /// Validator Ed25519 public key.
    publicKey: uint256
    /// Validator voting weight.
    weight: uint64
}

/// Validator descriptor with ADNL address.
struct (0x73) ConfigValidatorDescrWithAdnl {
    /// Ed25519 public-key constructor tag.
    pubkeyTag: uint32
    /// Validator Ed25519 public key.
    publicKey: uint256
    /// Validator voting weight.
    weight: uint64
    /// Validator ADNL address hash.
    adnlAddress: uint256
}

/// Validator descriptor variants stored in validator-set dictionaries.
type ConfigAnyValidatorDescr =
    | ConfigValidatorDescr
    | ConfigValidatorDescrWithAdnl

/// Supported incoming internal message bodies.
type ConfigIncomingInternalMessage =
    | ConfigSetNextValidatorSetRequest
    | ConfigNewVotingProposalRequest
    | ConfigVoteForProposalRequest

/// Request from Elector to stage config parameter 36 as the next validator set.
struct (0x4e565354) ConfigSetNextValidatorSetRequest {
    /// Caller-supplied query id echoed in the response.
    queryId: uint64
    /// Reference to validators_ext#12 validator-set cell.
    vset: Cell<ConfigValidatorSetExt>
}

/// Request to register or extend a voting proposal.
struct (0x6e565052) ConfigNewVotingProposalRequest {
    /// Caller-supplied query id echoed in the response.
    queryId: uint64
    /// Relative storage duration in seconds, or absolute Unix expiration when high bits are set.
    expireAt: uint32
    /// Reference to cfg_proposal#f3.
    proposal: Cell<ConfigProposal>
    /// Critical voting flag stored in the proposal status.
    critical: bool
}

/// Signed vote payload authenticated by validator public key.
struct (0x566f7445) ConfigSignedVotePayload {
    /// Validator index in the current validator set.
    validatorIndex: uint16
    /// Hash of the proposal cell being voted for.
    proposalHash: uint256
}

/// Incoming internal vote request carrying a validator signature over the signed payload.
struct (0x566f7465) ConfigVoteForProposalRequest {
    /// Caller-supplied query id echoed in the response.
    queryId: uint64
    /// Ed25519 signature over the following signed vote payload slice.
    signature: bits512
    /// Inline signed vote body tagged with 0x566f7445.
    signedBody: ConfigSignedVotePayload
}

/// Full external signed message body: signature plus one action-specific payload.
struct ConfigIncomingExternalMessage {
    /// Ed25519 signature over action, seqno, validity, and action-specific body.
    signature: bits512
    /// Signed action selected by the following opcode.
    action: ConfigExternalAction
}

/// Supported signed external actions.
type ConfigExternalAction =
    | ConfigExternalVoteForProposalAction
    | ConfigExternalChangeParamAction
    | ConfigExternalChangeConfigCodeAction
    | ConfigExternalChangeMasterPublicKeyAction
    | ConfigExternalChangeElectorCodeAction

/// External validator vote action.
struct (0x566f7465) ConfigExternalVoteForProposalAction {
    /// Expected storage seqno.
    msgSeqno: uint32
    /// Unix time after which the message is invalid.
    validUntil: uint32
    /// Validator index in the current validator set.
    validatorIndex: uint16
    /// Hash of the proposal cell being voted for.
    proposalHash: uint256
}

/// External master-key action to change one config parameter immediately.
struct (0x43665021) ConfigExternalChangeParamAction {
    /// Expected storage seqno.
    msgSeqno: uint32
    /// Unix time after which the message is invalid.
    validUntil: uint32
    /// Signed config parameter id.
    paramId: int32
    /// Reference to the new parameter cell.
    paramValue: cell
}

/// External master-key action to change Config contract code.
struct (0x4e436f64) ConfigExternalChangeConfigCodeAction {
    /// Expected storage seqno.
    msgSeqno: uint32
    /// Unix time after which the message is invalid.
    validUntil: uint32
    /// Reference to the replacement code cell.
    newCode: cell
    /// Remaining upgrade payload passed to the post-upgrade hook.
    upgradePayload: RemainingBitsAndRefs
}

/// External master-key action to replace the master public key.
struct (0x50624b21) ConfigExternalChangeMasterPublicKeyAction {
    /// Expected storage seqno.
    msgSeqno: uint32
    /// Unix time after which the message is invalid.
    validUntil: uint32
    /// New master Ed25519 public key.
    publicKey: uint256
}

/// External master-key action forwarded to Elector as a code-change request.
struct (0x4e43ef05) ConfigExternalChangeElectorCodeAction {
    /// Expected storage seqno.
    msgSeqno: uint32
    /// Unix time after which the message is invalid.
    validUntil: uint32
    /// Payload forwarded after Elector action and query id.
    payload: RemainingBitsAndRefs
}

/// Supported outgoing message bodies.
type ConfigOutgoingMessage =
    | ConfigSetNextValidatorSetAcceptedResponse
    | ConfigSetNextValidatorSetRejectedResponse
    | ConfigNewVotingProposalAcceptedResponse
    | ConfigNewVotingProposalBadCurrentValueHashResponse
    | ConfigNewVotingProposalMandatoryParamCannotBeNullResponse
    | ConfigNewVotingProposalBadValueDepthResponse
    | ConfigNewVotingProposalCriticalFlagRequiredResponse
    | ConfigNewVotingProposalCriticalityMismatchResponse
    | ConfigNewVotingProposalAlreadyExistsResponse
    | ConfigNewVotingProposalExpiresTooSoonResponse
    | ConfigNewVotingProposalNotEnoughFundsResponse
    | ConfigVoteAlreadyRegisteredResponse
    | ConfigVoteProposalNotFoundResponse
    | ConfigVoteStillPendingResponse
    | ConfigVoteCriticalProposalAcceptedResponse
    | ConfigVoteNormalProposalAcceptedResponse
    | ConfigElectorCodeChangeAction

/// Successful SetNextValidatorSet response.
struct (0xee764f4b) ConfigSetNextValidatorSetAcceptedResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Failed SetNextValidatorSet response.
struct (0xee764f6f) ConfigSetNextValidatorSetRejectedResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Successful NewVotingProposal response.
struct (0xee565052) ConfigNewVotingProposalAcceptedResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response for mismatched current config value hash.
struct (0xe2646356) ConfigNewVotingProposalBadCurrentValueHashResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response for clearing a mandatory parameter.
struct (0xcd506e6c) ConfigNewVotingProposalMandatoryParamCannotBeNullResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response for an oversized proposed value.
struct (0xc2616456) ConfigNewVotingProposalBadValueDepthResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response for proposing a critical parameter without the critical flag.
struct (0xc3726954) ConfigNewVotingProposalCriticalFlagRequiredResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response for extending an existing proposal with a different critical flag.
struct (0xc3726955) ConfigNewVotingProposalCriticalityMismatchResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response when the existing proposal already expires no earlier.
struct (0xc16c7245) ConfigNewVotingProposalAlreadyExistsResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response when requested storage time is below the minimum.
struct (0xc5787069) ConfigNewVotingProposalExpiresTooSoonResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// NewVotingProposal error response when the message value cannot cover storage price plus reserve.
struct (0xf0617924) ConfigNewVotingProposalNotEnoughFundsResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Vote response when this validator already voted for the proposal.
struct (0xd674523e) ConfigVoteAlreadyRegisteredResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Vote response when the proposal is absent, expired, or discarded.
struct (0xd674523f) ConfigVoteProposalNotFoundResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Vote response when the proposal remains pending after recording this vote.
struct (0xd6745242) ConfigVoteStillPendingResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Vote response when a critical proposal reaches the required wins.
struct (0xd6745245) ConfigVoteCriticalProposalAcceptedResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Vote response when a non-critical proposal reaches the required wins.
struct (0xd6745246) ConfigVoteNormalProposalAcceptedResponse {
    /// Query id copied from the request.
    queryId: uint64
}

/// Outgoing body forwarded to Elector to request code replacement.
struct (0x4e436f64) ConfigElectorCodeChangeAction {
    /// Query id generated from current Unix time.
    queryId: uint64
    /// Remaining external action payload forwarded to Elector.
    payload: RemainingBitsAndRefs
}

/// Current external signed-message seqno.
get fun seqno(): int {
    throw 0;
}

/// Return one active proposal by proposal cell hash, or null.
get fun get_proposal(proposalHash: int): ConfigProposalTuple? {
    throw 0;
}

/// Return active proposal entries.
get fun list_proposals(): lisp_list<ConfigProposalListEntry> {
    throw 0;
}

/// Computes the paid storage price for a proposal value with explicit size.
get fun proposal_storage_price(critical: int, seconds: int, bits: int, refs: int): int {
    throw 0;
}
