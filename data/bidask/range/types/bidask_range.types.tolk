/// Bidask DLMM Range interface for the verified mainnet range code hash 4bd7191b...
contract BidaskRange {
    author: "Bidask"
    version: "0.9.2"
    description: "Curated Bidask DLMM Range ABI with storage, getters, internal range operations, and observed outbound callbacks"
    storage: BidaskRangeStorage
    incomingMessages: BidaskRangeIncomingMessage
    outgoingMessages: BidaskRangeOutgoingMessage
    forceAbiExport: BidaskRangeForceExport
}

/// Root Range storage parsed by the saved SDK RangeContract.getStorage helper.
struct BidaskRangeStorage {
    /// First 16 bits skipped by the SDK; likely RangeStatus where 0 is uninitialized and 1 is initialized.
    status: uint16
    /// Precalculation flag read immediately after the 16-bit status field.
    precalculated: bool
    /// Optional ref to the total-liquidity dictionary; SDK parses Int(32) keys and 4 packed 244-bit amounts per value.
    liquidityDict: cell?
    /// Optional ref to the LP-supply dictionary; SDK parses Int(32) keys and 4 packed 244-bit amounts per value.
    lpSupplyDict: cell?
    /// Active bin number stored as a signed 32-bit integer.
    currentBin: int32
    /// Current sqrt price in Q128-style integer form.
    sqrtPrice: uint256
    /// Flag named `isMain` by the SDK storage parser.
    isMain: bool
    /// Referenced static/configuration storage cell with pool, neighbors, range bounds, and fee parameters.
    staticData: Cell<BidaskRangeStaticData>
    /// Root storage bits/refs left unread by the SDK after the static-data ref; preserved for exact fixture parsing.
    ignoredRootTail: RemainingBitsAndRefs
}

/// Referenced static Range storage cell parsed after the root mutable fields.
struct BidaskRangeStaticData {
    /// Parent pool address, encoded as Maybe MsgAddress in storage.
    poolAddress: address?
    /// Previous range address, or addr_none when the range has no left neighbor.
    leftRangeAddress: address?
    /// Next range address, or addr_none when the range has no right neighbor.
    rightRangeAddress: address?
    /// First bin covered by this range.
    firstBin: int32
    /// Fee value named `baseFee` by the SDK; DLMM docs also expose this as LP fee.
    baseFee: uint16
    /// Pool bin step, in basis-point units.
    binStep: uint32
    /// Dynamic fee multiplier/factor used by Range pricing.
    dynamicFeeFactor: uint32
    /// Dynamic fee time filter parameter.
    timeFilter: uint32
    /// Dynamic fee time decay parameter.
    timeDecay: uint32
    /// Extra static-data ref left unread by the SDK parser; semantics remain unknown.
    ignoredStaticRef: cell
}

/// V2 swap additional data cell containing swap origin and referral address.
struct AdditionalData {
    /// Address that originated the swap flow.
    fromAddress: address
    /// Referral address carried with the swap, when present.
    refAddress: address
}

/// Farming reward amounts carried by v2 swap messages.
struct FarmingData {
    /// Token X rewards already distributed during the swap flow.
    distributedXAmount: coins
    /// Token Y rewards already distributed during the swap flow.
    distributedYAmount: coins
}

/// Continued-swap accounting cell used by v2 self-messages.
struct SwapAdditionalData {
    /// Previous swap timestamp.
    previousTime: uint64
    /// Sqrt price at the start of the swap.
    startPrice: uint256
    /// Actual dynamic fee applied to the swap.
    actualFee: uint16
    /// Token X rewards already distributed while continuing the swap.
    distributedXAmount: coins
    /// Token Y rewards already distributed while continuing the swap.
    distributedYAmount: coins
}

/// Referenced payload for live opcode 0xd1b02ea5 `bidask_internal_provide`.
struct BidaskInternalProvidePayload {
    /// First bin of this provide batch.
    firstBin: int32
    /// Local TL-B catalog shape for provided liquidity; SDK evidence suggests packed grouped values, see research note.
    liquidityDict: map<uint32, int32>
    /// Pool current bin supplied with the provide payload.
    currentBin: int32
    /// Conditional price and user payload tail that docs describe after currentBin.
    tail: RemainingBitsAndRefs
}

