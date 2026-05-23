// Generated from XML ABI schemas.
// Source schema: schemas/affluent.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract AffluentLendingVault {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/affluent.xml"
    outgoingMessages: AffluentLendingVaultOutgoingMessage
}

// TL-B helper types referenced by messages.
struct (0xf9471134) DepositContext {
    assetAddress: address
    fromAddress: address
    amount: coins
    forwardTonAmount: coins
    forwardPayload: cell?
}

// TL-B message bodies.
struct (0xab7bef17) TakeAggregatedDataDeposit {
    queryId: uint64
    index: coins
    assetData: cell?
    poolData: cell?
    vaultData: cell?
    contextPayload: DepositContext
}

struct (0xb0c69ffe) ProvideAggregatedDataDeposit {
    queryId: uint64
    assetRequests: cell?
    poolRequests: cell?
    vaultRequests: cell?
    contextPayload: DepositContext
}

// Message unions used by Acton ABI.
type AffluentLendingVaultOutgoingMessage =
    | TakeAggregatedDataDeposit
    | ProvideAggregatedDataDeposit

struct GetVaultDataWhitelistedPool {
    poolAddress: address
    isWhitelisted: bool
    targetWeight: int
    supplyShare: int
    supplyAmount: int
    poolCash: int
}

struct GetVaultDataReply {
    totalSupply: int
    ownerAddress: address
    managerAddress: address
    assetAddress: address
    balance: int
    cash: int
    totalTargetWeight: int
    assetWalletAddress: address
    whitelistedPool: lisp_list<GetVaultDataWhitelistedPool>
    jettonWalletCode: cell
    poolAggregatorCode: cell
}

get fun get_vault_data(): GetVaultDataReply {
    return {
        totalSupply: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        managerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        assetAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        balance: 0,
        cash: 0,
        totalTargetWeight: 0,
        assetWalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        whitelistedPool: [],
        jettonWalletCode: createEmptyCell(),
        poolAggregatorCode: createEmptyCell(),
    };
}
