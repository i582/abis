/// JVault per-owner staking wallet interface confirmed against exact source and mainnet block 43915595.
contract JVaultStakingWallet {
    author: "JVault"
    description: "JVault per-owner staking position, rewards, unstake requests, transferable stake, and administrative pool messages."
    storage: JVaultStakingWalletStorage
    incomingMessages: JVaultStakingWalletIncomingMessage
    outgoingMessages: JVaultStakingWalletOutgoingMessage
    thrownErrors: JVaultStakingWalletErrors
    forceAbiExport: JVaultStakingWalletForwardedReceiveTail
        | JVaultStakingWalletForwardedReceiveContext
        | JVaultStakingWalletForwardedUpdateRewardsTail
}

/// Reward accounting retained for one reward Jetton wallet.
struct JVaultStakingWalletRewardInfo {
    /// Last cumulative reward value accounted for this staking wallet.
    distributedRewards: uint256
    /// Reward Jettons accrued but not yet transferred to the owner.
    unclaimedRewards: coins
}

/// Mutable balances, requests, limits, and activation state held by a staking wallet.
struct JVaultStakingWalletState {
    /// Lock period selected when this staking wallet was derived.
    lockPeriod: uint32
    /// Staked Jettons not currently requested for unstaking.
    jettonBalance: coins
    /// Reward accounting keyed by reward Jetton wallet address.
    rewards: map<address, JVaultStakingWalletRewardInfo>
    /// Pending unstake amounts keyed by request Unix timestamp.
    unstakeRequests: map<uint32, coins>
    /// Number of pending unstake requests.
    requestsCount: uint8
    /// Total Jettons covered by pending unstake requests.
    totalRequestedJettons: coins
    /// Whether the wallet currently accepts owner actions.
    isActive: bool
    /// Commission rate for an instant unstake, in protocol basis points.
    unstakeCommission: uint16
    /// Fixed GRAM fee charged for an instant unstake.
    unstakeFee: coins
    /// Minimum accepted staking deposit.
    minDeposit: coins
    /// Maximum accepted staking deposit.
    maxDeposit: coins
    /// Accounts allowed to receive transferred stake; an empty map disables membership.
    whitelist: map<address, bool>
}

/// Persistent state of a deployed JVault staking wallet.
struct JVaultStakingWalletStorage {
    /// Parent staking-pool address.
    stakingPoolAddress: address
    /// Jetton minter address exposed for TEP-74 compatibility.
    minterAddress: address
    /// Owner of the staked position.
    ownerAddress: address
    /// Referenced balances, requests, limits, and activation state.
    state: Cell<JVaultStakingWalletState>
}

/// Standard Jetton-compatible tuple returned by `get_wallet_data`.
struct JVaultStakingWalletData {
    /// Current free staked-Jetton balance.
    balance: int
    /// Owner of the staked position.
    ownerAddress: address
    /// Jetton minter address.
    minterAddress: address
    /// Executable staking-wallet code cell.
    walletCode: cell
}

/// Complete tuple returned by the staking-wallet `get_storage_data` method.
struct JVaultStakingWalletStorageData {
    /// Parent staking-pool address.
    stakingPoolAddress: address
    /// Owner of the staked position.
    ownerAddress: address
    /// Lock period selected for this wallet.
    lockPeriod: int
    /// Staked Jettons not requested for unstaking.
    jettonBalance: int
    /// Raw optional reward-accounting dictionary returned on the TVM stack.
    rewards: cell?
    /// Raw optional pending-unstake dictionary returned on the TVM stack.
    unstakeRequests: cell?
    /// Number of pending unstake requests.
    requestsCount: int
    /// Total Jettons covered by pending requests.
    totalRequestedJettons: int
    /// Whether the wallet currently accepts owner actions.
    isActive: bool
    /// Instant-unstake commission in protocol basis points.
    unstakeCommission: int
    /// Fixed GRAM fee for instant unstaking.
    unstakeFee: int
    /// Minimum accepted deposit.
    minDeposit: int
    /// Maximum accepted deposit.
    maxDeposit: int
    /// Raw optional inherited whitelist dictionary returned on the TVM stack.
    whitelist: cell?
    /// Jetton minter address exposed for TEP-74 compatibility.
    minterAddress: address
}