/// Pool-to-range provide message observed live as opcode 0xd1b02ea5.
struct (0xd1b02ea5) BidaskInternalProvide {
    /// Caller-selected query id copied through provide/refund/mint flow.
    queryId: uint64
    /// Optional code/state ref named `ref_1` in the local Toncenter TL-B catalog.
    ref1: cell?
    /// Optional code/state ref named `ref_2` in the local Toncenter TL-B catalog.
    ref2: cell?
    /// Optional code/state ref named `ref_3` in the local Toncenter TL-B catalog.
    ref3: cell?
    /// Total token X amount supplied to this provide flow.
    amountX: coins
    /// Total token Y amount supplied to this provide flow.
    amountY: coins
    /// User address that receives refunds and LP multitoken minting.
    toAddress: address
    /// Referenced provide payload with first bin, liquidity dictionary, current bin, and tail data.
    dexPayload: Cell<BidaskInternalProvidePayload>
}

/// Original internal swap message from Pool/Range to a Range.
struct (0x66210c65) BidaskInternalSwap {
    /// Query id propagated through swap success, fallback, or continuation messages.
    queryId: uint64
    /// Receiver for swap output.
    toAddress: address
    /// Swap order flag from the generated schema.
    order: bool
    /// True when token X is the input side.
    isX: bool
    /// Input token amount in basic units.
    amountIn: coins
    /// Accumulated output token amount in basic units.
    amountOut: coins
    /// Exact output target, or zero for exact-input swaps.
    exactOut: coins
    /// Raw TL-B Either Coins uint256 slippage tail.
    slippage: RemainingBitsAndRefs
    /// Optional referral cell used by the pre-v2 swap flow.
    refCell: cell?
    /// Optional pre-v2 additional data cell.
    additionalData: cell?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful swap output.
    forwardPayload: cell?
}

/// V2 internal swap message with farming and structured additional data refs.
struct (0x87d36990) BidaskInternalSwapV2 {
    /// Query id propagated through swap success, fallback, or continuation messages.
    queryId: uint64
    /// Receiver for swap output.
    toAddress: address
    /// Swap order flag from the generated schema.
    order: bool
    /// True when token X is the input side.
    isX: bool
    /// Input token amount in basic units.
    amountIn: coins
    /// Accumulated output token amount in basic units.
    amountOut: coins
    /// Exact output target, or zero for exact-input swaps.
    exactOut: coins
    /// Raw TL-B Either Coins uint256 slippage tail.
    slippage: RemainingBitsAndRefs
    /// Optional farming distribution data ref.
    farmingCell: Cell<FarmingData>?
    /// Optional structured origin/referral data ref.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful swap output.
    forwardPayload: cell?
}

/// Self-message used to continue a pre-v2 swap in another range.
struct (0x59699475) BidaskInternalContinueSwap {
    /// Query id propagated from the original swap.
    queryId: uint64
    /// Receiver for final swap output.
    toAddress: address
    /// Swap order flag from the generated schema.
    order: bool
    /// True when token X is the input side.
    isX: bool
    /// Remaining input token amount.
    amountIn: coins
    /// Accumulated output token amount.
    amountOut: coins
    /// Exact output target, or zero for exact-input swaps.
    exactOut: coins
    /// Raw TL-B Either Coins uint256 slippage tail.
    slippage: RemainingBitsAndRefs
    /// Optional referral cell used by the pre-v2 swap flow.
    refCell: cell?
    /// Optional pre-v2 additional data cell.
    additionalData: cell?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful swap output.
    forwardPayload: cell?
}

/// Self-message used to continue a v2 swap in another range.
struct (0x5a6a036f) BidaskInternalContinueSwapV2 {
    /// Query id propagated from the original swap.
    queryId: uint64
    /// Receiver for final swap output.
    toAddress: address
    /// Swap order flag from the generated schema.
    order: bool
    /// True when token X is the input side.
    isX: bool
    /// Remaining input token amount.
    amountIn: coins
    /// Accumulated output token amount.
    amountOut: coins
    /// Exact output target, or zero for exact-input swaps.
    exactOut: coins
    /// Raw TL-B Either Coins uint256 slippage tail.
    slippage: RemainingBitsAndRefs
    /// Optional continued-swap accounting data.
    swapAdditionalData: Cell<SwapAdditionalData>?
    /// Optional structured origin/referral data ref.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful swap output.
    forwardPayload: cell?
}

