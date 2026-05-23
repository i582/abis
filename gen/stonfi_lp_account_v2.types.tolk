// Generated from XML ABI schemas.
// Source schema: schemas/ston-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StonfiLpAccountV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/ston-fi.xml"
    incomingMessages: StonfiLpAccountV2IncomingMessage
}

struct StonfiAddLiquidityV2AdditionalFields {
    refundAddress: address
    excessAddress: address
}

// TL-B message bodies.
struct (0x50c6a654) StonfiAddLiquidityV2 {
    queryId: uint64
    newAmount0: coins
    newAmount1: coins
    minLpOut: coins
    fwdAmount: coins
    bothPositive: uint1
    toUser: address
    customPayloadCs: cell?
    additionalFields: Cell<StonfiAddLiquidityV2AdditionalFields>
}

struct (0x29d22935) PtonResetGas {
    queryId: uint64
}

// Message unions used by Acton ABI.
type StonfiLpAccountV2IncomingMessage =
    | StonfiAddLiquidityV2
    | PtonResetGas

struct GetLpAccountDataReply {
    userAddress: address
    poolAddress: address
    amount0: int
    amount1: int
}

get fun get_lp_account_data(): GetLpAccountDataReply {
    return {
        userAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        amount0: 0,
        amount1: 0,
    };
}
