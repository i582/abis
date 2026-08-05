/// Bidask Farming NFT item that records one owner's FF Vault staking position.
contract FfVaultPosition {
    author: "Bidask"
    description: "Bidask Farming FF Vault Position is an NFT item that tracks locked assets, pending unstake requests, reward state, and stake price."
    storage: FfVaultPositionStorage
    storageAtDeployment: FfVaultPositionDeploymentStorage
    incomingMessages: FfVaultPositionIncomingMessage
    outgoingMessages: FfVaultPositionOutgoingMessage
    forceAbiExport: FfVaultPositionInit
    thrownErrors: FfVaultPositionErrors
}

/// Minimal NFT item data installed before the Vault collection initializes a position.
struct FfVaultPositionDeploymentStorage {
    /// NFT item index assigned by the Vault collection.
    itemIndex: uint64
    /// Vault collection authorized to initialize this position.
    collectionAddress: address
}

/// Immutable item identity and the reward accumulator retained in a referenced cell.
struct FfVaultPositionStaticData {
    /// NFT item index assigned by the Vault collection.
    itemIndex: uint64
    /// Vault collection that deployed and controls this position.
    collectionAddress: address
    /// Q128 cumulative stable rewards already accounted for by this position.
    previousStablePerAssetCollected: uint256
}

/// Complete initialized state of one FF Vault NFT position.
struct FfVaultPositionStorage {
    /// Referenced immutable item identity and previous reward accumulator.
    staticData: Cell<FfVaultPositionStaticData>
    /// Current NFT owner authorized to request an unstake.
    ownerAddress: address
    /// Asset-token amount still locked in this position.
    lockedAssetAmount: coins
    /// Q128 asset price recorded when this position was created.
    assetPriceStaked: uint256
    /// Asset-token amount requested for unstaking but not yet executed.
    amountWantedToUnstake: coins
}

/// One-time initialization sent by the FF Vault collection while deploying a position.
struct (0x00000001) FfVaultPositionInit {
    /// Correlation id returned in the initialization excesses response.
    queryId: uint64
    /// Initial owner of the NFT position.
    ownerAddress: address
    /// Asset-token amount locked by the new position.
    lockedAssetAmount: coins
    /// Q128 cumulative stable rewards at position creation.
    previousStablePerAssetCollected: uint256
    /// Q128 asset price at position creation.
    assetPriceStaked: uint256
}