/// Self-message used to continue liquidity provision across a range.
struct (0x0c09445a) BidaskInternalContinueProvide {
    /// Query id propagated from the original provide flow.
    queryId: uint64
    /// Token X amount still assigned to this provide flow.
    amountX: coins
    /// Token Y amount still assigned to this provide flow.
    amountY: coins
    /// Token X excess to refund.
    excessX: coins
    /// Token Y excess to refund.
    excessY: coins
    /// User address that receives refunds and LP multitoken minting.
    userAddress: address
    /// First bin of this provide batch.
    firstBin: int32
    /// Number of bins included in this provide batch.
    numberOfBins: uint32
    /// Local XML/TL-B dictionary shape for liquidity; packed value semantics remain uncertain.
    liquidityDict: map<uint32, int32>
    /// Local XML/TL-B dictionary shape for LP token amounts to mint.
    lpTokens: map<uint32, int32>
    /// Optional payload returned when provide is refunded.
    rejectPayload: cell?
    /// Optional payload forwarded after LP multitoken notification.
    forwardPayload: cell?
    /// Token order flag copied into the refund path.
    order: bool
}

/// Burn request from LP multitoken or another Range, observed live as incoming opcode 0x16e09400.
struct (0x16e09400) BidaskInternalBurn {
    /// Query id propagated to the burn payout.
    queryId: uint64
    /// Owner/user address that receives withdrawn tokens.
    ownerAddress: address
    /// Token X amount already accumulated for payout.
    amountX: coins
    /// Token Y amount already accumulated for payout.
    amountY: coins
    /// First bin of the burn batch.
    firstBin: int32
    /// Local XML/TL-B dictionary shape for LP tokens to burn; SDK builder indicates packed grouped values.
    tokensToBurn: map<uint32, int32>
    /// Optional payload forwarded with withdrawn tokens.
    forwardPayload: cell?
}

/// Swap success callback to the Pool for the pre-v2 swap flow.
struct (0x520e4831) BidaskSwapSuccess {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// New active bin after the swap.
    newCurrentBin: int32
    /// New sqrt price after the swap.
    newSqrtPrice: uint256
    /// Swap order flag from the triggering swap.
    order: bool
    /// Token X amount credited or debited by the swap.
    amountX: coins
    /// Token Y amount credited or debited by the swap.
    amountY: coins
    /// True when token X was the input side.
    isX: bool
    /// User address associated with the swap.
    userAddress: address
    /// Optional referral cell used by the pre-v2 swap flow.
    refCell: cell?
    /// Optional pre-v2 additional data cell.
    additionalData: cell?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful swap output.
    forwardPayload: cell?
}

/// Swap success callback to the Pool for the v2 swap flow.
struct (0xd3a25890) BidaskSwapSuccessV2 {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// New active bin after the swap.
    newCurrentBin: int32
    /// New sqrt price after the swap.
    newSqrtPrice: uint256
    /// Swap order flag from the triggering swap.
    order: bool
    /// Token X amount credited or debited by the swap.
    amountX: coins
    /// Token Y amount credited or debited by the swap.
    amountY: coins
    /// True when token X was the input side.
    isX: bool
    /// User address associated with the swap.
    userAddress: address
    /// Dynamic fee value applied to the swap.
    dynamicFee: uint16
    /// Optional structured origin/referral data ref.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
    /// Optional payload forwarded with successful swap output.
    forwardPayload: cell?
}

/// Pre-v2 swap fallback body. It shares opcode 0x1bba3896 with the v2 fallback.
struct (0x1bba3896) BidaskSwapFallback {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// First bin of the range returning the fallback.
    firstRangeBin: int32
    /// Swap order flag from the triggering swap.
    order: bool
    /// User address receiving fallback/refund handling.
    userAddress: address
    /// True when token X was the input side.
    isX: bool
    /// Unswapped input amount.
    amountIn: coins
    /// Optional pre-v2 additional data cell.
    additionalData: cell?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
}

