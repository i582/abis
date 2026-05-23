// Generated from XML ABI schemas.
// Source schema: schemas/jettons.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract ScaledUi {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/jettons.xml"
    outgoingMessages: ScaledUiOutgoingMessage
}

// TL-B message bodies.
struct (0xac392598) DisplayMultiplierChanged {
    numerator: coins
    denominator: coins
    comment: string?
}

// Message unions used by Acton ABI.
type ScaledUiOutgoingMessage = DisplayMultiplierChanged

struct GetDisplayMultiplierReply {
    numerator: int
    denominator: int
}

get fun get_display_multiplier(): GetDisplayMultiplierReply {
    return {
        numerator: 0,
        denominator: 0,
    };
}
