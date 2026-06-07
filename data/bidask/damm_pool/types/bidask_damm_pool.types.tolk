/// Bidask DAMM Pool: a two-asset DAMM pool that is also the LP Jetton master.
contract BidaskDammPool {
    author: "Bidask Protocol"
    version: "1.0"
    description: "Curated interface for Bidask DAMM Pool storage, pool/user-account messages, LP Jetton master getters, and SDK-documented jetton forward payloads."
    storage: BidaskDammPoolStorage
    incomingMessages: BidaskDammPoolIncomingMessage
    outgoingMessages: BidaskDammPoolOutgoingMessage
    forceAbiExport: BidaskDammPoolForwardPayload
    thrownErrors: BidaskDammPoolErrors
}

/// Persistent root data cell decoded from the live DAMM Pool code.
struct BidaskDammPoolStorage {
    /// Stored root prefix; the live code writes zero in 16 bits.
    storagePrefix: uint16
    /// Token X reserve currently available for liquidity operations.
    liquidityXAmount: coins
    /// Token Y reserve currently available for liquidity operations.
    liquidityYAmount: coins
    /// Token X amount held for account deposits or pending accounting, added by `get_tvl`.
    accountedXAmount: coins
    /// Token Y amount held for account deposits or pending accounting, added by `get_tvl`.
    accountedYAmount: coins
    /// Token X protocol fees accumulated until admin collection.
    protocolFeeX: coins
    /// Token Y protocol fees accumulated until admin collection.
    protocolFeeY: coins
    /// LP Jetton supply that is not locked.
    unlockedLpSupply: coins
    /// Current dynamic fee component returned by `get_fees_info`.
    dynamicFee: uint16
    /// Last swap timestamp used by dynamic-fee decay.
    previousSwapTime: uint64
    /// Referenced immutable and admin-mutable pool configuration.
    config: Cell<BidaskDammPoolConfig>
    /// Referenced fee accumulators, virtual liquidity, and locked LP supply.
    accumulators: Cell<BidaskDammPoolAccumulators>
    /// Optional farming schedule; absent when farming is inactive.
    farming: Cell<BidaskDammPoolFarmingSchedule>?
}

/// Pool configuration stored in the first root reference.
struct BidaskDammPoolConfig {
    /// Admin address allowed to run fee, code, lock, farming-duration, and collection commands.
    adminAddress: address
    /// Pool wallet for token X; this getter value is also returned by `get_pool_info`.
    tokenXPoolWallet: address
    /// Pool wallet for token Y, or the native-TON sentinel for TON-paired pools.
    tokenYPoolWallet: address
    /// Unix timestamp before which swaps are rejected.
    startTradeTime: uint64
    /// Dynamic fee factor used by the timestamp-based fee formula.
    dynamicFeeFactor: uint32
    /// Dynamic fee time-filter window in seconds.
    timeFilter: uint32
    /// Dynamic fee decay parameter in seconds.
    timeDecay: uint32
    /// Base LP fee returned by `get_pool_info`.
    baseFee: uint16
    /// Protocol-fee reduction factor returned by `get_fees_info`.
    protocolFeeReductionFactor: uint16
    /// Four-bit status flags; bit 2 is set by `lock` and cleared by `unlock`.
    statusFlags: uint4
    /// Code cell used to derive deterministic LP account contracts.
    lpAccountCode: cell
    /// LP Jetton wallet code returned by `get_jetton_data` and used by `get_wallet_address`.
    lpWalletCode: cell
    /// Code cell used to derive deterministic DAMM trade account contracts.
    tradeAccountCode: cell
}

/// Pool counters stored in the second root reference.
struct BidaskDammPoolAccumulators {
    /// Token X fee accumulator per LP token, stored as the live 256-bit counter.
    feesPerLpX: uint256
    /// Token Y fee accumulator per LP token, stored as the live 256-bit counter.
    feesPerLpY: uint256
    /// Virtual token X amount used by the DAMM quote formula.
    virtualXAmount: coins
    /// Virtual token Y amount used by the DAMM quote formula.
    virtualYAmount: coins
    /// LP Jetton supply locked by account/liquidity flows.
    lockedLpSupply: coins
}

