// Generated from XML ABI schemas.
// Source schema: schemas/daolama.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract DaolamaVault {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/daolama.xml"
    incomingMessages: DaolamaVaultIncomingMessage
}

// TL-B message bodies.
struct (0x5c11ada9) DaolamaVaultSupply {
    amount: coins
}

struct (0x7bdd97de) DaolamaVaultWithdraw {
    jettonAmount: coins
    userAddress: address
}

// Message unions used by Acton ABI.
type DaolamaVaultIncomingMessage =
    | DaolamaVaultSupply
    | DaolamaVaultWithdraw

struct GetPoolDataReply {
    halted: bool
    balance: uint64
    borrowed: uint64
    lpTokenBalance: uint64
    feeCollected: uint64
}

get fun get_pool_data(): GetPoolDataReply {
    return {
        halted: false,
        balance: 0,
        borrowed: 0,
        lpTokenBalance: 0,
        feeCollected: 0,
    };
}
