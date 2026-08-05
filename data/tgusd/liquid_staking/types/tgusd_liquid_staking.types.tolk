/// Torch Finance pool that stakes tgUSD and issues stgUSD shares.
contract TgUsdLiquidStaking {
    author: "Torch Finance"
    version: "126ba782"
    description: "tgUSD staking pool with vested rewards, delayed unstaking, and stgUSD share accounting."
    storage: TgUsdLiquidStakingStorage
    incomingMessages: TgUsdLiquidStakingIncomingMessage
    outgoingMessages: TgUsdLiquidStakingOutgoingMessage
    forceAbiExport: TgUsdLiquidStakingForceExport
    emittedEvents: TgUsdLiquidStakingEvent
    thrownErrors: TgUsdLiquidStakingErrors
}

/// Stake parameters carried by a tgUSD transfer notification forward-payload reference.
struct (0xd4c3fdc0) TgUsdStakeForwardPayload {
    /// stgUSD recipient, or `addr_none` to mint shares to the tgUSD sender.
    recipient: address?
}

/// Marker carried by a manager's tgUSD transfer when principal is returned to the pool.
struct (0x095663da) TgUsdDeallocateStakedForwardPayload {}

/// Reward provenance carried by a tgUSD transfer notification forward-payload reference.
struct (0x5fe15c80) TgUsdSupplyRewardForwardPayload {
    /// Referenced collateral-asset descriptor whose yield produced the reward.
    collateralAsset: cell
    /// Collateral amount associated with the reward, in that asset's elementary units.
    collateralAmount: coins
    /// Administrator or engine custodial wallet that receives a halted-operation refund.
    source: address
    /// Custodial wallet that received the reward-generating collateral.
    custodialWallet: address
}

/// Supported tgUSD transfer-notification forward payloads.
type TgUsdTransferForwardPayload =
    | TgUsdStakeForwardPayload
    | TgUsdDeallocateStakedForwardPayload
    | TgUsdSupplyRewardForwardPayload

/// stgUSD burn marker that requests creation or update of an unstake account.
struct (0x51656704) TgUsdRequestUnstakeForwardPayload {}

/// tgUSD Jetton wallet notification consumed by the staking pool.
struct (0x7362d09c) TgUsdTransferNotification {
    /// Jetton transfer query identifier.
    queryId: uint64
    /// tgUSD amount received by the pool in elementary units.
    jettonAmount: coins
    /// Previous tgUSD owner or protocol reward source.
    jettonSender: address
    /// Required referenced operation payload; absence is rejected with `ForwardPayloadNull`.
    forwardPayload: Cell<TgUsdTransferForwardPayload>?
}

/// Administrator or manager request to transfer pool-owned tgUSD to a recipient.
struct (0xe4692b7c) TgUsdAllocateStaked {
    /// Request identifier propagated into the Jetton transfer.
    queryId: uint64
    /// tgUSD principal amount allocated from the pool.
    stakedAmount: coins
    /// tgUSD recipient, or `addr_none` to use the authorized sender.
    recipient: address?
    /// Optional referenced payload forwarded with the tgUSD transfer notification.
    customPayload: cell?
}

/// Unstake-account request to release cooled-down tgUSD to its final recipient.
struct (0xfa3ec18e) TgUsdWithdrawInternal {
    /// Request identifier propagated into the payout or rollback.
    queryId: uint64
    /// Owner whose deterministic unstake account sent the request.
    unstaker: address
    /// tgUSD amount requested for withdrawal.
    unstakedAmount: coins
    /// Address that receives released tgUSD.
    recipient: address
}

/// stgUSD master callback containing the burn amount and unstake request payload.
struct (0x85306c8c) TgUsdExtraBurnInfo {
    /// Burn request identifier.
    queryId: uint64
    /// stgUSD owner whose shares were burned.
    unstaker: address
    /// Burned stgUSD share amount in elementary units.
    jettonAmount: coins
    /// Required referenced unstake operation payload.
    customPayload: Cell<TgUsdRequestUnstakeForwardPayload>?
}

