/// Storm Trade PositionManager v4 interface.
contract StormPositionManager {
    author: "Storm Trade"
    version: "4"
    description: "Storm Trade PositionManager interface with runtime storage, getters, order messages, and event bodies."
    storage: StormPositionManagerStorage
    incomingMessages: StormPositionManagerIncomingMessage
    outgoingMessages: StormPositionManagerOutgoingMessage
    thrownErrors: StormPositionManagerErrors
}

/// Runtime storage parsed from the PositionManager persistent data cell.
struct StormPositionManagerStorage {
    /// Trader address used by the vault to derive this PositionManager account.
    traderAddress: address
    /// Owning Storm vault address that authenticates vault-originated flows.
    vaultAddress: address
    /// Market VAMM address that authenticates position and order callbacks.
    vammAddress: address
    /// Optional long-side position record stored as a Maybe ref.
    longRecord: Cell<PositionRecord>?
    /// Optional short-side position record stored as a Maybe ref.
    shortRecord: Cell<PositionRecord>?
    /// Optional referral parameters; non-null storage makes `get_is_inited` true.
    referralData: Cell<PositionReferralData>?
    /// Optional global limit/market order dictionary cell keyed by three-bit order index.
    ordersDict: cell?
    /// Global limit/market order occupancy bitset; one bit per three-bit order index.
    ordersBitset: uint8
}

/// Position accounting snapshot embedded in records and VAMM callback payloads.
struct PositionData {
    /// Signed base position size in contract accounting units.
    size: int128
    /// Position direction bit: zero for long-side storage, one for short-side storage.
    direction: uint1
    /// Margin amount locked for the position.
    margin: coins
    /// Open notional amount recorded at execution time.
    openNotional: coins
    /// Last cumulative premium used for funding settlement.
    lastUpdatedCumulativePremium: int64
    /// Position fee rate copied from the VAMM state.
    fee: uint32
    /// Referral discount rate saved for the position.
    discount: uint32
    /// Referral rebate rate saved for the position.
    rebate: uint32
    /// Unix timestamp of the last position update.
    lastUpdatedTimestamp: uint32
}

/// Per-direction position record stored under `longRecord` or `shortRecord`.
struct PositionRecord {
    /// Lock flag that blocks mutable order/position actions while a VAMM flow is in progress.
    isLocked: bool
    /// Optional redirect address for excess or error messages; `addr_none` means no redirect.
    redirectAddress: address?
    /// Per-position SL/TP order occupancy bitset keyed by three-bit order index.
    positionOrdersBitset: uint8
    /// Optional per-position order dictionary cell keyed by three-bit order index.
    positionOrders: cell?
    /// Referenced position accounting snapshot.
    positionData: Cell<PositionData>
}

/// Referral parameters saved during PositionManager initialization.
struct PositionReferralData {
    /// Optional referral item/address; `addr_none` means referral is absent.
    referralAddress: address?
    /// Discount rate applied to this trader's position fees.
    discount: uint32
    /// Rebate rate accrued to the referral address.
    rebate: uint32
}

/// Stop-loss order data stored inside a position order dictionary value ref.
struct (0x0) StopLossOrder {
    /// Unix expiration timestamp; zero means no expiration.
    expiration: uint32
    /// Direction bit of the position that owns this order.
    direction: uint1
    /// Position amount covered by the stop-loss order.
    amount: coins
    /// Trigger price that activates the stop-loss order.
    triggerPrice: coins
}

/// Take-profit order data stored inside a position order dictionary value ref.
struct (0x1) TakeProfitOrder {
    /// Unix expiration timestamp; zero means no expiration.
    expiration: uint32
    /// Direction bit of the position that owns this order.
    direction: uint1
    /// Position amount covered by the take-profit order.
    amount: coins
    /// Trigger price that activates the take-profit order.
    triggerPrice: coins
}

/// Limit order data stored inside the global order dictionary value ref.
struct (0x2) LimitOrder {
    /// Unix expiration timestamp; zero means no expiration.
    expiration: uint32
    /// Direction bit for the position to open or increase.
    direction: uint1
    /// Margin amount supplied for the order.
    amount: coins
    /// Leverage value stored as a 64-bit integer.
    leverage: uint64
    /// Limit price required for execution.
    limitPrice: coins
    /// Stop price paired with the limit order.
    stopPrice: coins
    /// Optional stop-loss trigger price attached to the resulting position.
    stopTriggerPrice: coins
    /// Optional take-profit trigger price attached to the resulting position.
    takeTriggerPrice: coins
}

