// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormExecutor {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: StormExecutorIncomingMessage
    outgoingMessages: StormExecutorOutgoingMessage
}

// TL-B message bodies.
struct (0x4f38cae8) StormMintExecutor {
    nftOwner: address
    redirectAddress: address
    balancesDict: cell
}

struct (0x5dd66579) StormAddExecutorAmount {
    referralAmount: coins
    originAddr: address
}

struct (0x2cde6351) StormWithdrawExecutorAmount {
    index: uint64
    executorAmount: coins
    ownerAddr: address
}

// Message unions used by Acton ABI.
type StormExecutorIncomingMessage =
    | StormMintExecutor
    | StormAddExecutorAmount

type StormExecutorOutgoingMessage = StormWithdrawExecutorAmount

enum Errors {
    NotAnOwner = 351
    WrongVaultWc = 354
    NegativeResponseValue = 357
    NotACollection = 358
    MinAddAmountValue = 359
    VaultWasNotAdded = 360
    MinTonForClaim = 361
    VaultNotFound = 362
    WrongOperation = 65535
}

get fun get_executor_balances(): cell {
    return createEmptyCell();
}
