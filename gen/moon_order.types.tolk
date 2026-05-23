// Generated from XML ABI schemas.
// Source schema: schemas/mooncx.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 88c38d29586b5d748badbc7b4dbfe239c25cb85ca9c4586a44e05507a6edf6a6
// Code hash: ee07140b3ccfe261ed28580f60a16bda4c4b9c6d7da7ae05f5b7c7e2b1dfe226

contract MoonOrder {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/mooncx.xml"
    incomingMessages: MoonOrderIncomingMessage
    outgoingMessages: MoonOrderOutgoingMessage
}

// TL-B message bodies.
struct (0x1e8d79c4) MoonCancelOrder {
    queryId: uint64
}

struct (0x99b49842) MoonFillOrder {
    queryId: uint64
    recipient: address
    recipientPayload: cell?
    rejectAddress: address
}

struct (0x49f48ee9) MoonOrderCancelled {
    queryId: uint64
}

struct (0x96612e37) MoonOrderPayout {
    queryId: uint64
}

struct (0xb4fc3916) MoonVestingPayout {
    queryId: uint64
}

// Message unions used by Acton ABI.
type MoonOrderIncomingMessage =
    | MoonCancelOrder
    | MoonFillOrder

type MoonOrderOutgoingMessage =
    | MoonOrderCancelled
    | MoonOrderPayout
    | MoonVestingPayout

struct GetVestingDataReply {
    vestingStartTime: uint64
    vestingTime: uint64
    recipient: address
}

get fun get_status(): uint8 {
    return 0;
}

get fun get_order_amount(): int {
    return 0;
}

get fun get_fill_out(amountIn: int): int {
    return 0;
}

get fun get_vesting_data(): GetVestingDataReply {
    return {
        vestingStartTime: 0,
        vestingTime: 0,
        recipient: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}
