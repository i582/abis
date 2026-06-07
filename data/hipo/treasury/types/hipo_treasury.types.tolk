/// Hipo Finance Treasury interface reconstructed from the saved FunC source and TL-B schema.
contract HipoTreasury {
    author: "Hipo Finance"
    version: "1.0"
    description: "Hipo Finance Treasury contract for TON staking deposits, delayed unstake bills, validator loans, governance, and wallet/collection proxy operations."
    storage: HipoTreasuryStorage
    incomingMessages: HipoTreasuryIncomingMessage
    incomingExternal: HipoTreasuryIncomingExternalMessage
    outgoingMessages: HipoTreasuryOutgoingMessage
    forceAbiExport: HipoTreasuryNewStakeMsg | HipoTreasuryLoanRequest | HipoTreasuryParticipation | HipoTreasuryExtension | HipoTreasuryLoanLog | HipoTreasuryRepaymentLog | HipoTreasuryFinishLog | HipoTreasuryFailedBurningTokensLog
    thrownErrors: HipoTreasuryErrors
}

/// Empty dictionary value used where the FunC source stores an empty builder as a set marker.
struct HipoTreasuryEmpty {
}

/// Proposed-governor cell stored as `Maybe ^Cell` in the treasury extension.
struct HipoTreasuryProposedGovernor {
    /// Unix timestamp after which the proposed governor may accept governance.
    acceptAfter: uint32
    /// Governor candidate stored as a TON message address.
    newGovernor: address
}

/// Runtime extension cell referenced by the root storage cell.
struct HipoTreasuryExtension {
    /// Previous token/coin rate after the last fully burned participation round.
    previousRate: coins
    /// Current token/coin rate scaled by 1e9.
    currentRate: coins
    /// Address allowed to halt selected operations together with the governor.
    halter: address
    /// Address allowed to perform governance-only operations.
    governor: address
    /// Optional referenced proposed-governor record.
    proposedGovernor: Cell<HipoTreasuryProposedGovernor>?
    /// Governance fee numerator over 65535, applied to treasury rewards.
    governanceFee: uint16
    /// Collection code dictionary keyed by round_since, stored in a referenced cell.
    collectionCodes: Cell<map<uint32, cell>>
    /// Bill code dictionary keyed by round_since, stored in a referenced cell.
    billCodes: Cell<map<uint32, cell>>
    /// Historical parent-address hashes keyed by uint256; values are empty set markers.
    oldParents: map<uint256, HipoTreasuryEmpty>
}

/// Persistent root storage cell saved by `save_data` in `treasury.fc`.
struct HipoTreasuryStorage {
    /// Total TON coins backing minted hTON tokens, in nanotons.
    totalCoins: coins
    /// Total hTON token supply tracked by the treasury.
    totalTokens: coins
    /// TON queued for minting after active participation rounds.
    totalStaking: coins
    /// hTON queued for delayed unstake after active participation rounds.
    totalUnstaking: coins
    /// Borrower stake currently locked in loan requests and active loans.
    totalBorrowersStake: coins
    /// Active parent contract address; source can store `addr_none` during setup.
    parent: address?
    /// Participation records keyed by validator round `round_since`.
    participations: map<uint32, HipoTreasuryParticipation>
    /// Round imbalance factor stored as uint8 and used by distribution sizing.
    roundsImbalance: uint8
    /// One-bit stopped flag that blocks deposits and loan requests.
    stopped: bool
    /// One-bit flag selecting instant minting when no delayed round is needed.
    instantMint: bool
    /// Loan code dictionary keyed by round_since, stored in a referenced cell.
    loanCodes: Cell<map<uint32, cell>>
    /// Referenced extension cell containing rates, governance, code dictionaries, and old parents.
    extension: Cell<HipoTreasuryExtension>
}

/// Elector new-stake payload stored as a referenced cell in loan requests.
struct HipoTreasuryNewStakeMsg {
    /// Validator public key bits passed to Elector `new_stake`.
    validatorPubkey: bits256
    /// Stake start timestamp for the Elector request.
    stakeAt: uint32
    /// Elector max_factor value for validator stake.
    maxFactor: uint32
    /// ADNL address bits for the validator.
    adnlAddr: bits256
    /// Referenced 512-bit validator signature.
    signature: Cell<bits512>
}

/// Borrower loan request stored inside participation dictionaries.
struct HipoTreasuryLoanRequest {
    /// Minimum borrower payment required before reward sharing.
    minPayment: coins
    /// Borrower reward share encoded over 255.
    borrowerRewardShare: uint8
    /// TON loan principal requested from the treasury.
    loanAmount: coins
    /// Extra allocated amount added by distribution.
    accrueAmount: coins
    /// Borrower stake amount held by the treasury.
    stakeAmount: coins
    /// Referenced Elector new-stake payload.
    newStakeMsg: Cell<HipoTreasuryNewStakeMsg>
}

