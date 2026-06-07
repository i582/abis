/// Storm Trade base VAMM interface for TON/USD-style markets.
contract StormVamm {
    author: "Storm Trade"
    version: "1.0"
    description: "Storm Trade base VAMM for TON/USD-style markets, trading messages, and public getters."
    storage: StormVammStorage
    incomingMessages: StormVammIncomingMessage
    outgoingMessages: StormVammOutgoingMessage
    thrownErrors: StormVammErrors
}

/// Runtime storage parsed from the base VAMM data cell.
struct StormVammStorage {
    /// Reserved coin slot; current base VAMM code stores zero before the vault address.
    reservedCoins: coins
    /// Vault contract that owns this VAMM market.
    vaultAddress: address
    /// Storm asset id returned by `get_amm_name`.
    assetId: uint16
    /// Close-only flag returned by `get_amm_status`.
    closeOnly: bool
    /// Persistent paused flag returned by `get_amm_status`.
    paused: bool
    /// Last oracle price used by `get_oracle_data`.
    oracleLastPrice: coins
    /// Last oracle spread used by `get_oracle_data`.
    oracleLastSpread: coins
    /// Last oracle timestamp used by `get_oracle_data`.
    oracleLastTimestamp: uint32
    /// Maximum allowed oracle deviation.
    oracleMaxDeviation: coins
    /// Oracle data validity period in seconds.
    oracleValidityPeriod: uint32
    /// Number of oracle public keys.
    oraclePublicKeysCount: uint4
    /// Referenced AMM reserve and funding state.
    ammState: Cell<StormVammAmmState>
    /// Referenced exchange settings and funding parameters.
    exchangeSettings: Cell<StormVammExchangeSettings>
    /// Raw oracle public key dictionary cell.
    oraclePublicKeysRef: cell
    /// Unused settlement-oracle ref for base VAMM; live storage keeps an empty cell.
    settlementOracleData: cell
    /// Pause start timestamp used by `get_amm_status`.
    pauseAt: uint32
    /// Pause end timestamp used by `get_amm_status`.
    unpauseAt: uint32
    /// Non-zero day-trading max leverage also marks day trading active.
    dayTradingMaxLeverage: uint32
    /// Packed Lazer oracle data: oracle flag and index Pyth id.
    lazerData: uint36
}

/// Referenced AMM reserve and cumulative premium state.
struct StormVammAmmState {
    /// Quote asset reserve.
    quoteAssetReserve: coins
    /// Base asset reserve.
    baseAssetReserve: coins
    /// Quote asset reserve weight.
    quoteAssetWeight: uint64
    /// Aggregate long position size.
    totalLongPositionSize: coins
    /// Aggregate short position size.
    totalShortPositionSize: coins
    /// Long open interest.
    openInterestLong: coins
    /// Short open interest.
    openInterestShort: coins
    /// Latest long cumulative premium fraction.
    latestLongCumulativePremiumFraction: int64
    /// Latest short cumulative premium fraction.
    latestShortCumulativePremiumFraction: int64
    /// Next funding block timestamp.
    nextFundingBlockTimestamp: uint32
}

/// Referenced exchange settings and funding configuration.
struct StormVammExchangeSettings {
    /// Position fee rate.
    fee: uint32
    /// Rollover fee rate.
    rolloverFee: uint32
    /// Funding period in seconds.
    fundingPeriod: uint32
    /// Initial margin ratio.
    initMarginRatio: uint32
    /// Maintenance margin ratio.
    maintenanceMarginRatio: uint32
    /// Liquidation fee ratio.
    liquidationFeeRatio: uint32
    /// Partial liquidation ratio.
    partialLiquidationRatio: uint32
    /// Maximum accepted spread.
    spreadLimit: uint32
    /// Maximum price impact.
    maxPriceImpact: uint32
    /// Maximum price spread.
    maxPriceSpread: uint32
    /// Maximum open notional.
    maxOpenNotional: coins
    /// Fee share paid to stakers.
    feeToStakersPercent: uint32
    /// Funding mode.
    fundingMode: uint2
    /// Minimum notional for partial liquidation.
    minPartialLiquidationNotional: coins
    /// Minimum initial margin ratio.
    minInitMarginRatio: uint32
    /// Direct increase enable flag.
    directIncreaseEnabled: bool
    /// Direct close enable flag.
    directCloseEnabled: bool
    /// Executor whitelist dictionary keyed by executor address hash.
    executorsWhitelist: map<uint256, cell>
    /// Low-funding function coefficient A.
    lowFundingFnA: uint64
    /// Low-funding function coefficient B.
    lowFundingFnB: uint64
    /// High-funding function coefficient A.
    highFundingFnA: int64
    /// High-funding function coefficient B.
    highFundingFnB: uint64
    /// Funding function inflection point.
    inflectionPoint: uint64
    /// Executor fee rate encoded as a fixed uint32 before the V3 close delay.
    executorFee: uint32
    /// V3 close delay in seconds.
    v3CloseDelay: uint32
}

/// Change-settings payload with AMM risk, fee, funding, and leverage parameters.
struct AmmSettings {
    /// Position fee rate in protocol fixed-point units.
    fee: uint32
    /// Rollover fee rate or amount carried by settings, logs, or margin calculations.
    rolloverFee: uint32
    /// Funding period length in seconds.
    fundingPeriod: uint32
    /// Initial margin ratio required for a position.
    initMarginRatio: uint32
    /// Maintenance margin ratio required to avoid liquidation.
    maintenanceMarginRatio: uint32
    /// Liquidation fee ratio applied during liquidation.
    liquidationFeeRatio: uint32
    /// Partial liquidation ratio configured for the market.
    partialLiquidationRatio: uint32
    /// Maximum accepted oracle or execution spread.
    spreadLimit: uint32
    /// Maximum accepted price impact.
    maxPriceImpact: uint32
    /// Maximum accepted price spread.
    maxPriceSpread: uint32
    /// Maximum open notional cap for the market.
    maxOpenNotional: coins
    /// Share of fees paid to stakers.
    feeToStakersPercent: uint32
    /// Funding mode discriminator encoded in settings.
    fundingMode: uint2
    /// Minimum notional that allows partial liquidation.
    minPartialLiquidationNotional: coins
    /// Minimum initial margin ratio allowed by change-settings payloads.
    minInitMarginRatio: uint32
    /// Direct increase enable flag copied into exchange settings.
    directIncreaseEnabled: bool
    /// Direct close enable flag copied into exchange settings.
    directCloseEnabled: bool
    /// Executor whitelist dictionary copied into exchange settings.
    executorsWhitelist: map<uint256, cell>
    /// Low-funding function coefficient A.
    lowFundingFnA: uint64
    /// Low-funding function coefficient B.
    lowFundingFnB: uint64
    /// High-funding function coefficient A.
    highFundingFnA: int64
    /// High-funding function coefficient B.
    highFundingFnB: uint64
    /// Funding function inflection point.
    inflectionPoint: uint64
    /// Executor fee rate encoded as a fixed uint32 when the V3 tail is present.
    executorFee: uint32
    /// V3 close delay encoded when the V3 tail is present.
    v3CloseDelay: uint32
}

