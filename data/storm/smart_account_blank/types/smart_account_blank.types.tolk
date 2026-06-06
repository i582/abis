/// Storm Trade transient SmartAccount interface used before factory initialization.
contract SmartAccountBlank {
    author: "Storm Trade"
    version: "0.1-local-schema"
    description: "Storm Trade transient smart account used by the factory to initialize a user SmartAccount or process the first deposit."
    storage: SmartAccountBlankStorage
    incomingMessages: SmartAccountBlankIncomingMessage
    outgoingMessages: SmartAccountBlankOutgoingMessage
}

/// Transient blank SmartAccount storage shape exposed by get_blank_storage_data.
struct SmartAccountBlankStorage {
    /// Blank smart-account type discriminator stored in the first byte.
    saType: uint8
    /// Factory address allowed to initialize this blank account.
    factoryAddress: address
    /// Owner address associated with the future ordinary SmartAccount.
    ownerAddress: address
    /// Vault balances dictionary keyed by vault address.
    balances: map<address, coins>
}

/// Notification Payload V2 layout used by SmartAccountBlank.
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

/// Initialization Data layout used by SmartAccountBlank.
struct InitializationData {
    /// Highload replay-protection timeout encoded as uint24 seconds.
    highloadTimeout: uint24
    /// Referenced key bundle cell used during SmartAccount initialization or storage.
    keys: Cell<Keys>
    /// Ordinary SmartAccount version installed by this initialization payload.
    version: uint8
    /// Code cell that replaces the transient blank account code.
    newCode: cell
}

/// Long layout used by SmartAccountBlank.
struct (0b0) Long {}

/// Short layout used by SmartAccountBlank.
struct (0b1) Short {}

/// Position Data layout used by SmartAccountBlank.
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

/// Keys layout used by SmartAccountBlank.
struct Keys {
    /// Hot public key accepted by the SmartAccount key set.
    hotPublicKey: uint256
    /// Cold public key accepted by the SmartAccount key set.
    coldPublicKey: uint256
    /// Raw user public keys dictionary.
    userPublicKeys: map<uint256, cell>
    /// Number of user keys recorded in the key dictionary.
    keysCount: uint8
}

/// Direction union or alias used by SmartAccountBlank.
type Direction =
    | Long
    | Short

/// Internal message body declarations.
/// Storm Deposit Notify layout used by SmartAccountBlank.
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

/// Storm Referral Fees layout used by SmartAccountBlank.
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

/// Storm Init Sa layout used by SmartAccountBlank.
struct (0x5b0dd9f4) StormInitSa {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Initialization payload that installs ordinary SmartAccount code/storage.
    initData: InitializationData
}

/// Storm Deposit Notify With Deploy layout used by SmartAccountBlank.
struct (0x18a092f7) StormDepositNotifyWithDeploy {
    /// Message query id used to correlate this ABI message with the triggering transaction.
    queryId: uint64
    /// Vault contract address referenced by the deposit or withdrawal flow.
    vaultAddress: address
    /// Coin amount encoded in TON/jetton nanounits.
    amount: coins
    /// Original sender address encoded in the message body.
    senderAddress: address
    /// Initialization payload that installs ordinary SmartAccount code/storage.
    initData: InitializationData
}

/// Storm Deposit Revert layout used by SmartAccountBlank.
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

/// Smart Account Blank Incoming Message union or alias used by SmartAccountBlank.
type SmartAccountBlankIncomingMessage =
    | StormDepositNotify
    | StormReferralFees
    | StormInitSa
    | StormDepositNotifyWithDeploy

/// Smart Account Blank Outgoing Message union or alias used by SmartAccountBlank.
type SmartAccountBlankOutgoingMessage = StormDepositRevert

/// Get Blank Storage Data Reply layout used by SmartAccountBlank.
struct GetBlankStorageDataReply {
    /// SmartAccount type discriminator stored in the first byte.
    saType: uint8
    /// Factory address encoded in storage or getter output.
    factoryAddress: address
    /// Owner address encoded in storage or revert payload.
    ownerAddress: address
    /// Vault balances dictionary keyed by vault address.
    balances: map<address, coins>
}

/// SmartAccountBlank exit-code catalog.
enum Errors {
    /// Sender is not authorized for the initialization or deposit-with-deploy path.
    Unauthorized = 401
    /// Message opcode is not accepted by the transient blank account.
    WrongOperation = 65535
}

/// Getter returning transient blank SmartAccount storage data.
get fun get_blank_storage_data(): GetBlankStorageDataReply {
    return {
        saType: 0,
        factoryAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        balances: [],
    };
}
