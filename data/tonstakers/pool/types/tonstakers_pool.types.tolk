/// Tonstakers liquid-staking Pool contract that accepts TON deposits, burns tsTON withdrawals, and lends TON to validator controllers.
contract TonstakersPool {
    author: "Tonstakers"
    version: "1.0"
    description: "Tonstakers Pool for liquid-staking deposits, tsTON withdrawals, validator-controller loans, governance, storage, and getters."
    storage: TonstakersPoolStorage
    incomingMessages: TonstakersPoolIncomingMessage
    outgoingMessages: TonstakersPoolOutgoingMessage
    forceAbiExport: TonstakersPoolEventMessage | TonstakersPoolPayoutData | TonstakersPoolPayoutInitData
}

/// Signed coin value encoded by Tonstakers as `Coins` magnitude followed by a one-bit sign.
struct TonstakersPoolSignedCoins {
    /// Absolute nanotons value.
    amount: coins
    /// True when the signed value is negative.
    negative: bool
}

/// Pending payout request stored inline or by reference in Pool minter data.
struct TonstakersPoolPayoutData {
    /// Deposit or withdrawal payout minter address.
    payoutAddress: address
    /// Amount requested for this payout minter, in nanotons or tsTON base units depending on context.
    requestedAmount: coins
}

/// No pending payout request is stored.
struct (0b0) TonstakersPoolPayoutAbsent {
}

/// Pending payout request stored inline in the minter-data cell.
struct (0b10) TonstakersPoolPayoutInline {
    /// Deposit or withdrawal payout minter address.
    payoutAddress: address
    /// Amount requested for this payout minter.
    requestedAmount: coins
}

/// Pending payout request stored in a referenced cell.
struct (0b11) TonstakersPoolPayoutRef {
    /// Referenced pending payout request.
    payout: Cell<TonstakersPoolPayoutData>
}

/// Optional payout request layout used by `load_maybe_minter`.
type TonstakersPoolMaybePayout =
    | TonstakersPoolPayoutAbsent
    | TonstakersPoolPayoutInline
    | TonstakersPoolPayoutRef

/// Jetton minter and pending deposit/withdrawal payout accounting referenced from root storage.
@overflow1023_policy("suppress")
struct TonstakersPoolMintersData {
    /// tsTON jetton minter address.
    jettonMinter: address
    /// Total tsTON supply tracked by the Pool.
    supply: coins
    /// Optional deposit payout minter and requested TON amount.
    depositPayout: TonstakersPoolMaybePayout
    /// Optional withdrawal payout minter and requested tsTON amount.
    withdrawalPayout: TonstakersPoolMaybePayout
}

/// Per-controller loan amounts stored in the round borrower dictionary.
struct TonstakersPoolLoanData {
    /// Principal borrowed by this validator controller.
    borrowedAmount: coins
    /// Accounted interest owed by this validator controller.
    accountedInterest: coins
}

/// Loan round aggregate and borrower dictionary.
struct TonstakersPoolRoundData {
    /// Borrower records keyed by validator controller address hash.
    borrowersDict: map<uint256, TonstakersPoolLoanData>
    /// Sequential lending round id.
    roundId: uint32
    /// Number of active borrowers in this round.
    activeBorrowers: uint32
    /// Total principal borrowed in this round.
    borrowed: coins
    /// Total expected repayment including interest.
    expected: coins
    /// Total amount returned so far.
    returned: coins
    /// Signed round profit encoded as magnitude plus sign bit in storage.
    profit: TonstakersPoolSignedCoins
}

/// Referenced pair of current and previous round records.
struct TonstakersPoolRoundsData {
    /// Current lending round data, stored first in the referenced rounds cell.
    currentRoundBorrowers: Cell<TonstakersPoolRoundData>
    /// Previous lending round data, stored second in the referenced rounds cell.
    prevRoundBorrowers: Cell<TonstakersPoolRoundData>
}

/// Role addresses stored in the second roles reference.
struct TonstakersPoolRoleTail {
    /// Address authorized to halt the Pool, or `addr_none` before configuration.
    halter: address?
    /// Address authorized to approve validator controllers, or `addr_none` before configuration.
    approver: address?
}

