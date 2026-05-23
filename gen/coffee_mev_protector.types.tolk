// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 58fbc2dba2684d38b80bfce3dc5a9ffce00af9b464c7b4dc21cf57e3aae11f1c

contract CoffeeMevProtector {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeMevProtectorIncomingMessage
}

// TL-B message bodies.
struct (0x6bc79e7e) CoffeeMevProtectHoldFunds {
    queryId: uint64
}

struct (0xee51ce51) CoffeeMevProtectFailedSwap {
    queryId: uint64
    recipient: address
}

// Message unions used by Acton ABI.
type CoffeeMevProtectorIncomingMessage =
    | CoffeeMevProtectHoldFunds
    | CoffeeMevProtectFailedSwap

enum Errors {
    EmptyTxToResend = 100
    DedustPayloadIsEmpty = 101
    InvalidJettonForwardPayload = 200
    InvalidNativePayload = 201
    NotAnAdmin = 300
}
