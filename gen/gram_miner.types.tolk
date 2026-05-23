// Generated from XML ABI schemas.
// Source schema: schemas/gram.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: ccae6ffb603c7d3e779ab59ec267ffc22dc1ebe0af9839902289a7a83e4c00f1

contract GramMiner {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/gram.xml"
    incomingMessages: GramMinerIncomingMessage
}

// TL-B message bodies.
struct (0x4d696e65) GramSubmitProofOfWork {
    flags: uint8
    expire: uint32
    whom: bits256
    rdata1: bits256
    rseed: uint128
    rdata2: bits256
}

// Message unions used by Acton ABI.
type GramMinerIncomingMessage = GramSubmitProofOfWork

struct GetPowParamsReply {
    seed: uint128
    powComplexity: int256
    amount: uint64
    interval: uint32
}

get fun get_pow_params(): GetPowParamsReply {
    return {
        seed: 0,
        powComplexity: 0,
        amount: 0,
        interval: 0,
    };
}
