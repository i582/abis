// Generated from XML ABI schemas.
// Source schema: schemas/mooncx.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract MoonPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/mooncx.xml"
    incomingMessages: MoonPoolIncomingMessage
    outgoingMessages: MoonPoolOutgoingMessage
}

// TL-B helper types referenced by messages.
struct SwapParams {
    minOut: coins
    deadline: uint64
    excess: address
    referral: address
    nextFulfill: Cell<MoonNextPayload>?
    nextReject: Cell<MoonNextPayload>?
}

struct NextPayload {
    recipient: address
    payload: cell?
}

type MoonSwapParams = SwapParams

type MoonNextPayload = NextPayload

// TL-B message bodies.
struct (0xb37a900b) MoonSwap {
    queryId: uint64
    amount: coins
    swapParams: MoonSwapParams
}

struct (0xb31db781) MoonDepositLiquidity {
    queryId: uint64
    minLpOut: coins
}

struct (0x96aa1586) MoonBoostPool {
    queryId: uint64
}

struct (0x6b1b8a3f) MoonProvideLiquidity {
    queryId: uint64
    amount1: coins
    amount2: coins
    user: address
    minLpAmount: coins
}

struct (0xcb7f38d6) MoonSwapSucceed {}

struct (0xc47c1f57) MoonSwapFailed {}

struct (0x737b4eb6) MoonProvideLiquiditySucceed {}

struct (0xbaaa2c1b) MoonDepositRecord {
    queryId: uint64
    assetNumber: uint8
    depositAmount: coins
    minLpAmount: coins
}

struct (0x90d3b4ad) MoonWithdrawLiquidityPayout {
    queryId: uint64
}

struct (0xff86f067) MoonWithdrawLiquidityNotify {
    queryId: uint64
}

// Message unions used by Acton ABI.
type MoonPoolIncomingMessage =
    | MoonSwap
    | MoonDepositLiquidity
    | MoonBoostPool
    | MoonProvideLiquidity

type MoonPoolOutgoingMessage =
    | MoonSwapSucceed
    | MoonSwapFailed
    | MoonProvideLiquiditySucceed
    | MoonDepositRecord
    | MoonWithdrawLiquidityPayout
    | MoonWithdrawLiquidityNotify

struct GetReservesReply {
    assetId1: address
    reserve1: int
    assetId2: address
    reserve2: int
}

struct GetAssetsReply {
    asset1Id: address
    asset2Id: address
}

get fun get_reserves(): GetReservesReply {
    return {
        assetId1: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        reserve1: 0,
        assetId2: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        reserve2: 0,
    };
}

get fun get_assets(): GetAssetsReply {
    return {
        asset1Id: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        asset2Id: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}