/// Governance, sudo, interest-manager, halter, and approver roles.
struct TonstakersPoolRoles {
    /// Sudoer address authorized for raw messages and upgrades, or `addr_none` before configuration.
    sudoer: address?
    /// Unix timestamp when the current sudoer was set.
    sudoerSetAt: uint48
    /// Governor address authorized for governance settings, or `addr_none` before configuration.
    governor: address?
    /// Unix timestamp after which a prepared governor update may mature.
    governorUpdateAfter: uint48
    /// Interest-manager address authorized to update interest rate, or `addr_none` before configuration.
    interestManager: address?
    /// Referenced halter and approver addresses.
    tail: Cell<TonstakersPoolRoleTail>
}

/// Code cells used to derive controllers, pool jetton wallets, and payout minters.
struct TonstakersPoolCodes {
    /// Validator controller code.
    controllerCode: cell
    /// Pool tsTON wallet code.
    poolJettonWalletCode: cell
    /// Payout minter code.
    payoutMinterCode: cell
}

/// Persistent Pool state stored in the root data cell.
struct TonstakersPoolStorage {
    /// Pool state enum value.
    state: uint8
    /// True when privileged halt logic prevents normal operation.
    halted: bool
    /// Total TON balance tracked by the Pool, in nanotons.
    totalBalance: coins
    /// Referenced jetton minter and pending payout accounting.
    mintersData: Cell<TonstakersPoolMintersData>
    /// Per-round interest rate share encoded as 24 bits.
    interestRate: uint24
    /// True when deposits and withdrawals use projected-ratio optimistic paths.
    optimisticDepositWithdrawals: bool
    /// True when user deposits are accepted.
    depositsOpen: bool
    /// Saved validator-set hash used by round-rotation logic.
    savedValidatorSetHash: uint256
    /// Referenced current and previous round data.
    rounds: Cell<TonstakersPoolRoundsData>
    /// Minimum loan per validator, in nanotons.
    minLoanPerValidator: coins
    /// Maximum loan per validator, in nanotons.
    maxLoanPerValidator: coins
    /// Governance fee share encoded as 24 bits.
    governanceFee: uint24
    /// Referenced governance and operational roles.
    roles: Cell<TonstakersPoolRoles>
    /// Referenced code cells used for deterministic child-contract addresses.
    codes: Cell<TonstakersPoolCodes>
}

/// Optional role update marker used by `governor::set_roles`.
struct (0b0) TonstakersPoolRoleUnchanged {
}

/// Present role update with the replacement address.
struct (0b1) TonstakersPoolRoleUpdated {
    /// Replacement role address.
    value: address
}

/// Optional role update field used four times by `governor::set_roles`.
type TonstakersPoolMaybeRoleAddress =
    | TonstakersPoolRoleUnchanged
    | TonstakersPoolRoleUpdated

/// Role tail embedded in validator controller static data.
struct TonstakersPoolControllerRoles {
    /// Approver address stored in controller StateInit.
    approver: address
    /// Halter address stored in controller StateInit.
    halter: address
}

/// Static validator controller data referenced by `pool::request_loan`.
struct TonstakersPoolControllerData {
    /// Controller id used in deterministic controller address derivation.
    controllerId: uint32
    /// Validator wallet address controlled by the derived controller.
    validator: address
    /// Pool address stored in controller data.
    pool: address
    /// Governor address stored in controller data.
    governor: address
    /// Referenced approver and halter addresses stored in controller data.
    roles: Cell<TonstakersPoolControllerRoles>
}

/// User TON deposit request with query id and Tonstakers partner code.
struct (0x47d54391) TonstakersPoolDeposit {
    /// User-selected query id copied into mint/payout messages.
    queryId: uint64
    /// Tonstakers partner code field.
    partnerCode: uint64
}

/// Burn notification from the tsTON minter for a Pool withdrawal request.
struct (0x319b0cdc) TonstakersPoolWithdraw {
    /// Query id copied to the direct withdrawal or payout mint path.
    queryId: uint64
    /// Burned tsTON amount.
    jettonAmount: coins
    /// Owner address that should receive TON or withdrawal payout tokens.
    fromAddress: address
    /// Response address parsed by the Pool and intentionally ignored.
    responseAddress: address
    /// True when the user waits for round-end payout instead of requesting immediate optimistic withdrawal.
    waitTillRoundEnd: bool
    /// True when the request must fail instead of minting a withdrawal payout token.
    fillOrKill: bool
}

