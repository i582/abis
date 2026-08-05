/// STON.fi v3 farming position represented as a non-transferable NFT item.
contract StonfiFarmNft {
    author: "STON.fi"
    version: "v3"
    description: "STON.fi Farm NFT stores one staked position and its per-pool reward checkpoints."
    storage: StonfiFarmNftStorage
    incomingMessages: StonfiFarmNftIncomingMessage
    outgoingMessages: StonfiFarmNftOutgoingMessage
    thrownErrors: StonfiFarmNftErrors
}

/// Persistent state of an initialized STON.fi v3 Farm NFT.
struct StonfiFarmNftStorage {
    /// Lifecycle state: uninitialized 0, active 1, unstaked 2, claiming 3, or unstake-pending 4.
    status: uint8
    /// Current owner, or `addr_none` after the position is destroyed.
    ownerAddress: address?
    /// Unix timestamp at which unstaking was requested, or zero before unstaking.
    revokeTime: uint64
    /// Per-pool accrued reward checkpoints keyed by an unsigned 8-bit pool index.
    claimedPerUnit: map<uint8, uint150>
    /// Referenced immutable and stake-specific position data.
    stakeData: Cell<StonfiFarmNftStakeData>
}

/// Referenced stake data retained across reward claims and unstaking.
struct StonfiFarmNftStakeData {
    /// Number of staking Jettons held by this position, in basic token units.
    stakedTokens: coins
    /// NFT item index assigned by the Farm collection.
    itemIndex: uint64
    /// Farm collection/minter address that initializes and settles this position.
    collectionAddress: address
    /// Unix timestamp at which the position was initialized.
    stakeDate: uint64
}

/// Farm collection initialization body for a newly deployed position.
struct (0xbba6cbca) StonfiFarmNftInitialize {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
    /// Number of staking Jettons assigned to the position.
    stakedTokens: coins
    /// Initial owner of the farming position.
    ownerAddress: address
    /// Initial per-pool accrued reward checkpoints.
    claimedPerUnit: map<uint8, uint150>
}

/// Owner request to claim rewards from one pool or every configured pool.
struct (0x78d9f109) StonfiFarmNftClaimRewards {
    /// Query identifier propagated through the claim flow.
    queryId: uint64
    /// True to claim every pool; false to use `poolIndex`.
    claimAll: bool
    /// Selected unsigned 8-bit pool index when `claimAll` is false.
    poolIndex: uint8
}

/// Farm collection callback that completes a reward claim with updated checkpoints.
struct (0xc70d3ca5) StonfiFarmNftClaimCompleted {
    /// Query identifier propagated from the owner request.
    queryId: uint64
    /// Updated per-pool accrued reward checkpoints.
    claimedPerUnit: map<uint8, uint150>
}

/// Owner request to unstake the complete farming position.
struct (0xb92965a0) StonfiFarmNftUnstake {
    /// Query identifier propagated through the unstake flow.
    queryId: uint64
}

/// Farm collection callback that completes unstaking with final checkpoints.
struct (0x2d673d98) StonfiFarmNftUnstakeCompleted {
    /// Query identifier propagated from the owner request.
    queryId: uint64
    /// Final per-pool accrued reward checkpoints.
    claimedPerUnit: map<uint8, uint150>
}

