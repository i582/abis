/// Shared interface of the DeDust CPMM v2 PoolV1 and PoolV2 revisions.
contract DedustV2Cpmm {
    author: "DeDust"
    version: "2.0"
    description: "DeDust CPMM v2 Pool is a liquidity pool where users swap an asset pair and LPs provide liquidity for constant-product market making."
    storage: DedustV2CpmmStorage
    incomingMessages: DedustV2CpmmIncomingMessage
    outgoingMessages: DedustV2CpmmOutgoingMessage
    thrownErrors: Errors
    forceAbiExport: DedustV2CpmmPaymentPayload
        | DedustV2CpmmPayJetton
        | DedustV2CpmmPoolConfig
        | DedustV2CpmmPoolFees
        | DedustV2CpmmPoolUpdatedState
        | DedustV2CpmmSwapFees
        | DedustV2CpmmExtendedPayoutConfig
        | DedustV2CpmmBasicPayoutConfig
}

/// Pool has not started initialization.
struct (0b00) DedustV2CpmmStatusUninitialized {}

/// Pool is initializing under the specified initiator.
struct (0b01) DedustV2CpmmStatusInitializing {
    /// Address that initiated pool initialization.
    initiatorAddress: address
}

/// Pool initialization is complete.
struct (0b10) DedustV2CpmmStatusInitialized {}

/// Persistent pool lifecycle state.
type DedustV2CpmmStatus =
    | DedustV2CpmmStatusUninitialized
    | DedustV2CpmmStatusInitializing
    | DedustV2CpmmStatusInitialized

/// Root persistent storage shared by CPMM v2 PoolV1 and PoolV2.
struct DedustV2CpmmStorage {
    /// Referenced immutable asset, fee, activation, and reward configuration.
    config: Cell<DedustV2CpmmPoolConfig>
    /// Referenced protocol, creator, and LP fee accumulators.
    fees: Cell<DedustV2CpmmPoolFees>
    /// Referenced controller and wallet-resolution registries.
    extra: Cell<DedustV2CpmmPoolExtra>
    /// Active reward programs indexed by a two-bit reward slot.
    rewards: DedustV2CpmmPoolRewards
    /// Inline pool lifecycle state.
    status: DedustV2CpmmStatus
    /// Deposit gate flag returned by `get_pool_data`.
    depositActive: bool
    /// Swap gate flag returned by `get_pool_data`.
    swapActive: bool
    /// Current LP liquidity amount.
    liquidity: coins
    /// Current reserve of asset X.
    reserveX: coins
    /// Current reserve of asset Y.
    reserveY: coins
}

/// Structured stack reply returned by the deployed `get_pool_data` getter.
struct DedustV2CpmmPoolDataReply {
    /// Pool status enum returned as a signed 8-bit value.
    status: int8
    /// Deposit gate flag.
    depositActive: bool
    /// Swap gate flag.
    swapActive: bool
    /// Asset X address; native GRAM is represented by `addr_none`.
    assetX: address?
    /// Asset Y address; native GRAM is represented by `addr_none`.
    assetY: address?
    /// Optional dictionary cell keyed by asset-address hashes.
    walletsByAssets: cell?
    /// Optional dictionary cell keyed by wallet-address hashes.
    assetsByWallets: cell?
    /// Optional dictionary cell keyed by wallet-address hashes.
    walletsResolutions: cell?
    /// Pool base fee in basis points.
    baseFeeBps: int32
    /// Current reserve of asset X.
    reserveX: int
    /// Current reserve of asset Y.
    reserveY: int
    /// Current LP liquidity amount.
    liquidity: int
    /// Protocol fee balance for asset X.
    protocolFeeX: int
    /// Protocol fee balance for asset Y.
    protocolFeeY: int
    /// Creator fee balance for asset X.
    creatorFeeX: int
    /// Creator fee balance for asset Y.
    creatorFeeY: int
    /// Accumulated fee per unit of liquidity for asset X.
    xFeePerLiquidity: int
    /// Accumulated fee per unit of liquidity for asset Y.
    yFeePerLiquidity: int
    /// Optional dictionary cell keyed by two-bit reward identifiers.
    rewards: cell?
}

/// CPMM v2 payment payload variants carried by `PayNative` or `PayJetton`.
type DedustV2CpmmPaymentPayload =
    | DedustV2CpmmSwapPayload
    | DedustV2CpmmDepositPayload
    | DedustV2CpmmFundRewardPayload

