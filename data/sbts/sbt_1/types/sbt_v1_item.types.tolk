/// Getgems TEP-85 SBT v1 collection item interface.
contract SbtV1Item {
    author: "Getgems"
    version: "1"
    description: "Curated TEP-85 SBT collection item interface with non-transferable NFT item surface"
    storage: SbtV1ItemStorage
    storageAtDeployment: SbtV1ItemDeploymentStorage
    incomingMessages: SbtV1ItemIncomingMessage
    outgoingMessages: SbtV1ItemOutgoingMessage
    forceAbiExport: SbtV1ItemInit
    thrownErrors: SbtV1ItemErrors
}

/// Deployment storage present before the collection initializes the SBT item.
struct SbtV1ItemDeploymentStorage {
    /// SBT item index stored as uint64 in the root data cell.
    itemIndex: uint64
    /// Collection address authorized to initialize this SBT item.
    collectionAddress: address
}

/// Initialized storage for a collection-owned Getgems SBT item.
struct SbtV1ItemStorage {
    /// SBT item index stored as uint64 in the root data cell.
    itemIndex: uint64
    /// Collection address used for static-data reports and init authorization.
    collectionAddress: address
    /// Current owner address, or `addr_none` after `destroy`.
    ownerAddress: address?
    /// Referenced individual SBT content cell.
    content: cell
    /// Authority address allowed to revoke the SBT, or `addr_none` when unset.
    authorityAddress: address?
    /// Unix timestamp of revocation, or zero when the SBT is not revoked.
    revokedAt: uint64
}

/// Collection-to-item initialization body accepted while storage is uninitialized.
struct SbtV1ItemInit {
    /// Initial owner address stored by the SBT item.
    ownerAddress: address?
    /// Referenced individual SBT content cell.
    content: cell
    /// Authority address allowed to revoke this SBT, or `addr_none` for no authority.
    authorityAddress: address?
}