/// Market order data stored inside the global order dictionary value ref.
struct (0x3) MarketOrder {
    /// Unix expiration timestamp; zero means no expiration.
    expiration: uint32
    /// Direction bit for the position to open or increase.
    direction: uint1
    /// Margin amount supplied for the order.
    amount: coins
    /// Leverage value stored as a 64-bit integer.
    leverage: uint64
    /// Price supplied as the market order limit guard.
    limitPrice: coins
    /// Minimum base asset amount accepted by the market order.
    minBaseAssetAmount: coins
    /// Optional stop-loss trigger price attached to the resulting position.
    stopTriggerPrice: coins
    /// Optional take-profit trigger price attached to the resulting position.
    takeTriggerPrice: coins
}

/// Ref-valued order dictionary payload variants distinguished by the four-bit order type prefix.
type OrderData =
    | StopLossOrder
    | TakeProfitOrder
    | LimitOrder
    | MarketOrder

/// Referral fee parameters forwarded by the `take_referral_fees` message.
struct Parameters {
    /// Referral discount rate.
    discount: uint32
    /// Referral rebate rate.
    rebate: uint32
}

/// Compact order selector used by activation, completion, and event payloads.
struct OrderPayload {
    /// Four-bit order type discriminator.
    orderType: uint4
    /// Three-bit order index inside the relevant order dictionary.
    orderIndex: uint3
    /// Direction bit of the associated position/order side.
    direction: uint1
}

/// Position delta sent by VAMM callbacks after execution.
struct PositionChange {
    /// Signed base position size after the change.
    size: int128
    /// Direction bit of the updated position.
    direction: uint1
    /// Margin amount after the change.
    margin: coins
    /// Open notional amount after the change.
    openNotional: coins
    /// Cumulative premium value used for funding after the change.
    lastUpdatedCumulativePremium: int64
    /// Fee rate applied to the update.
    fee: uint32
    /// Referral discount rate applied to the update.
    discount: uint32
    /// Referral rebate rate applied to the update.
    rebate: uint32
    /// Unix timestamp of the position change.
    lastUpdatedTimestamp: uint32
}