/// Payment payload requesting a swap.
struct (0xc442500f) DedustV2CpmmSwapPayload {
    /// Minimum acceptable output amount.
    minimalAmountOut: coins
    /// Unix timestamp after which the swap must not execute.
    deadline: uint40
    /// Optional next route step for multi-hop swaps.
    next: Cell<DedustV2CpmmSwapStep>?
    /// Optional partner fee configuration.
    partnerConfig: DedustV2CpmmPartnerConfig?
    /// Optional referrer fee configuration.
    referrerConfig: DedustV2CpmmReferrerConfig?
}

/// Payment payload requesting a liquidity deposit.
struct (0xc9a015da) DedustV2CpmmDepositPayload {
    /// Expected total amount of asset X.
    amountX: coins
    /// Expected total amount of asset Y.
    amountY: coins
    /// Minimum acceptable minted liquidity.
    minimalLiquidity: coins
    /// Share of minted liquidity to lock.
    lockedLiquidityShare: uint16
}

/// Payment payload funding a reward distribution.
struct (0x2eb87df9) DedustV2CpmmFundRewardPayload {
    /// Reward distribution end timestamp.
    till: uint40
}

/// Forward payload used by jetton transfer notifications.
struct (0xcbc33949) DedustV2CpmmPayJetton {
    /// Operation-specific payment payload.
    paymentPayload: cell
    /// Payout configuration for fulfillment and rejection paths.
    payoutConfig: Cell<DedustV2CpmmExtendedPayoutConfig>
}

/// Single multi-hop swap step.
struct DedustV2CpmmSwapStep {
    /// Pool that executes this route step.
    pool: address
    /// Minimum acceptable output amount for this step.
    minimalAmountOut: coins
    /// Unix timestamp after which this step must not execute.
    deadline: uint40
    /// Optional next route step.
    next: Cell<DedustV2CpmmSwapStep>?
}

/// Partner attribution configuration.
struct DedustV2CpmmPartnerConfig {
    /// Partner identifier.
    partnerId: uint256
    /// Partner fee in basis points.
    partnerFeeBPS: uint16
}

/// Referrer attribution configuration.
struct DedustV2CpmmReferrerConfig {
    /// Referrer identifier.
    referrerId: uint256
    /// Referrer fee in basis points.
    referrerFeeBPS: uint16
}

/// Strategy for swap fee collection.
enum DedustV2CpmmFeeIn: uint2 {
    /// Fees are collected in the input asset.
    Both = 0b00
    /// Fees are collected in asset X.
    AssetX = 0b01
    /// Fees are collected in asset Y.
    AssetY = 0b10
}

/// Asset identifier used by CPMM v2; `addr_none` denotes native GRAM.
struct DedustV2CpmmAsset {
    /// Jetton root address, or `addr_none` for the native asset.
    value: address?
}

/// Unsigned Q120.120 fixed-point accumulator encoded as `varuint32`.
struct DedustV2CpmmQ120X120 {
    /// Raw fixed-point numerator with 120 fractional bits.
    value: varuint32
}

/// Pool immutable configuration.
struct DedustV2CpmmPoolConfig {
    /// Asset X identifier.
    assetX: DedustV2CpmmAsset
    /// Asset Y identifier.
    assetY: DedustV2CpmmAsset
    /// Pool creator address.
    creatorAddress: address?
    /// Base swap fee in basis points.
    baseFeeBPS: uint16
    /// Creator fee in basis points.
    creatorFeeBPS: uint16
    /// Optional deposit activation rule.
    depositActivation: Cell<DedustV2CpmmActivation>?
    /// Optional swap activation rule.
    swapActivation: Cell<DedustV2CpmmActivation>?
    /// Fee collection strategy.
    feeIn: DedustV2CpmmFeeIn
    /// Custom jetton wallet resolvers.
    customResolvers: map<uint256, address>
    /// Allowed reward configurations by reward index.
    allowedRewards: map<uint2, DedustV2CpmmRewardConfig>
}

/// Time-based activation rule.
struct (0x01) DedustV2CpmmActivationTime {
    /// Unix timestamp from which the operation is active.
    activeSince: uint40
}

/// Initiator-based activation rule.
struct (0x02) DedustV2CpmmActivationInitiator {
    /// Address that can trigger activation.
    initiatorAddress: address
}

