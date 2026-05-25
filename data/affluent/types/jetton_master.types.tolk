contract JettonMaster {
    author: "TON"
    version: "1.0"
    description: "Standard jetton master interface used by the Affluent FactorialTON minter"
    storage: JettonMasterStorage
    incomingMessages: JettonMasterIncomingMessage
}

struct JettonMasterStorage {
    jettonContent: cell
    jettonWalletCode: cell
}

struct (0x7bdd97de) JettonBurnNotification {
    queryId: uint64
    amount: coins
    sender: address
    responseDestination: address
}

type JettonMasterIncomingMessage = JettonBurnNotification

struct GetJettonDataReply {
    totalSupply: int
    mintable: bool
    adminAddress: address?
    jettonContent: cell
    jettonWalletCode: cell
}

get fun get_jetton_data(): GetJettonDataReply {
    return {
        totalSupply: 1000000000,
        mintable: true,
        adminAddress: null,
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
