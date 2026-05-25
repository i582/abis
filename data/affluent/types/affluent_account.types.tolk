contract AffluentAccount {
    author: "Affluent"
    version: "1.0"
    description: "Curated Affluent account-like contract interface with get_account_data"
    storage: AffluentAccountStorage
}

struct AffluentAccountStorage {
    ownerAddress: address
    secondaryAddress: address
    balances: cell?
    pendingBalances: cell?
}

struct GetAccountDataReply {
    ownerAddress: address
    secondaryAddress: address
    balances: cell
    pendingBalances: cell
}

get fun get_account_data(): GetAccountDataReply {
    return {
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        secondaryAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        balances: createEmptyCell(),
        pendingBalances: createEmptyCell(),
    };
}
