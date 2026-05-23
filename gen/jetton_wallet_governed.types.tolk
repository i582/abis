// Generated from XML ABI schemas.
// Source schema: schemas/jettons.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 89468f02c78e570802e39979c8516fc38df07ea76a48357e0536f2ba7b3ee37b

contract JettonWalletGoverned {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/jettons.xml"
    incomingMessages: JettonWalletGovernedIncomingMessage
    outgoingMessages: JettonWalletGovernedOutgoingMessage
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
type JettonWalletGovernedIncomingMessage =
    | JettonTransfer
    | JettonInternalTransfer
    | JettonBurn

type JettonWalletGovernedOutgoingMessage =
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
