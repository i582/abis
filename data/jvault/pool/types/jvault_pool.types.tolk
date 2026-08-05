/// JVault staking pool interface for the pinned mainnet implementation.
contract JVaultPool {
    author: "JVault"
    description: "JVault staking pool storage, NFT/getter surface, staking flows, rewards accounting, and administrative messages."
    storage: JVaultPoolStorage
    incomingMessages: JVaultPoolIncomingMessage
    outgoingMessages: JVaultPoolOutgoingMessage
    thrownErrors: JVaultPoolErrors
    forceAbiExport: JVaultPoolStakeJettonsPayload
        | JVaultPoolAddRewardsPayload
        | JVaultPoolForwardedUpdateRewardsTail
}

/// One scheduled reward distribution stored under a reward Jetton wallet.
struct JVaultPoolRewardDeposit {
    /// Reward amount distributed per day in Jetton basic units.
    distributionSpeed: coins
    /// Unix timestamp at which this distribution starts.
    startTime: uint32
    /// Unix timestamp at which this distribution ends.
    endTime: uint32
}

/// Cumulative reward state for one reward Jetton wallet.
struct JVaultPoolRewardJettonInfo {
    /// Fixed-point cumulative rewards per weighted staked Jetton.
    distributedRewards: uint256
    /// Active distributions keyed by their unsigned 32-bit sequence index.
    rewardDeposits: map<uint32, JVaultPoolRewardDeposit>
}

/// Staking constraints and reward settings for one supported lock period.
struct JVaultPoolLockPeriodInfo {
    /// Current staked balance assigned to this lock period.
    currentTvl: coins
    /// Maximum staked balance accepted for this lock period.
    tvlLimit: coins
    /// Reward multiplier in thousandths, where 1000 means 1x.
    rewardMultiplier: uint16
    /// Deposit commission in protocol basis points.
    depositCommission: uint16
    /// Instant-unstake commission in protocol basis points.
    unstakeCommission: uint16
    /// Jetton minter used to derive staking-wallet children for this lock period.
    minterAddress: address
}

/// Per-user cumulative and unclaimed reward accounting for one reward Jetton.
struct JVaultPoolUserRewardInfo {
    /// Last cumulative reward value accounted for the user.
    distributedRewards: uint256
    /// Reward Jettons accrued but not yet transferred to the user.
    unclaimedRewards: coins
}

/// Referenced mutable accounting state stored by a JVault staking pool.
struct JVaultPoolAccounting {
    /// Staked Jettons without lock-period reward multipliers.
    tvl: coins
    /// Staked Jettons after applying lock-period reward multipliers.
    tvlWithMultipliers: coins
    /// Minimum accepted staking deposit in Jetton basic units.
    minDeposit: coins
    /// Maximum accepted staking deposit in Jetton basic units.
    maxDeposit: coins
    /// Reward state keyed by reward Jetton wallet address.
    rewardJettons: map<address, JVaultPoolRewardJettonInfo>
    /// Number of configured reward Jettons.
    rewardJettonsCount: uint8
    /// Number of active reward distributions across all reward Jettons.
    rewardsDepositsCount: uint8
    /// Supported staking configurations keyed by lock duration in seconds.
    lockPeriods: map<uint32, JVaultPoolLockPeriodInfo>
    /// Accounts allowed to stake; an empty map disables whitelist membership.
    whitelist: map<address, bool>
    /// Fixed GRAM fee charged for an instant unstake.
    unstakeFee: coins
    /// Protocol commissions collected by the pool.
    collectedCommissions: coins
    /// Commission rate charged when rewards are added, in protocol basis points.
    rewardsCommission: uint16
    /// Stored pool implementation version.
    version: uint16
}

/// Persistent state of a deployed JVault staking pool.
struct JVaultPoolStorage {
    /// Whether the pool completed initialization and installed its staking Jetton wallet.
    initialized: bool
    /// Pool index assigned by the JVault factory.
    poolId: uint32
    /// Factory administrator that receives protocol commissions.
    adminAddress: address
    /// Account that created this pool.
    creatorAddress: address
    /// Pool-owned Jetton wallet holding the staked asset.
    lockWalletAddress: address
    /// Optional referenced TEP-64 NFT item content cell.
    nftContent: cell?
    /// Code used to derive and deploy staking-wallet children.
    stakeWalletCode: cell
    /// Referenced accounting, limits, rewards, and commission state.
    accounting: Cell<JVaultPoolAccounting>
}

