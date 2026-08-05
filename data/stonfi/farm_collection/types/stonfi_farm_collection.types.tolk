/// STON.fi v3.1 farming collection and minter for soulbound farming positions.
contract StonfiFarmCollection {
    author: "STON.fi"
    version: "3.1"
    description: "STON.fi Farm Collection accepts staking Jettons, mints farming-position NFTs, and accounts rewards for several pools."
    storage: StonfiFarmCollectionStorage
    incomingMessages: StonfiFarmCollectionIncomingMessage
    outgoingMessages: StonfiFarmCollectionOutgoingMessage
    thrownErrors: StonfiFarmCollectionErrors
    forceAbiExport: StonfiFarmStakeForwardPayload | StonfiFarmDepositRewardsForwardPayload
}

/// Exact root storage of the pinned STON.fi v3.1 Farm Collection revision.
struct StonfiFarmCollectionStorage {
    /// Collection-specific identifier used in deterministic item state initialization.
    contractUniqueId: uint64
    /// Number of configured reward pools.
    poolCount: uint8
    /// Lifecycle state: uninitialized 0, operational 1, paused 2, frozen 3, or retired 4.
    status: uint8
    /// Index assigned to the next farming-position NFT.
    nextItemIndex: uint64
    /// Minimum number of seconds a position must remain staked before normal unstaking.
    minStakeTime: uint64
    /// Total staking Jettons held by all active positions, in basic token units.
    currentStakedTokens: coins
    /// True when the custodian may install a pending code upgrade.
    canUpgradeCode: bool
    /// True when the custodian may schedule and execute an arbitrary raw message.
    canSendRawMsg: bool
    /// Collection-owned wallet of the staking Jetton.
    stakingTokenWallet: address
    /// True when the collection owner may schedule a custodian change.
    canChangeCustodian: bool
    /// Account authorized for operational reward withdrawals and delayed actions.
    custodianAddress: address
    /// Accrued accounting data keyed by reward-pool index.
    farmDataAccrued: map<uint8, Cell<StonfiFarmDataAccrued>>
    /// Reward-pool parameters keyed by reward-pool index.
    farmDataParameters: map<uint8, Cell<StonfiFarmDataParametersV31>>
    /// Collection content, item code, and owner stored together by reference.
    collectionData: Cell<StonfiFarmCollectionStaticData>
    /// Delayed custodian, raw-message, and code-upgrade state.
    pendingData: Cell<StonfiFarmCollectionPendingData>
}

/// Accrued reward accounting for one configured Farm pool.
struct StonfiFarmDataAccrued {
    /// Reward amount deposited into this pool, in reward-token nanounits.
    depositedNanorewards: uint150
    /// Accrued reward per one billion basic staking-token units.
    accruedPerUnitNanorewards: uint150
    /// Protocol fee accrued but not yet withdrawn.
    accruedFeeNanorewards: uint150
    /// Rewards already paid to farming positions.
    claimedNanorewards: uint150
    /// Protocol fees already withdrawn.
    claimedFeeNanorewards: uint150
    /// Total reward amount accrued by time-based accounting.
    accruedNanorewards: uint150
    /// Unix timestamp of the last accrual update.
    lastUpdateTime: uint64
}

/// Reward configuration for one pool in the exact v3.1 storage layout.
struct StonfiFarmDataParametersV31 {
    /// Protocol fee in basis points with denominator 10000.
    adminFee: uint16
    /// Rewards accrued during 24 hours, in reward-token nanounits.
    nanorewardsPer24h: uint150
    /// True when any account may deposit rewards for this pool.
    unrestrictedDepositRewards: bool
    /// Collection-owned wallet of this pool's reward Jetton.
    rewardTokenWallet: address
    /// True when the collection owner may change `adminFee`.
    canChangeFee: bool
    /// Pool lifecycle state used by reward accounting.
    status: uint8
}

