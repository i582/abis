/// TON Validators Nominator Pool contract for pooled validator staking, nominator accounting, withdrawals, and voting.
contract NominatorPool {
    author: "TON Validators"
    version: "1.0"
    description: "TON Validators Nominator Pool for pooled validator staking, nominator deposits and withdrawals, validator maintenance commands, Elector messages, config-proposal voting, and getters."
    storage: NominatorPoolStorage
    incomingMessages: NominatorPoolIncomingMessage
    outgoingMessages: NominatorPoolOutgoingMessage
    forceAbiExport: NominatorPoolConfig
        | NominatorPoolEmpty
        | NominatorPoolVote
        | NominatorPoolVoting
        | NominatorPoolElectorNewStake
        | NominatorPoolEmptyBody
    thrownErrors: NominatorPoolErrors
}

/// Empty dictionary value used as a set marker.
struct NominatorPoolEmpty {}

/// Immutable Pool configuration stored in the root storage reference.
struct NominatorPoolConfig {
    /// Validator masterchain wallet address hash.
    validatorAddress: uint256
    /// Validator reward share over 10000.
    validatorRewardShare: uint16
    /// Maximum number of nominators accepted by the Pool.
    maxNominatorsCount: uint16
    /// Minimum validator-owned stake required by the Pool.
    minValidatorStake: coins
    /// Minimum nominator stake required by the Pool.
    minNominatorStake: coins
}

/// Per-nominator stake record keyed by basechain wallet address hash.
struct NominatorPoolNominator {
    /// Active nominator stake.
    amount: coins
    /// Deposit amount queued for the next validation round.
    pendingDepositAmount: coins
}

/// Per-voter record stored inside a config-proposal voting dictionary.
struct NominatorPoolVote {
    /// One-bit support value where -1 means support and 0 means against.
    support: int1
    /// Unix timestamp when this voter record was created.
    voteTime: uint32
}

/// Config-proposal voting record keyed by proposal hash.
struct NominatorPoolVoting {
    /// Voter records keyed by validator or nominator address hash.
    votes: map<uint256, NominatorPoolVote>
    /// Unix timestamp when this proposal voting was created.
    votesCreateTime: uint32
}

/// Persistent Pool state saved in the root data cell.
@overflow1023_policy("suppress")
struct NominatorPoolStorage {
    /// Pool validation state: idle, new-stake sent, or accepted by Elector.
    state: uint8
    /// Number of current nominator records.
    nominatorsCount: uint16
    /// Stake amount sent to the Elector for the current round.
    stakeAmountSent: coins
    /// Validator-owned amount tracked by the Pool.
    validatorAmount: coins
    /// Referenced immutable Pool configuration.
    config: Cell<NominatorPoolConfig>
    /// Nominator records keyed by basechain wallet address hash.
    nominators: map<uint256, NominatorPoolNominator>
    /// Pending withdrawal requests keyed by basechain wallet address hash.
    withdrawRequests: map<uint256, NominatorPoolEmpty>
    /// Validation round start timestamp used for the active or pending stake.
    stakeAt: uint32
    /// Saved current validator-set hash.
    savedValidatorSetHash: uint256
    /// Number of observed validator-set hash changes.
    validatorSetChangesCount: uint8
    /// Unix timestamp for the last validator-set change tracked by the Pool.
    validatorSetChangeTime: uint32
    /// Stake hold period saved from network config.
    stakeHeldFor: uint32
    /// Config-proposal votings keyed by proposal hash.
    configProposalVotings: map<uint256, NominatorPoolVoting>
}

/// Text-comment nominator command. Action byte is `d`, `w`, `y`, or `n`.
struct (0x00000000) NominatorPoolTextCommand {
    /// Text command action byte.
    action: uint8
    /// Remaining text payload after the action byte.
    tail: RemainingBitsAndRefs
}

/// Maintenance command that accepts attached coins without changing command-specific fields.
struct (0x00000001) NominatorPoolAcceptCoins {
    /// Caller-selected query id.
    queryId: uint64
}

