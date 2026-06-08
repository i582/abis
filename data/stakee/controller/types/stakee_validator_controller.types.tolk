/// Stakee Validator Controller interface for validator-round funding, loan, Elector, and governance flows.
contract StakeeValidatorController {
    author: "Stakee"
    version: "1.0"
    description: "Stakee Validator Controller for storage, controller commands, Pool and Elector messages, getters, and exit codes."
    storage: StakeeValidatorControllerStorage
    incomingMessages: StakeeValidatorControllerIncomingMessage
    outgoingMessages: StakeeValidatorControllerOutgoingMessage
    forceAbiExport: StakeeValidatorControllerEmptyBody
        | StakeeValidatorControllerBouncedKnownBody
    thrownErrors: StakeeValidatorControllerErrors
}

/// Shared static role cell referenced from the controller static-data cell.
struct StakeeValidatorControllerRoles {
    /// Address authorized to approve or disapprove this controller.
    approver: address
    /// Address authorized to halt this controller.
    halter: address
}

/// Static controller identity copied into outgoing pool loan requests.
struct StakeeValidatorControllerStaticData {
    /// Pool-assigned controller id stored as uint32 in the static-data ref.
    controllerId: uint32
    /// Validator wallet address authorized for staking, hash updates, withdrawals, and loan requests.
    validator: address
    /// Stakee pool address authorized for credits and loan-repayment bounces.
    pool: address
    /// Governor address authorized for sudoer/unhalt/return-available-funds requests.
    governor: address
    /// Referenced approver/halter role addresses.
    roles: Cell<StakeeValidatorControllerRoles>
}

/// Runtime controller state stored in the root data cell by `save_data`.
@overflow1023_policy("suppress")
struct StakeeValidatorControllerStorage {
    /// Controller state: 0 REST, 1 SENT_BORROWING_REQUEST, 2 SENT_STAKE_REQUEST, 3 FUNDS_STAKEN, 4 SENT_RECOVER_REQUEST, 5 INSOLVENT.
    state: uint8
    /// Halt flag for safety and governance paths.
    halted: bool
    /// Whether the approver has approved loan requests for this controller.
    approved: bool
    /// Stake amount sent to Elector after subtracting the controller operation fee.
    stakeAmountSent: coins
    /// Election round timestamp accepted by Elector for the current/last stake.
    stakeAt: uint48
    /// Validator-set cell hash saved when staking or updating validator-set state.
    savedValidatorSetHash: uint256
    /// Count of validator-set changes observed after the stake request.
    validatorSetChangesCount: uint8
    /// Unix timestamp of the last saved validator-set change.
    validatorSetChangeTime: uint48
    /// Stake hold duration from validator config, stored as a timestamp-width integer.
    stakeHeldFor: uint48
    /// Borrowed amount including interest owed to the Stakee pool.
    borrowedAmount: coins
    /// Unix timestamp when the current loan was first borrowed.
    borrowingTime: uint48
    /// Optional sudoer address; live mainnet storage can contain `addr_none`.
    sudoer: address?
    /// Unix timestamp when `sudoer` was set.
    sudoerSetAt: uint48
    /// Maximum expected interest share encoded as 24 bits.
    maxExpectedInterest: uint24
    /// Referenced static controller identity and role data.
    staticData: Cell<StakeeValidatorControllerStaticData>
}

/// Controller top-up command with attached value and op/query header.
struct (0xd372158c) StakeeValidatorControllerTopUp {
    /// Caller-selected query id parsed by the common body header.
    queryId: uint64
}

/// Pool-originated loan credit notification.
struct (0x1690c604) StakeeValidatorControllerCredit {
    /// Pool query id copied from the loan request/credit flow.
    queryId: uint64
    /// Borrowed amount including interest, parsed as TL-B Coins.
    creditAmount: coins
}

/// Approver-originated command that marks this controller approved.
struct (0x7b4b42e6) StakeeValidatorControllerApprove {
    /// Approver query id parsed by the common body header.
    queryId: uint64
}

/// Approver-originated command that clears controller approval.
struct (0xe8a0abfe) StakeeValidatorControllerDisapprove {
    /// Approver query id parsed by the common body header.
    queryId: uint64
}

/// Sudoer raw-message relay with message cell followed by send mode.
struct (0x270695fb) StakeeValidatorControllerSudoSendMessage {
    /// Sudoer query id parsed by the common body header.
    queryId: uint64
    /// Raw full message cell passed to `send_raw_message`.
    message: cell
    /// TVM send mode loaded after the message ref.
    mode: uint8
}