/// Referenced static NFT collection configuration.
struct StonfiFarmCollectionStaticData {
    /// Off-chain collection content cell.
    collectionContent: cell
    /// Exact code installed in newly minted Farm NFT items.
    nftItemCode: cell
    /// Collection owner that controls Farm configuration.
    ownerAddress: address
}

/// Referenced delayed-action state; zero timestamps mean no action is pending.
struct StonfiFarmCollectionPendingData {
    /// Unix timestamp at which a pending custodian change may be confirmed.
    changeCustodianTime: uint64
    /// Unix timestamp at which a pending raw message may be sent.
    sendRawMessageTime: uint64
    /// Unix timestamp at which a pending code upgrade may be confirmed.
    codeUpgradeTime: uint64
    /// Proposed custodian, or `addr_none` when no change is pending.
    newCustodianAddress: address?
    /// Complete pending outbound message, or an empty cell when none is pending.
    pendingMessage: cell
    /// Pending contract code, or an empty cell when none is pending.
    newCode: cell
    /// Pending replacement storage, or an empty cell when none is pending.
    newStorage: cell
}

/// Farm NFT request to settle an unstaked position.
struct (0xa1312496) StonfiFarmCollectionUnstakeRequest {
    /// Query identifier propagated through settlement and Jetton transfers.
    queryId: uint64
    /// Farming-position NFT index.
    itemIndex: uint64
    /// Unix timestamp at which the position was created.
    stakeDate: uint64
    /// Number of staking Jettons held by the position.
    stakedTokens: coins
    /// Position owner that receives staking Jettons and rewards.
    ownerAddress: address
    /// Optional direct dictionary-root reference with previous reward checkpoints.
    claimedPerUnitRoot: cell?
}

/// Farm NFT request to claim rewards without unstaking.
struct (0x39656584) StonfiFarmCollectionClaimRequest {
    /// Query identifier propagated through reward transfers and callback.
    queryId: uint64
    /// Farming-position NFT index.
    itemIndex: uint64
    /// Number of staking Jettons held by the position.
    stakedTokens: coins
    /// Position owner that receives rewards.
    ownerAddress: address
    /// True to claim from every pool; false to select `poolIndex`.
    claimAll: bool
    /// Selected reward-pool index when `claimAll` is false.
    poolIndex: uint8
    /// Optional direct dictionary-root reference with previous reward checkpoints.
    claimedPerUnitRoot: cell?
}