/// Per-round participation record stored in the root participation dictionary.
struct HipoTreasuryParticipation {
    /// Participation state: open=0, distributing=1, staked=2, validating=3, held=4, recovering=5, burning=6.
    state: uint4
    /// Number of pending or active borrower requests in this round.
    size: uint16
    /// Sort buckets keyed by request sort key; values are referenced borrower-address sets.
    sorted: map<uint112, cell>
    /// Pending loan requests keyed by borrower address hash.
    requests: map<uint256, HipoTreasuryLoanRequest>
    /// Rejected requests keyed by borrower address hash.
    rejected: map<uint256, HipoTreasuryLoanRequest>
    /// Accepted requests before accrual distribution, keyed by borrower address hash.
    accepted: map<uint256, HipoTreasuryLoanRequest>
    /// Accepted requests after accrual distribution, keyed by borrower address hash.
    accrued: map<uint256, HipoTreasuryLoanRequest>
    /// Requests with active loan contracts, keyed by borrower address hash.
    staked: map<uint256, HipoTreasuryLoanRequest>
    /// Requests being recovered from loan contracts, keyed by borrower address hash.
    recovering: map<uint256, HipoTreasuryLoanRequest>
    /// Total TON staked for this round, or a temporary available amount during distribution.
    totalStaked: coins
    /// Total TON recovered for this round, or a temporary allocated amount during distribution.
    totalRecovered: coins
    /// Hash of the validator-set config cell used to detect vset changes.
    currentVsetHash: uint256
    /// Configured stake-hold duration in seconds.
    stakeHeldFor: uint32
    /// Unix timestamp when stake recovery may begin.
    stakeHeldUntil: uint32
}

/// Treasury deposit body accepted from users and wrappers.
struct (0x3d3761a6) HipoTreasuryDepositCoins {
    /// User query id copied to parent proxy messages.
    queryId: uint64
    /// Deposit owner, or `addr_none` to use the message sender.
    owner: address?
    /// TON amount to deposit; zero means use the maximum value after fees.
    coins: coins
    /// Nanotons forwarded to ownership-assigned notifications downstream.
    ownershipAssignedAmount: coins
    /// Referrer marker address stored only on-chain by the source.
    referrer: address?
}

/// User request to ask the parent to unstake all wallet tokens.
struct (0x45baeda9) HipoTreasurySendUnstakeAll {
    /// Query id copied into the parent proxy_unstake_all body.
    queryId: uint64
}

/// Parent-to-treasury request to reserve or burn hTON tokens.
struct (0x386a358b) HipoTreasuryReserveTokens {
    /// Query id copied into rollback, burn, or bill-mint messages.
    queryId: uint64
    /// hTON amount requested for unstake.
    tokens: coins
    /// Token owner whose wallet initiated the unstake.
    owner: address
    /// Four-bit unstake mode: auto=0, instant=1, best=2.
    mode: uint4
    /// Nanotons forwarded to ownership-assigned notifications downstream.
    ownershipAssignedAmount: coins
}

/// Collection-to-treasury callback that turns delayed staking TON into hTON tokens.
struct (0x42684479) HipoTreasuryMintTokens {
    /// Query id copied into proxy_tokens_minted.
    queryId: uint64
    /// TON amount represented by the bill.
    coins: coins
    /// Owner receiving minted tokens through the fixed parent.
    owner: address
    /// Parent address fixed at bill creation time.
    parent: address
    /// Participation round since which minting was delayed.
    roundSince: uint32
}

/// Collection-to-treasury callback that burns delayed unstake bills.
struct (0x7cffe1ee) HipoTreasuryBurnTokens {
    /// Query id copied into proxy_tokens_burned or a replacement bill.
    queryId: uint64
    /// hTON amount represented by the bill.
    tokens: coins
    /// Owner receiving burned TON through the fixed parent.
    owner: address
    /// Parent address fixed at bill creation time.
    parent: address
    /// Participation round since which burning was delayed.
    roundSince: uint32
}

/// Borrower request to join the next validator election with treasury funding.
struct (0x36335da9) HipoTreasuryRequestLoan {
    /// Query id copied through distribution and loan messages.
    queryId: uint64
    /// Expected next validator round.
    roundSince: uint32
    /// TON principal requested from the treasury.
    loanAmount: coins
    /// Minimum treasury payment required from borrower rewards or stake.
    minPayment: coins
    /// Borrower reward share encoded over 255.
    borrowerRewardShare: uint8
    /// Referenced Elector new-stake payload.
    newStakeMsg: Cell<HipoTreasuryNewStakeMsg>
}

