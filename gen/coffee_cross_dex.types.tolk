// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: fea9c6a1ef5eab2c5ca94d6bef1e33994c5786abeb5264760e150da33bfb3677

contract CoffeeCrossDex {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeCrossDexIncomingMessage
}

// TL-B message bodies.
struct (0x200f9086) CoffeeCrossDexResend {
    queryId: uint64
    nextRecipient: address
    next: cell
    totalGas: coins
    nextGas: coins
}

struct (0xb902e61a) CoffeeCrossDexFailure {
    queryId: uint64
    recipient: address
}

// Message unions used by Acton ABI.
type CoffeeCrossDexIncomingMessage =
    | CoffeeCrossDexResend
    | CoffeeCrossDexFailure

enum Errors {
    InvalidPayloadToResent = 100
    DedustPayloadIsEmpty = 101
    ProxyTonPayloadIsEmpty = 102
    NotAnAdmin = 200
}
