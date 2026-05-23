// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormExecutorCollection {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
}

enum Errors {
    NotAnOwner = 351
    ProvideVaultsMinValue = 352
    UnauthorizedBatchRequest = 353
    WrongVaultWc = 354
    VaultAlreadyAdded = 355
    MinExecutorMintValue = 356
}

get fun get_executor_vaults_whitelist(): cell {
    return createEmptyCell();
}