/// Validator controller loan request.
struct (0xe642c965) TonstakersPoolRequestLoan {
    /// Controller query id copied into the credit message and notification paths.
    queryId: uint64
    /// Controller-requested minimum loan.
    minLoan: coins
    /// Controller-requested maximum loan.
    maxLoan: coins
    /// Maximum accepted interest share, encoded as 24 bits.
    maxInterest: uint24
    /// Referenced controller static data used to derive and authenticate the sender.
    controllerData: Cell<TonstakersPoolControllerData>
}

/// Loan repayment message accepted from validator controllers; attached value carries the repayment.
struct (0xdfdca27b) TonstakersPoolLoanRepayment {
    /// Query id from the controller repayment message.
    queryId: uint64
}

/// Maintenance no-op that refreshes round accounting.
struct (0x4bc7c2df) TonstakersPoolTouch {
    /// Query id parsed by the common body header.
    queryId: uint64
}

/// Value donation that increases Pool accounting and returns jetton excesses.
struct (0x73affe21) TonstakersPoolDonate {
    /// Query id copied into the jetton excesses response.
    queryId: uint64
}

/// Governance command that deploys or tops up a validator controller.
struct (0xb27edcad) TonstakersPoolDeployController {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// Controller id used to derive the child controller address.
    controllerId: uint32
}

/// Halter command that marks the Pool halted.
struct (0x139a1b4e) TonstakersPoolHalt {
    /// Query id parsed by the common body header.
    queryId: uint64
}

/// Sudo command that sends an arbitrary raw internal message.
struct (0x270695fb) TonstakersPoolSudoSendMessage {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// Raw send mode used by the privileged branch.
    mode: uint8
    /// Raw message cell sent by the Pool.
    message: cell
}

/// Sudo command that upgrades code/data and optionally executes a post-upgrade body.
struct (0x96e7f528) TonstakersPoolSudoUpgrade {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// Optional replacement data cell.
    data: cell?
    /// Optional replacement code cell.
    code: cell?
    /// Optional post-upgrade continuation body.
    afterUpgrade: cell?
}

/// Governor command that replaces the sudoer address.
struct (0x79e7c016) TonstakersPoolSetSudoer {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// New sudoer address.
    sudoer: address
}

/// Governor command that clears the halted flag.
struct (0x7247e7a5) TonstakersPoolUnhalt {
    /// Query id parsed by the common body header.
    queryId: uint64
}

/// Governor command that prepares a governance migration timestamp.
struct (0x9971881c) TonstakersPoolPrepareGovernanceMigration {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// Timestamp after which governance migration can mature.
    governorUpdateAfter: uint48
}

/// Governor command that optionally replaces governor, interest-manager, halter, and approver roles.
@overflow1023_policy("suppress")
struct (0x5e517f36) TonstakersPoolSetRoles {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// Optional governor replacement.
    governor: TonstakersPoolMaybeRoleAddress
    /// Optional interest-manager replacement.
    interestManager: TonstakersPoolMaybeRoleAddress
    /// Optional halter replacement.
    halter: TonstakersPoolMaybeRoleAddress
    /// Optional approver replacement.
    approver: TonstakersPoolMaybeRoleAddress
}

/// Governor command that changes optimistic withdrawal and deposit-open settings.
struct (0x9bf5561c) TonstakersPoolSetDepositSettings {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// New optimistic deposit/withdrawal flag.
    optimisticDepositWithdrawals: bool
    /// New deposit-open flag.
    depositsOpen: bool
}

/// Governor command that changes protocol governance fee share.
struct (0x2aaa96a0) TonstakersPoolSetGovernanceFee {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// New governance fee share encoded as 24 bits.
    governanceFee: uint24
}

/// Governor command that attempts to return available funds during maintenance.
struct (0x55c26cd5) TonstakersPoolReturnAvailableFunds {
    /// Query id parsed by the common body header.
    queryId: uint64
}

/// Interest-manager command that changes the Pool interest rate.
struct (0xc9f04485) TonstakersPoolSetInterest {
    /// Query id parsed by the common body header.
    queryId: uint64
    /// New interest share encoded as 24 bits.
    interestRate: uint24
}