/// Maintenance command that processes pending withdrawal requests up to a limit.
struct (0x00000002) NominatorPoolProcessWithdrawRequests {
    /// Caller-selected query id.
    queryId: uint64
    /// Maximum number of withdrawal requests to process.
    limit: uint8
    /// Remaining payload ignored by the Pool.
    tail: RemainingBitsAndRefs
}

/// Emergency command that processes a specific pending withdrawal request.
struct (0x00000003) NominatorPoolEmergencyProcessWithdrawRequest {
    /// Caller-selected query id.
    queryId: uint64
    /// Basechain wallet address hash with a pending withdrawal request.
    requestAddress: uint256
}

/// Validator command that adds validator-owned funds to the Pool.
struct (0x00000004) NominatorPoolValidatorDeposit {
    /// Caller-selected query id.
    queryId: uint64
}

/// Validator command that withdraws validator-owned funds.
struct (0x00000005) NominatorPoolValidatorWithdraw {
    /// Caller-selected query id.
    queryId: uint64
    /// Validator-owned amount requested for withdrawal.
    amount: coins
}

/// Maintenance command that refreshes the current validator-set hash.
struct (0x00000006) NominatorPoolUpdateValidatorSetHash {
    /// Caller-selected query id.
    queryId: uint64
}

/// Maintenance command that removes expired config-proposal voting records.
struct (0x00000007) NominatorPoolCleanupVotings {
    /// Caller-selected query id.
    queryId: uint64
}

/// Command that forwards a recover-stake request to the Elector.
struct (0x47657424) NominatorPoolRecoverStake {
    /// Caller-selected query id.
    queryId: uint64
}

/// Validator command that asks the Pool to send a new-stake request to the Elector.
struct (0x4e73744b) NominatorPoolNewStake {
    /// Caller-selected query id.
    queryId: uint64
    /// Stake value requested for the outgoing Elector message.
    stakeValue: coins
    /// Validator public key passed to the Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp.
    stakeAt: uint32
    /// Elector max-factor value.
    maxFactor: uint32
    /// Validator ADNL address.
    adnlAddr: bits256
    /// Referenced validator signature bits.
    signature: Cell<bits512>
}

/// New-stake request body emitted by the Pool to the Elector.
struct (0x4e73744b) NominatorPoolElectorNewStake {
    /// Query id copied from the validator command.
    queryId: uint64
    /// Validator public key passed to the Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp.
    stakeAt: uint32
    /// Elector max-factor value.
    maxFactor: uint32
    /// Validator ADNL address.
    adnlAddr: bits256
    /// Referenced validator signature bits.
    signature: Cell<bits512>
}

/// Elector response that returns stake after a failed new-stake request.
struct (0xee6f454c) NominatorPoolNewStakeError {
    /// Query id copied from the Pool's new-stake request.
    queryId: uint64
    /// Remaining Elector response payload.
    tail: RemainingBitsAndRefs
}

/// Elector response that confirms a new-stake request.
struct (0xf374484c) NominatorPoolNewStakeOk {
    /// Query id copied from the Pool's new-stake request.
    queryId: uint64
    /// Remaining Elector response payload ignored by the Pool.
    tail: RemainingBitsAndRefs
}

/// Elector response that returns stake after a recover-stake request.
struct (0xf96f7324) NominatorPoolRecoverStakeOk {
    /// Query id copied from the Pool's recover-stake request.
    queryId: uint64
}

/// Elector response for a failed recover-stake request.
struct (0xfffffffe) NominatorPoolRecoverStakeError {
    /// Query id copied from the Pool's recover-stake request.
    queryId: uint64
    /// Remaining Elector response payload.
    tail: RemainingBitsAndRefs
}

/// Empty body emitted for plain TON withdrawals and excess transfers.
struct NominatorPoolEmptyBody {}

/// Internal message bodies accepted by the Pool.
type NominatorPoolIncomingMessage =
    | NominatorPoolTextCommand
    | NominatorPoolAcceptCoins
    | NominatorPoolProcessWithdrawRequests
    | NominatorPoolEmergencyProcessWithdrawRequest
    | NominatorPoolValidatorDeposit
    | NominatorPoolValidatorWithdraw
    | NominatorPoolUpdateValidatorSetHash
    | NominatorPoolCleanupVotings
    | NominatorPoolRecoverStake
    | NominatorPoolNewStake
    | NominatorPoolNewStakeError
    | NominatorPoolNewStakeOk
    | NominatorPoolRecoverStakeOk
    | NominatorPoolRecoverStakeError