/// Jetton wallet notification for a stake or reward deposit.
struct (0x7362d09c) StonfiFarmCollectionJettonTransferNotification {
    /// Query identifier copied from the Jetton transfer.
    queryId: uint64
    /// Received staking or reward Jettons, in basic token units.
    amount: coins
    /// Original Jetton sender reported by the notifying wallet.
    senderAddress: address
    /// Referenced STON.fi Farm stake or reward-deposit payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Forward payload that stakes transferred Jettons and mints a Farm NFT.
struct (0x6ec9dc65) StonfiFarmStakeForwardPayload {
    /// Optional farming-position owner; `addr_none` selects the original Jetton sender.
    ownerAddress: address?
}

/// Forward payload that deposits transferred reward Jettons into one Farm pool.
struct (0xe8e8e46c) StonfiFarmDepositRewardsForwardPayload {
    /// Reward-pool index receiving the transferred Jettons.
    poolIndex: uint8
    /// Optional GRAM excess recipient; `addr_none` selects the original Jetton sender.
    excessesAddress: address?
}

/// Custodian request to withdraw unallocated rewards from one pool.
struct (0x82ee3aec) StonfiFarmCollectionWithdrawRewards {
    /// Query identifier copied into the Jetton transfer.
    queryId: uint64
    /// Reward-pool index.
    poolIndex: uint8
    /// Reward amount in whole Jettons; zero withdraws the maximum available amount.
    amount: coins
}

/// Collection-owner initialization request for the exact v3.1 revision.
struct (0xc674e474) StonfiFarmCollectionInitialize {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Collection-owned staking Jetton wallet.
    stakingTokenWallet: address
    /// Whether later custodian changes are permitted.
    canChangeCustodian: bool
    /// Whether delayed arbitrary raw messages are permitted.
    canSendRawMsg: bool
    /// Minimum stake duration in seconds.
    minStakeTime: uint64
    /// Initial custodian; `addr_none` selects the collection owner.
    custodianAddress: address?
}

/// Collection-owner request to create a new reward pool.
struct (0x2e3034ef) StonfiFarmCollectionCreatePool {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Collection-owned reward Jetton wallet for the new pool.
    rewardTokenWallet: address
    /// Rewards emitted per 24 hours in whole reward tokens before nanounit scaling.
    rewardsPer24h: coins
    /// True when reward deposits are not restricted to the custodian.
    unrestrictedDepositRewards: bool
    /// True when the pool fee may be changed later.
    canChangeFee: bool
    /// Protocol fee in basis points with denominator 10000.
    adminFee: uint16
}

/// Collection-owner request to update the minimum stake duration.
struct (0xf7929fbe) StonfiFarmCollectionUpdateStakeTime {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// New minimum stake duration in seconds.
    minStakeTime: uint64
}

/// Confirmed governance operation whose exact tail remains available to low-level callers.
struct (0x7844c9d6) StonfiFarmCollectionUpdateAccruedValues {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed governance operation that changes the collection lifecycle state.
struct (0x7331888c) StonfiFarmCollectionChangeStatus {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed governance operation that changes one pool's reward rate.
struct (0xbc3b7682) StonfiFarmCollectionChangeRate {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed governance operation that changes one pool's status.
struct (0xb6eba1d8) StonfiFarmCollectionChangePoolStatus {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed governance operation that changes one pool's protocol fee.
struct (0x476c06a8) StonfiFarmCollectionChangeFee {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed governance operation that withdraws accrued protocol fees.
struct (0x9d5d1457) StonfiFarmCollectionClaimFee {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed delayed custodian-change request.
struct (0x53b5e0e7) StonfiFarmCollectionChangeCustodian {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed delayed code-upgrade request.
struct (0x8fc13086) StonfiFarmCollectionCodeUpgrade {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirmed delayed arbitrary-message request.
struct (0xbc2d127b) StonfiFarmCollectionScheduleRawMessage {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Exact operation-specific fields retained without structural interpretation.
    payload: RemainingBitsAndRefs
}

/// Confirm a matured custodian change.
struct (0xb2b4d0f7) StonfiFarmCollectionConfirmChangeCustodian {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Reject a pending custodian change.
struct (0x0f235998) StonfiFarmCollectionRejectChangeCustodian {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Send a matured pending arbitrary message.
struct (0x382b4467) StonfiFarmCollectionConfirmRawMessage {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Reject a pending arbitrary message.
struct (0xcfeda65d) StonfiFarmCollectionRejectRawMessage {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Confirm a matured code upgrade.
struct (0x267513cc) StonfiFarmCollectionConfirmCodeUpgrade {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Reject a pending code upgrade.
struct (0xadfc18b0) StonfiFarmCollectionRejectCodeUpgrade {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Owner-only request to retain the reserve and return excess GRAM.
struct (0x42a0fb43) StonfiFarmCollectionResetGas {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Internal message bodies accepted by the exact Farm Collection revision.
type StonfiFarmCollectionIncomingMessage =
    | StonfiFarmCollectionUnstakeRequest
    | StonfiFarmCollectionClaimRequest
    | StonfiFarmCollectionJettonTransferNotification
    | StonfiFarmCollectionWithdrawRewards
    | StonfiFarmCollectionInitialize
    | StonfiFarmCollectionCreatePool
    | StonfiFarmCollectionUpdateStakeTime
    | StonfiFarmCollectionUpdateAccruedValues
    | StonfiFarmCollectionChangeStatus
    | StonfiFarmCollectionChangeRate
    | StonfiFarmCollectionChangePoolStatus
    | StonfiFarmCollectionChangeFee
    | StonfiFarmCollectionClaimFee
    | StonfiFarmCollectionChangeCustodian
    | StonfiFarmCollectionCodeUpgrade
    | StonfiFarmCollectionScheduleRawMessage
    | StonfiFarmCollectionConfirmChangeCustodian
    | StonfiFarmCollectionRejectChangeCustodian
    | StonfiFarmCollectionConfirmRawMessage
    | StonfiFarmCollectionRejectRawMessage
    | StonfiFarmCollectionConfirmCodeUpgrade
    | StonfiFarmCollectionRejectCodeUpgrade
    | StonfiFarmCollectionResetGas

/// Callback that initializes a newly deployed Farm NFT position.
struct (0xbba6cbca) StonfiFarmCollectionInitializeNft {
    /// Query identifier propagated from the stake transfer.
    queryId: uint64
    /// Number of staking Jettons assigned to the new position.
    stakedTokens: coins
    /// Owner assigned to the new farming position.
    ownerAddress: address
    /// Initial reward-per-unit checkpoints keyed by pool index.
    claimedPerUnit: map<uint8, uint150>
}

/// Callback that completes a Farm NFT reward claim.
struct (0xc70d3ca5) StonfiFarmCollectionClaimCompleted {
    /// Query identifier propagated from the Farm NFT claim request.
    queryId: uint64
    /// Updated reward-per-unit checkpoints keyed by pool index.
    claimedPerUnit: map<uint8, uint150>
}

/// Callback that completes a Farm NFT unstake operation.
struct (0x2d673d98) StonfiFarmCollectionUnstakeCompleted {
    /// Query identifier propagated from the Farm NFT unstake request.
    queryId: uint64
    /// Final reward-per-unit checkpoints keyed by pool index.
    claimedPerUnit: map<uint8, uint150>
}

/// Jetton transfer emitted for staking-token returns, rewards, and protocol fees.
struct (0x0f8a7ea5) StonfiFarmCollectionJettonTransfer {
    /// Query identifier propagated from the triggering Farm operation.
    queryId: uint64
    /// Jetton amount transferred, in basic token units.
    amount: coins
    /// Account that receives the Jettons.
    destination: address
    /// Optional address that receives excess GRAM from the Jetton wallet.
    responseDestination: address?
    /// Optional custom payload forwarded to the recipient wallet.
    customPayload: cell?
    /// GRAM amount forwarded with the Jetton notification.
    forwardTonAmount: coins
    /// Inline-or-referenced Jetton forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response.
struct (0xd53276db) StonfiFarmCollectionExcesses {
    /// Query identifier propagated from the completed request.
    queryId: uint64
}

/// Internal message bodies emitted by the exact Farm Collection code.
type StonfiFarmCollectionOutgoingMessage =
    | StonfiFarmCollectionInitializeNft
    | StonfiFarmCollectionClaimCompleted
    | StonfiFarmCollectionUnstakeCompleted
    | StonfiFarmCollectionJettonTransfer
    | StonfiFarmCollectionExcesses

/// Full v3 farming collection state returned by `get_farming_minter_data`.
struct StonfiFarmCollectionFarmingDataReply {
    /// Index assigned to the next farming-position NFT.
    nextItemIndex: int
    /// Current collection lifecycle state.
    status: int
    /// Number of configured reward pools.
    poolCount: int
    /// Total staking Jettons held by active positions, in basic token units.
    currentStakedTokens: int
    /// Collection-specific identifier used in item state initialization.
    contractUniqueId: int
    /// Minimum normal stake duration, in seconds.
    minStakeTime: int
    /// Collection-owned wallet of the staking Jetton.
    stakingTokenWallet: any_address
    /// Custodian authorized for operational reward withdrawals and delayed actions.
    custodianAddress: any_address
    /// True when the owner may schedule a custodian change.
    canChangeCustodian: bool
    /// True when the custodian may schedule an arbitrary raw message.
    canSendRawMsg: bool
    /// Accrued reward accounting keyed by pool index.
    farmDataAccrued: map<uint8, Cell<StonfiFarmDataAccrued>>
    /// Reward-pool configuration keyed by pool index.
    farmDataParameters: map<uint8, Cell<StonfiFarmDataParametersV31>>
}

/// Semantic version returned by `get_version`.
struct StonfiFarmCollectionVersionReply {
    /// Major interface version.
    major: int
    /// Minor interface version.
    minor: int
    /// Development channel label compiled into the contract.
    development: string
}

/// Standard NFT collection state returned by `get_collection_data`.
struct StonfiFarmCollectionDataReply {
    /// Index assigned to the next farming-position NFT.
    nextItemIndex: int
    /// Off-chain collection metadata content.
    collectionContent: cell
    /// Collection owner that controls Farm configuration.
    ownerAddress: any_address
}

/// Delayed governance state returned by `get_pending_data`.
struct StonfiFarmCollectionPendingDataReply {
    /// Unix timestamp at which a pending custodian change may be confirmed.
    changeCustodianTime: int
    /// Unix timestamp at which a pending raw message may be sent.
    sendRawMessageTime: int
    /// Unix timestamp at which a pending code upgrade may be confirmed.
    codeUpgradeTime: int
    /// Proposed custodian, or `addr_none` when no change is pending.
    newCustodianAddress: any_address
    /// Complete pending outbound message, or an empty cell when none is pending.
    pendingMessage: cell
    /// Pending contract code, or an empty cell when none is pending.
    newCode: cell
    /// Pending replacement storage, or an empty cell when none is pending.
    newStorage: cell
}

/// Exit codes observed in the exact Farm Collection revision.
enum StonfiFarmCollectionErrors {
    /// An address is outside the base workchain required by this contract.
    InvalidWorkchain = 20085
    /// Attached GRAM does not cover the required reserve and downstream messages.
    InsufficientAttachedValue = 20083
    /// A token, reward, or withdrawal amount is invalid for the operation.
    InvalidAmount = 20087
    /// A supplied account address fails the operation's address constraints.
    InvalidAddress = 20088
    /// The incoming sender is not authorized for the operation.
    InvalidSender = 20095
    /// A Farm NFT sender does not match the deterministic item address.
    InvalidItemAddress = 20401
    /// Current collection or pool status does not allow the operation.
    InvalidStatus = 20803
    /// The requested optional governance action is disabled.
    ActionDisabled = 20805
    /// A required reward-pool dictionary entry is absent.
    MissingDictionaryEntry = 20902
    /// The requested reward-pool index is outside the configured range.
    InvalidPoolIndex = 20954
    /// A reward-pool key conflicts with the encoded or expected pool index.
    InconsistentPoolIndex = 20955
    /// Incoming opcode is not implemented by the exact contract revision.
    UnknownOpcode = 65535
}

/// Return the exact major, minor, and development label compiled into the contract.
get fun get_version(): StonfiFarmCollectionVersionReply {
    throw 0;
}

/// Return collection state and both reward-pool dictionaries.
get fun get_farming_minter_data(): StonfiFarmCollectionFarmingDataReply {
    throw 0;
}

/// Return the full metadata cell for one NFT item's individual content.
get fun get_nft_content(itemIndex: int, individualNftContent: cell): cell {
    throw 0;
}

/// Derive the deterministic Farm NFT address for an item index.
get fun get_nft_address_by_index(itemIndex: int): address {
    throw 0;
}

/// Return the exact code installed in newly minted Farm NFT items.
get fun get_nft_item_code(): cell {
    throw 0;
}

/// Return the standard NFT collection index, content, and owner tuple.
get fun get_collection_data(): StonfiFarmCollectionDataReply {
    throw 0;
}

/// Return timestamps and payloads for delayed governance actions.
get fun get_pending_data(): StonfiFarmCollectionPendingDataReply {
    throw 0;
}
