/// Low-level ABI for Coffee Swap staking master NFT collection contracts.
contract CoffeeStakingMaster {
    author: "swap.coffee"
    version: "0.1"
    description: "Coffee Swap staking master ABI for reward accounting, NFT collection getters, vault/item callbacks, admin updates, and storage."
    storage: CoffeeStakingMasterStorage
    incomingMessages: CoffeeStakingMasterIncomingMessage
    outgoingMessages: CoffeeStakingMasterOutgoingMessage
    forceAbiExport: CoffeeStakingForwardData | CoffeeStakingAssetData | CoffeeStakingPositionData | CoffeeStakingMasterState | CoffeeStakingMasterStateRefs
}

/// Root persistent storage for the staking master.
struct CoffeeStakingMasterStorage {
    /// Initialization flag. False before the vault-authorized `staking_master_init` message.
    initialized: bool
    /// NFT collection owner and admin for reward updates.
    owner: address
    /// Distributor authorized to claim rewards.
    distributor: address
    /// Staking vault address authorized to initialize the master and submit deposits.
    vault: address
    /// Referenced state and dictionary bundle.
    stateRefs: Cell<CoffeeStakingMasterStateRefs>
    /// Code cell used to derive one staking NFT item variant.
    itemCode: cell
    /// Code cell used to derive the alternate staking NFT item variant.
    alternateItemCode: cell
}

/// Referenced master state bundle stored after owner/distributor/vault.
struct CoffeeStakingMasterStateRefs {
    /// Aggregate points and next NFT item id.
    state: Cell<CoffeeStakingMasterState>
    /// Rewards dictionary keyed by staking Jetton wallet hash.
    rewards: cell?
    /// Staking asset dictionary keyed by Jetton wallet hash.
    jettons: cell?
    /// Staking periods dictionary keyed by period id.
    periods: cell?
}

/// Aggregate staking state stored in `stateRefs.state`.
struct CoffeeStakingMasterState {
    /// Total staking points accumulated by active positions.
    totalPoints: coins
    /// Next NFT item index used by `get_collection_data` and item deployment.
    nextItemIndex: uint64
}

/// Jetton staking asset tuple used in item init payloads and item callbacks.
struct CoffeeStakingAssetData {
    /// Jetton wallet address.
    wallet: address
    /// Jetton amount locked for the position.
    amount: coins
}

/// Position data stored by staking item NFTs.
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

/// Optional Jetton transfer forward payload used by reward claims.
struct CoffeeStakingForwardData {
    /// TON amount forwarded with the Jetton transfer notification.
    gas: coins
    /// Payload cell forwarded with the Jetton transfer notification.
    payload: cell
}

/// Vault-authorized master initialization.
struct (0xbe5a7595) CoffeeStakingMasterInit {
    /// Caller-selected query id.
    queryId: uint64
    /// Collection owner address.
    owner: address
    /// Reward distributor address.
    distributor: address
    /// Initial Jetton dictionary stored as a HashmapE root.
    jettons: cell?
    /// Initial period dictionary stored as a HashmapE root.
    periods: cell?
}

/// Owner request that adds or extends rewards for a Jetton wallet.
struct (0x0a9577f0) CoffeeStakingUpdateRewards {
    /// Caller-selected query id.
    queryId: uint64
    /// Reward Jetton wallet key.
    jettonWallet: address
    /// Reward Jetton amount.
    jettonAmount: coins
    /// Reward distribution duration in seconds.
    duration: uint64
}

/// Vault callback submitted after a user lock transfer is accepted.
struct (0xf9471134) CoffeeStakingDeposit {
    /// Query id copied from the vault transfer notification.
    queryId: uint64
    /// Jetton wallet address that notified the vault.
    sender: address
    /// Locked Jetton amount.
    jettonAmount: coins
    /// User address reported by the Jetton transfer notification.
    fromUser: address
    /// Selected staking period id.
    periodId: uint32
}

/// Distributor request that transfers accumulated rewards to a receiver.
struct (0xb30c7310) CoffeeStakingClaimRewards {
    /// Caller-selected query id.
    queryId: uint64
    /// Reward Jetton wallet key.
    jettonWallet: address
    /// Requested reward amount.
    jettonAmount: coins
    /// Reward receiver.
    receiver: address
    /// Optional forwarded Jetton transfer payload parameters.
    payload: Cell<CoffeeStakingForwardData>?
}

/// Owner request that changes the reward distributor address.
struct (0x27ee4c7d) CoffeeStakingSetDistributor {
    /// Caller-selected query id.
    queryId: uint64
    /// New reward distributor address.
    distributor: address
}

/// Vault-authorized request that changes the master owner.
struct (0xf1eef33c) CoffeeStakingSetOwner {
    /// Caller-selected query id.
    queryId: uint64
    /// New owner address.
    owner: address
}

/// Vault-authorized request that replaces the Jetton dictionary.
struct (0xeec15c2a) CoffeeStakingSetJettons {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement Jetton dictionary.
    jettons: cell?
}

/// Vault-authorized request that replaces the periods dictionary.
struct (0xfab30dc2) CoffeeStakingSetPeriods {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement periods dictionary.
    periods: cell?
}

/// Owner request that replaces contract code and optionally full storage data.
struct (0xce4e2066) CoffeeStakingUpdateContract {
    /// Caller-selected query id.
    queryId: uint64
    /// New code cell passed to `set_code`.
    newCode: cell
    /// Optional replacement data cell passed to `set_data` before `set_code`.
    newData: cell?
}

