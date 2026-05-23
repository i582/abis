// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract SmartAccountBlank {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: SmartAccountBlankIncomingMessage
    outgoingMessages: SmartAccountBlankOutgoingMessage
}

// TL-B helper types referenced by messages.
struct NotificationPayloadV2 {
    bundleSenderAddress: address
    balanceDelta: coins
    ammAddress: address
    direction: cell
    positionData: Cell<PositionData>?
}

struct InitializationData {
    highloadTimeout: uint24
    keys: Cell<Keys>
    version: uint8
    newCode: cell
}

struct (0b0) Long {}

struct (0b1) Short {}

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

struct Keys {
    hotPublicKey: uint256
    coldPublicKey: uint256
    userPublicKeys: map<uint256, cell>
    keysCount: uint8
}

type Direction =
    | Long
    | Short

// TL-B message bodies.
struct (0x186b2edf) StormDepositNotify {
    queryId: uint64
    amount: coins
    senderAddress: address
    jettonMinterAddress: address
}

struct (0x4fedc82b) StormReferralFees {
    queryId: uint64
    referralSaAddress: address
    amount: coins
    jettonMinterAddress: address
    notificationPayload: Cell<NotificationPayloadV2>
}

struct (0x5b0dd9f4) StormInitSa {
    queryId: uint64
    initData: InitializationData
}

struct (0x18a092f7) StormDepositNotifyWithDeploy {
    queryId: uint64
    vaultAddress: address
    amount: coins
    senderAddress: address
    initData: InitializationData
}

struct (0x5b27f9c5) StormDepositRevert {
    queryId: uint64
    amount: coins
    senderAddress: address
    ownerAddress: address
}

// Message unions used by Acton ABI.
type SmartAccountBlankIncomingMessage =
    | StormDepositNotify
    | StormReferralFees
    | StormInitSa
    | StormDepositNotifyWithDeploy

type SmartAccountBlankOutgoingMessage = StormDepositRevert

struct GetBlankStorageDataReply {
    saType: uint8
    factoryAddress: address
    ownerAddress: address
    balances: cell?
}

enum Errors {
    Unauthorized = 401
    WrongOperation = 65535
}

get fun get_blank_storage_data(): GetBlankStorageDataReply {
    return {
        saType: 0,
        factoryAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        balances: null,
    };
}