/// Direct TON withdrawal body sent to the withdrawing user when optimistic withdrawal succeeds.
struct (0x0a77535c) TonstakersPoolWithdrawal {
    /// Query id copied from the incoming withdrawal request.
    queryId: uint64
}

/// Payout minter command that mints tsTON or withdrawal-payout tokens.
struct (0x1674b0a0) TonstakersPayoutMint {
    /// Query id copied from the originating request.
    queryId: uint64
    /// Destination owner that receives minted tokens.
    destination: address
    /// Token amount to mint.
    amount: coins
    /// Nanotons attached to the owner transfer notification.
    notificationTon: coins
    /// Nanotons forwarded with the minted transfer payload.
    forwardTon: coins
}

/// Validator controller credit body emitted when a loan is approved.
struct (0x1690c604) TonstakersControllerCredit {
    /// Query id copied from `pool::request_loan`.
    queryId: uint64
    /// Amount the controller is expected to repay, including interest.
    repaymentAmount: coins
}

/// Validator controller top-up body emitted during controller deployment.
struct (0xd372158c) TonstakersControllerTopUp {
    /// Query id emitted as current logical time by the Pool branch.
    queryId: uint64
}

/// Standard jetton excesses body emitted after donations.
struct (0xd53276db) TonstakersJettonExcesses {
    /// Query id copied from `pool::donate`.
    queryId: uint64
}

/// Payout minter initialization data stored in a referenced body.
struct TonstakersPoolPayoutInitData {
    /// True once payout distribution has started.
    distributionStarted: bool
    /// True for pool-jetton payout minters and false for TON withdrawal payout minters.
    jettonPayout: bool
    /// Amount already distributed by the payout minter.
    distributedAmount: coins
    /// Optional tail; deposit payout minters additionally store the deposit minter's jetton wallet address.
    tail: RemainingBitsAndRefs
}

/// Payout minter initialization message.
struct (0xf5aa8943) TonstakersPayoutInit {
    /// Query id emitted as current logical time by the Pool branch.
    queryId: uint64
    /// Referenced payout-minter initialization data.
    initData: Cell<TonstakersPoolPayoutInitData>
}

/// Payout minter command that starts TON distribution for a withdrawal payout round.
struct (0x1140a64f) TonstakersPayoutsStartDistribution {
    /// Query id emitted as current logical time by the Pool branch.
    queryId: uint64
}

/// Interest-manager notification requested after a successful loan.
struct (0xb1ebae06) TonstakersInterestManagerRequestNotification {
    /// Query id emitted as current logical time by the Pool branch.
    queryId: uint64
    /// Effective minimum loan after Pool storage limits.
    minLoan: coins
    /// Effective maximum loan after Pool storage limits.
    maxLoan: coins
    /// Controller-provided maximum accepted interest share.
    maxInterest: uint24
}

/// Interest-manager operation-fee notification emitted when a round finalizes.
struct (0x54d37487) TonstakersInterestManagerOperationFee {
    /// Query id emitted as current logical time by the Pool branch.
    queryId: uint64
}

/// Interest-manager round statistics emitted when a round finalizes.
struct (0xc1344900) TonstakersInterestManagerStats {
    /// Query id emitted as current logical time by the Pool branch.
    queryId: uint64
    /// Round borrowed amount.
    borrowed: coins
    /// Round expected repayment.
    expected: coins
    /// Round returned amount.
    returned: coins
    /// Signed round profit.
    profit: TonstakersPoolSignedCoins
    /// Pool total balance after round accounting.
    totalBalance: coins
}

/// Internal message bodies accepted by the Pool.
type TonstakersPoolIncomingMessage =
    | TonstakersPoolDeposit
    | TonstakersPoolWithdraw
    | TonstakersPoolRequestLoan
    | TonstakersPoolLoanRepayment
    | TonstakersPoolTouch
    | TonstakersPoolDonate
    | TonstakersPoolDeployController
    | TonstakersPoolHalt
    | TonstakersPoolSudoSendMessage
    | TonstakersPoolSudoUpgrade
    | TonstakersPoolSetSudoer
    | TonstakersPoolUnhalt
    | TonstakersPoolPrepareGovernanceMigration
    | TonstakersPoolSetRoles
    | TonstakersPoolSetDepositSettings
    | TonstakersPoolSetGovernanceFee
    | TonstakersPoolReturnAvailableFunds
    | TonstakersPoolSetInterest

