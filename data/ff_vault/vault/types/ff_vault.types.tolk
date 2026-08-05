/// Bidask Farming vault that stakes an asset Jetton, distributes stable-token rewards, and issues NFT positions.
contract FfVault {
    author: "Bidask"
    description: "Bidask Farming FF Vault coordinates asset staking, stable-token rewards, Pyth price updates, and NFT position accounts."
    storage: FfVaultStorage
    incomingMessages: FfVaultIncomingMessage
    outgoingMessages: FfVaultOutgoingMessage
    forceAbiExport: FfVaultAssetDeposit
        | FfVaultStableDeposit
        | FfVaultPositionData
        | FfVaultStakeOperation
        | FfVaultUnstakeOperation
    thrownErrors: FfVaultErrors
}

/// Immutable addresses, child code, and token precision referenced by Vault storage.
struct FfVaultStaticData {
    /// Pyth oracle account used to validate asset price updates.
    pythOracle: address
    /// Vault-owned wallet for the staked asset Jetton.
    assetJettonWallet: address
    /// Vault-owned wallet for the distributed stable-token Jetton.
    stableJettonWallet: address
    /// Code installed into deterministic NFT position accounts.
    nftItemCode: cell
    /// Decimal precision of the stable-token Jetton.
    stableDecimals: uint8
    /// Decimal precision of the staked asset Jetton.
    assetDecimals: uint8
}

/// Complete initialized Vault state; the leading zero byte is the storage revision tag.
struct (0x00) FfVaultStorage {
    /// Total asset amount currently represented by active staking positions.
    assetStaked: coins
    /// Q128 cumulative stable-token rewards distributed per staked asset unit.
    distributedStables: uint256
    /// Maximum accepted price change in protocol basis points.
    maxPriceChange: uint32
    /// Index assigned to the next NFT position account.
    nextItemIndex: uint64
    /// Administrator authorized to execute maintenance operations.
    admin: address
    /// Asset-token balance accounted as held by the Vault.
    assetAmountOnVault: coins
    /// Stable-token balance accounted as held by the Vault.
    stableAmountOnVault: coins
    /// Referenced immutable addresses, child code, and decimal precision.
    staticData: Cell<FfVaultStaticData>
}

