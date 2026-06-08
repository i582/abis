/// Fragment Telegram username collection contract.
contract FragmentUsernameCollection {
    author: "Telegram"
    version: "1.0"
    description: "Fragment collection interface for Telegram username TeleMint items with DNS resolver support"
    storage: FragmentCollectionStorage
    incomingMessages: FragmentUsernameCollectionIncomingMessage
    outgoingMessages: FragmentCollectionOutgoingMessage
    thrownErrors: FragmentCollectionErrors
}

/// Fragment anonymous Telegram number collection contract.
contract FragmentNumbersCollection {
    author: "Telegram"
    version: "1.0"
    description: "Fragment collection interface for anonymous Telegram number TeleMint items"
    storage: FragmentCollectionStorage
    incomingMessages: FragmentNumbersCollectionIncomingMessage
    outgoingMessages: FragmentCollectionOutgoingMessage
    thrownErrors: FragmentCollectionErrors
}

/// Fragment Telegram username TeleMint item contract.
contract FragmentUsernameItem {
    author: "Telegram"
    version: "1.0"
    description: "Fragment TeleMint item interface for Telegram usernames with auction, DNS, royalty, and TEP-62 messages"
    storage: FragmentItemStorage
    incomingMessages: FragmentUsernameItemIncomingMessage
    outgoingMessages: FragmentItemOutgoingMessage
    forceAbiExport: FragmentTelemintBidInfo
    thrownErrors: FragmentItemErrors
}

/// Fragment anonymous Telegram number TeleMint item contract.
contract FragmentNumbersItem {
    author: "Telegram"
    version: "1.0"
    description: "Fragment TeleMint item interface for anonymous Telegram numbers with auction, royalty, and TEP-62 messages"
    storage: FragmentItemStorage
    incomingMessages: FragmentNumbersItemIncomingMessage
    outgoingMessages: FragmentItemOutgoingMessage
    forceAbiExport: FragmentTelemintBidInfo
    thrownErrors: FragmentItemErrors
}

/// Root persistent collection data.
struct FragmentCollectionStorage {
    /// One-bit touch flag set by the first accepted external message.
    touched: bool
    /// Collection subwallet id checked in signed deploy requests.
    subwalletId: uint32
    /// Ed25519 public key used for signed deploy requests.
    publicKey: bits256
    /// Referenced collection metadata cell returned by `get_collection_data`.
    content: cell
    /// Referenced item code cell used to derive item addresses.
    itemCode: cell
    /// Referenced length-prefixed root domain text cell.
    fullDomain: cell
    /// Referenced default royalty parameters.
    royaltyParams: Cell<FragmentRoyaltyParams>
}

/// Root persistent item data.
struct FragmentItemStorage {
    /// Referenced immutable item config.
    config: Cell<FragmentItemConfig>
    /// Referenced runtime item state, absent before collection initialization.
    state: Cell<FragmentItemState>?
}

/// Immutable item config stored in item data.
struct FragmentItemConfig {
    /// Name hash used as the NFT item index.
    itemIndex: uint256
    /// Collection address authorized to initialize the item.
    collectionAddress: address
}

/// Initialized Fragment item state.
struct FragmentItemState {
    /// Current owner; `addr_none` is used while an initial auction has no winner.
    ownerAddress: address?
    /// Referenced content cell containing NFT content, DNS records, and token info.
    content: Cell<FragmentItemContent>
    /// Referenced active auction state and config, or absent when no auction is active.
    auction: Cell<FragmentAuction>?
    /// Referenced royalty parameters used for auction settlement.
    royaltyParams: Cell<FragmentRoyaltyParams>
}

/// Item content cell used by Fragment TeleMint items.
struct FragmentItemContent {
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// DNS record dictionary keyed by 256-bit category hash with record cells as values.
    dnsRecords: map<uint256, cell>
    /// Raw referenced token-info cell with length-prefixed name and domain text.
    tokenInfo: cell
}

/// NFT royalty payout parameters.
struct FragmentRoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Optional royalty payout address.
    destination: address?
}

/// Last accepted auction bid stored in auction state.
struct FragmentLastBid {
    /// Bidder address to receive ownership or refunds.
    bidderAddress: address
    /// Bid amount in nanotons.
    bid: coins
    /// Unix timestamp of the bid.
    bidTs: uint32
}

/// Mutable auction state.
struct FragmentAuctionState {
    /// Referenced last bid, absent before the first successful bid.
    lastBid: Cell<FragmentLastBid>?
    /// Current minimum acceptable bid in nanotons.
    minBid: coins
    /// Unix timestamp when the auction may be finalized.
    endTime: uint32
}

