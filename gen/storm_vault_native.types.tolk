// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormVaultNative {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: StormVaultNativeIncomingMessage
    outgoingMessages: StormVaultNativeOutgoingMessage
}

// TL-B helper types referenced by messages.
struct ReferralData {
    amount: coins
    index: uint32
}

struct ExecutorData {
    splitExecutorRewards: uint8
    amount: coins
    index: uint32
}

struct (0b1) NeedKeyInit {
    userPublicKeys: map<uint256, cell>
}

struct (0b0) NoKeyInit {}

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

struct (0b0) Long {}

struct (0b1) Short {}

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

struct OraclePayload {
    priceData: Cell<OraclePriceData>
    signatures: Cell<Signatures>
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

struct PriceData {
    price: coins
    spread: coins
    anotherSpread: uint32
    assetId: uint16
}

struct Signatures {
    data: cell
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

struct UpdateMsg {
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

struct LazerFeed {
    numberOfProperties: uint8
    pricePropertyId: uint8
    pricePropertyValue: uint64
    exponentPropertyId: uint8
    exponentPropertyValue: int16
}

type InitializationRequest =
    | NeedKeyInit
    | NoKeyInit

type Direction =
    | Long
    | Short

type Intent =
    | UserIntent
    | ExecutorIntent

type OraclePayloadV2 =
    | Single
    | Double
    | SingleWithCreated
    | DoubleWithCreated

type OraclePriceData = PriceData

type SingleOraclePayload = WithoutSettlement

type DoubleOraclePayload = WithSettlement

type CreatedOraclePayload =
    | CreatedPrice
    | CreatedPriceWithSettlement

type ExecutorOrder =
    | Liquidate
    | ForceClose
    | ForceCloseMaxLeverage

type UserOrder =
    | StopLossOrder
    | TakeProfitOrder
    | LimitMarketOrder
    | AddMargin
    | RemoveMargin
    | RequestOrder

type UpdateMsgV2 = UpdateMsg

type LazerPayload =
    | Single2
    | Double2

type CreateOrder =
    | LimitOrder
    | MarketOrder

type ExecuteSelector =
    | ExecuteStop
    | ExecuteTake

// TL-B message bodies.
struct (0xf5d4eb52) StormWithdrawReferralAmount {
    index: uint64
    referralAmount: coins
    ownerAddr: address
}

struct (0x2cde6351) StormWithdrawExecutorAmount {
    index: uint64
    executorAmount: coins
    ownerAddr: address
}

struct (0xc89a3ee4) StormVaultStake {
    amount: coins
}

struct (0x29c102d1) StormVaultInit {
    jettonAddress: address
}

struct (0x0226df66) StormRequestWithdrawPosition {
    traderAddr: address
    vammAddr: address
    amount: coins
    gasToAddr: address
    withdrawReason: uint32
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

struct (0x29bb3721) StormDepositNative {
    queryId: uint64
    amount: coins
    receiverAddress: address
    init: bool
    keyInit: cell
}

struct (0x5b27f9c5) StormDepositRevert {
    queryId: uint64
    amount: coins
    senderAddress: address
    ownerAddress: address
}

struct (0x512cbd25) StormWithdrawRequest {
    queryId: uint64
    amount: coins
    ownerAddress: address
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

struct (0x186b2edf) StormDepositNotify {
    queryId: uint64
    amount: coins
    senderAddress: address
    jettonMinterAddress: address
}

struct (0x367f2743) StormFailNotification {
    query: uint64
    spentAmount: coins
    jettonMinterAddress: address
    ammAddress: address
    direction: cell
    bundleSenderAddress: address
    intent: cell
}

struct (0x8865b402) StormProvidePosition {
    orderType: uint4
    orderIndex: uint3
    direction: uint1
    executorIndex: uint32
    oraclePayload: Cell<OraclePayload>
}

struct (0x4fedc82b) StormReferralFees {
    queryId: uint64
    referralSaAddress: address
    amount: coins
    jettonMinterAddress: address
    notificationPayload: Cell<NotificationPayloadV2>
}

struct (0x29c102d1) StormVammInit {
    redirectAddr: address
    code: cell
    data: cell
}

struct (0x6cde12e2) StormUnsuccessfulDeposit {
    queryId: uint64
}

struct (0x20d835c2) StormWithdrawSuccess {
    queryId: uint64
}

struct (0x1ca43d2f) StormNotifyUpdatePosition {
    queryId: uint64
    jettonMinterAddress: address
    notificationPayload: Cell<NotificationPayloadV2>
}

// Message unions used by Acton ABI.
type StormVaultNativeIncomingMessage =
    | StormWithdrawReferralAmount
    | StormWithdrawExecutorAmount
    | StormVaultStake
    | StormVaultInit
    | StormRequestWithdrawPosition
    | StormVaultTradeNotification
    | StormDepositNative
    | StormDepositRevert
    | StormWithdrawRequest
    | StormTradeNotificationV2
    | StormFailedBundleExecution

type StormVaultNativeOutgoingMessage =
    | StormDepositNotify
    | StormFailNotification
    | StormProvidePosition
    | StormReferralFees
    | StormVammInit
    | StormUnsuccessfulDeposit
    | StormWithdrawSuccess
    | StormNotifyUpdatePosition

struct GetVaultDataReply {
    jettonWallet: address
    rate: uint64
    totalSupply: coins
    freeBalance: coins
    lockedBalance: coins
    bufferBalance: uint64
    stakersBalance: coins
    executorsBalance: coins
    v3Paused: bool
}

struct GetBufferDataReply {
    bufferBalance: uint64
    bufferRate: coins
    bufferUnderRate: coins
    bufferOverRate: coins
}

enum Errors {
    InvalidJetton = 100
    InvalidJettonAmount = 101
    NotEnoughGas = 102
    WrongPositionAddress = 103
    NotAVamm = 104
    NotALpMinter = 106
    NotAnAdmin = 107
    WrongReferralItem = 108
    WrongExecutorItem = 109
    NotABatchOp = 110
    WrongBufferParams = 111
    NotAClaimer = 112
    JettonMinterNotFound = 113
    SmartAccountFactoryNotFound = 114
    KeysSetupNotAllowed = 115
    V3Paused = 116
    InvalidKeysDict = 117
    WrongOperation = 65535
}

get fun get_vault_contract_data(): cell {
    return createEmptyCell();
}

get fun get_vault_data(): GetVaultDataReply {
    return {
        jettonWallet: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        rate: 0,
        totalSupply: 0,
        freeBalance: 0,
        lockedBalance: 0,
        bufferBalance: 0,
        stakersBalance: 0,
        executorsBalance: 0,
        v3Paused: false,
    };
}

get fun get_buffer_data(): GetBufferDataReply {
    return {
        bufferBalance: 0,
        bufferRate: 0,
        bufferUnderRate: 0,
        bufferOverRate: 0,
    };
}

get fun get_vault_whitelisted_addresses(): cell {
    return createEmptyCell();
}

get fun get_position_address(traderAddress: address, vammAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_vamm_address(assetIndex: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_lp_minter_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_referral_item_addr(referralIndex: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_executor_item_addr(executorIndex: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_referral_collection_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_executor_collection_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_claimer_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_last_position_manager_code(): cell {
    return createEmptyCell();
}

get fun get_vault_type(): uint32 {
    return 0;
}
