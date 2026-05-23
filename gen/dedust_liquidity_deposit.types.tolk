// Generated from XML ABI schemas.
// Source schema: schemas/dedust.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract DedustLiquidityDeposit {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/dedust.xml"
    outgoingMessages: DedustLiquidityDepositOutgoingMessage
}

struct DedustDepositLiquidityAllField5 {
    asset0: cell
    asset0Amount: coins
    asset1: cell
    asset1Amount: coins
}

// TL-B helper types referenced by messages.
struct (0b0000) Native {}

struct (0b0001) Jetton {
    workchainId: int8
    address: bits256
}

struct (0b0010) ExtraCurrency {
    currencyId: int32
}

type DedustAsset =
    | Native
    | Jetton
    | ExtraCurrency

// TL-B message bodies.
struct (0xb56b9598) DedustDepositLiquidityAll {
    queryId: uint64
    proof: cell
    ownerAddr: address
    minLpAmount: coins
    field5: Cell<DedustDepositLiquidityAllField5>
    fulfillPayload: cell?
    rejectPayload: cell?
}

// Message unions used by Acton ABI.
type DedustLiquidityDepositOutgoingMessage = DedustDepositLiquidityAll

struct GetBalancesReply {
    reserve0: int
    reserve1: int
}

struct GetTargetBalancesReply {
    reserve0: int
    reserve1: int
}

get fun get_balances(): GetBalancesReply {
    return {
        reserve0: 0,
        reserve1: 0,
    };
}

get fun get_target_balances(): GetTargetBalancesReply {
    return {
        reserve0: 0,
        reserve1: 0,
    };
}
