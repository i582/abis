/// Bidask DLMM Pool interface covering storage, swaps, liquidity provision, range callbacks, and pool getters.
contract BidaskPool {
    author: "Bidask"
    version: "0.9.2"
    description: "Curated Bidask DLMM Pool ABI for storage, direct and Jetton-forward swap/provide flows, range callbacks, and public pool getters"
    storage: BidaskPoolStorage
    outgoingMessages: BidaskPoolOutgoingMessage
    forceAbiExport: BidaskPoolIncomingMessage
        | BidaskPoolForwardPayloadMessage
        | BidaskPoolExtraExport
}

/// Runtime Pool storage for the current versioned DLMM data cell.
struct BidaskPoolStorage {
    /// Version tag stored before the current Pool payload.
    storageVersion: uint16
    /// Amount of token X held by the Pool.
    tokenXAmount: coins
    /// Amount of token Y held by the Pool.
    tokenYAmount: coins
    /// Collected protocol fees in token X.
    collectedTokenXProtocolFee: coins
    /// Collected protocol fees in token Y.
    collectedTokenYProtocolFee: coins
    /// Current sqrt price.
    sqrtPrice: uint256
    /// Current active bin.
    currentBin: int32
    /// Pool initialization/status nibble.
    initStatus: uint4
    /// Referenced static configuration and code cells.
    staticData: Cell<BidaskPoolStaticData>
    /// Referenced auxiliary account data.
    tradeAccountAuxData: cell
    /// Optional farming state.
    farmingData: Cell<BidaskPoolFarmingStorage>?
}

/// Referenced immutable and admin-configured Pool data.
struct BidaskPoolStaticData {
    /// Pool admin address.
    adminAddress: address
    /// Pool LP/base fee.
    lpFee: uint16
    /// Dynamic fee factor.
    dynamicFeeFactor: uint32
    /// Dynamic fee time filter.
    timeFilter: uint32
    /// Dynamic fee time decay.
    timeDecay: uint32
    /// Protocol fee reduction factor used in swap accounting.
    protocolFeeReductionFactor: uint16
    /// Referral fee value used when referral data is present.
    refFee: uint16
    /// Pool bin step.
    binStep: uint32
    /// Additional Pool configuration flags.
    configFlags: uint16
    /// Token X Pool Jetton wallet.
    jettonWalletX: address
    /// Token Y Pool Jetton wallet.
    jettonWalletY: address
    /// Code ref used to derive LP account addresses.
    lpAccountCode: cell
    /// Code ref used to derive trade account addresses.
    tradeAccountCode: cell
    /// Code ref used in child-account derivation.
    childAccountCode: cell
    /// Range contract code ref used by get_active_range and get_range_address.
    rangeCode: cell
}

/// Optional farming state cell.
struct BidaskPoolFarmingStorage {
    /// Token X rewards already distributed by farming.
    distributedXAmount: coins
    /// Token Y rewards already distributed by farming.
    distributedYAmount: coins
    /// Token X farming emission rate per second.
    farmingXPerSecond: coins
    /// Token Y farming emission rate per second.
    farmingYPerSecond: coins
    /// Timestamp of the previous farming accounting update.
    previousCall: uint64
    /// Timestamp when the active farming schedule ends.
    endOfFarming: uint64
}

/// Additional origin and referral data used by v2 swaps.
struct AdditionalData {
    /// Address that initiated the v2 swap flow.
    fromAddress: address
    /// Optional referral address carried by the v2 swap.
    refAddress: address
}

/// Farming reward amounts carried by v2 range-swap messages.
struct FarmingData {
    /// Token X rewards already distributed during the swap.
    distributedXAmount: coins
    /// Token Y rewards already distributed during the swap.
    distributedYAmount: coins
}

/// Continued-swap accounting data carried by v2 range messages.
struct SwapAdditionalData {
    /// Timestamp of the previous swap accounting step.
    previousTime: uint64
    /// Sqrt price at the start of the continued swap.
    startPrice: uint256
    /// Dynamic fee applied to the continued swap.
    actualFee: uint16
    /// Token X rewards already distributed during the continued swap.
    distributedXAmount: coins
    /// Token Y rewards already distributed during the continued swap.
    distributedYAmount: coins
}

/// Slippage branch for exact/normal execution: minimum output coins.
struct (0b0) BidaskPoolNormalSlippage {
    /// Minimum output amount accepted by the caller.
    minAmountOut: coins
}

/// Slippage branch for partial execution: last accepted sqrt price.
struct (0b1) BidaskPoolPartialSlippage {
    /// Sqrt price limit accepted for partial execution.
    sqrtPriceLimit: uint256
}

