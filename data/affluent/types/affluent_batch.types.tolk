contract AffluentBatch {
    author: "Affluent"
    version: "1.0"
    description: "Curated Affluent batch interface"
    storage: AffluentBatchStorage
    incomingMessages: AffluentBatchIncomingMessage
    outgoingMessages: AffluentBatchOutgoingMessage
    forceAbiExport: AffluentBatchForwardPayload | AffluentBatchAggregatorContext | AffluentBatchStorageRecord | AffluentBatchAggregatorData
}

struct AffluentBatchDepositRecord {
    amount: coins
    responseAddress: address
    forwardTonAmount: coins
    forwardPayload: cell?
}

struct AffluentBatchAssetData {
    cash: coins
    balance: coins
    isDepositable: bool
    isWhitelisted: bool
    isWithdrawable: bool
    exposureCap: uint20
}

struct AffluentBatchFactorialPoolAsset {
    supply: coins
    borrow: coins
    isSupplyable: bool
    isBorrowable: bool
}

struct AffluentBatchStorage {
    nativeReserve: coins
    asset0Minter: address
    asset1Minter: address
    asset0Deposited: coins
    asset1Deposited: coins
    asset0Deposits: cell?
    asset1Deposits: cell?
    executionFlag: uint8
    executionDeadline: uint40
    config: Cell<AffluentBatchStorageConfig>
    executionState: Cell<AffluentBatchExecutionState>
}

struct AffluentBatchStorageConfig {
    asset0Wallet: address
    asset1Wallet: address
    dataAggregatorCode: cell
    aggregatorIndex: coins
    oracleConfig: cell?
    withdrawFeeRateBps: coins
    feeRecipient: address
    executorWhitelist: cell?
    executionDelay: uint32
    executionWindow: uint32
}

struct AffluentBatchExecutionState {
    activeExecutor: address
    asset0CollectedFees: coins
    asset1CollectedFees: coins
    depositQueueSize: coins
    depositQueueLimit: coins
    asset0MinDeposit: coins
    asset1MinDeposit: coins
    limits: Cell<AffluentBatchExecutionLimits>
}

struct AffluentBatchExecutionLimits {
    asset0DepositCap: coins
    asset1DepositCap: coins
    codeAdmin: address
    asset0LastPrice: coins
    asset1LastPrice: coins
}

type AffluentBatchStorageRecord =
    | AffluentBatchDepositRecord
    | AffluentBatchAssetData
    | AffluentBatchFactorialPoolAsset

struct (0xbe5a7595) AffluentBatchInit {
    queryId: uint64
}

struct (0xd1735400) AffluentBatchTakeWalletAddress {
    queryId: uint64
    walletAddress: address
}

struct (0x7362d09c) JettonNotify {
    queryId: uint64
    amount: coins
    sender: address
    forwardPayload: RemainingBitsAndRefs
}

struct (0x67134629) AffluentBatchCancelDeposit {
    queryId: uint64
    side: uint1
}

struct (0x683a7dab) AffluentBatchStartExecution {
    queryId: uint64
}

struct (0x77c65602) AffluentBatchTakeAggregatedData {
    queryId: uint64
    index: coins
    assetData: cell?
    poolData: cell?
    vaultData: cell?
    contextPayload: AffluentBatchSwapContext
}

struct (0xd4374956) AffluentBatchProcessWithdrawals {
    queryId: uint64
    side: uint1
    maxItems: coins
}

struct (0xb9d749b8) AffluentBatchFinishExecution {
    queryId: uint64
}

struct (0x9d21f1da) AffluentBatchClaimFees {
    queryId: uint64
}

struct (0x44be0c76) AffluentBatchUpgradeCode {
    queryId: uint64
    code: cell
}

struct (0x2c76b973) ProvideWalletAddress {
    queryId: uint64
    ownerAddress: address
    includeAddress: bool
}

struct (0xd53276db) Excess {
    queryId: uint64
}

struct (0xb0c69ffe) AffluentBatchProvideAggregatedData {
    queryId: uint64
    assetRequests: cell?
    poolRequests: cell?
    vaultRequests: cell?
    contextPayload: AffluentBatchSwapContext
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

struct (0x193a4483) AffluentBatchDepositPayload {
    responseAddress: address
    forwardTonAmount: coins
    forwardPayload: cell?
}

struct (0xb48a809e) AffluentBatchOraclePayload {
    oracleData: cell?
}

struct (0xb48a809e) AffluentBatchSwapContext {
    side: uint1
    accountAddress: address
    amount: coins
}

type AffluentBatchIncomingMessage =
    | AffluentBatchInit
    | AffluentBatchTakeWalletAddress
    | JettonNotify
    | AffluentBatchCancelDeposit
    | AffluentBatchStartExecution
    | AffluentBatchTakeAggregatedData
    | AffluentBatchProcessWithdrawals
    | AffluentBatchFinishExecution
    | AffluentBatchClaimFees
    | AffluentBatchUpgradeCode

type AffluentBatchOutgoingMessage =
    | ProvideWalletAddress
    | Excess
    | AffluentBatchProvideAggregatedData
    | JettonTransfer

type AffluentBatchForwardPayload =
    | AffluentBatchDepositPayload
    | AffluentBatchOraclePayload

type AffluentBatchAggregatorContext = AffluentBatchSwapContext

type AffluentBatchAggregatorData =
    | AffluentBatchAssetData
    | AffluentBatchFactorialPoolAsset