/// V2 swap fallback body. This is the outgoing union variant because the TL-B catalog marks it as more specific.
struct (0x1bba3896) BidaskSwapFallbackV2 {
    /// Query id copied from the triggering swap.
    queryId: uint64
    /// First bin of the range returning the fallback.
    firstRangeBin: int32
    /// Swap order flag from the triggering swap.
    order: bool
    /// User address receiving fallback/refund handling.
    userAddress: address
    /// True when token X was the input side.
    isX: bool
    /// Unswapped input amount.
    amountIn: coins
    /// Token X rewards already distributed before fallback.
    distributedXAmount: coins
    /// Token Y rewards already distributed before fallback.
    distributedYAmount: coins
    /// Optional structured origin/referral data ref.
    additionalData: Cell<AdditionalData>?
    /// Optional payload returned when the swap is rejected.
    rejectPayload: cell?
}

/// Provide refund callback observed live as outgoing opcode 0x02422cbe.
struct (0x02422cbe) BidaskProvideRefund {
    /// Query id copied from the provide flow.
    queryId: uint64
    /// First bin of the range returning the refund.
    firstRangeBin: int32
    /// Token X excess refunded to the user through the Pool.
    xExcess: coins
    /// Token Y excess refunded to the user through the Pool.
    yExcess: coins
    /// User address receiving the refund.
    userAddress: address
    /// Optional user reject payload returned with the refund.
    rejectPayload: cell?
    /// Token order flag copied from the provide flow.
    order: bool
}

/// Burn payout callback observed live as outgoing opcode 0x42062d62.
struct (0x42062d62) BidaskBurnPayout {
    /// Query id copied from the burn request.
    queryId: uint64
    /// First bin of the range paying out the burn.
    firstRangeBin: int32
    /// Token X amount paid out to the user through the Pool.
    amountX: coins
    /// Token Y amount paid out to the user through the Pool.
    amountY: coins
    /// User address receiving withdrawn tokens.
    userAddress: address
    /// Optional payload forwarded with withdrawn tokens.
    forwardPayload: cell?
}

/// LP multitoken mint callback observed live as outgoing opcode 0x250ad226.
struct (0x250ad226) BidaskMultitokenMint {
    /// Query id copied from the provide flow.
    queryId: uint64
    /// Optional code/state ref named `ref_1` in the local Toncenter TL-B catalog.
    ref1: cell?
    /// Optional code/state ref named `ref_2` in the local Toncenter TL-B catalog.
    ref2: cell?
    /// Local XML/TL-B dictionary shape for LP token amounts to mint.
    liquidityDict: map<uint32, int32>
    /// Number of bins included in the mint.
    numberOfBins: uint32
    /// Optional payload forwarded after mint notification.
    forwardPayload: cell?
}

/// Incoming internal messages accepted by the curated Range interface.
type BidaskRangeIncomingMessage =
    | BidaskInternalProvide
    | BidaskInternalSwap
    | BidaskInternalSwapV2
    | BidaskInternalContinueSwap
    | BidaskInternalContinueSwapV2
    | BidaskInternalContinueProvide
    | BidaskInternalBurn

/// Outgoing internal messages emitted or forwarded by the curated Range interface.
type BidaskRangeOutgoingMessage =
    | BidaskInternalContinueSwap
    | BidaskInternalContinueSwapV2
    | BidaskInternalContinueProvide
    | BidaskSwapSuccess
    | BidaskSwapSuccessV2
    | BidaskSwapFallbackV2
    | BidaskProvideRefund
    | BidaskBurnPayout
    | BidaskInternalBurn
    | BidaskMultitokenMint

/// Extra exported bodies that cannot be placed in outgoingMessages because of opcode ambiguity.
type BidaskRangeForceExport =
    | BidaskSwapFallback

/// Reply returned by XML-derived `get_bin_assets`.
struct GetBinAssetsReply {
    /// Token X amount represented by the queried bin.
    amountX: int
    /// Token Y amount represented by the queried bin.
    amountY: int
}

/// Reply returned by XML-derived `get_user_bin_assets`.
struct GetUserBinAssetsReply {
    /// User token X amount represented by the queried bin and LP amount.
    amountX: int
    /// User token Y amount represented by the queried bin and LP amount.
    amountY: int
}

