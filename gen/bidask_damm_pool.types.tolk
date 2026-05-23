// Generated from XML ABI schemas.
// Source schema: schemas/bidask.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract BidaskDammPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bidask.xml"
    incomingMessages: BidaskDammPoolIncomingMessage
    outgoingMessages: BidaskDammPoolOutgoingMessage
}

struct BidaskDammInternalBurnFees {
    feesPerLpXLast: uint220
    feesPerLpYLast: uint220
    claimedX: uint220
    claimedY: uint220
}

struct BidaskDammInternalClaimFees {
    feesPerLpXLast: uint220
    feesPerLpYLast: uint220
    claimedX: uint220
    claimedY: uint220
}

struct BidaskDammMintFees {
    feesPerLpXLast: uint220
    feesPerLpYLast: uint220
}

// TL-B message bodies.
struct (0xdd79732c) BidaskDammSwap {
    queryId: uint64
    nativeAmount: coins
    toAddress: address
    slippage: coins
    fromAddress: address
    exactOut: coins
    additionalData: cell?
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0x729c04c8) BidaskDammProvideOneSide {
    queryId: uint64
    nativeAmount: coins
    receiver: address
    lockLiquidity: bool
    rejectPayload: cell?
    forwardPayload: cell?
}

struct (0xadb8eb49) BidaskDammInternalBurn {
    queryId: uint64
    burner: address
    burnAmount: coins
    isAccount: bool
    receiver: address
    fees: Cell<BidaskDammInternalBurnFees>
    additionalData: cell?
    forwardPayload: cell?
}

struct (0x983b6933) BidaskDammInternalClaim {
    queryId: uint64
    owner: address
    isAccount: bool
    receiver: address
    walletBalance: coins
    fees: Cell<BidaskDammInternalClaimFees>
    forwardPayload: cell?
}

struct (0x27ae4eff) BidaskDammMint {
    queryId: uint64
    mintAmount: coins
    fromAddress: address
    responseAddress: address
    fees: Cell<BidaskDammMintFees>
    forwardPayload: cell?
}

struct (0x6edd65f0) BidaskNativeTransferNotification {
    queryId: uint64
    notificationBit: bool
    nativeAmount: coins
    forwardPayload: cell?
}

// Message unions used by Acton ABI.
type BidaskDammPoolIncomingMessage =
    | BidaskDammSwap
    | BidaskDammProvideOneSide
    | BidaskDammInternalBurn
    | BidaskDammInternalClaim

type BidaskDammPoolOutgoingMessage =
    | BidaskDammMint
    | BidaskNativeTransferNotification

struct GetPoolInfoReply {
    jettonWalletX: address
    jettonWalletY: address
    baseFee: int
}

struct GetFeesInfoReply {
    dynamicFee: int
    dynamicFeeFactor: int
    previousSwapTime: int
    timeFilter: int
    timeDecay: int
    protocolFeeReductionFactor: int
}

struct GetFarmingInfoReply {
    farmingXPerSecond: int
    farmingYPerSecond: int
    previousCall: int
    endOfFarming: int
}

struct GetCollectedFeesInfoReply {
    feesPerLpX: int
    feesPerLpY: int
}

struct GetLiquidityInfoReply {
    liquidityXAmount: int
    liquidityYAmount: int
    virtualXAmount: int
    virtualYAmount: int
    totalSupplyLp: int
    lockedLp: int
}

struct GetExpectedSwapResultReply {
    out: int
    excess: int
    lpFee: int
    protocolFee: int
    refFee: int
    liquidityXAmount: int
    liquidityYAmount: int
}

get fun get_pool_info(): GetPoolInfoReply {
    return {
        jettonWalletX: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletY: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        baseFee: 0,
    };
}

get fun whoami(): string {
    return "";
}

get fun get_fees_info(): GetFeesInfoReply {
    return {
        dynamicFee: 0,
        dynamicFeeFactor: 0,
        previousSwapTime: 0,
        timeFilter: 0,
        timeDecay: 0,
        protocolFeeReductionFactor: 0,
    };
}

get fun get_farming_info(): GetFarmingInfoReply {
    return {
        farmingXPerSecond: 0,
        farmingYPerSecond: 0,
        previousCall: 0,
        endOfFarming: 0,
    };
}

get fun get_collected_fees_info(): GetCollectedFeesInfoReply {
    return {
        feesPerLpX: 0,
        feesPerLpY: 0,
    };
}

get fun get_liquidity_info(): GetLiquidityInfoReply {
    return {
        liquidityXAmount: 0,
        liquidityYAmount: 0,
        virtualXAmount: 0,
        virtualYAmount: 0,
        totalSupplyLp: 0,
        lockedLp: 0,
    };
}

get fun get_start_trade_time(): int {
    return 0;
}

get fun get_expected_swap_result(amount: int, exactOut: int, tokenWallet: address, refFee: int, timestamp: int): GetExpectedSwapResultReply {
    return {
        out: 0,
        excess: 0,
        lpFee: 0,
        protocolFee: 0,
        refFee: 0,
        liquidityXAmount: 0,
        liquidityYAmount: 0,
    };
}