/// TEP-74 notification received from an asset or stable Jetton wallet.
struct (0x7362d09c) FfVaultJettonTransferNotification {
    /// Query id copied from the originating Jetton transfer.
    queryId: uint64
    /// Jetton amount received in basic token units.
    amount: coins
    /// Logical sender reported by the Jetton wallet.
    sender: address
    /// `Either Cell ^Cell` tail containing an asset- or stable-deposit payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Asset-deposit payload nested in a TEP-74 transfer notification.
struct (0x534917c3) FfVaultAssetDeposit {
    /// Optional referenced Pyth update data; none accepts the deposit without an oracle request.
    priceUpdateData: cell?
}

/// Stable-token deposit payload nested in a TEP-74 transfer notification.
struct (0x3d669db7) FfVaultStableDeposit {
    /// Whether the deposit immediately increases the cumulative reward accumulator.
    distributeBetweenStakers: bool
}

/// Administrator request to execute an unstake after obtaining a fresh oracle price.
struct (0x4e835078) FfVaultUnstakeExecute {
    /// Correlation id propagated through the oracle and position callbacks.
    queryId: uint64
    /// Referenced Pyth price update data.
    priceUpdateData: cell
    /// Asset amount requested from the position.
    amountToUnstake: coins
    /// NFT position index to execute.
    itemIndex: uint64
}

/// Successful Pyth response delivered to the Vault.
struct (0x00000005) FfVaultPythResponseSuccess {
    /// Number of price feeds in the referenced response chain.
    feedsCount: uint8
    /// Referenced linked list of price-feed cells.
    priceFeeds: cell
    /// Original account that requested the update.
    initialSender: address
    /// Referenced Vault operation resumed after price verification.
    operation: cell
}

/// Failed Pyth response delivered to the Vault.
struct (0x00010002) FfVaultPythErrorResponse {
    /// Oracle error code.
    errorCode: uint32
    /// Oracle operation code that failed.
    operationCode: uint32
    /// Referenced Vault operation associated with the failed request.
    operation: cell
}

/// Administrator request to transfer Jettons from one of the Vault-owned wallets.
struct (0xe44c1944) FfVaultWithdrawJetton {
    /// Correlation id copied to the emitted Jetton transfer.
    queryId: uint64
    /// Vault-owned Jetton wallet that executes the transfer.
    jettonWallet: address
    /// Recipient of the withdrawn Jettons.
    toAddress: address
    /// Jetton amount to withdraw in basic token units.
    amount: coins
}

/// Administrator request to replace the Vault code cell.
struct (0x3124ce76) FfVaultUpgrade {
    /// Correlation id copied to the excesses response.
    queryId: uint64
    /// Replacement Vault code cell.
    newCode: cell
}

/// Price and reward accumulator retained by an NFT position.
struct FfVaultPositionData {
    /// Q128 asset price recorded for the position.
    assetPriceStaked: uint256
    /// Q128 cumulative stable rewards previously collected by the position.
    previousStablePerAssetCollected: uint256
}

/// Callback from a derived position after calculating the executable unstake amount.
struct (0x61755200) FfVaultUnstakeExecuteInternalCallback {
    /// Correlation id propagated through the unstake flow.
    queryId: uint64
    /// NFT position index being unstaked.
    itemIndex: uint64
    /// Asset amount requested from the position.
    amountToUnstake: coins
    /// Q128 current asset price returned by the oracle flow.
    assetPriceActual: uint256
    /// Owner that receives unstaked assets and stable rewards.
    owner: address
    /// Referenced position price and reward state.
    positionData: Cell<FfVaultPositionData>
}

/// Administrator request to replace the Vault administrator.
struct (0x00000003) FfVaultChangeAdmin {
    /// Correlation id copied to the excesses response.
    queryId: uint64
    /// Replacement administrator address.
    newAdmin: address
}

/// Pyth request emitted to parse a bounded asset-price update.
struct (0x00000005) FfVaultPythParsePriceFeedUpdates {
    /// Referenced encoded Pyth update data.
    updateData: cell
    /// Referenced list of requested price-feed identifiers.
    priceIds: cell
    /// Earliest accepted publication timestamp.
    minPublishTime: uint64
    /// Latest accepted publication timestamp.
    maxPublishTime: uint64
    /// Account that receives the oracle response.
    targetAddress: any_address
    /// Referenced Vault operation resumed by the response.
    operation: cell
}

/// Vault operation resumed after the oracle validates an asset deposit.
struct (0x7a294fdc) FfVaultStakeOperation {
    /// Correlation id copied from the Jetton notification.
    queryId: uint64
    /// Account that deposited the staked asset.
    depositAddress: address
    /// Staked asset amount in basic token units.
    assetAmount: coins
}

/// Vault operation resumed after the oracle validates an unstake request.
struct (0x97004d72) FfVaultUnstakeOperation {
    /// Correlation id propagated to the NFT position.
    queryId: uint64
    /// Asset amount requested from the position.
    amountToUnstake: coins
    /// NFT position index to execute.
    itemIndex: uint64
}

/// Initialization body sent while deploying an NFT position account.
struct (0x00000001) FfVaultPositionInit {
    /// Correlation id copied from the asset deposit.
    queryId: uint64
    /// Owner assigned to the new NFT position.
    owner: address
    /// Asset amount locked by the new position.
    assetAmount: coins
    /// Q128 reward accumulator at position creation.
    distributedStables: uint256
    /// Q128 asset price at position creation.
    assetPriceStaked: uint256
}

/// Unstake instruction sent to a deterministic NFT position.
struct (0xd1029c99) FfVaultPositionUnstakeExecute {
    /// Correlation id propagated through the unstake flow.
    queryId: uint64
    /// Asset amount requested from the position.
    amountToUnstake: coins
    /// Q128 current asset price supplied by the oracle.
    assetPriceActual: uint256
}

/// Cancellation sent to a position when Vault liquidity or price limits prevent an unstake.
struct (0x0b30393c) FfVaultPositionUnstakeCancel {
    /// Correlation id propagated through the unstake flow.
    queryId: uint64
    /// Vault account that receives any excess GRAM from the position.
    excessReceiver: address
    /// Asset amount restored to the position after cancellation.
    amountToRestore: coins
}

/// TEP-74 internal transfer emitted for refunds and administrator withdrawals.
struct (0x0f8a7ea5) FfVaultJettonInternalTransfer {
    /// Correlation id propagated through the Jetton transfer flow.
    queryId: uint64
    /// Jetton amount transferred in basic token units.
    amount: coins
    /// Previous owner recorded by the receiving Jetton wallet.
    fromAddress: address
    /// Address that receives a transfer notification when forwarding is enabled.
    responseAddress: address
    /// Optional custom payload retained by the Jetton wallet.
    customPayload: cell?
    /// GRAM value forwarded with a transfer notification.
    forwardTonAmount: coins
    /// `Either Cell ^Cell` forward payload for the recipient.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard response that returns unused GRAM to a correlated recipient.
struct (0xd53276db) FfVaultExcesses {
    /// Query id copied from the completed operation.
    queryId: uint64
}

/// Messages accepted by the initialized Vault.
type FfVaultIncomingMessage =
    | FfVaultJettonTransferNotification
    | FfVaultUnstakeExecute
    | FfVaultPythResponseSuccess
    | FfVaultPythErrorResponse
    | FfVaultWithdrawJetton
    | FfVaultUpgrade
    | FfVaultUnstakeExecuteInternalCallback
    | FfVaultChangeAdmin

/// Messages emitted by the Vault to the oracle, positions, Jetton wallets, and callers.
type FfVaultOutgoingMessage =
    | FfVaultPythParsePriceFeedUpdates
    | FfVaultPositionInit
    | FfVaultPositionUnstakeExecute
    | FfVaultPositionUnstakeCancel
    | FfVaultJettonInternalTransfer
    | FfVaultExcesses

/// Standard NFT collection data returned by `get_collection_data`.
struct FfVaultCollectionData {
    /// Index assigned to the next NFT position.
    nextItemIndex: int
    /// Collection metadata content cell.
    content: cell
    /// Collection owner address.
    owner: address
}

/// Aggregate staking values returned by `get_staking_data`.
struct FfVaultStakingData {
    /// Total asset amount represented by active positions.
    tokensStaked: coins
    /// Q128 cumulative stable rewards distributed per staked asset unit.
    distributedStables: uint256
    /// Maximum accepted asset-price change in protocol basis points.
    maxPriceChange: uint32
}

/// Vault-owned token balances returned by `get_balance`.
struct FfVaultBalance {
    /// Accounted balance of the staked asset Jetton.
    assetAmount: coins
    /// Accounted balance of the distributed stable-token Jetton.
    stableAmount: coins
}

/// Return standard NFT collection data for the Vault's position collection.
get fun get_collection_data(): FfVaultCollectionData {
    throw 0;
}

/// Derive the deterministic NFT position address for an item index.
get fun get_nft_address_by_index(itemIndex: int): address {
    throw 0;
}

/// Build full NFT item metadata from an item index and individual-content cell.
get fun get_nft_content(itemIndex: int, individualContent: cell): cell {
    throw 0;
}

/// Return aggregate staking and reward-distribution values.
get fun get_staking_data(): FfVaultStakingData {
    throw 0;
}

/// Return the Vault's accounted asset and stable-token balances.
get fun get_balance(): FfVaultBalance {
    throw 0;
}

/// Exit codes exposed by the deployed Vault runtime.
enum FfVaultErrors {
    /// Stable rewards cannot be distributed while no asset is staked.
    InvalidDistributionState = 47
    /// Attached GRAM cannot cover the oracle and operation flow.
    InsufficientAttachedValue = 48
    /// A Jetton transfer notification reports a zero deposit amount.
    ZeroDeposit = 49
    /// Persistent storage or a nested operation payload is malformed.
    InvalidStructure = 63
    /// The sender cannot perform the administrator-address change.
    UnauthorizedAdminChange = 73
    /// The sender is not the configured Vault administrator.
    UnauthorizedAdmin = 401
    /// A position index or derived position sender is invalid.
    InvalidPosition = 402
    /// An oracle response names a target other than this Vault.
    InvalidOracleTarget = 405
    /// The sender is not the configured Pyth oracle.
    UnauthorizedOracle = 406
    /// A non-empty body uses an unsupported operation.
    UnsupportedMessage = 65535
}
