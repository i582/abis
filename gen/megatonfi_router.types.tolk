// Generated from XML ABI schemas.
// Source schema: schemas/megaton-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract MegatonfiRouter {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/megaton-fi.xml"
}

struct GetMiningDataReply {
    totalMiningAmount: uint64
    totalMiningRate: uint64
    miningAmountPerSec: uint64
    halfLife: uint64
    totalReward: uint64
    unknown: uint64
}

struct GetLpDataReply {
    poolCount: uint64
    jettonPairToLp: cell
    lpToJettonPair: cell
}

get fun get_mining_data(): GetMiningDataReply {
    return {
        totalMiningAmount: 0,
        totalMiningRate: 0,
        miningAmountPerSec: 0,
        halfLife: 0,
        totalReward: 0,
        unknown: 0,
    };
}

get fun get_lp_data(): GetLpDataReply {
    return {
        poolCount: 0,
        jettonPairToLp: createEmptyCell(),
        lpToJettonPair: createEmptyCell(),
    };
}
