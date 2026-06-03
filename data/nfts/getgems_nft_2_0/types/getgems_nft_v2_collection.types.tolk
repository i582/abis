/// Getgems NFT collection v2 editable interface with second-owner administration.
contract GetgemsNftCollectionV2 {
    author: "Getgems"
    version: "2.0"
    description: "Curated Getgems NFT collection v2 interface with second owner and balance-return operation"
    storage: GetgemsNftCollectionV2Storage
    incomingMessages: GetgemsNftCollectionV2IncomingMessage
    outgoingMessages: GetgemsNftCollectionV2OutgoingMessage
    forceAbiExport: GetgemsNftCollectionV2LegacyStorage | GetgemsNftCollectionV2ItemMintInit | GetgemsNftCollectionV2BatchDeployItem | GetgemsNftCollectionV2BatchAutoIndexFlag
}

/// Current collection v2 storage written by `save_data`.
struct GetgemsNftCollectionV2Storage {
    /// Primary owner address authorized for all admin operations.
    ownerAddress: address
    /// Next item index stored as uint64.
    nextItemIndex: uint64
    /// Secondary owner address accepted for most admin operations except primary-owner change.
    secondOwnerAddress: address
    /// Referenced collection content cell containing metadata and common-content refs.
    content: Cell<GetgemsNftCollectionV2Content>
    /// Referenced NFT item code cell used to derive item state init.
    nftItemCode: cell
    /// Referenced royalty-params cell.
    royaltyParams: Cell<GetgemsNftCollectionV2RoyaltyParams>
}

/// Backward-compatible collection storage shape when no second owner bits are present.
struct GetgemsNftCollectionV2LegacyStorage {
    /// Primary owner address also used as the effective second owner by source fallback.
    ownerAddress: address
    /// Next item index stored as uint64.
    nextItemIndex: uint64
    /// Referenced collection content cell containing metadata and common-content refs.
    content: Cell<GetgemsNftCollectionV2Content>
    /// Referenced NFT item code cell used to derive item state init.
    nftItemCode: cell
    /// Referenced royalty-params cell.
    royaltyParams: Cell<GetgemsNftCollectionV2RoyaltyParams>
}

/// Collection content stored under the storage content reference.
struct GetgemsNftCollectionV2Content {
    /// Referenced collection metadata cell returned by `get_collection_data`.
    collectionMetadata: cell
    /// Referenced common content prefix cell used by `get_nft_content`.
    commonContent: cell
}

/// TEP-66 royalty parameters stored in a referenced cell.
struct GetgemsNftCollectionV2RoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    royaltyAddress: address
}

/// Raw standard-item initialization body that the collection can forward as an item body ref.
struct GetgemsNftCollectionV2ItemMintInit {
    /// Initial owner address stored by a standard Getgems item.
    ownerAddress: address
    /// Referenced individual item content cell.
    content: cell
    /// Empty tail for no initial notification, or `forwardTonAmount` followed by raw forwarded payload.
    mintForwardTail: RemainingBitsAndRefs
}

/// Value stored in the batch deploy dictionary.
struct GetgemsNftCollectionV2BatchDeployItem {
    /// Nanotons attached to the item deployment message.
    attachTonAmount: coins
    /// Raw referenced item initialization body forwarded unchanged to the deployed item.
    initParams: cell
}

/// Optional two-bit tail after batch deploy list controlling auto-index mode.
struct GetgemsNftCollectionV2BatchAutoIndexFlag {
    /// Source treats true or integer one as "use next_item_index for every batch entry".
    useNextItemIndex: int2
}

/// Royalty-params request accepted by Getgems collection v2.
struct (0x693d3950) GetgemsNftCollectionV2GetRoyaltyParams {
    /// Caller-selected query id copied into `report_royalty_params`.
    queryId: uint64
}

/// Owner or second-owner request to deploy a single NFT item.
struct (0x00000001) GetgemsNftCollectionV2DeployItem {
    /// Admin-selected query id parsed by the source.
    queryId: uint64
    /// Item index to deploy; must not be greater than `nextItemIndex`.
    itemIndex: uint64
    /// Nanotons attached to the item deployment message.
    attachTonAmount: coins
    /// Raw referenced item initialization body forwarded unchanged to the deployed item.
    initParams: cell
}

/// Owner or second-owner request to deploy a dictionary of NFT items.
struct (0x00000002) GetgemsNftCollectionV2BatchDeployItems {
    /// Admin-selected query id parsed by the source.
    queryId: uint64
    /// Dictionary keyed by uint64 item index with deployment amount and raw init body ref.
    deployList: map<uint64, GetgemsNftCollectionV2BatchDeployItem>
    /// Empty tail for classic indexes, or a raw two-bit `GetgemsNftCollectionV2BatchAutoIndexFlag`.
    autoIndexTail: RemainingBitsAndRefs
}