/// Oracle update wrapper carrying a referenced price update and its signature payload.
struct OracleData {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsg>
    /// Oracle signature payload or referenced signature bundle.
    signatures: cell
}

/// Long direction tag encoded as the zero branch of the direction union.
struct (0b0) Long {}

/// Short direction tag encoded as the one branch of the direction union.
struct (0b1) Short {}

/// Stop-loss order body with trigger price and collateral amount.
struct (0x0) StopLossOrder {
    /// Order expiration timestamp.
    expiration: uint32
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Collateral amount assigned to the stop-loss order.
    amount: coins
    /// Trigger price for stop-loss or take-profit execution.
    triggerPrice: coins
}

/// Take-profit order body with trigger price and collateral amount.
struct (0x1) TakeProfitOrder {
    /// Order expiration timestamp.
    expiration: uint32
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Collateral amount assigned to the take-profit order.
    amount: coins
    /// Trigger price for stop-loss or take-profit execution.
    triggerPrice: coins
}

/// Legacy raw limit or market order cell wrapper.
struct LimitMarketOrder {
    /// Raw order cell matching the selected order variant.
    order: cell
}

/// User order body that adds margin to an existing position.
struct (0x4) AddMargin {
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Margin amount to add to the position.
    amount: coins
}

/// User order body that removes margin from an existing position.
struct (0x5) RemoveMargin {
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Margin amount to remove from the position.
    amount: coins
}

/// User order body that requests execution of another order selector and payload.
struct (0x8) RequestOrder {
    /// Execution selector cell choosing the requested order action.
    selector: cell
    /// Raw order cell matching the selected order variant.
    order: cell
}

/// Position snapshot cell passed between SmartAccount, VAMM, and order execution flows.
struct PositionData {
    /// Signed or unsigned position size in the payload context.
    size: int128
    /// Long/short direction bit in the position snapshot.
    direction: uint1
    /// Position margin amount.
    margin: coins
    /// Position open notional amount.
    openNotional: coins
    /// Cumulative premium fraction captured at last position update.
    lastUpdatedCumulativePremium: int64
    /// Position fee rate in protocol fixed-point units.
    fee: uint32
    /// Referral discount rate applied to the trader.
    discount: uint32
    /// Referral rebate rate applied to the referrer.
    rebate: uint32
    /// Timestamp of the last position update.
    lastUpdatedTimestamp: uint32
}

/// Legacy oracle payload with price data and signatures in referenced cells.
struct OraclePayload {
    /// Referenced oracle price-data cell.
    priceData: Cell<OraclePriceData>
    /// Oracle signature payload or referenced signature bundle.
    signatures: Cell<Signatures>
}

/// Address bundle supplied by the SmartAccount take-position flow.
struct AddressesData {
    /// Trader SmartAccount owner address.
    traderAddress: address
    /// SmartAccount factory address used to validate account origin.
    smartAccountFactoryAddress: address
    /// Vault contract address that owns this VAMM market.
    vaultAddress: address
}

/// Empty referral-data branch used when no referral payload is attached.
struct (0x0) RefData0 {}

/// Referral-data branch carrying one V2 referral payload.
struct (0x1) RefData1 {
    /// V2 referral payload carried by this ref-data branch.
    data: ReferralDataV2
}

/// Referral-data branch carrying an alternate V2 referral payload.
struct (0x2) RefData2 {
    /// V2 referral payload carried by this alternate ref-data branch.
    data: ReferralDataV2
}

/// Signed user intent with oracle data and optional chained intent reference.
struct (0b0) UserIntent {
    /// User signature over the intent payload.
    signature: bits512
    /// Referenced or raw intent payload carried by user/executor flows.
    intent: Cell<UserIntent2>
    /// Oracle payload cell used to verify execution prices.
    oraclePayload: cell
    /// Optional reference to the next chained intent.
    nextIntent: cell?
}

/// Executor intent with oracle data and optional chained intent reference.
struct (0b1) ExecutorIntent {
    /// Referenced or raw intent payload carried by user/executor flows.
    intent: Cell<ExecutorIntent2>
    /// Oracle payload cell used to verify execution prices.
    oraclePayload: cell
    /// Optional reference to the next chained intent.
    nextIntent: cell?
}

/// Position delta emitted to position-manager update messages.
struct PositionChange {
    /// Signed position size after the VAMM update.
    size: int128
    /// Long/short direction tag for the order, position, or update.
    direction: uint1
    /// Position margin amount.
    margin: coins
    /// Position open notional amount.
    openNotional: coins
    /// Signed cumulative premium fraction captured at last position update.
    lastUpdatedCumulativePremium: int64
    /// Position fee rate in protocol fixed-point units.
    fee: uint32
    /// Referral discount rate applied to the trader.
    discount: uint32
    /// Referral rebate rate applied to the referrer.
    rebate: uint32
    /// Timestamp of the last position update.
    lastUpdatedTimestamp: uint32
}

/// AMM reserve and open-interest delta emitted with position updates.
struct AmmChange {
    /// Quote asset reserve used by AMM pricing.
    quoteAssetReserve: coins
    /// Quote reserve weight included in the emitted AMM delta.
    quoteAssetReserveWeight: coins
    /// Base asset reserve used by AMM pricing.
    baseAssetReserve: coins
    /// Aggregate long position size tracked by the VAMM.
    totalLongPositionSize: coins
    /// Aggregate short position size tracked by the VAMM.
    totalShortPositionSize: coins
    /// Long-side open interest tracked by the VAMM.
    openInterestLong: coins
    /// Short-side open interest tracked by the VAMM.
    openInterestShort: coins
}

/// VPI market-depth tuple appended to complete-order callbacks.
struct StormVpiMarketDepth {
    /// VPI spread value used by pricing checks.
    vpiSpread: coins
    /// Long-side VPI market depth.
    vpiMarketDepthLong: coins
    /// Short-side VPI market depth.
    vpiMarketDepthShort: coins
    /// VPI coefficient encoded as a 64-bit value.
    vpiCoefficient: uint64
}

/// Referral reward payload used by vault trade notifications.
struct ReferralData {
    /// Referral reward amount credited by the vault notification.
    amount: coins
    /// Referral or executor registry index credited by the flow.
    index: uint32
}

/// Executor reward payload used by vault trade notifications.
struct ExecutorData {
    /// Whether executor rewards are split by notification accounting.
    splitExecutorRewards: bool
    /// Executor reward amount credited by the vault notification.
    amount: coins
    /// Referral or executor registry index credited by the flow.
    index: uint32
}

/// Compact order identity used when an order is activated.
struct OrderPayload {
    /// Order type tag encoded in compact order identifiers.
    orderType: uint4
    /// Order slot index within the selected order type.
    orderIndex: uint3
    /// Long/short direction tag for the order, position, or update.
    direction: uint1
}

/// Referrer payout entry used in referral dictionaries.
struct ReferrerData {
    /// Referrer address credited by referral accounting.
    referrerAddress: address
    /// Referrer share in the referral split dictionary.
    referrerPart: uint8
}