/// Reply returned by `get_bins_dicts`.
struct GetBinsDictsReply {
    /// Optional total-liquidity dictionary cell, parsed by the SDK as Int(32) keys and packed 244-bit values.
    liquidityDict: cell?
    /// Optional LP-supply dictionary cell, parsed by the SDK as Int(32) keys and packed 244-bit values.
    lpSupplyDict: cell?
}

/// Reply returned by `get_price_bounds`.
struct GetPriceBoundsReply {
    /// Left edge sqrt price of the requested bin.
    binStartPrice: int
    /// Right edge sqrt price of the requested bin.
    binEndPrice: int
}

/// Reply returned by NFT-style `get_collection_data` documented for Range.
struct GetCollectionDataReply {
    /// Collection next-item index placeholder; docs name this value `zero`.
    zero: int
    /// Collection content cell.
    contentData: cell
    /// Parent pool address.
    poolAddress: address
}

/// Reply returned by `get_dynamic_fees_info`.
struct GetDynamicFeesInfoReply {
    /// Current dynamic fee value.
    dynamicFee: int
    /// Dynamic fee factor from storage/configuration.
    dynamicFeeFactor: int
    /// Previous swap/update timestamp used by dynamic fee calculation.
    previousTime: int
    /// Dynamic fee time filter parameter.
    timeFilter: int
    /// Dynamic fee time decay parameter.
    timeDecay: int
}

/// Return the current sqrt price. Live mainnet call returned exit code 0.
get fun get_sqrt_price(): int {
    return 0;
}

/// Return the first bin covered by this range.
get fun get_first_bin_number(): int {
    return 0;
}

/// Return the pool bin step. Live mainnet call returned exit code 0.
get fun get_bin_step(): int {
    return 0;
}

/// Return the LP/base fee configured for this range.
get fun get_lp_fee(): int {
    return 0;
}

/// Return the current active bin. Live mainnet call returned exit code 0.
get fun get_current_bin(): int {
    return 0;
}

/// Return the parent pool address.
get fun get_pool_addr(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the total-liquidity dictionary cell.
get fun get_bins_dict(): cell {
    return createEmptyCell();
}

/// Return total-liquidity and LP-supply dictionary cells.
get fun get_bins_dicts(): GetBinsDictsReply {
    return {
        liquidityDict: null,
        lpSupplyDict: null,
    };
}

/// Derive the LP multitoken wallet address for a user.
get fun get_lp_multitoken_wallet(userAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the previous range address, or addr_none if absent.
get fun get_left_range(): any_address {
    return createAddressNone();
}

/// Return the next range address, or addr_none if absent.
get fun get_right_range(): any_address {
    return createAddressNone();
}

/// Return total liquidity for a bin.
get fun get_bin(binNumber: int): int {
    return 0;
}

/// Return LP supply for a bin.
get fun get_bin_lp(binNumber: int): int {
    return 0;
}

/// Return left and right sqrt-price bounds for a bin.
get fun get_price_bounds(binNumber: int): GetPriceBoundsReply {
    return {
        binStartPrice: 0,
        binEndPrice: 0,
    };
}

/// Return NFT-style collection metadata exposed by the Range docs.
get fun get_collection_data(): GetCollectionDataReply {
    return {
        zero: 0,
        contentData: createEmptyCell(),
        poolAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return the current dynamic fee.
get fun get_dynamic_fee(): int {
    return 0;
}

/// Return the dynamic fee calculated at a specific timestamp.
get fun get_get_dynamic_fee_by_timestamp(timestamp: int): int {
    return 0;
}

/// Return the dynamic fee state tuple.
get fun get_dynamic_fees_info(): GetDynamicFeesInfoReply {
    return {
        dynamicFee: 0,
        dynamicFeeFactor: 0,
        previousTime: 0,
        timeFilter: 0,
        timeDecay: 0,
    };
}

/// Return the raw current storage cell.
get fun get_storage(): cell {
    return createEmptyCell();
}

/// Return token X and token Y represented by a bin, from the local XML schema.
get fun get_bin_assets(binNumber: int): GetBinAssetsReply {
    return {
        amountX: 0,
        amountY: 0,
    };
}

/// Return user token X and token Y represented by a bin and LP amount, from the local XML schema.
get fun get_user_bin_assets(binNumber: int, userLp: int): GetUserBinAssetsReply {
    return {
        amountX: 0,
        amountY: 0,
    };
}
