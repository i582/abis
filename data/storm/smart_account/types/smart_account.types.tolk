/// Storm Trade SmartAccount interface for balances, positions, orders, keys, and replay protection.
contract SmartAccount {
    author: "Storm Trade"
    version: "0.1-local-schema"
    description: "Storm Trade smart account for balances, positions, order execution, key management, and highload replay protection."
    storage: SmartAccountStorage
    incomingMessages: SmartAccountIncomingMessage
    incomingExternal: SmartAccountIncomingExternalMessage
    outgoingMessages: SmartAccountOutgoingMessage
}

/// SmartAccount key bundle stored in the referenced storage cell.
struct Keys {
    /// Hot public key accepted by this SmartAccount.
    hotPublicKey: uint256
    /// Cold public key accepted by this SmartAccount.
    coldPublicKey: uint256
    /// User public keys dictionary.
    userPublicKeys: map<uint256, cell>
    /// Number of user public keys in the dictionary.
    keysCount: uint8
}

/// Highload replay-protection state used by SmartAccount storage.
struct HighloadData {
    /// Previous epoch query dictionary from the highload replay window.
    oldQueries: map<uint13, cell>
    /// Current epoch query dictionary from the highload replay window.
    queries: map<uint13, cell>
    /// Last cleanup timestamp for the highload replay window.
    lastCleanTime: uint64
    /// Highload replay timeout value.
    timeout: uint24
}

/// SmartAccount persistent storage layout.
struct SmartAccountStorage {
    /// SmartAccount type discriminator stored in the first byte.
    saType: uint8
    /// Factory address used to authenticate factory-originated operations.
    factoryAddress: address
    /// Owner address associated with this SmartAccount NFT item.
    ownerAddress: address
    /// Vault balances dictionary keyed by vault address.
    balances: map<address, coins>
    /// Ordinary SmartAccount code version installed by factory initialization.
    version: uint8
    /// Referenced key bundle with hot, cold, and user public keys.
    keys: Cell<Keys>
    /// Position dictionary keyed by 268-bit Storm position key.
    positions: map<bits268, PositionRecord>
    /// Referenced highload replay-protection state.
    highloadData: Cell<HighloadData>
}

/// Notification Payload V2 layout used by SmartAccount.
struct NotificationPayloadV2 {
    /// Bundle sender address carried by the Storm notification/order flow.
    bundleSenderAddress: address
    /// Signed or absolute balance delta carried by the notification payload.
    balanceDelta: coins
    /// AMM/VAMM contract address referenced by the order or notification.
    ammAddress: address
    /// Position direction union tag: long or short.
    direction: Direction
    /// Optional position data reference carried by the notification payload.
    positionData: Cell<PositionData>?
}

/// Long layout used by SmartAccount.
struct (0b0) Long {}

/// Short layout used by SmartAccount.
struct (0b1) Short {}

/// User Intent layout used by SmartAccount.
struct (0b0) UserIntent {
    /// 512-bit EdDSA-style signature carried by the signed payload.
    signature: bits512
    /// Referenced user/executor intent payload.
    intent: Cell<UserIntent2>
    /// Raw oracle payload cell; recursive union layout is kept opaque for Acton compatibility.
    oraclePayload: cell
    /// Optional next intent cell in the intent chain.
    nextIntent: cell?
}

/// Executor Intent layout used by SmartAccount.
struct (0b1) ExecutorIntent {
    /// Referenced user/executor intent payload.
    intent: Cell<ExecutorIntent2>
    /// Raw oracle payload cell; recursive union layout is kept opaque for Acton compatibility.
    oraclePayload: cell
    /// Optional next intent cell in the intent chain.
    nextIntent: cell?
}

/// External Msg Payload layout used by SmartAccount.
struct ExternalMsgPayload {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: ExecutorQueryId
    /// Creation timestamp field in seconds.
    createdAt: uint32
    /// SmartAccount address embedded in intent or external payload data.
    saAddress: address
    /// SmartAccount version expected by the external payload.
    actualVersion: uint8
    /// Optional signed upgrade payload reference.
    upgradePayload: Cell<SignedUpgradePayload>?
    /// Optional prepared internal message reference.
    msg: Cell<PreparedMessage>?
}

