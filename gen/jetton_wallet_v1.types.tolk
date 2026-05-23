// Generated from XML ABI schemas.
// Source schema: schemas/jettons.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: beb0683ebeb8927fe9fc8ec0a18bc7dd17899689825a121eab46c5a3a860d0ce

contract JettonWalletV1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/jettons.xml"
    incomingMessages: JettonWalletV1IncomingMessage
    outgoingMessages: JettonWalletV1OutgoingMessage
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
type JettonWalletV1IncomingMessage =
    | JettonTransfer
    | JettonInternalTransfer
    | JettonBurn

type JettonWalletV1OutgoingMessage =
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