/// Pool activation rule.
type DedustV2CpmmActivation =
    | DedustV2CpmmActivationTime
    | DedustV2CpmmActivationInitiator

/// Reward program configuration.
struct DedustV2CpmmRewardConfig {
    /// Reward asset identifier.
    asset: DedustV2CpmmAsset
    /// Maximum reward duration in seconds.
    maxDuration: uint40
}

/// Active reward programs by reward index.
struct DedustV2CpmmPoolRewards {
    /// Reward state keyed by a two-bit reward slot.
    entries: map<uint2, DedustV2CpmmPoolReward>
}

/// Active reward state.
struct DedustV2CpmmPoolReward {
    /// Remaining distribution time in seconds.
    remainingTime: uint40
    /// Remaining reward budget.
    remainingBudget: coins
    /// Accumulated reward per liquidity token in Q120.120 form.
    rewardsPerToken: DedustV2CpmmQ120X120
    /// Last reward state update timestamp.
    lastUpdate: uint40
}

/// Accumulated pool fee state.
struct DedustV2CpmmPoolFees {
    /// Accumulated protocol fees in asset X.
    protocolFeeX: coins
    /// Accumulated protocol fees in asset Y.
    protocolFeeY: coins
    /// Accumulated creator fees in asset X.
    creatorFeeX: coins
    /// Accumulated creator fees in asset Y.
    creatorFeeY: coins
    /// Accumulated LP fee per token in asset X, encoded as Q120.120.
    xFeePerToken: DedustV2CpmmQ120X120
    /// Accumulated LP fee per token in asset Y, encoded as Q120.120.
    yFeePerToken: DedustV2CpmmQ120X120
}

/// Wallet and asset lookup dictionaries maintained by the pool.
struct DedustV2CpmmPoolWallets {
    /// Asset-hash keys mapped to pool-owned jetton wallet addresses.
    walletsByAssets: map<uint256, address>
    /// Wallet-address hashes mapped to their pool asset identifiers.
    assetsByWallets: map<uint256, DedustV2CpmmAsset>
    /// Resolver-address hashes mapped to the assets they resolve.
    resolutions: map<uint256, DedustV2CpmmAsset>
}

/// Controller and wallet-resolution state referenced by root storage.
struct DedustV2CpmmPoolExtra {
    /// Controller authorized for administrative pool operations.
    controller: address
    /// Wallet and asset lookup dictionaries.
    wallets: DedustV2CpmmPoolWallets
}

/// Compact post-operation pool state used in events.
struct DedustV2CpmmPoolUpdatedState {
    /// Updated asset X reserve.
    reserveX: coins
    /// Updated asset Y reserve.
    reserveY: coins
    /// Updated total liquidity.
    liquidity: coins
    /// Updated fee state.
    fees: Cell<DedustV2CpmmPoolFees>
}

/// Fee breakdown emitted with swap events.
struct DedustV2CpmmSwapFees {
    /// Whether fees are denominated in asset X.
    isX: bool
    /// Liquidity-provider fee amount.
    lpFee: coins
    /// Creator fee amount.
    creatorFee: coins
    /// Protocol fee amount.
    protocolFee: coins
    /// Partner fee amount.
    partnerFee: coins
    /// Referrer fee amount.
    referrerFee: coins
}

/// Full payout configuration for fulfillment and rejection paths.
@overflow1023_policy("suppress")
struct DedustV2CpmmExtendedPayoutConfig {
    /// Fulfillment payout options.
    fulfill: DedustV2CpmmPayoutOptions
    /// Rejection payout options.
    reject: DedustV2CpmmPayoutOptions
    /// Excess gas recipient, or `addr_none` to use the operation fallback.
    excessesTo: address?
}

/// Single-path payout configuration.
struct DedustV2CpmmBasicPayoutConfig {
    /// Payout options.
    options: DedustV2CpmmPayoutOptions
    /// Excess gas recipient, or `addr_none` to use the operation fallback.
    excessesTo: address?
}

/// Payout destination and notification options.
struct DedustV2CpmmPayoutOptions {
    /// Asset recipient, or `addr_none` to use the operation fallback.
    destination: address?
    /// Extra gas attached to the downstream notification.
    extraGas: coins
    /// Optional downstream payload.
    payload: cell?
    /// Whether to wrap the payload into a result envelope.
    wrapPayload: bool
}