/// Addresses Data layout used by SmartAccount.
struct AddressesData {
    /// Trader address embedded in the prepared position message.
    traderAddress: address
    /// SmartAccountFactory address embedded in prepared position data.
    smartAccountFactoryAddress: address
    /// Vault contract address referenced by the deposit or withdrawal flow.
    vaultAddress: address
}

/// Ref Data0 layout used by SmartAccount.
struct (0x0) RefData0 {}

/// Ref Data1 layout used by SmartAccount.
struct (0x1) RefData1 {
    /// Referral data carried by the tagged reference payload.
    data: ReferralDataV2
}

/// Ref Data2 layout used by SmartAccount.
struct (0x2) RefData2 {
    /// Referral data carried by the tagged reference payload.
    data: ReferralDataV2
}

/// Position Data layout used by SmartAccount.
struct PositionData {
    /// Position size encoded as signed 128-bit integer.
    size: int128
    /// Position direction union tag: long or short.
    direction: Direction
    /// Position margin amount encoded as coins.
    margin: coins
    /// Open notional amount encoded as coins.
    openNotional: coins
    /// Last cumulative premium value stored for the position.
    lastUpdatedCumulativePremium: int64
    /// Position fee value from the position data.
    fee: uint32
    /// Referral discount value encoded in the position/referral data.
    discount: uint32
    /// Referral rebate value encoded in the position/referral data.
    rebate: uint32
    /// Last position update timestamp in seconds.
    lastUpdatedTimestamp: uint32
}

/// Free position record stored in the SmartAccount position dictionary.
struct (0b0) FreePositionRecord {
    /// Referenced position data payload.
    positionData: Cell<PositionData>
}

/// Locked position record stored in the SmartAccount position dictionary.
struct (0b1) LockedPositionRecord {
    /// Referenced position data payload.
    positionData: Cell<PositionData>
}

/// SmartAccount position dictionary value union from saved Storm TL-B.
type PositionRecord =
    | FreePositionRecord
    | LockedPositionRecord

/// User Intent2 layout used by SmartAccount.
struct UserIntent2 {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: UserQueryId
    /// Creation timestamp field in seconds.
    createdAt: uint32
    /// Optional parent query id referenced by this intent.
    referenceQueryId: UserQueryId?
    /// User public key carried by the key-management message.
    publicKey: bits256
    /// Referenced user/executor intent payload.
    intent: Cell<UserIntentPayload>
}

/// Single layout used by SmartAccount.
struct (0x00) Single {
    /// Referenced price oracle payload selected by the variant tag.
    priceOraclePayload: Cell<SingleOraclePayload>
    /// Optional referenced Lazer oracle message cell.
    lazerMessage: Cell<LazerMessage>?
}

/// Double layout used by SmartAccount.
struct (0x01) Double {
    /// Referenced price oracle payload selected by the variant tag.
    priceOraclePayload: Cell<DoubleOraclePayload>
    /// Optional referenced Lazer oracle message cell.
    lazerMessage: Cell<LazerMessage>?
}

/// Single With Created layout used by SmartAccount.
struct (0x02) SingleWithCreated {
    /// Referenced price oracle payload selected by the variant tag.
    priceOraclePayload: Cell<SingleOraclePayload>
    /// Referenced created-position oracle payload selected by the variant tag.
    createdOraclePayload: Cell<CreatedOraclePayload>
    /// Optional referenced Lazer oracle message cell.
    lazerMessage: Cell<LazerMessage>?
    /// Optional referenced Lazer oracle message for created-position data.
    createdLazerMessage: Cell<LazerMessage>?
}

/// Double With Created layout used by SmartAccount.
struct (0x03) DoubleWithCreated {
    /// Referenced price oracle payload selected by the variant tag.
    priceOraclePayload: Cell<DoubleOraclePayload>
    /// Referenced created-position oracle payload selected by the variant tag.
    createdOraclePayload: Cell<CreatedOraclePayload>
    /// Optional referenced Lazer oracle message cell.
    lazerMessage: Cell<LazerMessage>?
    /// Optional referenced Lazer oracle message for created-position data.
    createdLazerMessage: Cell<LazerMessage>?
}

