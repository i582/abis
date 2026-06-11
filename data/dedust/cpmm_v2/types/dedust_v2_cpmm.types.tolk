/// DeDust V2 CPMM pool interface reconstructed from the verified library-backed pool code at `EQD026kOv4j6-56O6y8kbaaFZdQhVkh4RbEGrQND7XJMlgLf`.
contract DedustV2Cpmm {
    author: "DeDust"
    version: "2.0"
    description: "Curated ABI for the deployed DeDust v2 CPMM pool family with get_pool_data, get_position_address, proven storage shape, and live message bodies."
    storage: DedustV2CpmmStorage
    incomingMessages: DedustV2CpmmIncomingMessage
    outgoingMessages: DedustV2CpmmOutgoingMessage
    thrownErrors: DedustV2CpmmErrors
    forceAbiExport: DedustV2CpmmPaymentPayload | DedustV2CpmmPayJetton | DedustV2CpmmPoolConfig | DedustV2CpmmPoolFees | DedustV2CpmmPoolUpdatedState | DedustV2CpmmSwapFees | DedustV2CpmmExtendedPayoutConfig | DedustV2CpmmBasicPayoutConfig
}

/// Inline two-bit mode tag stored after the root dictionary.
struct (0b00) DedustV2CpmmModeIdle {}

/// Two-bit mode tag variant with an embedded address.
struct (0b01) DedustV2CpmmModeWithAddress {
    /// Embedded internal address carried by the mode tag.
    address: address
}

/// Inline two-bit mode tag used by the live representative pool.
struct (0b10) DedustV2CpmmModeSettled {}

/// Root mode tag reconstructed from `set_data(...)` sites in the verified decompile.
type DedustV2CpmmMode =
    | DedustV2CpmmModeIdle
    | DedustV2CpmmModeWithAddress
    | DedustV2CpmmModeSettled