/// Tuple returned by `get_storage_data`.
struct JVaultPoolStorageData {
    /// Whether pool initialization completed.
    initialized: bool
    /// Factory-assigned pool index.
    poolId: int
    /// Factory administrator address.
    adminAddress: any_address
    /// Pool creator address.
    creatorAddress: any_address
    /// Code used for staking-wallet children.
    stakeWalletCode: cell
    /// Pool-owned Jetton wallet holding the staked asset.
    lockWalletAddress: any_address
    /// Staked Jettons without multipliers.
    tvl: int
    /// Staked Jettons with reward multipliers.
    tvlWithMultipliers: int
    /// Minimum accepted deposit.
    minDeposit: int
    /// Maximum accepted deposit.
    maxDeposit: int
    /// Raw optional reward-Jetton dictionary returned as a TVM stack cell.
    rewardJettons: cell?
    /// Number of configured reward Jettons.
    rewardJettonsCount: int
    /// Number of active reward distributions.
    rewardsDepositsCount: int
    /// Raw optional lock-period dictionary returned as a TVM stack cell.
    lockPeriods: cell?
    /// Raw optional account-whitelist dictionary returned as a TVM stack cell.
    whitelist: cell?
    /// Fixed GRAM fee for instant unstaking.
    unstakeFee: int
    /// Accumulated protocol commissions.
    collectedCommissions: int
    /// Reward commission rate in protocol basis points.
    rewardsCommission: int
    /// Pool implementation version.
    version: int
}

/// Standard NFT data returned for the pool item.
struct JVaultPoolNftData {
    /// Whether the pool item completed initialization.
    initialized: bool
    /// Factory-assigned NFT item index.
    itemIndex: int
    /// Factory/collection stack address.
    collectionAddress: any_address
    /// Pool creator stack address.
    ownerAddress: any_address
    /// Item content with the pool index appended to the `uri` attribute, or null.
    content: cell?
}

/// Payload nested in a TEP-74 transfer notification when a user stakes Jettons.
struct (0xe3a06989) JVaultPoolStakeJettonsPayload {
    /// Lock duration selected by the staking user, in seconds.
    lockPeriod: uint32
    /// Empty when no referrer is supplied, or a `Maybe ^MsgAddress` tail when present.
    referrerTail: RemainingBitsAndRefs
}

/// Payload nested in a TEP-74 transfer notification when the creator funds rewards.
struct (0xdb16ac95) JVaultPoolAddRewardsPayload {
    /// Unix timestamp at which reward distribution starts.
    startTime: uint32
    /// Unix timestamp at which reward distribution ends.
    endTime: uint32
}

