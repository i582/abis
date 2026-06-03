/// Getgems NFT item v2 interface for the standard runtime storage variant.
contract GetgemsNftItemV2 {
    author: "Getgems"
    version: "2.0"
    description: "Curated Getgems NFT item v2 interface with mint-time ownership_assigned support"
    storage: GetgemsNftItemV2Storage
    storageAtDeployment: GetgemsNftItemV2DeploymentStorage
    incomingMessages: GetgemsNftItemV2IncomingMessage
    outgoingMessages: GetgemsNftItemV2OutgoingMessage
    forceAbiExport: GetgemsNftItemV2MintInit | GetgemsNftItemV2MintForwardTail
}

/// Deployment storage present before the collection initializes the item.
struct GetgemsNftItemV2DeploymentStorage {
    /// NFT item index stored as uint64 in the root data cell.
    itemIndex: uint64
    /// Collection address authorized to initialize this item.
    collectionAddress: address
}

/// Initialized storage for a standard Getgems NFT item v2.
struct GetgemsNftItemV2Storage {
    /// NFT item index stored as uint64 in the root data cell.
    itemIndex: uint64
    /// Collection address used for static-data reports and init authorization.
    collectionAddress: address
    /// Current owner address authorized to transfer this item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
}

/// Raw payload tail forwarded by a mint-time ownership notification.
type GetgemsNftItemV2MintForwardPayload = RemainingBitsAndRefs

/// Optional tail layout after mint init body when source emits initial ownership_assigned.
struct GetgemsNftItemV2MintForwardTail {
    /// Nanotons forwarded to the initial owner notification; absent when the raw tail is empty.
    forwardTonAmount: coins
    /// Raw remaining payload copied into the initial ownership_assigned message.
    forwardPayload: GetgemsNftItemV2MintForwardPayload
}

/// Collection-to-item initialization body accepted while storage is uninitialized.
struct GetgemsNftItemV2MintInit {
    /// Initial owner address stored by the item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
    /// Empty tail for no notification, or `forwardTonAmount` followed by raw forwarded payload.
    mintForwardTail: RemainingBitsAndRefs
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) GetgemsNftItemV2Transfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address; source restricts it to the base workchain.
    newOwnerAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Optional referenced custom payload parsed for TEP-62 layout compatibility.
    customPayload: cell?
    /// Nanotons forwarded to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) GetgemsNftItemV2GetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Ownership assignment notification sent to the new owner or initial owner.
struct (0x05138d91) GetgemsNftItemV2OwnershipAssigned {
    /// Query id copied from transfer requests, or zero for mint-time notifications.
    queryId: uint64
    /// Previous owner address, or collection address for mint-time notifications.
    previousOwnerAddress: address
    /// Raw forwarded payload copied from the source request body.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) GetgemsNftItemV2ReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as uint256 by the source.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer.
struct (0xd53276db) GetgemsNftItemV2Excesses {
    /// Query id copied from the transfer request.
    queryId: uint64
}

/// Internal message bodies accepted by initialized standard Getgems NFT item v2.
type GetgemsNftItemV2IncomingMessage =
    | GetgemsNftItemV2Transfer
    | GetgemsNftItemV2GetStaticData

/// Internal message bodies emitted by standard Getgems NFT item v2.
type GetgemsNftItemV2OutgoingMessage =
    | GetgemsNftItemV2OwnershipAssigned
    | GetgemsNftItemV2ReportStaticData
    | GetgemsNftItemV2Excesses

/// Structured result returned by `get_nft_data`.
struct GetgemsNftItemV2DataReply {
    /// True when runtime storage includes owner and content fields.
    isInitialized: bool
    /// NFT item index returned as a TVM stack integer.
    itemIndex: int
    /// Collection address stored by the item.
    collectionAddress: address
    /// Current owner address; null while storage is uninitialized.
    ownerAddress: address?
    /// Referenced individual content cell; null while storage is uninitialized.
    content: cell?
}

/// Getgems NFT item v2 exit-code catalog from source.
enum GetgemsNftItemV2Errors {
    /// Address workchain is not the configured base workchain.
    InvalidWorkchain = 333
    /// Transfer sender is not the current owner.
    UnauthorizedOwner = 401
    /// Remaining balance after storage, forward amount, and fees would be negative.
    InsufficientRestAmount = 402
    /// Initialization sender is not the stored collection address.
    UnauthorizedCollectionInit = 405
    /// Incoming internal message opcode is not supported by the initialized item.
    UnsupportedOperation = 65535
}

/// Return item initialization flag, index, collection, owner, and content.
get fun get_nft_data(): GetgemsNftItemV2DataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftItemV2Errors.InvalidWorkchain;
    assert (true) throw GetgemsNftItemV2Errors.UnauthorizedOwner;
    assert (true) throw GetgemsNftItemV2Errors.InsufficientRestAmount;
    assert (true) throw GetgemsNftItemV2Errors.UnauthorizedCollectionInit;
    assert (true) throw GetgemsNftItemV2Errors.UnsupportedOperation;
    return {
        isInitialized: false,
        itemIndex: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: null,
        content: null,
    };
}
