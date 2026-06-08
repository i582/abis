/// Aqua Protocol USD master vault with jetton-minter getters, asset dictionaries, deposit/withdraw commands, and standard TON asset messages.
contract AquaUsdMasterVault {
    author: "Aqua Protocol"
    version: "1.0"
    description: "Aqua USD master vault ABI for root storage, jetton-minter getters, asset dictionaries, wallet discovery, asset transfers, and vault command bodies."
    storage: AquaUsdMasterVaultStorage
    incomingMessages: AquaUsdMasterVaultIncomingMessage
    outgoingMessages: AquaUsdMasterVaultOutgoingMessage
    thrownErrors: AquaUsdMasterVaultErrors
}

/// Root persistent storage split into four referenced sections.
struct AquaUsdMasterVaultStorage {
    /// Referenced admin, feature flag, timeout, asset dictionary, and settings section.
    adminConfig: Cell<AquaAdminConfig>
    /// Referenced total-supply, user-asset dictionaries, and pending action section.
    assetLedger: Cell<AquaAssetLedger>
    /// Referenced wallet code and auxiliary code section.
    codeRefs: Cell<AquaCodeRefs>
    /// Referenced jetton metadata content cell returned by `get_jetton_data`.
    jettonContent: cell
}

/// Admin and global settings section.
struct AquaAdminConfig {
    /// Admin address authorized for owner-only commands.
    adminAddress: address
    /// One-bit switch controlling public vault operations.
    operationsEnabled: bool
    /// Validity window stored as a 10-bit unsigned value.
    validityWindow: uint10
    /// Raw asset metadata dictionary.
    assets: cell?
    /// Raw asset-wallet dictionary.
    assetWallets: cell?
    /// Referenced global settings cell.
    settings: cell
}

/// Supply and per-user ledger section.
struct AquaAssetLedger {
    /// Total issued Aqua USD jettons encoded as TL-B `Coins`.
    totalSupply: coins
    /// Raw per-user asset dictionary.
    userAssets: cell?
    /// Raw per-user pending-operation dictionary.
    pendingOperations: cell?
    /// Referenced pending action payload.
    pendingAction: cell
}

/// Referenced code cells used by deterministic wallet and asset flows.
struct AquaCodeRefs {
    /// Jetton wallet code returned by `get_jetton_data`.
    jettonWalletCode: cell
    /// Auxiliary code or configuration cell.
    auxiliaryCode: cell
}

/// TEP-89 wallet discovery request accepted by the vault.
struct (0x2c76b973) AquaProvideWalletAddress {
    /// Caller-selected query id copied into `AquaTakeWalletAddress`.
    queryId: uint64
    /// Owner address whose deterministic wallet address is requested.
    ownerAddress: address
    /// True when the response includes a referenced owner address.
    includeAddress: bool
}

