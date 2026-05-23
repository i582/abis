// Generated from XML ABI schemas.
// Source schema: schemas/notcoin.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Notcoin {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/notcoin.xml"
}

struct JettonWalletLockDataReply {
    fullBalance: int
    individualUnlockTime: uint32
}

get fun jetton_wallet_lock_data(): JettonWalletLockDataReply {
    return {
        fullBalance: 0,
        individualUnlockTime: 0,
    };
}