/// V2 trade-notification payload referenced from the notification message body.
struct NotificationPayloadV2 {
    /// SmartAccount bundle sender address.
    bundleSenderAddress: address
    /// Account balance delta emitted in the notification payload.
    balanceDelta: coins
    /// VAMM market address targeted by the message or intent.
    ammAddress: address
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Optional referenced position snapshot attached to the notification payload.
    positionData: Cell<PositionData>?
}

/// Per-intent execution log entry stored inside the intent-log dictionary.
struct IntentLog {
    /// Intent-log action tag cell.
    typeValue: cell
    /// Signed or unsigned position size in the payload context.
    size: int128
    /// Position margin amount.
    margin: coins
    /// Position open notional amount.
    openNotional: coins
    /// Last updated cumulative premium fraction logged for the position.
    lastUpdatedCpf: int64
    /// Realized profit or loss recorded in the intent log.
    realizedPnl: int64
    /// Funding payment recorded in the intent log or margin calculation.
    fundingPayment: int64
    /// Rollover fee rate or amount carried by settings, logs, or margin calculations.
    rolloverFee: uint64
    /// Position fee rate recorded for the intent execution.
    positionFeeRate: uint32
    /// Executor fee rate recorded for the intent execution.
    executorFeeRate: uint32
    /// Position fee amount charged for the intent execution.
    positionFeeAmount: coins
    /// Executor fee amount charged or credited for the intent execution.
    executorFeeAmount: coins
    /// Share of fees paid to stakers.
    feeToStakersPercent: uint32
    /// Referenced additional log-data cell.
    additionalData: Cell<AdditionalLogData>
}

/// Legacy oracle price update message for one asset.
struct UpdateMsg {
    /// Oracle price value.
    price: coins
    /// Oracle spread value.
    spread: coins
    /// Oracle or Lazer message timestamp.
    timestamp: uint32
    /// Oracle asset index carried in the price update.
    assetIndex: uint16
}

/// Create-order payload for a limit order with stop-loss and take-profit triggers.
struct (0x2) LimitOrder {
    /// Order expiration timestamp.
    expiration: uint32
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Collateral amount for the limit-order creation request.
    amount: coins
    /// Requested leverage for a limit or market order.
    leverage: uint64
    /// Limit price attached to order creation.
    limitPrice: coins
    /// Stop price attached to order creation.
    stopPrice: coins
    /// Stop-loss trigger price.
    stopTriggerPrice: coins
    /// Take-profit trigger price.
    takeTriggerPrice: coins
}

/// Create-order payload for a market order with stop-loss and take-profit triggers.
struct (0x3) MarketOrder {
    /// Order expiration timestamp.
    expiration: uint32
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// Collateral amount for the market-order creation request.
    amount: coins
    /// Requested leverage for a limit or market order.
    leverage: uint64
    /// Limit price attached to order creation.
    limitPrice: coins
    /// Stop price attached to order creation.
    stopPrice: coins
    /// Stop-loss trigger price.
    stopTriggerPrice: coins
    /// Take-profit trigger price.
    takeTriggerPrice: coins
}

/// Execute-selector tag for stop-loss execution.
struct (0b0) ExecuteStop {}

/// Execute-selector tag for take-profit execution.
struct (0b1) ExecuteTake {}

/// Legacy oracle price tuple with price, spreads, and asset id.
struct PriceData {
    /// Oracle price value.
    price: coins
    /// Oracle spread value.
    spread: coins
    /// Additional spread field in the legacy price-data tuple.
    anotherSpread: uint32
    /// Storm asset id for the traded market.
    assetId: uint16
}

/// Referenced container for raw oracle signatures.
struct Signatures {
    /// Raw oracle signatures cell.
    data: cell
}

/// V2 referral payload with discount, rebate, and referrer split dictionary.
struct ReferralDataV2 {
    /// Referral discount rate applied to the trader.
    discount: uint32
    /// Referral rebate rate applied to the referrer.
    rebate: uint32
    /// Dictionary of referrer split entries keyed by uint4 referrer slot.
    refInfo: map<uint4, ReferrerData>
}

/// Decoded signed user-intent payload with query id, timestamp, key, and order intent.
struct UserIntent2 {
    /// Query id copied through request, response, or notification messages.
    queryId: UserQueryId
    /// User-intent creation timestamp.
    createdAt: uint32
    /// Optional parent query id referenced by the intent.
    referenceQueryId: UserQueryId?
    /// User public key that verifies the signed intent.
    publicKey: bits256
    /// Referenced or raw intent payload carried by user/executor flows.
    intent: Cell<UserIntentPayload>
}

/// Oracle payload branch for one price feed and optional Lazer message.
struct (0x00) Single {
    /// Referenced oracle payload for live price verification.
    priceOraclePayload: Cell<SingleOraclePayload>
    /// Optional referenced Lazer oracle message.
    lazerMessage: Cell<LazerMessage>?
}

/// Oracle payload branch for index and settlement feeds with optional Lazer message.
struct (0x01) Double {
    /// Referenced oracle payload for live price verification.
    priceOraclePayload: Cell<DoubleOraclePayload>
    /// Optional referenced Lazer oracle message.
    lazerMessage: Cell<LazerMessage>?
}

/// Oracle payload branch with one live feed plus a created-price payload.
struct (0x02) SingleWithCreated {
    /// Referenced oracle payload for live price verification.
    priceOraclePayload: Cell<SingleOraclePayload>
    /// Created-price oracle payload cell.
    createdOraclePayload: cell
    /// Optional referenced Lazer oracle message.
    lazerMessage: Cell<LazerMessage>?
    /// Optional Lazer message for the created-price payload.
    createdLazerMessage: Cell<LazerMessage>?
}

/// Oracle payload branch with live index/settlement feeds plus created-price payloads.
struct (0x03) DoubleWithCreated {
    /// Referenced oracle payload for live price verification.
    priceOraclePayload: Cell<DoubleOraclePayload>
    /// Created-price oracle payload cell.
    createdOraclePayload: cell
    /// Optional referenced Lazer oracle message.
    lazerMessage: Cell<LazerMessage>?
    /// Optional Lazer message for the created-price payload.
    createdLazerMessage: Cell<LazerMessage>?
}

/// Decoded executor-intent payload targeting a SmartAccount order.
struct ExecutorIntent2 {
    /// VAMM market address targeted by the message or intent.
    ammAddress: address
    /// SmartAccount address involved in the flow.
    saAddress: address
    /// Raw order cell matching the selected order variant.
    order: cell
}

/// Intent-log type tag for a position increase.
struct (0x00) Increase {}

/// Intent-log type tag for a position close.
struct (0x01) Close {}

/// Intent-log type tag for an add-margin action.
struct (0x02) AddMargin2 {}

/// Intent-log type tag for a remove-margin action.
struct (0x03) RemoveMargin2 {}

/// Additional intent-log data cell containing the execution index price.
struct AdditionalLogData {
    /// Index price used for execution or logging.
    indexPrice: coins
}

/// Packed user query id split into shift and bit-number components.
struct UserQueryId {
    /// High component of the packed user query id.
    shift: uint13
    /// Bit-index component of the packed user query id.
    bitNumber: uint10
}