/// Optional farming schedule cell used by `get_farming_info`.
struct BidaskDammPoolFarmingSchedule {
    /// Token X farming emission per second.
    farmingXPerSecond: coins
    /// Token Y farming emission per second.
    farmingYPerSecond: coins
    /// Timestamp at which the farming accumulator was last settled.
    previousCall: uint64
    /// Timestamp at which the current farming period ends.
    endOfFarming: uint64
}

/// Optional referral data accepted by direct and jetton-forward swap bodies.
struct BidaskDammSwapAdditionalData {
    /// Referral address credited by the swap route.
    refAddress: address
    /// Referral fee in Bidask basis-point units.
    refFee: uint16
}

/// Fee checkpoint cell sent by the LP wallet when burning liquidity.
struct BidaskDammInternalBurnFees {
    /// Wallet's token X fee checkpoint before the burn.
    feesPerLpXLast: uint220
    /// Wallet's token Y fee checkpoint before the burn.
    feesPerLpYLast: uint220
    /// Token X fees already claimed by the LP owner.
    claimedX: uint220
    /// Token Y fees already claimed by the LP owner.
    claimedY: uint220
}

/// Fee checkpoint cell sent by the LP wallet when claiming accumulated fees.
struct BidaskDammInternalClaimFees {
    /// Wallet's token X fee checkpoint before the claim.
    feesPerLpXLast: uint220
    /// Wallet's token Y fee checkpoint before the claim.
    feesPerLpYLast: uint220
    /// Token X fees already claimed by the LP owner.
    claimedX: uint220
    /// Token Y fees already claimed by the LP owner.
    claimedY: uint220
}

/// Fee checkpoint cell attached to LP mint messages emitted by the pool.
struct BidaskDammMintFees {
    /// Pool token X fee checkpoint assigned to the freshly minted LP tokens.
    feesPerLpXLast: uint220
    /// Pool token Y fee checkpoint assigned to the freshly minted LP tokens.
    feesPerLpYLast: uint220
}

/// Standard Jetton transfer notification accepted from token pool wallets.
struct (0x7362d09c) BidaskDammPoolJettonTransferNotification {
    /// Query id from the originating Jetton transfer.
    queryId: uint64
    /// Jetton amount received by the pool wallet before this notification.
    amount: coins
    /// Sender address from the Jetton notification body.
    sender: address
    /// Raw TEP-74 forward-payload tail; live DAMM handlers expect the payload by reference.
    forwardPayload: RemainingBitsAndRefs
}

/// Direct native-token swap body; jetton swaps use `BidaskDammSwapForwardPayload`.
struct (0xdd79732c) BidaskDammSwapNative {
    /// Query id chosen by the caller.
    queryId: uint64
    /// Native TON amount participating in the swap.
    nativeAmount: coins
    /// Receiver of the swap output or account credit.
    toAddress: address
    /// Minimum output for exact-input swaps, or maximum input for exact-output swaps.
    slippage: coins
    /// Address used as the logical swap sender in callbacks and accounting.
    fromAddress: address
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Optional referral cell with `refAddress` and `refFee`.
    additionalData: Cell<BidaskDammSwapAdditionalData>?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after a successful swap.
    forwardPayload: cell?
}

