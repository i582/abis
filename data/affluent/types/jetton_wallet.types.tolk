contract JettonWallet {
    author: "TON"
    version: "1.0"
    description: "Standard jetton wallet interface used by Affluent FactorialTON wallets"
    storage: JettonWalletStorage
    incomingMessages: JettonWalletIncomingMessage
    outgoingMessages: JettonWalletOutgoingMessage
}

struct JettonWalletStorage {
    owner: address
    jetton: address
    jettonWalletCode: cell
}

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

type JettonWalletIncomingMessage =
    | JettonTransfer
    | JettonInternalTransfer
    | JettonBurn

type JettonWalletOutgoingMessage =
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
    throw 0;
}
