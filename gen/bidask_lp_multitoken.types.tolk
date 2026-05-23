// Generated from XML ABI schemas.
// Source schema: schemas/bidask.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract BidaskLpMultitoken {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bidask.xml"
    incomingMessages: BidaskLpMultitokenIncomingMessage
    outgoingMessages: BidaskLpMultitokenOutgoingMessage
}

// TL-B message bodies.
struct (0x73403c43) BidaskBurn {
    queryId: uint64
    tokensToBurn: map<uint32, int32>
    forwardPayload: cell?
}

struct (0xebd6ec83) BidaskBurnAll {
    queryId: uint64
    forwardPayload: cell?
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

struct (0x0dc8bb28) BidaskLiquidityAddedNotify {
    queryId: uint64
    forwardPayload: cell?
}

// Message unions used by Acton ABI.
type BidaskLpMultitokenIncomingMessage =
    | BidaskBurn
    | BidaskBurnAll

type BidaskLpMultitokenOutgoingMessage =
    | BidaskInternalBurn
    | BidaskLiquidityAddedNotify

enum Errors {
    InsufficientGasForOperation = 83
}

get fun get_bins_number(): int {
    return 0;
}