/// Governor command that replaces the quarantined sudoer address.
struct (0x79e7c016) StakeeValidatorControllerSetSudoer {
    /// Governor query id parsed by the common body header.
    queryId: uint64
    /// New sudoer message address, including `addr_none`.
    sudoer: address?
}

/// Governor command that clears the halted flag.
struct (0x7247e7a5) StakeeValidatorControllerUnhalt {
    /// Governor query id parsed by the common body header.
    queryId: uint64
}

/// Governor command that repays available insolvent funds to the pool.
struct (0x55c26cd5) StakeeValidatorControllerReturnAvailableFunds {
    /// Query id copied into the outgoing pool loan-repayment body.
    queryId: uint64
}

/// Halter command that sets the halted flag through the shared halter request.
struct (0x139a1b4e) StakeeValidatorControllerHalt {
    /// Halter query id parsed by the common body header.
    queryId: uint64
}

/// Validator command that asks Elector to recover stake.
struct (0xeb373a05) StakeeValidatorControllerRecoverStake {
    /// Query id copied into the outgoing Elector `recover_stake` body.
    queryId: uint64
}

/// Validator command that refreshes the saved validator-set hash after staking.
struct (0xf0fd2250) StakeeValidatorControllerUpdateValidatorHash {
    /// Validator query id parsed by the common body header.
    queryId: uint64
}

/// Validator command that withdraws TON from the controller wallet back to validator.
struct (0x8efed779) StakeeValidatorControllerWithdrawValidator {
    /// Query id copied into the outgoing validator withdrawal notification.
    queryId: uint64
    /// Requested withdrawal amount; the outgoing body does not repeat this field.
    requestAmount: coins
}