/// Auction configuration used for initial and restarted auctions.
struct FragmentAuctionConfig {
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
struct FragmentAuction {
    /// Referenced mutable auction state.
    state: Cell<FragmentAuctionState>
    /// Referenced auction configuration.
    config: Cell<FragmentAuctionConfig>
}

/// Signed collection deploy request for username items.
struct (0x4637289a) FragmentUsernameCollectionDeploy {
    /// Ed25519 signature over the command bytes after the signature field.
    signature: bits512
    /// Collection subwallet id.
    subwalletId: uint32
    /// Unix timestamp after which the request becomes valid.
    validSince: uint32
    /// Unix timestamp after which the request expires.
    validTill: uint32
    /// Raw deploy command tail with token name, content, auction config, and optional royalty.
    command: RemainingBitsAndRefs
}

/// Signed collection deploy request for anonymous number items.
struct (0x4637289b) FragmentNumbersCollectionDeploy {
    /// Ed25519 signature over the command bytes after the signature field.
    signature: bits512
    /// Collection subwallet id.
    subwalletId: uint32
    /// Unix timestamp after which the request becomes valid.
    validSince: uint32
    /// Unix timestamp after which the request expires.
    validTill: uint32
    /// Raw deploy command tail with token name, content, auction config, optional royalty, and optional restrictions.
    command: RemainingBitsAndRefs
}

/// Collection-to-item initialization and first-bid body.
struct (0x299a3e15) FragmentTelemintItemDeploy {
    /// First bidder address supplied by the collection.
    senderAddress: address
    /// First bid amount in nanotons.
    bid: coins
    /// Raw referenced token-info cell.
    tokenInfo: cell
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// Referenced auction configuration.
    auctionConfig: Cell<FragmentAuctionConfig>
    /// Referenced royalty parameters.
    royaltyParams: Cell<FragmentRoyaltyParams>
}

/// Owner-originated request to start a new auction.
struct (0x487a8e81) FragmentItemStartAuction {
    /// Caller-selected query id echoed by `teleitem_ok` when non-zero.
    queryId: uint64
    /// Referenced auction configuration.
    auctionConfig: Cell<FragmentAuctionConfig>
}

/// Owner-originated request to cancel an auction without bids.
struct (0x371638ae) FragmentItemCancelAuction {
    /// Caller-selected query id echoed by `teleitem_ok` when non-zero.
    queryId: uint64
}

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) FragmentItemTransfer {
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
struct (0x2fcb26a2) FragmentItemGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Royalty-params request accepted by collection and item contracts.
struct (0x693d3950) FragmentGetRoyaltyParams {
    /// Caller-selected query id copied into `report_royalty_params`.
    queryId: uint64
}

/// Owner-originated DNS record update or delete request.
struct (0x4eb1f0f9) FragmentItemChangeDnsRecord {
    /// Caller-selected query id echoed by `teleitem_ok`.
    queryId: uint64
    /// DNS category key.
    key: uint256
    /// Raw tail: either a single referenced DNS record cell or empty to delete the key.
    value: RemainingBitsAndRefs
}

/// Ownership assignment notification sent to a transfer target or auction winner.
struct (0x05138d91) FragmentItemOwnershipAssigned {
    /// Query id copied from transfer requests, or current logical time for auction settlement.
    queryId: uint64
    /// Previous owner address; auction settlement may use `addr_none`.
    previousOwnerAddress: address?
    /// Raw forwarded payload; auction settlement may include `FragmentTelemintBidInfo`.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) FragmentItemReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// NFT item index encoded as uint256.
    itemIndex: uint256
    /// Collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer.
struct (0xd53276db) FragmentItemExcesses {
    /// Query id copied from the transfer request.
    queryId: uint64
}

/// Royalty-params response emitted by collection and item contracts.
struct (0xa8cb00ad) FragmentReportRoyaltyParams {
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
struct (0x370fec51) FragmentItemFillUp {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Notification emitted to the previous bidder when they are outbid.
struct (0x557cea20) FragmentItemOutbidNotification {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Acknowledgement emitted after successful auction or DNS management commands.
struct (0xa37a0983) FragmentItemOk {
    /// Query id copied from the accepted owner command.
    queryId: uint64
}

/// Refund notification emitted when a collection deploy attempt cannot initialize state.
struct (0xa43227e1) FragmentItemReturnBid {
    /// Refund query id copied from the current logical time.
    queryId: uint64
}

/// Payload embedded in auction-settlement `ownership_assigned` forward data.
struct (0x38127de1) FragmentTelemintBidInfo {
    /// Winning bid amount in nanotons.
    bid: coins
    /// Unix timestamp of the winning bid.
    bidTs: uint32
}

/// Internal message bodies accepted by the username collection.
type FragmentUsernameCollectionIncomingMessage = FragmentUsernameCollectionDeploy

/// Internal message bodies accepted by the anonymous number collection.
type FragmentNumbersCollectionIncomingMessage =
    | FragmentNumbersCollectionDeploy
    | FragmentGetRoyaltyParams

/// Internal message bodies emitted by Fragment collections.
type FragmentCollectionOutgoingMessage = FragmentTelemintItemDeploy

/// Internal message bodies accepted by username items.
type FragmentUsernameItemIncomingMessage =
    | FragmentTelemintItemDeploy
    | FragmentItemStartAuction
    | FragmentItemCancelAuction
    | FragmentItemTransfer
    | FragmentItemGetStaticData
    | FragmentGetRoyaltyParams
    | FragmentItemChangeDnsRecord

/// Internal message bodies accepted by anonymous number items.
type FragmentNumbersItemIncomingMessage =
    | FragmentTelemintItemDeploy
    | FragmentItemStartAuction
    | FragmentItemCancelAuction
    | FragmentItemTransfer
    | FragmentItemGetStaticData
    | FragmentGetRoyaltyParams

/// Internal message bodies emitted by Fragment items.
type FragmentItemOutgoingMessage =
    | FragmentItemOwnershipAssigned
    | FragmentItemReportStaticData
    | FragmentItemExcesses
    | FragmentReportRoyaltyParams
    | FragmentItemFillUp
    | FragmentItemOutbidNotification
    | FragmentItemOk
    | FragmentItemReturnBid

/// Structured result returned by `get_collection_data`.
struct FragmentCollectionDataReply {
    /// Constant collection item index value returned by Fragment collections.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionContent: cell
    /// Collection owner address returned by the NFT collection getter.
    ownerAddress: any_address
}

/// Structured result returned by `dnsresolve`.
struct FragmentDnsResolveReply {
    /// Number of bits resolved from the requested DNS subdomain.
    resolvedBits: uint32
    /// DNS record cell or next-resolver cell.
    result: cell
}

/// Structured result returned by `get_nft_data`.
struct FragmentItemDataReply {
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
struct FragmentAuctionStateReply {
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
struct FragmentAuctionConfigReply {
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
struct FragmentRoyaltyParamsReply {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: any_address
}

/// Fragment collection exit-code catalog.
enum FragmentCollectionErrors {
    /// DNS subdomain length is not byte-aligned.
    BadSubdomainLength = 70
    /// Text payload length is invalid.
    InvalidLength = 201
    /// Signed deploy request signature is invalid.
    InvalidSignature = 202
    /// Signed deploy request subwallet id does not match storage.
    WrongSubwalletId = 203
    /// Signed deploy request is not valid yet.
    NotYetValidSignature = 204
    /// Signed deploy request is expired.
    ExpiredSignature = 205
    /// Incoming deploy value is below the auction minimum.
    NotEnoughFunds = 206
    /// Plain top-up transfer does not contain the required comment.
    WrongTopupComment = 207
    /// Incoming internal message opcode is not supported.
    UnknownOp = 208
    /// NFT content is not on-chain content.
    ExpectedOnchainContent = 212
    /// External touch was already accepted.
    ForbiddenTouch = 218
    /// Forced sender restriction does not match the inbound sender.
    InvalidSenderAddress = 224
    /// Address workchain is not zero.
    IncorrectWorkchain = 333
    /// DNS subdomain does not start with the required zero byte.
    NoFirstZeroByte = 413
}

/// Fragment item exit-code catalog.
enum FragmentItemErrors {
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

/// Return collection metadata and zero owner address.
get fun get_collection_data(): FragmentCollectionDataReply {
    throw 0;
}

/// Return deterministic item address for an item index.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return full NFT content from the individual item content.
get fun get_nft_content(index: int, individualContent: cell): cell {
    throw 0;
}

/// Return full root domain slice for DNS-enabled collections and items.
get fun get_full_domain(): slice {
    throw 0;
}

/// Resolve a DNS subdomain/category pair.
get fun dnsresolve(subdomain: slice, category: int): FragmentDnsResolveReply {
    throw 0;
}