/// Root persistent CPMM storage loaded directly from the saved mainnet data cell.
struct DedustV2CpmmStorage {
    /// First referenced state cell with the owner address and wallet registry dictionaries returned through `get_pool_data`.
    walletRegistryState: cell
    /// Second referenced state cell with protocol-fee and LP-fee accumulators.
    feeState: cell
    /// Third referenced state cell with asset addresses, fee settings, and auxiliary collections.
    assetState: cell
    /// Root dictionary cell persisted alongside the three referenced state cells.
    rootDictionary: cell?
    /// Inline pool mode tag.
    mode: DedustV2CpmmMode
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
    /// Asset X address; the live TON/LFG example returns `addr_none` for native TON.
    assetX: address?
    /// Asset Y address.
    assetY: address
    /// Registry cell keyed by asset addresses.
    walletsByAssets: cell
    /// Registry cell keyed by wallet addresses.
    assetsByWallets: cell
    /// Raw resolution tuple returned by the live getter.
    walletsResolutions: tuple
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
    createdFeeX: int
    /// Creator fee balance for asset Y.
    createdFeeY: int
    /// Accumulated LP fee-per-token for asset X.
    xLpFeePerToken: int
    /// Accumulated LP fee-per-token for asset Y.
    yLpFeePerToken: int
    /// Raw rewards tuple returned by the live getter.
    rewards: tuple
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
enum DedustV2CpmmFeeIn : uint2 {
    /// Fees are collected in the input asset.
    Both = 0b00,
    /// Fees are collected in asset X.
    AssetX = 0b01,
    /// Fees are collected in asset Y.
    AssetY = 0b10,
}

/// Pool immutable configuration.
struct DedustV2CpmmPoolConfig {
    /// Asset X identifier.
    assetX: address?
    /// Asset Y identifier.
    assetY: address?
    /// Pool creator address.
    creatorAddress: address
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
    asset: address?
    /// Maximum reward duration in seconds.
    maxDuration: uint40
}

/// Active reward programs by reward index.
type DedustV2CpmmPoolRewards = map<uint2, DedustV2CpmmPoolReward>

/// Active reward state.
struct DedustV2CpmmPoolReward {
    /// Remaining distribution time in seconds.
    remainingTime: uint40
    /// Remaining reward budget.
    remainingBudget: coins
    /// Accumulated reward per liquidity token.
    rewardsPerToken: varuint32
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
    /// Accumulated LP fee per token in asset X.
    xFeePerToken: varuint32
    /// Accumulated LP fee per token in asset Y.
    yFeePerToken: varuint32
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
    /// Excess gas recipient.
    excessesTo: address
}

/// Single-path payout configuration.
struct DedustV2CpmmBasicPayoutConfig {
    /// Payout options.
    options: DedustV2CpmmPayoutOptions
    /// Excess gas recipient.
    excessesTo: address
}

/// Payout destination and notification options.
struct DedustV2CpmmPayoutOptions {
    /// Asset recipient.
    destination: address
    /// Extra gas attached to the downstream notification.
    extraGas: coins
    /// Optional downstream payload.
    payload: cell?
    /// Whether to wrap the payload into a result envelope.
    wrapPayload: bool
}

/// Incoming native-payment swap body accepted by the verified CPMM pool.
struct (0xa5a7cbf8) DedustV2CpmmPayNative {
    /// Query id copied through the swap flow.
    queryId: uint64
    /// Native TON amount routed into the pool.
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

/// Observed incoming body parsed by the `0xf287e089` dispatch branch.
struct (0xf287e089) DedustV2CpmmOpcodeF287e089 {
    /// Query id carried by the body.
    queryId: uint64
    /// Referenced opaque payload cell.
    payload: cell
}

/// Wallet address callback emitted during asset resolution.
struct (0x2c76b973) DedustV2CpmmTakeWalletAddressResult {
    /// Query id copied into the callback.
    queryId: uint64
    /// Resolved wallet address.
    walletAddress: address
    /// Optional owner-address marker.
    includeOwnerAddress: uint1
}

/// Standard excess message emitted by the verified CPMM pool.
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

/// Short callback emitted by the verified CPMM pool.
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

/// Referenced payload used by `0xbc1531a9`.
struct DedustV2CpmmOpcodeBc1531a9Details {
    /// Leading address copied into the details cell.
    address0: address
    /// Coins argument copied into the details cell.
    amount0: coins
    /// Optional referenced cell copied into the details cell.
    payload0: cell?
    /// One-bit flag copied into the details cell.
    flag0: uint1
    /// Trailing address copied into the details cell.
    address1: address
}

/// Outgoing body emitted by the `0xbc1531a9` send site.
struct (0xbc1531a9) DedustV2CpmmOpcodeBc1531a9 {
    /// Query id copied into the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Third coins argument.
    amount2: coins
    /// First varuint32 value.
    value0: varuint32
    /// Second varuint32 value.
    value1: varuint32
    /// Optional referenced payload.
    payload0: cell?
    /// One-bit flag.
    flag0: uint1
    /// Referenced details cell.
    details: Cell<DedustV2CpmmOpcodeBc1531a9Details>
}

/// Outgoing body emitted by the `0x855afcbd` send site.
struct (0x855afcbd) DedustV2CpmmOpcode855afcbd {
    /// Query id copied into the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Unsigned 16-bit parameter.
    value0: uint16
    /// Second coins argument.
    amount1: coins
    /// Optional referenced payload.
    payload0: cell?
    /// Trailing address argument.
    address0: address
    /// First varuint32 value.
    value1: varuint32
    /// Second varuint32 value.
    value2: varuint32
    /// Optional referenced payload.
    payload1: cell?
}

/// Outgoing body emitted by the `0x25f19752` send site.
struct (0x25f19752) DedustV2CpmmOpcode25f19752 {
    /// Query id copied into the body.
    queryId: uint64
    /// Trailing address argument.
    address0: address
    /// First varuint32 value.
    value0: varuint32
    /// Second varuint32 value.
    value1: varuint32
}

/// Outgoing body emitted by the `0x870a9579` send site.
struct (0x870a9579) DedustV2CpmmOpcode870a9579 {
    /// Query id copied into the body.
    queryId: uint64
    /// Remaining opaque payload after the query id.
    payload: RemainingBitsAndRefs
}

/// Outgoing body emitted by the `0x2e0cccba` send site.
struct (0x2e0cccba) DedustV2CpmmOpcode2e0cccba {
    /// Query id copied into the body.
    queryId: uint64
    /// Two-bit mode value.
    mode: uint2
    /// First unsigned 40-bit value.
    value0: uint40
    /// Coins argument.
    amount0: coins
    /// Varuint32 value.
    value1: varuint32
    /// Second unsigned 40-bit value.
    value2: uint40
    /// Trailing address or fallback slice.
    address0: address
}

/// Result envelope emitted according to payout options.
struct (0xe8db4696) DedustV2CpmmPayoutPayload {
    /// Signed 32-bit status or error code.
    exitCode: int32
    /// Optional referenced payload.
    payload: cell?
}

/// Outgoing swap event emitted by the verified CPMM pool.
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
    | DedustV2CpmmOpcodeF287e089

type DedustV2CpmmOutgoingMessage =
    | DedustV2CpmmTakeWalletAddressResult
    | DedustV2CpmmExcess
    | DedustV2CpmmInitPoolResult
    | DedustV2CpmmCallback3216ca09
    | DedustV2CpmmPayoutPayload
    | DedustV2CpmmOpcode855afcbd
    | DedustV2CpmmOpcode25f19752
    | DedustV2CpmmOpcodeBc1531a9
    | DedustV2CpmmOpcode870a9579
    | DedustV2CpmmOpcode2e0cccba
    | DedustV2CpmmSwapEvent
    | DedustV2CpmmDepositEvent
    | DedustV2CpmmWithdrawalEvent

/// CPMM v2 exit-code catalog from official docs and verified decompile.
enum DedustV2CpmmErrors {
    /// Pool is not in the uninitialized state.
    NotUninitialized = 20,
    /// Pool is not in the initializing state.
    NotInitializing = 21,
    /// Pool has not completed initialization.
    NotInitialized = 22,
    /// Sender is not authorized for the requested operation.
    SenderUnauthorized = 23,
    /// Wallet resolver returned an unsupported address.
    WalletCannotBeResolved = 24,
    /// Attached message value is too low for gas and forwarding.
    MessageValueTooLow = 25,
    /// Pool initialization used duplicate assets.
    DuplicateOfAssets = 26,
    /// Payment asset is unrelated to this pool.
    UnrelatedAsset = 28,
    /// Input value is lower than required.
    ValueTooLow = 29,
    /// Slippage limit was exceeded.
    SlippageExceeded = 30,
    /// Asset type is not supported.
    AssetNotSupported = 31,
    /// Address is in an unexpected workchain.
    WrongWorkchain = 32,
    /// Operation deadline has passed.
    DeadlineExceeded = 33,
    /// Pool has zero liquidity.
    ZeroLiquidity = 34,
    /// Creator fee exceeds the allowed maximum.
    MaxCreatorFeeExceeded = 35,
    /// Position or pool liquidity is insufficient.
    NotEnoughLiquidity = 36,
    /// Swaps are not active.
    SwapNotActive = 37,
    /// Deposits are not active.
    DepositNotActive = 38,
    /// Jetton wallet is already registered.
    WalletAlreadyRegistered = 39,
    /// Jetton wallet is not registered.
    WalletNotRegistered = 40,
    /// Wallet-resolution callback came from an unknown resolver.
    UnknownResolver = 41,
    /// Reward asset is not allowed.
    RewardIsNotAllowed = 42,
    /// Reward duration exceeds the configured maximum.
    MaxRewardDurationExceeded = 43,
    /// Reward duration is zero.
    ZeroDurationReward = 44,
    /// Reward top-up would dilute the current reward rate.
    RewardBudgetDilution = 45,
    /// Reward program is not active.
    RewardIsNotActive = 46,
    /// Swap or deposit input amount is zero.
    ZeroInputAmount = 47,
    /// Tagged-union or forwarded-payload layout check failed.
    InvalidTag = 63,
    /// Fallback rejection for unsupported operation codes.
    UnknownOperation = 65535,
}

get fun get_position_address(ownerAddress: address): address {
    throw 0;
}

get fun get_pool_data(): DedustV2CpmmPoolDataReply {
    throw 0;
}
