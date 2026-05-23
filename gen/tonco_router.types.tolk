// Generated from XML ABI schemas.
// Source schema: schemas/tonco.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 9b9891eaa7db7becc6ccdda1bd9a8d25dc3df2817d57e4b27ec003daf81a4439

contract ToncoRouter {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/tonco.xml"
    incomingMessages: ToncoRouterIncomingMessage
    outgoingMessages: ToncoRouterOutgoingMessage
}

struct PayToCode0CoinsinfoCell {
    amount0: coins
    jetton0Address: address
    amount1: coins
    jetton1Address: address
}

struct PayToCode200CoinsinfoCellPayloadCell {
    payloadAmount0: coins
    payloadCell0: cell?
    payloadAmount1: coins
    payloadCell1: cell?
}

struct PayToCode200CoinsinfoCell {
    amount0: coins
    jetton0Address: address
    amount1: coins
    jetton1Address: address
    payloadCell: Cell<PayToCode200CoinsinfoCellPayloadCell>
}

struct PayToCode200IndexerSwapInfoCell {
    liquidity: uint128
    priceSqrt: uint160
    tick: int24
    feeGrowthGlobal0X128: int256
    feeGrowthGlobal1X128: int256
}

struct PayToCode201CoinsinfoCellPayloadCell {
    payloadAmount0: coins
    payloadCell0: cell?
    payloadAmount1: coins
    payloadCell1: cell?
}

struct PayToCode201CoinsinfoCell {
    amount0: coins
    jetton0Address: address
    amount1: coins
    jetton1Address: address
    payloadCell: Cell<PayToCode201CoinsinfoCellPayloadCell>
}

struct PayToCode201IndexerBurnInfoCell {
    nftIndex: uint64
    liquidityBurned: uint128
    tickLower: int24
    tickUpper: int24
    tick: int24
}

struct PayToCode230CoinsinfoCellPayloadCell {
    payloadAmount0: coins
    payloadCell0: cell?
    payloadAmount1: coins
    payloadCell1: cell?
}

struct PayToCode230CoinsinfoCell {
    amount0: coins
    jetton0Address: address
    amount1: coins
    jetton1Address: address
    payloadCell: Cell<PayToCode230CoinsinfoCellPayloadCell>
}

struct PayToCode230IndexerSwapInfoCell {
    liquidity: uint128
    priceSqrt: uint160
    tick: int24
    feeGrowthGlobal0X128: int256
    feeGrowthGlobal1X128: int256
}

struct Poolv3SwapParamsCell {
    amount: coins
    sqrtPriceLimitX96: uint160
    minOutAmount: coins
}

struct Poolv3SwapPayloadsCell {
    targetAddress: address
    okForwardAmount: coins
    okForwardPayload: cell?
    retForwardAmount: coins
    retForwardPayload: cell?
}

// TL-B parser notes:
// - type_1: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 58]).
// - type_2: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 60]).
// - type_3: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 60]).
// - type_4: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 60]).

// TL-B helper types referenced by messages.
struct (0x00000000) PayToCode0 {
    seqno: uint64
    coinsinfoCell: Cell<PayToCode0CoinsinfoCell>?
}

struct (0x000000c8) PayToCode200 {
    seqno: uint64
    coinsinfoCell: Cell<PayToCode200CoinsinfoCell>?
    indexerSwapInfoCell: Cell<PayToCode200IndexerSwapInfoCell>?
}

struct (0x000000c9) PayToCode201 {
    seqno: uint64
    coinsinfoCell: Cell<PayToCode201CoinsinfoCell>?
    indexerBurnInfoCell: Cell<PayToCode201IndexerBurnInfoCell>?
}

struct (0x000000e6) PayToCode230 {
    seqno: uint64
    coinsinfoCell: Cell<PayToCode230CoinsinfoCell>?
    indexerSwapInfoCell: Cell<PayToCode230IndexerSwapInfoCell>?
}

type PayTo =
    | PayToCode0
    | PayToCode200
    | PayToCode201
    | PayToCode230

// TL-B message bodies.
struct (0xa1daa96d) PayTo2 {
    queryId: uint64
    reciever0: address
    reciever1: address
    payTo: cell
}

struct (0xa7fb58f8) Poolv3Swap {
    queryId: uint64
    ownerAddress: address
    sourceWallet: address
    paramsCell: Cell<Poolv3SwapParamsCell>
    payloadsCell: Cell<Poolv3SwapPayloadsCell>
}

struct (0x4468de77) Poolv3FundAccount {
    queryId: uint64
    ownerAddr: address
    amount0: coins
    amount1: coins
    enough0: coins
    enough1: coins
    liquidity: uint128
    tickLower: int24
    tickUpper: int24
}

// Message unions used by Acton ABI.
type ToncoRouterIncomingMessage = PayTo2

type ToncoRouterOutgoingMessage =
    | Poolv3Swap
    | Poolv3FundAccount

struct GetRouterStateReply {
    routerAdminAddress: address
    poolAdminAddress: address
    poolFactoryAddress: address
    activeFlags: int
    internalNumber: int
}

struct GetChildContractsReply {
    poolCode: cell
    accountCode: cell
    nftPositionCode: cell
}

get fun getRouterState(): GetRouterStateReply {
    return {
        routerAdminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolAdminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolFactoryAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        activeFlags: 0,
        internalNumber: 0,
    };
}

get fun getChildContracts(): GetChildContractsReply {
    return {
        poolCode: createEmptyCell(),
        accountCode: createEmptyCell(),
        nftPositionCode: createEmptyCell(),
    };
}
