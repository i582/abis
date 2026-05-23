// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract SmartAccountFactory {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: SmartAccountFactoryIncomingMessage
    outgoingMessages: SmartAccountFactoryOutgoingMessage
}

// TL-B helper types referenced by messages.
struct InitializationData {
    highloadTimeout: uint24
    keys: Cell<Keys>
    version: uint8
    newCode: cell
}

struct Keys {
    hotPublicKey: uint256
    coldPublicKey: uint256
    userPublicKeys: map<uint256, cell>
    keysCount: uint8
}

// TL-B message bodies.
struct (0x5a89f5a2) StormNotifyWithDeploy {
    queryId: uint64
    amount: coins
    userPublicKeys: map<uint256, cell>
    senderAddress: address
    ownerAddress: address
    jettonMinterAddress: address
}

struct (0x0302cd79) StormDeployOrdinarySa {
    queryId: uint64
    userPublicKeys: map<uint256, cell>
}

struct (0x18a092f7) StormDepositNotifyWithDeploy {
    queryId: uint64
    vaultAddress: address
    amount: coins
    senderAddress: address
    initData: InitializationData
}

struct (0x5b0dd9f4) StormInitSa {
    queryId: uint64
    initData: InitializationData
}

// Message unions used by Acton ABI.
type SmartAccountFactoryIncomingMessage =
    | StormNotifyWithDeploy
    | StormDeployOrdinarySa

type SmartAccountFactoryOutgoingMessage =
    | StormDepositNotifyWithDeploy
    | StormInitSa

struct GetFactoryDataReply {
    adminAddress: address
    highloadTimeout: uint32
    hotPublicKey: int
    coldPublicKey: int
    content: cell
    saOrdinaryVersion: uint8
    saOrdinaryCode: cell
}

struct GetMinFeesReply {
    depositMinFeeNative: coins
    depositMinFeeJetton: coins
    depositWithDeployMinFeeNative: coins
    depositWithDeployMinFeeJetton: coins
    withdrawMinFee: coins
    ordinarySaStorageFee: coins
}

enum Errors {
    NotEnoughGasToDeploy = 150
    Unauthorized = 401
    InsufficientGas = 406
    WrongWorkchain = 710
    WrongOperation = 65535
}

get fun get_factory_data(): GetFactoryDataReply {
    return {
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        highloadTimeout: 0,
        hotPublicKey: 0,
        coldPublicKey: 0,
        content: createEmptyCell(),
        saOrdinaryVersion: 0,
        saOrdinaryCode: createEmptyCell(),
    };
}

get fun get_min_fees(): GetMinFeesReply {
    return {
        depositMinFeeNative: 0,
        depositMinFeeJetton: 0,
        depositWithDeployMinFeeNative: 0,
        depositWithDeployMinFeeJetton: 0,
        withdrawMinFee: 0,
        ordinarySaStorageFee: 0,
    };
}
