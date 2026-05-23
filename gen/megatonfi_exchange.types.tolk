// Generated from XML ABI schemas.
// Source schema: schemas/megaton-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract MegatonfiExchange {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/megaton-fi.xml"
}

struct GetLpSwapDataReply {
    swapFee: uint64
    minAmount: uint64
    routerAddress: address
    jettonAAddress: address
    jettonAWalletAddress: address
    jettonABalance: int
    jettonAPendingBalance: int
    jettonBAddress: address
    jettonBWalletAddress: address
    jettonBBalance: int
    jettonBPendingBalance: int
}

struct GetLpMiningDataReply {
    miningAmount: uint64
    datetimeAmount: uint64
    minableTime: uint64
    halfLife: uint64
    lastIndex: uint64
    lastMined: uint64
    miningRateCell: cell
}

get fun get_lp_swap_data(): GetLpSwapDataReply {
    return {
        swapFee: 0,
        minAmount: 0,
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonAAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonAWalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonABalance: 0,
        jettonAPendingBalance: 0,
        jettonBAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonBWalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonBBalance: 0,
        jettonBPendingBalance: 0,
    };
}

get fun get_lp_mining_data(): GetLpMiningDataReply {
    return {
        miningAmount: 0,
        datetimeAmount: 0,
        minableTime: 0,
        halfLife: 0,
        lastIndex: 0,
        lastMined: 0,
        miningRateCell: createEmptyCell(),
    };
}