/// Referenced transfer context appended when stake moves between deterministic wallets.
struct JVaultStakingWalletForwardedReceiveContext {
    /// Address receiving excess GRAM after the transfer completes.
    responseAddress: address
    /// GRAM forwarded to the new owner's transfer notification.
    forwardAmount: coins
    /// Source wallet balance used for ordered reward-accounting updates.
    senderBalance: coins
    /// Source wallet reward accounting before the transfer.
    senderRewards: map<address, JVaultStakingWalletRewardInfo>
    /// Original TEP-74 forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Conditional tail present when `receive_jettons` comes from another staking wallet.
struct JVaultStakingWalletForwardedReceiveTail {
    /// Owner represented by the source deterministic staking wallet.
    fromAddress: address
    /// Referenced response, amount, balance, rewards, and forward-payload context.
    context: Cell<JVaultStakingWalletForwardedReceiveContext>
}

/// Pool or sibling-wallet delivery that credits staked Jettons.
struct (0xd68a4ac1) JVaultStakingWalletReceiveJettons {
    /// Query identifier copied from the originating transfer.
    queryId: uint64
    /// Minimum allowed staking-wallet balance after the credit.
    minDeposit: coins
    /// Maximum allowed staking-wallet balance after the credit.
    maxDeposit: coins
    /// Instant-unstake commission in protocol basis points.
    unstakeCommission: uint16
    /// Fixed GRAM fee charged for an instant unstake.
    unstakeFee: coins
    /// Pool whitelist copied into the receiving wallet.
    whitelist: map<address, bool>
    /// Net Jettons credited to the receiving wallet.
    receivedJettons: coins
    /// Deposit commission retained by the pool.
    depositCommission: coins
    /// Empty for a direct pool credit, or a `JVaultStakingWalletForwardedReceiveTail` body.
    forwardedTail: RemainingBitsAndRefs
}

/// Rollback sent or accepted when a stake transfer cannot be credited.
struct (0x9eada1d9) JVaultStakingWalletCancelStake {
    /// Correlation identifier copied from the failed transfer.
    queryId: uint64
    /// Owner represented by the source staking wallet.
    stakeOwnerAddress: address
    /// Lock period identifying the deterministic staking wallet.
    lockPeriod: uint32
    /// Net staked Jettons restored after failure.
    stakedAmount: coins
    /// Deposit commission restored together with the stake.
    depositCommission: coins
}

/// Pool response that replaces reward accounting and reactivates the wallet.
struct (0xae9307ce) JVaultStakingWalletUpdateRewards {
    /// Correlation identifier copied from the reward update request.
    queryId: uint64
    /// Updated reward accounting keyed by reward Jetton wallet.
    rewards: map<address, JVaultStakingWalletRewardInfo>
    /// Address receiving any excess GRAM.
    responseAddress: address
}

/// Pool command that disables owner operations for this wallet.
struct (0x4b14c485) JVaultStakingWalletDeactivate {
    /// Correlation identifier accepted by the common envelope.
    queryId: uint64
}

/// Pool command to replace wallet code and optionally persistent data.
struct (0xe2d2d211) JVaultStakingWalletSetCode {
    /// Correlation identifier accepted by the common envelope.
    queryId: uint64
    /// Replacement executable code stored as a mandatory reference.
    code: cell
    /// Empty to preserve current data, or a trailing untagged data reference.
    optionalData: RemainingBitsAndRefs
}

/// Permissionless request to report the complete persistent wallet data.
struct (0x5b88e5cc) JVaultStakingWalletGetStorageData {
    /// Correlation identifier copied into the storage report.
    queryId: uint64
    /// Contract that receives the storage report.
    responseAddress: address
    /// Opaque request tail echoed after the report's state-data reference.
    tail: RemainingBitsAndRefs
}

/// Owner request to claim selected accumulated reward Jettons.
struct (0x78d9f109) JVaultStakingWalletClaimRewards {
    /// Correlation identifier copied into the pool request.
    queryId: uint64
    /// Reward Jettons requested for payout; boolean values are structural placeholders.
    jettonsToClaim: map<address, bool>
}

/// Owner request to schedule Jettons for delayed unstaking.
struct (0x0168d4b7) JVaultStakingWalletUnstakeRequest {
    /// Correlation identifier copied into the pool update request.
    queryId: uint64
    /// Jettons added to the delayed-unstake queue.
    amount: coins
}

/// Owner request to release matured requests and optionally force an instant unstake.
struct (0x499a9262) JVaultStakingWalletUnstakeJettons {
    /// Correlation identifier copied into the pool update request.
    queryId: uint64
    /// Total Jettons requested for release.
    amount: coins
    /// Whether free balance may be unstaked immediately for the configured fee and commission.
    forceUnstake: bool
}

/// Owner request to cancel selected delayed-unstake entries.
struct (0xa4910f1a) JVaultStakingWalletCancelUnstakeRequests {
    /// Correlation identifier copied into the pool update request.
    queryId: uint64
    /// Request timestamps to cancel; boolean values are structural placeholders.
    requests: map<uint32, bool>
}

/// TEP-74-compatible transfer of staked Jettons to another owner.
struct (0x0f8a7ea5) JVaultStakingWalletTransferJettons {
    /// Correlation identifier copied into child messages.
    queryId: uint64
    /// Staked Jettons transferred to the recipient's deterministic wallet.
    amount: coins
    /// New owner of the transferred staking position.
    destination: address
    /// Address receiving excess GRAM, or `addr_none` when omitted.
    responseDestination: address?
    /// Optional custom payload accepted for TEP-74 compatibility and ignored.
    customPayload: cell?
    /// GRAM forwarded with the recipient notification.
    forwardTonAmount: coins
    /// TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Optional response-routing tail appended to a pool reward update request.
struct JVaultStakingWalletForwardedUpdateRewardsTail {
    /// Staking wallet that receives the updated reward dictionary.
    responseAddress: address
    /// Referenced staking owner address used for the second ordered update.
    stakeOwnerAddress: Cell<address>
}

/// Reward/TVL update request emitted to the parent staking pool.
struct (0xf5c5baa3) JVaultStakingWalletRequestUpdateRewards {
    /// Correlation identifier copied into the pool response.
    queryId: uint64
    /// Owner represented by this staking wallet.
    stakeOwnerAddress: address
    /// Lock period identifying this deterministic staking wallet.
    lockPeriod: uint32
    /// Wallet balance used for reward accounting before the change.
    userJettonBalance: coins
    /// Signed change applied to pool TVL.
    tvlChange: int121
    /// Per-reward-Jetton accounting supplied to the pool.
    userRewards: map<address, JVaultStakingWalletRewardInfo>
    /// Jettons transferred back to the owner for an unstake.
    jettonsToUnstake: coins
    /// Commission retained by the pool for an instant unstake.
    commission: coins
    /// Empty for a direct request, or a `JVaultStakingWalletForwardedUpdateRewardsTail` body.
    forwardedTail: RemainingBitsAndRefs
}

/// Transfer notification forwarded to the new owner after stake moves between wallets.
struct (0x7362d09c) JVaultStakingWalletTransferNotification {
    /// Query identifier copied from the staked-Jetton transfer.
    queryId: uint64
    /// Number of staked Jettons transferred.
    amount: coins
    /// Previous owner of the transferred staking position.
    sender: address
    /// Original TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Full persistent-state report emitted on request.
struct (0xaab4a8ef) JVaultStakingWalletReportStorageData {
    /// Correlation identifier copied from the request.
    queryId: uint64
    /// Contract that requested the report.
    requesterAddress: address
    /// Unix timestamp at which the report was built.
    timestamp: uint32
    /// Complete persistent staking-wallet state.
    storage: Cell<JVaultStakingWalletStorage>
    /// Opaque request tail echoed after the storage reference.
    tail: RemainingBitsAndRefs
}

/// Standard excess-value response emitted after updates and bounced messages.
struct (0xd53276db) JVaultStakingWalletExcesses {
    /// Correlation identifier copied from the triggering request, or zero for a bounce.
    queryId: uint64
}

/// Pool request to calculate and transfer selected reward Jettons.
struct (0x44bc1fe3) JVaultStakingWalletSendClaimedRewards {
    /// Correlation identifier copied from the owner request.
    queryId: uint64
    /// Owner represented by this staking wallet.
    stakeOwnerAddress: address
    /// Lock period identifying this deterministic staking wallet.
    lockPeriod: uint32
    /// Current free staked-Jetton balance used for reward accounting.
    userJettonBalance: coins
    /// Per-reward-Jetton accounting supplied to the pool.
    userRewards: map<address, JVaultStakingWalletRewardInfo>
    /// Reward Jettons requested for payout; boolean values are structural placeholders.
    jettonsToClaim: map<address, bool>
}

/// UTF-8 comment emitted after a failed sibling-wallet transfer.
struct (0x00000000) JVaultStakingWalletTextComment {
    /// Remaining UTF-8 comment bytes after the zero opcode.
    text: RemainingBitsAndRefs
}

/// Internal application bodies accepted by the pinned staking-wallet implementation.
type JVaultStakingWalletIncomingMessage =
    | JVaultStakingWalletReceiveJettons
    | JVaultStakingWalletCancelStake
    | JVaultStakingWalletUpdateRewards
    | JVaultStakingWalletDeactivate
    | JVaultStakingWalletSetCode
    | JVaultStakingWalletGetStorageData
    | JVaultStakingWalletClaimRewards
    | JVaultStakingWalletUnstakeRequest
    | JVaultStakingWalletUnstakeJettons
    | JVaultStakingWalletCancelUnstakeRequests
    | JVaultStakingWalletTransferJettons

/// Internal application bodies emitted by the pinned staking-wallet implementation.
type JVaultStakingWalletOutgoingMessage =
    | JVaultStakingWalletReceiveJettons
    | JVaultStakingWalletCancelStake
    | JVaultStakingWalletRequestUpdateRewards
    | JVaultStakingWalletTransferNotification
    | JVaultStakingWalletReportStorageData
    | JVaultStakingWalletExcesses
    | JVaultStakingWalletSendClaimedRewards
    | JVaultStakingWalletTextComment

/// Exit codes thrown explicitly by the pinned staking-wallet implementation.
enum JVaultStakingWalletErrors {
    /// Attached GRAM does not cover compute and downstream message fees.
    OutOfGas = 13
    /// Transferred stake is below the configured minimum deposit.
    LessThanMinimumDeposit = 41
    /// Requested amount exceeds free balance plus eligible queued requests.
    NotEnoughJettons = 46
    /// Sender is not the owner, pool, or expected deterministic sibling wallet.
    IncorrectSender = 50
    /// Another reward or balance update is already in flight.
    HasPendingRequest = 56
    /// Transfer recipient is absent from the configured whitelist.
    UserNotInWhitelist = 57
    /// Pending-unstake dictionary reached its configured entry limit.
    HashmapOverflow = 61
    /// Incoming opcode is not implemented by the staking wallet.
    UnsupportedOperation = 65535
}

/// Return the standard Jetton-compatible wallet data tuple.
get fun get_wallet_data(): JVaultStakingWalletData {
    throw 0;
}

/// Return all public staking-wallet storage fields.
get fun get_storage_data(): JVaultStakingWalletStorageData {
    throw 0;
}