/// Internal or external trigger to start participation distribution for a round.
struct (0x574a297b) HipoTreasuryParticipateInElection {
    /// Query id copied into self-continuation messages.
    queryId: uint64
    /// Validator round to process.
    roundSince: uint32
}

/// Self-message that continues selecting accepted loan requests.
struct (0x6a31d344) HipoTreasuryDecideLoanRequests {
    /// Query id copied into later self and borrower messages.
    queryId: uint64
    /// Validator round being processed.
    roundSince: uint32
}

/// Self-message that deploys loan contracts or refunds rejected requests.
struct (0x071d07cc) HipoTreasuryProcessLoanRequests {
    /// Query id copied into loan and borrower messages.
    queryId: uint64
    /// Validator round being processed.
    roundSince: uint32
}

/// Internal or external trigger used when the validator set changes.
struct (0x2f0b5b3b) HipoTreasuryVsetChanged {
    /// Query id for the accepted external/internal trigger.
    queryId: uint64
    /// Validator round whose state should advance.
    roundSince: uint32
}

/// Internal or external trigger to finish a held participation round; source uses uint64 query_id.
struct (0x23274435) HipoTreasuryFinishParticipation {
    /// Query id copied into recover_stakes self-message.
    queryId: uint64
    /// Validator round to finish.
    roundSince: uint32
}

/// Self-message that sends recover-stake commands to loan contracts.
struct (0x4f173d3e) HipoTreasuryRecoverStakes {
    /// Query id copied into loan recovery messages.
    queryId: uint64
    /// Validator round being recovered.
    roundSince: uint32
}

/// Loan-to-treasury recovery result after Elector stake recovery.
struct (0x0fca4c86) HipoTreasuryRecoverStakeResult {
    /// Query id copied into borrower/governor notifications.
    queryId: uint64
    /// One-bit ok flag from the loan contract.
    ok: bool
    /// Borrower address used to locate the request.
    borrower: address
    /// Validator round being recovered.
    roundSince: uint32
}

/// Collection-to-treasury notification that the last bill for a round was burned.
struct (0xc6d8b51f) HipoTreasuryLastBillBurned {
    /// Query id from the collection burn-all flow.
    queryId: uint64
    /// Validator round whose participation record can be removed.
    roundSince: uint32
}

/// Governance message that stores a proposed new governor.
struct (0x76ff2956) HipoTreasuryProposeGovernor {
    /// Query id for the excess response.
    queryId: uint64
    /// New governor candidate.
    newGovernor: address
}

/// Proposed-governor message that accepts governance after the delay.
struct (0x06e237e3) HipoTreasuryAcceptGovernance {
    /// Query id for the excess response.
    queryId: uint64
}

/// Governance or halter message that replaces the halter address.
struct (0x16bb5b17) HipoTreasurySetHalter {
    /// Query id for the excess response.
    queryId: uint64
    /// New halter address.
    newHalter: address
}

/// Governance or halter message that updates the stopped flag.
struct (0x0e5e9773) HipoTreasurySetStopped {
    /// Query id for the excess response.
    queryId: uint64
    /// New stopped flag stored as one bit.
    newStopped: bool
}

/// Governance or halter message that updates instant minting.
struct (0x535b09d2) HipoTreasurySetInstantMint {
    /// Query id for the excess response.
    queryId: uint64
    /// New instant-mint flag stored as one bit.
    newInstantMint: bool
}

/// Governor-only message that updates the reward fee.
struct (0x470fe5f6) HipoTreasurySetGovernanceFee {
    /// Query id for the excess response.
    queryId: uint64
    /// New governance fee numerator over 65535.
    newGovernanceFee: uint16
}

/// Governance or halter message that updates round imbalance.
struct (0x1b4463b6) HipoTreasurySetRoundsImbalance {
    /// Query id for authorization and tracing.
    queryId: uint64
    /// New uint8 imbalance factor.
    newRoundsImbalance: uint8
}

/// Governance or halter message that forwards an arbitrary body to a derived loan.
struct (0x0e93f65b) HipoTreasurySendMessageToLoan {
    /// Query id for authorization and tracing.
    queryId: uint64
    /// Borrower whose loan address is derived.
    borrower: address
    /// Validator round used in loan address derivation.
    roundSince: uint32
    /// Referenced raw message body forwarded to the loan.
    message: cell
}

/// Governance or halter retry for a distribution round.
struct (0x6ec00c48) HipoTreasuryRetryDistribute {
    /// Query id copied into the restarted distribution.
    queryId: uint64
    /// Validator round to retry.
    roundSince: uint32
}