/// User-intent target and raw order cell payload.
struct UserIntentPayload {
    /// VAMM market address targeted by the message or intent.
    ammAddress: address
    /// SmartAccount address involved in the flow.
    saAddress: address
    /// Raw order cell matching the selected order variant.
    order: cell
}

/// V2 oracle payload for markets without a settlement price feed.
struct WithoutSettlement {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Oracle signature payload or referenced signature bundle.
    signatures: cell
}

/// Signed Lazer oracle message with signature components and raw payload cell.
struct LazerMessage {
    /// Magic value identifying the Lazer message or payload format.
    magic: uint32
    /// ECDSA signature r component for the Lazer message.
    r: uint256
    /// ECDSA signature s component for the Lazer message.
    s: uint256
    /// ECDSA signature recovery id for the Lazer message.
    v: uint8
    /// Declared byte length of the Lazer payload.
    payloadLength: uint16
    /// Raw referenced Lazer payload cell.
    payload: cell
}

/// V2 oracle payload carrying both index and settlement oracle updates.
struct WithSettlement {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Oracle signature payload or referenced signature bundle.
    signatures: cell
    /// Referenced settlement oracle update message cell.
    settlementUpdateMsg: Cell<UpdateMsgV2>
    /// Settlement oracle signature payload.
    settlementSignatures: cell
}

/// Created-price oracle payload without a settlement update.
struct (0x00) CreatedPrice {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Oracle signature payload or referenced signature bundle.
    signatures: cell
}

/// Created-price oracle payload with settlement update data.
struct (0x01) CreatedPriceWithSettlement {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Oracle signature payload or referenced signature bundle.
    signatures: cell
    /// Referenced settlement oracle update message cell.
    settlementUpdateMsg: Cell<UpdateMsgV2>
    /// Settlement oracle signature payload.
    settlementSignatures: cell
}

/// Executor order branch for liquidation.
struct (0x6) Liquidate {
    /// Long/short direction tag for the order, position, or update.
    direction: cell
}

/// Executor order branch for forced close.
struct (0x7) ForceClose {
    /// Long/short direction tag for the order, position, or update.
    direction: cell
}

/// Executor order branch for forced close by max-leverage rule.
struct (0x9) ForceCloseMaxLeverage {
    /// Long/short direction tag for the order, position, or update.
    direction: cell
}

/// V2 oracle update tuple with price, pause window, and VPI parameters.
struct UpdateMsg2 {
    /// Oracle price value.
    price: coins
    /// Oracle spread value.
    spread: coins
    /// Oracle or Lazer message timestamp.
    timestamp: uint32
    /// Oracle asset index carried in the price update.
    assetIndex: uint16
    /// Scheduled or active pause start timestamp.
    pauseAt: uint32
    /// Scheduled unpause timestamp.
    unpauseAt: uint32
    /// VPI spread parameter from oracle update or getter input.
    vpiSpread: coins
    /// VPI long-side market-depth parameter.
    vpiMarketDepthLong: coins
    /// VPI short-side market-depth parameter.
    vpiMarketDepthShort: coins
    /// VPI coefficient used by liquidation and pricing checks.
    vpiCoefficient: uint64
}

/// Lazer payload branch for a single index feed.
struct (0b0) Single2 {
    /// Magic value identifying the Lazer message or payload format.
    magic: uint32
    /// Oracle or Lazer message timestamp.
    timestamp: uint64
    /// Lazer oracle channel id.
    channelId: uint8
    /// Number of feeds encoded in the Lazer payload.
    numberOfFeeds: uint8
    /// Lazer feed id for the index price.
    indexFeedId: uint32
    /// Lazer index feed property bundle.
    indexFeed: LazerFeed
}

/// Lazer payload branch for index and settlement feeds.
struct (0b1) Double2 {
    /// Magic value identifying the Lazer message or payload format.
    magic: uint32
    /// Oracle or Lazer message timestamp.
    timestamp: uint64
    /// Lazer oracle channel id.
    channelId: uint8
    /// Number of feeds encoded in the Lazer payload.
    numberOfFeeds: uint8
    /// Lazer feed id for the index price.
    indexFeedId: uint32
    /// Lazer index feed property bundle.
    indexFeed: LazerFeed
    /// Lazer feed id for the settlement price.
    settlementFeedId: uint32
    /// Lazer settlement feed property bundle.
    settlementFeed: LazerFeed
}

/// Lazer feed property bundle carrying price and exponent properties.
struct LazerFeed {
    /// Number of properties encoded in the Lazer feed.
    numberOfProperties: uint8
    /// Property id for the Lazer price value.
    pricePropertyId: uint8
    /// Price value carried by the Lazer feed property.
    pricePropertyValue: uint64
    /// Property id for the Lazer exponent value.
    exponentPropertyId: uint8
    /// Exponent value carried by the Lazer feed property.
    exponentPropertyValue: int16
}

/// Long/short direction union used by order and position payloads.
type Direction =
// Selects the long direction branch.
    | Long
    | // Selects the short direction branch.
    Short

/// Union of user order payload variants accepted by order flows.
type UserOrder =
// Selects the stop-loss order payload branch.
    | StopLossOrder
    | TakeProfitOrder
    | LimitMarketOrder
    | AddMargin
    | RemoveMargin
    | // Selects the request-order branch with selector and nested order.
    RequestOrder

/// Union of referral-data branches attached to user intents.
type RefData =
// Selects the no-referral branch.
    | RefData0
    | RefData1
    | // Selects the second referral-data branch.
    RefData2

/// Union of signed user intents and executor intents.
type Intent =
// Selects the signed user-intent branch.
    | UserIntent
    | // Selects the executor-intent branch.
    ExecutorIntent

/// Union of order creation payloads for limit and market orders.
type CreateOrder =
// Selects limit-order creation.
    | LimitOrder
    | // Selects market-order creation.
    MarketOrder

/// Union selecting stop-loss or take-profit execution.
type ExecuteSelector =
// Selects stop-loss execution.
    | ExecuteStop
    | // Selects take-profit execution.
    ExecuteTake

/// Alias for the legacy oracle price-data payload.
type OraclePriceData = PriceData

/// Union of V2 oracle payload shapes for live and created prices.
type OraclePayloadV2 =
// Selects a single-feed V2 oracle payload.
    | Single
    | Double
    | SingleWithCreated
    | // Selects an index/settlement payload with created-price data.
    DoubleWithCreated

/// Union of intent-log action tags.
type LogType =
// Selects an increase intent-log action.
    | Increase
    | Close
    | AddMargin2
    | // Selects a remove-margin intent-log action.
    RemoveMargin2

/// Alias for the no-settlement V2 oracle payload shape.
type SingleOraclePayload = WithoutSettlement

/// Alias for the with-settlement V2 oracle payload shape.
type DoubleOraclePayload = WithSettlement

/// Union of created-price oracle payload shapes.
type CreatedOraclePayload =
// Selects created-price data without settlement price.
    | CreatedPrice
    | // Selects created-price data with settlement price.
    CreatedPriceWithSettlement

