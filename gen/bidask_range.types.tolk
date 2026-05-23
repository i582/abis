// Generated from XML ABI schemas.
// Source schema: schemas/bidask.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract BidaskRange {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bidask.xml"
    incomingMessages: BidaskRangeIncomingMessage
    forceAbiExport: BidaskRangeOutgoingMessage
}

// TL-B parser notes:
// - outgoingMessages: not added to contract header because bidask_swap_fallback and bidask_swap_fallback_v2 share opcode 0x1bba3896; the message structs and union type are still generated.

// TL-B helper types referenced by messages.
struct FarmingData {
    distributedXAmount: coins
    distributedYAmount: coins
}

struct AdditionalData {
    fromAddress: address
    refAddress: address
}

struct SwapAdditional {
    previousTime: uint64
    startPrice: uint256
    actualFee: uint16
    distributedXAmount: coins
    distributedYAmount: coins
}

type SwapAdditionalData = SwapAdditional

// TL-B message bodies.
struct (0x66210c65) BidaskInternalSwap {
    queryId: uint64
    toAddress: address
    order: bool
    isX: bool
    amountIn: coins
    amountOut: coins
    exactOut: coins
    slippage: RemainingBitsAndRefs
    refCell: cell?
    additionalData: cell?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x87d36990) BidaskInternalSwapV2 {
    queryId: uint64
    toAddress: address
    order: bool
    isX: bool
    amountIn: coins
    amountOut: coins
    exactOut: coins
    slippage: RemainingBitsAndRefs
    farmingCell: Cell<FarmingData>?
    additionalData: Cell<AdditionalData>?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x59699475) BidaskInternalContinueSwap {
    queryId: uint64
    toAddress: address
    order: bool
    isX: bool
    amountIn: coins
    amountOut: coins
    exactOut: coins
    slippage: RemainingBitsAndRefs
    refCell: cell?
    additionalData: cell?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x5a6a036f) BidaskInternalContinueSwapV2 {
    queryId: uint64
    toAddress: address
    order: bool
    isX: bool
    amountIn: coins
    amountOut: coins
    exactOut: coins
    slippage: RemainingBitsAndRefs
    swapAdditionalData: Cell<SwapAdditionalData>?
    additionalData: Cell<AdditionalData>?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x0c09445a) BidaskInternalContinueProvide {
    queryId: uint64
    amountX: coins
    amountY: coins
    excessX: coins
    excessY: coins
    userAddress: address
    firstBin: int32
    numberOfBins: uint32
    liquidityDict: map<uint32, int32>
    lpTokens: map<uint32, int32>
    rejectPayload: cell?
    forwardPayload: cell?
    order: bool
}

struct (0x16e09400) BidaskInternalBurn {
    queryId: uint64
    ownerAddress: address
    amountX: coins
    amountY: coins
    firstBin: int32
    tokensToBurn: map<uint32, int32>
    forwardPayload: cell?
}

struct (0x520e4831) BidaskSwapSuccess {
    queryId: uint64
    newCurrentBin: int32
    newSqrtPrice: uint256
    order: bool
    amountX: coins
    amountY: coins
    isX: bool
    userAddress: address
    refCell: cell?
    additionalData: cell?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0xd3a25890) BidaskSwapSuccessV2 {
    queryId: uint64
    newCurrentBin: int32
    newSqrtPrice: uint256
    order: bool
    amountX: coins
    amountY: coins
    isX: bool
    userAddress: address
    dynamicFee: uint16
    additionalData: Cell<AdditionalData>?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x1bba3896) BidaskSwapFallback {
    queryId: uint64
    firstRangeBin: int32
    order: bool
    userAddress: address
    isX: bool
    amountIn: coins
    additionalData: cell?
    rejectPayload: cell?
}

struct (0x1bba3896) BidaskSwapFallbackV2 {
    queryId: uint64
    firstRangeBin: int32
    order: bool
    userAddress: address
    isX: bool
    amountIn: coins
    distributedXAmount: coins
    distributedYAmount: coins
    additionalData: Cell<AdditionalData>?
    rejectPayload: cell?
}

struct (0x02422cbe) BidaskProvideRefund {
    queryId: uint64
    firstRangeBin: int32
    xExcess: coins
    yExcess: coins
    userAddress: address
    rejectPayload: cell?
    order: bool
}

struct (0x42062d62) BidaskBurnPayout {
    queryId: uint64
    firstRangeBin: int32
    amountX: coins
    amountY: coins
    userAddress: address
    forwardPayload: cell?
}

// Message unions used by Acton ABI.
type BidaskRangeIncomingMessage =
    | BidaskInternalSwap
    | BidaskInternalSwapV2
    | BidaskInternalContinueSwap
    | BidaskInternalContinueSwapV2
    | BidaskInternalContinueProvide
    | BidaskInternalBurn

type BidaskRangeOutgoingMessage =
    | BidaskInternalContinueSwap
    | BidaskInternalContinueSwapV2
    | BidaskInternalContinueProvide
    | BidaskSwapSuccess
    | BidaskSwapSuccessV2
    | BidaskSwapFallback
    | BidaskSwapFallbackV2
    | BidaskProvideRefund
    | BidaskBurnPayout
    | BidaskInternalBurn

struct GetBinAssetsReply {
    amountX: int
    amountY: int
}

struct GetUserBinAssetsReply {
    amountX: int
    amountY: int
}

get fun get_pool_addr(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_lp_multitoken_wallet(userAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_bin_assets(binNumber: int): GetBinAssetsReply {
    return {
        amountX: 0,
        amountY: 0,
    };
}

get fun get_user_bin_assets(binNumber: int, userLp: int): GetUserBinAssetsReply {
    return {
        amountX: 0,
        amountY: 0,
    };
}
