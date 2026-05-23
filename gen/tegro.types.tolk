// Generated from XML ABI schemas.
// Source schema: schemas/tegro.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Tegro {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/tegro.xml"
    incomingMessages: TegroIncomingMessage
    forceAbiExport: TegroJettonPayload
}

// TL-B message bodies.
struct (0x600c00fd) TegroSwapTon {
    queryId: uint64
    extract: bool
    maxIn: coins
    minOut: coins
    destination: address
    errorDestination: address
    ref: Cell<address>?
}

struct (0x287e167a) TegroAddLiquidity {
    amountA: coins
    abountB: coins
}

struct (0x01fb7a25) TegroJettonSwap {
    extract: bool
    maxIn: coins
    minOut: coins
    destination: address
    errorDestination: address
    payload: cell?
}

// Message unions used by Acton ABI.
type TegroIncomingMessage = TegroSwapTon

type TegroJettonPayload =
    | TegroAddLiquidity
    | TegroJettonSwap