/// Executor Intent2 layout used by SmartAccount.
struct ExecutorIntent2 {
    /// AMM/VAMM contract address referenced by the order or notification.
    ammAddress: address
    /// SmartAccount address embedded in intent or external payload data.
    saAddress: address
    /// Raw order cell for the nested order payload.
    order: cell
}

/// Executor Query Id layout used by SmartAccount.
struct ExecutorQueryId {
    /// Highload query-id shift component.
    shift: uint13
    /// Highload query-id bit component.
    bitNumber: uint10
}

/// Signed Upgrade Payload layout used by SmartAccount.
struct SignedUpgradePayload {
    /// 512-bit EdDSA-style signature carried by the signed payload.
    signature: bits512
    /// Nested upgrade payload dictionary.
    payload: map<uint8, UpgradePayload>
}

/// Prepared Message layout used by SmartAccount.
struct PreparedMessage {
    /// Relaxed internal-message info body.
    info: InternalMessageInfoRelaxed
    /// No-init marker in the prepared message layout.
    field2: NoInitRefBody
    /// Referenced prepared message body cell.
    msgBody: Cell<PreparedMessageBody>
}

/// Referral Data V2 layout used by SmartAccount.
struct ReferralDataV2 {
    /// Referral discount value encoded in the position/referral data.
    discount: uint32
    /// Referral rebate value encoded in the position/referral data.
    rebate: uint32
    /// Referral info dictionary keyed by 4-bit referral slot.
    refInfo: map<uint4, ReferrerData>
}

/// User Query Id layout used by SmartAccount.
struct UserQueryId {
    /// Highload query-id shift component.
    shift: uint13
    /// Highload query-id bit component.
    bitNumber: uint10
}

/// User Intent Payload layout used by SmartAccount.
struct UserIntentPayload {
    /// AMM/VAMM contract address referenced by the order or notification.
    ammAddress: address
    /// SmartAccount address embedded in intent or external payload data.
    saAddress: address
    /// Raw order cell for the nested order payload.
    order: cell
}

/// Without Settlement layout used by SmartAccount.
struct WithoutSettlement {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Raw signature set cell from the oracle payload.
    signatures: cell
}

/// Lazer Message layout used by SmartAccount.
struct LazerMessage {
    /// Magic prefix used by the oracle/Lazer payload.
    magic: uint32
    /// ECDSA signature r component in the Lazer message.
    r: uint256
    /// ECDSA signature s component in the Lazer message.
    s: uint256
    /// ECDSA recovery id in the Lazer message.
    v: uint8
    /// Byte length of the raw Lazer payload.
    payloadLength: uint16
    /// Raw Lazer payload cell.
    payload: cell
}

/// With Settlement layout used by SmartAccount.
struct WithSettlement {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Raw signature set cell from the oracle payload.
    signatures: cell
    /// Referenced settlement oracle update message cell.
    settlementUpdateMsg: Cell<UpdateMsgV2>
    /// Raw settlement signature set cell.
    settlementSignatures: cell
}

/// Created Price layout used by SmartAccount.
struct (0x00) CreatedPrice {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Raw signature set cell from the oracle payload.
    signatures: cell
}

/// Created Price With Settlement layout used by SmartAccount.
struct (0x01) CreatedPriceWithSettlement {
    /// Referenced oracle update message cell.
    updateMsg: Cell<UpdateMsgV2>
    /// Raw signature set cell from the oracle payload.
    signatures: cell
    /// Referenced settlement oracle update message cell.
    settlementUpdateMsg: Cell<UpdateMsgV2>
    /// Raw settlement signature set cell.
    settlementSignatures: cell
}

/// Liquidate layout used by SmartAccount.
struct (0x6) Liquidate {
    /// Position direction union tag: long or short.
    direction: Direction
}

