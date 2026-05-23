// Generated from XML ABI schemas.
// Source schema: schemas/dedust.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract DedustV2Cpmm {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/dedust.xml"
}

struct GetPoolDataReply {
    status: int8
    depositActive: bool
    swapActive: bool
    assetX: address
    assetY: address
    walletsByAssets: cell?
    assetsByWallets: cell?
    walletsResolutions: cell?
    baseFeeBps: int32
    reserveX: int
    reserveY: int
    liquidity: int
    protocolFeeX: int
    protocolFeeY: int
    createdFeeX: int
    createdFeeY: int
    xLpFeePerToken: int
    yLpFeePerToken: int
    rewards: cell?
}

get fun get_pool_data(): GetPoolDataReply {
    return {
        status: 0,
        depositActive: false,
        swapActive: false,
        assetX: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        assetY: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        walletsByAssets: null,
        assetsByWallets: null,
        walletsResolutions: null,
        baseFeeBps: 0,
        reserveX: 0,
        reserveY: 0,
        liquidity: 0,
        protocolFeeX: 0,
        protocolFeeY: 0,
        createdFeeX: 0,
        createdFeeY: 0,
        xLpFeePerToken: 0,
        yLpFeePerToken: 0,
        rewards: null,
    };
}