/// Request for the current tgUSD-to-stgUSD conversion quote.
struct (0x984d8449) TgUsdProvideCurrentQuote {
    /// Quote request identifier copied into the reply.
    queryId: uint64
    /// Address that receives the quote reply.
    recipient: address
    /// Optional opaque payload returned unchanged in the quote reply.
    customPayload: cell?
}

/// Administrator request to return excess GRAM while retaining the minimum storage balance.
struct (0x53a9192c) TgUsdResetGas {
    /// Administrator-selected request identifier.
    queryId: uint64
    /// GRAM recipient, or `addr_none` to use the administrator.
    recipient: address?
}

/// Administrator request to change the unstake cooldown duration.
struct (0xaa2eb3a8) TgUsdUpdateCooldownPeriod {
    /// Administrator-selected request identifier.
    queryId: uint64
    /// New cooldown duration in seconds.
    cooldownPeriod: uint32
}

/// Administrator request to change the reward vesting duration.
struct (0xe9a09a01) TgUsdUpdateVestingPeriod {
    /// Administrator-selected request identifier.
    queryId: uint64
    /// New reward vesting duration in seconds.
    vestingPeriod: uint32
}

/// Administrator request to replace the per-user unstake-account implementation code.
struct (0x658ce2c0) TgUsdUpdateUnstakeAccountCode {
    /// Administrator-selected request identifier.
    queryId: uint64
    /// Referenced replacement unstake-account code cell.
    unstakeAccountCode: cell
}

/// Administrator request that bypasses cooldown checks in a selected unstake account.
struct (0xeb3a8986) TgUsdForceWithdraw {
    /// Request identifier copied into the child withdrawal message.
    queryId: uint64
    /// Existing unstake account instructed to withdraw.
    unstakeAccount: address
}

/// Administrator request that halts user-facing staking operations.
struct (0xa8d19f57) TgUsdHalt {
    /// Administrator-selected request identifier.
    queryId: uint64
}

/// Administrator request that resumes user-facing staking operations.
struct (0xe2241ebe) TgUsdUnhalt {
    /// Administrator-selected request identifier.
    queryId: uint64
}

/// Two-step administration request; the same body is forwarded to the stgUSD master.
struct (0x6501f354) TgUsdChangeAdmin {
    /// Administrator-selected request identifier.
    queryId: uint64
    /// Pending administrator address.
    nextAdmin: address?
}

/// Pending-administrator request to assume control of the staking pool.
struct (0xfb88e119) TgUsdClaimAdmin {
    /// Pending-administrator request identifier.
    queryId: uint64
}

/// Administrator request to make a controlled call through the stgUSD Jetton master.
struct (0xadc0579b) TgUsdCallToJettonMaster {
    /// Request identifier copied into the forwarded call.
    queryId: uint64
    /// Destination requested from the Jetton master.
    to: address
    /// Nanograms attached by the Jetton master to the destination call.
    tonAmount: coins
    /// Referenced opaque message body forwarded by the Jetton master.
    masterMessage: cell
}

/// Administrator request to change the stgUSD Jetton master's administrator.
struct (0x7ba4e3ab) TgUsdChangeJettonMasterAdmin {
    /// Request identifier copied into the master administration message.
    queryId: uint64
    /// New stgUSD Jetton master administrator.
    newAdmin: address?
}

/// Administrator request to replace staking code, storage, or both.
struct (0x2508d66a) TgUsdUpgradeContract {
    /// Administrator-selected upgrade identifier.
    queryId: uint64
    /// Optional referenced replacement persistent data.
    newData: cell?
    /// Optional referenced replacement contract code.
    newCode: cell?
}

/// Administrator request to upgrade a selected unstake account.
struct (0x240961d7) TgUsdUpgradeUnstakeAccount {
    /// Upgrade request identifier propagated to the child contract.
    queryId: uint64
    /// Existing unstake account to upgrade.
    unstakeAccount: address
    /// Optional referenced replacement child storage.
    newData: cell?
}

/// Administrator request to upgrade the stgUSD Jetton master with direct code/data refs.
struct (0xe5661dc8) TgUsdUpgradeJettonMaster {
    /// Upgrade request identifier propagated to the Jetton master.
    queryId: uint64
    /// Referenced replacement Jetton master data.
    newData: cell
    /// Referenced replacement Jetton master code.
    newCode: cell
}