/// Force Close layout used by SmartAccount.
struct (0x7) ForceClose {
    /// Position direction union tag: long or short.
    direction: Direction
}

/// Force Close Max Leverage layout used by SmartAccount.
struct (0x9) ForceCloseMaxLeverage {
    /// Position direction union tag: long or short.
    direction: Direction
}

/// Upgrade Payload layout used by SmartAccount.
struct UpgradePayload {
    /// Optional migration code cell from the upgrade payload.
    migrateCode: cell?
    /// Code cell that replaces the transient blank account code.
    newCode: cell?
}

/// Int Msg Info layout used by SmartAccount.
struct (0b0) IntMsgInfo {
    /// Relaxed internal-message IHR disabled flag.
    ihrDisabled: bool
    /// Relaxed internal-message bounce flag.
    bounce: bool
    /// Relaxed internal-message bounced flag.
    bounced: bool
    /// Source address from relaxed internal message info.
    src: address
    /// Destination address from relaxed internal message info.
    dest: address
    /// Relaxed internal-message value tuple with grams and extra currencies.
    value: (coins, ExtraCurrenciesMap)
    /// IHR fee field from relaxed internal message info.
    ihrFee: coins
    /// Forwarding fee field from relaxed internal message info.
    fwdFee: coins
    /// Logical time from relaxed internal message info.
    createdLt: uint64
    /// Creation timestamp field in seconds.
    createdAt: uint32
}

/// No Init Ref Body layout used by SmartAccount.
struct (0b01) NoInitRefBody {}

/// Take Position V2 layout used by SmartAccount.
struct (0x1bea50f1) TakePositionV2 {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Bundle sender address carried by the Storm notification/order flow.
    bundleSenderAddress: address
    /// AMM/VAMM contract address referenced by the order or notification.
    ammAddress: address
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount spent by the position-opening flow.
    spentAmount: coins
    /// Referenced address bundle for the prepared position message.
    addresses: Cell<AddressesData>
    /// Referral-data union carried by the prepared position message.
    ref: RefData
    /// Position payload or optional position cell.
    position: Cell<PositionData>
    /// Referenced user/executor intent payload.
    intent: Cell<Intent>
}

/// Referrer Data layout used by SmartAccount.
struct ReferrerData {
    /// Referrer address stored in referral data.
    referrerAddress: address
    /// Referrer share part stored as uint8.
    referrerPart: uint8
}

/// Stop Loss Order layout used by SmartAccount.
struct (0x0) StopLossOrder {
    /// Order expiration timestamp in seconds.
    expiration: uint32
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Trigger price threshold encoded as contract coin precision.
    triggerPrice: coins
}

/// Take Profit Order layout used by SmartAccount.
struct (0x1) TakeProfitOrder {
    /// Order expiration timestamp in seconds.
    expiration: uint32
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Trigger price threshold encoded as contract coin precision.
    triggerPrice: coins
}

/// Limit Market Order layout used by SmartAccount.
struct LimitMarketOrder {
    /// Raw order cell for the nested order payload.
    order: cell
}

/// Add Margin layout used by SmartAccount.
struct (0x4) AddMargin {
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
}

/// Remove Margin layout used by SmartAccount.
struct (0x5) RemoveMargin {
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
}

/// Request Order layout used by SmartAccount.
struct (0x8) RequestOrder {
    /// Raw selector cell kept opaque for the request-order layout.
    selector: cell
    /// Raw order cell for the nested order payload.
    order: cell
}

/// Update Msg layout used by SmartAccount.
struct UpdateMsg {
    /// Oracle or order price encoded as contract coin precision.
    price: coins
    /// Oracle spread value encoded as contract coin precision.
    spread: coins
    /// Oracle payload timestamp in seconds.
    timestamp: uint32
    /// Storm asset index used by the oracle update.
    assetIndex: uint16
    /// Oracle pause timestamp from the price update payload.
    pauseAt: uint32
    /// Oracle unpause timestamp from the price update payload.
    unpauseAt: uint32
    /// VPI spread value from the update payload.
    vpiSpread: coins
    /// VPI market depth for long direction.
    vpiMarketDepthLong: coins
    /// VPI market depth for short direction.
    vpiMarketDepthShort: coins
    /// VPI coefficient from the update payload.
    vpiCoefficient: uint64
}