/// Governance or halter retry for recover-stake self-processing.
struct (0x2b7ad9e8) HipoTreasuryRetryRecoverStakes {
    /// Query id copied into the recover_stakes self-message.
    queryId: uint64
    /// Validator round to retry.
    roundSince: uint32
}

/// Governor-only retry that mints a delayed bill for an existing participation.
struct (0x654de488) HipoTreasuryRetryMintBill {
    /// Query id copied into mint_bill.
    queryId: uint64
    /// Validator round for the bill collection.
    roundSince: uint32
    /// TON or hTON amount represented by the bill.
    amount: coins
    /// One-bit flag: true for unstake bill, false for staking bill.
    unstake: bool
    /// Bill owner.
    owner: address
    /// Parent address fixed for downstream wallet operations.
    parent: address
    /// Nanotons forwarded to ownership-assigned notifications.
    ownershipAssignedAmount: coins
}

/// Governance or halter retry that asks a bill collection to burn all bills.
struct (0x106b8001) HipoTreasuryRetryBurnAll {
    /// Query id copied into burn_all.
    queryId: uint64
    /// Validator round for the bill collection.
    roundSince: uint32
    /// First bill index for the collection burn loop.
    startIndex: uint64
}

/// Governor-only message that replaces the parent address and records old parent hashes.
struct (0x4f6f6eed) HipoTreasurySetParent {
    /// Query id for the excess response.
    queryId: uint64
    /// New parent contract address.
    newParent: address
}

/// Governor-only proxy that sends set_content to another contract.
struct (0x2b1c8e37) HipoTreasuryProxySetContent {
    /// Query id copied into set_content.
    queryId: uint64
    /// Destination contract that receives set_content.
    destination: address
    /// Referenced content cell passed through unchanged.
    newContent: cell
}

/// Governor-only message that withdraws surplus TON to a response address.
struct (0x23355ffb) HipoTreasuryWithdrawSurplus {
    /// Query id copied into gas_excess.
    queryId: uint64
    /// Destination for the surplus gas_excess body and remaining balance.
    returnExcess: address
}

/// Governor-only proxy that sends withdraw_surplus to another contract.
struct (0x77a0bf77) HipoTreasuryProxyWithdrawSurplus {
    /// Query id copied into withdraw_surplus.
    queryId: uint64
    /// Destination contract that receives withdraw_surplus.
    destination: address
}

/// Governor-only code upgrade body.
struct (0x3d6a29b5) HipoTreasuryUpgradeCode {
    /// Query id copied into upgrade_data and excess response.
    queryId: uint64
    /// Referenced replacement code cell.
    newCode: cell
    /// Optional referenced replacement data cell.
    newData: cell?
    /// Destination for the excess response after upgrade_data.
    returnExcess: address
}

/// Governor-only proxy that sends upgrade_code to another contract.
struct (0x78570010) HipoTreasuryProxyUpgradeCode {
    /// Query id copied into upgrade_code.
    queryId: uint64
    /// Destination contract to upgrade.
    destination: address
    /// Referenced replacement code cell.
    newCode: cell
    /// Optional referenced replacement data cell.
    newData: cell?
}

/// Governance or halter proxy that asks a wallet to upgrade.
struct (0x7ade1ed8) HipoTreasurySendUpgradeWallet {
    /// Query id copied into proxy_upgrade_wallet.
    queryId: uint64
    /// Wallet or parent destination.
    destination: address
    /// Wallet owner forwarded downstream.
    owner: address
}

/// Old-parent-to-treasury wallet migration body.
struct (0x325aacfa) HipoTreasuryMigrateWallet {
    /// Query id copied into proxy_merge_wallet.
    queryId: uint64
    /// Token balance to merge.
    tokens: coins
    /// Wallet owner forwarded downstream.
    owner: address
}

/// Governor-only proxy that asks another contract to add a library.
struct (0x31cb87f7) HipoTreasuryProxyAddLibrary {
    /// Query id copied into add_library.
    queryId: uint64
    /// Destination contract.
    destination: address
    /// Referenced library code cell.
    code: cell
}

/// Governor-only proxy that asks another contract to remove a library.
struct (0x747bf3a2) HipoTreasuryProxyRemoveLibrary {
    /// Query id copied into remove_library.
    queryId: uint64
    /// Destination contract.
    destination: address
    /// Library code hash to remove.
    codeHash: uint256
}

/// Message that gifts TON to the treasury accounting when tokens exist.
struct (0x3496db80) HipoTreasuryGiftCoins {
    /// Query id copied into gas_excess.
    queryId: uint64
    /// TON amount intended for totalCoins accounting.
    coins: coins
}

