contract AffluentMultiplyVaultV2 {
    author: "Affluent"
    version: "2.0"
    description: "Curated Affluent multiply vault v2 interface"
    storage: AffluentMultiplyVaultV2Storage
    outgoingMessages: AffluentMultiplyVaultV2OutgoingMessage
    forceAbiExport: AffluentVaultJettonPayload
}

// Standard jetton transfer emitted by the vault when moving managed assets.
struct (0x0f8a7ea5) JettonTransfer {
    queryId: uint64
    amount: coins
    destination: address
    responseDestination: address
    customPayload: cell?
    forwardTonAmount: coins
    forwardPayload: RemainingBitsAndRefs
}

struct (0x178d4519) JettonInternalTransfer {
    queryId: uint64
    amount: coins
    from: address
    responseAddress: address
    forwardTonAmount: coins
    forwardPayload: RemainingBitsAndRefs
}

// Jetton forward payloads accepted by Affluent vault flows.
struct (0xf9471134) AffluentDepositPayload {
    oracleParams: cell?
    forwardTonAmount: coins
    forwardPayload: cell?
}

struct (0xcb03bfaf) AffluentWithdrawPayload {
    assetAddress: address
    oracleParams: cell?
    forwardTonAmount: coins
    forwardPayload: cell?
}

type AffluentMultiplyVaultV2OutgoingMessage =
    | JettonTransfer
    | JettonInternalTransfer

type AffluentVaultJettonPayload =
    | AffluentDepositPayload
    | AffluentWithdrawPayload

struct AffluentMultiplyVaultV2Storage {
    base: Cell<AffluentMultiplyVaultV2StorageBase>
    extension: Cell<AffluentMultiplyVaultV2StorageExtension>
}

struct AffluentMultiplyVaultV2StorageBase {
    ownerAddress: address
    assets: cell?
    factorialPools: cell?
    aggregatorIndex: coins
    rfqIndex: coins
    totalSupply: coins
    collectedManagementFee: coins
    collectedProtocolFee: coins
    isExecutingStrategy: bool
    config: Cell<AffluentMultiplyVaultV2StorageConfig>
    code: Cell<AffluentMultiplyVaultV2StorageCode>
}

struct AffluentMultiplyVaultV2StorageConfig {
    protocolFeeManagerAddress: address
    manager: address
    isPrivateVault: bool
    depositCloseTimestamp: uint40
    withdrawCloseTimestamp: uint40
    whitelistedMinters: cell?
    lastCollectedTime: uint40
    managementFeeRatePerYear: uint14
    protocolFeeRatePerYear: uint14
    maxLeverageRatio: uint20
    assetWalletDict: cell?
    walletAssetDict: cell?
    extra: Cell<AffluentMultiplyVaultV2StorageExtra>
}

struct AffluentMultiplyVaultV2StorageExtra {
    rfqConfig: cell?
    gasConfig: cell?
    oracleConfig: cell?
    managementFeeRecipientAddress: address?
    guardianAddress: address?
    timelock: coins
    pendingOwnerActionIndex: coins
    pendingOwnerActionCount: coins
    pendingOwnerAction: cell?
}

struct AffluentMultiplyVaultV2StorageCode {
    walletCode: cell
    dataAggregatorCode: cell
    rfqCode: cell
    content: cell
}

struct AffluentMultiplyVaultV2StorageExtension {
    queueConfig: Cell<AffluentMultiplyVaultV2QueueConfig>
    xchain: Cell<AffluentMultiplyVaultV2XchainState>
}

struct AffluentMultiplyVaultV2QueueConfig {
    globalDepositValueCap: coins
    withdrawFeeRate: uint14
    queueWithdrawFeeRate: uint14
    depositQueue: Cell<AffluentMultiplyVaultV2DepositQueue>
    withdrawQueue: Cell<AffluentMultiplyVaultV2WithdrawQueue>
    interactiveVaults: cell?
}

struct AffluentMultiplyVaultV2DepositQueue {
    depositQueueTotalSize: coins
    depositQueueCounter: coins
    depositQueuePendingDict: cell?
    depositQueueProcessingDict: cell?
}

struct AffluentMultiplyVaultV2WithdrawQueue {
    withdrawQueueTotalSize: coins
    withdrawQueueCounter: coins
    withdrawQueuePendingDict: cell?
    withdrawQueueProcessingDict: cell?
}

struct AffluentMultiplyVaultV2XchainState {
    xchainConnectorAddress: address
    xchainConfig: cell?
    xchainUpdateHash: uint256
}

struct GetVaultDataAffluentVaultData {
    ownerAddress: address
    assets: cell
    factorialPools: cell?
    aggregatorIndex: int
    rfqIndex: int
    totalSupply: int
    collectedManagementFee: int
    collectedProtocolFee: int
    isExecutingStrategy: bool
    config: cell
    code: cell
    protocolFeeManagerAddress: address
    manager: address
    isPrivateVault: bool
    depositCloseTimestamp: int64
    withdrawCloseTimestamp: int64
    whitelistedMinters: cell?
    lastCollectedTime: int64
    managementFeeRatePerYear: int32
    protocolFeeRatePerYear: int32
    maxLeverageRatio: int32
    assetWalletDict: cell
    walletAssetDict: cell
    rfqConfig: cell?
    gasConfig: cell?
    oracleConfig: cell?
    managementFeeRecipientAddress: address?
    guardianAddress: address?
    timelock: int
    pendingOwnerActionIndex: int
    pendingOwnerActionCount: int
    pendingOwnerAction: cell?
    walletCode: cell
    dataAggregatorCode: cell
    rfqCode: cell
    content: cell
    globalDepositValueCap: int
    withdrawFeeRate: int
    queueWithdrawFeeRate: int
    depositQueueTotalSize: int
    depositQueueCounter: int
    depositQueuePendingDict: cell?
    depositQueueProcessingDict: cell?
    withdrawQueueTotalSize: int
    withdrawQueueCounter: int
    withdrawQueuePendingDict: cell?
    withdrawQueueProcessingDict: cell?
    interactiveVaults: cell?
    xchainConnectorAddress: address
    xchainConfig: cell?
    xchainUpdateHash: int
}

get fun get_vault_data(): GetVaultDataAffluentVaultData {
    throw 0;
}

struct GetJettonDataReply {
    totalSupply: int
    mintable: bool
    adminAddress: address
    jettonContent: cell
    jettonWalletCode: cell
}

get fun get_jetton_data(): GetJettonDataReply {
    throw 0;
}

get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

get fun is_strategy_vault(): bool {
    throw 0;
}

get fun get_rfq_address(index: int): address {
    throw 0;
}