/// Swap slippage variants accepted by Pool and Range swap bodies.
type BidaskPoolSlippage =
    | BidaskPoolNormalSlippage
    | BidaskPoolPartialSlippage

/// Standard Jetton transfer notification accepted by the Pool.
struct (0x7362d09c) BidaskPoolJettonTransferNotification {
    /// Query id copied from the originating Jetton transfer.
    queryId: uint64
    /// Jetton amount received by the Pool wallet.
    amount: coins
    /// Logical sender reported by the Jetton wallet.
    sender: address
    /// Referenced Bidask forward payload dispatched by the Pool.
    forwardPayload: cell
}

/// Native swap request accepted directly by the Pool.
struct (0xf2ef6c1b) BidaskPoolSwap {
    /// Caller-selected query id.
    queryId: uint64
    /// Native TON amount participating in the swap.
    nativeAmount: coins
    /// Receiver of swap output.
    toAddress: address
    /// Slippage limit for exact or partial execution.
    slippage: BidaskPoolSlippage
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Referral address used by the legacy swap flow.
    refAddress: address
    /// Optional legacy additional data.
    additionalData: cell?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// Native v2 swap request accepted directly by the Pool.
struct (0xc09da84e) BidaskPoolSwapV2 {
    /// Caller-selected query id.
    queryId: uint64
    /// Native TON amount participating in the swap.
    nativeAmount: coins
    /// Receiver of swap output.
    toAddress: address
    /// Slippage limit for exact or partial execution.
    slippage: BidaskPoolSlippage
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Optional structured origin and referral data.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// Native-only liquidity provide request.
struct (0x96feef7b) BidaskPoolProvide {
    /// Caller-selected query id.
    queryId: uint64
    /// Native TON amount supplied as one side of liquidity.
    nativeAmount: coins
    /// Deposit mode for initial, add, or update liquidity.
    depositType: uint3
    /// Liquidity mode bit parsed separately from depositType.
    liquidityType: uint1
    /// Requested liquidity distribution by bin.
    liquidityDict: map<uint32, int32>
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Native deposit routed to a deterministic trade account.
struct (0xd8e04bf6) BidaskPoolDepositOnAccount {
    /// Caller-selected query id.
    queryId: uint64
    /// Native TON amount credited to the trade account flow.
    nativeAmount: coins
    /// Owner address committed into the deterministic trade account.
    userAddress: address
    /// Public key committed into the deterministic trade account.
    publicKey: uint256
    /// Seed cell committed into the deterministic trade account.
    seed: cell
    /// Optional payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Range callback after a v1 swap succeeds.
struct (0x520e4831) BidaskPoolSwapSuccess {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// New active bin after the Range swap.
    newCurrentBin: int32
    /// New sqrt price after the Range swap.
    newSqrtPrice: uint256
    /// Swap direction/order flag.
    order: bool
    /// Token X amount accounted by the swap.
    amountX: coins
    /// Token Y amount accounted by the swap.
    amountY: coins
    /// True when token X was the input side.
    isX: bool
    /// User address associated with the swap.
    userAddress: address
    /// Optional referral cell used by the legacy flow.
    refCell: cell?
    /// Optional legacy additional data.
    additionalData: cell?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// Range callback after a v2 swap succeeds.
struct (0xd3a25890) BidaskPoolSwapSuccessV2 {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// New active bin after the Range swap.
    newCurrentBin: int32
    /// New sqrt price after the Range swap.
    newSqrtPrice: uint256
    /// Swap direction/order flag.
    order: bool
    /// Token X amount accounted by the swap.
    amountX: coins
    /// Token Y amount accounted by the swap.
    amountY: coins
    /// True when token X was the input side.
    isX: bool
    /// User address associated with the swap.
    userAddress: address
    /// Dynamic fee applied by the Range.
    dynamicFee: uint16
    /// Optional structured origin and referral data.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// Legacy swap fallback callback. Shares opcode with the v2 fallback shape.
struct (0x1bba3896) BidaskPoolSwapFallback {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// First bin of the Range returning the fallback.
    firstRangeBin: int32
    /// Swap direction/order flag.
    order: bool
    /// User address receiving fallback handling.
    userAddress: address
    /// True when token X was the input side.
    isX: bool
    /// Unswapped input amount.
    amountIn: coins
    /// Optional legacy additional data.
    additionalData: cell?
    /// Optional payload returned with rejection.
    rejectPayload: cell?
}

/// v2 swap fallback callback. Shares opcode with the legacy fallback shape.
struct (0x1bba3896) BidaskPoolSwapFallbackV2 {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// First bin of the Range returning the fallback.
    firstRangeBin: int32
    /// Swap direction/order flag.
    order: bool
    /// User address receiving fallback handling.
    userAddress: address
    /// True when token X was the input side.
    isX: bool
    /// Unswapped input amount.
    amountIn: coins
    /// Token X rewards already distributed before fallback.
    distributedXAmount: coins
    /// Token Y rewards already distributed before fallback.
    distributedYAmount: coins
    /// Optional structured origin and referral data.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned with rejection.
    rejectPayload: cell?
}

/// Range refund after provide-liquidity fails or leaves excesses.
struct (0x02422cbe) BidaskPoolProvideRefund {
    /// Query id copied from the provide flow.
    queryId: uint64
    /// First bin of the Range returning the refund.
    firstRangeBin: int32
    /// Token X excess refunded through the Pool.
    xExcess: coins
    /// Token Y excess refunded through the Pool.
    yExcess: coins
    /// User address receiving the refund.
    userAddress: address
    /// Optional payload returned with the refund.
    rejectPayload: cell?
    /// Token order flag copied from the provide flow.
    order: bool
}

/// Range payout after liquidity burn.
struct (0x42062d62) BidaskPoolBurnPayout {
    /// Query id copied from the burn flow.
    queryId: uint64
    /// First bin of the Range paying out the burn.
    firstRangeBin: int32
    /// Token X amount paid out through the Pool.
    amountX: coins
    /// Token Y amount paid out through the Pool.
    amountY: coins
    /// User address receiving withdrawn tokens.
    userAddress: address
    /// Optional payload forwarded with withdrawn tokens.
    forwardPayload: cell?
}

/// Internal liquidity vault notification routed back to the Pool after save_liquidity_info.
struct (0xaf31d23f) BidaskPoolAddingLiquidityNotify {
    /// Query id copied from the saved liquidity operation.
    queryId: uint64
    /// Liquidity provider address stored by the vault.
    userAddress: address
    /// Combined token X amount.
    amountX: coins
    /// Combined token Y amount.
    amountY: coins
    /// Deposit mode for initial, add, or update liquidity.
    depositType: uint3
    /// Requested liquidity distribution by bin.
    liquidityDict: map<uint32, int32>
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Swap payload sent as a jetton transfer forward payload.
struct (0xf2ef6c1b) BidaskPoolSwapForwardPayload {
    /// Receiver of swap output.
    toAddress: address
    /// Slippage limit for exact or partial execution.
    slippage: BidaskPoolSlippage
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Referral address used by the legacy swap flow.
    refAddress: address
    /// Optional legacy additional data.
    additionalData: cell?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// v2 swap payload sent as a jetton transfer forward payload.
struct (0xc09da84e) BidaskPoolSwapV2ForwardPayload {
    /// Receiver of swap output.
    toAddress: address
    /// Slippage limit for exact or partial execution.
    slippage: BidaskPoolSlippage
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Optional structured origin and referral data.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// Liquidity provide payload sent as a jetton transfer forward payload.
struct (0x96feef7b) BidaskPoolProvideForwardPayload {
    /// Deposit mode for initial, add, or update liquidity.
    depositType: uint3
    /// Liquidity mode bit parsed separately from depositType.
    liquidityType: uint1
    /// Requested liquidity distribution by bin.
    liquidityDict: map<uint32, int32>
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Liquidity provide payload for jetton+native pools.
struct (0x3ea0bafc) BidaskPoolProvideBothForwardPayload {
    /// Native TON amount paired with the received Jetton amount.
    nativeAmount: coins
    /// Deposit mode for initial, add, or update liquidity.
    depositType: uint3
    /// Liquidity mode bit parsed separately from depositType.
    liquidityType: uint1
    /// Requested liquidity distribution by bin.
    liquidityDict: map<uint32, int32>
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Jetton transfer forward payload for depositing assets on a trade account.
struct (0xd8e04bf6) BidaskPoolDepositOnAccountForwardPayload {
    /// Owner address committed into the deterministic trade account.
    userAddress: address
    /// Public key committed into the deterministic trade account.
    publicKey: uint256
    /// Seed cell committed into the deterministic trade account.
    seed: cell
    /// Optional payload forwarded to the trade account.
    forwardPayload: cell?
}

/// Internal swap routed from Pool to Range.
struct (0x66210c65) BidaskPoolInternalSwap {
    /// Query id propagated from the original swap.
    queryId: uint64
    /// Receiver of final swap output.
    toAddress: address
    /// Swap direction/order flag.
    order: bool
    /// True when token X is the input side.
    isX: bool
    /// Remaining input token amount.
    amountIn: coins
    /// Accumulated output token amount.
    amountOut: coins
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Slippage limit for exact or partial execution.
    slippage: BidaskPoolSlippage
    /// Optional referral cell used by the legacy flow.
    refCell: cell?
    /// Optional legacy additional data.
    additionalData: cell?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// v2 internal swap routed from Pool to Range.
struct (0x87d36990) BidaskPoolInternalSwapV2 {
    /// Query id propagated from the original swap.
    queryId: uint64
    /// Receiver of final swap output.
    toAddress: address
    /// Swap direction/order flag.
    order: bool
    /// True when token X is the input side.
    isX: bool
    /// Remaining input token amount.
    amountIn: coins
    /// Accumulated output token amount.
    amountOut: coins
    /// Exact-output target; zero means exact-input mode.
    exactOut: coins
    /// Slippage limit for exact or partial execution.
    slippage: BidaskPoolSlippage
    /// Optional farming reward data.
    farmingCell: Cell<FarmingData>?
    /// Optional structured origin and referral data.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned if the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful output.
    forwardPayload: cell?
}

/// Message sent to the internal liquidity vault to persist provide-liquidity context.
struct (0x214ad1d2) BidaskPoolSaveLiquidityInfo {
    /// Query id copied from the provide-liquidity flow.
    queryId: uint64
    /// Token X amount saved in the vault.
    amountX: coins
    /// Token Y amount saved in the vault.
    amountY: coins
    /// Deposit mode for initial, add, or update liquidity.
    depositType: uint3
    /// Requested liquidity distribution by bin.
    liquidityDict: map<uint32, int32>
    /// Optional payload returned if provision is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded after successful provision.
    forwardPayload: cell?
}

/// Notification carrying native TON after a Pool payout/refund.
struct (0x6edd65f0) BidaskPoolNativeTransferNotification {
    /// Query id copied from the Pool operation.
    queryId: uint64
    /// Notification flag stored by the Pool.
    notificationBit: bool
    /// Native TON amount carried by the notification.
    nativeAmount: coins
    /// Optional payload forwarded with the notification.
    forwardPayload: cell?
}

/// Standard Jetton transfer sent by Pool to user or Pool wallets.
struct (0x0f8a7ea5) BidaskPoolJettonTransfer {
    /// Query id copied from the Pool operation.
    queryId: uint64
    /// Jetton amount transferred.
    amount: coins
    /// Destination owner address for the receiving Jetton wallet.
    destination: address
    /// Address that receives excess TON.
    responseDestination: address
    /// Optional custom payload for the receiving Jetton wallet.
    customPayload: cell?
    /// Nanotons forwarded with the Jetton transfer notification.
    forwardTonAmount: coins
    /// Optional forward payload for the destination owner.
    forwardPayload: cell?
}

/// Direct incoming bodies accepted by the Pool plus Range callbacks.
type BidaskPoolIncomingMessage =
    | BidaskPoolJettonTransferNotification
    | BidaskPoolSwap
    | BidaskPoolSwapV2
    | BidaskPoolProvide
    | BidaskPoolDepositOnAccount
    | BidaskPoolSwapSuccess
    | BidaskPoolSwapSuccessV2
    | BidaskPoolSwapFallback
    | BidaskPoolSwapFallbackV2
    | BidaskPoolProvideRefund
    | BidaskPoolBurnPayout
    | BidaskPoolAddingLiquidityNotify

/// Jetton transfer forward-payload bodies decoded by the Pool.
type BidaskPoolForwardPayloadMessage =
    | BidaskPoolSwapForwardPayload
    | BidaskPoolSwapV2ForwardPayload
    | BidaskPoolProvideForwardPayload
    | BidaskPoolProvideBothForwardPayload
    | BidaskPoolDepositOnAccountForwardPayload

/// Internal bodies emitted by the Pool.
type BidaskPoolOutgoingMessage =
    | BidaskPoolJettonTransfer
    | BidaskPoolInternalSwap
    | BidaskPoolInternalSwapV2
    | BidaskPoolSaveLiquidityInfo
    | BidaskPoolNativeTransferNotification

/// Additional cells exported for wrapper users.
type BidaskPoolExtraExport =
    | AdditionalData
    | FarmingData
    | SwapAdditionalData

/// Structured result returned by `get_pool_info`.
struct GetPoolInfoReply {
    /// Token X Pool Jetton wallet.
    jettonWalletX: address
    /// Token Y Pool Jetton wallet.
    jettonWalletY: address
    /// Pool bin step.
    binStep: int
    /// Pool LP/base fee.
    lpFee: int
}

/// Structured result returned by `get_fees_info`.
struct GetFeesInfoReply {
    /// Referral fee value.
    refFee: int
    /// Protocol fee reduction factor.
    protocolFeeReductionFactor: int
}

/// Structured result returned by `get_dynamic_fees_info`.
struct GetDynamicFeesInfoReply {
    /// Base LP fee.
    baseFee: int
    /// Dynamic fee factor.
    dynamicFeeFactor: int
    /// Dynamic fee time filter.
    timeFilter: int
    /// Dynamic fee time decay.
    timeDecay: int
}

/// Structured result returned by `get_farming_info`.
struct GetFarmingInfoReply {
    /// Token X rewards already distributed by farming.
    distributedXAmount: int
    /// Token Y rewards already distributed by farming.
    distributedYAmount: int
    /// Token X farming emission rate per second.
    farmingXPerSecond: int
    /// Token Y farming emission rate per second.
    farmingYPerSecond: int
    /// Timestamp of the previous farming accounting update.
    previousCall: int
    /// Timestamp when the active farming schedule ends.
    endOfFarming: int
}

/// Structured result returned by `get_protocol_fees`.
struct GetProtocolFeesReply {
    /// Collected protocol fees in token X.
    collectedTokenXProtocolFee: int
    /// Collected protocol fees in token Y.
    collectedTokenYProtocolFee: int
}

/// Structured result returned by `get_tvl`.
struct GetTvlReply {
    /// Amount of token X held by the Pool.
    tokenXAmount: int
    /// Amount of token Y held by the Pool.
    tokenYAmount: int
}

/// Structured result returned by `get_pool_tokens`.
struct GetPoolTokensReply {
    /// Token X Pool Jetton wallet.
    jettonWalletX: address
    /// Token Y Pool Jetton wallet.
    jettonWalletY: address
}

/// Source-level exit-code catalog observed in the verified Pool code.
enum BidaskPoolErrors {
    /// Internal message value is too small for the operation's gas budget.
    InsufficientGasForOperation = 83
    /// Contract or derived address is not in the expected workchain.
    InvalidWorkchain = 84
    /// Amount or quote input is invalid.
    InvalidAmount = 85
    /// Sender address failed deterministic authentication.
    InvalidSender = 204
    /// Pool state does not support the requested operation.
    UnsupportedPoolState = 205
}

/// Return token wallets, bin step, and LP fee.
get fun get_pool_info(): GetPoolInfoReply {
    throw 0;
}

/// Return referral and protocol-fee parameters.
get fun get_fees_info(): GetFeesInfoReply {
    throw 0;
}

/// Return the Pool token wallet pair.
get fun get_pool_tokens(): GetPoolTokensReply {
    throw 0;
}

/// Return the Pool kind marker.
get fun whoami(): string {
    throw 0;
}

/// Return the current active bin.
get fun get_current_bin(): int {
    throw 0;
}

/// Return the deterministic DLMM LP account address for a user.
get fun get_lp_account_address(userAddress: address): address {
    throw 0;
}

/// Return the current active Range address.
get fun get_active_range(): address {
    throw 0;
}

/// Return the deterministic trade account address for a user and seed.
get fun get_trade_account_address(userAddress: address, seed: cell): address {
    throw 0;
}

/// Return base and dynamic-fee parameters.
get fun get_dynamic_fees_info(): GetDynamicFeesInfoReply {
    throw 0;
}

/// Return the Pool admin address.
get fun get_admin_address(): address {
    throw 0;
}

/// Return total token amounts tracked by the Pool.
get fun get_tvl(): GetTvlReply {
    throw 0;
}

/// Return the raw root storage cell.
get fun get_storage(): cell {
    throw 0;
}

/// Return active or zeroed farming schedule data.
get fun get_farming_info(): GetFarmingInfoReply {
    throw 0;
}

/// Return accumulated protocol fee counters.
get fun get_protocol_fees(): GetProtocolFeesReply {
    throw 0;
}

/// Return the Pool initialization/status value.
get fun get_is_inited(): int {
    throw 0;
}

/// Return the deterministic Range address for a first bin.
get fun get_range_address(firstBin: int): address {
    throw 0;
}

/// Return the current sqrt price.
get fun get_sqrt_p(): int {
    throw 0;
}
