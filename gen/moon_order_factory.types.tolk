// Generated from XML ABI schemas.
// Source schema: schemas/mooncx.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: d04737d6f678103a9e448c22109919d0f9cbe05ef1b1a83c5e7b886683a54704

contract MoonOrderFactory {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/mooncx.xml"
    incomingMessages: MoonOrderFactoryIncomingMessage
    outgoingMessages: MoonOrderFactoryOutgoingMessage
}

// TL-B helper types referenced by messages.
struct OrderData {
    rate: uint256
    lock: uint2
    vestingTime: uint64
}

type MoonOrderParams = OrderData

// TL-B message bodies.
struct (0xda067c19) MoonCreateOrder {
    queryId: uint64
    asset2Id: address
    orderData: MoonOrderParams
}

struct (0x983432e2) MoonDeployOrder {
    queryId: uint64
    orderFee: uint8
    orderData: MoonOrderParams
    pipes: cell
}

// Message unions used by Acton ABI.
type MoonOrderFactoryIncomingMessage = MoonCreateOrder

type MoonOrderFactoryOutgoingMessage = MoonDeployOrder

get fun get_id(): uint64 {
    return 0;
}

get fun get_pipe(assetId: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