/// Incoming native-asset payment body.
struct (0xa5a7cbf8) DedustV2CpmmPayNative {
    /// Query id copied through the swap flow.
    queryId: uint64
    /// Native GRAM amount routed into the pool.
    amount: coins
    /// Operation-specific payment payload.
    paymentPayload: cell
    /// Payout configuration for fulfillment and rejection paths.
    payoutConfig: Cell<DedustV2CpmmExtendedPayoutConfig>
}

/// Starts pool initialization.
struct (0xde8402ce) DedustV2CpmmInitPool {
    /// Query id carried by the body.
    queryId: uint64
    /// Optional custom payload included in the init result.
    customPayload: cell?
}

/// Wallet-resolution callback used during pool initialization.
struct (0xd1735400) DedustV2CpmmTakeWalletAddress {
    /// Query id carried by the body.
    queryId: uint64
    /// Resolved wallet address.
    walletAddress: address
    /// Optional owner address cell returned by the resolver.
    ownerAddress: Cell<address>?
}

/// TEP-74 transfer notification received from a pool-owned jetton wallet.
struct (0x7362d09c) DedustV2CpmmTransferNotification {
    /// Query id carried by the body.
    queryId: uint64
    /// Jetton amount received by the pool.
    amount: coins
    /// Original jetton transfer sender.
    sender: address
    /// One-bit Either selector for the forward payload.
    isForwardPayloadRef: bool
    /// Forward payload, expected to contain `DedustV2CpmmPayJetton`.
    forwardPayload: RemainingBitsAndRefs
}

/// Finalizes a two-asset liquidity deposit.
struct (0x25251ee0) DedustV2CpmmJoinLiquidity {
    /// Query id carried by the body.
    queryId: uint64
    /// Deposit configuration cell.
    config: cell
    /// Deposited amount of asset X.
    amountX: coins
    /// Deposited amount of asset Y.
    amountY: coins
    /// Original deposit initiator.
    initiatorAddress: address
}

/// Refunds an incomplete two-asset liquidity deposit.
struct (0x0d299e12) DedustV2CpmmRefundDeposit {
    /// Query id carried by the body.
    queryId: uint64
    /// Deposit configuration cell.
    config: cell
    /// Refunded amount of asset X.
    amountX: coins
    /// Refunded amount of asset Y.
    amountY: coins
    /// Original deposit initiator.
    initiatorAddress: address
}

/// Requests synchronization and payout of position fees.
struct (0x5652f1df) DedustV2CpmmClaimPositionFees {
    /// Query id carried by the body.
    queryId: uint64
    /// Excess gas recipient.
    excessesTo: address
}

/// Position callback requesting actual fee payout.
struct (0x29ff1bcf) DedustV2CpmmPayoutPositionFees {
    /// Query id carried by the body.
    queryId: uint64
    /// Accrued fees in asset X.
    xFees: coins
    /// Accrued fees in asset Y.
    yFees: coins
    /// Position owner address.
    ownerAddress: address
    /// Excess gas recipient.
    excessesTo: address
}

/// Requests protocol fee payout.
struct (0x419a17b3) DedustV2CpmmClaimProtocolFees {
    /// Query id carried by the body.
    queryId: uint64
    /// Fee recipient.
    to: address
    /// Excess gas recipient.
    excessesTo: address
}

/// Requests creator fee payout.
struct (0xbe3e3179) DedustV2CpmmClaimCreatorFees {
    /// Query id carried by the body.
    queryId: uint64
    /// Fee recipient.
    to: address
    /// Excess gas recipient.
    excessesTo: address
}

/// Requests liquidity withdrawal.
struct (0x20b5ef89) DedustV2CpmmWithdraw {
    /// Query id carried by the body.
    queryId: uint64
    /// Liquidity amount to burn.
    liquidity: coins
    /// Minimum acceptable asset X output.
    minimalXOut: coins
    /// Minimum acceptable asset Y output.
    minimalYOut: coins
    /// Whether to claim accrued fees during withdrawal.
    autoClaimFees: bool
    /// Payout configuration for withdrawn assets.
    payoutConfig: Cell<DedustV2CpmmBasicPayoutConfig>
}

