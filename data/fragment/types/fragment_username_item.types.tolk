/// Fragment Telegram username TeleMint item contract.
contract FragmentUsernameItem {
    author: "Telegram"
    version: "1.0"
    description: "Fragment TeleMint item interface for Telegram usernames with auction, DNS, royalty, and TEP-62 messages"
    storage: FragmentUsernameItemStorage
    incomingMessages: FragmentUsernameItemIncomingMessage
    outgoingMessages: FragmentUsernameItemOutgoingMessage
    forceAbiExport: FragmentUsernameItemBidInfo
    thrownErrors: FragmentUsernameItemErrors
}

/// Root persistent item data.
struct FragmentUsernameItemStorage {
    /// Referenced immutable item config.
    config: Cell<FragmentUsernameItemConfig>
    /// Referenced runtime item state, absent before collection initialization.
    state: Cell<FragmentUsernameItemState>?
}

/// Immutable item config stored in item data.
struct FragmentUsernameItemConfig {
    /// Name hash used as the NFT item index.
    itemIndex: uint256
    /// Collection address authorized to initialize the item.
    collectionAddress: address
}

/// Initialized Fragment username item state.
struct FragmentUsernameItemState {
    /// Current owner; `addr_none` is used while an initial auction has no winner.
    ownerAddress: address?
    /// Referenced content cell containing NFT content, DNS records, and token info.
    content: Cell<FragmentUsernameItemContent>
    /// Referenced active auction state and config, or absent when no auction is active.
    auction: Cell<FragmentUsernameItemAuction>?
    /// Referenced royalty parameters used for auction settlement.
    royaltyParams: Cell<FragmentUsernameItemRoyaltyParams>
}

/// Item content cell used by Fragment username items.
struct FragmentUsernameItemContent {
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// DNS record dictionary keyed by 256-bit category hash with record cells as values.
    dnsRecords: map<uint256, cell>
    /// Raw referenced token-info cell with length-prefixed name and domain text.
    tokenInfo: cell
}

/// NFT royalty payout parameters.
struct FragmentUsernameItemRoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: address?
}

/// Last accepted auction bid stored in auction state.
struct FragmentUsernameItemLastBid {
    /// Bidder address to receive ownership or refunds.
    bidderAddress: address
    /// Bid amount in nanotons.
    bid: coins
    /// Unix timestamp of the bid.
    bidTs: uint32
}

/// Mutable auction state.
struct FragmentUsernameItemAuctionState {
    /// Referenced last bid, absent before the first successful bid.
    lastBid: Cell<FragmentUsernameItemLastBid>?
    /// Current minimum acceptable bid in nanotons.
    minBid: coins
    /// Unix timestamp when the auction may be finalized.
    endTime: uint32
}

/// Auction configuration used for initial and restarted auctions.
struct FragmentUsernameItemAuctionConfig {
    /// Beneficiary receiving auction proceeds after royalties.
    beneficiaryAddress: address
    /// Minimum first bid in nanotons.
    initialMinBid: coins
    /// Instant-win bid in nanotons, or zero when disabled.
    maxBid: coins
    /// Minimum bid increase percent.
    minBidStep: uint8
    /// Minimum extension window in seconds.
    minExtendTime: uint32
    /// Auction duration in seconds.
    duration: uint32
}

/// Active auction cell with state and config references.
struct FragmentUsernameItemAuction {
    /// Referenced mutable auction state.
    state: Cell<FragmentUsernameItemAuctionState>
    /// Referenced auction configuration.
    config: Cell<FragmentUsernameItemAuctionConfig>
}

/// Collection-to-item initialization and first-bid body.
struct (0x299a3e15) FragmentUsernameItemDeploy {
    /// First bidder address supplied by the collection.
    senderAddress: address
    /// First bid amount in nanotons.
    bid: coins
    /// Raw referenced token-info cell.
    tokenInfo: cell
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// Referenced auction configuration.
    auctionConfig: Cell<FragmentUsernameItemAuctionConfig>
    /// Referenced royalty parameters.
    royaltyParams: Cell<FragmentUsernameItemRoyaltyParams>
}

/// Owner-originated request to start a new auction.
struct (0x487a8e81) FragmentUsernameItemStartAuction {
    /// Caller-selected query id echoed by `teleitem_ok` when non-zero.
    queryId: uint64
    /// Referenced auction configuration.
    auctionConfig: Cell<FragmentUsernameItemAuctionConfig>
}

/// Owner-originated request to cancel an auction without bids.
struct (0x371638ae) FragmentUsernameItemCancelAuction {
    /// Caller-selected query id echoed by `teleitem_ok` when non-zero.
    queryId: uint64
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) FragmentUsernameItemTransfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// Basechain new owner address.
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
struct (0x2fcb26a2) FragmentUsernameItemGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Royalty-params request accepted by username items.
struct (0x693d3950) FragmentUsernameItemGetRoyaltyParams {
    /// Caller-selected query id copied into `report_royalty_params`.
    queryId: uint64
}

/// Owner-originated DNS record update or delete request.
struct (0x4eb1f0f9) FragmentUsernameItemChangeDnsRecord {
    /// Caller-selected query id echoed by `teleitem_ok`.
    queryId: uint64
    /// DNS category key.
    key: uint256
    /// Raw tail: either a single referenced DNS record cell or empty to delete the key.
    value: RemainingBitsAndRefs
}