/// Single2 layout used by SmartAccount.
struct (0b0) Single2 {
    /// Magic prefix used by the oracle/Lazer payload.
    magic: uint32
    /// Oracle payload timestamp in seconds.
    timestamp: uint64
    /// Lazer channel id encoded in the payload.
    channelId: uint8
    /// Number of Lazer feeds encoded in the payload.
    numberOfFeeds: uint8
    /// Feed id for the index feed.
    indexFeedId: uint32
    /// Index feed payload in the Lazer message.
    indexFeed: LazerFeed
}

/// Double2 layout used by SmartAccount.
struct (0b1) Double2 {
    /// Magic prefix used by the oracle/Lazer payload.
    magic: uint32
    /// Oracle payload timestamp in seconds.
    timestamp: uint64
    /// Lazer channel id encoded in the payload.
    channelId: uint8
    /// Number of Lazer feeds encoded in the payload.
    numberOfFeeds: uint8
    /// Feed id for the index feed.
    indexFeedId: uint32
    /// Index feed payload in the Lazer message.
    indexFeed: LazerFeed
    /// Feed id for the settlement feed.
    settlementFeedId: uint32
    /// Settlement feed payload in the Lazer message.
    settlementFeed: LazerFeed
}

/// Limit Order layout used by SmartAccount.
struct (0x2) LimitOrder {
    /// Order expiration timestamp in seconds.
    expiration: uint32
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Order leverage value encoded as uint64.
    leverage: uint64
    /// Limit price threshold encoded as contract coin precision.
    limitPrice: coins
    /// Stop price threshold encoded as contract coin precision.
    stopPrice: coins
    /// Stop trigger price encoded as contract coin precision.
    stopTriggerPrice: coins
    /// Take-profit trigger price encoded as contract coin precision.
    takeTriggerPrice: coins
}

/// Market Order layout used by SmartAccount.
struct (0x3) MarketOrder {
    /// Order expiration timestamp in seconds.
    expiration: uint32
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Order leverage value encoded as uint64.
    leverage: uint64
    /// Limit price threshold encoded as contract coin precision.
    limitPrice: coins
    /// Stop price threshold encoded as contract coin precision.
    stopPrice: coins
    /// Stop trigger price encoded as contract coin precision.
    stopTriggerPrice: coins
    /// Take-profit trigger price encoded as contract coin precision.
    takeTriggerPrice: coins
}

/// Execute Stop layout used by SmartAccount.
struct (0b0) ExecuteStop {}

/// Execute Take layout used by SmartAccount.
struct (0b1) ExecuteTake {}

/// Lazer Feed layout used by SmartAccount.
struct LazerFeed {
    /// Number of properties encoded in the Lazer feed.
    numberOfProperties: uint8
    /// Property id for the price value in the Lazer feed.
    pricePropertyId: uint8
    /// Price property value from the Lazer feed.
    pricePropertyValue: uint64
    /// Property id for the exponent value in the Lazer feed.
    exponentPropertyId: uint8
    /// Exponent property value from the Lazer feed.
    exponentPropertyValue: int16
}

/// Direction union or alias used by SmartAccount.
type Direction =
    | Long
    | Short

/// Intent union or alias used by SmartAccount.
type Intent =
    | UserIntent
    | ExecutorIntent

/// Ref Data union or alias used by SmartAccount.
type RefData =
    | RefData0
    | RefData1
    | RefData2

/// Oracle Payload V2 union or alias used by SmartAccount.
type OraclePayloadV2 =
    | Single
    | Double
    | SingleWithCreated
    | DoubleWithCreated

/// Single Oracle Payload union or alias used by SmartAccount.
type SingleOraclePayload = WithoutSettlement

/// Double Oracle Payload union or alias used by SmartAccount.
type DoubleOraclePayload = WithSettlement