/// Position callback finalizing liquidity withdrawal.
struct (0xf6f6a3aa) DedustV2CpmmExitLiquidity {
    /// Query id carried by the body.
    queryId: uint64
    /// Liquidity amount burned.
    liquidity: coins
    /// Claimed fees in asset X.
    xFees: coins
    /// Claimed fees in asset Y.
    yFees: coins
    /// Position owner address.
    ownerAddress: address
    /// Minimum acceptable asset X output.
    minimalAmountX: coins
    /// Minimum acceptable asset Y output.
    minimalAmountY: coins
    /// Payout configuration for withdrawn assets.
    payoutConfig: Cell<DedustV2CpmmBasicPayoutConfig>
}

/// Requests a pool state snapshot.
struct (0x00d8d379) DedustV2CpmmProvidePoolState {
    /// Query id carried by the body.
    queryId: uint64
    /// Include pool configuration in the response.
    includeConfig: bool
    /// Include pool fees in the response.
    includeFees: bool
    /// Include pool code hash in the response.
    includeCodeHash: bool
    /// Include reward state in the response.
    includeRewards: bool
}

/// Requests reward payout synchronization.
struct (0x909fdb65) DedustV2CpmmClaimReward {
    /// Query id carried by the body.
    queryId: uint64
    /// Reward program index.
    rewardIndex: uint2
    /// Excess gas recipient.
    excessesTo: address
}

/// Position callback requesting actual reward payout.
struct (0x9e17fbbe) DedustV2CpmmPayoutReward {
    /// Query id carried by the body.
    queryId: uint64
    /// Reward amount to pay out.
    amount: coins
    /// Reward program index.
    rewardIndex: uint2
    /// Position owner address.
    ownerAddress: address
    /// Excess gas recipient.
    excessesTo: address
}

/// Administrative request that replaces the pool implementation code.
struct (0xf287e089) DedustV2CpmmUpgradePoolCode {
    /// Query id carried by the body.
    queryId: uint64
    /// Referenced next pool code cell.
    nextCode: cell
}

/// Wallet-address request emitted to an asset resolver.
struct (0x2c76b973) DedustV2CpmmProvideWalletAddress {
    /// Query id copied into the callback.
    queryId: uint64
    /// Owner address whose wallet must be resolved.
    ownerAddress: address?
    /// Whether the response should include the owner address.
    includeOwnerAddress: bool
}

/// Standard excess-value response.
struct (0xd53276db) DedustV2CpmmExcess {
    /// Query id copied into the refund.
    queryId: uint64
}

/// Initialization result callback emitted by the pool.
struct (0xce185bd7) DedustV2CpmmInitPoolResult {
    /// Query id copied into the callback.
    queryId: uint64
    /// Initialization exit code.
    exitCode: int32
    /// Optional referenced payload.
    customPayload: cell?
}

/// Payout callback carrying amount, status, and an optional payload.
struct (0x3216ca09) DedustV2CpmmCallback3216ca09 {
    /// Query id copied into the callback.
    queryId: uint64
    /// Coins value attached to the callback body.
    amount0: coins
    /// Signed 32-bit status or error code.
    code: int32
    /// Optional referenced payload.
    payload: cell?
}

/// Position request to withdraw liquidity and optionally claim fees.
struct (0xbc1531a9) DedustV2CpmmWithdrawLiquidity {
    /// Query id copied into the position request.
    queryId: uint64
    /// Liquidity amount to withdraw.
    liquidity: coins
    /// Minimum acceptable asset X output.
    minimalXOut: coins
    /// Minimum acceptable asset Y output.
    minimalYOut: coins
    /// Position's last asset X fee-per-token checkpoint.
    xFeePerToken: DedustV2CpmmQ120X120
    /// Position's last asset Y fee-per-token checkpoint.
    yFeePerToken: DedustV2CpmmQ120X120
    /// Position reward checkpoints keyed by reward slot.
    rewards: DedustV2CpmmPoolRewards
    /// Whether accrued position fees should be claimed automatically.
    autoClaimFees: bool
    /// Referenced payout configuration for the withdrawn assets.
    payoutConfig: Cell<DedustV2CpmmBasicPayoutConfig>
}