/// Standard TEP-62 request to transfer ownership of this NFT position.
struct (0x5fcc3d14) FfVaultPositionTransfer {
    /// Caller-selected query id propagated to transfer responses.
    queryId: uint64
    /// Account that becomes the new position owner.
    newOwnerAddress: address
    /// Optional destination that receives remaining GRAM after the transfer.
    responseDestination: address?
    /// Optional custom payload accepted for TEP-62 compatibility.
    customPayload: cell?
    /// GRAM amount forwarded to the new owner with ownership assignment.
    forwardTonAmount: coins
    /// Raw `Either Cell ^Cell` payload forwarded to the new owner.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard TEP-62 request for the position's immutable item identity.
struct (0x2fcb26a2) FfVaultPositionGetStaticData {
    /// Caller-selected query id copied into the static-data response.
    queryId: uint64
}

/// Owner request to add an asset amount to the position's pending unstake counter.
struct (0x8a77cf39) FfVaultPositionUnstakeRequest {
    /// Correlation id returned in the excesses response.
    queryId: uint64
    /// Additional asset-token amount requested for unstaking.
    amountWantedToUnstake: coins
}

/// Vault instruction that executes part or all of the pending unstake amount.
struct (0xd1029c99) FfVaultPositionUnstakeExecute {
    /// Correlation id propagated to the Vault callback.
    queryId: uint64
    /// Asset-token amount removed from locked and pending balances.
    amountToUnstake: coins
    /// Q128 current asset price supplied by the Vault oracle flow.
    assetPriceActual: uint256
}

/// Vault instruction that cancels an unstake and restores the supplied asset amount.
struct (0x0b30393c) FfVaultPositionUnstakeCancel {
    /// Correlation id returned in the excesses response.
    queryId: uint64
    /// Account that receives unused GRAM after cancellation.
    excessReceiver: address
    /// Asset-token amount restored to locked and pending balances.
    amountToRestore: coins
}

/// Standard TEP-62 notification sent to the new owner after a position transfer.
struct (0x05138d91) FfVaultPositionOwnershipAssigned {
    /// Query id copied from the transfer request.
    queryId: uint64
    /// Previous position owner.
    previousOwnerAddress: address
    /// Raw `Either Cell ^Cell` payload copied from the transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard TEP-62 response containing immutable position identity.
struct (0x8b771735) FfVaultPositionReportStaticData {
    /// Query id copied from the static-data request.
    queryId: uint64
    /// NFT item index encoded as uint256 by the deployed contract.
    itemIndex: uint256
    /// FF Vault collection address stored by the position.
    collectionAddress: address
}

/// Position state returned to the Vault after an unstake is executed.
struct FfVaultPositionCallbackData {
    /// Q128 asset price recorded when the position was created.
    assetPriceStaked: uint256
    /// Q128 cumulative stable rewards previously accounted for by the position.
    previousStablePerAssetCollected: uint256
}

/// Callback emitted to the Vault after reducing a position's balances.
struct (0x61755200) FfVaultPositionUnstakeCallback {
    /// Correlation id copied from the execute instruction.
    queryId: uint64
    /// NFT item index being unstaked.
    itemIndex: uint64
    /// Asset-token amount removed from the position.
    amountToUnstake: coins
    /// Q128 current asset price supplied by the Vault.
    assetPriceActual: uint256
    /// Owner that receives unstaked assets and stable rewards.
    ownerAddress: address
    /// Referenced stake price and previous reward accumulator.
    positionData: Cell<FfVaultPositionCallbackData>
}

/// Standard response returning unused GRAM after a completed operation.
struct (0xd53276db) FfVaultPositionExcesses {
    /// Query id copied from the completed operation.
    queryId: uint64
}

/// Messages accepted by an FF Vault position, including its one-time initialization.
type FfVaultPositionIncomingMessage =
    | FfVaultPositionInit
    | FfVaultPositionTransfer
    | FfVaultPositionGetStaticData
    | FfVaultPositionUnstakeRequest
    | FfVaultPositionUnstakeExecute
    | FfVaultPositionUnstakeCancel

/// Messages emitted by an FF Vault position to its owner, Vault, and TEP-62 callers.
type FfVaultPositionOutgoingMessage =
    | FfVaultPositionOwnershipAssigned
    | FfVaultPositionReportStaticData
    | FfVaultPositionUnstakeCallback
    | FfVaultPositionExcesses

/// Standard NFT item data returned by `get_nft_data`.
struct FfVaultPositionNftData {
    /// True after the Vault collection has initialized the position.
    isInitialized: bool
    /// NFT item index assigned by the Vault collection.
    itemIndex: int
    /// Vault collection that deployed this position.
    collectionAddress: address
    /// Current owner, or null before initialization.
    ownerAddress: address?
    /// Position-specific NFT content, or null before initialization.
    content: cell?
}

/// Position accounting values returned by `get_stake_position_info`.
struct FfVaultPositionInfo {
    /// Asset-token amount still locked in the position.
    lockedAssetAmount: coins
    /// Asset-token amount requested for unstaking but not yet executed.
    amountWantedToUnstake: coins
    /// Q128 cumulative stable rewards already accounted for by the position.
    previousStablePerAssetCollected: uint256
    /// Q128 asset price recorded when the position was created.
    assetPriceStaked: uint256
}

/// Return standard NFT item identity, ownership, and content.
get fun get_nft_data(): FfVaultPositionNftData {
    throw 0;
}

/// Return the position's locked amount, pending unstake, reward state, and stake price.
get fun get_stake_position_info(): FfVaultPositionInfo {
    throw 0;
}

/// Exit codes exposed by the deployed FF Vault position runtime.
enum FfVaultPositionErrors {
    /// A requested, executed, or cancelled amount is inconsistent with position balances.
    InvalidUnstakeAmount = 47
    /// Initialization storage or body does not match the expected layout.
    InvalidInitialization = 63
    /// NFT transfer addresses use a workchain unsupported by this implementation.
    UnsupportedWorkchain = 333
    /// The sender is not the current position owner.
    UnauthorizedOwner = 401
    /// Attached GRAM cannot cover NFT transfer forwarding and fees.
    InsufficientTransferValue = 402
    /// Initialization or an unstake update was not sent by the Vault collection.
    UnauthorizedCollection = 405
    /// The NFT transfer omits its required forward-payload selector.
    MissingForwardPayload = 708
    /// A non-empty body uses an unsupported operation.
    UnsupportedMessage = 65535
}