/// Created Oracle Payload union or alias used by SmartAccount.
type CreatedOraclePayload =
    | CreatedPrice
    | CreatedPriceWithSettlement

/// Executor Order union or alias used by SmartAccount.
type ExecutorOrder =
    | Liquidate
    | ForceClose
    | ForceCloseMaxLeverage

/// Internal Message Info Relaxed union or alias used by SmartAccount.
type InternalMessageInfoRelaxed = IntMsgInfo

/// Prepared Message Body union or alias used by SmartAccount.
type PreparedMessageBody = TakePositionV2

/// User Order union or alias used by SmartAccount.
type UserOrder =
    | StopLossOrder
    | TakeProfitOrder
    | LimitMarketOrder
    | AddMargin
    | RemoveMargin
    | RequestOrder

/// Update Msg V2 union or alias used by SmartAccount.
type UpdateMsgV2 = UpdateMsg

/// Lazer Payload union or alias used by SmartAccount.
type LazerPayload =
    | Single2
    | Double2

/// Create Order union or alias used by SmartAccount.
type CreateOrder =
    | LimitOrder
    | MarketOrder

/// Execute Selector union or alias used by SmartAccount.
type ExecuteSelector =
    | ExecuteStop
    | ExecuteTake

/// Internal message body declarations.
/// Storm Notify Update Position layout used by SmartAccount.
struct (0x1ca43d2f) StormNotifyUpdatePosition {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Jetton minter address identifying the asset for this amount.
    jettonMinterAddress: address
    /// Referenced Storm notification payload cell.
    notificationPayload: Cell<NotificationPayloadV2>
}

/// Storm Deposit Notify layout used by SmartAccount.
struct (0x186b2edf) StormDepositNotify {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Original sender address encoded in the message body.
    senderAddress: address
    /// Jetton minter address identifying the asset for this amount.
    jettonMinterAddress: address
}

/// Storm Withdraw Request User layout used by SmartAccount.
struct (0x6eec039d) StormWithdrawRequestUser {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Vault contract address referenced by the deposit or withdrawal flow.
    vaultAddress: address
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
}

/// Storm Fail Notification layout used by SmartAccount.
struct (0x367f2743) StormFailNotification {
    /// Query id field used by the fail-notification payload.
    query: uint64
    /// Coin amount spent by the position-opening flow.
    spentAmount: coins
    /// Jetton minter address identifying the asset for this amount.
    jettonMinterAddress: address
    /// AMM/VAMM contract address referenced by the order or notification.
    ammAddress: address
    /// Position direction union tag: long or short.
    direction: Direction
    /// Bundle sender address carried by the Storm notification/order flow.
    bundleSenderAddress: address
    /// Referenced user/executor intent payload.
    intent: Cell<Intent>
}

/// Storm Referral Fees layout used by SmartAccount.
struct (0x4fedc82b) StormReferralFees {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Referral smart-account address that receives referral accounting.
    referralSaAddress: address
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Jetton minter address identifying the asset for this amount.
    jettonMinterAddress: address
    /// Referenced Storm notification payload cell.
    notificationPayload: Cell<NotificationPayloadV2>
}

/// Storm Execute Orders Bundle Internal layout used by SmartAccount.
struct (0x5f40f1ec) StormExecuteOrdersBundleInternal {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// 512-bit EdDSA-style signature carried by the signed payload.
    signature: bits512
    /// External message payload signed by the requester.
    payload: Cell<ExternalMsgPayload>
}

/// Storm Add Public Key layout used by SmartAccount.
struct (0x220c4c19) StormAddPublicKey {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// User public key carried by the key-management message.
    publicKey: uint256
}

/// Storm Remove Public Key layout used by SmartAccount.
struct (0x76519f8b) StormRemovePublicKey {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// User public key carried by the key-management message.
    publicKey: uint256
}

/// Storm Remove All Keys Except Current layout used by SmartAccount.
struct (0x644794b8) StormRemoveAllKeysExceptCurrent {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// User public key carried by the key-management message.
    publicKey: uint256
}

/// Storm Deposit Ton layout used by SmartAccount.
struct (0x5a091c43) StormDepositTon {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
}