/// NFT item callback reporting a position extension.
struct (0xeb666ce0) CoffeeStakingItemExtended {
    /// Query id copied from the NFT item request.
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

/// NFT item callback reporting an unlock/withdrawal.
struct (0xcb03bfaf) CoffeeStakingItemUnlocked {
    /// Query id copied from the NFT item request.
    queryId: uint64
    /// NFT item index.
    nftId: uint64
    /// Position owner address.
    owner: address
    /// Unlocked amount.
    amount: coins
    /// Referenced item asset payload.
    assetData: cell
}

/// External event emitted after master initialization.
struct (0xbe5a7595) CoffeeStakingMasterInitialized {
    /// Query id copied from the initialization request.
    queryId: uint64
}

/// External event emitted after reward data is updated.
struct (0x0a9577f0) CoffeeStakingRewardsUpdated {
    /// Query id copied from the update request.
    queryId: uint64
    /// Reward Jetton wallet key.
    jettonWallet: address
    /// Reward duration.
    duration: uint64
    /// Reward finish timestamp.
    finishAt: uint64
    /// Reward rate.
    rewardsRate: coins
}

/// External event emitted after rewards are claimed.
struct (0xb30c7310) CoffeeStakingRewardsClaimed {
    /// Query id copied from the claim request.
    queryId: uint64
    /// Reward Jetton wallet key.
    jettonWallet: address
    /// Claimed reward amount.
    amount: coins
    /// Reward receiver.
    receiver: address
}

/// External event emitted after a distributor change.
struct (0x27ee4c7d) CoffeeStakingDistributorUpdated {
    /// Query id copied from the admin request.
    queryId: uint64
}

/// External event emitted after an owner change.
struct (0xf1eef33c) CoffeeStakingOwnerUpdated {
    /// Query id copied from the admin request.
    queryId: uint64
}

/// External event emitted after Jetton dictionary replacement.
struct (0xeec15c2a) CoffeeStakingJettonsUpdated {
    /// Query id copied from the admin request.
    queryId: uint64
    /// Replacement Jetton dictionary.
    jettons: cell?
}

/// External event emitted after periods dictionary replacement.
struct (0xfab30dc2) CoffeeStakingPeriodsUpdated {
    /// Query id copied from the admin request.
    queryId: uint64
    /// Replacement periods dictionary.
    periods: cell?
}

/// Structured return value for `get_stored_data`.
struct CoffeeStakingMasterStoredDataReply {
    /// Initialization flag.
    initialized: bool
    /// Collection owner.
    owner: address
    /// Reward distributor.
    distributor: address
    /// Staking vault address.
    vault: address
    /// Aggregate state cell.
    state: cell
    /// Rewards dictionary.
    rewards: cell
    /// Jetton dictionary.
    jettons: cell
    /// Period dictionary.
    periods: cell
}

/// Structured return value for standard NFT collection data.
struct CoffeeStakingMasterCollectionDataReply {
    /// Next NFT item index.
    nextItemIndex: int
    /// Collection metadata cell.
    collectionMetadata: cell
    /// Collection owner address.
    ownerAddress: address
}

/// Internal messages accepted by the staking master.
type CoffeeStakingMasterIncomingMessage =
    | CoffeeStakingMasterInit
    | CoffeeStakingUpdateRewards
    | CoffeeStakingDeposit
    | CoffeeStakingClaimRewards
    | CoffeeStakingSetDistributor
    | CoffeeStakingSetOwner
    | CoffeeStakingSetJettons
    | CoffeeStakingSetPeriods
    | CoffeeStakingUpdateContract
    | CoffeeStakingItemExtended
    | CoffeeStakingItemUnlocked

/// External events emitted by the staking master.
type CoffeeStakingMasterOutgoingMessage =
    | CoffeeStakingMasterInitialized
    | CoffeeStakingRewardsUpdated
    | CoffeeStakingRewardsClaimed
    | CoffeeStakingDistributorUpdated
    | CoffeeStakingOwnerUpdated
    | CoffeeStakingJettonsUpdated
    | CoffeeStakingPeriodsUpdated
    | CoffeeStakingItemExtended
    | CoffeeStakingItemUnlocked

enum CoffeeStakingMasterErrors {
    /// Unknown reward or staking Jetton wallet.
    UnknownJettonWallet = 81
    /// Contract is not initialized.
    NotInitialized = 99
    /// Contract is already initialized.
    AlreadyInitialized = 100
    /// Reward duration mismatch while extending active rewards.
    MismatchingDuration = 110
    /// Computed reward rate is zero.
    ZeroRewardRate = 111
    /// Requested token is not distributed.
    TokenNotDistributed = 200
    /// Sender is not authorized for the requested operation.
    UnauthorizedAccess = 403
    /// Period dictionary validation failed.
    WrongPeriod = 503
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return owner, distributor, vault, aggregate state, and dictionaries.
get fun get_stored_data(): CoffeeStakingMasterStoredDataReply {
    throw 0;
}

/// Return standard NFT collection data for the staking position collection.
get fun get_collection_data(): CoffeeStakingMasterCollectionDataReply {
    throw 0;
}

/// Return deterministic NFT item address by item index.
get fun get_nft_address_by_index(itemIndex: int): address {
    throw 0;
}

/// Return full NFT item content from collection and item content cells.
get fun get_nft_content(itemIndex: int, individualContent: cell): cell {
    throw 0;
}
