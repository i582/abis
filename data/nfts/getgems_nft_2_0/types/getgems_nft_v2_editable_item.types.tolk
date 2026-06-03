/// Getgems NFT item v2 interface for the editable runtime storage variant.
contract GetgemsNftEditableItemV2 {
    author: "Getgems"
    version: "2.0"
    description: "Curated Getgems NFT editable item v2 interface with editor storage and mint notifications"
    storage: GetgemsNftEditableItemV2Storage
    storageAtDeployment: GetgemsNftEditableItemV2DeploymentStorage
    incomingMessages: GetgemsNftEditableItemV2IncomingMessage
    outgoingMessages: GetgemsNftEditableItemV2OutgoingMessage
    forceAbiExport: GetgemsNftEditableItemV2MintInit | GetgemsNftEditableItemV2MintForwardTail
}

/// Deployment storage present before the collection initializes the editable item.
struct GetgemsNftEditableItemV2DeploymentStorage {
    /// NFT item index stored as uint64 in the root data cell.
    itemIndex: uint64
    /// Collection address authorized to initialize this editable item.
    collectionAddress: address
}

/// Initialized storage for an editable Getgems NFT item v2.
struct GetgemsNftEditableItemV2Storage {
    /// NFT item index stored as uint64 in the root data cell.
    itemIndex: uint64
    /// Collection address used for static-data reports and init authorization.
    collectionAddress: address
    /// Current owner address authorized to transfer this item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
    /// Current editor address authorized to update content and transfer editorship.
    editorAddress: address
}

/// Raw payload tail forwarded by a mint-time ownership notification.
type GetgemsNftEditableItemV2MintForwardPayload = RemainingBitsAndRefs

/// Optional tail layout after editable mint init body when source emits initial ownership_assigned.
struct GetgemsNftEditableItemV2MintForwardTail {
    /// Nanotons forwarded to the initial owner notification; absent when the raw tail is empty.
    forwardTonAmount: coins
    /// Raw remaining payload copied into the initial ownership_assigned message.
    forwardPayload: GetgemsNftEditableItemV2MintForwardPayload
}

/// Collection-to-item initialization body accepted while editable item storage is uninitialized.
struct GetgemsNftEditableItemV2MintInit {
    /// Initial owner address stored by the editable item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
    /// Initial editor address stored after content.
    editorAddress: address
    /// Empty tail for no notification, or `forwardTonAmount` followed by raw forwarded payload.
    mintForwardTail: RemainingBitsAndRefs
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) GetgemsNftEditableItemV2Transfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address; source restricts it to the base workchain.
    newOwnerAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Optional referenced custom payload parsed for layout compatibility.
    customPayload: cell?
    /// Nanotons forwarded to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) GetgemsNftEditableItemV2GetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Editor-originated request to transfer editorship.
struct (0x1c04412a) GetgemsNftEditableItemV2TransferEditorship {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New editor address; source restricts it to the base workchain.
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
struct (0x1a0b9d51) GetgemsNftEditableItemV2EditContent {
    /// Caller-selected query id parsed before the content ref.
    queryId: uint64
    /// Replacement individual item content cell.
    content: cell
}

/// Ownership assignment notification sent to the new owner or initial owner.
struct (0x05138d91) GetgemsNftEditableItemV2OwnershipAssigned {
    /// Query id copied from transfer requests, or zero for mint-time notifications.
    queryId: uint64
    /// Previous owner address, or collection address for mint-time notifications.
    previousOwnerAddress: address
    /// Raw forwarded payload copied from the source request body.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) GetgemsNftEditableItemV2ReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as uint256 by the source.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer or editorship transfer.
struct (0xd53276db) GetgemsNftEditableItemV2Excesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Editorship assignment notification sent to the new editor.
struct (0x511a4463) GetgemsNftEditableItemV2EditorshipAssigned {
    /// Query id copied from the editorship transfer request.
    queryId: uint64
    /// Previous editor address.
    previousEditorAddress: address
    /// Raw forwarded payload copied from the editorship transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by editable Getgems NFT item v2.
type GetgemsNftEditableItemV2IncomingMessage =
    | GetgemsNftEditableItemV2Transfer
    | GetgemsNftEditableItemV2GetStaticData
    | GetgemsNftEditableItemV2TransferEditorship
    | GetgemsNftEditableItemV2EditContent

/// Internal message bodies emitted by editable Getgems NFT item v2.
type GetgemsNftEditableItemV2OutgoingMessage =
    | GetgemsNftEditableItemV2OwnershipAssigned
    | GetgemsNftEditableItemV2ReportStaticData
    | GetgemsNftEditableItemV2Excesses
    | GetgemsNftEditableItemV2EditorshipAssigned

/// Structured result returned by `get_nft_data`.
struct GetgemsNftEditableItemV2DataReply {
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

/// Getgems NFT editable item v2 exit-code catalog from source.
enum GetgemsNftEditableItemV2Errors {
    /// Address workchain is not the configured base workchain.
    InvalidWorkchain = 333
    /// Transfer sender is not the owner, or editorship sender is not the editor.
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
get fun get_nft_data(): GetgemsNftEditableItemV2DataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftEditableItemV2Errors.InvalidWorkchain;
    assert (true) throw GetgemsNftEditableItemV2Errors.UnauthorizedOwnerOrEditor;
    assert (true) throw GetgemsNftEditableItemV2Errors.InsufficientRestAmount;
    assert (true) throw GetgemsNftEditableItemV2Errors.UnauthorizedCollectionInit;
    assert (true) throw GetgemsNftEditableItemV2Errors.UnauthorizedEditContent;
    assert (true) throw GetgemsNftEditableItemV2Errors.UnsupportedOperation;
    return {
        isInitialized: false,
        itemIndex: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: null,
        content: null,
    };
}

/// Return the current editable-item editor address.
get fun get_editor(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