/// Owner-only request to retain the required reserve and return excess GRAM.
struct (0x42a0fb43) StonfiFarmNftResetGas {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Owner-only request to destroy an already unstaked position.
struct (0x1f04537a) StonfiFarmNftDestroy {
    /// Query identifier copied into the excess-value response.
    queryId: uint64
}

/// Rejected TEP-62 transfer request retained for SBT compatibility.
struct (0x5fcc3d14) StonfiFarmNftTransfer {
    /// Query identifier parsed before transfer is rejected.
    queryId: uint64
    /// Proposed new owner from the inherited NFT transfer layout.
    newOwnerAddress: address
    /// Optional destination for the inherited excess response.
    responseDestination: address?
    /// Optional custom payload from the inherited NFT transfer layout.
    customPayload: cell?
    /// Nanograms requested for the ownership-assigned notification.
    forwardTonAmount: coins
    /// Inline or referenced forward payload from the inherited NFT transfer layout.
    forwardPayload: RemainingBitsAndRefs
}

/// Open request for the NFT item index and collection address.
struct (0x2fcb26a2) StonfiFarmNftGetStaticData {
    /// Query identifier copied into the static-data response.
    queryId: uint64
}

/// Open request for the complete raw persistent data cell.
struct (0x5b88e5cc) StonfiFarmNftGetStorageData {
    /// Query identifier copied into the storage-data response.
    queryId: uint64
}

/// Owner-only request for a cryptographic ownership proof response.
struct (0x04ded148) StonfiFarmNftProveOwnership {
    /// Query identifier copied into the ownership proof.
    queryId: uint64
    /// Destination that receives the proof response.
    destination: address
    /// Referenced caller payload copied into the proof response.
    forwardPayload: cell
    /// True when the proof response should include the item content.
    withContent: bool
}

/// Open request for current owner information.
struct (0xd0c3bfea) StonfiFarmNftRequestOwner {
    /// Query identifier copied into the owner-information response.
    queryId: uint64
    /// Destination that receives the owner-information response.
    destination: address
    /// Referenced caller payload copied into the response.
    forwardPayload: cell
    /// True when the response should include the item content.
    withContent: bool
}

/// Internal message bodies accepted or explicitly rejected by the exact Farm NFT code.
type StonfiFarmNftIncomingMessage =
    | StonfiFarmNftInitialize
    | StonfiFarmNftClaimRewards
    | StonfiFarmNftClaimCompleted
    | StonfiFarmNftUnstake
    | StonfiFarmNftUnstakeCompleted
    | StonfiFarmNftResetGas
    | StonfiFarmNftDestroy
    | StonfiFarmNftTransfer
    | StonfiFarmNftGetStaticData
    | StonfiFarmNftGetStorageData
    | StonfiFarmNftProveOwnership
    | StonfiFarmNftRequestOwner

/// Claim request sent to the Farm collection/minter.
struct (0x39656584) StonfiFarmNftClaimRequest {
    /// Query identifier copied from the owner claim request.
    queryId: uint64
    /// NFT item index identifying this farming position.
    itemIndex: uint64
    /// Number of staking Jettons held by this position.
    stakedTokens: coins
    /// Current position owner.
    ownerAddress: address
    /// True to claim every pool; false to use `poolIndex`.
    claimAll: bool
    /// Selected unsigned 8-bit pool index when `claimAll` is false.
    poolIndex: uint8
    /// Optional direct dictionary-root reference containing previous reward checkpoints.
    claimedPerUnitRoot: cell?
}

/// Unstake request sent to the Farm collection/minter.
struct (0xa1312496) StonfiFarmNftUnstakeRequest {
    /// Query identifier copied from the owner unstake request.
    queryId: uint64
    /// NFT item index identifying this farming position.
    itemIndex: uint64
    /// Unix timestamp at which the position was initialized.
    stakeDate: uint64
    /// Number of staking Jettons held by this position.
    stakedTokens: coins
    /// Current position owner.
    ownerAddress: address
    /// Optional direct dictionary-root reference containing previous reward checkpoints.
    claimedPerUnitRoot: cell?
}

/// TEP-85 ownership proof sent to the requested destination.
struct (0x0524c7ae) StonfiFarmNftOwnershipProof {
    /// Query identifier copied from `prove_ownership`.
    queryId: uint64
    /// NFT item index encoded as an unsigned 256-bit integer.
    itemIndex: uint256
    /// Current owner that authorized the proof.
    ownerAddress: address
    /// Referenced caller payload copied unchanged.
    data: cell
    /// Unix timestamp at which unstaking was requested.
    revokeTime: uint64
    /// Optional item content included on request.
    content: cell?
}

/// Bounce-routed ownership proof failure returned to the owner.
struct (0xc18e86d2) StonfiFarmNftOwnershipProofBounced {
    /// Query identifier copied from the bounced proof.
    queryId: uint64
}

/// TEP-85 owner information sent to the requested destination.
struct (0x0dd607e3) StonfiFarmNftOwnerInfo {
    /// Query identifier copied from `request_owner`.
    queryId: uint64
    /// NFT item index encoded as an unsigned 256-bit integer.
    itemIndex: uint256
    /// Address that initiated the owner lookup.
    initiatorAddress: address
    /// Current owner, or `addr_none` after destruction.
    ownerAddress: address?
    /// Referenced caller payload copied unchanged.
    data: cell
    /// Unix timestamp at which unstaking was requested.
    revokeTime: uint64
    /// Optional item content included on request.
    content: cell?
}

/// TEP-62 static item-data response.
struct (0x8b771735) StonfiFarmNftReportStaticData {
    /// Query identifier copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as an unsigned 256-bit integer.
    itemIndex: uint256
    /// Farm collection/minter address.
    collectionAddress: address
}

/// Raw persistent-storage response used by STON.fi indexing infrastructure.
struct (0xaab4a8ef) StonfiFarmNftReportStorageData {
    /// Query identifier copied from `get_storage_data`.
    queryId: uint64
    /// Referenced complete persistent Farm NFT data cell.
    storage: Cell<StonfiFarmNftStorage>
}

/// Standard excess-value response.
struct (0xd53276db) StonfiFarmNftExcesses {
    /// Query identifier copied from the triggering request.
    queryId: uint64
}

/// Internal message bodies emitted by the exact Farm NFT code.
type StonfiFarmNftOutgoingMessage =
    | StonfiFarmNftClaimRequest
    | StonfiFarmNftUnstakeRequest
    | StonfiFarmNftOwnershipProof
    | StonfiFarmNftOwnershipProofBounced
    | StonfiFarmNftOwnerInfo
    | StonfiFarmNftReportStaticData
    | StonfiFarmNftReportStorageData
    | StonfiFarmNftExcesses

/// Current farming-position data returned by `get_farming_data`.
struct StonfiFarmNftFarmingDataReply {
    /// Current lifecycle status as a TVM stack integer.
    status: int
    /// Unix timestamp at which unstaking was requested, or zero.
    revokeTime: int
    /// Number of staking Jettons held by this position.
    stakedTokens: int
    /// Unix timestamp at which the position was initialized.
    stakeDate: int
    /// Per-pool accrued reward checkpoints keyed by an unsigned 8-bit pool index.
    claimedPerUnit: map<uint8, uint150>
    /// Current owner stack address, or `addr_none` after destruction.
    ownerAddress: any_address
}

/// Standard NFT data returned by `get_nft_data`.
struct StonfiFarmNftDataReply {
    /// True after the Farm collection has initialized this item.
    isInitialized: bool
    /// NFT item index assigned by the Farm collection.
    itemIndex: int
    /// Farm collection/minter stack address.
    collectionAddress: any_address
    /// Current owner stack address, or `addr_none` after destruction.
    ownerAddress: any_address
    /// Off-chain item content cell containing `<raw-address>.json`.
    content: cell
}

/// Exit codes thrown by the exact STON.fi Farm NFT revision.
enum StonfiFarmNftErrors {
    /// Sender address is outside the base workchain.
    InvalidWorkchain = 20085
    /// Attached GRAM does not cover the required reserve and downstream messages.
    InsufficientAttachedValue = 20083
    /// Current lifecycle status does not allow the requested operation.
    InvalidStatus = 20803
    /// TEP-62 ownership transfer is intentionally rejected for this SBT-style item.
    TransferRejected = 413
    /// Incoming opcode is not implemented by the exact contract revision.
    UnknownOpcode = 65535
}

/// Return current farming position state and per-pool reward checkpoints.
get fun get_farming_data(): StonfiFarmNftFarmingDataReply {
    throw 0;
}

/// Return standard NFT initialization, index, collection, owner, and content data.
get fun get_nft_data(): StonfiFarmNftDataReply {
    throw 0;
}

/// Return the optional SBT authority stack address; this revision returns `addr_none`.
get fun get_authority_address(): any_address {
    throw 0;
}

/// Return the unix timestamp at which unstaking was requested, or zero.
get fun get_revoked_time(): uint64 {
    throw 0;
}
