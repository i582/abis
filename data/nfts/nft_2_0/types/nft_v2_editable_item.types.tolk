/// TON NFT 2.0 editable item interface with editor-aware runtime storage.
contract NftV2EditableItem {
    author: "TON Core"
    version: "2.0"
    description: "Curated TON NFT 2.0 editable item profile; on-chain ABI matches the editable TEP-62 NFT v1 item"
    storage: NftV2EditableItemStorage
    storageAtDeployment: NftV2EditableItemDeploymentStorage
    incomingMessages: NftV2EditableItemIncomingMessage
    outgoingMessages: NftV2EditableItemOutgoingMessage
}

/// Deployment storage present before the collection initializes the editable item.
struct NftV2EditableItemDeploymentStorage {
    /// NFT item index stored as uint64 in the data cell.
    itemIndex: uint64
    /// Collection address authorized to initialize this item.
    collectionAddress: address
}

/// Initialized storage for the editable NFT item variant.
struct NftV2EditableItemStorage {
    /// NFT item index stored as uint64 in the data cell.
    itemIndex: uint64
    /// Collection address used for static-data reports.
    collectionAddress: address
    /// Current owner address authorized to transfer this item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
    /// Current editor address authorized to update content and transfer editorship.
    editorAddress: address
}

/// Editable collection-to-item initialization body used while storage is uninitialized.
struct NftV2EditableItemInit {
    /// Initial owner address stored by the item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
    /// Initial editor address stored by the editable item.
    editorAddress: address
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) NftV2EditableTransfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address; source restricts it to basechain.
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
struct (0x2fcb26a2) NftV2EditableGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Editor-originated request to transfer editorship.
struct (0x1c04412a) NftV2EditableTransferEditorship {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New editor address; source restricts it to basechain.
    newEditorAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Optional referenced custom payload parsed for layout compatibility.
    customPayload: cell?
    /// Nanotons forwarded to the new editor notification.
    forwardTonAmount: coins
    /// Raw `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Editor-originated request to replace the stored content cell.
struct (0x1a0b9d51) NftV2EditableEditContent {
    /// Caller-selected query id parsed by the source before the content ref.
    queryId: uint64
    /// Replacement individual item content cell.
    content: cell
}

/// Ownership assignment notification sent to the new owner.
struct (0x05138d91) NftV2EditableOwnershipAssigned {
    /// Query id copied from the transfer request.
    queryId: uint64
    /// Previous owner address.
    previousOwnerAddress: address
    /// Raw forwarded payload copied from the transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) NftV2EditableReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as uint256 by the reference source.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer or editorship transfer.
struct (0xd53276db) NftV2EditableExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Editorship assignment notification sent to the new editor.
struct (0x511a4463) NftV2EditableEditorshipAssigned {
    /// Query id copied from the editorship transfer request.
    queryId: uint64
    /// Previous editor address.
    previousEditorAddress: address
    /// Raw forwarded payload copied from the editorship transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by editable NFT 2.0 items.
type NftV2EditableItemIncomingMessage =
    | NftV2EditableTransfer
    | NftV2EditableGetStaticData
    | NftV2EditableTransferEditorship
    | NftV2EditableEditContent

/// Internal message bodies emitted by editable NFT 2.0 items.
type NftV2EditableItemOutgoingMessage =
    | NftV2EditableOwnershipAssigned
    | NftV2EditableReportStaticData
    | NftV2EditableExcesses
    | NftV2EditableEditorshipAssigned

/// Structured result returned by `get_nft_data`.
struct GetNftV2EditableDataReply {
    /// True when runtime storage includes owner, content, and editor fields.
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

/// NFT 2.0 editable item exit-code catalog from the reference FunC sources.
enum NftV2EditableItemErrors {
    /// Address workchain is not basechain.
    InvalidWorkchain = 333
    /// Transfer sender is not the current owner, or editorship sender is not the current editor.
    UnauthorizedOwnerOrEditor = 401
    /// Remaining balance after storage, forward amount, and fees would be negative.
    InsufficientRestAmount = 402
    /// Initialization sender is not the stored collection address.
    UnauthorizedCollectionInit = 405
    /// Content update sender is not the current editor.
    UnauthorizedEditContent = 410
    /// Incoming internal message opcode is not supported by the initialized item.
    UnsupportedOperation = 65535
}

/// Return item initialization flag, index, collection, owner, and content.
get fun get_nft_data(): GetNftV2EditableDataReply {
    throw 0;
}

/// Return the current editable-item editor address.
get fun get_editor(): address {
    throw 0;
}