/// Internal message bodies emitted by the Pool.
type NominatorPoolOutgoingMessage =
    | NominatorPoolRecoverStake
    | NominatorPoolElectorNewStake

/// Structured result returned by `get_pool_data`.
struct NominatorPoolDataReply {
    /// Pool validation state.
    state: int
    /// Number of current nominator records.
    nominatorsCount: int
    /// Stake amount sent to the Elector for the current round.
    stakeAmountSent: int
    /// Validator-owned amount tracked by the Pool.
    validatorAmount: int
    /// Validator masterchain wallet address hash.
    validatorAddress: uint256
    /// Validator reward share over 10000.
    validatorRewardShare: int
    /// Maximum number of nominators accepted by the Pool.
    maxNominatorsCount: int
    /// Minimum validator-owned stake required by the Pool.
    minValidatorStake: int
    /// Minimum nominator stake required by the Pool.
    minNominatorStake: int
    /// Raw nominators dictionary returned by the getter.
    nominators: cell?
    /// Raw withdrawal-request dictionary returned by the getter.
    withdrawRequests: cell?
    /// Validation round start timestamp used for the active or pending stake.
    stakeAt: uint32
    /// Saved current validator-set hash.
    savedValidatorSetHash: uint256
    /// Number of observed validator-set hash changes.
    validatorSetChangesCount: int
    /// Unix timestamp for the last validator-set change tracked by the Pool.
    validatorSetChangeTime: uint32
    /// Stake hold period saved from network config.
    stakeHeldFor: uint32
    /// Raw config-proposal voting dictionary returned by the getter.
    configProposalVotings: cell?
}

/// Entry returned by `list_nominators`.
struct NominatorPoolListNominatorsEntry {
    /// Basechain nominator wallet address hash.
    address: uint256
    /// Active nominator stake.
    amount: int
    /// Deposit amount queued for the next validation round.
    pendingDepositAmount: int
    /// True when a withdrawal request exists for this nominator.
    withdrawRequested: bool
}

/// Result returned by `get_nominator_data`.
struct NominatorPoolNominatorDataReply {
    /// Active nominator stake.
    amount: int
    /// Deposit amount queued for the next validation round.
    pendingDepositAmount: int
    /// True when a withdrawal request exists for this nominator.
    withdrawRequested: bool
}

/// Entry returned by `list_votes`.
struct NominatorPoolListVotesEntry {
    /// Config proposal hash.
    proposalHash: uint256
    /// Unix timestamp when this proposal voting was created.
    voteCreateTime: uint32
}

/// Entry returned by `list_voters`.
struct NominatorPoolListVotersEntry {
    /// Validator or basechain nominator wallet address hash.
    address: uint256
    /// Vote value where -1 means support and 0 means against.
    support: int
    /// Unix timestamp when this voter record was created.
    voteTime: uint32
}

