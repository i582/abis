/// Tonstakers payout NFT collection for withdrawal/deposit payout bills.
contract TonstakersPayoutCollection {
    author: "Tonstakers"
    version: "1.0"
    description: "Tonstakers payout NFT collection for storage, mint/init flows, distribution callbacks, getters, and exit codes."
    storage: TonstakersPayoutCollectionStorage
    storageAtDeployment: TonstakersPayoutCollectionDeploymentStorage
    incomingMessages: TonstakersPayoutCollectionIncomingMessage
    outgoingMessages: TonstakersPayoutCollectionOutgoingMessage
    forceAbiExport: TonstakersPayoutCollectionContent | TonstakersPayoutCollectionPendingTonDistribution | TonstakersPayoutCollectionPendingJettonDistribution | TonstakersPayoutCollectionStartedTonDistribution | TonstakersPayoutCollectionStartedJettonDistribution
}

/// Runtime storage shape after at least one payout NFT has been minted.
struct TonstakersPayoutCollectionStorage {
    /// Total bill amount still issued by live payout NFTs, encoded as TL-B `Coins`.
    issuedBills: coins
    /// Pool/admin address authorized to initialize, mint, and start distribution.
    admin: address
    /// Optional distribution state cell installed by `init_collection`.
    distribution: Cell<TonstakersPayoutCollectionDistribution>?
    /// Referenced on-chain collection metadata cell used by `get_collection_data` and `get_nft_content`.
    collectionContent: Cell<TonstakersPayoutCollectionContent>
    /// Trailing runtime cursor ref present once `next_item_index > 0`.
    nftCursor: Cell<TonstakersPayoutCollectionNftCursor>
}

/// Initialized storage shape before the first payout NFT cursor ref exists.
struct TonstakersPayoutCollectionDeploymentStorage {
    /// Total bill amount before the first mint, encoded as TL-B `Coins`.
    issuedBills: coins
    /// Pool/admin address authorized to initialize, mint, and start distribution.
    admin: address
    /// Optional distribution state cell installed by `init_collection`.
    distribution: Cell<TonstakersPayoutCollectionDistribution>?
    /// Referenced on-chain collection metadata cell used by collection getters.
    collectionContent: Cell<TonstakersPayoutCollectionContent>
}

/// Runtime NFT cursor stored in the trailing storage ref.
struct TonstakersPayoutCollectionNftCursor {
    /// Next item index stored as uint64 and returned by `get_collection_data`.
    nextItemIndex: uint64
    /// First neighbor address stored before `current`.
    prev: address?
    /// Current deterministic payout NFT address that receives burn requests.
    current: address?
    /// Second neighbor address stored after `current`.
    next: address?
    /// Precomputed StateInit cell for the next deterministic payout NFT.
    nextStateInit: cell
}

/// TEP-64 on-chain content dictionary referenced from collection storage.
struct TonstakersPayoutCollectionContent {
    /// On-chain metadata marker byte before the metadata dictionary.
    tag: uint8
    /// Metadata dictionary keyed by sha256 field name and storing metadata value cells.
    entries: map<uint256, cell>
}

/// Pending TON distribution state encoded by tag bits `started = 0, jettons = 0`.
struct (0b00) TonstakersPayoutCollectionPendingTonDistribution {
    /// Initial volume before TON distribution starts; pool init stores zero.
    volume: coins
}

/// Pending Jetton distribution state encoded by tag bits `started = 0, jettons = 1`.
struct (0b01) TonstakersPayoutCollectionPendingJettonDistribution {
    /// Initial volume before Jetton distribution starts; pool init stores zero.
    volume: coins
    /// Collection-owned Jetton wallet authorized to start distribution by transfer notification.
    jettonWallet: address
}

/// Started TON distribution state encoded by tag bits `started = 1, jettons = 0`.
struct (0b10) TonstakersPayoutCollectionStartedTonDistribution {
    /// Remaining TON volume to distribute across burned bills.
    remainingVolume: coins
}

/// Started Jetton distribution state encoded by tag bits `started = 1, jettons = 1`.
struct (0b11) TonstakersPayoutCollectionStartedJettonDistribution {
    /// Remaining Jetton volume to distribute across burned bills.
    remainingVolume: coins
    /// Collection-owned Jetton wallet used for outgoing standard Jetton transfers.
    jettonWallet: address
}