/// No-op top-up body accepted by the dispatcher.
struct (0x5372158c) HipoTreasuryTopUp {
    /// Query id present in schema but ignored by the source no-op branch.
    queryId: uint64
}

/// Zero-op text/comment command; source accepts exactly deposit (`d`) and withdraw (`w`) shorthands.
struct (0x00000000) HipoTreasuryTextCommand {
    /// Raw one-byte command tail and any unexpected remainder preserved for tests.
    command: RemainingBitsAndRefs
}

/// Treasury-to-parent notification that tokens were minted.
struct (0x5be57626) HipoTreasuryProxyTokensMinted {
    /// Query id copied from the deposit or bill mint.
    queryId: uint64
    /// hTON tokens minted.
    tokens: coins
    /// TON coins deposited or finalized.
    coins: coins
    /// Owner receiving minted tokens.
    owner: address
    /// Delayed round, or zero for instant mint.
    roundSince: uint32
}

/// Treasury-to-parent request to save delayed staking TON.
struct (0x47daa10f) HipoTreasuryProxySaveCoins {
    /// Query id copied from the deposit.
    queryId: uint64
    /// TON coins to save.
    coins: coins
    /// Deposit owner.
    owner: address
    /// Participation round since which minting is delayed.
    roundSince: uint32
}

/// Treasury-to-parent rollback for an unstake request that cannot proceed.
struct (0x32b67194) HipoTreasuryProxyRollbackUnstake {
    /// Query id copied from reserve_tokens.
    queryId: uint64
    /// hTON tokens to roll back.
    tokens: coins
    /// Owner whose wallet should be restored.
    owner: address
}

/// Treasury-to-parent notification that tokens were burned for TON.
struct (0x4476fde0) HipoTreasuryProxyTokensBurned {
    /// Query id copied from reserve or bill burn.
    queryId: uint64
    /// hTON tokens burned.
    tokens: coins
    /// TON coins released.
    coins: coins
    /// Owner receiving released TON.
    owner: address
}

/// Treasury-to-parent request to unstake all tokens for a user.
struct (0x76bd2760) HipoTreasuryProxyUnstakeAll {
    /// Query id copied from send_unstake_all.
    queryId: uint64
    /// User that requested full unstake.
    owner: address
}

/// Treasury-to-caller quote response.
struct (0x0a420458) HipoTreasuryTakeCurrentQuote {
    /// Query id copied from provide_current_quote.
    queryId: uint64
    /// Quote numerator, equal to totalCoins.
    quoteNumerator: uint128
    /// Quote denominator, equal to totalTokens.
    quoteDenominator: uint128
    /// Optional referenced custom payload echoed from the request.
    customPayload: cell?
}

/// Treasury-to-collection request to mint a staking or unstake bill.
struct (0x4b2d7871) HipoTreasuryMintBill {
    /// Query id copied from the source operation.
    queryId: uint64
    /// TON or hTON amount represented by the bill.
    amount: coins
    /// One-bit flag: true for unstake bill, false for staking bill.
    unstake: bool
    /// Bill owner.
    owner: address
    /// Parent address fixed for downstream wallet operations.
    parent: address
    /// Nanotons forwarded to ownership-assigned notifications.
    ownershipAssignedAmount: coins
}

/// Treasury-to-loan request to send the referenced Elector new-stake payload.
struct (0x089cd4d0) HipoTreasuryProxyNewStake {
    /// Query id copied from distribution.
    queryId: uint64
    /// Referenced Elector new-stake payload.
    newStakeMsg: Cell<HipoTreasuryNewStakeMsg>
}

/// Treasury-to-loan request to recover a validator stake.
struct (0x407cb243) HipoTreasuryProxyRecoverStake {
    /// Query id copied from recover_stakes.
    queryId: uint64
}

/// Treasury-to-collection request to burn all bills for a round.
struct (0x639d400a) HipoTreasuryBurnAll {
    /// Query id copied from recover result or retry.
    queryId: uint64
    /// First bill index for the collection burn loop.
    startIndex: uint64
}

/// Borrower refund/notification that a loan request was rejected.
struct (0xcd0f2116) HipoTreasuryRequestRejected {
    /// Query id copied from the loan request flow.
    queryId: uint64
}

/// Borrower notification that a recovered loan result returned remaining stake.
struct (0xfaaa8366) HipoTreasuryLoanResult {
    /// Query id copied from recover_stake_result.
    queryId: uint64
}

/// Governor notification that profit was sent.
struct (0x8b556813) HipoTreasuryTakeProfit {
    /// Query id copied from recover_stake_result.
    queryId: uint64
}

/// Standard excess response body used by governance and withdrawal branches.
struct (0xd53276db) HipoTreasuryGasExcess {
    /// Query id copied from the triggering operation.
    queryId: uint64
}