/// Internal message bodies emitted by the Pool or by helper send sites it directly constructs.
type TonstakersPoolOutgoingMessage =
    | TonstakersPoolWithdrawal
    | TonstakersPayoutMint
    | TonstakersControllerCredit
    | TonstakersControllerTopUp
    | TonstakersJettonExcesses
    | TonstakersPayoutInit
    | TonstakersPayoutsStartDistribution
    | TonstakersInterestManagerRequestNotification
    | TonstakersInterestManagerOperationFee
    | TonstakersInterestManagerStats

/// External log body for loan events; the topic value is carried in the external destination address, not in this body.
struct TonstakersPoolLoanEvent {
    /// Controller address that received the loan.
    lender: address
    /// Principal loan amount.
    amount: coins
}

/// External log body for repayment events; the topic value is carried in the external destination address, not in this body.
struct TonstakersPoolRepaymentEvent {
    /// Controller address that repaid the loan.
    lender: address
    /// Repaid principal amount.
    amount: coins
    /// Signed profit from the repayment.
    profit: TonstakersPoolSignedCoins
}

/// External log body for lending-round completion events.
struct TonstakersPoolRoundCompletionEvent {
    /// Completed lending round id.
    roundId: uint32
    /// Round borrowed amount.
    borrowed: coins
    /// Round returned amount.
    returned: coins
    /// Signed round profit.
    profit: TonstakersPoolSignedCoins
    /// Pool total balance after completion.
    totalBalance: coins
    /// tsTON total supply after completion.
    supply: coins
}

/// External log body for round-rotation events.
struct TonstakersPoolRoundRotationEvent {
    /// New lending round id.
    roundId: uint32
}

/// Event bodies emitted through external-out messages; event topic is encoded in the external destination address.
type TonstakersPoolEventMessage =
    | TonstakersPoolLoanEvent
    | TonstakersPoolRepaymentEvent
    | TonstakersPoolRoundCompletionEvent
    | TonstakersPoolRoundRotationEvent

/// Structured round tuple returned by Pool full-data getters.
struct TonstakersPoolRoundDataReply {
    /// Raw borrower dictionary root returned inside the getter tuple; storage decodes this dictionary as a typed map.
    borrowersDict: cell?
    /// Sequential lending round id.
    roundId: int
    /// Number of active borrowers in this round.
    activeBorrowers: int
    /// Total principal borrowed in this round.
    borrowed: int
    /// Total expected repayment including interest.
    expected: int
    /// Total amount returned so far.
    returned: int
    /// Signed profit returned as a stack integer.
    profit: int
}

/// Structured result returned by `get_pool_full_data` and `get_pool_full_data_raw`.
struct TonstakersPoolFullDataReply {
    /// Pool state enum value.
    state: int
    /// True when the Pool is halted.
    halted: bool
    /// Total TON balance tracked by the Pool.
    totalBalance: int
    /// Current interest share.
    interestRate: int
    /// Optimistic deposit/withdrawal setting.
    optimisticDepositWithdrawals: bool
    /// Deposit-open setting.
    depositsOpen: bool
    /// Saved validator-set hash.
    savedValidatorSetHash: uint256
    /// Previous lending round raw TVM tuple; storage decodes the same layout as `TonstakersPoolRoundData`.
    prevRoundBorrowers: tuple
    /// Current lending round raw TVM tuple; storage decodes the same layout as `TonstakersPoolRoundData`.
    currentRoundBorrowers: tuple
    /// Minimum loan per validator.
    minLoanPerValidator: int
    /// Maximum loan per validator.
    maxLoanPerValidator: int
    /// Governance fee share.
    governanceFee: int
    /// tsTON jetton minter address.
    jettonMinter: any_address
    /// Total tsTON supply.
    supply: int
    /// Deposit payout minter address, or null when absent.
    depositPayout: address?
    /// Amount requested for deposit payout.
    requestedForDeposit: int
    /// Withdrawal payout minter address, or null when absent.
    withdrawalPayout: address?
    /// Amount requested for withdrawal payout.
    requestedForWithdrawal: int
    /// Sudoer address, or null when absent.
    sudoer: address?
    /// Timestamp when sudoer was set.
    sudoerSetAt: int
    /// Governor address, or null when absent.
    governor: address?
    /// Timestamp after which governor update matures.
    governorUpdateAfter: int
    /// Interest-manager address, or null when absent.
    interestManager: address?
    /// Halter address, or null when absent.
    halter: address?
    /// Approver address, or null when absent.
    approver: address?
    /// Validator controller code cell.
    controllerCode: cell
    /// Pool tsTON wallet code cell.
    poolJettonWalletCode: cell
    /// Payout minter code cell.
    payoutMinterCode: cell
    /// Projected TON balance after previous-round profit and fee accounting.
    projectedBalance: int
    /// Projected tsTON supply after previous-round accounting.
    projectedSupply: int
}