/// Rejected TEP-62 transfer request kept in ABI because TEP-85 requires NFT compatibility.
struct (0x5fcc3d14) SbtV1ItemTransfer {
    /// Caller-selected query id parsed before the source rejects transfer with exit code 413.
    queryId: uint64
    /// New owner address from the inherited NFT transfer layout.
    newOwnerAddress: address
    /// Optional response destination from the inherited NFT transfer layout.
    responseDestination: address?
    /// Optional custom payload from the inherited NFT transfer layout.
    customPayload: cell?
    /// Nanotons from the inherited NFT transfer layout.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) SbtV1ItemGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Open SBT owner lookup request defined by TEP-85.
struct (0xd0c3bfea) SbtV1ItemRequestOwner {
    /// Caller-selected query id copied into `owner_info`.
    queryId: uint64
    /// Destination that receives the owner information response.
    destination: address
    /// Referenced payload copied into the outgoing `owner_info` data field.
    forwardPayload: cell
    /// True when the outgoing response should include the SBT content ref.
    withContent: bool
}

/// Owner-only TEP-85 ownership proof request.
struct (0x04ded148) SbtV1ItemProveOwnership {
    /// Caller-selected query id copied into `ownership_proof`.
    queryId: uint64
    /// Destination that receives the ownership proof response.
    destination: address
    /// Referenced payload copied into the outgoing `ownership_proof` data field.
    forwardPayload: cell
    /// True when the outgoing proof should include the SBT content ref.
    withContent: bool
}

/// Owner-only request to destroy the SBT by clearing owner and authority addresses.
struct (0x1f04537a) SbtV1ItemDestroy {
    /// Caller-selected query id copied into the outgoing `excesses` response.
    queryId: uint64
}

/// Authority-only request to revoke the SBT by setting `revokedAt` to `now()`.
struct (0x6f89f5e3) SbtV1ItemRevoke {
    /// Caller-selected query id parsed by the source before revocation checks.
    queryId: uint64
}

/// Owner-only request to reserve storage funds and return excess balance.
struct (0xd136d3b3) SbtV1ItemTakeExcess {
    /// Caller-selected query id copied into the outgoing `excesses` response.
    queryId: uint64
}

/// Static-data response sent to the requester.
struct (0x8b771735) SbtV1ItemReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// SBT item index encoded as uint256 by the source.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Owner-information response emitted for open `request_owner` calls.
struct (0x0dd607e3) SbtV1ItemOwnerInfo {
    /// Query id copied from `request_owner`.
    queryId: uint64
    /// SBT item id encoded as uint256.
    itemId: uint256
    /// Address that initiated the `request_owner` call.
    initiatorAddress: address
    /// Current owner address, or `addr_none` after `destroy`.
    ownerAddress: address?
    /// Referenced payload copied from `request_owner`.
    data: cell
    /// Unix timestamp of revocation, or zero when the SBT is not revoked.
    revokedAt: uint64
    /// Optional content ref included only when `withContent` was true.
    content: cell?
}

/// Ownership proof response emitted for owner-only `prove_ownership` calls.
struct (0x0524c7ae) SbtV1ItemOwnershipProof {
    /// Query id copied from `prove_ownership`.
    queryId: uint64
    /// SBT item id encoded as uint256.
    itemId: uint256
    /// Current owner address that authorized the proof.
    ownerAddress: address
    /// Referenced payload copied from `prove_ownership`.
    data: cell
    /// Unix timestamp of revocation, or zero when the SBT is not revoked.
    revokedAt: uint64
    /// Optional content ref included only when `withContent` was true.
    content: cell?
}

/// Bounce-routed ownership proof failure notification sent back to the owner.
struct (0xc18e86d2) SbtV1ItemOwnershipProofBounced {
    /// Query id copied from the bounced `ownership_proof` body.
    queryId: uint64
}

/// Excess-value response emitted after destroy or take-excess requests.
struct (0xd53276db) SbtV1ItemExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Internal message bodies accepted by the collection-owned SBT item.
type SbtV1ItemIncomingMessage =
    | SbtV1ItemTransfer
    | SbtV1ItemGetStaticData
    | SbtV1ItemRequestOwner
    | SbtV1ItemProveOwnership
    | SbtV1ItemDestroy
    | SbtV1ItemRevoke
    | SbtV1ItemTakeExcess

/// Internal message bodies emitted by the collection-owned SBT item.
type SbtV1ItemOutgoingMessage =
    | SbtV1ItemReportStaticData
    | SbtV1ItemOwnerInfo
    | SbtV1ItemOwnershipProof
    | SbtV1ItemOwnershipProofBounced
    | SbtV1ItemExcesses

/// Structured result returned by `get_nft_data`.
struct SbtV1ItemDataReply {
    /// True when runtime storage includes owner, content, authority, and revoked time.
    isInitialized: bool
    /// SBT item index returned as a TVM stack integer.
    itemIndex: int
    /// Collection address stored by the item.
    collectionAddress: address
    /// Current owner address, or null while uninitialized or after `destroy`.
    ownerAddress: address?
    /// Referenced individual content cell; null while storage is uninitialized.
    content: cell?
}

/// Collection-owned SBT item exit-code catalog from Getgems FunC source.
enum SbtV1ItemErrors {
    /// Sender is not authorized for owner-only or authority-only operations.
    UnauthorizedOwnerOrAuthority = 401
    /// Revoke was requested after the SBT had already been revoked.
    AlreadyRevoked = 403
    /// Initialization sender is not the stored collection address.
    UnauthorizedCollectionInit = 405
    /// TEP-62 transfer is intentionally rejected for SBT.
    TransferRejected = 413
    /// Incoming internal message opcode is not supported by the initialized item.
    UnsupportedOperation = 65535
}

/// Return item initialization flag, index, collection, owner, and content.
get fun get_nft_data(): SbtV1ItemDataReply {
    throw 0;
}

/// Return the authority stack `MsgAddress`, or `addr_none` when no authority exists.
get fun get_authority_address(): any_address {
    throw 0;
}

/// Return the unix timestamp of revocation, or zero when the SBT is not revoked.
get fun get_revoked_time(): uint64 {
    throw 0;
}