/// Union of executor-only order actions.
type ExecutorOrder =
// Selects liquidation executor action.
    | Liquidate
    | ForceClose
    | // Selects max-leverage force-close executor action.
    ForceCloseMaxLeverage

/// Alias for the V2 oracle update payload.
type UpdateMsgV2 = UpdateMsg2

/// Union of Lazer oracle payload branches.
type LazerPayload =
// Selects the single-feed Lazer payload branch.
    | Single2
    | // Selects the double-feed Lazer payload branch.
    Double2

/// Internal message body declarations.
/// Incoming admin message that replaces AMM settings and redirects excess value.
struct (0xedcd36a6) StormChangeSettings {
    /// Address receiving redirected value or follow-up excess response.
    redirectAddr: address
    /// Referenced AMM settings payload cell.
    settings: Cell<AmmSettings>
}

/// Incoming message that pays funding using a referenced oracle update.
struct (0xb652c441) StormPayFunding {
    /// Referenced oracle data cell used by funding payment.
    oracleRef: Cell<OracleData>
}

/// Incoming initialization message carrying code and data cells.
struct (0x29c102d1) StormVammInit {
    /// Address receiving redirected value or follow-up excess response.
    redirectAddr: address
    /// Contract code cell carried by initialization.
    code: cell
    /// Initial storage data cell carried by the initialization message.
    data: cell
}

/// Incoming order-execution message with order, position, and oracle refs.
struct (0xde1ddbcc) StormExecuteOrder {
    /// Long/short direction bit for the order side.
    direction: uint1
    /// Order slot index within the selected order type.
    orderIndex: uint3
    /// Trader address supplied by order execution or notification messages.
    traderAddr: address
    /// Previous linked position or order address used by execution flow.
    prevAddr: address
    /// Optional referral item address supplied to execution.
    refAddr: address?
    /// Executor registry index credited by execution.
    executorIndex: uint32
    /// Raw order cell matching the selected order variant.
    order: cell
    /// Referenced position snapshot or delta cell.
    position: Cell<PositionData>
    /// Oracle payload cell used to verify execution prices.
    oraclePayload: Cell<OraclePayload>
}

/// Incoming SmartAccount take-position message with address, referral, position, and intent refs.
struct (0x1bea50f1) TakePositionV2 {
    /// Query id copied through request, response, or notification messages.
    queryId: uint64
    /// Optional SmartAccount bundle sender address; `addr_none` appears in real bodies.
    bundleSenderAddress: address?
    /// VAMM market address targeted by the message or intent.
    ammAddress: address
    /// Long/short direction bit for the position request.
    direction: uint1
    /// Amount spent by the bundle sender.
    spentAmount: coins
    /// Referenced trader/factory/vault address bundle.
    addresses: Cell<AddressesData>
    /// Inline referral-data branch attached to take-position execution.
    ref: RefData
    /// Referenced position snapshot or delta cell.
    position: Cell<PositionData>
    /// Referenced signed or executor intent payload carried by the request.
    intent: Cell<Intent>
}

/// Outgoing position-manager message reporting completed order execution.
struct (0xcf90d618) StormCompleteOrder {
    /// Order type tag encoded in compact order identifiers.
    orderType: uint4
    /// Order slot index within the selected order type.
    orderIndex: uint3
    /// Long/short direction tag for the order, position, or update.
    direction: uint1
    /// Opcode of the message that produced this result.
    originOpcode: uint32
    /// Index price used for execution or logging.
    indexPrice: coins
    /// Settlement oracle price written directly by callback send sites.
    settlementOraclePrice: coins
    /// Referenced position snapshot or delta cell.
    position: Cell<PositionChange>
    /// Referenced AMM reserve delta cell.
    amm: Cell<AmmChange>
    /// Referenced VPI market-depth tuple appended by complete-order send sites.
    marketDepth: Cell<StormVpiMarketDepth>
}

/// Outgoing vault notification with account balance deltas and reward refs.
struct (0x3475fdd2) StormVaultTradeNotification {
    /// AMM or asset index reported to the vault.
    ammIndex: uint16
    /// Signed free-balance delta reported to the vault.
    freeAmount: int64
    /// Signed locked-balance delta reported to the vault.
    lockedAmount: int64
    /// Signed exchange amount delta reported to the vault.
    exchangeAmount: int64
    /// Locked amount released for withdrawal.
    withdrawLockedAmount: uint64
    /// Fee amount credited to stakers.
    feeToStakers: uint64
    /// Withdraw amount reported to the vault.
    withdrawAmount: uint64
    /// Trader address supplied by order execution or notification messages.
    traderAddr: address
    /// Origin or withdrawal destination address forwarded with the accounting update.
    originAddr: address
    /// Optional referenced referral reward payload.
    referralParams: Cell<ReferralData>?
    /// Optional referenced executor reward payload.
    executorParams: Cell<ExecutorData>?
}

/// Outgoing position-manager message reporting a position and AMM update.
struct (0x60dfc677) StormUpdatePosition {
    /// Long/short direction tag for the order, position, or update.
    direction: uint1
    /// Opcode of the message that produced this result.
    originOpcode: uint32
    /// Index price used for execution or logging.
    indexPrice: coins
    /// Settlement oracle price written directly by callback send sites.
    settlementOraclePrice: coins
    /// Referenced position snapshot or delta cell.
    position: Cell<PositionChange>
    /// Referenced AMM reserve delta cell.
    amm: Cell<AmmChange>
}

/// Position update emitted when stop-loss/take-profit trigger prices are present.
struct (0x5d1b17b8) StormUpdatePositionWithStopLoss {
    /// Position direction copied to the position manager.
    direction: uint1
    /// Stop-loss trigger price.
    stopTriggerPrice: coins
    /// Take-profit trigger price.
    takeTriggerPrice: coins
    /// Originating AMM opcode.
    originOpcode: uint32
    /// Index price used for execution.
    indexPrice: coins
    /// Settlement oracle price written directly by callback send sites.
    settlementOraclePrice: coins
    /// Referenced position delta.
    position: Cell<PositionChange>
    /// Referenced AMM reserve delta.
    amm: Cell<AmmChange>
}

/// Outgoing position-manager message that marks an order as activated.
struct (0x9d2ec640) StormActivateOrder {
    /// Order slot index within the selected order type.
    orderIndex: uint3
    /// Referenced compact order payload that was activated.
    activatedOrder: Cell<OrderPayload>
}

/// Outgoing SmartAccount failure notification for bundle execution.
struct (0x666392ee) StormFailedBundleExecution {
    /// Query id copied through request, response, or notification messages.
    queryId: uint64
    /// Storm asset id for the traded market.
    assetId: uint16
    /// Protocol exit code reported by failure or check getters.
    errorCode: uint16
    /// Amount spent by the bundle sender.
    spentAmount: coins
    /// SmartAccount address involved in the flow.
    saAddress: address
    /// VAMM market address targeted by the message or intent.
    ammAddress: address
    /// Long/short direction tag for the order, position, or update.
    direction: cell
    /// SmartAccount bundle sender address.
    bundleSenderAddress: address
    /// Referenced or raw intent payload carried by user/executor flows.
    intent: cell
}