/// Structured result returned by `get_controller_address_legacy`.
struct TonstakersPoolControllerAddressLegacyReply {
    /// Workchain id parsed from the derived controller address.
    workchain: int
    /// 256-bit address hash parsed from the derived controller address.
    addressHash: uint256
}

/// Structured result returned by `get_loan`.
struct TonstakersPoolLoanReply {
    /// Principal borrowed by the selected controller.
    borrowedAmount: int
    /// Accounted interest for the selected controller.
    accountedInterest: int
}

/// Structured result returned by `get_controller_loan_position`.
struct TonstakersPoolControllerLoanPositionReply {
    /// Distance from the ordered loan list start to the median of this controller's loan.
    distanceToMedian: int
    /// Total expected repayment for the selected round.
    expected: int
}

/// Pool exit-code catalog.
enum TonstakersPoolErrors {
    /// Message opcode is unsupported, or a loan-position getter could not find the requested controller.
    UnknownOperation = 0xffff
    /// Sender does not match the role, minter, or derived controller expected by a branch.
    WrongSender = 0x9283
    /// Pool state is not valid for the requested branch.
    WrongState = 0x9284
    /// Pool is halted while the branch requires normal operation.
    Halted = 0x9285
    /// Sudoer update quarantine period is still active.
    SudoerQuarantine = 0xa000
    /// New governor update was requested too soon.
    GovernorUpdateTooSoon = 0xa001
    /// Prepared governor update has not matured yet.
    GovernorUpdateNotMatured = 0xa003
    /// Controller's max accepted interest is below Pool interest.
    InterestTooLow = 0xf100
    /// Loan minimum is greater than loan maximum after Pool limits are applied.
    ContradictingBorrowingParams = 0xf101
    /// Pool does not have enough available funds for the requested loan.
    NotEnoughFundsForLoan = 0xf102
    /// Controller total credit would exceed the configured maximum.
    TotalCreditTooHigh = 0xf103
    /// Controller requested borrowing after the current round was closed.
    BorrowingRequestInClosedRound = 0xf104
    /// Attached TON deposit amount is below the deposit fee.
    DepositAmountTooLow = 0xf200
    /// Deposits are closed.
    DepositsAreClosed = 0xf201
    /// Deposit or withdrawal conversion would produce a zero output amount.
    OutputAmountIsZero = 0xf202
    /// Attached TON value is insufficient for withdrawal processing budget.
    NotEnoughTonToProcess = 0xf300
    /// Derived controller address is not in the expected workchain.
    ControllerInWrongWorkchain = 0xf400
    /// Borrower credit-book depth limit would be exceeded.
    CreditBookTooDeep = 0xf401
    /// Borrower dictionary lookup failed where a known borrower was required.
    UnknownBorrower = 0xf402
    /// Round-finalization logic was asked to finalize an active credit round.
    FinalizingActiveCreditRound = 0xf500
    /// Stake recovery attempt counter is too early.
    TooEarlyStakeRecoverAttemptCount = 0xf600
    /// Stake recovery attempt time is too early.
    TooEarlyStakeRecoverAttemptTime = 0xf601
    /// Attached value for stake recovery is too low.
    TooLowRecoverStakeValue = 0xf602
    /// Controller does not have enough money to pay the fine.
    NotEnoughMoneyToPayFine = 0xf603
    /// Attached value for loan request is too low.
    TooLowRequestLoanValue = 0xf604
    /// Validator-set count tuple is too large for update logic.
    TooMuchValidatorSetCounts = 0xf700
    /// Validator-set update did not provide a new hash.
    NoNewHash = 0xf701
    /// Withdrawal was requested while the controller is credited.
    WithdrawalWhileCredited = 0xf800
    /// Withdrawal amount is not valid for controller accounting.
    IncorrectWithdrawalAmount = 0xf801
    /// Controller new-stake query id is incorrect.
    IncorrectNewStakeQueryId = 0xf900
    /// Controller new-stake request value is incorrect.
    IncorrectNewStakeRequestValue = 0xf901
    /// Controller new-stake value is below the minimum.
    IncorrectNewStakeValueLtMinimum = 0xf902
    /// Controller new-stake value is too high.
    IncorrectNewStakeValueTooHigh = 0xf903
    /// Controller new-stake incorrectly uses credited funds.
    IncorrectNewStakeWronglyUsedCredit = 0xf904
    /// Controller new-stake would not guarantee solvency.
    IncorrectNewStakeSolvencyNotGuaranteed = 0xf905
    /// Controller has not been approved by the configured approver.
    ControllerNotApproved = 0xfa00
    /// Multiple loans are prohibited for this controller path.
    MultipleLoansAreProhibited = 0xfa01
    /// Controller requested a loan too early.
    TooEarlyLoanRequest = 0xfa02
    /// Controller requested a loan too late.
    TooLateLoanRequest = 0xfa03
    /// Controller requested too large a loan.
    TooHighLoanRequestAmount = 0xfa04
    /// Controller requested too high a credit interest.
    CreditInterestTooHigh = 0xfa05
    /// Controller attempted to return a loan where no credit exists.
    NoCredit = 0xfb00
    /// Controller attempted to return a loan too early.
    TooEarlyLoanReturn = 0xfb01
}