/// Downstream content update body emitted by proxy_set_content.
struct (0x04dc78b7) HipoTreasurySetContent {
    /// Query id copied from proxy_set_content.
    queryId: uint64
    /// Address receiving any excess from the destination.
    returnExcess: address
    /// Referenced content cell passed through unchanged.
    newContent: cell
}

/// Downstream withdraw-surplus body emitted by proxy_withdraw_surplus.
struct (0x23355ffb) HipoTreasuryForwardWithdrawSurplus {
    /// Query id copied from proxy_withdraw_surplus.
    queryId: uint64
    /// Address receiving the destination's excess response.
    returnExcess: address
}

/// Downstream upgrade-code body emitted by proxy_upgrade_code.
struct (0x3d6a29b5) HipoTreasuryForwardUpgradeCode {
    /// Query id copied from proxy_upgrade_code.
    queryId: uint64
    /// Referenced replacement code cell.
    newCode: cell
    /// Optional referenced replacement data cell.
    newData: cell?
    /// Address receiving the destination's excess response.
    returnExcess: address
}

/// Downstream wallet-upgrade proxy body emitted by send_upgrade_wallet.
struct (0x4664bc68) HipoTreasuryProxyUpgradeWallet {
    /// Query id copied from send_upgrade_wallet.
    queryId: uint64
    /// Wallet owner forwarded downstream.
    owner: address
}

/// Downstream merge-wallet proxy body emitted by migrate_wallet.
struct (0x6833d7d0) HipoTreasuryProxyMergeWallet {
    /// Query id copied from migrate_wallet.
    queryId: uint64
    /// Token balance to merge.
    tokens: coins
    /// Wallet owner forwarded downstream.
    owner: address
}

/// Downstream add-library body emitted by proxy_add_library.
struct (0x53d0473e) HipoTreasuryAddLibrary {
    /// Query id copied from proxy_add_library.
    queryId: uint64
    /// Referenced library code cell.
    code: cell
}

/// Downstream remove-library body emitted by proxy_remove_library.
struct (0x6bd0ce52) HipoTreasuryRemoveLibrary {
    /// Query id copied from proxy_remove_library.
    queryId: uint64
    /// Library code hash to remove.
    codeHash: uint256
}

/// External log body for accepted loans; emitted to topic `log::loan`.
struct HipoTreasuryLoanLog {
    /// Validator round for the loan.
    roundSince: uint32
    /// Minimum borrower payment.
    minPayment: coins
    /// Borrower reward share over 255.
    borrowerRewardShare: uint8
    /// Loan principal amount.
    loanAmount: coins
    /// Extra accrued amount.
    accrueAmount: coins
    /// Borrower stake amount.
    stakeAmount: coins
    /// Borrower address.
    borrower: address
}

/// External log body for recovered loan repayment; emitted to topic `log::repayment`.
struct HipoTreasuryRepaymentLog {
    /// Validator round being repaid.
    roundSince: uint32
    /// Total incoming repayment amount.
    repaymentAmount: coins
    /// Loan principal amount.
    loanAmount: coins
    /// Extra accrued amount.
    accrueAmount: coins
    /// Stakers' reward share added to total coins.
    stakersShare: coins
    /// Governance fee share.
    governorShare: coins
    /// Borrower share returned as stake.
    borrowerShare: coins
    /// Borrower address.
    borrower: address
}

/// External log body emitted after a participation round is finalized.
struct HipoTreasuryFinishLog {
    /// Validator round that finished.
    roundSince: uint32
    /// Total TON staked in the round.
    totalStaked: coins
    /// Total TON recovered in the round.
    totalRecovered: coins
    /// Treasury totalCoins after finalization.
    totalCoins: coins
    /// Treasury totalTokens after finalization.
    totalTokens: coins
}

/// External log body emitted when delayed token burning cannot be completed.
struct HipoTreasuryFailedBurningTokensLog {
    /// Validator round where burning failed.
    roundSince: uint32
    /// Treasury totalCoins at failure time.
    totalCoins: coins
    /// Treasury totalTokens at failure time.
    totalTokens: coins
    /// TON coins that could not be released.
    coins: coins
    /// hTON tokens that could not be burned.
    tokens: coins
    /// Owner affected by the failed burn.
    owner: address
}