/// Outgoing V2 trade notification with balance deltas, referral data, and payload ref.
struct (0x28d36491) StormTradeNotificationV2 {
    /// Query id copied through request, response, or notification messages.
    queryId: uint64
    /// Storm asset id for the traded market.
    assetId: uint16
    /// Free balance delta reported to the vault or trade notification.
    freeAmount: int64
    /// Locked balance delta reported to the vault or trade notification.
    lockedAmount: int64
    /// Exchange balance delta reported to the vault or trade notification.
    exchangeAmount: int64
    /// Locked amount withdrawn or released by the trade.
    withdrawLockedAmount: uint64
    /// Fee amount routed to stakers.
    feeToStakers: uint64
    /// Executor amount credited in the V2 trade notification.
    executorAmount: uint64
    /// Total referrer amount credited in the V2 trade notification.
    totalReferrerAmount: uint64
    /// Number of referrer entries in the referral dictionary.
    refCount: uint4
    /// Dictionary of referrer entries keyed by uint4 referrer slot.
    referralData: map<uint4, ReferrerData>
    /// SmartAccount address involved in the flow.
    saAddress: address
    /// Referenced V2 trade-notification payload.
    notificationPayload: Cell<NotificationPayloadV2>
}

/// Outgoing external log message carrying the intent-log dictionary.
struct (0x812e8f40) IntentLog2 {
    /// Dictionary of intent logs keyed by uint8 log index.
    logDict: map<uint8, IntentLog>
}

/// Standard excesses response emitted by admin/update flows.
struct (0xd53276db) StormExcesses {
    /// Query id copied from the triggering request.
    queryId: uint64
}

/// Incoming internal message union accepted by the base VAMM contract.
type StormVammIncomingMessage =
// Accepts the change-settings internal message body.
    | StormChangeSettings
    | StormPayFunding
    | StormVammInit
    | StormExecuteOrder
    | // Accepts the V2 take-position internal message body.
    TakePositionV2

/// Outgoing message union emitted by the base VAMM contract.
type StormVammOutgoingMessage =
// Emits completed-order messages to the position manager.
    | StormCompleteOrder
    | StormVaultTradeNotification
    | StormUpdatePosition
    | StormUpdatePositionWithStopLoss
    | StormActivateOrder
    | StormFailedBundleExecution
    | StormTradeNotificationV2
    | IntentLog2
    | // Emits standard excesses responses.
    StormExcesses

/// Stack return tuple for the `get_amm_name` getter.
struct GetAmmNameReply {
    /// Vault contract address returned by the getter.
    vaultAddr: address
    /// Storm asset id for the traded market.
    assetId: uint16
}

/// Stack return tuple for the `get_amm_status` getter.
struct GetAmmStatusReply {
    /// Flag that permits closing positions while blocking new opens.
    closeOnly: bool
    /// Persistent pause flag stored by the VAMM.
    paused: bool
    /// Computed stopped flag returned by status getters.
    stopped: bool
    /// Scheduled or active pause start timestamp.
    pauseAt: uint32
    /// Scheduled unpause timestamp.
    unpauseAt: uint32
}

/// Stack return tuple for the `get_amm_state` getter.
struct GetAmmStateReply {
    /// Quote asset reserve used by AMM pricing.
    quoteAssetReserve: uint64
    /// Base asset reserve used by AMM pricing.
    baseAssetReserve: uint64
    /// Quote reserve weight used by the AMM price function.
    quoteAssetWeight: uint64
    /// Aggregate long position size tracked by the VAMM.
    totalLongPositionSize: uint64
    /// Aggregate short position size tracked by the VAMM.
    totalShortPositionSize: uint64
    /// Long-side open interest tracked by the VAMM.
    openInterestLong: uint64
    /// Short-side open interest tracked by the VAMM.
    openInterestShort: uint64
    /// Latest long cumulative premium fraction.
    latestLongCumulativePremiumFraction: int64
    /// Latest short cumulative premium fraction.
    latestShortCumulativePremiumFraction: int64
    /// Timestamp for the next funding block.
    nextFundingBlockTimestamp: uint32
}

/// Stack return tuple for the `get_exchange_settings` getter.
struct GetExchangeSettingsReply {
    /// Position fee rate in protocol fixed-point units.
    fee: uint32
    /// Rollover fee rate or amount carried by settings, logs, or margin calculations.
    rolloverFee: uint32
    /// Funding period length in seconds.
    fundingPeriod: uint32
    /// Initial margin ratio required for a position.
    initMarginRatio: uint32
    /// Maintenance margin ratio required to avoid liquidation.
    maintenanceMarginRatio: uint32
    /// Liquidation fee ratio applied during liquidation.
    liquidationFeeRatio: uint32
    /// Partial liquidation ratio configured for the market.
    partialLiquidationRatio: uint32
    /// Maximum accepted oracle or execution spread.
    spreadLimit: uint32
    /// Maximum accepted price impact.
    maxPriceImpact: uint32
    /// Maximum accepted price spread.
    maxPriceSpread: uint32
    /// Maximum open notional cap for the market.
    maxOpenNotional: coins
    /// Share of fees paid to stakers.
    feeToStakersPercent: uint32
    /// Funding mode discriminator encoded in settings.
    fundingMode: uint8
    /// Minimum notional that allows partial liquidation.
    minPartialLiquidationNotional: coins
    /// Minimum initial margin ratio.
    minInitMarginRatio: uint32
    /// Executor fee amount configured for order execution.
    executorFee: coins
    /// Cooldown or delay before close-position actions can execute.
    closePositionTimeDelta: uint32
    /// Maximum unrealized PnL returned by exchange-settings getter.
    maxUnrealizedPnl: uint64
    /// Flag allowing direct position increases.
    directIncreaseEnabled: bool
    /// Flag allowing direct position closes.
    directCloseEnabled: bool
    /// Executor whitelist dictionary keyed by executor address hash.
    executorsWhitelist: map<uint256, cell>
    /// Low-funding function coefficient A.
    lowFundingFnA: uint64
    /// Low-funding function coefficient B.
    lowFundingFnB: uint64
    /// High-funding function coefficient A.
    highFundingFnA: int64
    /// High-funding function coefficient B.
    highFundingFnB: uint64
    /// Funding-function inflection point.
    inflectionPoint: uint64
    /// V3 close cooldown duration in seconds.
    v3CloseDelay: uint32
}

/// Stack return tuple for the `get_can_liquidate` getter.
struct GetCanLiquidateReply {
    /// Boolean result for liquidation or order-execution checks.
    canExecute: bool
    /// Spot-price margin ratio from liquidation checks.
    spotMarginRatio: uint32
    /// Liquidation threshold margin ratio.
    liquidationMarginRatio: uint32
    /// Protocol exit code reported by failure or check getters.
    errorCode: uint16
}

/// Stack return tuple for the `get_can_force_close` getter.
struct GetCanForceCloseReply {
    /// Boolean result for force-close checks.
    canClose: bool
    /// Protocol exit code reported by failure or check getters.
    errorCode: uint16
}

