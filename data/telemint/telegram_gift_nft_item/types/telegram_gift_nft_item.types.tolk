/// Telegram Gift NFT item interface for collectible gifts traded through Fragment.
contract TelegramGiftNftItem {
    author: "Telegram"
    version: "1.0"
    description: "Telegram Gift NFT Item represents one Telegram collectible gift, including ownership transfers and Fragment auctions."
    storage: TelegramGiftNftItemStorage
    incomingMessages: TelegramGiftNftItemIncomingMessage
    outgoingMessages: TelegramGiftNftItemOutgoingMessage
    forceAbiExport: TelegramGiftNftItemBidInfo
    thrownErrors: Errors
}

/// Root persistent item data: immutable config plus optional initialized item state.
struct TelegramGiftNftItemStorage {
    /// Referenced config cell with item index and collection address.
    config: Cell<TelegramGiftNftItemConfig>
    /// Referenced runtime state, absent before collection deployment initializes the item.
    state: Cell<TelegramGiftNftItemState>?
}

/// Immutable item config stored in the item data root.
struct TelegramGiftNftItemConfig {
    /// Collection-defined 256-bit NFT item index.
    itemIndex: uint256
    /// Collection address authorized to initialize this item.
    collectionAddress: address
}

/// Initialized Telegram Gift item state.
struct TelegramGiftNftItemState {
    /// Current owner; `addr_none` is used while an initial auction has no winner.
    ownerAddress: address?
    /// Referenced content cell containing NFT content, a reserved dictionary, and token info.
    content: Cell<TelegramGiftNftItemContent>
    /// Referenced active auction state and config, or absent when no auction is active.
    auction: Cell<TelegramGiftAuction>?
    /// Referenced royalty parameters used when distributing auction proceeds.
    royaltyParams: Cell<TelegramGiftNftRoyaltyParams>
}

/// Telegram Gift content cell retained from the TeleMint item storage format.
struct TelegramGiftNftItemContent {
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// Reserved 256-bit-key dictionary retained by the TeleMint storage layout.
    dnsRecords: map<uint256, cell>
    /// Raw referenced gift token-info cell; text fields are length-prefixed by an 8-bit byte length.
    tokenInfo: cell
}

/// NFT royalty payout parameters.
struct TelegramGiftNftRoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address; `addr_none` means no payout destination.
    destination: address?
}

/// Last accepted auction bid stored in auction state.
struct TelegramGiftLastBid {
    /// Bidder address to receive ownership or refunds.
    bidderAddress: address
    /// Bid amount in nanograms.
    bid: coins
    /// Unix timestamp of the bid.
    bidTs: uint32
}

/// Mutable auction state.
struct TelegramGiftAuctionState {
    /// Referenced last bid, absent before the first successful bid.
    lastBid: Cell<TelegramGiftLastBid>?
    /// Current minimum acceptable bid in nanograms.
    minBid: coins
    /// Auction timing value; newer revisions may retain a relative duration until the first bid.
    endTime: uint32
}

/// Auction configuration used for initial and restarted auctions.
struct TelegramGiftAuctionConfig {
    /// Beneficiary receiving auction proceeds after royalties.
    beneficiaryAddress: address
    /// Minimum first bid in nanograms.
    initialMinBid: coins
    /// Instant-win bid in nanograms, or zero when disabled.
    maxBid: coins
    /// Minimum bid increase percent.
    minBidStep: uint8
    /// Minimum extension window in seconds.
    minExtendTime: uint32
    /// Auction duration in seconds; newer revisions also accept a high-bit absolute-deadline mode.
    duration: uint32
}

/// Active auction cell with state and config references.
struct TelegramGiftAuction {
    /// Referenced mutable auction state.
    state: Cell<TelegramGiftAuctionState>
    /// Referenced auction configuration.
    config: Cell<TelegramGiftAuctionConfig>
}