/// TEP-74 transfer notification accepted by the vault.
struct (0x7362d09c) AquaJettonTransferNotification {
    /// Query id copied from the originating transfer.
    queryId: uint64
    /// Received jetton amount in base units.
    amount: coins
    /// Source owner address reported by the sender wallet.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Aqua vault command with a referenced operation payload.
struct (0x02aaed1c) AquaExecuteAssetOperation {
    /// Caller-selected query id.
    queryId: uint64
    /// Referenced operation payload and remaining command tail.
    operation: RemainingBitsAndRefs
}

/// Aqua operations flag update command.
struct (0xd96f0b08) AquaFinalizePayout {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement one-bit operations flag.
    operationsEnabled: bool
}

/// Aqua routed asset command with raw remaining payload.
struct (0xe61feeea) AquaRoutedAssetCommand {
    /// Caller-selected query id.
    queryId: uint64
    /// Raw command payload.
    payload: RemainingBitsAndRefs
}

/// Aqua routed asset request with raw remaining payload.
struct (0x04bebfab) AquaAssetRouteRequest {
    /// Caller-selected query id.
    queryId: uint64
    /// Raw route payload.
    payload: RemainingBitsAndRefs
}

/// Aqua signed bundle command with raw remaining payload.
struct (0x1e0d25ea) AquaSignedBundleCommand {
    /// Caller-selected query id.
    queryId: uint64
    /// Raw signed bundle payload.
    payload: RemainingBitsAndRefs
}

/// Aqua asset callback with raw remaining payload.
struct (0xf2de0fef) AquaAssetCallback {
    /// Caller-selected query id.
    queryId: uint64
    /// Raw callback payload.
    payload: RemainingBitsAndRefs
}

/// Aqua account update command with raw remaining payload.
struct (0xe5836655) AquaAccountUpdateCommand {
    /// Caller-selected query id.
    queryId: uint64
    /// Raw update payload.
    payload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the Aqua USD master vault.
type AquaUsdMasterVaultIncomingMessage =
    | AquaProvideWalletAddress
    | AquaJettonTransferNotification
    | AquaExecuteAssetOperation
    | AquaFinalizePayout
    | AquaRoutedAssetCommand
    | AquaAssetRouteRequest
    | AquaSignedBundleCommand
    | AquaAssetCallback
    | AquaAccountUpdateCommand

/// TEP-89 wallet discovery response emitted to a requester.
struct (0xd1735400) AquaTakeWalletAddress {
    /// Query id copied from `AquaProvideWalletAddress`.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when unavailable.
    walletAddress: address?
    /// Optional referenced owner address cell.
    ownerAddress: Cell<address>?
}

/// TEP-74 jetton transfer emitted by the vault.
struct (0x0f8a7ea5) AquaJettonTransfer {
    /// Query id copied from the vault operation.
    queryId: uint64
    /// Jetton amount to transfer in base units.
    amount: coins
    /// Destination owner address.
    destination: address
    /// Optional response address for excess TON.
    responseDestination: address?
    /// Optional referenced custom payload.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-62 NFT transfer emitted by the vault.
struct (0x5fcc3d14) AquaNftTransfer {
    /// Query id copied from the vault operation.
    queryId: uint64
    /// New NFT owner address.
    newOwnerAddress: address
    /// Optional response destination for excess TON.
    responseDestination: address?
    /// Optional referenced custom payload.
    customPayload: cell?
    /// Nanotons forwarded to the new owner notification.
    forwardAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 excess-value response emitted by the vault.
struct (0xd53276db) AquaExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Aqua payout response with raw remaining payload.
struct (0xc74a7fe7) AquaPayoutResponse {
    /// Query id copied from the vault command.
    queryId: uint64
    /// Raw payout response payload.
    payload: RemainingBitsAndRefs
}

/// Aqua asset acknowledgement with raw remaining payload.
struct (0x007a59cd) AquaAssetAcknowledgement {
    /// Query id copied from the vault command.
    queryId: uint64
    /// Raw acknowledgement payload.
    payload: RemainingBitsAndRefs
}

/// Aqua asset completion callback with raw remaining payload.
struct (0xcb03bfaf) AquaAssetCompletion {
    /// Query id copied from the vault command.
    queryId: uint64
    /// Raw completion payload.
    payload: RemainingBitsAndRefs
}

/// Internal message bodies emitted by the Aqua USD master vault.
type AquaUsdMasterVaultOutgoingMessage =
    | AquaTakeWalletAddress
    | AquaJettonTransfer
    | AquaNftTransfer
    | AquaExcesses
    | AquaPayoutResponse
    | AquaAssetAcknowledgement
    | AquaAssetCompletion

/// Structured result returned by `get_jetton_data`.
struct GetAquaJettonDataReply {
    /// Total issued Aqua USD jettons returned as a TVM stack integer.
    totalSupply: int
    /// Mintability flag returned by the jetton-minter getter.
    mintable: bool
    /// Current admin address.
    adminAddress: address
    /// Referenced jetton metadata content cell.
    jettonContent: cell
    /// Referenced wallet code cell.
    jettonWalletCode: cell
}

/// Structured result returned by `get_assets`.
struct GetAquaAssetsReply {
    /// Raw asset metadata dictionary cell.
    assets: cell
    /// Raw asset-wallet dictionary cell.
    assetWallets: cell
}

/// Aqua USD master vault exit-code catalog.
enum AquaUsdMasterVaultErrors {
    /// Requested asset amount must be positive.
    InvalidAmount = 60
    /// Wallet discovery response budget is insufficient.
    InsufficientWalletDiscoveryValue = 70
    /// Sender is not the stored jetton admin.
    InvalidJettonAdminSender = 76
    /// Sender is not the stored admin address.
    UnauthorizedAdmin = 80
    /// Required referenced payload is missing.
    MissingPayload = 100
    /// Public operations are disabled.
    OperationsDisabled = 101
    /// Requested balance is insufficient.
    InsufficientBalance = 125
    /// Requested asset balance is insufficient.
    InsufficientAssetBalance = 126
    /// Mint cap would be exceeded.
    MintCapExceeded = 129
    /// Asset operation already exists.
    DuplicateAssetOperation = 131
    /// Wallet sender is not the expected jetton wallet.
    InvalidWalletSender = 202
    /// Callback sender is invalid.
    InvalidCallbackSender = 205
    /// Asset callback sender is invalid.
    InvalidAssetCallbackSender = 221
    /// Asset callback state is invalid.
    InvalidAssetCallbackState = 223
    /// Address workchain is not supported.
    IncorrectWorkchain = 333
    /// Attached value does not cover the operation budget.
    InsufficientOperationValue = 709
    /// Asset entry was not found.
    AssetNotFound = 800
    /// Asset operation failed.
    AssetOperationFailed = 801
    /// Oracle command is unsupported.
    UnsupportedOracleCommand = 810
    /// Oracle chain id is invalid.
    InvalidOracleChain = 811
    /// Oracle timestamp is outside the accepted window.
    InvalidOracleTimestamp = 812
    /// Deferred callback opcode is invalid.
    InvalidDeferredOpcode = 65520
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return the deterministic wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return total supply, mintability, admin address, content cell, and wallet code cell.
get fun get_jetton_data(): GetAquaJettonDataReply {
    throw 0;
}

/// Return raw asset dictionaries used by the vault.
get fun get_assets(): GetAquaAssetsReply {
    throw 0;
}