/// Stack return tuple for the `get_can_execute_order` getter.
struct GetCanExecuteOrderReply {
    /// Boolean result for liquidation or order-execution checks.
    canExecute: bool
    /// Spot price returned by pricing or execution getters.
    spotPrice: coins
    /// Protocol exit code reported by failure or check getters.
    errorCode: uint16
}

/// Stack return tuple for the `get_remain_margin_with_funding_payment` getter.
struct GetRemainMarginWithFundingPaymentReply {
    /// Remaining margin after funding and PnL adjustments.
    remainMargin: coins
    /// Funding payment returned by the getter.
    fundindPayment: coins
    /// Computed margin ratio for the position.
    marginRatio: coins
    /// Unrealized profit or loss for the position.
    unrealizedPnl: coins
    /// Bad-debt amount detected by margin calculation.
    badDebt: coins
    /// Current notional value of the position.
    positionNotional: coins
    /// Rollover fee rate or amount carried by settings, logs, or margin calculations.
    rolloverFee: coins
    /// Candidate index price supplied to or returned from getters.
    newPrice: coins
    /// Spot price returned by pricing or execution getters.
    spotPrice: coins
}

/// Stack return tuple for the `get_validate_signatures` getter.
struct GetValidateSignaturesReply {
    /// Candidate index price supplied to or returned from getters.
    newPrice: coins
    /// Candidate settlement price supplied to or returned from getters.
    newSettlementPrice: coins
    /// Optional created index price returned by signature validation.
    newCreatedPrice: coins?
    /// Optional created settlement price returned by signature validation.
    settlementCreatedPrice: coins?
    /// Pause time returned by signature validation or funding computations.
    pauseTime: uint32
}

/// Stack return tuple for the `get_oracle_data` getter.
struct GetOracleDataReply {
    /// Last accepted oracle price stored by the VAMM.
    oracleLastPrice: coins
    /// Last accepted oracle spread stored by the VAMM.
    oracleLastSpread: coins
    /// Timestamp of the last accepted oracle update.
    oracleLastTimestamp: uint32
    /// Maximum accepted oracle deviation configured for the market.
    oracleMaxDeviation: coins
    /// Oracle update validity period in seconds.
    oracleValidityPeriod: uint32
    /// Number of oracle public keys encoded in storage or returned by getter.
    oraclePublicKeysCount: uint8
    /// Raw oracle public-key dictionary cell.
    oraclePublicKeysRef: cell
}

/// Stack return tuple for the `get_funding` getter.
struct GetFundingReply {
    /// Long-side funding amount.
    longFunding: coins
    /// Short-side funding amount.
    shortFunding: coins
    /// Premium amount or rate routed to the vault.
    premiumToVault: uint32
    /// Exchange amount synchronized during funding computation.
    syncExchangeAmount: coins
    /// Spot price returned by pricing or execution getters.
    spotPrice: coins
}

/// Stack return tuple for the `get_compute_funding_data` getter.
struct GetComputeFundingDataReply {
    /// Computed short-side premium fraction.
    shortPremiumFraction: coins
    /// Computed long-side premium fraction.
    longPremiumFraction: coins
    /// Premium amount or rate routed to the vault.
    premiumToVault: coins
    /// Number of funding periods included in the computation.
    fundingPeriods: uint32
}

/// Stack return tuple for the `get_funding_settings` getter.
struct GetFundingSettingsReply {
    /// Low-funding function coefficient A.
    lowFundingFnA: uint64
    /// Low-funding function coefficient B.
    lowFundingFnB: uint64
    /// High-funding function coefficient A.
    highFundingFnA: int64
    /// High-funding function coefficient B.
    highFundingFnB: uint64
    /// Funding-function inflection point.
    inflectionPoint: uint64
}

/// Stack return tuple for the `get_day_trading_data` getter.
struct GetDayTradingDataReply {
    /// Day-trading active flag.
    active: bool
    /// Maximum day-trading leverage.
    maxLeverage: uint32
}

/// Stack return tuple for the `get_lazer_data` getter.
struct GetLazerDataReply {
    /// Lazer oracle enablement or source flag.
    oracleFlag: uint8
    /// Pyth id for the index asset in packed Lazer data.
    indexAssetPythId: uint32
    /// Pyth id for the settlement asset in packed Lazer data.
    settlementAssetPythId: uint32
}

/// Base VAMM exit codes.
enum StormVammErrors {
    /// Invalid vault address.
    InvalidVaultAddress = 157
    /// Invalid AMM address.
    InvalidAmmAddress = 158
    /// Sender is not the configured admin.
    NotAnAdmin = 401
    /// Incoming value is below the gas requirement.
    NotEnoughGas = 404
    /// Position address does not match the expected position.
    WrongPositionAddress = 405
    /// Sender is not the configured vault.
    NotAVault = 407
    /// Margin ratio is below the required threshold.
    LessMarginRatio = 409
    /// Position size is invalid for the requested operation.
    WrongSize = 411
    /// Position would create or already has bad debt.
    PositionBadDebt = 412
    /// Position timestamp is invalid.
    WrongPositionTimestamp = 413
    /// Amount is invalid for the requested operation.
    WrongAmount = 414
    /// Price impact exceeds the configured limit.
    HighPriceImpact = 415
    /// Spread exceeds the configured limit.
    OverSpreadLimit = 416
    /// Open notional exceeds the configured maximum.
    OverMaxOpenNotional = 417
    /// Stop order is not executable at the supplied price.
    NotExecutableByStop = 418
    /// Order is not executable under current market conditions.
    NotExecutable = 419
    /// Base asset reserve is invalid.
    WrongBaseAssetReserve = 420
    /// Quote asset reserve is invalid.
    WrongQuoteAssetReserve = 421
    /// Order or asset id is invalid.
    WrongId = 422
    /// Oracle signature quorum check failed.
    QuorumFailed = 423
    /// Timestamp is outside the accepted window.
    InvalidTimestamp = 424
    /// Oracle price difference is invalid.
    InvalidDiff = 425
    /// Leverage value is invalid.
    WrongLeverage = 426
    /// Slippage tolerance check failed.
    SlippageTolerance = 427
    /// Margin returned to the trader would be negative.
    NegativeMarginToTrader = 428
    /// Order expiration timestamp has passed.
    OrderExpired = 429
    /// Liquidity state is invalid for the operation.
    WrongLiquidity = 430
    /// Base asset amount is invalid.
    InvalidBaseAssetAmount = 431
    /// Market is paused.
    Paused = 432
    /// Market is in close-only mode.
    CloseOnly = 433
    /// Market is active when inactive state was required.
    MarketIsActive = 434
    /// Market is not active.
    MarketIsNotActive = 435
    /// Referral item address or index is invalid.
    WrongReferralItem = 436
    /// Executor item address or index is invalid.
    WrongExecutorItem = 437
    /// Start timestamp was already set.
    StartAlreadySet = 438
    /// End timestamp was already set.
    EndAlreadySet = 439
    /// Market or campaign has not started.
    NotStarted = 440
    /// Market or campaign has ended.
    Ended = 441
    /// Start date is invalid.
    WrongStartDate = 442
    /// End date is invalid.
    WrongEndDate = 443
    /// Executor address is invalid.
    WrongExecutorAddress = 444
    /// Direct position increase is disabled.
    DirectIncreaseDisabled = 445
    /// Direct position close is disabled.
    DirectCloseDisabled = 446
    /// Oracle payload variant is unknown.
    UnknownOraclePayload = 447
    /// Single-oracle payload variant is invalid.
    WrongSingleOraclePayload = 448
    /// Pause configuration is invalid.
    WrongPause = 450
    /// Market pause state blocks the requested operation.
    MarketPaused = 451
    /// PnL is below the required amount.
    NotEnoughPnl = 452
    /// Cumulative price impact exceeds the configured limit.
    HighCumulativePriceImpact = 453
    /// Pause timestamp is after unpause timestamp.
    PauseAfterUnpause = 454
    /// Position is too close to liquidation.
    TooCloseToLiquidation = 455
    /// Unpause timestamp is not defined when required.
    UnpauseNotDefined = 456
    /// Pause timestamp is invalid.
    InvalidPauseAt = 457
    /// Unpause timestamp is invalid.
    InvalidUnpauseAt = 458
    /// Day trading is disabled for this market.
    DayTradingDisabled = 459
    /// Current time is not close enough to the pause window.
    NotCloseToPause = 460
    /// Leverage is below the required value.
    NotEnoughLeverage = 461
    /// Oracle timestamp is invalid.
    InvalidOracleTimestamp = 462
    /// Margin is sufficient when insufficient margin was expected.
    MarginIsSufficient = 463
    /// VPI price is invalid.
    InvalidVpiPrice = 464
    /// SmartAccount address is invalid.
    WrongSmartAccountAddress = 470
    /// V3 close cooldown has not elapsed.
    V3CloseCooldown = 471
    /// Lazer message magic is invalid.
    InvalidMessageMagic = 1000
    /// Lazer payload magic is invalid.
    InvalidPayloadMagic = 1001
    /// Lazer feeds count is invalid.
    InvalidFeedsCount = 1002
    /// Lazer index feed id is invalid.
    InvalidIndexFeedId = 1003
    /// Lazer property count is invalid.
    InvalidPropertyCount = 1005
    /// Lazer property id is invalid.
    InvalidPropertyId = 1006
    /// Lazer signature verification failed.
    InvalidLazerSignature = 1007
    /// VAMM type discriminator is invalid.
    InvalidVammType = 1008
    /// Message opcode is not accepted by the VAMM dispatcher.
    WrongOperation = 65535
}

