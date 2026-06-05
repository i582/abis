/// Low-level ABI for Coffee Swap staking NFT item contracts.
contract CoffeeStakingItem {
    author: "swap.coffee"
    version: "0.1"
    description: "Coffee Swap staking item ABI for NFT position state, unlock/extend callbacks, and standard NFT item getter."
    storage: CoffeeStakingItemStorage
    incomingMessages: CoffeeStakingItemIncomingMessage
    outgoingMessages: CoffeeStakingItemOutgoingMessage
    forceAbiExport: CoffeeStakingAssetData | CoffeeStakingPositionData
}

/// Root persistent storage for the staking item.
struct CoffeeStakingItemStorage {
    /// Initialization flag.
    initialized: bool
    /// NFT item index.
    nftId: uint64
    /// Staking master collection address.
    master: address
    /// Current NFT owner.
    owner: address
    /// Referenced locked asset data.
    asset: Cell<CoffeeStakingAssetData>
    /// Referenced position data.
    info: Cell<CoffeeStakingPositionData>
    /// Period dictionary keyed by period id.
    periods: cell?
}

/// Jetton staking asset tuple stored by the item.
struct CoffeeStakingAssetData {
    /// Jetton wallet address.
    wallet: address
    /// Jetton amount locked for the position.
    amount: coins
}

/// Position data stored by the item.
struct CoffeeStakingPositionData {
    /// Base user points for the position.
    userPoints: coins
    /// Additional points earned by extensions.
    additionalPoints: coins
    /// Position start timestamp.
    startTimestamp: uint64
    /// Position end timestamp.
    endTimestamp: uint64
    /// Staking period id.
    periodId: uint32
}

/// Master-authorized item initialization.
struct (0xbe5a7595) CoffeeStakingItemInit {
    /// Caller-selected query id.
    queryId: uint64
    /// Initial NFT owner.
    owner: address
    /// Referenced locked asset data.
    jettonData: Cell<CoffeeStakingAssetData>
    /// Referenced position data.
    positionData: Cell<CoffeeStakingPositionData>
    /// Period dictionary.
    periods: cell?
}

/// Owner request that unlocks an expired staking position.
struct (0xcb03bfaf) CoffeeStakingItemUnlock {
    /// Caller-selected query id.
    queryId: uint64
}

/// Owner request that extends the staking position to a new period.
struct (0xeb666ce0) CoffeeStakingItemExtend {
    /// Caller-selected query id.
    queryId: uint64
    /// Target staking period id.
    periodId: uint32
}

/// Master callback emitted when an item unlocks.
struct (0xcb03bfaf) CoffeeStakingItemUnlockNotification {
    /// Query id copied from the unlock request.
    queryId: uint64
    /// NFT item index.
    nftId: uint64
    /// Position owner address.
    owner: address
    /// Unlocked amount.
    amount: coins
    /// Referenced asset payload.
    assetData: Cell<CoffeeStakingAssetData>
}

/// Master callback emitted when an item extends.
struct (0xeb666ce0) CoffeeStakingItemExtendNotification {
    /// Query id copied from the extend request.
    queryId: uint64
    /// NFT item index.
    nftId: uint64
    /// Position owner address.
    owner: address
    /// Additional points or token amount reported by the item.
    amount: coins
    /// New position end timestamp.
    endTimestamp: uint64
    /// New staking period id.
    periodId: uint32
}

/// Structured return value for `get_stored_data`.
struct CoffeeStakingItemStoredDataReply {
    /// Initialization flag.
    initialized: bool
    /// NFT item index.
    nftId: uint64
    /// Staking master collection address.
    master: address
    /// Current NFT owner.
    owner: address
    /// Locked asset data cell.
    asset: cell
    /// Position data cell.
    info: cell
    /// Period dictionary.
    periods: cell
}

/// Structured return value for standard NFT item data.
struct CoffeeStakingItemNftDataReply {
    /// Initialization flag.
    isInitialized: bool
    /// NFT item index.
    itemIndex: int
    /// Staking master collection address.
    collectionAddress: address
    /// Current NFT owner.
    ownerAddress: address
    /// NFT item content cell assembled from asset and position data.
    content: cell
}

/// Internal messages accepted by the staking item.
type CoffeeStakingItemIncomingMessage =
    | CoffeeStakingItemInit
    | CoffeeStakingItemUnlock
    | CoffeeStakingItemExtend

/// Internal messages emitted by the staking item.
type CoffeeStakingItemOutgoingMessage =
    | CoffeeStakingItemUnlockNotification
    | CoffeeStakingItemExtendNotification

enum CoffeeStakingItemErrors {
    /// Contract is not initialized.
    NotInitialized = 99
    /// Contract is already initialized.
    AlreadyInitialized = 100
    /// Unlock requested before position end timestamp.
    TooEarlyToUnlock = 500
    /// Extension requested after the current period allows extension.
    TooLateToExtend = 501
    /// Computed points are zero.
    ZeroPoints = 502
    /// Requested period is not present or invalid.
    WrongPeriod = 503
    /// Sender is not authorized for the requested operation.
    UnauthorizedAccess = 403
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return item storage fields.
get fun get_stored_data(): CoffeeStakingItemStoredDataReply {
    return {
        initialized: false,
        nftId: 0,
        master: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        asset: createEmptyCell(),
        info: createEmptyCell(),
        periods: createEmptyCell(),
    };
}

/// Return standard NFT item data for the staking position.
get fun get_nft_data(): CoffeeStakingItemNftDataReply {
    return {
        isInitialized: false,
        itemIndex: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        content: createEmptyCell(),
    };
}