/// Ownership assignment notification sent to a transfer target or auction winner.
struct (0x05138d91) FragmentUsernameItemOwnershipAssigned {
    /// Query id copied from transfer requests, or current logical time for auction settlement.
    queryId: uint64
    /// Previous owner address; auction settlement may use `addr_none`.
    previousOwnerAddress: address?
    /// Raw forwarded payload; auction settlement may include `FragmentUsernameItemBidInfo`.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) FragmentUsernameItemReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as uint256.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer.
struct (0xd53276db) FragmentUsernameItemExcesses {
    /// Query id copied from the transfer request.
    queryId: uint64
}

/// Royalty-params response emitted by the item.
struct (0xa8cb00ad) FragmentUsernameItemReportRoyaltyParams {
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
struct (0x370fec51) FragmentUsernameItemFillUp {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Notification emitted to the previous bidder when they are outbid.
struct (0x557cea20) FragmentUsernameItemOutbidNotification {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Acknowledgement emitted after successful auction or DNS management commands.
struct (0xa37a0983) FragmentUsernameItemOk {
    /// Query id copied from the accepted owner command.
    queryId: uint64
}

/// Refund notification emitted when a collection deploy attempt cannot initialize state.
struct (0xa43227e1) FragmentUsernameItemReturnBid {
    /// Refund query id copied from the current logical time.
    queryId: uint64
}

/// Payload embedded in auction-settlement `ownership_assigned` forward data.
struct (0x38127de1) FragmentUsernameItemBidInfo {
    /// Winning bid amount in nanotons.
    bid: coins
    /// Unix timestamp of the winning bid.
    bidTs: uint32
}

/// Internal message bodies accepted by username items.
type FragmentUsernameItemIncomingMessage =
    | FragmentUsernameItemDeploy
    | FragmentUsernameItemStartAuction
    | FragmentUsernameItemCancelAuction
    | FragmentUsernameItemTransfer
    | FragmentUsernameItemGetStaticData
    | FragmentUsernameItemGetRoyaltyParams
    | FragmentUsernameItemChangeDnsRecord

/// Internal message bodies emitted by username items.
type FragmentUsernameItemOutgoingMessage =
    | FragmentUsernameItemOwnershipAssigned
    | FragmentUsernameItemReportStaticData
    | FragmentUsernameItemExcesses
    | FragmentUsernameItemReportRoyaltyParams
    | FragmentUsernameItemFillUp
    | FragmentUsernameItemOutbidNotification
    | FragmentUsernameItemOk
    | FragmentUsernameItemReturnBid

/// Structured result returned by `get_nft_data`.
struct FragmentUsernameItemDataReply {
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
struct FragmentUsernameItemAuctionStateReply {
    /// Last bidder address, or `addr_none` before the first bid.
    bidderAddress: any_address
    /// Last bid amount in nanotons, or zero before the first bid.
    bid: coins
    /// Last bid unix timestamp, or zero before the first bid.
    bidTs: uint32
    /// Current minimum acceptable bid in nanotons.
    minBid: coins
    /// Auction end unix timestamp.
    endTime: uint32
}

/// Structured result returned by `get_telemint_auction_config`.
struct FragmentUsernameItemAuctionConfigReply {
    /// Beneficiary address, or `addr_none` when no auction is active.
    beneficiaryAddress: any_address
    /// Minimum first bid in nanotons.
    initialMinBid: coins
    /// Instant-win bid in nanotons, or zero when disabled.
    maxBid: coins
    /// Minimum bid increase percent.
    minBidStep: uint8
    /// Minimum extension window in seconds.
    minExtendTime: uint32
    /// Auction duration in seconds.
    duration: uint32
}

/// Structured result returned by `royalty_params`.
struct FragmentUsernameItemRoyaltyParamsReply {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: any_address
}

/// Structured result returned by `dnsresolve`.
struct FragmentUsernameItemDnsResolveReply {
    /// Number of bits resolved from the requested DNS subdomain.
    resolvedBits: uint32
    /// DNS record cell for the requested category, or null cell if absent.
    result: cell
}

/// Fragment username item exit-code catalog.
enum FragmentUsernameItemErrors {
    /// DNS subdomain length is not byte-aligned.
    BadSubdomainLength = 70
    /// Text payload length is invalid.
    InvalidLength = 201
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
    /// DNS record changes are allowed only from the current owner.
    ForbiddenChangeDns = 217
    /// No active auction exists.
    NoAuction = 219
    /// Auction management is allowed only from the current owner.
    ForbiddenAuction = 220
    /// Auction cancellation is forbidden after bids have arrived.
    AlreadyHasStakes = 221
    /// Auction already exists.
    AuctionAlreadyStarted = 222
    /// Auction config violates allowed bounds.
    InvalidAuctionConfig = 223
    /// Address workchain is not zero.
    IncorrectWorkchain = 333
    /// DNS subdomain does not start with the required zero byte.
    NoFirstZeroByte = 413
}

/// Return item initialization flag, index, collection, owner, and individual content.
get fun get_nft_data(): FragmentUsernameItemDataReply {
    throw 0;
}

/// Return full DNS domain slice as `domain + token_name + zero byte`.
get fun get_full_domain(): slice {
    throw 0;
}

/// Return the TeleMint token name.
get fun get_telemint_token_name(): string {
    throw 0;
}

/// Return active auction state; throws `NoAuction` when no auction is active.
get fun get_telemint_auction_state(): FragmentUsernameItemAuctionStateReply {
    throw 0;
}

/// Return active auction configuration, or zero values with `addr_none` when no auction is active.
get fun get_telemint_auction_config(): FragmentUsernameItemAuctionConfigReply {
    throw 0;
}

/// Return stored royalty parameters.
get fun royalty_params(): FragmentUsernameItemRoyaltyParamsReply {
    throw 0;
}

/// Resolve a DNS subdomain/category pair through the item's DNS record dictionary.
get fun dnsresolve(subdomain: slice, category: int): FragmentUsernameItemDnsResolveReply {
    throw 0;
}