/// Return current pause-time value; pseudo-asserts export the VAMM error catalog.
get fun get_pause_time(): uint32 {
    throw 0;
}

/// Return the raw AMM contract data cell exposed by the on-chain getter.
get fun get_amm_contract_data(): cell {
    throw 0;
}

/// Return the vault address and Storm asset id for this market.
get fun get_amm_name(): GetAmmNameReply {
    throw 0;
}

/// Return close-only, paused, stopped, and pause-window status flags.
get fun get_amm_status(): GetAmmStatusReply {
    throw 0;
}

/// Return reserves, open interest, cumulative premiums, and next funding timestamp.
get fun get_amm_state(): GetAmmStateReply {
    throw 0;
}

/// Return fee, risk, funding, executor, and direct-trade settings.
get fun get_exchange_settings(): GetExchangeSettingsReply {
    throw 0;
}

/// Return the position-manager contract address used by this VAMM.
get fun get_position_manager_address(): address {
    throw 0;
}

/// Check whether a position can be liquidated for supplied prices and time.
get fun get_can_liquidate(
    newPrice: int,
    positionRef: cell,
    newSettlementPrice: int,
    vpiSpread: int,
    vpiMarketDepthLong: int,
    vpiMarketDepthShort: int,
    vpiCoefficient: int,
    now: int,
): GetCanLiquidateReply {
    throw 0;
}

/// Check whether a position can be force-closed for supplied prices and time.
get fun get_can_force_close(
    newPrice: int,
    positionRef: cell,
    newSettlementPrice: int,
    vpiSpread: int,
    vpiMarketDepthLong: int,
    vpiMarketDepthShort: int,
    vpiCoefficient: int,
    now: int,
): GetCanForceCloseReply {
    throw 0;
}

/// Check whether an order can execute and return its spot price/error status.
get fun get_can_execute_order(
    newPrice: int,
    positionRef: cell,
    newSettlementPrice: int,
    vpiSpread: int,
    vpiMarketDepthLong: int,
    vpiMarketDepthShort: int,
    vpiCoefficient: int,
    now: int,
): GetCanExecuteOrderReply {
    throw 0;
}

/// Return the current AMM spot price.
get fun get_spot_price(): coins {
    throw 0;
}

/// Return the VPI-aware liquidation price for supplied position values.
get fun get_liquidation_price_vpi(
    openNotional: int,
    marginRatio: int,
    positionMargin: int,
    positionSize: int,
    isAdd: int,
    remainMargin: int,
    settlementOraclePrice: int,
    isSettleBySpotPrice: int,
): coins {
    throw 0;
}

/// Return remaining margin, funding payment, PnL, and price data for a position.
get fun get_remain_margin_with_funding_payment(
    newPrice: int,
    positionRef: cell,
    newSettlementPrice: int,
): GetRemainMarginWithFundingPaymentReply {
    throw 0;
}

/// Return the terminal AMM price used by price-adjustment logic.
get fun get_terminal_amm_price(): coins {
    throw 0;
}

/// Return the AMM peg-adjustment cost for a supplied price.
get fun get_peg_adjust_cost(price: int): coins {
    throw 0;
}

/// Return adjusted spot price for supplied index and settlement prices.
get fun get_adjusted_spot_price(price: int, settlementPrice: int): coins {
    throw 0;
}

/// Validate oracle signatures and return live/created price results plus pause time.
get fun get_validate_signatures(oraclePayload: cell): GetValidateSignaturesReply {
    throw 0;
}

/// Return stored oracle price, spread, timestamp, limits, and public-key dictionary.
get fun get_oracle_data(): GetOracleDataReply {
    throw 0;
}

/// Return current long/short funding, premium-to-vault, sync amount, and spot price.
get fun get_funding(newPrice: int, newSettlementPrice: int): GetFundingReply {
    throw 0;
}

/// Return computed premium fractions and funding-period count.
get fun get_compute_funding_data(newPrice: int, pauseTime: int): GetComputeFundingDataReply {
    throw 0;
}

/// Return the funding premium for a supplied price.
get fun get_premium(newPrice: int): coins {
    throw 0;
}

/// Return funding-function coefficients and inflection point.
get fun get_funding_settings(): GetFundingSettingsReply {
    throw 0;
}

/// Return day-trading activity flag and maximum leverage.
get fun get_day_trading_data(): GetDayTradingDataReply {
    throw 0;
}

/// Return packed Lazer oracle flag and Pyth asset identifiers.
get fun get_lazer_data(): GetLazerDataReply {
    throw 0;
}

/// Return the VAMM type discriminator.
get fun get_vamm_type(): uint32 {
    throw 0;
}
