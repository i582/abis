// Generated from XML ABI schemas.
// Source schema: schemas/bidask.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract BidaskPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bidask.xml"
    outgoingMessages: BidaskPoolOutgoingMessage
    forceAbiExport: BidaskPoolIncomingMessage
}

// TL-B parser notes:
// - incomingMessages: not added to contract header because bidask_swap_fallback and bidask_swap_fallback_v2 share opcode 0x1bba3896; the message structs and union type are still generated.

// TL-B helper types referenced by messages.
struct AdditionalData {
    fromAddress: address
    refAddress: address
}

struct FarmingData {
    distributedXAmount: coins
    distributedYAmount: coins
}

// TL-B message bodies.
struct (0xf2ef6c1b) BidaskSwap {
    queryId: uint64
    nativeAmount: coins
    toAddress: address
    slippage: RemainingBitsAndRefs
    exactOut: coins
    refAddress: address
    additionalData: cell?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x87d36990) BidaskSwapV2 {
    queryId: uint64
    nativeAmount: coins
    toAddress: address
    slippage: RemainingBitsAndRefs
    exactOut: coins
    additionalData: Cell<AdditionalData>?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x96feef7b) BidaskProvide {
    queryId: uint64
    depositType: uint4
    liquidityDict: map<uint32, int32>
    rejectPayload: cell?
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

struct (0xaf31d23f) BidaskAddingLiquidityNotify {
    queryId: uint64
    userAddress: address
    amountX: coins
    amountY: coins
    depositType: uint3
    liquidityDict: map<uint32, int32>
    rejectPayload: cell?
    forwardPayload: cell?
}

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

struct (0x214ad1d2) BidaskSaveLiquidityInfo {
    queryId: uint64
    amountX: coins
    amountY: coins
    depositType: uint3
    liquidityDict: map<uint32, int32>
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x6edd65f0) BidaskNativeTransferNotification {
    queryId: uint64
    notificationBit: bool
    nativeAmount: coins
    forwardPayload: cell?
}

// Message unions used by Acton ABI.
type BidaskPoolIncomingMessage =
    | BidaskSwap
    | BidaskSwapV2
    | BidaskProvide
    | BidaskSwapSuccess
    | BidaskSwapSuccessV2
    | BidaskSwapFallback
    | BidaskSwapFallbackV2
    | BidaskProvideRefund
    | BidaskBurnPayout
    | BidaskAddingLiquidityNotify

type BidaskPoolOutgoingMessage =
    | BidaskInternalSwap
    | BidaskInternalSwapV2
    | BidaskSaveLiquidityInfo
    | BidaskNativeTransferNotification

struct GetPoolInfoReply {
    jettonWalletX: address
    jettonWalletY: address
    binStep: int
    lpFee: int
}

struct GetDynamicFeesInfoReply {
    baseFee: int
    dynamicFeeFactor: int
    timeFilter: int
    timeDecay: int
}

struct GetFarmingInfoReply {
    distributedXAmount: int
    distributedYAmount: int
    farmingXPerSecond: int
    farmingYPerSecond: int
    previousCall: int
    endOfFarming: int
}

enum Errors {
    InsufficientGasForOperation = 83
}

get fun get_pool_info(): GetPoolInfoReply {
    return {
        jettonWalletX: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletY: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        binStep: 0,
        lpFee: 0,
    };
}

get fun get_current_bin(): int {
    return 0;
}

get fun get_sqrt_p(): int {
    return 0;
}

get fun get_active_range(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun whoami(): string {
    return "";
}

get fun get_dynamic_fees_info(): GetDynamicFeesInfoReply {
    return {
        baseFee: 0,
        dynamicFeeFactor: 0,
        timeFilter: 0,
        timeDecay: 0,
    };
}

get fun get_farming_info(): GetFarmingInfoReply {
    return {
        distributedXAmount: 0,
        distributedYAmount: 0,
        farmingXPerSecond: 0,
        farmingYPerSecond: 0,
        previousCall: 0,
        endOfFarming: 0,
    };
}
