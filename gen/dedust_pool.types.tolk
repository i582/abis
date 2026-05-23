// Generated from XML ABI schemas.
// Source schema: schemas/dedust.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract DedustPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/dedust.xml"
    incomingMessages: DedustPoolIncomingMessage
    outgoingMessages: DedustPoolOutgoingMessage
}

struct DedustSwapField5 {
    senderAddr: address
    referralAddr: address
    reserve0: coins
    reserve1: coins
}

// TL-B helper types referenced by messages.
struct StepParams {
    kindOut: bool
    limit: coins
    next: Cell<DedustSwapStep>?
}

struct SwapParams {
    deadline: uint32
    recipientAddr: address
    referralAddr: address
    fulfillPayload: cell?
    rejectPayload: cell?
}

struct (0b0000) Native {}

struct (0b0001) Jetton {
    workchainId: int8
    address: bits256
}

struct (0b0010) ExtraCurrency {
    currencyId: int32
}

struct Step {
    poolAddr: address
    params: DedustSwapStepParams
}

type DedustSwapStepParams = StepParams

type DedustSwapParams = SwapParams

type DedustAsset =
    | Native
    | Jetton
    | ExtraCurrency

type DedustSwapStep = Step

// TL-B message bodies.
struct (0x61ee542d) DedustSwapExternal {
    queryId: uint64
    proof: cell
    amount: coins
    senderAddr: address
    current: DedustSwapStepParams
    swapParams: Cell<DedustSwapParams>
}

struct (0x72aca8aa) DedustSwapPeer {
    queryId: uint64
    proof: cell
    asset: cell
    amount: coins
    senderAddr: address
    current: DedustSwapStepParams
    swapParams: Cell<DedustSwapParams>
}

struct (0xad4eb6f5) DedustPayoutFromPool {
    queryId: uint64
    proof: cell
    amount: coins
    recipientAddr: address
    payload: cell?
}

struct (0x9c610de3) DedustSwap {
    assetIn: cell
    assetOut: cell
    amountIn: coins
    amountOut: coins
    field5: Cell<DedustSwapField5>
}

struct (0xb544f4a4) DedustDeposit {
    senderAddr: address
    amount0: coins
    amount1: coins
    reserve0: coins
    reserve1: coins
    liquidity: coins
}

struct (0x3aa870a6) DedustWithdrawal {
    senderAddr: address
    liquidity: coins
    amount0: coins
    amount1: coins
    reserve0: coins
    reserve1: coins
}

// Message unions used by Acton ABI.
type DedustPoolIncomingMessage =
    | DedustSwapExternal
    | DedustSwapPeer

type DedustPoolOutgoingMessage =
    | DedustPayoutFromPool
    | DedustSwapPeer
    | DedustSwap
    | DedustDeposit
    | DedustWithdrawal

struct GetReservesReply {
    reserve0: int
    reserve1: int
}

struct GetAssetsReply {
    asset0: slice
    asset1: slice
}

struct GetTradeFeeReply {
    tradeFeeNumerator: int
    tradeFeeDenominator: int
}

struct EstimateSwapOutReply {
    assetOut: slice
    amountOut: int
    tradeFee: int
}

get fun get_reserves(): GetReservesReply {
    return {
        reserve0: 0,
        reserve1: 0,
    };
}

get fun get_assets(): GetAssetsReply {
    return {
        asset0: createEmptyCell().beginParse(),
        asset1: createEmptyCell().beginParse(),
    };
}

get fun is_stable(): bool {
    return false;
}

get fun get_trade_fee(): GetTradeFeeReply {
    return {
        tradeFeeNumerator: 0,
        tradeFeeDenominator: 0,
    };
}

get fun estimate_swap_out(assetIn: slice, amountIn: int): EstimateSwapOutReply {
    return {
        assetOut: createEmptyCell().beginParse(),
        amountOut: 0,
        tradeFee: 0,
    };
}