/// Position request crediting newly minted liquidity.
@overflow1023_policy("suppress")
struct (0x855afcbd) DedustV2CpmmCreditLiquidity {
    /// Query id copied into the position request.
    queryId: uint64
    /// Liquidity amount credited to the position.
    liquidity: coins
    /// Share of the credited liquidity that remains locked.
    lockedLiquidityShare: uint16
    /// Extra GRAM attached to the position notification.
    notifyExtraGas: coins
    /// Optional notification payload.
    notifyPayload: cell?
    /// Excess gas recipient, or `addr_none` for the operation fallback.
    excessesTo: address?
    /// Current asset X fee-per-token accumulator.
    xFeePerToken: DedustV2CpmmQ120X120
    /// Current asset Y fee-per-token accumulator.
    yFeePerToken: DedustV2CpmmQ120X120
    /// Current reward accumulators keyed by reward slot.
    rewards: DedustV2CpmmPoolRewards
}

/// Position request to claim all currently available fees.
struct (0x25f19752) DedustV2CpmmClaimAvailableFees {
    /// Query id copied into the position request.
    queryId: uint64
    /// Excess gas recipient, or `addr_none` for the operation fallback.
    excessesTo: address?
    /// Current asset X fee-per-token accumulator.
    xFeePerToken: DedustV2CpmmQ120X120
    /// Current asset Y fee-per-token accumulator.
    yFeePerToken: DedustV2CpmmQ120X120
}

/// Requested snapshot of pool state and selected optional sections.
struct (0x870a9579) DedustV2CpmmTakePoolState {
    /// Query id copied from the state request.
    queryId: uint64
    /// Current pool lifecycle state.
    status: DedustV2CpmmStatus
    /// Whether deposits are active.
    depositActive: bool
    /// Whether swaps are active.
    swapActive: bool
    /// Current LP liquidity amount.
    liquidity: coins
    /// Current reserve of asset X.
    reserveX: coins
    /// Current reserve of asset Y.
    reserveY: coins
    /// Optional referenced pool configuration requested by the caller.
    config: Cell<DedustV2CpmmPoolConfig>?
    /// Optional referenced fee accumulators requested by the caller.
    fees: Cell<DedustV2CpmmPoolFees>?
    /// Optional inline reward-state section requested by the caller.
    rewards: DedustV2CpmmPoolRewards?
    /// Optional current code hash requested by the caller.
    codeHash: uint256?
}

/// Position request to claim one reward program.
struct (0x2e0cccba) DedustV2CpmmClaimPositionReward {
    /// Query id copied into the position request.
    queryId: uint64
    /// Reward program index.
    rewardIndex: uint2
    /// Current state of the selected reward program.
    reward: DedustV2CpmmPoolReward
    /// Excess gas recipient, or `addr_none` for the operation fallback.
    excessesTo: address?
}

/// Result envelope emitted according to payout options.
struct (0xe8db4696) DedustV2CpmmPayoutPayload {
    /// Signed 32-bit status or error code.
    exitCode: int32
    /// Optional referenced payload.
    payload: cell?
}

/// Outgoing swap event.
struct (0x78e79ba4) DedustV2CpmmSwapEvent {
    /// Swap direction: true for X to Y.
    xToY: bool
    /// Input amount.
    amountIn: coins
    /// Output amount.
    amountOut: coins
    /// Swap initiator.
    initiatorAddress: address
    /// Output recipient.
    recipientAddress: address
    /// Post-swap pool state.
    nextState: Cell<DedustV2CpmmPoolUpdatedState>
    /// Swap fee breakdown.
    fees: Cell<DedustV2CpmmSwapFees>
}

/// Outgoing liquidity deposit event emitted by the pool.
struct (0x35df2e12) DedustV2CpmmDepositEvent {
    /// Amount of asset X deposited.
    amountXIn: coins
    /// Amount of asset Y deposited.
    amountYIn: coins
    /// Minted liquidity amount.
    liquidity: coins
    /// Deposit initiator.
    initiatorAddress: address
    /// Liquidity recipient.
    recipientAddress: address
    /// Post-deposit pool state.
    nextState: Cell<DedustV2CpmmPoolUpdatedState>
}

/// Outgoing liquidity withdrawal event emitted by the pool.
struct (0xc0d77b54) DedustV2CpmmWithdrawalEvent {
    /// Burned liquidity amount.
    liquidity: coins
    /// Amount of asset X withdrawn.
    amountXOut: coins
    /// Amount of asset Y withdrawn.
    amountYOut: coins
    /// Withdrawal initiator.
    initiatorAddress: address
    /// Asset recipient.
    recipientAddress: address
    /// Post-withdrawal pool state.
    nextState: Cell<DedustV2CpmmPoolUpdatedState>
}

