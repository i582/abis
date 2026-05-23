// Generated from XML ABI schemas.
// Source schema: schemas/lockup-wallet.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract LockupUniversal {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/lockup-wallet.xml"
}

struct GetBalancesReply {
    tonBalance: int64
    totalRestrictedValue: int64
    totalLockedValue: int64
}

get fun get_balances(): GetBalancesReply {
    return {
        tonBalance: 0,
        totalRestrictedValue: 0,
        totalLockedValue: 0,
    };
}
