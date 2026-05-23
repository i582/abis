// Generated from XML ABI schemas.
// Source schema: schemas/jettons.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 8d28ea421b77e805fea52acf335296499f03aec8e9fd21ddb5f2564aa65c48de

contract JettonWalletV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/jettons.xml"
    incomingMessages: JettonWalletV2IncomingMessage
    outgoingMessages: JettonWalletV2OutgoingMessage
}

// TL-B message bodies.
struct (0x0f8a7ea5) JettonTransfer {
    queryId: uint64
    amount: coins
    destination: address
    responseDestination: address
    customPayload: cell?
    forwardTonAmount: coins
    forwardPayload: RemainingBitsAndRefs
}

struct (0x178d4519) JettonInternalTransfer {
    queryId: uint64
    amount: coins
    from: address
    responseAddress: address
    forwardTonAmount: coins
    forwardPayload: RemainingBitsAndRefs
}

struct (0x595f07bc) JettonBurn {
    queryId: uint64
    amount: coins
    responseDestination: address
    customPayload: cell?
}

struct (0x7bdd97de) JettonBurnNotification {
    queryId: uint64
    amount: coins
    sender: address
    responseDestination: address
}

struct (0x7362d09c) JettonNotify {
    queryId: uint64
    amount: coins
    sender: address
    forwardPayload: RemainingBitsAndRefs
}

// Message unions used by Acton ABI.
type JettonWalletV2IncomingMessage =
    | JettonTransfer
    | JettonInternalTransfer
    | JettonBurn

type JettonWalletV2OutgoingMessage =
    | JettonBurnNotification
    | JettonInternalTransfer
    | JettonNotify

struct GetWalletDataReply {
    balance: int
    owner: address
    jetton: address
    jettonWalletCode: cell
}

get fun get_wallet_data(): GetWalletDataReply {
    return {
        balance: 0,
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jetton: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
    };
}