/// Collection-to-item initialization and first-bid body.
struct (0x299a3e15) TelegramGiftNftItemDeploy {
    /// First bidder address supplied by the collection.
    senderAddress: address
    /// First bid amount in nanograms.
    bid: coins
    /// Raw referenced gift token-info cell.
    tokenInfo: cell
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// Referenced auction configuration.
    auctionConfig: Cell<TelegramGiftAuctionConfig>
    /// Referenced royalty parameters.
    royaltyParams: Cell<TelegramGiftNftRoyaltyParams>
}

/// Owner-originated request to start a new auction.
struct (0x487a8e81) TelegramGiftNftItemStartAuction {
    /// Caller-selected query id echoed by `teleitem_ok` when non-zero.
    queryId: uint64
    /// Referenced auction configuration.
    auctionConfig: Cell<TelegramGiftAuctionConfig>
}

/// Owner-originated request to cancel an auction without bids.
struct (0x371638ae) TelegramGiftNftItemCancelAuction {
    /// Caller-selected query id echoed by `teleitem_ok` when non-zero.
    queryId: uint64
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) TelegramGiftNftItemTransfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address; only workchain 0 is accepted.
    newOwnerAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Optional referenced custom payload parsed for TEP-62 layout compatibility.
    customPayload: cell?
    /// Nanograms forwarded to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) TelegramGiftNftItemGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Royalty-params request accepted by the Telegram Gift item.
struct (0x693d3950) TelegramGiftNftItemGetRoyaltyParams {
    /// Caller-selected query id copied into `report_royalty_params`.
    queryId: uint64
}

