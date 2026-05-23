// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormPositionManager {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: StormPositionManagerIncomingMessage
    outgoingMessages: StormPositionManagerOutgoingMessage
}

// TL-B helper types referenced by messages.
struct Parameters {
    discount: uint32
    rebate: uint32
}

struct OrderPayload {
    orderType: uint4
    orderIndex: uint3
    direction: uint1
}

struct PositionChange {
    size: uint128
    direction: uint1
    margin: coins
    openNotional: coins
    lastUpdatedCumulativePremium: uint64
    fee: uint32
    discount: uint32
    rebate: uint32
    lastUpdatedTimestamp: uint32
}

struct AmmChange {
    quoteAssetReserve: coins
    quoteAssetReserveWeight: coins
    baseAssetReserve: coins
    totalLongPositionSize: coins
    totalShortPositionSize: coins
    openInterestLong: coins
    openInterestShort: coins
}

struct OraclePayload {
    priceData: Cell<OraclePriceData>
    signatures: Cell<Signatures>
}

struct PriceData {
    price: coins
    spread: coins
    anotherSpread: uint32
    assetId: uint16
}

struct Signatures {
    data: cell
}

type OraclePriceData = PriceData

// TL-B message bodies.
struct (0x12d9601d) StormTakeReferralFees {
    referralFees: Cell<Parameters>
}

struct (0x67134629) StormCancelOrder {
    orderType: uint4
    orderIndex: uint3
    direction: uint1
    gasToAddress: address
}

struct (0xa39843f4) StormCreateOrder {
    orderPayload: Cell<OrderPayload>
}

struct (0xcf90d618) StormCompleteOrder {
    orderType: uint4
    orderIndex: uint3
    direction: uint1
    originOpcode: uint32
    indexPrice: coins
    settlementOraclePrice: coins?
    position: Cell<PositionChange>
    amm: Cell<AmmChange>
}

struct (0x9d2ec640) StormActivateOrder {
    orderIndex: uint3
    activatedOrder: Cell<OrderPayload>
}

struct (0x60dfc677) StormUpdatePosition {
    direction: uint1
    originOpcode: uint32
    indexPrice: coins
    settlementOraclePrice: coins?
    position: Cell<PositionChange>
    amm: Cell<AmmChange>
}

struct (0x5d1b17b8) StormUpdatePositionWithStopLoss {
    direction: uint1
    stopTriggerPrice: coins
    takeTriggerPrice: coins
    originOpcode: uint32
    indexPrice: coins
    settlementOraclePrice: coins?
    position: Cell<PositionChange>
    amm: Cell<AmmChange>
}

struct (0x8865b402) StormProvidePosition {
    orderType: uint4
    orderIndex: uint3
    direction: uint1
    executorIndex: uint32
    oraclePayload: Cell<OraclePayload>
}

struct (0x3a943ce6) StormOrderCreated {}

struct (0x69d08679) StormOrderCanceled {}

// Message unions used by Acton ABI.
type StormPositionManagerIncomingMessage =
    | StormTakeReferralFees
    | StormCancelOrder
    | StormCreateOrder
    | StormCompleteOrder
    | StormActivateOrder
    | StormUpdatePosition
    | StormUpdatePositionWithStopLoss
    | StormProvidePosition

type StormPositionManagerOutgoingMessage =
    | StormOrderCreated
    | StormOrderCanceled

struct GetPositionManagerContractDataReply {
    traderAddress: address
    vaultAddress: address
    vammAddress: address
    longRecord: cell
    shortRecord: cell
    ordersDict: cell
    referralData: cell
    ordersBitset: cell
}

enum Errors {
    PositionLocked = 500
    NotAnAmm = 501
    NotATrader = 502
    NotFound = 504
    PositionExists = 505
    NotAVault = 507
    WrongOrderType = 508
    OrderExists = 509
    WrongOrderParams = 510
    PositionNotFound = 511
    Expired = 512
    NoFreeOrder = 513
    OrderNotFound = 514
    VammBounced = 515
    MaxOrders = 516
    OrderCanceled = 517
    MinProvideGas = 518
    MinProvideOrderGas = 519
    MinCancelOrderGas = 520
    NotAReferral = 521
    NotInited = 522
    PositionManagerInited = 523
    WrongInitAddr = 524
    LateMigration = 525
    DirectionMismatch = 526
    MarketOrderCanceled = 527
    WrongOperation = 65535
}

get fun get_position_manager_data(): cell {
    return createEmptyCell();
}

get fun get_position_manager_contract_data(): GetPositionManagerContractDataReply {
    return {
        traderAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        vaultAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        vammAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        longRecord: createEmptyCell(),
        shortRecord: createEmptyCell(),
        ordersDict: createEmptyCell(),
        referralData: createEmptyCell(),
        ordersBitset: createEmptyCell(),
    };
}

get fun get_is_inited(): bool {
    return false;
}

get fun get_version(): uint32 {
    return 0;
}
