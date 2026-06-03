/// Getgems NFT auction V3R3 interface for TON-denominated auctions.
contract GetgemsNftAuctionV3R3 {
    author: "Getgems"
    version: "3.3"
    description: "Curated Getgems NFT auction V3R3 interface"
    storage: GetgemsNftAuctionV3R3Storage
    incomingMessages: GetgemsNftAuctionV3R3IncomingMessage
    incomingExternal: GetgemsNftAuctionV3R3IncomingExternalMessage
    outgoingMessages: GetgemsNftAuctionV3R3OutgoingMessage
    forceAbiExport: GetgemsNftAuctionV3R3EmptyBid
}

/// Fee address cell referenced from root auction storage.
struct GetgemsNftAuctionV3R3Fees {
    /// Marketplace fee payout address loaded from `fees_cell`.
    marketplaceFeeAddress: address?
    /// Royalty payout address loaded after the marketplace fee address.
    royaltyAddress: address?
}

/// Constant auction parameters referenced from root auction storage.
struct GetgemsNftAuctionV3R3Constants {
    /// Marketplace address authorized for administrative commands.
    marketplaceAddress: address
    /// Minimum first bid in nanotons.
    minBid: coins
    /// Buy-now bid ceiling in nanotons; zero disables the ceiling.
    maxBid: coins
    /// Minimum bid step percent delta stored as a 7-bit unsigned integer.
    minStep: uint7
    /// Anti-sniping extension time stored as a 17-bit unsigned integer.
    stepTime: uint17
    /// NFT item address authorized to initialize the auction.
    nftAddress: address
    /// Auction creation timestamp stored as uint32.
    createdAt: uint32
}

/// Persistent auction state; activation is derived from whether `nftOwnerAddress` is not `addr_none`.
struct GetgemsNftAuctionV3R3Storage {
    /// True after cancellation or successful completion.
    isEnded: bool
    /// True when the owner or marketplace cancelled before any bid.
    isCanceled: bool
    /// Current highest bidder, or `addr_none` before the first bid.
    lastMemberAddress: address?
    /// Current highest bid in nanotons.
    lastBid: coins
    /// Unix timestamp of the latest accepted bid.
    lastBidAt: uint32
    /// Unix timestamp after which the auction can be ended.
    endTime: uint32
    /// NFT owner recorded from `ownership_assigned`; null before activation.
    nftOwnerAddress: address?
    /// Last query id parsed from a non-text bid body.
    lastQueryId: uint64
    /// Marketplace fee numerator used with the fee base.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator; zero makes marketplace fee zero.
    marketplaceFeeBase: uint32
    /// Royalty fee numerator used with the fee base.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator; zero makes royalty fee zero.
    royaltyFeeBase: uint32
    /// Referenced cell containing marketplace and royalty fee addresses.
    fees: Cell<GetgemsNftAuctionV3R3Fees>
    /// Referenced cell containing immutable auction parameters.
    constants: Cell<GetgemsNftAuctionV3R3Constants>
}

/// Empty internal body accepted as a bid with query id zero when bidding is open.
struct GetgemsNftAuctionV3R3EmptyBid {
}