/// TEP-74 transfer notification accepted from a configured staking or reward Jetton wallet.
struct (0x7362d09c) JVaultPoolTransferNotification {
    /// Query identifier copied from the originating Jetton transfer.
    queryId: uint64
    /// Number of Jettons transferred to the pool wallet.
    amount: coins
    /// Logical sender recorded by the notifying Jetton wallet.
    sender: address
    /// TEP-74 `Either Cell ^Cell` tail containing a staking or reward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Creator request to add reward Jetton wallet addresses to the pool.
struct (0x10676ae7) JVaultPoolAddRewardJettons {
    /// Correlation identifier copied into the excess response.
    queryId: uint64
    /// Reward Jetton wallets keyed by address; boolean values are structural placeholders.
    wallets: map<address, bool>
}

/// Creator request to transfer collected staking commissions.
struct (0xbca8f067) JVaultPoolClaimCommissions {
    /// Correlation identifier copied into the Jetton transfer.
    queryId: uint64
}

/// Creator request to replace the pool item's TEP-64 content dictionary.
struct (0x0ec29200) JVaultPoolChangeContent {
    /// Correlation identifier accepted for the common management envelope.
    queryId: uint64
    /// Optional referenced TEP-64 item content cell.
    content: cell?
}

/// One-time response that installs the pool-owned staking Jetton wallet address.
struct (0xd1735400) JVaultPoolTakeWalletAddress {
    /// Correlation identifier accepted from the Jetton discovery exchange.
    queryId: uint64
    /// Discovered Jetton wallet address owned by the pool.
    walletAddress: address
}

/// Request to report the complete persistent pool data to another contract.
struct (0x5b88e5cc) JVaultPoolGetStorageData {
    /// Correlation identifier copied into the storage report.
    queryId: uint64
    /// Contract that receives the storage report.
    responseAddress: address
    /// Opaque request tail echoed after the report's state-data reference.
    tail: RemainingBitsAndRefs
}

/// Administrator request to withdraw all GRAM not needed for the pool reserve.
struct (0x37726bdb) JVaultPoolWithdrawTon {
    /// Correlation identifier copied into the excess response.
    queryId: uint64
}

/// Administrator request to withdraw arbitrary Jettons held by a wallet.
struct (0x11c09682) JVaultPoolWithdrawJetton {
    /// Correlation identifier copied into the Jetton transfer.
    queryId: uint64
    /// Jetton wallet instructed to send the withdrawal.
    jettonWalletAddress: address
    /// Jetton amount transferred to the administrator.
    amount: coins
}

/// Administrator request forwarded to a child wallet to deactivate it.
struct (0x4b14c485) JVaultPoolDeactivateWallet {
    /// Correlation identifier forwarded to the child wallet.
    queryId: uint64
    /// Child wallet that receives the deactivation request.
    walletAddress: address
}

/// Administrator request to forward an arbitrary referenced body.
struct (0xa47d989c) JVaultPoolSendAnyMessage {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// Contract that receives the arbitrary body.
    destination: address
    /// Complete body cell forwarded without interpretation.
    payload: cell
}

/// Administrator request to replace code and optionally replace persistent data.
struct (0xe2d2d211) JVaultPoolSetCode {
    /// Correlation identifier copied into the excess response.
    queryId: uint64
    /// Replacement executable code stored as a mandatory reference.
    code: cell
    /// Optional trailing data reference; an empty tail preserves current data.
    optionalData: RemainingBitsAndRefs
}

/// Request from a deterministic referrer wallet to calculate and send its rewards.
struct (0xb80e71d2) JVaultPoolSendReferrerRewards {
    /// Correlation identifier copied into reward transfers and the update response.
    queryId: uint64
    /// Owner represented by the sending referrer wallet.
    referrerAddress: address
    /// Weighted invited-user balance used to calculate rewards.
    inviteesBalance: coins
    /// Per-reward-Jetton accounting supplied by the referrer wallet.
    userRewards: map<address, JVaultPoolUserRewardInfo>
    /// Reward Jettons requested for payout; boolean values are structural placeholders.
    jettonsToClaim: map<address, bool>
}

/// Request from a deterministic referrer wallet to update referral reward accounting.
struct (0x55c35b40) JVaultPoolRequestUpdateReferrer {
    /// Correlation identifier copied into the update response.
    queryId: uint64
    /// Owner represented by the sending referrer wallet.
    referrerAddress: address
    /// Weighted invited-user balance before applying the requested change.
    inviteesBalance: coins
    /// Signed weighted-balance change.
    balanceChange: int121
    /// Per-reward-Jetton accounting supplied by the referrer wallet.
    userRewards: map<address, JVaultPoolUserRewardInfo>
    /// Address that receives the resulting referral update.
    responseAddress: address
}

/// Staking-wallet notification that rolls back a failed stake.
struct (0x9eada1d9) JVaultPoolCancelStake {
    /// Correlation identifier copied into the refund transfer.
    queryId: uint64
    /// Owner represented by the sending staking wallet.
    stakeOwnerAddress: address
    /// Lock duration identifying the deterministic staking wallet.
    lockPeriod: uint32
    /// Net staked Jettons removed from the lock-period TVL.
    stakedAmount: coins
    /// Deposit commission added back to the refund.
    depositCommission: coins
}

/// Optional extension appended to a forwarded staking-wallet reward update.
struct JVaultPoolForwardedUpdateRewardsTail {
    /// Staking wallet that receives the updated reward dictionary.
    responseAddress: address
    /// Referenced staking owner address used for reward and referrer accounting.
    stakeOwnerAddress: Cell<address>
}

/// Staking-wallet request to update rewards and optionally complete an unstake.
struct (0xf5c5baa3) JVaultPoolRequestUpdateRewards {
    /// Correlation identifier copied into downstream transfers and responses.
    queryId: uint64
    /// Owner represented by the sending staking wallet.
    stakeOwnerAddress: address
    /// Lock duration identifying the deterministic staking wallet.
    lockPeriod: uint32
    /// User's staked Jetton balance before the requested change.
    userJettonBalance: coins
    /// Signed change to pool TVL.
    tvlChange: int121
    /// Per-reward-Jetton accounting supplied by the staking wallet.
    userRewards: map<address, JVaultPoolUserRewardInfo>
    /// Jettons transferred back to the owner for an unstake.
    jettonsToUnstake: coins
    /// Commission retained by the pool for the unstake.
    commission: coins
    /// Empty for a direct request, or a `JVaultPoolForwardedUpdateRewardsTail` body.
    forwardedTail: RemainingBitsAndRefs
}

/// Staking-wallet request to pay selected accumulated reward Jettons.
struct (0x44bc1fe3) JVaultPoolSendClaimedRewards {
    /// Correlation identifier copied into reward transfers and the update response.
    queryId: uint64
    /// Owner represented by the sending staking wallet.
    stakeOwnerAddress: address
    /// Lock duration identifying the deterministic staking wallet.
    lockPeriod: uint32
    /// User's weighted staking balance used to calculate rewards.
    userJettonBalance: coins
    /// Per-reward-Jetton accounting supplied by the staking wallet.
    userRewards: map<address, JVaultPoolUserRewardInfo>
    /// Reward Jettons requested for payout; boolean values are structural placeholders.
    jettonsToClaim: map<address, bool>
}

/// Standard Jetton transfer emitted for commission refunds, unstakes, and rewards.
struct (0x0f8a7ea5) JVaultPoolJettonTransfer {
    /// Correlation identifier copied from the triggering request.
    queryId: uint64
    /// Jetton amount transferred by the addressed Jetton wallet.
    amount: coins
    /// Logical Jetton recipient.
    destination: address
    /// Address receiving any excess GRAM, or `addr_none` when omitted.
    responseDestination: address?
    /// Optional custom payload; JVault emits no custom payload in these flows.
    customPayload: cell?
    /// GRAM forwarded with the Jetton notification.
    forwardTonAmount: coins
    /// Optional referenced comment or application payload.
    forwardPayload: Cell<RemainingBitsAndRefs>?
}

/// Initialization body sent when the pool deploys a deterministic staking wallet.
struct (0xd68a4ac1) JVaultPoolReceiveJettons {
    /// Correlation identifier copied from the staking Jetton transfer.
    queryId: uint64
    /// Minimum allowed wallet balance after the stake.
    minDeposit: coins
    /// Maximum allowed wallet balance after the stake.
    maxDeposit: coins
    /// Instant-unstake commission in protocol basis points.
    unstakeCommission: uint16
    /// Fixed GRAM fee charged for an instant unstake.
    unstakeFee: coins
    /// Pool whitelist copied into the staking wallet.
    whitelist: map<address, bool>
    /// Net Jettons credited to the staking wallet.
    stakedAmount: coins
    /// Deposit commission retained by the pool.
    depositCommission: coins
}

/// Storage report emitted in response to `JVaultPoolGetStorageData`.
struct (0xaab4a8ef) JVaultPoolReportStorageData {
    /// Correlation identifier copied from the request.
    queryId: uint64
    /// Contract that requested the report.
    requesterAddress: address
    /// Unix timestamp at which the report was built.
    timestamp: uint32
    /// Complete persistent pool state.
    storage: Cell<JVaultPoolStorage>
    /// Opaque request tail echoed after the state reference.
    tail: RemainingBitsAndRefs
}

/// Standard excess-value response emitted after management operations.
struct (0xd53276db) JVaultPoolExcesses {
    /// Correlation identifier copied from the triggering request.
    queryId: uint64
}

/// Deactivation message forwarded unchanged to a selected child wallet.
struct (0x4b14c485) JVaultPoolForwardDeactivateWallet {
    /// Correlation identifier copied from the administrator request.
    queryId: uint64
}

/// Initialization body sent to a deterministic invitee wallet.
struct (0x383411ea) JVaultPoolInviteeSetData {
    /// Deployment correlation identifier; the pool emits zero.
    queryId: uint64
    /// Factory-assigned pool index used by the referral subsystem.
    poolId: uint32
    /// Optional referenced referrer address.
    referrerAddress: Cell<address>?
    /// Optional referrer-wallet code installed when a referrer is present.
    referrerWalletCode: cell?
}

/// Balance-change notification sent to a deterministic invitee wallet.
struct (0x55c35b40) JVaultPoolInviteeRequestUpdateReferrer {
    /// Correlation identifier copied from the staking-wallet request.
    queryId: uint64
    /// Factory-assigned pool index used by the referral subsystem.
    poolId: uint32
    /// Signed weighted-balance change for the invitee.
    balanceChange: int121
}

/// Updated referral accounting sent back to a referrer or response wallet.
struct (0x076ee4e0) JVaultPoolUpdateReferrer {
    /// Correlation identifier copied from the referral request.
    queryId: uint64
    /// Factory-assigned pool index used by the referral subsystem.
    poolId: uint32
    /// Signed weighted-balance change applied to the referrer.
    balanceChange: int121
    /// Updated per-reward-Jetton accounting.
    userRewards: map<address, JVaultPoolUserRewardInfo>
    /// Account associated with the response.
    responseAddress: address
}

/// Updated reward accounting returned to a staking wallet.
struct (0xae9307ce) JVaultPoolUpdateRewards {
    /// Correlation identifier copied from the staking-wallet request.
    queryId: uint64
    /// Updated per-reward-Jetton accounting.
    userRewards: map<address, JVaultPoolUserRewardInfo>
    /// Owner represented by the staking wallet.
    stakeOwnerAddress: address
}

/// UTF-8 comment body used by deployment notices and fee transfers.
struct (0x00000000) JVaultPoolTextComment {
    /// Remaining UTF-8 comment bytes after the zero opcode.
    text: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the pinned pool implementation.
type JVaultPoolIncomingMessage =
    | JVaultPoolTransferNotification
    | JVaultPoolAddRewardJettons
    | JVaultPoolClaimCommissions
    | JVaultPoolChangeContent
    | JVaultPoolTakeWalletAddress
    | JVaultPoolGetStorageData
    | JVaultPoolWithdrawTon
    | JVaultPoolWithdrawJetton
    | JVaultPoolDeactivateWallet
    | JVaultPoolSendAnyMessage
    | JVaultPoolSetCode
    | JVaultPoolSendReferrerRewards
    | JVaultPoolRequestUpdateReferrer
    | JVaultPoolCancelStake
    | JVaultPoolRequestUpdateRewards
    | JVaultPoolSendClaimedRewards

/// Internal message bodies emitted by the pinned pool implementation.
type JVaultPoolOutgoingMessage =
    | JVaultPoolJettonTransfer
    | JVaultPoolReceiveJettons
    | JVaultPoolReportStorageData
    | JVaultPoolExcesses
    | JVaultPoolForwardDeactivateWallet
    | JVaultPoolInviteeSetData
    | JVaultPoolInviteeRequestUpdateReferrer
    | JVaultPoolUpdateReferrer
    | JVaultPoolUpdateRewards
    | JVaultPoolTextComment

/// Exit codes thrown by the pinned pool implementation.
enum JVaultPoolErrors {
    /// Attached GRAM does not cover the required downstream messages and compute.
    OutOfGas = 13
    /// Staking amount is below the configured minimum deposit.
    LessThanMinimumDeposit = 41
    /// Net staking amount exceeds the configured maximum deposit.
    MoreThanMaximumDeposit = 42
    /// Transfer notification came from an unexpected Jetton wallet.
    IncorrectJetton = 43
    /// Staking would exceed the selected lock-period TVL limit.
    TvlLimitExceeded = 44
    /// Requested lock period is not configured.
    IncorrectLockPeriod = 47
    /// Sender is not the expected creator, administrator, or deterministic child wallet.
    IncorrectSender = 50
    /// Reward distribution timestamps are not ordered or start in the past.
    IncorrectDistributionPeriod = 58
    /// One-time Jetton-wallet initialization was requested twice.
    AlreadyInitialized = 59
    /// A stake was attempted before the pool installed its Jetton wallet.
    NotInitialized = 60
    /// A reward, whitelist, or distribution dictionary exceeded its configured bound.
    HashmapOverflow = 61
    /// A supplied address is outside the base workchain.
    WrongWorkchain = 333
    /// Incoming opcode is not implemented by the pool.
    UnsupportedOperation = 65535
}

/// Return standard NFT identity, collection, owner, and content data for the pool item.
get fun get_nft_data(): JVaultPoolNftData {
    throw 0;
}

/// Return the optional SBT authority stack address; this implementation returns `addr_none`.
get fun get_authority_address(): any_address {
    throw 0;
}

/// Return the SBT revocation timestamp; this implementation returns zero.
get fun get_revoked_time(): int {
    throw 0;
}

/// Return all public pool storage fields in their source-defined order.
get fun get_storage_data(): JVaultPoolStorageData {
    throw 0;
}

/// Derive a staking-wallet address, or return `addr_none` for a rejected owner or lock period.
get fun get_stake_wallet_address(ownerAddress: address, lockPeriod: int): any_address {
    throw 0;
}
