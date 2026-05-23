// Generated from XML ABI schemas.
// Source schema: schemas/jettons.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract JettonMaster {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/jettons.xml"
    incomingMessages: JettonMasterIncomingMessage
}

// TL-B message bodies.
struct (0x7bdd97de) JettonBurnNotification {
    queryId: uint64
    amount: coins
    sender: address
    responseDestination: address
}

// Message unions used by Acton ABI.
type JettonMasterIncomingMessage = JettonBurnNotification

struct GetJettonDataReply {
    totalSupply: int
    mintable: bool
    adminAddress: address
    jettonContent: cell
    jettonWalletCode: cell
}

get fun get_jetton_data(): GetJettonDataReply {
    return {
        totalSupply: 0,
        mintable: false,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