/// Distribution state variants stored in the optional storage ref.
type TonstakersPayoutCollectionDistribution =
    | TonstakersPayoutCollectionPendingTonDistribution
    | TonstakersPayoutCollectionPendingJettonDistribution
    | TonstakersPayoutCollectionStartedTonDistribution
    | TonstakersPayoutCollectionStartedJettonDistribution

/// Pool/admin initialization request that installs the distribution state ref.
struct (0xf5aa8943) TonstakersPayoutCollectionInitCollection {
    /// Query id parsed from the standard body header.
    queryId: uint64
    /// Referenced distribution state; empty cells are invalid.
    distribution: Cell<TonstakersPayoutCollectionDistribution>
}

/// Pool/admin mint request for the next payout NFT.
struct (0x1674b0a0) TonstakersPayoutCollectionMintNft {
    /// Query id copied into the outgoing `init_nft` body.
    queryId: uint64
    /// Payout NFT owner address loaded by collection as `owner`.
    owner: address
    /// Bill amount added to `issued_bills`, encoded as TL-B `Coins`.
    amount: coins
    /// Pool-produced notification amount tail.
    notificationTon: coins
    /// Pool-produced forward amount tail.
    forwardTon: coins
}

/// Jetton-wallet transfer notification that starts Jetton distribution.
struct (0x7362d09c) TonstakersPayoutCollectionTransferNotification {
    /// Query id copied into the first burn request.
    queryId: uint64
    /// Jetton amount received by the collection wallet for distribution.
    burntAmount: coins
    /// Source address from the Jetton notification; `addr_none` is accepted for direct wallet mints.
    fromAddress: address?
    /// Standard Jetton notification tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Pool/admin request that starts TON distribution with the attached message value.
struct (0x1140a64f) TonstakersPayoutCollectionStartDistribution {
    /// Query id copied into the first burn request.
    queryId: uint64
}

/// Payout NFT burn callback accepted only from the deterministic burned item address.
struct (0xed58b0b2) TonstakersPayoutCollectionBurnNotification {
    /// Query id copied into distribution payout and follow-up messages.
    queryId: uint64
    /// Bill amount represented by the burned payout NFT.
    burntAmount: coins
    /// NFT owner that receives TON or Jetton distribution share.
    burnerAddress: address
    /// Burned NFT index used to verify the callback sender and advance the cursor.
    burntIndex: uint64
}

/// Collection-to-item initialization body emitted for each minted payout NFT.
struct (0x132f9a45) TonstakersPayoutCollectionInitNft {
    /// Query id copied from the mint request.
    queryId: uint64
    /// Initial owner stored by the payout NFT item.
    owner: address
    /// Bill amount stored by the payout NFT item.
    amount: coins
    /// Previous neighbor address loaded by `nft-item.func` before `next`.
    prev: address?
    /// Next neighbor address loaded by `nft-item.func` after `prev`.
    next: address?
}

/// Burn request emitted to the current payout NFT when distribution starts or continues.
struct (0xf127fe4e) TonstakersPayoutCollectionBurn {
    /// Query id copied from the distribution-start or burn-notification flow.
    queryId: uint64
}

/// Marker body emitted to TON distribution recipients and embedded in Jetton transfer forward payloads.
struct (0xdb3b8abd) TonstakersPayoutCollectionDistributedAsset {
    /// Query id copied from the burn-notification flow.
    queryId: uint64
}

/// Standard Jetton transfer emitted through the collection-owned Jetton wallet for Jetton distributions.
struct (0x0f8a7ea5) TonstakersPayoutCollectionJettonTransfer {
    /// Query id copied from the burn-notification flow.
    queryId: uint64
    /// Jetton share sent to the payout NFT owner.
    amount: coins
    /// Recipient payout NFT owner address.
    destination: address
    /// Response destination set to the payout recipient.
    responseDestination: address
    /// Optional custom payload, absent in distribution transfers.
    customPayload: cell?
    /// Notification TON amount forwarded with the Jetton transfer.
    forwardTonAmount: coins
    /// Inline forward payload tail beginning with `0` then `distributed_asset#db3b8abd`.
    forwardPayload: RemainingBitsAndRefs
}

/// Final admin callback emitted with all remaining balance after index zero is burned.
struct (0x4bc7c2df) TonstakersPayoutCollectionReturnUnused {
    /// Query id copied from the final burn-notification flow.
    queryId: uint64
}

/// Internal message bodies accepted by Tonstakers payout collection.
type TonstakersPayoutCollectionIncomingMessage =
    | TonstakersPayoutCollectionInitCollection
    | TonstakersPayoutCollectionMintNft
    | TonstakersPayoutCollectionTransferNotification
    | TonstakersPayoutCollectionStartDistribution
    | TonstakersPayoutCollectionBurnNotification

/// Internal message bodies emitted by Tonstakers payout collection.
type TonstakersPayoutCollectionOutgoingMessage =
    | TonstakersPayoutCollectionInitNft
    | TonstakersPayoutCollectionBurn
    | TonstakersPayoutCollectionDistributedAsset
    | TonstakersPayoutCollectionJettonTransfer
    | TonstakersPayoutCollectionReturnUnused

/// Structured result returned by `get_collection_data`.
struct TonstakersPayoutCollectionDataReply {
    /// Next payout NFT index returned as a TVM stack integer.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionContent: cell
    /// Pool/admin address stored by the collection.
    admin: address
}

/// Structured result returned by `get_issued_bills`.
struct TonstakersPayoutCollectionIssuedBillsReply {
    /// Total live bill amount, encoded as a TVM stack integer.
    issuedBills: int
    /// Number of minted bills, equal to `next_item_index`.
    billsCount: int
}

/// Payout collection exit-code catalog.
enum TonstakersPayoutCollectionErrors {
    /// Burn notification arrived before distribution was started.
    BurnBeforeDistribution = 66
    /// Collection has not been initialized with a distribution state ref.
    NeedInit = 67
    /// Distribution was already started before the requested start path.
    DistributionAlreadyStarted = 68
    /// Pending distribution is not configured for Jetton distribution.
    CannotDistributeJettons = 69
    /// Pending distribution is not configured for TON distribution.
    CannotDistributeTons = 70
    /// Transfer notification sender is not the configured Jetton wallet.
    UnknownJettonWallet = 71
    /// Mint request arrived after distribution had started.
    MintAfterDistributionStart = 72
    /// Mint request sender is not the stored admin/pool address.
    UnauthorizedMintRequest = 73
    /// Burn notification sender is not the deterministic payout NFT for the burned index.
    UnauthorizedBurnNotification = 74
    /// Jetton transfer notification sender is not admin or `addr_none`.
    UnauthorizedTransferSource = 79
    /// TON distribution start request sender is not the stored admin/pool address.
    UnauthorizedStartRequest = 80
    /// Init distribution ref was empty.
    EmptyDistributionCell = 333
    /// Unauthorized init or unsupported operation.
    UnauthorizedInitOrUnsupportedOperation = 65535
}

/// Return next item index, collection metadata cell, and admin address.
get fun get_collection_data(): TonstakersPayoutCollectionDataReply {
    assert (true) throw TonstakersPayoutCollectionErrors.BurnBeforeDistribution;
    assert (true) throw TonstakersPayoutCollectionErrors.NeedInit;
    assert (true) throw TonstakersPayoutCollectionErrors.DistributionAlreadyStarted;
    assert (true) throw TonstakersPayoutCollectionErrors.CannotDistributeJettons;
    assert (true) throw TonstakersPayoutCollectionErrors.CannotDistributeTons;
    assert (true) throw TonstakersPayoutCollectionErrors.UnknownJettonWallet;
    assert (true) throw TonstakersPayoutCollectionErrors.MintAfterDistributionStart;
    assert (true) throw TonstakersPayoutCollectionErrors.UnauthorizedMintRequest;
    assert (true) throw TonstakersPayoutCollectionErrors.UnauthorizedBurnNotification;
    assert (true) throw TonstakersPayoutCollectionErrors.UnauthorizedTransferSource;
    assert (true) throw TonstakersPayoutCollectionErrors.UnauthorizedStartRequest;
    assert (true) throw TonstakersPayoutCollectionErrors.EmptyDistributionCell;
    assert (true) throw TonstakersPayoutCollectionErrors.UnauthorizedInitOrUnsupportedOperation;
    return {
        nextItemIndex: 0,
        collectionContent: createEmptyCell(),
        admin: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return the optional distribution state cell.
get fun get_distribution_data(): cell? {
    return null;
}

/// Return total issued bill amount and minted bill count.
get fun get_issued_bills(): TonstakersPayoutCollectionIssuedBillsReply {
    return {
        issuedBills: 0,
        billsCount: 0,
    };
}

/// Return deterministic payout NFT item address for `index`.
get fun get_nft_address_by_index(index: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return full TEP-64 NFT content built from collection metadata and individual bill amount.
get fun get_nft_content(index: int, individualNftContent: cell): cell {
    return createEmptyCell();
}