/// Storm Execute Orders Bundle External layout used by SmartAccount.
struct (0x04c52fd2) StormExecuteOrdersBundleExternal {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// 512-bit EdDSA-style signature carried by the signed payload.
    signature: bits512
    /// External message payload signed by the requester.
    payload: Cell<ExternalMsgPayload>
}

/// Take Position V22 layout used by SmartAccount.
struct (0x1bea50f1) TakePositionV22 {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Bundle sender address carried by the Storm notification/order flow.
    bundleSenderAddress: address
    /// AMM/VAMM contract address referenced by the order or notification.
    ammAddress: address
    /// Position direction union tag: long or short.
    direction: Direction
    /// Coin amount spent by the position-opening flow.
    spentAmount: coins
    /// Referenced address bundle for the prepared position message.
    addresses: Cell<AddressesData>
    /// Referral-data union carried by the prepared position message.
    ref: RefData
    /// Position payload or optional position cell.
    position: Cell<PositionData>
    /// Referenced user/executor intent payload.
    intent: Cell<Intent>
}

/// Storm Deposit Revert layout used by SmartAccount.
struct (0x5b27f9c5) StormDepositRevert {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Original sender address encoded in the message body.
    senderAddress: address
    /// Owner address encoded in storage or revert payload.
    ownerAddress: address
}

/// Storm Withdraw Request layout used by SmartAccount.
struct (0x512cbd25) StormWithdrawRequest {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Owner address encoded in storage or revert payload.
    ownerAddress: address
}

/// Smart Account Incoming Message union or alias used by SmartAccount.
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

/// Smart Account Incoming External Message union or alias used by SmartAccount.
type SmartAccountIncomingExternalMessage = StormExecuteOrdersBundleExternal

/// Smart Account Outgoing Message union or alias used by SmartAccount.
type SmartAccountOutgoingMessage =
    | TakePositionV22
    | StormDepositRevert
    | StormWithdrawRequest

/// Get Storage Data Reply layout used by SmartAccount.
struct GetStorageDataReply {
    /// SmartAccount type discriminator stored in the first byte.
    saType: uint8
    /// Factory address encoded in storage or getter output.
    factoryAddress: address
    /// Owner address encoded in storage or revert payload.
    ownerAddress: address
    /// Vault balances dictionary keyed by vault address.
    balances: map<address, coins>
    /// Ordinary SmartAccount code version returned by storage getter.
    version: uint8
    /// Referenced key bundle cell used during SmartAccount initialization or storage.
    keys: cell
    /// Position dictionary keyed by 268-bit Storm position key.
    positions: map<bits268, PositionRecord>
    /// Referenced highload replay-protection state cell.
    highloadData: cell
}

/// Get Highload Data Reply layout used by SmartAccount.
struct GetHighloadDataReply {
    /// Previous highload replay dictionary.
    oldQueries: map<uint13, cell>
    /// Current highload replay dictionary.
    queries: map<uint13, cell>
    /// Last highload cleanup timestamp.
    lastCleanTime: uint64
    /// Highload replay timeout value.
    timeout: uint24
}

/// Get Keys Data Reply layout used by SmartAccount.
struct GetKeysDataReply {
    /// Hot public key accepted by the SmartAccount key set.
    hotPublicKey: int
    /// Cold public key accepted by the SmartAccount key set.
    coldPublicKey: int
    /// Raw user public keys dictionary.
    userPublicKeys: map<uint256, cell>
    /// Number of user keys recorded in the key dictionary.
    keysCount: uint8
}

/// Get Position Reply layout used by SmartAccount.
struct GetPositionReply {
    /// Getter flag indicating whether the requested position is locked.
    locked: bool
    /// Position payload or optional position cell.
    position: Cell<PositionData>?
}