/// Internal message bodies accepted by the Treasury dispatcher.
type HipoTreasuryIncomingMessage =
    | HipoTreasuryDepositCoins
    | HipoTreasurySendUnstakeAll
    | HipoTreasuryReserveTokens
    | HipoTreasuryMintTokens
    | HipoTreasuryBurnTokens
    | HipoTreasuryRequestLoan
    | HipoTreasuryParticipateInElection
    | HipoTreasuryDecideLoanRequests
    | HipoTreasuryProcessLoanRequests
    | HipoTreasuryVsetChanged
    | HipoTreasuryFinishParticipation
    | HipoTreasuryRecoverStakes
    | HipoTreasuryRecoverStakeResult
    | HipoTreasuryLastBillBurned
    | HipoTreasuryProposeGovernor
    | HipoTreasuryAcceptGovernance
    | HipoTreasurySetHalter
    | HipoTreasurySetStopped
    | HipoTreasurySetInstantMint
    | HipoTreasurySetGovernanceFee
    | HipoTreasurySetRoundsImbalance
    | HipoTreasurySendMessageToLoan
    | HipoTreasuryRetryDistribute
    | HipoTreasuryRetryRecoverStakes
    | HipoTreasuryRetryMintBill
    | HipoTreasuryRetryBurnAll
    | HipoTreasurySetParent
    | HipoTreasuryProxySetContent
    | HipoTreasuryWithdrawSurplus
    | HipoTreasuryProxyWithdrawSurplus
    | HipoTreasuryUpgradeCode
    | HipoTreasuryProxyUpgradeCode
    | HipoTreasurySendUpgradeWallet
    | HipoTreasuryMigrateWallet
    | HipoTreasuryProxyAddLibrary
    | HipoTreasuryProxyRemoveLibrary
    | HipoTreasuryGiftCoins
    | HipoTreasuryTopUp
    | HipoTreasuryTextCommand

/// External-in message bodies accepted by the Treasury dispatcher.
type HipoTreasuryIncomingExternalMessage =
    | HipoTreasuryParticipateInElection
    | HipoTreasuryVsetChanged
    | HipoTreasuryFinishParticipation

/// Internal message bodies emitted by Treasury send-sites; external log bodies are force-exported separately.
type HipoTreasuryOutgoingMessage =
    | HipoTreasuryProxyTokensMinted
    | HipoTreasuryProxySaveCoins
    | HipoTreasuryProxyRollbackUnstake
    | HipoTreasuryProxyTokensBurned
    | HipoTreasuryProxyUnstakeAll
    | HipoTreasuryTakeCurrentQuote
    | HipoTreasuryMintBill
    | HipoTreasuryDecideLoanRequests
    | HipoTreasuryProcessLoanRequests
    | HipoTreasuryProxyNewStake
    | HipoTreasuryProxyRecoverStake
    | HipoTreasuryRecoverStakes
    | HipoTreasuryBurnAll
    | HipoTreasuryRequestRejected
    | HipoTreasuryLoanResult
    | HipoTreasuryTakeProfit
    | HipoTreasuryGasExcess
    | HipoTreasurySetContent
    | HipoTreasuryForwardWithdrawSurplus
    | HipoTreasuryForwardUpgradeCode
    | HipoTreasuryProxyUpgradeWallet
    | HipoTreasuryProxyMergeWallet
    | HipoTreasuryAddLibrary
    | HipoTreasuryRemoveLibrary

/// Stack reply returned by `get_treasury_state`.
struct HipoTreasuryStateReply {
    /// Total TON coins backing minted hTON tokens, in nanotons.
    totalCoins: coins
    /// Total hTON token supply tracked by the treasury.
    totalTokens: coins
    /// TON queued for delayed minting.
    totalStaking: coins
    /// hTON queued for delayed unstake.
    totalUnstaking: coins
    /// Borrower stake currently locked by loan flows.
    totalBorrowersStake: coins
    /// Parent address returned from storage, or none during setup.
    parent: any_address
    /// Raw participation dictionary returned as a cell by the source getter.
    participations: cell?
    /// Round imbalance factor.
    roundsImbalance: uint8
    /// Stopped flag.
    stopped: bool
    /// Instant-mint flag.
    instantMint: bool
    /// Loan code dictionary cell.
    loanCodes: cell
    /// Previous rate scaled by 1e9.
    previousRate: coins
    /// Current rate scaled by 1e9.
    currentRate: coins
    /// Halter address.
    halter: address
    /// Governor address.
    governor: address
    /// Optional proposed-governor cell.
    proposedGovernor: cell?
    /// Governance fee numerator over 65535.
    governanceFee: uint16
    /// Collection code dictionary cell.
    collectionCodes: cell
    /// Bill code dictionary cell.
    billCodes: cell
    /// Raw old-parent dictionary returned as a cell by the source getter.
    oldParents: cell?
}

