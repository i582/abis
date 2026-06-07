contract AffluentLendingVault {
    author: "Affluent"
    version: "1.0"
    description: "Curated Affluent lending vault interface"
    storage: AffluentLendingVaultStorage
    outgoingMessages: AffluentLendingVaultOutgoingMessage
    forceAbiExport: AffluentLendingVaultExtendedOutgoingMessage | AffluentVaultJettonPayload
}

// TL-B helper types referenced by messages.
struct (0xf9471134) DepositContext {
    assetAddress: address
    fromAddress: address
    amount: coins
    forwardTonAmount: coins
    forwardPayload: cell?
}

struct (0xcb03bfaf) WithdrawContext {
    assetAddress: address
    fromAddress: address
    amount: coins
    forwardTonAmount: coins
    forwardPayload: cell?
}

// TL-B message bodies.
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

struct (0xab7bef17) TakeAggregatedDataDeposit {
    queryId: uint64
    index: coins
    assetData: cell?
    poolData: cell?
    vaultData: cell?
    contextPayload: DepositContext
}

struct (0xd9cf8c91) TakeAggregatedDataWithdraw {
    queryId: uint64
    index: coins
    assetData: cell?
    poolData: cell?
    vaultData: cell?
    contextPayload: WithdrawContext
}

struct (0xb0c69ffe) ProvideAggregatedDataDeposit {
    queryId: uint64
    assetRequests: cell?
    poolRequests: cell?
    vaultRequests: cell?
    contextPayload: DepositContext
}

struct (0xb0c69ffe) ProvideAggregatedDataWithdraw {
    queryId: uint64
    assetRequests: cell?
    poolRequests: cell?
    vaultRequests: cell?
    contextPayload: WithdrawContext
}

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

// Message unions used by Acton ABI.
type AffluentLendingVaultOutgoingMessage =
    | JettonTransfer
    | JettonInternalTransfer
    | TakeAggregatedDataDeposit
    | ProvideAggregatedDataDeposit

type AffluentLendingVaultExtendedOutgoingMessage =
    | TakeAggregatedDataDeposit
    | TakeAggregatedDataWithdraw
    | ProvideAggregatedDataDeposit
    | ProvideAggregatedDataWithdraw

type AffluentVaultJettonPayload =
    | AffluentDepositPayload
    | AffluentWithdrawPayload

struct AffluentLendingVaultStorage {
    totalSupply: coins
    ownerAddress: address
    managerAddress: address
    balance: coins
    cash: coins
    totalTargetWeight: coins
    aggregatorIndex: coins
    payloadMarkerEnabled: bool
    whitelistedPools: cell?
    assetConfig: Cell<AffluentLendingVaultAssetConfig>
    gasConfig: Cell<AffluentLendingVaultGasConfig>
}

struct AffluentLendingVaultAssetConfig {
    assetAddress: address
    assetWalletAddress: address
    jettonContent: cell
    jettonWalletCode: cell
    poolAggregatorCode: cell
}

struct AffluentLendingVaultGasConfig {
    depositAggregatorGas: coins
    withdrawAggregatorGas: coins
    depositJettonTransferGas: coins
    withdrawJettonTransferGas: coins
    walletDeploymentGas: coins
}

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