/// SmartAccount exit-code catalog.
enum Errors {
    /// Sender is not authorized for the requested SmartAccount operation.
    Unauthorized = 401
    /// Requested public key was not found in the SmartAccount key dictionary.
    PublicKeyNotFound = 402
    /// Key-management request would exceed the allowed public-key count.
    TooManyPublicKeys = 403
    /// Referenced vault address is not present in SmartAccount balances.
    VaultNotFound = 404
    /// SmartAccount balance is below the requested amount.
    NotEnoughBalance = 405
    /// Incoming value is below the gas requirement for the requested operation.
    InsufficientGas = 406
    /// Highload query id is outside the accepted replay-protection window.
    InvalidQueryId = 407
    /// Prepared message destination is not accepted by SmartAccount validation.
    InvalidDestination = 408
    /// Position data or requested position state is invalid.
    InvalidPosition = 409
    /// Position is not free for the requested operation.
    PositionNotFree = 410
    /// Operation code or nested operation selector is invalid.
    InvalidOp = 411
    /// Parent query id has not been processed.
    ParentQueryNotProcessed = 412
    /// Trader address in the payload does not match the expected trader.
    InvalidTraderAddress = 413
    /// Factory address in the payload does not match the stored factory.
    InvalidFactoryAddress = 414
    /// Sender address does not match the expected sender for this path.
    InvalidSenderAddress = 415
    /// Referral data contains too many referrer entries.
    TooManyReferrers = 416
    /// Signed upgrade payload is missing when required.
    UpgradePayloadNotFound = 417
    /// Upgrade payload does not contain a new code cell.
    NewCodeNotFound = 418
    /// Referral discount value is outside the accepted range.
    InvalidDiscount = 419
    /// Referral rebate value is outside the accepted range.
    InvalidRebate = 420
    /// External payload version does not match the stored SmartAccount version.
    InvalidActualVersion = 421
    /// Referral-data entry expected by the flow was not found.
    ReferrerDataNotFound = 422
    /// Referrer address is invalid for the referral payload.
    InvalidReferrerAddress = 423
    /// Referrer share parts are invalid for the referral payload.
    InvalidReferrerParts = 424
    /// Spent amount in the payload does not match SmartAccount validation.
    IncorrectSpentAmount = 425
    /// Intent chain contains too many intents.
    TooManyIntents = 426
    /// Real balance is below the amount required for the operation.
    NotEnoughRealBalance = 427
    /// Created-at timestamp is outside the accepted time window.
    InvalidCreatedAt = 170
    /// Query id was already processed by highload replay protection.
    QueryAlreadyProcessed = 171
    /// SmartAccount address in the payload is invalid.
    InvalidSmartAccountAddress = 172
    /// Prepared message to send failed SmartAccount validation.
    InvalidMessageToSend = 173
    /// Nested intent was already processed.
    IntentAlreadyProcessed = 174
    /// AMM/VAMM address in the order payload is invalid.
    InvalidAmmAddress = 158
    /// SmartAccount address in the order payload is invalid.
    InvalidSaAddress = 190
    /// Direction tag is not accepted for the requested order.
    InvalidDirection = 191
    /// Order amount is below the gas-reserve threshold.
    NotEnoughAmountForGas = 192
    /// User signature over the intent payload is invalid.
    UserSignatureInvalid = 180
    /// Message opcode is not accepted by the SmartAccount dispatcher.
    WrongOperation = 65535
}

/// Getter returning SmartAccount storage data.
get fun get_storage_data(): GetStorageDataReply {
    throw 0;
}

/// Getter returning the SmartAccount user public-key dictionary.
get fun get_user_public_keys(): map<uint256, cell> {
    throw 0;
}

/// Getter returning SmartAccount highload replay-protection data.
get fun get_highload_data(): GetHighloadDataReply {
    throw 0;
}

/// Getter returning SmartAccount key data.
get fun get_keys_data(): GetKeysDataReply {
    throw 0;
}

/// Getter returning the balance for a vault address.
get fun get_vault_balance(vaultAddress: address): coins {
    throw 0;
}

/// Getter returning a position by its 268-bit key.
get fun get_position(positionKey: bits268): GetPositionReply {
    throw 0;
}

/// Return whether a highload query bit is already processed.
get fun `processed?`(shift: int, bitNumber: int, needClean: int): bool {
    throw 0;
}