/// Primary-owner-only request to change the collection owner.
struct (0x00000003) GetgemsNftCollectionV2ChangeOwner {
    /// Admin-selected query id parsed by the source.
    queryId: uint64
    /// Replacement primary owner; source also stores it as second owner.
    newOwnerAddress: address
}

/// Owner or second-owner request to replace collection content and royalty params.
struct (0x00000004) GetgemsNftCollectionV2ChangeContent {
    /// Admin-selected query id parsed by the source.
    queryId: uint64
    /// Referenced replacement collection content cell.
    content: Cell<GetgemsNftCollectionV2Content>
    /// Referenced replacement royalty params cell.
    royaltyParams: Cell<GetgemsNftCollectionV2RoyaltyParams>
}

/// Owner or second-owner request that returns non-reserved collection balance.
struct (0x00000005) GetgemsNftCollectionV2ReturnBalance {
    /// Admin-selected query id copied into the balance-return response.
    queryId: uint64
}

/// Owner or second-owner request to change only the secondary owner address.
struct (0x00000006) GetgemsNftCollectionV2ChangeSecondOwner {
    /// Admin-selected query id parsed by the source.
    queryId: uint64
    /// Replacement secondary owner.
    newSecondOwnerAddress: address
}

/// Royalty-params response emitted by the collection.
struct (0xa8cb00ad) GetgemsNftCollectionV2ReportRoyaltyParams {
    /// Query id copied from `get_royalty_params`.
    queryId: uint64
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    royaltyAddress: address
}

/// Internal message bodies accepted by Getgems NFT collection v2.
type GetgemsNftCollectionV2IncomingMessage =
    | GetgemsNftCollectionV2GetRoyaltyParams
    | GetgemsNftCollectionV2DeployItem
    | GetgemsNftCollectionV2BatchDeployItems
    | GetgemsNftCollectionV2ChangeOwner
    | GetgemsNftCollectionV2ChangeContent
    | GetgemsNftCollectionV2ReturnBalance
    | GetgemsNftCollectionV2ChangeSecondOwner

/// Internal message bodies emitted by Getgems NFT collection v2.
type GetgemsNftCollectionV2OutgoingMessage =
    | GetgemsNftCollectionV2ReportRoyaltyParams
    | GetgemsNftCollectionV2ReturnBalance

/// Structured result returned by `get_collection_data`.
struct GetgemsNftCollectionV2DataReply {
    /// Next item index returned as a TVM stack integer.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionMetadata: cell
    /// Current primary owner address.
    ownerAddress: address
}

/// Getgems NFT collection v2 exit-code catalog from source.
enum GetgemsNftCollectionV2Errors {
    /// Batch deploy would exceed the action-list limit.
    BatchLimitExceeded = 399
    /// Sender is neither primary owner nor secondary owner.
    UnauthorizedOwnerOrSecondOwner = 401
    /// Single deploy item index is greater than `nextItemIndex`.
    InvalidItemIndex = 402
    /// Batch deploy item index errors are encoded as 403 plus the 1-based batch counter.
    InvalidBatchItemIndexBase = 403
    /// Secondary owner attempted to change the primary owner.
    UnauthorizedPrimaryOwnerChange = 4001
    /// Incoming internal message opcode is not supported by the collection.
    UnsupportedOperation = 65535
}

/// Return next item index, collection metadata cell, and primary owner address.
get fun get_collection_data(): GetgemsNftCollectionV2DataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftCollectionV2Errors.BatchLimitExceeded;
    assert (true) throw GetgemsNftCollectionV2Errors.UnauthorizedOwnerOrSecondOwner;
    assert (true) throw GetgemsNftCollectionV2Errors.InvalidItemIndex;
    assert (true) throw GetgemsNftCollectionV2Errors.InvalidBatchItemIndexBase;
    assert (true) throw GetgemsNftCollectionV2Errors.UnauthorizedPrimaryOwnerChange;
    assert (true) throw GetgemsNftCollectionV2Errors.UnsupportedOperation;
    return {
        nextItemIndex: 0,
        collectionMetadata: createEmptyCell(),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return deterministic NFT item address for an item index.
get fun get_nft_address_by_index(itemIndex: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return royalty numerator, denominator, and payout address.
get fun royalty_params(): GetgemsNftCollectionV2RoyaltyParams {
    return {
        numerator: 0,
        denominator: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return full NFT content by combining common collection content with individual item content.
get fun get_nft_content(itemIndex: int, individualContent: cell): cell {
    return createEmptyCell();
}

/// Return the secondary owner address used by Getgems collection v2 admin checks.
get fun get_second_owner_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