/// Ownership assignment notification sent to a transfer target or auction winner.
struct (0x05138d91) TelegramGiftNftItemOwnershipAssigned {
    /// Query id copied from transfer requests, or current logical time for auction settlement.
    queryId: uint64
    /// Previous owner address; auction settlement may use `addr_none`.
    previousOwnerAddress: address?
    /// Raw forwarded payload; auction settlement includes inline `TelegramGiftNftItemBidInfo`.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) TelegramGiftNftItemReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as uint256.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer.
struct (0xd53276db) TelegramGiftNftItemExcesses {
    /// Query id copied from the transfer request.
    queryId: uint64
}

/// Royalty-params response emitted by the item.
struct (0xa8cb00ad) TelegramGiftNftItemReportRoyaltyParams {
    /// Query id copied from `get_royalty_params`.
    queryId: uint64
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: address?
}

/// Plain money-transfer notification emitted for auction payouts and balance returns.
struct (0x370fec51) TelegramGiftNftItemFillUp {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Notification emitted to the previous bidder when they are outbid.
struct (0x557cea20) TelegramGiftNftItemOutbidNotification {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Acknowledgement emitted after successful auction-management commands.
struct (0xa37a0983) TelegramGiftNftItemOk {
    /// Query id copied from the accepted owner command.
    queryId: uint64
}

/// Refund notification emitted when a collection deploy attempt cannot initialize state.
struct (0xa43227e1) TelegramGiftNftItemReturnBid {
    /// Current logical time used as the refund query id.
    queryId: uint64
}

/// Payload embedded in auction-settlement `ownership_assigned` forward data.
struct (0x38127de1) TelegramGiftNftItemBidInfo {
    /// Winning bid amount in nanograms.
    bid: coins
    /// Unix timestamp of the winning bid.
    bidTs: uint32
}

/// Internal message bodies accepted by Telegram Gift NFT item.
type TelegramGiftNftItemIncomingMessage =
    | TelegramGiftNftItemDeploy
    | TelegramGiftNftItemStartAuction
    | TelegramGiftNftItemCancelAuction
    | TelegramGiftNftItemTransfer
    | TelegramGiftNftItemGetStaticData
    | TelegramGiftNftItemGetRoyaltyParams

/// Internal message bodies emitted by Telegram Gift NFT item.
type TelegramGiftNftItemOutgoingMessage =
    | TelegramGiftNftItemOwnershipAssigned
    | TelegramGiftNftItemReportStaticData
    | TelegramGiftNftItemExcesses
    | TelegramGiftNftItemReportRoyaltyParams
    | TelegramGiftNftItemFillUp
    | TelegramGiftNftItemOutbidNotification
    | TelegramGiftNftItemOk
    | TelegramGiftNftItemReturnBid

/// Structured result returned by `get_nft_data`.
struct TelegramGiftNftItemDataReply {
    /// True when runtime state has been initialized by the collection.
    isInitialized: bool
    /// NFT item index returned as a TVM stack integer.
    itemIndex: int
    /// Collection address stored in item config.
    collectionAddress: address
    /// Current owner address, or `addr_none` before auction settlement.
    ownerAddress: any_address
    /// Referenced individual NFT content cell, or null while uninitialized.
    content: cell?
}

/// Structured result returned by `get_telemint_auction_state`.
struct TelegramGiftAuctionStateReply {
    /// Last bidder address, or `addr_none` before the first bid.
    bidderAddress: any_address
    /// Last bid amount in nanograms, or zero before the first bid.
    bid: coins
    /// Last bid unix timestamp, or zero before the first bid.
    bidTs: uint32
    /// Current minimum acceptable bid in nanograms.
    minBid: coins
    /// Auction end timestamp; a pending relative-time auction may return the uint32 maximum sentinel.
    endTime: uint32
}

/// Structured result returned by `get_telemint_auction_config`.
struct TelegramGiftAuctionConfigReply {
    /// Beneficiary address, or TVM null when no auction is active.
    beneficiaryAddress: address?
    /// Minimum first bid in nanograms.
    initialMinBid: coins
    /// Instant-win bid in nanograms, or zero when disabled.
    maxBid: coins
    /// Minimum bid increase percent.
    minBidStep: uint8
    /// Minimum extension window in seconds.
    minExtendTime: uint32
    /// Auction duration in seconds.
    duration: uint32
}

/// Structured result returned by `royalty_params`.
struct TelegramGiftRoyaltyParamsReply {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: any_address
}

/// Telegram Gift NFT item exit-code catalog.
enum Errors {
    /// Remaining balance after storage, forward amount, and fees would be negative.
    NotEnoughFunds = 206
    /// Incoming internal message opcode is not supported.
    UnknownOp = 208
    /// Item state is still uninitialized.
    Uninitialized = 210
    /// Bid is below the current minimum.
    TooSmallStake = 211
    /// Initialization message was not sent by the stored collection.
    ForbiddenNotDeploy = 213
    /// Active auction accepts only plain zero-op bid transfers.
    ForbiddenNotStake = 214
    /// Top-up is allowed only from the current owner after auction end.
    ForbiddenTopup = 215
    /// Transfer is allowed only from the current owner.
    ForbiddenTransfer = 216
    /// No active auction exists.
    NoAuction = 219
    /// Auction management is allowed only from the current owner.
    ForbiddenAuction = 220
    /// Auction cancellation is forbidden after bids have arrived.
    AlreadyHasStakes = 221
    /// Auction config violates the accepted value bounds.
    InvalidAuctionConfig = 223
    /// Address workchain is not zero.
    IncorrectWorkchain = 333
}

/// Return item initialization flag, index, collection, owner, and individual content.
get fun get_nft_data(): TelegramGiftNftItemDataReply {
    throw 0;
}

/// Return the collection-defined gift token name used in Fragment metadata.
get fun get_telemint_token_name(): string {
    throw 0;
}

/// Return active auction state; throws `NoAuction` when no auction is active.
get fun get_telemint_auction_state(): TelegramGiftAuctionStateReply {
    throw 0;
}

/// Return active auction configuration, or null beneficiary and zero values when no auction is active.
get fun get_telemint_auction_config(): TelegramGiftAuctionConfigReply {
    throw 0;
}

/// Return stored royalty parameters.
get fun royalty_params(): TelegramGiftRoyaltyParamsReply {
    throw 0;
}
