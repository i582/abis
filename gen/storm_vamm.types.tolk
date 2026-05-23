// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormVamm {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: StormVammIncomingMessage
    outgoingMessages: StormVammOutgoingMessage
}

// TL-B helper types referenced by messages.
struct AmmSettings {
    fee: uint32
    rolloverFee: uint32
    fundingPeriod: uint32
    initMarginRatio: uint32
    maintenanceMarginRatio: uint32
    liquidationFeeRatio: uint32
    partialLiquidationRatio: uint32
    spreadLimit: uint32
    maxPriceImpact: uint32
    maxPriceSpread: uint32
    maxOpenNotional: uint32
    feeToStakersPercent: uint32
    fundingMode: uint2
    minPartialLiquidationNotional: coins
    minLeverage: uint32
}

struct OracleData {
    updateMsg: Cell<UpdateMsg>
    signatures: cell
}

struct (0b0) Long {}

struct (0b1) Short {}

struct (0x0) StopLossOrder {
    expiration: uint32
    direction: cell
    amount: coins
    triggerPrice: coins
}

struct (0x1) TakeProfitOrder {
    expiration: uint32
    direction: cell
    amount: coins
    triggerPrice: coins
}

struct LimitMarketOrder {
    order: cell
}

struct (0x4) AddMargin {
    direction: cell
    amount: coins
}

struct (0x5) RemoveMargin {
    direction: cell
    amount: coins
}

struct (0x8) RequestOrder {
    selector: cell
    order: cell
}

struct PositionData {
    size: int128
    direction: cell
    margin: coins
    openNotional: coins
    lastUpdatedCumulativePremium: int64
    fee: uint32
    discount: uint32
    rebate: uint32
    lastUpdatedTimestamp: uint32
}

struct OraclePayload {
    priceData: Cell<OraclePriceData>
    signatures: Cell<Signatures>
}

struct AddressesData {
    traderAddress: address
    smartAccountFactoryAddress: address
    vaultAddress: address
}

struct (0x0) RefData0 {}

struct (0x1) RefData1 {
    data: ReferralDataV2
}

struct (0x2) RefData2 {
    data: ReferralDataV2
}

struct (0b0) UserIntent {
    signature: bits512
    intent: Cell<UserIntent2>
    oraclePayload: cell
    nextIntent: cell?
}