/// Administrator request whose remaining body is forwarded as new stgUSD metadata content.
struct (0x8de1b72e) TgUsdChangeJettonMasterContentRequest {
    /// Request identifier copied into the stgUSD content-update body.
    queryId: uint64
    /// Opaque metadata URI/content tail forwarded to the stgUSD Jetton master.
    newContent: RemainingBitsAndRefs
}

/// One-time administrator initialization of staking managers, timings, and child code.
struct (0xd372158c) TgUsdTopUp {
    /// Initialization query identifier copied into wallet-discovery requests.
    queryId: uint64
    /// stgUSD share Jetton master.
    stgUsdJettonMaster: address
    /// Manager authorized to allocate pool tgUSD.
    stakedManager: address
    /// Initial reward vesting duration in seconds.
    vestingPeriod: uint32
    /// Initial unstake cooldown duration in seconds.
    cooldownPeriod: uint32
    /// Referenced common child-contract base code.
    baseCode: cell
    /// Referenced initial unstake-account implementation code.
    unstakeAccountCode: cell
}

/// Jetton-master wallet-discovery response consumed during staking initialization.
struct (0xd1735400) TgUsdTakeWalletAddress {
    /// Wallet-discovery query identifier.
    queryId: uint64
    /// Deterministic Jetton wallet address, or `addr_none` when unavailable.
    walletAddress: address?
    /// Optional referenced owner address included by discoverable Jetton masters.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the tgUSD staking dispatcher.
type TgUsdLiquidStakingIncomingMessage =
    | TgUsdTransferNotification
    | TgUsdAllocateStaked
    | TgUsdWithdrawInternal
    | TgUsdExtraBurnInfo
    | TgUsdProvideCurrentQuote
    | TgUsdResetGas
    | TgUsdUpdateCooldownPeriod
    | TgUsdUpdateVestingPeriod
    | TgUsdUpdateUnstakeAccountCode
    | TgUsdForceWithdraw
    | TgUsdHalt
    | TgUsdUnhalt
    | TgUsdChangeAdmin
    | TgUsdClaimAdmin
    | TgUsdCallToJettonMaster
    | TgUsdChangeJettonMasterAdmin
    | TgUsdUpgradeContract
    | TgUsdUpgradeUnstakeAccount
    | TgUsdUpgradeJettonMaster
    | TgUsdChangeJettonMasterContentRequest
    | TgUsdTopUp
    | TgUsdTakeWalletAddress

/// Jetton transfer emitted for allocation, withdrawal, or halted-operation refunds.
struct (0x0f8a7ea5) TgUsdJettonTransfer {
    /// Query identifier copied from the triggering staking request.
    queryId: uint64
    /// tgUSD amount transferred in elementary units.
    jettonAmount: coins
    /// New tgUSD owner.
    destination: address
    /// Address that receives excess GRAM.
    responseDestination: address
    /// Optional custom payload; staking sends encode this as absent.
    customPayload: cell?
    /// Nanograms forwarded to the destination's notification handler.
    forwardTonAmount: coins
    /// Optional referenced notification payload or comment.
    forwardPayload: cell?
}

/// Jetton internal-transfer body referenced by an stgUSD mint request.
struct (0x178d4519) TgUsdJettonInternalTransfer {
    /// Query identifier copied from the stake or refund request.
    queryId: uint64
    /// stgUSD share amount minted in elementary units.
    jettonAmount: coins
    /// Staking contract recorded as the mint origin.
    senderAddress: address
    /// Address that receives excess GRAM from the Jetton wallet.
    responseAddress: address
    /// Nanograms forwarded by the receiving stgUSD wallet.
    forwardTonAmount: coins
    /// Optional referenced recipient notification payload.
    forwardPayload: cell?
}

/// stgUSD mint request emitted for a stake or halted-unstake refund.
struct (0x642b7d07) TgUsdJettonMint {
    /// Query identifier copied into the referenced internal transfer.
    queryId: uint64
    /// Owner whose stgUSD wallet receives the minted shares.
    recipient: address
    /// Nanograms supplied to the stgUSD wallet deployment/transfer flow.
    walletTonAmount: coins
    /// Referenced internal-transfer body containing share amount and notification data.
    internalTransfer: Cell<TgUsdJettonInternalTransfer>
}

/// Failure reply that restores an unstake-account amount after payout rejection.
struct (0x1fcaa449) TgUsdRollbackWithdraw {
    /// Query identifier copied from the failed withdrawal.
    queryId: uint64
    /// tgUSD amount restored to the child account.
    unstakedAmount: coins
}

/// Current conversion quote returned to a caller-selected recipient.
struct (0x80ed6c2e) TgUsdTakeCurrentQuote {
    /// Quote request identifier.
    queryId: uint64
    /// Active vested tgUSD principal at the quote timestamp.
    totalActiveStake: coins
    /// Issued stgUSD shares at the quote timestamp.
    totalShares: coins
    /// Unix timestamp at which the quote was produced.
    timestamp: uint32
    /// Optional referenced caller payload returned unchanged.
    customPayload: cell?
}

/// Withdrawal command sent to a deterministic unstake account.
struct (0x4ca83dc8) TgUsdWithdraw {
    /// Withdrawal request identifier.
    queryId: uint64
    /// Recipient override; forced withdrawals encode `addr_none`.
    recipient: address?
}

/// Child-contract installation body used when creating an unstake account.
struct (0xe07784e5) TgUsdInstall {
    /// Unstake request identifier.
    queryId: uint64
    /// Referenced unstake-account implementation code.
    newCode: cell
    /// Referenced initialized unstake-account storage.
    newData: cell
    /// Optional referenced post-install callback payload.
    callbackPayload: cell?
}

/// Opcode-zero text comment emitted after successful unstake-account deployment.
struct (0x00000000) TgUsdComment {
    /// UTF-8 comment bytes stored in the remaining body.
    text: RemainingBitsAndRefs
}

/// Discoverable-Jetton request for the staking contract's wallet address.
struct (0x2c76b973) TgUsdProvideWalletAddress {
    /// Initialization query identifier.
    queryId: uint64
    /// Staking contract address whose wallet is requested.
    ownerAddress: address
    /// Whether the Jetton master should include the owner address in its response.
    includeOwnerAddress: bool
}

/// Controlled Jetton-master call body emitted from an administrator request.
struct (0x235caf52) TgUsdCallTo {
    /// Administrator request identifier.
    queryId: uint64
    /// Final call destination.
    to: address
    /// Nanograms attached to the final call.
    tonAmount: coins
    /// Referenced opaque final-call body.
    masterMessage: cell
}

/// stgUSD metadata update emitted from an administrator request.
struct (0xcb862902) TgUsdChangeJettonMasterContent {
    /// Administrator request identifier.
    queryId: uint64
    /// Opaque metadata URI/content bytes forwarded from the request body.
    newContent: RemainingBitsAndRefs
}

/// Internal body-bearing messages emitted by tgUSD staking send sites.
type TgUsdLiquidStakingOutgoingMessage =
    | TgUsdJettonTransfer
    | TgUsdJettonMint
    | TgUsdRollbackWithdraw
    | TgUsdTakeCurrentQuote
    | TgUsdWithdraw
    | TgUsdInstall
    | TgUsdComment
    | TgUsdProvideWalletAddress
    | TgUsdCallTo
    | TgUsdChangeAdmin
    | TgUsdUpgradeContract
    | TgUsdChangeJettonMasterContent

/// stgUSD master upgrade uses direct refs despite sharing the generic upgrade opcode.
struct (0x2508d66a) TgUsdJettonMasterUpgrade {
    /// Administrator request identifier.
    queryId: uint64
    /// Direct reference to replacement Jetton master data.
    newData: cell
    /// Direct reference to replacement Jetton master code.
    newCode: cell
}

/// Totals stored by reference in a staking event.
struct TgUsdStakedEventTotals {
    /// Total issued stgUSD shares after the stake.
    totalShares: coins
    /// Total pool tgUSD after the stake.
    totalStaked: coins
    /// Unallocated pool tgUSD after the stake.
    remainingStaked: coins
}

/// External log emitted after staking tgUSD and minting stgUSD shares.
struct (0xa2c713f1) TgUsdStakedEvent {
    /// stgUSD shares minted for this stake.
    mintedShares: coins
    /// tgUSD principal supplied by the staker.
    stakedAmount: coins
    /// Previous tgUSD owner.
    staker: address
    /// stgUSD share recipient.
    recipient: address
    /// Referenced pool totals after the operation.
    totals: Cell<TgUsdStakedEventTotals>
}

/// External log emitted after burning stgUSD and scheduling tgUSD withdrawal.
struct (0xb7c4a217) TgUsdUnstakedEvent {
    /// stgUSD shares burned.
    burnedShares: coins
    /// tgUSD principal scheduled for withdrawal.
    unstakedAmount: coins
    /// Share owner that requested unstaking.
    unstaker: address
    /// Unix timestamp after which withdrawal is available.
    cooldownEnd: uint32
    /// Total issued shares after the burn.
    totalShares: coins
    /// Total pool tgUSD after reserving the withdrawal.
    totalStaked: coins
    /// tgUSD reserved for all pending unstake requests.
    lockedForUnstake: coins
}

/// External log emitted after a withdrawal succeeds or is rolled back.
struct (0xb40329ca) TgUsdWithdrawProcessedEvent {
    /// Status: `0` success, `1` halted, or `2` insufficient liquid stake.
    status: uint2
    /// Owner of the unstake account.
    unstaker: address
    /// tgUSD amount processed.
    unstakedAmount: coins
    /// Requested tgUSD recipient.
    recipient: address
    /// Unallocated tgUSD remaining after processing.
    remainingStaked: coins
    /// tgUSD still reserved for pending unstake requests.
    lockedForUnstake: coins
}

/// Reward provenance stored by reference in a reward-supplied event.
struct TgUsdRewardSuppliedEventDetails {
    /// Referenced collateral-asset descriptor.
    collateralAsset: cell
    /// Collateral amount associated with this reward.
    collateralAmount: coins
    /// tgUSD reward amount supplied.
    rewardAmount: coins
    /// Administrator or engine source of the reward.
    source: address
    /// Custodial wallet holding the reward-generating collateral.
    custodialWallet: address
}

/// External log emitted after a new tgUSD reward enters the vesting schedule.
struct (0xc513df24) TgUsdRewardSuppliedEvent {
    /// Total pool tgUSD including the new reward.
    totalStaked: coins
    /// Unallocated tgUSD including the new reward.
    remainingStaked: coins
    /// Combined unvested reward amount.
    vestingReward: coins
    /// Unix timestamp at which the new vesting schedule starts.
    vestingStart: uint32
    /// Reward vesting duration in seconds.
    vestingPeriod: uint32
    /// Referenced collateral and reward provenance.
    details: Cell<TgUsdRewardSuppliedEventDetails>
}

/// External log emitted after allocating tgUSD to a manager-selected recipient.
struct (0x6f62ba25) TgUsdStakedAllocatedEvent {
    /// Administrator or staked manager that requested allocation.
    manager: address
    /// tgUSD amount allocated.
    stakedAmount: coins
    /// Unallocated tgUSD remaining in the pool.
    remainingStaked: coins
    /// Recipient of allocated tgUSD.
    recipient: address
}

/// External log emitted when a manager returns allocated tgUSD to the pool.
struct (0xaf8fc45b) TgUsdStakedDeallocatedEvent {
    /// Manager that returned tgUSD.
    manager: address
    /// tgUSD amount returned.
    stakedAmount: coins
    /// Unallocated tgUSD after the return.
    remainingStaked: coins
}

/// External log emitted when the contract replies with a conversion quote.
struct (0x08a92aee) TgUsdCurrentQuoteProvidedEvent {
    /// Active vested tgUSD at the quote timestamp.
    totalActiveStake: coins
    /// Issued stgUSD shares at the quote timestamp.
    totalShares: coins
    /// Unix timestamp when the quote was emitted.
    timestamp: uint32
    /// Quote requester.
    sender: address
    /// Address that received the quote body.
    recipient: address
}

/// External log emitted after changing the unstake cooldown.
struct (0x52eadaae) TgUsdCooldownPeriodUpdatedEvent {
    /// Administrator that changed the cooldown.
    admin: address
    /// New cooldown duration in seconds.
    cooldownPeriod: uint32
}

/// External log emitted after changing reward vesting duration.
struct (0xec0d399d) TgUsdVestingPeriodUpdatedEvent {
    /// Administrator that changed the vesting duration.
    admin: address
    /// New vesting duration in seconds.
    vestingPeriod: uint32
}

/// External log emitted during the one-time staking top-up.
struct (0xa46dbccd) TgUsdStakingDeployedEvent {
    /// Manager authorized to allocate pool tgUSD.
    stakedManager: address
    /// Initial reward vesting duration in seconds.
    vestingPeriod: uint32
    /// Initial unstake cooldown duration in seconds.
    cooldownPeriod: uint32
    /// Initial staking administrator.
    admin: address
}

/// External log emitted after resolving a contract-owned Jetton wallet.
struct (0x36fad736) TgUsdStakingWalletAddressTakenEvent {
    /// tgUSD or stgUSD Jetton master that returned the wallet.
    jettonMaster: address
    /// Resolved contract-owned Jetton wallet.
    jettonWallet: address?
}

/// External log emitted when a pending administrator claims control.
struct (0xd08409e4) TgUsdAdminChangedEvent {
    /// Administrator that claimed control.
    newAdmin: address
    /// Previous administrator.
    oldAdmin: address
}

/// External log emitted when the administrator halts staking operations.
struct (0x86c6c5cb) TgUsdHaltedEvent {
    /// Administrator that halted the contract.
    admin: address
}

/// External log emitted when the administrator resumes staking operations.
struct (0x93c5742d) TgUsdUnhaltedEvent {
    /// Administrator that resumed the contract.
    admin: address
}

/// External log bodies emitted by tgUSD staking state transitions.
type TgUsdLiquidStakingEvent =
    | TgUsdStakedEvent
    | TgUsdUnstakedEvent
    | TgUsdWithdrawProcessedEvent
    | TgUsdRewardSuppliedEvent
    | TgUsdStakedAllocatedEvent
    | TgUsdStakedDeallocatedEvent
    | TgUsdCurrentQuoteProvidedEvent
    | TgUsdCooldownPeriodUpdatedEvent
    | TgUsdVestingPeriodUpdatedEvent
    | TgUsdStakingDeployedEvent
    | TgUsdStakingWalletAddressTakenEvent
    | TgUsdAdminChangedEvent
    | TgUsdHaltedEvent
    | TgUsdUnhaltedEvent

/// Additional nested bodies and the opcode-ambiguous Jetton-master upgrade.
type TgUsdLiquidStakingForceExport =
    | TgUsdTransferForwardPayload
    | TgUsdRequestUnstakeForwardPayload
    | TgUsdJettonInternalTransfer
    | TgUsdJettonMasterUpgrade

/// Staking balances and reward-vesting state stored in the first referenced cell.
struct TgUsdLiquidStakingStakeInfo {
    /// Total tgUSD attributed to the pool, including rewards, in elementary units.
    totalStaked: coins
    /// Total issued stgUSD shares in elementary units.
    totalShares: coins
    /// tgUSD currently available for unstaking or allocation, in elementary units.
    remainingStaked: coins
    /// Reward amount released linearly over the vesting period, in elementary units.
    vestingReward: coins
    /// Reward vesting duration, in seconds.
    vestingPeriod: uint32
    /// Unix timestamp at which the current reward vesting period started.
    vestingStart: uint32
    /// tgUSD reserved for pending unstake requests, in elementary units.
    lockedForUnstake: coins
}

/// Jetton masters used for tgUSD principal and stgUSD shares.
struct TgUsdLiquidStakingJettonMasters {
    /// tgUSD Jetton master accepted as the staking asset.
    tgUsdJettonMaster: address?
    /// stgUSD Jetton master that mints and burns staking shares.
    stgUsdJettonMaster: address?
}

/// Deterministic Jetton wallets used by the staking contract.
struct TgUsdLiquidStakingJettonWallets {
    /// Contract-owned tgUSD wallet that receives stakes and rewards.
    tgUsdJettonWallet: address?
    /// Contract-owned stgUSD wallet used by unstaking flows.
    stgUsdJettonWallet: address?
}

/// Code cells used to derive and deploy per-user unstake accounts.
struct TgUsdLiquidStakingContractCodes {
    /// Shared child-contract base code included in address derivation.
    baseCode: cell
    /// Unstake-account implementation code installed for each user.
    unstakeAccountCode: cell
}

/// Complete persistent state of the tgUSD staking contract.
struct TgUsdLiquidStakingStorage {
    /// Current administrator address.
    admin: address?
    /// Pending administrator allowed to claim administration.
    nextAdmin: address?
    /// Manager allowed to allocate and deallocate staked tgUSD.
    stakedManager: address?
    /// Whether user-facing staking operations are halted.
    isHalted: bool
    /// Delay between an unstake request and withdrawal, in seconds.
    cooldownPeriod: uint32
    /// Referenced staking balances and vesting state.
    stakeInfo: Cell<TgUsdLiquidStakingStakeInfo>
    /// Referenced tgUSD and stgUSD Jetton master addresses.
    jettonMasters: Cell<TgUsdLiquidStakingJettonMasters>
    /// Referenced contract-owned Jetton wallet addresses.
    jettonWallets: Cell<TgUsdLiquidStakingJettonWallets>
    /// Referenced child-contract code cells.
    contractCodes: Cell<TgUsdLiquidStakingContractCodes>
}

/// Active-stake numerator and issued-share denominator used for tgUSD/stgUSD conversion.
struct TgUsdLiquidStakingConversionRatio {
    /// Vested active tgUSD stake after subtracting the currently unvested reward.
    totalActiveStake: coins
    /// Total issued stgUSD shares in elementary units.
    totalShares: coins
}

/// Returns active tgUSD stake and total stgUSD shares as a conversion-ratio pair.
get fun conversionRatio(): TgUsdLiquidStakingConversionRatio {
    throw 0;
}

/// Derives the deterministic unstake-account address for a user.
get fun unstakeAccount(unstaker: any_address): any_address {
    throw 0;
}

/// Exit codes explicitly used by the deployed tgUSD staking contract.
enum TgUsdLiquidStakingErrors {
    /// The transferred Jetton amount is not positive.
    NonPositiveJettonAmount = 1000
    /// A required Jetton forward payload is absent.
    ForwardPayloadNull = 1001
    /// The sender is not the current administrator.
    NotAdmin = 1002
    /// The sender is not a supported Jetton master.
    NotSupportedJettonMaster = 1003
    /// The sender is not the configured tgUSD Jetton wallet.
    NotSupportedJettonWallet = 1004
    /// The requested operation is disabled while the contract is halted.
    ContractHalted = 1007
    /// A required custom payload is absent.
    CustomPayloadNull = 1013
    /// The attached GRAM value does not cover the required fees.
    NotEnoughFee = 1027
    /// Share conversion produced a non-positive amount.
    InvalidShare = 1028
    /// The requested unstake amount is invalid.
    InvalidUnstakedAmount = 1029
    /// The sender is not the deterministic unstake account.
    NotUnstakeAccount = 1031
    /// Available staked tgUSD is insufficient for the operation.
    NotEnoughStaked = 1032
    /// The sender is neither the administrator nor the staked-funds manager.
    NotSupportedAdminOrStakedManager = 1035
    /// The sender is not the pending administrator.
    NotNextAdmin = 1037
    /// The supplied upgrade code or data is invalid.
    InvalidUpgrade = 1038
    /// The supplied cell is identical to the currently stored cell.
    IdenticalCell = 1039
    /// The operation requires the contract to be halted.
    ContractNotHalted = 1040
    /// The supplied configuration value equals the current value.
    SameValue = 1042
    /// The sender is neither the tgUSD Jetton master nor the administrator.
    NotTgUsdJettonMasterOrAdmin = 1047
    /// Reward vesting is still active.
    VestingActive = 1050
    /// Initial top-up has already been completed.
    AlreadyTopUp = 1051
    /// The requested cooldown exceeds the supported maximum.
    CooldownPeriodTooLong = 1052
    /// The requested vesting duration exceeds the supported maximum.
    VestingPeriodTooLong = 1053
    /// The incoming opcode is not supported.
    WrongOperation = 65535
}
