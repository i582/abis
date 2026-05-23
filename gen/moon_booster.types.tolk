// Generated from XML ABI schemas.
// Source schema: schemas/mooncx.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: ce84c382c8b6ac0d05212bbaa34d05e54e1e30e2cc9289f2d9c9d64726a112a8

contract MoonBooster {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/mooncx.xml"
    outgoingMessages: MoonBoosterOutgoingMessage
}

// TL-B message bodies.
struct (0x96aa1586) MoonBoostPool {
    queryId: uint64
}

// Message unions used by Acton ABI.
type MoonBoosterOutgoingMessage = MoonBoostPool

get fun get_status(): uint8 {
    return 0;
}

get fun get_pool(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