/// NFT ownership callback accepted only from the configured NFT address before activation.
struct (0x05138d91) GetgemsNftAuctionV3R3OwnershipAssigned {
    /// Query id supplied by the NFT transfer callback; source skips it.
    queryId: uint64
    /// Previous NFT owner stored as the auction seller.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves it unread.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal command branch for cancellation; optional query id or extra bits are ignored by the source.
struct (0x00000001) GetgemsNftAuctionV3R3Cancel {
    /// Raw tail after the command opcode; first 64 bits are parsed as query id when present.
    tail: RemainingBitsAndRefs
}

/// Internal or external command branch for ending the auction.
struct (0x00000002) GetgemsNftAuctionV3R3Stop {
    /// Raw tail after the command opcode; first 64 bits are parsed as query id when present.
    tail: RemainingBitsAndRefs
}

/// Internal no-op command that only accepts attached coins.
struct (0x00000003) GetgemsNftAuctionV3R3DeployAccept {
    /// Raw tail after the command opcode; first 64 bits are parsed as query id when present.
    tail: RemainingBitsAndRefs
}

/// Marketplace emergency command that relays a full raw message from a referenced cell.
struct (0x0000022b) GetgemsNftAuctionV3R3EmergencyRawSend {
    /// Referenced relay payload containing send mode and full message cell.
    payload: Cell<GetgemsNftAuctionV3R3EmergencyRawSendPayload>
}

/// Payload for the marketplace emergency raw-message relay.
struct GetgemsNftAuctionV3R3EmergencyRawSendPayload {
    /// Send mode; source rejects values with bit 32 set.
    mode: uint8
    /// Full raw message cell passed directly to `send_raw_message`.
    message: cell
}

/// Text-comment body used for outgoing fee/refund comments and exact incoming text commands.
struct (0x00000000) GetgemsNftAuctionV3R3TextComment {
    /// UTF-8 comment bytes after the zero opcode; source recognizes cancel, stop, finish, and deploy on input.
    text: RemainingBitsAndRefs
}

/// NFT transfer message emitted to the NFT item on cancel or completion.
struct (0x5fcc3d14) GetgemsNftAuctionV3R3NftTransfer {
    /// Query id generated from current logical time.
    queryId: uint64
    /// Seller on cancellation, or highest bidder on completion.
    newOwnerAddress: address
    /// Response destination: command sender for internal endings or seller for external endings.
    responseAddress: address
    /// Always absent in this source.
    customPayload: cell?
    /// Zero on cancellation and one nanotons on successful completion.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies with structured opcode branches.
type GetgemsNftAuctionV3R3IncomingMessage =
    | GetgemsNftAuctionV3R3OwnershipAssigned
    | GetgemsNftAuctionV3R3Cancel
    | GetgemsNftAuctionV3R3Stop
    | GetgemsNftAuctionV3R3DeployAccept
    | GetgemsNftAuctionV3R3EmergencyRawSend
    | GetgemsNftAuctionV3R3TextComment

/// External message body accepted by the public external stop branch.
type GetgemsNftAuctionV3R3IncomingExternalMessage = GetgemsNftAuctionV3R3Stop

/// Outgoing message bodies emitted by Getgems NFT auction V3R3.
type GetgemsNftAuctionV3R3OutgoingMessage =
    | GetgemsNftAuctionV3R3NftTransfer
    | GetgemsNftAuctionV3R3TextComment

/// Structured result returned by `get_sale_data`.
struct GetgemsNftAuctionV3R3SaleDataReply {
    /// Fixed magic `0x415543`, ASCII `AUC`.
    magic: uint64
    /// True after cancellation or successful completion.
    isEnded: bool
    /// Unix timestamp after which the auction can be ended.
    endTime: uint32
    /// Marketplace address stored in constants.
    marketplaceAddress: address
    /// NFT item address stored in constants.
    nftAddress: address
    /// Seller address, or `addr_none` before the NFT ownership callback initializes the auction.
    nftOwnerAddress: any_address
    /// Current highest bid in nanotons.
    lastBid: coins
    /// Highest bidder address, or `addr_none` before the first bid.
    lastMemberAddress: any_address
    /// Minimum bid step percent delta.
    minStep: uint7
    /// Marketplace fee payout address.
    marketplaceFeeAddress: any_address
    /// Marketplace fee numerator.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty payout address.
    royaltyAddress: any_address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
    /// Buy-now bid ceiling in nanotons; zero disables the ceiling.
    maxBid: coins
    /// Minimum first bid in nanotons.
    minBid: coins
    /// Auction creation timestamp.
    createdAt: uint32
    /// Unix timestamp of the latest accepted bid.
    lastBidAt: uint32
    /// True when cancellation completed before any bid.
    isCanceled: bool
}

/// Structured result returned by the V3R3-specific `get_auction_data`.
struct GetgemsNftAuctionV3R3AuctionDataReply {
    /// True after the NFT ownership callback initializes the auction.
    isActivated: bool
    /// True after cancellation or successful completion.
    isEnded: bool
    /// Unix timestamp after which the auction can be ended.
    endTime: uint32
    /// Marketplace address stored in constants.
    marketplaceAddress: address
    /// NFT item address stored in constants.
    nftAddress: address
    /// Seller address, or `addr_none` before activation.
    nftOwnerAddress: any_address
    /// Current highest bid in nanotons.
    lastBid: coins
    /// Highest bidder address, or `addr_none` before the first bid.
    lastMemberAddress: any_address
    /// Minimum bid step percent delta.
    minStep: uint7
    /// Marketplace fee payout address.
    marketplaceFeeAddress: any_address
    /// Marketplace fee numerator.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty payout address.
    royaltyAddress: any_address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
    /// Buy-now bid ceiling in nanotons; zero disables the ceiling.
    maxBid: coins
    /// Current next minimum bid when there is a bid, otherwise the configured first bid.
    minBid: coins
    /// Auction creation timestamp.
    createdAt: uint32
    /// Unix timestamp of the latest accepted bid.
    lastBidAt: uint32
    /// True when cancellation completed before any bid.
    isCanceled: bool
    /// Anti-sniping extension time in seconds.
    stepTime: uint17
    /// Last query id parsed from a non-text bid body.
    lastQueryId: uint64
}

/// Source-level exit-code catalog for Getgems NFT auction V3R3.
enum GetgemsNftAuctionV3R3Errors {
    /// Sender is not authorized for the command.
    UnauthorizedAddress = 403
    /// Bid or externally ended profit is below the required threshold.
    LowBid = 1000
    /// NFT ownership callback attempted to initialize an already initialized auction.
    AlreadyInitiated = 1001
    /// NFT callback opcode was not `ownership_assigned`.
    InvalidOwnershipAssigned = 1002
    /// Defined in `exit-codes.func`; no source throw site was found in V3R3.
    NotMessage = 1003
    /// Emergency relay is not allowed in the current active/cancel state.
    NotCancel = 1004
    /// Auction is already ended, cancelled, or past end time in a rejecting branch.
    AuctionEnded = 1005
    /// Defined in `exit-codes.func`; no source throw site was found in V3R3.
    AlreadyActivated = 1006
    /// Defined in `exit-codes.func`; no source throw site was found in V3R3.
    CannotCancelEnded = 1007
    /// Command attached less than the required 0.1 TON.
    LowAmount = 1008
    /// Cancellation is forbidden after a bid exists.
    CannotCancelWithBid = 1009
    /// Stop command was sent before end time.
    CannotStopBeforeEndTime = 1010
    /// Marketplace and royalty fee factors leave no positive seller profit.
    NonProfitableFees = 1011
    /// Emergency relay send mode includes forbidden bit 32.
    BadEmergencySendMode = 1012
    /// Emergency relay is too close to end time or the latest bid time.
    LastBidTooClose = 1013
    /// Auction duration remaining exceeds 20 days.
    AuctionDurationTooLong = 1014
    /// Command or bid requires an activated auction.
    NotActivatedYet = 1015
    /// External message opcode is not supported.
    UnknownExternalOperation = 65535
}

/// Return legacy auction state, fee, and royalty data.
get fun get_sale_data(): GetgemsNftAuctionV3R3SaleDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftAuctionV3R3Errors.UnauthorizedAddress;
    assert (true) throw GetgemsNftAuctionV3R3Errors.LowBid;
    assert (true) throw GetgemsNftAuctionV3R3Errors.AlreadyInitiated;
    assert (true) throw GetgemsNftAuctionV3R3Errors.InvalidOwnershipAssigned;
    assert (true) throw GetgemsNftAuctionV3R3Errors.NotMessage;
    assert (true) throw GetgemsNftAuctionV3R3Errors.NotCancel;
    assert (true) throw GetgemsNftAuctionV3R3Errors.AuctionEnded;
    assert (true) throw GetgemsNftAuctionV3R3Errors.AlreadyActivated;
    assert (true) throw GetgemsNftAuctionV3R3Errors.CannotCancelEnded;
    assert (true) throw GetgemsNftAuctionV3R3Errors.LowAmount;
    assert (true) throw GetgemsNftAuctionV3R3Errors.CannotCancelWithBid;
    assert (true) throw GetgemsNftAuctionV3R3Errors.CannotStopBeforeEndTime;
    assert (true) throw GetgemsNftAuctionV3R3Errors.NonProfitableFees;
    assert (true) throw GetgemsNftAuctionV3R3Errors.BadEmergencySendMode;
    assert (true) throw GetgemsNftAuctionV3R3Errors.LastBidTooClose;
    assert (true) throw GetgemsNftAuctionV3R3Errors.AuctionDurationTooLong;
    assert (true) throw GetgemsNftAuctionV3R3Errors.NotActivatedYet;
    assert (true) throw GetgemsNftAuctionV3R3Errors.UnknownExternalOperation;
    return {
        magic: 0x415543,
        isEnded: false,
        endTime: 0,
        marketplaceAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftOwnerAddress: createAddressNone(),
        lastBid: 0,
        lastMemberAddress: createAddressNone(),
        minStep: 0,
        marketplaceFeeAddress: createAddressNone(),
        marketplaceFeeFactor: 0,
        marketplaceFeeBase: 0,
        royaltyAddress: createAddressNone(),
        royaltyFeeFactor: 0,
        royaltyFeeBase: 0,
        maxBid: 0,
        minBid: 0,
        createdAt: 0,
        lastBidAt: 0,
        isCanceled: false,
    };
}

/// Return V3R3 auction state, including activation, step time, and last query id.
get fun get_auction_data(): GetgemsNftAuctionV3R3AuctionDataReply {
    return {
        isActivated: false,
        isEnded: false,
        endTime: 0,
        marketplaceAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftOwnerAddress: createAddressNone(),
        lastBid: 0,
        lastMemberAddress: createAddressNone(),
        minStep: 0,
        marketplaceFeeAddress: createAddressNone(),
        marketplaceFeeFactor: 0,
        marketplaceFeeBase: 0,
        royaltyAddress: createAddressNone(),
        royaltyFeeFactor: 0,
        royaltyFeeBase: 0,
        maxBid: 0,
        minBid: 0,
        createdAt: 0,
        lastBidAt: 0,
        isCanceled: false,
        stepTime: 0,
        lastQueryId: 0,
    };
}