/// Return complete Pool data after first refreshing round accounting.
get fun get_pool_full_data(): TonstakersPoolFullDataReply {
    assert (true) throw TonstakersPoolErrors.UnknownOperation;
    assert (true) throw TonstakersPoolErrors.WrongSender;
    assert (true) throw TonstakersPoolErrors.WrongState;
    assert (true) throw TonstakersPoolErrors.Halted;
    assert (true) throw TonstakersPoolErrors.SudoerQuarantine;
    assert (true) throw TonstakersPoolErrors.GovernorUpdateTooSoon;
    assert (true) throw TonstakersPoolErrors.GovernorUpdateNotMatured;
    assert (true) throw TonstakersPoolErrors.InterestTooLow;
    assert (true) throw TonstakersPoolErrors.ContradictingBorrowingParams;
    assert (true) throw TonstakersPoolErrors.NotEnoughFundsForLoan;
    assert (true) throw TonstakersPoolErrors.TotalCreditTooHigh;
    assert (true) throw TonstakersPoolErrors.BorrowingRequestInClosedRound;
    assert (true) throw TonstakersPoolErrors.DepositAmountTooLow;
    assert (true) throw TonstakersPoolErrors.DepositsAreClosed;
    assert (true) throw TonstakersPoolErrors.OutputAmountIsZero;
    assert (true) throw TonstakersPoolErrors.NotEnoughTonToProcess;
    assert (true) throw TonstakersPoolErrors.ControllerInWrongWorkchain;
    assert (true) throw TonstakersPoolErrors.CreditBookTooDeep;
    assert (true) throw TonstakersPoolErrors.UnknownBorrower;
    assert (true) throw TonstakersPoolErrors.FinalizingActiveCreditRound;
    assert (true) throw TonstakersPoolErrors.TooEarlyStakeRecoverAttemptCount;
    assert (true) throw TonstakersPoolErrors.TooEarlyStakeRecoverAttemptTime;
    assert (true) throw TonstakersPoolErrors.TooLowRecoverStakeValue;
    assert (true) throw TonstakersPoolErrors.NotEnoughMoneyToPayFine;
    assert (true) throw TonstakersPoolErrors.TooLowRequestLoanValue;
    assert (true) throw TonstakersPoolErrors.TooMuchValidatorSetCounts;
    assert (true) throw TonstakersPoolErrors.NoNewHash;
    assert (true) throw TonstakersPoolErrors.WithdrawalWhileCredited;
    assert (true) throw TonstakersPoolErrors.IncorrectWithdrawalAmount;
    assert (true) throw TonstakersPoolErrors.IncorrectNewStakeQueryId;
    assert (true) throw TonstakersPoolErrors.IncorrectNewStakeRequestValue;
    assert (true) throw TonstakersPoolErrors.IncorrectNewStakeValueLtMinimum;
    assert (true) throw TonstakersPoolErrors.IncorrectNewStakeValueTooHigh;
    assert (true) throw TonstakersPoolErrors.IncorrectNewStakeWronglyUsedCredit;
    assert (true) throw TonstakersPoolErrors.IncorrectNewStakeSolvencyNotGuaranteed;
    assert (true) throw TonstakersPoolErrors.ControllerNotApproved;
    assert (true) throw TonstakersPoolErrors.MultipleLoansAreProhibited;
    assert (true) throw TonstakersPoolErrors.TooEarlyLoanRequest;
    assert (true) throw TonstakersPoolErrors.TooLateLoanRequest;
    assert (true) throw TonstakersPoolErrors.TooHighLoanRequestAmount;
    assert (true) throw TonstakersPoolErrors.CreditInterestTooHigh;
    assert (true) throw TonstakersPoolErrors.NoCredit;
    assert (true) throw TonstakersPoolErrors.TooEarlyLoanReturn;
    return emptyTonstakersPoolFullDataReply();
}

