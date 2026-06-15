contract AffluentAccount {
    author: "Affluent"
    version: "1.0"
    description: "Affluent Account is a user's lending account that tracks collateral, debt, and market positions across Affluent pools."
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
    throw 0;
}