/// Internal message bodies accepted by CPMM v2 pools.
type DedustV2CpmmIncomingMessage =
    | DedustV2CpmmInitPool
    | DedustV2CpmmTakeWalletAddress
    | DedustV2CpmmPayNative
    | DedustV2CpmmTransferNotification
    | DedustV2CpmmJoinLiquidity
    | DedustV2CpmmRefundDeposit
    | DedustV2CpmmClaimPositionFees
    | DedustV2CpmmPayoutPositionFees
    | DedustV2CpmmClaimProtocolFees
    | DedustV2CpmmClaimCreatorFees
    | DedustV2CpmmWithdraw
    | DedustV2CpmmExitLiquidity
    | DedustV2CpmmProvidePoolState
    | DedustV2CpmmClaimReward
    | DedustV2CpmmPayoutReward
    | DedustV2CpmmUpgradePoolCode

/// Internal and external-out message bodies emitted by CPMM v2 pools.
type DedustV2CpmmOutgoingMessage =
    | DedustV2CpmmProvideWalletAddress
    | DedustV2CpmmExcess
    | DedustV2CpmmInitPoolResult
    | DedustV2CpmmCallback3216ca09
    | DedustV2CpmmPayoutPayload
    | DedustV2CpmmCreditLiquidity
    | DedustV2CpmmClaimAvailableFees
    | DedustV2CpmmWithdrawLiquidity
    | DedustV2CpmmTakePoolState
    | DedustV2CpmmClaimPositionReward
    | DedustV2CpmmSwapEvent
    | DedustV2CpmmDepositEvent
    | DedustV2CpmmWithdrawalEvent

/// CPMM v2 pool exit codes.
enum Errors {
    /// Pool is not in the uninitialized state.
    NotUninitialized = 20
    /// Pool is not in the initializing state.
    NotInitializing = 21
    /// Pool has not completed initialization.
    NotInitialized = 22
    /// Sender is not authorized for the requested operation.
    SenderUnauthorized = 23
    /// Wallet resolver returned an unsupported address.
    WalletCannotBeResolved = 24
    /// Attached message value is too low for gas and forwarding.
    MessageValueTooLow = 25
    /// Pool initialization used duplicate assets.
    DuplicateOfAssets = 26
    /// Payment asset is unrelated to this pool.
    UnrelatedAsset = 28
    /// Input value is lower than required.
    ValueTooLow = 29
    /// Slippage limit was exceeded.
    SlippageExceeded = 30
    /// Asset type is not supported.
    AssetNotSupported = 31
    /// Address is in an unexpected workchain.
    WrongWorkchain = 32
    /// Operation deadline has passed.
    DeadlineExceeded = 33
    /// Pool has zero liquidity.
    ZeroLiquidity = 34
    /// Creator fee exceeds the allowed maximum.
    MaxCreatorFeeExceeded = 35
    /// Position or pool liquidity is insufficient.
    NotEnoughLiquidity = 36
    /// Swaps are not active.
    SwapNotActive = 37
    /// Deposits are not active.
    DepositNotActive = 38
    /// Jetton wallet is already registered.
    WalletAlreadyRegistered = 39
    /// Jetton wallet is not registered.
    WalletNotRegistered = 40
    /// Wallet-resolution callback came from an unknown resolver.
    UnknownResolver = 41
    /// Reward asset is not allowed.
    RewardIsNotAllowed = 42
    /// Reward duration exceeds the configured maximum.
    MaxRewardDurationExceeded = 43
    /// Reward duration is zero.
    ZeroDurationReward = 44
    /// Reward top-up would dilute the current reward rate.
    RewardBudgetDilution = 45
    /// Reward program is not active.
    RewardIsNotActive = 46
    /// Swap or deposit input amount is zero.
    ZeroInputAmount = 47
    /// Tagged-union or forwarded-payload layout check failed.
    InvalidTag = 63
    /// Fallback rejection for unsupported operation codes.
    UnknownOperation = 65535
}

/// Return the deterministic position contract address for `ownerAddress`.
get fun get_position_address(ownerAddress: address): address {
    throw 0;
}

/// Return pool status, assets, reserves, fee accumulators, and rewards.
get fun get_pool_data(): DedustV2CpmmPoolDataReply {
    throw 0;
}