/// Return complete Pool data without refreshing round accounting.
get fun get_pool_full_data_raw(): TonstakersPoolFullDataReply {
    return emptyTonstakersPoolFullDataReply();
}

/// Return the deterministic validator controller address for `controllerId` and `validator`.
get fun get_controller_address(controllerId: int, validator: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the deterministic validator controller address as legacy workchain/hash tuple.
get fun get_controller_address_legacy(controllerId: int, workchain: int, addressHash: uint256): TonstakersPoolControllerAddressLegacyReply {
    return {
        workchain: 0,
        addressHash: 0,
    };
}

/// Return principal and accounted interest for a controller in current or previous round data.
get fun get_loan(controllerId: int, validatorAddress: address, prev: bool, update: bool): TonstakersPoolLoanReply {
    return {
        borrowedAmount: 0,
        accountedInterest: 0,
    };
}

/// Return median-position data for a controller address hash in current or previous round data.
get fun get_controller_loan_position(controllerAddrHash: uint256, prev: bool): TonstakersPoolControllerLoanPositionReply {
    return {
        distanceToMedian: 0,
        expected: 0,
    };
}

/// Return the loan amount the Pool would grant for the supplied controller limits, or -1 when unavailable.
get fun calculate_loan_amount(minLoan: int, maxLoan: int, maxInterest: int): int {
    return 0;
}

fun emptyTonstakersPoolRoundDataReply(): TonstakersPoolRoundDataReply {
    return {
        borrowersDict: null,
        roundId: 0,
        activeBorrowers: 0,
        borrowed: 0,
        expected: 0,
        returned: 0,
        profit: 0,
    };
}

fun emptyTonstakersPoolFullDataReply(): TonstakersPoolFullDataReply {
    return {
        state: 0,
        halted: false,
        totalBalance: 0,
        interestRate: 0,
        optimisticDepositWithdrawals: false,
        depositsOpen: false,
        savedValidatorSetHash: 0,
        prevRoundBorrowers: [],
        currentRoundBorrowers: [],
        minLoanPerValidator: 0,
        maxLoanPerValidator: 0,
        governanceFee: 0,
        jettonMinter: createAddressNone(),
        supply: 0,
        depositPayout: null,
        requestedForDeposit: 0,
        withdrawalPayout: null,
        requestedForWithdrawal: 0,
        sudoer: null,
        sudoerSetAt: 0,
        governor: null,
        governorUpdateAfter: 0,
        interestManager: null,
        halter: null,
        approver: null,
        controllerCode: createEmptyCell(),
        poolJettonWalletCode: createEmptyCell(),
        payoutMinterCode: createEmptyCell(),
        projectedBalance: 0,
        projectedSupply: 0,
    };
}