/// Nominator Pool exit-code catalog.
enum NominatorPoolErrors {
    /// Current validator-set config is not encoded as `validators_ext`.
    InvalidValidatorSetConfig = 9
    /// Nominator record is missing for withdrawal.
    NominatorMissingForWithdrawal = 60
    /// Nominator operation sender is not in the basechain.
    NominatorWrongWorkchain = 61
    /// Validator wallet cannot use nominator deposit or withdrawal flow.
    ValidatorAsNominator = 62
    /// Text-comment command action is not supported.
    UnsupportedTextAction = 64
    /// Nominator count exceeds the configured maximum.
    MaxNominatorsExceeded = 65
    /// Deposit value after processing fee is zero.
    DepositValueTooLow = 66
    /// Nominator stake is below the configured minimum.
    NominatorStakeTooLow = 67
    /// Nominator dictionary depth exceeds the source guard.
    NominatorDictTooDeep = 68
    /// Withdrawal request sender is not a nominator.
    WithdrawSenderNotNominator = 69
    /// Nonzero message opcode is not supported.
    UnsupportedOpcode = 70
    /// Emergency withdrawal request address is not pending.
    EmergencyWithdrawRequestMissing = 71
    /// Validator deposit sender is not the validator masterchain wallet.
    ValidatorDepositWrongSender = 73
    /// Validator deposit or withdrawal state/value precondition failed.
    ValidatorDepositWithdrawPrecondition = 74
    /// Validator withdrawal sender is not the validator masterchain wallet.
    ValidatorWithdrawWrongSender = 75
    /// Validator withdrawal amount exceeds available validator-owned balance.
    ValidatorWithdrawTooHigh = 76
    /// Validator withdrawal or new-stake parameter precondition failed.
    ValidatorRequestInvalid = 78
    /// New-stake request was sent while the Pool is not idle.
    NewStakeWrongState = 79
    /// New-stake query id is zero.
    NewStakeZeroQuery = 80
    /// New-stake value is below the minimum stake to send.
    NewStakeTooLow = 81
    /// New-stake value exceeds spendable Pool balance.
    NewStakeTooHigh = 82
    /// Validator-owned amount is below the configured validator minimum.
    ValidatorStakeTooLow = 83
    /// Validator-owned amount is below the recommended punishment reserve.
    ValidatorReserveTooLow = 84
    /// Withdrawal requests exist when new-stake is requested.
    WithdrawRequestsExist = 85
    /// Nominator lookup or new-stake fee precondition failed.
    NominatorLookupOrNewStakeFeeFailed = 86
    /// Recover-stake was requested before two validator-set changes.
    RecoverStakeTooFewSetChanges = 111
    /// Recover-stake was requested before the hold-period condition matured.
    RecoverStakeTooEarly = 112
    /// Validator-set hash update was requested after the change-count limit.
    ValidatorSetChangesLimit = 113
    /// Vote sender is not a basechain nominator or validator wallet.
    VoteWrongWorkchain = 121
    /// Vote sender is not an authorized nominator.
    VoteSenderNotAuthorized = 122
    /// Vote sender has no active stake or did not attach the required fee.
    VoteStakeOrFeeInvalid = 123
    /// Sender already voted for this proposal.
    VoteAlreadyExists = 124
    /// Voter-list proposal hash was not found.
    VoteProposalMissing = 133
    /// Vote text payload contains an invalid hex symbol.
    InvalidVoteHexSymbol = 329
}

/// Return complete Pool data.
get fun get_pool_data(): NominatorPoolDataReply {
    throw 0;
}

/// Return whether the Pool has pending withdrawal requests.
get fun has_withdraw_requests(): bool {
    throw 0;
}

/// Return nominator accounting for a basechain wallet address hash.
get fun get_nominator_data(nominatorAddress: uint256): NominatorPoolNominatorDataReply {
    throw 0;
}

/// Return the maximum recommended punishment for the supplied stake.
get fun get_max_punishment(stake: int): int {
    throw 0;
}

/// Return the list of current nominator records.
get fun list_nominators(): lisp_list<NominatorPoolListNominatorsEntry> {
    throw 0;
}

/// Return the list of config-proposal voting records.
get fun list_votes(): lisp_list<NominatorPoolListVotesEntry> {
    throw 0;
}

/// Return the voters for a config proposal hash.
get fun list_voters(proposalHash: uint256): lisp_list<NominatorPoolListVotersEntry> {
    throw 0;
}

fun emptyNominatorPoolDataReply(): NominatorPoolDataReply {
    return {
        state: 0,
        nominatorsCount: 0,
        stakeAmountSent: 0,
        validatorAmount: 0,
        validatorAddress: 0,
        validatorRewardShare: 0,
        maxNominatorsCount: 0,
        minValidatorStake: 0,
        minNominatorStake: 0,
        nominators: null,
        withdrawRequests: null,
        stakeAt: 0,
        savedValidatorSetHash: 0,
        validatorSetChangesCount: 0,
        validatorSetChangeTime: 0,
        stakeHeldFor: 0,
        configProposalVotings: null,
    };
}

fun assertNominatorPoolKnownErrors(): void {}
