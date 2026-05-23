// Generated from XML ABI schemas.
// Source schema: schemas/tonco.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: bc947d16346c2fdc845b7a446382f59c86acb075e2a31dbfa956cd0c9e54678e

contract ToncoPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/tonco.xml"
    incomingMessages: ToncoPoolIncomingMessage
    outgoingMessages: ToncoPoolOutgoingMessage
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

struct PositionnftV3PositionInitOldFeeCell {
    feeGrowthInside0LastX128: uint256
    feeGrowthInside1LastX128: uint256
    nftIndex: uint64
    jetton0Amount: coins
    jetton1Amount: coins
    tick: int24
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
struct (0xa7fb58f8) Poolv3Swap {
    queryId: uint64
    ownerAddress: address
    sourceWallet: address
    paramsCell: Cell<Poolv3SwapParamsCell>
    payloadsCell: Cell<Poolv3SwapPayloadsCell>
}

struct (0xa1daa96d) PayTo2 {
    queryId: uint64
    reciever0: address
    reciever1: address
    payTo: cell
}

struct (0x3ebe5431) Accountv3AddLiquidity {
    queryId: uint64
    newAmount0: coins
    newAmount1: coins
    newEnough0: coins
    newEnough1: coins
    liquidity: uint128
    tickLower: int24
    tickUpper: int24
}

struct (0xd5ecca2a) PositionnftV3PositionInit {
    queryId: uint64
    userAddress: address
    liquidity: uint128
    tickLower: int24
    tickUpper: int24
    oldFeeCell: Cell<PositionnftV3PositionInitOldFeeCell>
}

// Message unions used by Acton ABI.
type ToncoPoolIncomingMessage = Poolv3Swap

type ToncoPoolOutgoingMessage =
    | PayTo2
    | Accountv3AddLiquidity
    | PositionnftV3PositionInit

struct GetPoolStateAndConfigurationReply {
    routerAddress: address
    adminAddress: address
    controllerAddress: address
    jettonWallet0: address
    jettonWallet1: address
    jettonMinter0: address
    jettonMinter1: address
    isActive: bool
    tickSpacing: int
    baseFee: int
    protocolFee: int
    activeFee: int
    currentTick: int
    currentPrice: int
    currentLiquidity: int
    feeGrowsGlobal0: int
    feeGrowsGlobal1: int
    collectedToken0ProtocolFee: int
    collectedToken1ProtocolFee: int
    mintedNftPositions: int
    reserve0: int
    reserve1: int
    activeNftPositions: int
    occupiedTickets: int
    operationsSinceDeploy: int
}

struct GetChildContractsReply {
    accountCode: cell
    nftPositionCode: cell
    nftCollectionMetadata: cell
    nftItemMetadata: cell
}

get fun getIsActive(): bool {
    return false;
}

get fun getPoolStateAndConfiguration(): GetPoolStateAndConfigurationReply {
    return {
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        controllerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWallet0: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWallet1: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMinter0: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMinter1: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        isActive: false,
        tickSpacing: 0,
        baseFee: 0,
        protocolFee: 0,
        activeFee: 0,
        currentTick: 0,
        currentPrice: 0,
        currentLiquidity: 0,
        feeGrowsGlobal0: 0,
        feeGrowsGlobal1: 0,
        collectedToken0ProtocolFee: 0,
        collectedToken1ProtocolFee: 0,
        mintedNftPositions: 0,
        reserve0: 0,
        reserve1: 0,
        activeNftPositions: 0,
        occupiedTickets: 0,
        operationsSinceDeploy: 0,
    };
}

get fun getChildContracts(): GetChildContractsReply {
    return {
        accountCode: createEmptyCell(),
        nftPositionCode: createEmptyCell(),
        nftCollectionMetadata: createEmptyCell(),
        nftItemMetadata: createEmptyCell(),
    };
}

get fun getAllTickInfos(): cell {
    return createEmptyCell();
}
