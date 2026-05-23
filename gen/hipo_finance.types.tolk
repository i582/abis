// Generated from XML ABI schemas.
// Source schema: schemas/hipo_finance.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract HipoFinance {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/hipo_finance.xml"
    incomingMessages: HipoFinanceIncomingMessage
}

// TL-B message bodies.
struct (0x3d3761a6) HipoFinanceDepositCoins {
    queryId: uint64
    owner: address
    coins: coins
    ownershipAssignedAmount: coins
    referrer: address
}

struct (0x5be57626) HipoFinanceProxyTokensMinted {
    queryId: uint64
    tokens: coins
    coins: coins
    owner: address
    roundSince: uint32
}

struct (0x5445efee) HipoFinanceTokensMinted {
    queryId: uint64
    tokens: coins
    coins: coins
    owner: address
    roundSince: uint32
}

// Message unions used by Acton ABI.
type HipoFinanceIncomingMessage =
    | HipoFinanceDepositCoins
    | HipoFinanceProxyTokensMinted
    | HipoFinanceTokensMinted