/// Direct native one-sided liquidity provision body.
struct (0x729c04c8) BidaskDammProvideOneSideNative {
    /// Query id chosen by the caller.
    queryId: uint64
    /// Native TON amount supplied as one side of liquidity.
    nativeAmount: coins
    /// Receiver of minted LP tokens or account credit.
    receiver: address
    /// Whether the resulting LP liquidity should be locked.
    lockLiquidity: bool
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Direct native deposit into a deterministic DAMM trade account.
struct (0xd8e04bf6) BidaskDammDepositOnAccountNative {
    /// Query id chosen by the caller.
    queryId: uint64
    /// Native TON amount credited to the trade account flow.
    nativeAmount: coins
    /// Owner address for the deterministic trade account.
    userAddress: address
    /// Public key committed into the trade account init data.
    publicKey: uint256
    /// Seed cell committed into the deterministic trade account address.
    seed: cell
    /// Optional payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Direct native deposit into an already known DAMM trade account.
struct (0x4b58a6c7) BidaskDammDirectDepositOnAccountNative {
    /// Query id chosen by the caller.
    queryId: uint64
    /// Native TON amount credited to the trade account.
    nativeAmount: coins
    /// Trade account address that receives the pool notification.
    tradeAccountAddress: address
    /// Optional payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Direct native farming top-up; jetton farming top-ups use `BidaskDammStartFarmingForwardPayload`.
struct (0xbe761948) BidaskDammStartFarmingNative {
    /// Query id chosen by the caller.
    queryId: uint64
    /// Native TON amount deposited as farming rewards.
    nativeAmount: coins
    /// Additional native-side emission rate per second.
    farmingPerSecond: coins
}

/// Internal burn request emitted by a DAMM LP wallet.
struct (0xadb8eb49) BidaskDammInternalBurn {
    /// Query id copied from the owner burn request.
    queryId: uint64
    /// LP owner whose liquidity is being burned.
    burner: address
    /// LP tokens to burn, in base units.
    burnAmount: coins
    /// Whether `receiver` is a Bidask account contract.
    isAccount: bool
    /// Address that receives withdrawn assets or account credit.
    receiver: address
    /// Referenced wallet fee checkpoint and claimed-total cell.
    fees: Cell<BidaskDammInternalBurnFees>
    /// Optional auxiliary data forwarded by the LP wallet.
    additionalData: cell?
    /// Optional payload forwarded with the burn result.
    forwardPayload: cell?
}

/// Internal fee-claim request emitted by a DAMM LP wallet.
struct (0x983b6933) BidaskDammInternalClaim {
    /// Query id copied from the owner claim request.
    queryId: uint64
    /// LP owner whose accumulated fees are being claimed.
    owner: address
    /// Whether `receiver` is a Bidask account contract.
    isAccount: bool
    /// Address that receives claimed assets or account credit.
    receiver: address
    /// Current LP wallet balance used for proportional fee settlement.
    walletBalance: coins
    /// Referenced wallet fee checkpoint and claimed-total cell.
    fees: Cell<BidaskDammInternalClaimFees>
    /// Optional payload forwarded with the claim result.
    forwardPayload: cell?
}

/// LP account callback that provides two-sided liquidity from account balances.
struct (0x64db1349) BidaskDammLpAccountProvide {
    /// Query id copied from the account operation.
    queryId: uint64
    /// Account owner for whom liquidity is being provided.
    userAddress: address
    /// Token X amount supplied by the account.
    amountX: coins
    /// Token Y amount supplied by the account.
    amountY: coins
    /// Whether the resulting LP liquidity should be locked.
    lockLiquidity: bool
    /// Refund address used if the account-provide operation fails.
    refundAddress: address
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// LP account refund callback returning unused token balances to the pool flow.
struct (0x10d674d7) BidaskDammLpAccountRefund {
    /// Query id copied from the account operation.
    queryId: uint64
    /// Token X amount refunded from the account.
    amountX: coins
    /// Token Y amount refunded from the account.
    amountY: coins
    /// Account owner associated with the refund.
    userAddress: address
    /// Optional payload forwarded with the refund.
    forwardPayload: cell?
}

/// Trade account request to provide liquidity from deterministic account balances.
struct (0x4409db64) BidaskDammProvideFromAccount {
    /// Query id copied from the account operation.
    queryId: uint64
    /// Owner address committed into the trade account address.
    userAddress: address
    /// Seed cell committed into the trade account address.
    seed: cell
    /// Token X amount supplied from the account.
    amountX: coins
    /// Token Y amount supplied from the account.
    amountY: coins
    /// Whether the resulting LP liquidity should be locked.
    lockLiquidity: bool
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Trade account request to perform a DAMM swap from account balances.
struct (0xf4a31e27) BidaskDammSwapFromAccount {
    /// Query id copied from the account operation.
    queryId: uint64
    /// Owner address committed into the trade account address.
    userAddress: address
    /// Seed cell committed into the trade account address.
    seed: cell
    /// Input amount for exact-input swaps, or output target for exact-output accounting.
    amount: coins
    /// True when token X is the input side.
    isX: bool
    /// Minimum output for exact-input swaps, or maximum input for exact-output swaps.
    slippage: coins
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after a successful swap.
    forwardPayload: cell?
}

/// Trade account request to withdraw balances through the pool.
struct (0x9aa06552) BidaskDammWithdrawFromAccount {
    /// Query id copied from the account operation.
    queryId: uint64
    /// Owner address committed into the trade account address.
    userAddress: address
    /// Seed cell committed into the trade account address.
    seed: cell
    /// Receiver of the withdrawn token balances.
    receiverAddress: address
    /// Token X amount to withdraw.
    amountX: coins
    /// Token Y amount to withdraw.
    amountY: coins
    /// Optional payload forwarded with the withdrawal result.
    forwardPayload: cell?
}

/// Admin command that collects accumulated protocol fees; the live body has an unresolved tail.
struct (0x144ad586) BidaskDammCollectProtocolFees {
    /// Query id chosen by the admin.
    queryId: uint64
    /// Raw remaining body; docs list only query id while the live code reads one additional value.
    tail: RemainingBitsAndRefs
}

/// Admin command that updates fee parameters in the config reference.
struct (0xfa94cd2f) BidaskDammSetFees {
    /// Query id chosen by the admin.
    queryId: uint64
    /// New protocol-fee reduction factor.
    protocolFeeReductionFactor: uint16
    /// New dynamic fee factor.
    dynamicFeeFactor: uint32
    /// New dynamic fee time-filter window.
    timeFilter: uint32
    /// New dynamic fee decay parameter.
    timeDecay: uint32
    /// New base LP fee.
    baseFee: uint16
}

/// Admin command that replaces only the DAMM trade account code cell.
struct (0x3967b023) BidaskDammUpdateTradeAccountCode {
    /// Query id chosen by the admin.
    queryId: uint64
    /// Replacement trade account code.
    tradeAccountCode: cell
}

/// Admin command that optionally replaces pool code and trade account code.
struct (0xdb55ccd0) BidaskDammUpdateAllCodes {
    /// Query id chosen by the admin.
    queryId: uint64
    /// Optional replacement code for this DAMM Pool contract.
    poolCode: cell?
    /// Optional replacement trade account code stored in pool config.
    tradeAccountCode: cell?
}

/// Admin command that sets the lock bit in pool status flags.
struct (0x7f656d43) BidaskDammLock {
    /// Query id chosen by the admin.
    queryId: uint64
}

/// Admin command that clears the lock bit in pool status flags.
struct (0x7bed2e64) BidaskDammUnlock {
    /// Query id chosen by the admin.
    queryId: uint64
}

/// Admin command that changes the active farming schedule end timestamp.
struct (0xa957dd3d) BidaskDammChangeFarmingDuration {
    /// Query id chosen by the admin.
    queryId: uint64
    /// New farming end timestamp; live code rejects this when no farming schedule exists.
    endOfFarming: uint64
}

/// Jetton-forward DAMM swap payload embedded in a token transfer notification.
struct (0xdd79732c) BidaskDammSwapForwardPayload {
    /// Receiver of the swap output or account credit.
    toAddress: address
    /// Minimum output for exact-input swaps, or maximum input for exact-output swaps.
    slippage: coins
    /// Address used as the logical swap sender in callbacks and accounting.
    fromAddress: address
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Optional referral cell with `refAddress` and `refFee`.
    additionalData: Cell<BidaskDammSwapAdditionalData>?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after a successful swap.
    forwardPayload: cell?
}

/// Jetton-forward two-sided liquidity provision payload.
struct (0x63ec24ae) BidaskDammProvideForwardPayload {
    /// Receiver of minted LP tokens or account credit.
    receiver: address
    /// Whether the resulting LP liquidity should be locked.
    lockLiquidity: bool
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Jetton-forward one-sided liquidity provision payload.
struct (0x729c04c8) BidaskDammProvideOneSideForwardPayload {
    /// Receiver of minted LP tokens or account credit.
    receiver: address
    /// Whether the resulting LP liquidity should be locked.
    lockLiquidity: bool
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Jetton-forward payload for mixed jetton/native two-sided provision.
struct (0xa8904134) BidaskDammProvideBothForwardPayload {
    /// Native TON amount paired with the received Jetton amount.
    nativeAmount: coins
    /// Receiver of minted LP tokens or account credit.
    receiver: address
    /// Whether the resulting LP liquidity should be locked.
    lockLiquidity: bool
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Jetton-forward deposit into a deterministic DAMM trade account.
struct (0xd8e04bf6) BidaskDammDepositOnAccountForwardPayload {
    /// Owner address for the deterministic trade account.
    userAddress: address
    /// Public key committed into the trade account init data.
    publicKey: uint256
    /// Seed cell committed into the deterministic trade account address.
    seed: cell
    /// Optional payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Jetton-forward deposit into an already known DAMM trade account.
struct (0x4b58a6c7) BidaskDammDirectDepositOnAccountForwardPayload {
    /// Trade account address that receives the pool notification.
    tradeAccountAddress: address
    /// Optional payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Jetton-forward farming top-up payload; reward amount is the Jetton notification amount.
struct (0xbe761948) BidaskDammStartFarmingForwardPayload {
    /// Additional emission rate per second for the Jetton side being notified.
    farmingPerSecond: coins
}

/// LP mint message emitted by the pool to a DAMM LP wallet.
struct (0x27ae4eff) BidaskDammMint {
    /// Query id copied from the liquidity operation.
    queryId: uint64
    /// LP tokens to mint, in base units.
    mintAmount: coins
    /// Source address carried by the pool mint body.
    fromAddress: address
    /// Response or LP owner address carried by the mint body.
    responseAddress: address
    /// Referenced fee checkpoint assigned to the minted LP tokens.
    fees: Cell<BidaskDammMintFees>
    /// Optional payload forwarded to the LP wallet owner after minting.
    forwardPayload: cell?
}

/// Standard Jetton transfer emitted by the pool to token or LP wallets.
struct (0x0f8a7ea5) BidaskDammJettonTransfer {
    /// Query id copied from the pool operation.
    queryId: uint64
    /// Jetton amount transferred, in base units.
    jettonAmount: coins
    /// Destination owner address for the receiving Jetton wallet.
    destination: address
    /// Optional response destination for excess TON.
    responseDestination: address?
    /// Optional custom payload.
    customPayload: cell?
    /// Nanotons forwarded with the Jetton transfer notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Native-token notification emitted by the pool for TON-side payouts.
struct (0x6edd65f0) BidaskNativeTransferNotification {
    /// Query id copied from the originating operation.
    queryId: uint64
    /// Notification flag stored as one bit by the pool.
    notificationBit: bool
    /// Native TON amount carried by the notification.
    nativeAmount: coins
    /// Optional payload forwarded with the notification.
    forwardPayload: cell?
}

/// Standard Jetton excesses response emitted by token wallet interactions.
struct (0xd53276db) BidaskDammJettonExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Pool-to-trade-account notification carrying account code/data and token deltas.
struct (0x30a3f9bc) BidaskDammTradeAccountNotification {
    /// Query id copied from the account operation.
    queryId: uint64
    /// Optional trade account code, present when the pool deploys or reinitializes an account.
    tradeAccountCode: cell?
    /// Optional trade account data cell, present with `tradeAccountCode`.
    tradeAccountData: cell?
    /// Token X amount credited or debited by the account notification.
    amountX: coins
    /// Token Y amount credited or debited by the account notification.
    amountY: coins
    /// Optional user payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Direct internal message bodies accepted by the DAMM Pool.
type BidaskDammPoolIncomingMessage =
    | BidaskDammPoolJettonTransferNotification
    | BidaskDammSwapNative
    | BidaskDammProvideOneSideNative
    | BidaskDammDepositOnAccountNative
    | BidaskDammDirectDepositOnAccountNative
    | BidaskDammStartFarmingNative
    | BidaskDammInternalBurn
    | BidaskDammInternalClaim
    | BidaskDammLpAccountProvide
    | BidaskDammLpAccountRefund
    | BidaskDammProvideFromAccount
    | BidaskDammSwapFromAccount
    | BidaskDammWithdrawFromAccount
    | BidaskDammCollectProtocolFees
    | BidaskDammSetFees
    | BidaskDammUpdateTradeAccountCode
    | BidaskDammUpdateAllCodes
    | BidaskDammLock
    | BidaskDammUnlock
    | BidaskDammChangeFarmingDuration

/// Internal message bodies emitted by the DAMM Pool.
type BidaskDammPoolOutgoingMessage =
    | BidaskDammMint
    | BidaskDammJettonTransfer
    | BidaskNativeTransferNotification
    | BidaskDammJettonExcesses
    | BidaskDammTradeAccountNotification

/// Jetton transfer forward-payload bodies decoded by the DAMM Pool.
type BidaskDammPoolForwardPayload =
    | BidaskDammSwapForwardPayload
    | BidaskDammProvideForwardPayload
    | BidaskDammProvideOneSideForwardPayload
    | BidaskDammProvideBothForwardPayload
    | BidaskDammDepositOnAccountForwardPayload
    | BidaskDammDirectDepositOnAccountForwardPayload
    | BidaskDammStartFarmingForwardPayload

/// Structured result returned by `get_protocol_fees`.
struct GetBidaskDammProtocolFeesReply {
    /// Accumulated token X protocol fees.
    protocolFeeX: int
    /// Accumulated token Y protocol fees.
    protocolFeeY: int
}

/// Structured result returned by `get_pool_info`.
struct GetBidaskDammPoolInfoReply {
    /// Pool wallet address for token X.
    tokenXPoolWallet: address
    /// Pool wallet address for token Y, or native-TON sentinel for native pairs.
    tokenYPoolWallet: address
    /// Base LP fee configured for the pool.
    baseFee: int
}

/// Structured result returned by `get_pool_tokens`.
struct GetBidaskDammPoolTokensReply {
    /// Pool wallet address for token X.
    tokenXPoolWallet: address
    /// Pool wallet address for token Y, or native-TON sentinel for native pairs.
    tokenYPoolWallet: address
}

/// Structured result returned by `get_tvl`.
struct GetBidaskDammTvlReply {
    /// Total token X value tracked by the pool.
    tokenXAmount: int
    /// Total token Y value tracked by the pool.
    tokenYAmount: int
}

/// Structured result returned by `get_liquidity_info`.
struct GetBidaskDammLiquidityInfoReply {
    /// Token X liquidity reserve.
    liquidityXAmount: int
    /// Token Y liquidity reserve.
    liquidityYAmount: int
    /// Virtual token X amount used by quote math.
    virtualXAmount: int
    /// Virtual token Y amount used by quote math.
    virtualYAmount: int
    /// Total LP supply, including locked LP.
    totalSupplyLp: int
    /// Locked LP supply.
    lockedLp: int
}

/// Structured result returned by `get_fees_info`.
struct GetBidaskDammFeesInfoReply {
    /// Current dynamic fee component.
    dynamicFee: int
    /// Dynamic fee factor.
    dynamicFeeFactor: int
    /// Last swap timestamp used by dynamic-fee decay.
    previousSwapTime: int
    /// Dynamic fee time-filter window.
    timeFilter: int
    /// Dynamic fee decay parameter.
    timeDecay: int
    /// Protocol-fee reduction factor.
    protocolFeeReductionFactor: int
}

/// Structured result returned by `get_farming_info`.
struct GetBidaskDammFarmingInfoReply {
    /// Token X farming emission per second.
    farmingXPerSecond: int
    /// Token Y farming emission per second.
    farmingYPerSecond: int
    /// Last farming settlement timestamp.
    previousCall: int
    /// Current farming end timestamp.
    endOfFarming: int
}

/// Structured result returned by `get_expected_swap_result`.
struct GetBidaskDammExpectedSwapResultReply {
    /// Expected output amount.
    out: int
    /// Excess input amount returned for exact-output quotes.
    excess: int
    /// LP fee charged by the quote.
    lpFee: int
    /// Protocol fee charged by the quote.
    protocolFee: int
    /// Referral fee charged by the quote.
    refFee: int
    /// Token X liquidity amount after applying quote-side accounting.
    liquidityXAmount: int
    /// Token Y liquidity amount after applying quote-side accounting.
    liquidityYAmount: int
}

/// Structured result returned by `get_collected_fees_info`.
struct GetBidaskDammCollectedFeesInfoReply {
    /// Token X fee accumulator per LP token.
    feesPerLpX: int
    /// Token Y fee accumulator per LP token.
    feesPerLpY: int
}

/// Structured result returned by standard Jetton master `get_jetton_data`.
struct GetBidaskDammJettonDataReply {
    /// Total LP Jetton supply, including locked LP.
    totalSupply: int
    /// Mintable flag; the live getter returns true.
    mintable: bool
    /// Admin address returned by the LP Jetton master view; the live pool returns `addr_none`.
    adminAddress: any_address
    /// LP Jetton metadata content cell.
    jettonContent: cell
    /// LP Jetton wallet code.
    jettonWalletCode: cell
}

/// Source-level exit-code catalog observed in the decompiled live pool code.
enum BidaskDammPoolErrors {
    /// Internal message value is too small for the operation's gas budget.
    InsufficientGas = 83
    /// Contract or derived address is not in workchain zero.
    WrongWorkchain = 84
    /// Amount or quote input is invalid.
    InvalidAmount = 85
    /// Farming schedule is missing when a farming operation requires it.
    MissingFarmingSchedule = 86
    /// Native-token path was required but the pool is not a native pair.
    NativePairRequired = 204
    /// Pool is administratively locked.
    PoolLocked = 205
    /// Swap or quote is unavailable before start time or without LP supply.
    SwapUnavailable = 207
    /// Farming reward rate is invalid.
    InvalidFarmingReward = 208
    /// Exact-output quote cannot be satisfied with the supplied input.
    ExactOutUnavailable = 209
    /// Exact-input quote output is below the requested minimum.
    OutputBelowLimit = 210
    /// Locked-liquidity status flag disallows this provision mode.
    LockedLiquidityDisabled = 211
    /// LP burn amount exceeds unlocked LP supply.
    BurnAmountExceedsUnlockedSupply = 502
    /// Initial liquidity invariant check failed.
    InvalidInitialLiquidity = 605
    /// Sender wallet or account address failed deterministic authentication.
    InvalidSender = 82
    /// Dispatcher fallback for unsupported opcodes.
    UnsupportedOperation = 65535
}

/// Return the accumulated protocol fee counters.
get fun get_protocol_fees(): GetBidaskDammProtocolFeesReply {
    throw 0;
}

/// Return the pool token wallet pair and configured base fee.
get fun get_pool_info(): GetBidaskDammPoolInfoReply {
    throw 0;
}

/// Return the deterministic DAMM LP account address for `userAddress`.
get fun get_lp_account_address(userAddress: address): address {
    throw 0;
}

/// Return the deterministic DAMM LP Jetton wallet address for an LP owner.
get fun get_wallet_address(userAddress: address): address {
    throw 0;
}

/// Return the deterministic DAMM trade account address for `userAddress` and `seed`.
get fun get_trade_account_address(userAddress: address, seed: cell): address {
    throw 0;
}

/// Return the pool token wallet addresses.
get fun get_pool_tokens(): GetBidaskDammPoolTokensReply {
    throw 0;
}

/// Return the pool admin address.
get fun get_admin_address(): address {
    throw 0;
}

/// Return total value tracked by the pool.
get fun get_tvl(): GetBidaskDammTvlReply {
    throw 0;
}

/// Return reserve, virtual-liquidity, total LP, and locked LP counters.
get fun get_liquidity_info(): GetBidaskDammLiquidityInfoReply {
    throw 0;
}

/// Return the dynamic fee that would apply at `timestamp`.
get fun get_dynamic_fee_by_timestamp(timestamp: int): int {
    throw 0;
}

/// Return the four-bit pool status flags.
get fun get_status(): int {
    throw 0;
}

/// Return fee configuration and current dynamic-fee state.
get fun get_fees_info(): GetBidaskDammFeesInfoReply {
    throw 0;
}

/// Return active or zeroed farming schedule data.
get fun get_farming_info(): GetBidaskDammFarmingInfoReply {
    throw 0;
}

/// Return the quote tuple for a hypothetical swap.
get fun get_expected_swap_result(
    amount: int,
    exactOut: int,
    tokenWallet: address,
    refFee: int,
    timestamp: int,
): GetBidaskDammExpectedSwapResultReply {
    throw 0;
}

/// Return token X/Y fee accumulator counters.
get fun get_collected_fees_info(): GetBidaskDammCollectedFeesInfoReply {
    throw 0;
}

/// Return the raw root storage cell.
get fun get_storage(): cell {
    throw 0;
}

/// Return the pool kind marker; live code returns ASCII `DAMM`.
get fun whoami(): string {
    throw 0;
}

/// Return standard Jetton master data for the DAMM LP token.
get fun get_jetton_data(): GetBidaskDammJettonDataReply {
    throw 0;
}

/// Return the configured trade start timestamp.
get fun get_start_trade_time(): int {
    throw 0;
}
