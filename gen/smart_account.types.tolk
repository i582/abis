// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract SmartAccount {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: SmartAccountIncomingMessage
    incomingExternal: SmartAccountIncomingExternalMessage
    outgoingMessages: SmartAccountOutgoingMessage
}

// TL-B helper types referenced by messages.
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

struct ExternalMsgPayload {
    queryId: ExecutorQueryId
    createdAt: uint32
    saAddress: address
    actualVersion: uint8
    upgradePayload: Cell<SignedUpgradePayload>?
    msg: Cell<PreparedMessage>?
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

struct ExecutorQueryId {
    shift: uint13
    bitNumber: uint10
}

struct SignedUpgradePayload {
    signature: bits512
    payload: map<uint8, UpgradePayload>
}

struct PreparedMessage {
    info: InternalMessageInfoRelaxed
    field2: NoInitRefBody
    msgBody: Cell<PreparedMessageBody>
}

struct ReferralDataV2 {
    discount: uint32
    rebate: uint32
    refInfo: map<uint4, ReferrerData>
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

struct UpgradePayload {
    migrateCode: cell?
    newCode: cell?
}

struct (0b0) IntMsgInfo {
    ihrDisabled: bool
    bounce: bool
    bounced: bool
    src: address
    dest: address
    value: (coins, ExtraCurrenciesMap)
    ihrFee: coins
    fwdFee: coins
    createdLt: uint64
    createdAt: uint32
}

struct (0b01) NoInitRefBody {}

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

struct ReferrerData {
    referrerAddress: address
    referrerPart: uint8
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

type Direction =
    | Long
    | Short

type Intent =
    | UserIntent
    | ExecutorIntent

type RefData =
    | RefData0
    | RefData1
    | RefData2

type OraclePayloadV2 =
    | Single
    | Double
    | SingleWithCreated
    | DoubleWithCreated

type SingleOraclePayload = WithoutSettlement

type DoubleOraclePayload = WithSettlement

type CreatedOraclePayload =
    | CreatedPrice
    | CreatedPriceWithSettlement

type ExecutorOrder =
    | Liquidate
    | ForceClose
    | ForceCloseMaxLeverage

type InternalMessageInfoRelaxed = IntMsgInfo

type PreparedMessageBody = TakePositionV2

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
struct (0x1ca43d2f) StormNotifyUpdatePosition {
    queryId: uint64
    jettonMinterAddress: address
    notificationPayload: Cell<NotificationPayloadV2>
}

struct (0x186b2edf) StormDepositNotify {
    queryId: uint64
    amount: coins
    senderAddress: address
    jettonMinterAddress: address
}

struct (0x6eec039d) StormWithdrawRequestUser {
    queryId: uint64
    vaultAddress: address
    amount: coins
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

struct (0x4fedc82b) StormReferralFees {
    queryId: uint64
    referralSaAddress: address
    amount: coins
    jettonMinterAddress: address
    notificationPayload: Cell<NotificationPayloadV2>
}

struct (0x5f40f1ec) StormExecuteOrdersBundleInternal {
    queryId: uint64
    signature: bits512
    payload: Cell<ExternalMsgPayload>
}

struct (0x220c4c19) StormAddPublicKey {
    queryId: uint64
    publicKey: uint256
}

struct (0x76519f8b) StormRemovePublicKey {
    queryId: uint64
    publicKey: uint256
}

struct (0x644794b8) StormRemoveAllKeysExceptCurrent {
    queryId: uint64
    publicKey: uint256
}

struct (0x5a091c43) StormDepositTon {
    queryId: uint64
}

struct (0x04c52fd2) StormExecuteOrdersBundleExternal {
    queryId: uint64
    signature: bits512
    payload: Cell<ExternalMsgPayload>
}

struct (0x1bea50f1) TakePositionV22 {
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

// Message unions used by Acton ABI.
type SmartAccountIncomingMessage =
    | StormNotifyUpdatePosition
    | StormDepositNotify
    | StormWithdrawRequestUser
    | StormFailNotification
    | StormReferralFees
    | StormExecuteOrdersBundleInternal
    | StormAddPublicKey
    | StormRemovePublicKey
    | StormRemoveAllKeysExceptCurrent
    | StormDepositTon

type SmartAccountIncomingExternalMessage = StormExecuteOrdersBundleExternal

type SmartAccountOutgoingMessage =
    | TakePositionV22
    | StormDepositRevert
    | StormWithdrawRequest

struct GetStorageDataReply {
    saType: uint8
    factoryAddress: address
    ownerAddress: address
    balances: cell?
    version: uint8
    keys: cell
    positions: cell?
    highloadData: cell
}

struct GetHighloadDataReply {
    oldQueries: cell
    queries: cell
    lastCleanTime: uint32
    timeout: uint32
}

struct GetKeysDataReply {
    hotPublicKey: int
    coldPublicKey: int
    userPublicKeys: cell
    keysCount: uint8
}

struct GetPositionReply {
    locked: bool
    position: cell?
}

struct ProcessedReply {
    shift: uint16
    bitNumber: uint16
    needClean: bool
}

enum Errors {
    Unauthorized = 401
    PublicKeyNotFound = 402
    TooManyPublicKeys = 403
    VaultNotFound = 404
    NotEnoughBalance = 405
    InsufficientGas = 406
    InvalidQueryId = 407
    InvalidDestination = 408
    InvalidPosition = 409
    PositionNotFree = 410
    InvalidOp = 411
    ParentQueryNotProcessed = 412
    InvalidTraderAddress = 413
    InvalidFactoryAddress = 414
    InvalidSenderAddress = 415
    TooManyReferrers = 416
    UpgradePayloadNotFound = 417
    NewCodeNotFound = 418
    InvalidDiscount = 419
    InvalidRebate = 420
    InvalidActualVersion = 421
    ReferrerDataNotFound = 422
    InvalidReferrerAddress = 423
    InvalidReferrerParts = 424
    IncorrectSpentAmount = 425
    TooManyIntents = 426
    NotEnoughRealBalance = 427
    InvalidCreatedAt = 170
    QueryAlreadyProcessed = 171
    InvalidSmartAccountAddress = 172
    InvalidMessageToSend = 173
    IntentAlreadyProcessed = 174
    InvalidAmmAddress = 158
    InvalidSaAddress = 190
    InvalidDirection = 191
    NotEnoughAmountForGas = 192
    UserSignatureInvalid = 180
    WrongOperation = 65535
}

get fun get_storage_data(): GetStorageDataReply {
    return {
        saType: 0,
        factoryAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        balances: null,
        version: 0,
        keys: createEmptyCell(),
        positions: null,
        highloadData: createEmptyCell(),
    };
}

get fun get_user_public_keys(): cell {
    return createEmptyCell();
}

get fun get_highload_data(): GetHighloadDataReply {
    return {
        oldQueries: createEmptyCell(),
        queries: createEmptyCell(),
        lastCleanTime: 0,
        timeout: 0,
    };
}

get fun get_keys_data(): GetKeysDataReply {
    return {
        hotPublicKey: 0,
        coldPublicKey: 0,
        userPublicKeys: createEmptyCell(),
        keysCount: 0,
    };
}

get fun get_vault_balance(vaultAddress: address): coins {
    return 0;
}

get fun get_position(): GetPositionReply {
    return {
        locked: false,
        position: null,
    };
}

get fun `processed?`(shift: int, bitNumber: int, needClean: int): ProcessedReply {
    return {
        shift: 0,
        bitNumber: 0,
        needClean: false,
    };
}
