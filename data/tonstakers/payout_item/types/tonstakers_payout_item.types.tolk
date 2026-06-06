/// Tonstakers payout NFT item interface for payout bill ownership and burn distribution.
contract TonstakersPayoutItem {
    author: "Tonstakers"
    version: "1.0"
    description: "Tonstakers payout NFT item for payout bill ownership, burn-chain distribution, storage, getters, and exit codes."
    storage: TonstakersPayoutItemStorage
    storageAtDeployment: TonstakersPayoutItemDeploymentStorage
    incomingMessages: TonstakersPayoutItemIncomingMessage
    outgoingMessages: TonstakersPayoutItemOutgoingMessage
}

/// Deployment storage created by the payout collection before `init_nft`.
struct TonstakersPayoutItemDeploymentStorage {
    /// False in collection-built item state init.
    isInitialized: bool
    /// Collection address authorized to initialize this payout item.
    collectionAddress: address
    /// Payout item index encoded as uint64.
    itemIndex: uint64
}

/// Referenced cell that stores the next payout item address.
struct TonstakersPayoutItemNextAddress {
    /// Next item in the payout burn chain, or `addr_none` for the terminal item.
    nextItemAddress: address?
}

/// Initialized runtime storage after the collection sends `init_nft`.
struct TonstakersPayoutItemStorage {
    /// True after the payout collection initializes the item.
    isInitialized: bool
    /// Current owner address authorized to transfer this payout bill.
    ownerAddress: address
    /// Payout collection address authorized to initialize and burn this item.
    collectionAddress: address
    /// Payout item index encoded as uint64.
    itemIndex: uint64
    /// Bill amount stored as TON or pool-jetton nano-units depending on the collection distribution.
    amount: coins
    /// Previous item address authorized to burn this item during chained distribution, or `addr_none` at a chain edge.
    previousItemAddress: address?
    /// Referenced next item address loaded from `^slice next`.
    nextItemAddress: Cell<TonstakersPayoutItemNextAddress>
}

/// Collection-to-item initialization body accepted only while storage is uninitialized.
struct (0x132f9a45) TonstakersPayoutItemInit {
    /// Query id copied into the initialization ownership-assigned notification.
    queryId: uint64
    /// Initial owner address stored by the item.
    ownerAddress: address
    /// Bill amount stored in runtime storage and exposed by `get_bill_amount`.
    amount: coins
    /// Previous item address in the payout burn chain, or `addr_none` at a chain edge.
    previousItemAddress: address?
    /// Next item address in the payout burn chain, or `addr_none` at a chain edge.
    nextItemAddress: address?
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) TonstakersPayoutItemTransfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address in the basechain workchain.
    newOwnerAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Custom-payload presence bit; remaining refs stay in `forwardPayload`.
    customPayloadPresent: bool
    /// Nanotons forwarded to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Burn request accepted from the previous item or collection and forwarded to the next item.
struct (0xf127fe4e) TonstakersPayoutItemBurn {
    /// Query id copied through the burn chain and into the collection burn notification.
    queryId: uint64
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) TonstakersPayoutItemGetStaticData {
    /// Query id copied into `report_static_data`.
    queryId: uint64
}

/// Ownership assignment notification sent after initialization or transfer.
struct (0x05138d91) TonstakersPayoutItemOwnershipAssigned {
    /// Query id copied from `init_nft` or transfer.
    queryId: uint64
    /// Previous owner address; initialization emits `addr_none`.
    previousOwnerAddress: address?
    /// Raw TEP-62 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Excess-value response sent after transfer when a response destination is present.
struct (0xd53276db) TonstakersPayoutItemExcesses {
    /// Query id copied from the transfer request.
    queryId: uint64
}

/// Burn report emitted to the payout collection.
struct (0xed58b0b2) TonstakersPayoutItemBurnNotification {
    /// Query id copied from the burn request.
    queryId: uint64
    /// Bill amount stored by this item at burn time.
    amount: coins
    /// Owner address stored by this item at burn time.
    ownerAddress: address
    /// Item index reported to the collection as uint64.
    itemIndex: uint64
}

/// Static-data response emitted to the requester.
struct (0x8b771735) TonstakersPayoutItemReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// Item index encoded as uint256.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Internal message bodies accepted by the payout item.
type TonstakersPayoutItemIncomingMessage =
    | TonstakersPayoutItemInit
    | TonstakersPayoutItemTransfer
    | TonstakersPayoutItemBurn
    | TonstakersPayoutItemGetStaticData

/// Internal message bodies emitted by the payout item.
type TonstakersPayoutItemOutgoingMessage =
    | TonstakersPayoutItemOwnershipAssigned
    | TonstakersPayoutItemExcesses
    | TonstakersPayoutItemBurn
    | TonstakersPayoutItemBurnNotification
    | TonstakersPayoutItemReportStaticData

/// Structured result returned by `get_nft_data`.
struct TonstakersPayoutItemNftDataReply {
    /// True when runtime storage includes owner, amount, previous, and next fields.
    isInitialized: bool
    /// Item index returned as a TVM stack integer.
    itemIndex: int
    /// Collection address stored by the item.
    collectionAddress: address
    /// Current owner address, or null before initialization.
    ownerAddress: address?
    /// Cell containing the bill amount encoded as `Coins`.
    billContent: cell
}

/// Payout item exit-code catalog.
enum TonstakersPayoutItemErrors {
    /// Address workchain is not basechain.
    InvalidWorkchain = 333
    /// Sender is not authorized for transfer or burn.
    Unauthorized = 401
    /// Remaining balance after storage, forward amount, and fees would be negative.
    NotEnoughTons = 402
    /// Incoming initialized opcode is not supported by the item.
    UnknownOpcode = 406
    /// Transfer body does not contain the required forward-payload bit.
    NoForwardPayload = 708
    /// Initialization sender is not the stored collection address.
    UnauthorizedInit = 65535
}

/// Return initialization flag, index, collection, owner, and a bill-amount content cell.
get fun get_nft_data(): TonstakersPayoutItemNftDataReply {
    assert (true) throw TonstakersPayoutItemErrors.InvalidWorkchain;
    assert (true) throw TonstakersPayoutItemErrors.Unauthorized;
    assert (true) throw TonstakersPayoutItemErrors.NotEnoughTons;
    assert (true) throw TonstakersPayoutItemErrors.UnknownOpcode;
    assert (true) throw TonstakersPayoutItemErrors.NoForwardPayload;
    assert (true) throw TonstakersPayoutItemErrors.UnauthorizedInit;
    return {
        isInitialized: false,
        itemIndex: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: null,
        billContent: createEmptyCell(),
    };
}

/// Return the payout bill amount stored in runtime storage.
get fun get_bill_amount(): int {
    return 0;
}