struct (0b1) ExecutorIntent {
    intent: Cell<ExecutorIntent2>
    oraclePayload: cell
    nextIntent: cell?
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

struct ReferralData {
    amount: coins
    index: uint32
}

struct ExecutorData {
    splitExecutorRewards: uint8
    amount: coins
    index: uint32
}

struct OrderPayload {
    orderType: uint4
    orderIndex: uint3
    direction: uint1
}

struct ReferrerData {
    referrerAddress: address
    referrerPart: uint8
}

struct NotificationPayloadV2 {
    bundleSenderAddress: address
    balanceDelta: coins
    ammAddress: address
    direction: cell
    positionData: Cell<PositionData>?
}

struct IntentLog {
    typeValue: cell
    size: int128
    margin: coins
    openNotional: coins
    lastUpdatedCpf: int64
    realizedPnl: int64
    fundingPayment: int64
    rolloverFee: uint64
    positionFeeRate: uint32
    executorFeeRate: uint32
    positionFeeAmount: coins
    executorFeeAmount: coins
    feeToStakersPercent: uint32
    additionalData: Cell<AdditionalLogData>
}

struct UpdateMsg {
    price: coins
    spread: coins
    timestamp: uint32
    assetIndex: uint16
}

struct (0x2) LimitOrder {
    expiration: uint32
    direction: cell
    amount: coins
    leverage: uint64
    limitPrice: coins
    stopPrice: coins
    stopTriggerPrice: coins
    takeTriggerPrice: coins
}

struct (0x3) MarketOrder {
    expiration: uint32
    direction: cell
    amount: coins
    leverage: uint64
    limitPrice: coins
    stopPrice: coins
    stopTriggerPrice: coins
    takeTriggerPrice: coins
}

struct (0b0) ExecuteStop {}

struct (0b1) ExecuteTake {}

struct PriceData {
    price: coins
    spread: coins
    anotherSpread: uint32
    assetId: uint16
}

struct Signatures {
    data: cell
}

struct ReferralDataV2 {
    discount: uint32
    rebate: uint32
    refInfo: map<uint4, ReferrerData>
}

struct UserIntent2 {
    queryId: UserQueryId
    createdAt: uint32
    referenceQueryId: UserQueryId?
    publicKey: bits256
    intent: Cell<UserIntentPayload>
}

struct (0x00) Single {
    priceOraclePayload: Cell<SingleOraclePayload>
    lazerMessage: Cell<LazerMessage>?
}

struct (0x01) Double {
    priceOraclePayload: Cell<DoubleOraclePayload>
    lazerMessage: Cell<LazerMessage>?
}

struct (0x02) SingleWithCreated {
    priceOraclePayload: Cell<SingleOraclePayload>
    createdOraclePayload: cell
    lazerMessage: Cell<LazerMessage>?
    createdLazerMessage: Cell<LazerMessage>?
}

struct (0x03) DoubleWithCreated {
    priceOraclePayload: Cell<DoubleOraclePayload>
    createdOraclePayload: cell
    lazerMessage: Cell<LazerMessage>?
    createdLazerMessage: Cell<LazerMessage>?
}

struct ExecutorIntent2 {
    ammAddress: address
    saAddress: address
    order: cell
}

struct (0x00) Increase {}

struct (0x01) Close {}

struct (0x02) AddMargin2 {}

struct (0x03) RemoveMargin2 {}

struct AdditionalLogData {
    indexPrice: coins
}

struct UserQueryId {
    shift: uint13
    bitNumber: uint10
}

struct UserIntentPayload {
    ammAddress: address
    saAddress: address
    order: cell
}

struct WithoutSettlement {
    updateMsg: Cell<UpdateMsgV2>
    signatures: cell
}

struct LazerMessage {
    magic: uint32
    r: uint256
    s: uint256
    v: uint8
    payloadLength: uint16
    payload: cell
}

struct WithSettlement {
    updateMsg: Cell<UpdateMsgV2>
    signatures: cell
    settlementUpdateMsg: Cell<UpdateMsgV2>
    settlementSignatures: cell
}

struct (0x00) CreatedPrice {
    updateMsg: Cell<UpdateMsgV2>
    signatures: cell
}

struct (0x01) CreatedPriceWithSettlement {
    updateMsg: Cell<UpdateMsgV2>
    signatures: cell
    settlementUpdateMsg: Cell<UpdateMsgV2>
    settlementSignatures: cell
}

struct (0x6) Liquidate {
    direction: cell
}

struct (0x7) ForceClose {
    direction: cell
}

struct (0x9) ForceCloseMaxLeverage {
    direction: cell
}

struct UpdateMsg2 {
    price: coins
    spread: coins
    timestamp: uint32
    assetIndex: uint16
    pauseAt: uint32
    unpauseAt: uint32
    vpiSpread: coins
    vpiMarketDepthLong: coins
    vpiMarketDepthShort: coins
    vpiCoefficient: uint64
}

struct (0b0) Single2 {
    magic: uint32
    timestamp: uint64
    channelId: uint8
    numberOfFeeds: uint8
    indexFeedId: uint32
    indexFeed: LazerFeed
}

struct (0b1) Double2 {
    magic: uint32
    timestamp: uint64
    channelId: uint8
    numberOfFeeds: uint8
    indexFeedId: uint32
    indexFeed: LazerFeed
    settlementFeedId: uint32
    settlementFeed: LazerFeed
}

struct LazerFeed {
    numberOfProperties: uint8
    pricePropertyId: uint8
    pricePropertyValue: uint64
    exponentPropertyId: uint8
    exponentPropertyValue: int16
}

type Direction =
    | Long
    | Short

type UserOrder =
    | StopLossOrder
    | TakeProfitOrder
    | LimitMarketOrder
    | AddMargin
    | RemoveMargin
    | RequestOrder

type RefData =
    | RefData0
    | RefData1
    | RefData2

type Intent =
    | UserIntent
    | ExecutorIntent

type CreateOrder =
    | LimitOrder
    | MarketOrder

type ExecuteSelector =
    | ExecuteStop
    | ExecuteTake

type OraclePriceData = PriceData

type OraclePayloadV2 =
    | Single
    | Double
    | SingleWithCreated
    | DoubleWithCreated

type LogType =
    | Increase
    | Close
    | AddMargin2
    | RemoveMargin2

type SingleOraclePayload = WithoutSettlement

type DoubleOraclePayload = WithSettlement

type CreatedOraclePayload =
    | CreatedPrice
    | CreatedPriceWithSettlement

type ExecutorOrder =
    | Liquidate
    | ForceClose
    | ForceCloseMaxLeverage

type UpdateMsgV2 = UpdateMsg2

type LazerPayload =
    | Single2
    | Double2

// TL-B message bodies.
struct (0xedcd36a6) StormChangeSettings {
    redirectAddr: address
    settings: Cell<AmmSettings>
}

struct (0xb652c441) StormPayFunding {
    oracleRef: Cell<OracleData>
}

struct (0x29c102d1) StormVammInit {
    redirectAddr: address
    code: cell
    data: cell
}

struct (0xde1ddbcc) StormExecuteOrder {
    direction: cell
    orderIndex: uint3
    traderAddr: address
    prevAddr: address
    refAddr: address
    executorIndex: uint32
    order: cell
    position: Cell<PositionData>
    oraclePayload: Cell<OraclePayload>
}

struct (0x1bea50f1) TakePositionV2 {
    queryId: uint64
    bundleSenderAddress: address
    ammAddress: address
    direction: cell
    spentAmount: coins
    addresses: Cell<AddressesData>
    ref: cell
    position: Cell<PositionData>
    intent: cell
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

struct (0x3475fdd2) StormVaultTradeNotification {
    ammIndex: uint16
    freeAmount: uint16
    lockedAmount: int64
    exchangeAmount: int64
    withdrawLockedAmount: int64
    feeToStakers: int64
    withdrawAmount: int64
    traderAddr: address
    referralParams: Cell<ReferralData>?
    executorParams: Cell<ExecutorData>?
}

struct (0x60dfc677) StormUpdatePosition {
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

struct (0x666392ee) StormFailedBundleExecution {
    queryId: uint64
    assetId: uint16
    errorCode: uint16
    spentAmount: coins
    saAddress: address
    ammAddress: address
    direction: cell
    bundleSenderAddress: address
    intent: cell
}

struct (0x28d36491) StormTradeNotificationV2 {
    queryId: uint64
    assetId: uint16
    freeAmount: int64
    lockedAmount: int64
    exchangeAmount: int64
    withdrawLockedAmount: uint64
    feeToStakers: uint64
    executorAmount: uint64
    totalReferrerAmount: uint64
    refCount: uint4
    referralData: map<uint4, ReferrerData>
    saAddress: address
    notificationPayload: Cell<NotificationPayloadV2>
}

struct (0x812e8f40) IntentLog2 {
    logDict: map<uint8, IntentLog>
}

// Message unions used by Acton ABI.
type StormVammIncomingMessage =
    | StormChangeSettings
    | StormPayFunding
    | StormVammInit
    | StormExecuteOrder
    | TakePositionV2

type StormVammOutgoingMessage =
    | StormCompleteOrder
    | StormVaultTradeNotification
    | StormUpdatePosition
    | StormActivateOrder
    | StormFailedBundleExecution
    | StormTradeNotificationV2
    | IntentLog2

struct GetAmmNameReply {
    vaultAddr: address
    assetId: uint16
}

struct GetAmmStatusReply {
    closeOnly: bool
    paused: bool
    stopped: bool
    pauseAt: uint32
    unpauseAt: uint32
}

struct GetAmmStateReply {
    quoteAssetReserve: uint64
    baseAssetReserve: uint64
    quoteAssetWeight: uint64
    totalLongPositionSize: uint64
    totalShortPositionSize: uint64
    openInterestLong: uint64
    openInterestShort: uint64
    latestLongCumulativePremiumFraction: int64
    latestShortCumulativePremiumFraction: int64
    nextFundingBlockTimestamp: uint32
}

struct GetExchangeSettingsReply {
    fee: uint32
    rolloverFee: uint32
    fundingPeriod: uint32
    initMarginRatio: uint32
    maintenanceMarginRatio: uint32
    liquidationFeeRatio: uint32
    partialLiquidationRatio: uint32
    spreadLimit: uint32
    maxPriceImpact: uint32
    maxPriceSpread: uint32
    maxOpenNotional: coins
    feeToStakersPercent: uint32
    fundingMode: uint8
    minPartialLiquidationNotional: coins
    minInitMarginRatio: uint32
    executorFee: coins
    closePositionTimeDelta: uint32
    maxUnrealizedPnl: uint64
    directIncreaseEnabled: bool
    directCloseEnabled: bool
    executorsWhitelist: cell
    lowFundingFnA: uint64
    lowFundingFnB: uint64
    highFundingFnA: int64
    highFundingFnB: uint64
    inflectionPoint: uint64
    v3CloseDelay: uint32
}

struct GetCanLiquidateReply {
    canExecute: bool
    spotMarginRatio: uint32
    liquidationMarginRatio: uint32
    errorCode: uint16
}

struct GetCanForceCloseReply {
    canClose: bool
    errorCode: uint16
}

struct GetCanExecuteOrderReply {
    canExecute: bool
    spotPrice: coins
    errorCode: uint16
}

struct GetRemainMarginWithFundingPaymentReply {
    remainMargin: coins
    fundindPayment: coins
    marginRatio: coins
    unrealizedPnl: coins
    badDebt: coins
    positionNotional: coins
    rolloverFee: coins
    newPrice: coins
    spotPrice: coins
}

struct GetValidateSignaturesReply {
    newPrice: coins
    newSettlementPrice: coins
    newCreatedPrice: coins?
    settlementCreatedPrice: coins?
    pauseTime: uint32
}

struct GetOracleDataReply {
    oracleLastPrice: coins
    oracleLastSpread: coins
    oracleLastTimestamp: uint32
    oracleMaxDeviation: coins
    oracleValidityPeriod: uint32
    oraclePublicKeysCount: uint8
    oraclePublicKeysRef: cell
}

struct GetFundingReply {
    longFunding: coins
    shortFunding: coins
    premiumToVault: uint32
    syncExchangeAmount: coins
    spotPrice: coins
}

struct GetComputeFundingDataReply {
    shortPremiumFraction: coins
    longPremiumFraction: coins
    premiumToVault: coins
    fundingPeriods: uint32
}

struct GetFundingSettingsReply {
    lowFundingFnA: uint64
    lowFundingFnB: uint64
    highFundingFnA: int64
    highFundingFnB: uint64
    inflectionPoint: uint64
}

struct GetDayTradingDataReply {
    active: bool
    maxLeverage: uint32
}

struct GetLazerDataReply {
    oracleFlag: uint8
    indexAssetPythId: uint32
    settlementAssetPythId: uint32
}

enum Errors {
    InvalidVaultAddress = 157
    InvalidAmmAddress = 158
    NotAnAdmin = 401
    NotEnoughGas = 404
    WrongPositionAddress = 405
    NotAVault = 407
    LessMarginRatio = 409
    WrongSize = 411
    PositionBadDebt = 412
    WrongPositionTimestamp = 413
    WrongAmount = 414
    HighPriceImpact = 415
    OverSpreadLimit = 416
    OverMaxOpenNotional = 417
    NotExecutableByStop = 418
    NotExecutable = 419
    WrongBaseAssetReserve = 420
    WrongQuoteAssetReserve = 421
    WrongId = 422
    QuorumFailed = 423
    InvalidTimestamp = 424
    InvalidDiff = 425
    WrongLeverage = 426
    SlippageTolerance = 427
    NegativeMarginToTrader = 428
    OrderExpired = 429
    WrongLiquidity = 430
    InvalidBaseAssetAmount = 431
    Paused = 432
    CloseOnly = 433
    MarketIsActive = 434
    MarketIsNotActive = 435
    WrongReferralItem = 436
    WrongExecutorItem = 437
    StartAlreadySet = 438
    EndAlreadySet = 439
    NotStarted = 440
    Ended = 441
    WrongStartDate = 442
    WrongEndDate = 443
    WrongExecutorAddress = 444
    DirectIncreaseDisabled = 445
    DirectCloseDisabled = 446
    UnknownOraclePayload = 447
    WrongSingleOraclePayload = 448
    WrongPause = 450
    MarketPaused = 451
    NotEnoughPnl = 452
    HighCumulativePriceImpact = 453
    PauseAfterUnpause = 454
    TooCloseToLiquidation = 455
    UnpauseNotDefined = 456
    InvalidPauseAt = 457
    InvalidUnpauseAt = 458
    DayTradingDisabled = 459
    NotCloseToPause = 460
    NotEnoughLeverage = 461
    InvalidOracleTimestamp = 462
    MarginIsSufficient = 463
    InvalidVpiPrice = 464
    WrongSmartAccountAddress = 470
    V3CloseCooldown = 471
    InvalidMessageMagic = 1000
    InvalidPayloadMagic = 1001
    InvalidFeedsCount = 1002
    InvalidIndexFeedId = 1003
    InvalidPropertyCount = 1005
    InvalidPropertyId = 1006
    InvalidLazerSignature = 1007
    InvalidVammType = 1008
    WrongOperation = 65535
}

get fun get_pause_time(): uint32 {
    return 0;
}

get fun get_amm_contract_data(): cell {
    return createEmptyCell();
}

get fun get_amm_name(): GetAmmNameReply {
    return {
        vaultAddr: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        assetId: 0,
    };
}

get fun get_amm_status(): GetAmmStatusReply {
    return {
        closeOnly: false,
        paused: false,
        stopped: false,
        pauseAt: 0,
        unpauseAt: 0,
    };
}

get fun get_amm_state(): GetAmmStateReply {
    return {
        quoteAssetReserve: 0,
        baseAssetReserve: 0,
        quoteAssetWeight: 0,
        totalLongPositionSize: 0,
        totalShortPositionSize: 0,
        openInterestLong: 0,
        openInterestShort: 0,
        latestLongCumulativePremiumFraction: 0,
        latestShortCumulativePremiumFraction: 0,
        nextFundingBlockTimestamp: 0,
    };
}

get fun get_exchange_settings(): GetExchangeSettingsReply {
    return {
        fee: 0,
        rolloverFee: 0,
        fundingPeriod: 0,
        initMarginRatio: 0,
        maintenanceMarginRatio: 0,
        liquidationFeeRatio: 0,
        partialLiquidationRatio: 0,
        spreadLimit: 0,
        maxPriceImpact: 0,
        maxPriceSpread: 0,
        maxOpenNotional: 0,
        feeToStakersPercent: 0,
        fundingMode: 0,
        minPartialLiquidationNotional: 0,
        minInitMarginRatio: 0,
        executorFee: 0,
        closePositionTimeDelta: 0,
        maxUnrealizedPnl: 0,
        directIncreaseEnabled: false,
        directCloseEnabled: false,
        executorsWhitelist: createEmptyCell(),
        lowFundingFnA: 0,
        lowFundingFnB: 0,
        highFundingFnA: 0,
        highFundingFnB: 0,
        inflectionPoint: 0,
        v3CloseDelay: 0,
    };
}

get fun get_position_manager_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_can_liquidate(newPrice: int, positionRef: cell, newSettlementPrice: int, vpiSpread: int, vpiMarketDepthLong: int, vpiMarketDepthShort: int, vpiCoefficient: int, now: int): GetCanLiquidateReply {
    return {
        canExecute: false,
        spotMarginRatio: 0,
        liquidationMarginRatio: 0,
        errorCode: 0,
    };
}

get fun get_can_force_close(newPrice: int, positionRef: cell, newSettlementPrice: int, vpiSpread: int, vpiMarketDepthLong: int, vpiMarketDepthShort: int, vpiCoefficient: int, now: int): GetCanForceCloseReply {
    return {
        canClose: false,
        errorCode: 0,
    };
}

get fun get_can_execute_order(newPrice: int, positionRef: cell, newSettlementPrice: int, vpiSpread: int, vpiMarketDepthLong: int, vpiMarketDepthShort: int, vpiCoefficient: int, now: int): GetCanExecuteOrderReply {
    return {
        canExecute: false,
        spotPrice: 0,
        errorCode: 0,
    };
}

get fun get_spot_price(): coins {
    return 0;
}

get fun get_liquidation_price_vpi(openNotional: int, marginRatio: int, positionMargin: int, positionSize: int, isAdd: int, remainMargin: int, settlementOraclePrice: int, isSettleBySpotPrice: int): coins {
    return 0;
}

get fun get_remain_margin_with_funding_payment(newPrice: int, positionRef: cell, newSettlementPrice: int): GetRemainMarginWithFundingPaymentReply {
    return {
        remainMargin: 0,
        fundindPayment: 0,
        marginRatio: 0,
        unrealizedPnl: 0,
        badDebt: 0,
        positionNotional: 0,
        rolloverFee: 0,
        newPrice: 0,
        spotPrice: 0,
    };
}

get fun get_terminal_amm_price(): coins {
    return 0;
}

get fun get_peg_adjust_cost(price: int): coins {
    return 0;
}

get fun get_adjusted_spot_price(price: int, settlementPrice: int): coins {
    return 0;
}

get fun get_validate_signatures(oraclePayload: cell): GetValidateSignaturesReply {
    return {
        newPrice: 0,
        newSettlementPrice: 0,
        newCreatedPrice: null,
        settlementCreatedPrice: null,
        pauseTime: 0,
    };
}

get fun get_oracle_data(): GetOracleDataReply {
    return {
        oracleLastPrice: 0,
        oracleLastSpread: 0,
        oracleLastTimestamp: 0,
        oracleMaxDeviation: 0,
        oracleValidityPeriod: 0,
        oraclePublicKeysCount: 0,
        oraclePublicKeysRef: createEmptyCell(),
    };
}

get fun get_funding(newPrice: int, newSettlementPrice: int): GetFundingReply {
    return {
        longFunding: 0,
        shortFunding: 0,
        premiumToVault: 0,
        syncExchangeAmount: 0,
        spotPrice: 0,
    };
}

get fun get_compute_funding_data(newPrice: int, pauseTime: int): GetComputeFundingDataReply {
    return {
        shortPremiumFraction: 0,
        longPremiumFraction: 0,
        premiumToVault: 0,
        fundingPeriods: 0,
    };
}

get fun get_premium(newPrice: int): coins {
    return 0;
}

get fun get_funding_settings(): GetFundingSettingsReply {
    return {
        lowFundingFnA: 0,
        lowFundingFnB: 0,
        highFundingFnA: 0,
        highFundingFnB: 0,
        inflectionPoint: 0,
    };
}

get fun get_day_trading_data(): GetDayTradingDataReply {
    return {
        active: false,
        maxLeverage: 0,
    };
}

get fun get_lazer_data(): GetLazerDataReply {
    return {
        oracleFlag: 0,
        indexAssetPythId: 0,
        settlementAssetPythId: 0,
    };
}

get fun get_vamm_type(): uint32 {
    return 0;
}