/// AMM reserve and open-interest delta sent by VAMM callbacks.
struct AmmChange {
    /// Quote asset reserve after the AMM update.
    quoteAssetReserve: coins
    /// Quote asset reserve weight after the AMM update.
    quoteAssetReserveWeight: coins
    /// Base asset reserve after the AMM update.
    baseAssetReserve: coins
    /// Aggregate long position size after the AMM update.
    totalLongPositionSize: coins
    /// Aggregate short position size after the AMM update.
    totalShortPositionSize: coins
    /// Long open interest after the AMM update.
    openInterestLong: coins
    /// Short open interest after the AMM update.
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

/// Oracle payload passed through PositionManager into VAMM execution.
struct OraclePayload {
    /// Referenced oracle price data cell.
    priceData: Cell<OraclePriceData>
    /// Referenced oracle signature bundle cell.
    signatures: Cell<Signatures>
}

/// Single-market oracle price data payload.
struct PriceData {
    /// Oracle price amount.
    price: coins
    /// Primary oracle spread amount.
    spread: coins
    /// Secondary spread or reserved spread field.
    anotherSpread: uint32
    /// Storm asset id for this price feed.
    assetId: uint16
}

/// Oracle signature bundle container.
struct Signatures {
    /// Raw signature dictionary or signature payload cell.
    data: cell
}

/// Alias used by oracle payloads for the active single-price data layout.
type OraclePriceData = PriceData

/// Referral fee withdrawal request accepted by the PositionManager.
struct (0x12d9601d) StormTakeReferralFees {
    /// Referenced referral fee parameters.
    referralFees: Cell<Parameters>
}

/// Cancel a global or per-position order.
struct (0x67134629) StormCancelOrder {
    /// Four-bit order type to cancel.
    orderType: uint4
    /// Three-bit order index to cancel.
    orderIndex: uint3
    /// Direction bit of the order side.
    direction: uint1
    /// Optional gas/notification recipient; `addr_none` falls back to the trader.
    gasToAddress: address?
}

/// Create a limit/market order from the vault or an SL/TP order from trader/vault.
struct (0xa39843f4) StormCreateOrder {
    /// Four-bit order type selecting limit, market, stop-loss, or take-profit layout.
    orderType: uint4
    /// Optional gas/notification recipient; `addr_none` falls back to the trader.
    gasToAddress: address?
    /// Ref payload decoded by `OrderData`; kept raw because auth path depends on order type.
    order: cell
}

/// VAMM completion callback that applies a completed order result.
struct (0xcf90d618) StormCompleteOrder {
    /// Four-bit completed order type.
    orderType: uint4
    /// Three-bit completed order index.
    orderIndex: uint3
    /// Direction bit of the completed order.
    direction: uint1
    /// Originating AMM operation opcode.
    originOpcode: uint32
    /// Index oracle price used for completion.
    indexPrice: coins
    /// Settlement oracle price written directly by the VAMM callback.
    settlementOraclePrice: coins
    /// Referenced position delta cell.
    position: Cell<PositionChange>
    /// Referenced AMM delta cell.
    amm: Cell<AmmChange>
    /// Referenced VPI market-depth tuple appended by VAMM complete-order send sites.
    marketDepth: Cell<StormVpiMarketDepth>
}

/// VAMM callback that activates a pending order.
struct (0x9d2ec640) StormActivateOrder {
    /// Three-bit order index activated by the VAMM.
    orderIndex: uint3
    /// Referenced activated order selector.
    activatedOrder: Cell<OrderPayload>
}

/// VAMM callback that updates position state without trigger prices.
struct (0x60dfc677) StormUpdatePosition {
    /// Direction bit of the updated position.
    direction: uint1
    /// Originating AMM operation opcode.
    originOpcode: uint32
    /// Index oracle price used for the update.
    indexPrice: coins
    /// Settlement oracle price written directly by the VAMM callback.
    settlementOraclePrice: coins
    /// Referenced position delta cell.
    position: Cell<PositionChange>
    /// Referenced AMM delta cell.
    amm: Cell<AmmChange>
}

/// VAMM callback that updates position state and trigger prices.
struct (0x5d1b17b8) StormUpdatePositionWithStopLoss {
    /// Direction bit of the updated position.
    direction: uint1
    /// New stop-loss trigger price.
    stopTriggerPrice: coins
    /// New take-profit trigger price.
    takeTriggerPrice: coins
    /// Originating AMM operation opcode.
    originOpcode: uint32
    /// Index oracle price used for the update.
    indexPrice: coins
    /// Settlement oracle price written directly by the VAMM callback.
    settlementOraclePrice: coins
    /// Referenced position delta cell.
    position: Cell<PositionChange>
    /// Referenced AMM delta cell.
    amm: Cell<AmmChange>
}

/// Provide/remove-margin request that forwards oracle data to the VAMM.
struct (0x13076670) StormProvidePosition {
    /// Direction bit of the position side.
    direction: uint1
    /// Optional gas/notification recipient; `addr_none` falls back to the trader.
    gasToAddress: address?
    /// Originating AMM operation opcode such as remove-margin.
    originOpcode: uint32
    /// Margin or settlement amount supplied by the caller.
    amount: coins
    /// Referenced oracle payload for VAMM execution.
    oraclePayload: Cell<OraclePayload>
}

/// Request to execute an order through the VAMM.
struct (0x8865b402) StormProvideOrder {
    /// Four-bit order type to execute.
    orderType: uint4
    /// Three-bit order index to execute.
    orderIndex: uint3
    /// Direction bit of the order side.
    direction: uint1
    /// Executor index forwarded to the VAMM.
    executorIndex: uint32
    /// Referenced oracle payload for VAMM execution.
    oraclePayload: Cell<OraclePayload>
}

/// Order-created notification sent to the selected gas or redirect address.
struct (0x80f4c55b) StormOrderCreated {
    /// Four-bit created order type.
    orderType: uint4
    /// Three-bit created order index.
    orderIndex: uint3
    /// Direction bit of the created order.
    direction: uint1
}

/// Order-canceled notification sent to the selected gas or redirect address.
struct (0x7db85c00) StormOrderCanceled {
    /// Four-bit canceled order type.
    orderType: uint4
    /// Three-bit canceled order index.
    orderIndex: uint3
    /// Direction bit of the canceled order.
    direction: uint1
}

/// Execution or error notification sent to gas or redirect addresses.
struct (0x2089a59f) StormPositionManagerExecutionResult {
    /// PositionManager error or status code returned to the recipient.
    errorCode: uint32
}

/// Failure accounting notification sent back to the vault.
struct (0x0226df66) StormPositionManagerVaultFailure {
    /// Trader address whose PositionManager failed the requested flow.
    traderAddress: address
    /// VAMM address associated with the failed flow.
    vammAddress: address
    /// Amount converted or returned in the failure notification.
    amount: coins
    /// Optional gas/notification recipient carried back to the vault.
    gasToAddress: address?
    /// PositionManager error code reported to the vault.
    errorCode: uint32
}

/// VAMM execute-order message constructed by PositionManager send sites.
struct (0xde1ddbcc) StormExecuteOrderToVamm {
    /// Direction bit of the order side.
    direction: uint1
    /// Three-bit order index to execute.
    orderIndex: uint3
    /// Trader address that owns this PositionManager.
    traderAddress: address
    /// Previous redirect or owner address forwarded to the VAMM.
    previousAddress: address
    /// Optional referral address forwarded to the VAMM.
    referralAddress: address?
    /// Executor index forwarded to the VAMM.
    executorIndex: uint32
    /// Raw order payload cell forwarded to the VAMM.
    order: cell
    /// Referenced current position snapshot.
    position: Cell<PositionData>
    /// Referenced oracle payload for VAMM execution.
    oraclePayload: Cell<OraclePayload>
}

/// Union of internal message bodies accepted by PositionManager v4.
type StormPositionManagerIncomingMessage =
    | StormTakeReferralFees
    | StormCancelOrder
    | StormCreateOrder
    | StormCompleteOrder
    | StormActivateOrder
    | StormUpdatePosition
    | StormUpdatePositionWithStopLoss
    | StormProvidePosition
    | StormProvideOrder

/// Union of message bodies emitted by audited PositionManager v4 send sites.
type StormPositionManagerOutgoingMessage =
    | StormOrderCreated
    | StormOrderCanceled
    | StormPositionManagerExecutionResult
    | StormPositionManagerVaultFailure
    | StormExecuteOrderToVamm

/// Return tuple for `get_position_manager_data` method id 123739.
struct GetPositionManagerDataReply {
    /// Trader address from persistent storage.
    traderAddress: address
    /// Vault address from persistent storage.
    vaultAddress: address
    /// VAMM address from persistent storage.
    vammAddress: address
    /// Long record cell, or an empty cell when the storage field is null.
    longRecord: cell
    /// Short record cell, or an empty cell when the storage field is null.
    shortRecord: cell
    /// Global order dictionary cell, or an empty cell when the storage field is null.
    ordersDict: cell
    /// Referral data cell, or an empty cell when the storage field is null.
    referralData: cell
    /// Global order occupancy bitset from persistent storage.
    ordersBitset: uint8
}

/// PositionManager exit codes.
enum StormPositionManagerErrors {
    /// Position record is locked during an in-flight update.
    PositionLocked = 500
    /// Sender is not the configured VAMM.
    NotAnAmm = 501
    /// Sender is not the configured trader.
    NotATrader = 502
    /// Requested position or order data was not found.
    NotFound = 504
    /// Position already exists when a new one is required.
    PositionExists = 505
    /// Sender is not the configured vault.
    NotAVault = 507
    /// Order type discriminator is unsupported for this path.
    WrongOrderType = 508
    /// Order slot is already occupied.
    OrderExists = 509
    /// Order payload parameters are invalid.
    WrongOrderParams = 510
    /// Required position record is missing.
    PositionNotFound = 511
    /// Order expiration timestamp has passed.
    Expired = 512
    /// No free order slot is available.
    NoFreeOrder = 513
    /// Requested order index is empty.
    OrderNotFound = 514
    /// VAMM execution bounced.
    VammBounced = 515
    /// Order bitset is full.
    MaxOrders = 516
    /// Order was canceled before completion.
    OrderCanceled = 517
    /// Message value is below the provide-position minimum.
    MinProvideGas = 518
    /// Message value is below the provide-order minimum.
    MinProvideOrderGas = 519
    /// Message value is below the cancel-order minimum.
    MinCancelOrderGas = 520
    /// Sender is not the configured referral address.
    NotAReferral = 521
    /// PositionManager has not been initialized with referral data.
    NotInited = 522
    /// Initialization was attempted after referral data was already set.
    PositionManagerInited = 523
    /// Initialization source address does not match expected vault or trader path.
    WrongInitAddr = 524
    /// Migration message arrived after the accepted migration window.
    LateMigration = 525
    /// Order direction does not match the requested position side.
    DirectionMismatch = 526
    /// Market order was canceled before execution.
    MarketOrderCanceled = 527
    /// Operation opcode is not handled by this PositionManager.
    WrongOperation = 65535
}

/// Public getter returning decoded PositionManager runtime storage fields.
get fun get_position_manager_data(): GetPositionManagerDataReply {
    throw 0;
}

/// Public getter returning the raw persistent data cell.
get fun get_position_manager_contract_data(): cell {
    throw 0;
}

/// Public getter returning whether referral initialization data is present.
get fun get_is_inited(): bool {
    throw 0;
}

/// Public getter returning the hard-coded PositionManager version number.
get fun get_version(): uint32 {
    throw 0;
}
