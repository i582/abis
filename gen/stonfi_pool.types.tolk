// Generated from XML ABI schemas.
// Source schema: schemas/ston-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StonfiPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/ston-fi.xml"
}

struct GetPoolDataReply {
    isLocked: bool
    routerAddress: address
    totalSupply: int
    reserve0: int
    reserve1: int
    token0WalletAddress: address
    token1WalletAddress: address
    lpFee: uint16
    protocolFee: uint16
    protocolFeeAddress: address
    collectedToken0ProtocolFee: int
    collectedToken1ProtocolFee: int
    amp: uint128
    rate: uint128
    w0: uint128
    rateSetter: address
}

get fun get_pool_data(): GetPoolDataReply {
    return {
        isLocked: false,
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        totalSupply: 0,
        reserve0: 0,
        reserve1: 0,
        token0WalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        token1WalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        lpFee: 0,
        protocolFee: 0,
        protocolFeeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        collectedToken0ProtocolFee: 0,
        collectedToken1ProtocolFee: 0,
        amp: 0,
        rate: 0,
        w0: 0,
        rateSetter: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}
