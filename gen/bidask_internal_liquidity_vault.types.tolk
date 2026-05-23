// Generated from XML ABI schemas.
// Source schema: schemas/bidask.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract BidaskInternalLiquidityVault {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bidask.xml"
    incomingMessages: BidaskInternalLiquidityVaultIncomingMessage
    outgoingMessages: BidaskInternalLiquidityVaultOutgoingMessage
}

// TL-B message bodies.
struct (0x214ad1d2) BidaskSaveLiquidityInfo {
    queryId: uint64
    amountX: coins
    amountY: coins
    depositType: uint3
    liquidityDict: map<uint32, int32>
    rejectPayload: cell?
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

// Message unions used by Acton ABI.
type BidaskInternalLiquidityVaultIncomingMessage = BidaskSaveLiquidityInfo

type BidaskInternalLiquidityVaultOutgoingMessage = BidaskAddingLiquidityNotify

struct GetLiquidityDataReply {
    userAddress: address
    poolAddress: address
    amountX: int
    amountY: int
}

get fun get_liquidity_data(): GetLiquidityDataReply {
    return {
        userAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        amountX: 0,
        amountY: 0,
    };
}