/// Stack reply returned by `get_participation`.
struct HipoTreasuryParticipationReply {
    /// Participation state.
    state: uint4
    /// Number of requests in the participation.
    size: uint16
    /// Raw sorted dictionary cell.
    sorted: cell?
    /// Raw pending requests dictionary cell.
    requests: cell?
    /// Raw rejected requests dictionary cell.
    rejected: cell?
    /// Raw accepted requests dictionary cell.
    accepted: cell?
    /// Raw accrued requests dictionary cell.
    accrued: cell?
    /// Raw staked requests dictionary cell.
    staked: cell?
    /// Raw recovering requests dictionary cell.
    recovering: cell?
    /// Total staked amount.
    totalStaked: coins
    /// Total recovered amount.
    totalRecovered: coins
    /// Validator-set hash.
    currentVsetHash: uint256
    /// Stake-hold duration.
    stakeHeldFor: uint32
    /// Stake-held-until timestamp.
    stakeHeldUntil: uint32
}

/// Stack reply returned by `get_times`.
struct HipoTreasuryTimesReply {
    /// Current validator round start timestamp.
    currentRoundSince: uint32
    /// Earliest participation time for the next round.
    participateSince: uint32
    /// Latest participation time for the next round.
    participateUntil: uint32
    /// Next validator round start timestamp.
    nextRoundSince: uint32
    /// Next validator round end timestamp.
    nextRoundUntil: uint32
    /// Stake-hold duration from config.
    stakeHeldFor: uint32
}

/// Stack reply returned by `get_treasury_fees`.
struct HipoTreasuryFeesReply {
    /// Fee required for request_loan.
    requestLoanFee: coins
    /// Fee required for deposit_coins with the supplied ownership-assigned amount.
    depositCoinsFee: coins
    /// Fee required for send_unstake_all.
    unstakeAllTokensFee: coins
}

/// Stack reply returned by address-derivation getters.
struct HipoTreasuryAddressReply {
    /// Derived internal address.
    value: any_address
}

/// Source-level exit-code catalog from `imports/constants.fc`.
enum HipoTreasuryErrors {
    /// Attached TON is below the required fee.
    InsufficientFee = 101
    /// Available funds are below the requested amount.
    InsufficientFunds = 102
    /// Sender is not authorized for the operation.
    AccessDenied = 103
    /// Address is not in the basechain when the source requires basechain.
    OnlyBasechainAllowed = 104
    /// Receiver equals sender in helper checks.
    ReceiverIsSender = 105
    /// Treasury is stopped for the requested operation.
    Stopped = 106
    /// Message opcode is not supported.
    InvalidOp = 107
    /// Zero-op text command is not a valid shorthand.
    InvalidComment = 108
    /// Governance or retry parameters are invalid.
    InvalidParameters = 109
    /// Treasury is not accepting loan requests.
    NotAcceptingLoanRequests = 201
    /// Participation cannot proceed in the current state.
    UnableToParticipate = 202
    /// Participation was requested too early.
    TooSoonToParticipate = 203
    /// Participation is not ready to finish.
    NotReadyToFinishParticipation = 204
    /// Held stake cannot be recovered yet.
    TooSoonToFinishParticipation = 205
    /// Validator set has not changed as required.
    VsetNotChanged = 206
    /// Validator set cannot change in the current participation state.
    VsetNotChangeable = 207
    /// Bill collection is not ready for burn_all.
    NotReadyToBurnAll = 208
    /// Config validator set cell has an unexpected format.
    UnexpectedValidatorSetFormat = 304
}

/// Return treasury accounting, parent, raw dictionaries, rates, governance, and code dictionaries.
get fun get_treasury_state(): HipoTreasuryStateReply {
    throw 0;
}

/// Return one participation record from the participation dictionary.
get fun get_participation(roundSince: int): HipoTreasuryParticipationReply {
    throw 0;
}

/// Return the derived collection address for a validator round.
get fun get_collection_address(roundSince: int): any_address {
    throw 0;
}

/// Return the derived bill address for a validator round and bill index.
get fun get_bill_address(roundSince: int, index: int): any_address {
    throw 0;
}

/// Return the derived loan address for a borrower and validator round.
get fun get_loan_address(borrower: slice, roundSince: int): any_address {
    throw 0;
}

/// Return loan, deposit, and unstake-all fee estimates.
get fun get_treasury_fees(ownershipAssignedAmount: int): HipoTreasuryFeesReply {
    throw 0;
}

/// Return current and next validator timing windows.
get fun get_times(): HipoTreasuryTimesReply {
    throw 0;
}

/// Return the currently burnable hTON amount based on balance and reserves.
get fun get_max_burnable_tokens(): coins {
    throw 0;
}

/// Return TON surplus above the source-calculated minimum reserve.
get fun get_surplus(): int {
    throw 0;
}

/// Return the recommended max misbehaviour punishment for a given stake.
get fun get_max_punishment(stake: int): coins {
    throw 0;
}