/// Controller-specific validator stake command; unlike Elector body it includes `stakeValue` before the Elector payload.
struct (0x4e73744b) StakeeValidatorControllerNewStake {
    /// Non-zero query id copied into the outgoing Elector `new_stake` body and Elector response.
    queryId: uint64
    /// TON amount sent to Elector as the message value.
    stakeValue: coins
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Election round timestamp forwarded to Elector.
    stakeAt: uint32
    /// Validator max-factor forwarded to Elector.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Validator command that asks the pool for a loan during the request window.
struct (0x6335b11a) StakeeValidatorControllerSendRequestLoan {
    /// Query id copied into the outgoing pool `request_loan` body.
    queryId: uint64
    /// Minimum acceptable loan amount.
    minLoan: coins
    /// Maximum requested loan amount.
    maxLoan: coins
    /// Maximum accepted interest share encoded as 24 bits.
    maxInterest: uint24
}

/// Validator command that repays an unused loan after the next round starts.
struct (0xed7378a6) StakeeValidatorControllerReturnUnusedLoan {
    /// Query id copied into the outgoing pool loan-repayment body.
    queryId: uint64
}

/// Elector success response for `new_stake`.
struct (0xf374484c) StakeeValidatorControllerNewStakeOk {
    /// Query id copied from the Elector request.
    queryId: uint64
    /// Elector comment field present in standard `new_stake_ok` bodies.
    comment: uint32
}

/// Elector failure response for `new_stake` with remaining error tail.
struct (0xee6f454c) StakeeValidatorControllerNewStakeError {
    /// Query id copied from the Elector request.
    queryId: uint64
    /// Remaining Elector error tail or bounce-derived data.
    tail: RemainingBitsAndRefs
}

/// Elector success response for `recover_stake`.
struct (0xf96f7324) StakeeValidatorControllerRecoverStakeOk {
    /// Query id copied from the Elector request.
    queryId: uint64
}

/// Elector failure response for `recover_stake` with remaining error tail.
struct (0xfffffffe) StakeeValidatorControllerRecoverStakeError {
    /// Query id copied from the Elector request when present.
    queryId: uint64
    /// Remaining Elector error tail or bounce-derived data.
    tail: RemainingBitsAndRefs
}

/// Pool loan request emitted by controller after validating the request window and solvency.
struct (0xe642c965) StakeeValidatorControllerPoolRequestLoan {
    /// Query id copied from the validator request.
    queryId: uint64
    /// Minimum acceptable loan amount copied from the validator request.
    minLoan: coins
    /// Maximum requested loan amount copied from the validator request.
    maxLoan: coins
    /// Maximum accepted interest share copied as uint24.
    maxInterest: uint24
    /// Static controller identity and role data forwarded to the pool as a ref.
    controllerData: Cell<StakeeValidatorControllerStaticData>
}

/// Pool loan repayment body emitted after stake recovery or unused-loan return.
struct (0xdfdca27b) StakeeValidatorControllerPoolLoanRepayment {
    /// Query id copied from the triggering controller or Elector response.
    queryId: uint64
}

/// Elector `new_stake` body emitted by the controller, without the controller-only `stakeValue` field.
struct (0x4e73744b) StakeeValidatorControllerElectorNewStake {
    /// Query id copied from the validator command.
    queryId: uint64
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Election round timestamp forwarded to Elector.
    stakeAt: uint32
    /// Validator max-factor forwarded to Elector.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Elector `recover_stake` body emitted by the controller.
struct (0x47657424) StakeeValidatorControllerElectorRecoverStake {
    /// Query id copied from the validator command.
    queryId: uint64
}

/// Validator notification body emitted after a successful withdrawal request.
struct (0x30026327) StakeeValidatorControllerValidatorWithdrawal {
    /// Query id copied from `withdraw_validator`; withdrawal amount is the TON message value.
    queryId: uint64
}

/// Empty body emitted for value-only excess or bounty transfers.
struct StakeeValidatorControllerEmptyBody {}

/// Protocol bounce body observed from failed controller requests.
struct (0xffffffff) StakeeValidatorControllerBouncedKnownBody {
    /// Original bounced opcode after the TVM bounce prefix.
    originalOpcode: uint32
    /// Original query id when the bounced body used the standard op/query header.
    queryId: uint64
    /// Remaining bounced payload, if any, after the common header.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the controller dispatcher or Elector response branch.
type StakeeValidatorControllerIncomingMessage =
    | StakeeValidatorControllerTopUp
    | StakeeValidatorControllerCredit
    | StakeeValidatorControllerApprove
    | StakeeValidatorControllerDisapprove
    | StakeeValidatorControllerSudoSendMessage
    | StakeeValidatorControllerSetSudoer
    | StakeeValidatorControllerUnhalt
    | StakeeValidatorControllerReturnAvailableFunds
    | StakeeValidatorControllerHalt
    | StakeeValidatorControllerRecoverStake
    | StakeeValidatorControllerUpdateValidatorHash
    | StakeeValidatorControllerWithdrawValidator
    | StakeeValidatorControllerNewStake
    | StakeeValidatorControllerSendRequestLoan
    | StakeeValidatorControllerReturnUnusedLoan
    | StakeeValidatorControllerNewStakeOk
    | StakeeValidatorControllerNewStakeError
    | StakeeValidatorControllerRecoverStakeOk
    | StakeeValidatorControllerRecoverStakeError

/// Internal message bodies emitted by explicit controller send-sites.
type StakeeValidatorControllerOutgoingMessage =
    | StakeeValidatorControllerPoolRequestLoan
    | StakeeValidatorControllerPoolLoanRepayment
    | StakeeValidatorControllerElectorNewStake
    | StakeeValidatorControllerElectorRecoverStake
    | StakeeValidatorControllerValidatorWithdrawal

/// Structured result returned by `get_validator_controller_data`.
struct StakeeValidatorControllerDataReply {
    /// Current state code returned from storage.
    state: uint8
    /// Halt flag returned as TVM bool.
    halted: bool
    /// Approval flag returned as TVM bool.
    approved: bool
    /// Stored stake amount sent to Elector.
    stakeAmountSent: coins
    /// Stored stake timestamp.
    stakeAt: uint48
    /// Stored validator-set hash.
    savedValidatorSetHash: uint256
    /// Stored validator-set change counter.
    validatorSetChangesCount: uint8
    /// Stored validator-set change timestamp.
    validatorSetChangeTime: uint48
    /// Stored stake hold duration.
    stakeHeldFor: uint48
    /// Stored borrowed amount including interest.
    borrowedAmount: coins
    /// Stored borrowing timestamp.
    borrowingTime: uint48
    /// Validator stack address; getter returns a raw MsgAddress.
    validator: any_address
    /// Pool stack address; getter returns a raw MsgAddress.
    pool: any_address
    /// Sudoer stack address, possibly `addr_none`.
    sudoer: any_address
}

/// Structured result returned by `required_balance_for_loan`.
struct StakeeValidatorControllerRequiredBalanceForLoanReply {
    /// Required validator balance to safely request a loan.
    requiredBalance: int
    /// Current validator-owned amount after subtracting outstanding borrowed amount.
    validatorAmount: int
}

/// Structured result returned by `request_window_time`.
struct StakeeValidatorControllerRequestWindowTimeReply {
    /// Earliest Unix timestamp at which loan requests are accepted.
    since: uint32
    /// Latest Unix timestamp before loan requests close.
    until: uint32
}

/// Controller exit-code catalog.
enum StakeeValidatorControllerErrors {
    /// Message opcode is unsupported in the active dispatcher branch.
    UnknownOp = 0xffff
    /// Sender does not match the role required by the operation.
    WrongSender = 0x9283
    /// Operation is not valid in the current controller state.
    WrongState = 0x9284
    /// Operation is blocked while the controller is halted.
    Halted = 0x9285
    /// Sudoer change is attempted before the quarantine period matures.
    SudoerQuarantine = 0xa000
    /// Stake recovery was requested before enough validator-set changes were observed.
    TooEarlyStakeRecoverAttemptCount = 0xf600
    /// Stake recovery was requested before the unfreeze timing condition was met.
    TooEarlyStakeRecoverAttemptTime = 0xf601
    /// Attached TON is below the Elector recover-stake operation value.
    TooLowRecoverStakeValue = 0xf602
    /// Attached TON is below the minimum request-loan operation value.
    TooLowRequestLoanValue = 0xf604
    /// Validator-set change counter would exceed the accepted bound.
    TooMuchValidatorSetCounts = 0xf700
    /// Validator-set hash update did not find a new hash.
    NoNewHash = 0xf701
    /// Validator withdrawal is attempted while borrowed funds are outstanding.
    WithdrawalWhileCredited = 0xf800
    /// Validator withdrawal requested a non-positive amount.
    IncorrectWithdrawalAmount = 0xf801
    /// New-stake query id is zero, so Elector confirmation could not be correlated.
    IncorrectNewStakeQueryId = 0xf900
    /// Attached TON is below the controller new-stake operation fee.
    IncorrectNewStakeRequestValue = 0xf901
    /// New-stake value is below the minimum stake.
    IncorrectNewStakeValueLtMinimum = 0xf902
    /// New-stake value would leave too little controller balance for reserves and fines.
    IncorrectNewStakeValueTooHigh = 0xf903
    /// Borrowed funds are used outside the round in which they were obtained.
    IncorrectNewStakeWronglyUsedCredit = 0xf904
    /// New-stake would not leave enough validator-owned funds to guarantee solvency.
    IncorrectNewStakeSolvencyNotGuaranteed = 0xf905
    /// Loan request is attempted before the controller is approved.
    ControllerNotApproved = 0xfa00
    /// Loan request is attempted while another loan is outstanding.
    MultipleLoansAreProhibited = 0xfa01
    /// Loan request is attempted before the election request window opens.
    TooEarlyLoanRequest = 0xfa02
    /// Loan request is attempted after the election request window closes.
    TooLateLoanRequest = 0xfa03
    /// Requested loan amount is above the safe solvency bound.
    TooHighLoanRequestAmount = 0xfa04
    /// Pool credit amount exceeds the configured maximum expected interest.
    CreditInterestTooHigh = 0xfa05
    /// Unused-loan return is attempted when no credit is outstanding.
    NoCredit = 0xfb00
    /// Unused-loan return is attempted before the next round starts.
    TooEarlyLoanReturn = 0xfb01
}

/// Return the controller runtime state and selected static addresses.
get fun get_validator_controller_data(): StakeeValidatorControllerDataReply {
    throw 0;
}

/// Return the maximum recommended punishment for a validator stake value.
get fun get_max_punishment(stake: int): coins {
    throw 0;
}

/// Return the maximum stake value the controller can send, or `-1` when staking is unavailable.
get fun get_max_stake_value(): int {
    throw 0;
}

/// Return required balance and validator-owned amount for a candidate loan.
get fun required_balance_for_loan(
    credit: coins,
    interest: uint24,
): StakeeValidatorControllerRequiredBalanceForLoanReply {
    throw 0;
}

/// Return the current election-round loan request window.
get fun request_window_time(): StakeeValidatorControllerRequestWindowTimeReply {
    throw 0;
}
