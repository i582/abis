/// Getgems NFT auction V2 interface with storage, text commands, NFT assignment, and auction settlement messages.
contract GetgemsNftAuctionV2 {
    author: "Getgems"
    version: "2.0"
    description: "Curated Getgems NFT auction V2 interface"
    storage: GetgemsNftAuctionV2Storage
    incomingMessages: GetgemsNftAuctionV2IncomingMessage
    incomingExternal: GetgemsNftAuctionV2IncomingExternalMessage
    outgoingMessages: GetgemsNftAuctionV2OutgoingMessage
    forceAbiExport: GetgemsNftAuctionV2EmergencyRelayTail
}

/// Referenced fee configuration cell used for marketplace and royalty payouts.
struct GetgemsNftAuctionV2Fees {
    /// Address receiving the marketplace fee when an auction settles with a bid.
    marketFeeAddress: address
    /// Marketplace fee numerator used by the source percent helper.
    mpFeeFactor: uint32
    /// Marketplace fee denominator used by the source percent helper.
    mpFeeBase: uint32
    /// Address receiving the royalty fee when an auction settles with a bid.
    royaltyAddress: address
    /// Royalty fee numerator used by the source percent helper.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator used by the source percent helper.
    royaltyFeeBase: uint32
}

/// Referenced immutable auction configuration cell.
struct GetgemsNftAuctionV2Constants {
    /// Nanotons subtracted from an outbid refund for bid-processing gas.
    subGasPriceFromBid: int32
    /// Marketplace address authorized for deploy acceptance and ended-auction recovery commands.
    marketplace: address
    /// Minimum first bid amount in nanotons.
    minBid: coins
    /// Buy-now bid threshold in nanotons; zero disables the max-bid shortcut.
    maxBid: coins
    /// Minimum absolute increment over the previous bid in nanotons.
    minStep: coins
    /// Seconds added to end time when a valid bid arrives near the end.
    stepTime: uint32
    /// NFT item address assigned to this auction.
    nft: address
    /// Auction creation timestamp.
    createdAt: uint32
}

/// Persistent auction data cell with two referenced configuration cells.
struct GetgemsNftAuctionV2Storage {
    /// True after cancellation or final settlement.
    end: bool
    /// True after external activation or NFT ownership assignment.
    activated: bool
    /// True only when the auction was canceled by owner or marketplace.
    isCanceled: bool
    /// Current highest bidder; `addr_none` before the first bid.
    lastMember: address?
    /// Current highest bid amount in nanotons.
    lastBid: coins
    /// Timestamp of the current highest bid.
    lastBidAt: uint32
    /// Current auction end timestamp.
    endTime: uint32
    /// NFT owner that should receive proceeds or returned NFT; `addr_none` before assignment.
    nftOwner: address?
    /// Referenced fee configuration cell.
    fees: Cell<GetgemsNftAuctionV2Fees>
    /// Referenced auction constants cell.
    constants: Cell<GetgemsNftAuctionV2Constants>
}

/// Opcode-0 text command body; accepted values are exact text comments documented in research.
struct (0x00000000) GetgemsNftAuctionV2TextCommand {
    /// Raw UTF-8 text tail such as `cancel`, `stop`, `finish`, `deploy`, or recovery commands.
    comment: RemainingBitsAndRefs
}

/// Emergency command payload referenced after the `emergency_message` text comment.
struct GetgemsNftAuctionV2EmergencyRelayTail {
    /// Send mode used for the relayed referenced message.
    mode: uint8
    /// Raw referenced message cell relayed unchanged by the contract.
    message: cell
}

/// TEP-62 ownership notification accepted only from the configured NFT address.
struct (0x05138d91) GetgemsNftAuctionV2OwnershipAssigned {
    /// Query id skipped by the source parser.
    queryId: uint64
    /// Previous NFT owner stored as auction owner.
    previousOwnerAddress: address
    /// Raw forwarded payload ignored by this auction version.
    forwardPayload: RemainingBitsAndRefs
}

/// Raw external body that activates the auction; the source does not parse fields.
struct GetgemsNftAuctionV2ActivateExternal {
    /// Entire external-in body, accepted only while `activated` is false.
    rawBody: RemainingBitsAndRefs
}

/// TEP-62 NFT transfer body emitted when returning or awarding the NFT.
struct (0x5fcc3d14) GetgemsNftAuctionV2NftTransfer {
    /// Contract logical time used as query id by the source.
    queryId: uint64
    /// NFT recipient: original owner on return, or highest bidder on settlement.
    newOwnerAddress: address
    /// Response destination copied from the sender that triggered cancel or settlement.
    responseDestination: address
    /// Optional custom payload; V2 always emits `null`.
    customPayload: cell?
    /// Nanotons forwarded to the NFT recipient notification.
    forwardTonAmount: coins
    /// Raw TEP-62 forward payload tail; V2 emits the empty inline variant.
    forwardPayload: RemainingBitsAndRefs
}

/// Opcode-0 outgoing text-comment body for bid refunds, fees, royalties, and owner profit.
struct (0x00000000) GetgemsNftAuctionV2TextComment {
    /// Raw UTF-8 comment tail selected by the source send site.
    comment: RemainingBitsAndRefs
}

/// Internal message bodies parsed by Getgems NFT auction V2.
type GetgemsNftAuctionV2IncomingMessage =
    | GetgemsNftAuctionV2TextCommand
    | GetgemsNftAuctionV2OwnershipAssigned

/// External-in body accepted by Getgems NFT auction V2.
type GetgemsNftAuctionV2IncomingExternalMessage = GetgemsNftAuctionV2ActivateExternal

/// Internal message bodies emitted by Getgems NFT auction V2.
type GetgemsNftAuctionV2OutgoingMessage =
    | GetgemsNftAuctionV2NftTransfer
    | GetgemsNftAuctionV2TextComment

/// Structured result returned by `get_sale_data`.
struct GetgemsNftAuctionV2SaleDataReply {
    /// Magic constant `0x415543` identifying auction data.
    magic: uint64
    /// True after cancellation or final settlement.
    end: bool
    /// Current auction end timestamp.
    endTime: uint32
    /// Marketplace address stored in constants.
    marketplace: address
    /// NFT item address stored in constants.
    nft: address
    /// NFT owner address; null before ownership assignment.
    owner: address?
    /// Current highest bid amount in nanotons.
    lastBid: coins
    /// Current highest bidder; null before first bid.
    lastMember: address?
    /// Minimum absolute increment over the previous bid in nanotons.
    minStep: coins
    /// Address receiving marketplace fee.
    marketFeeAddress: address
    /// Marketplace fee numerator.
    mpFeeFactor: uint32
    /// Marketplace fee denominator.
    mpFeeBase: uint32
    /// Address receiving royalty fee.
    royaltyAddress: address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
    /// Buy-now bid threshold in nanotons; zero disables the shortcut.
    maxBid: coins
    /// Minimum first bid amount in nanotons.
    minBid: coins
    /// Auction creation timestamp.
    createdAt: uint32
    /// Timestamp of the current highest bid.
    lastBidAt: uint32
    /// True only when the auction was canceled.
    isCanceled: bool
}

/// V2 exit-code catalog from actually thrown source branches.
enum GetgemsNftAuctionV2Errors {
    /// Cancel or stop sender is not authorized for the current auction state.
    UnauthorizedAddress = 403
    /// Bid amount is below the first-bid or next-bid threshold.
    LowBid = 1000
    /// NFT ownership assignment was attempted after owner initialization.
    AlreadyInitiated = 1001
    /// NFT sender did not provide the required `ownership_assigned` opcode.
    InvalidOpExpectOwnershipAssigned = 1002
    /// Auction is already ended, canceled, or past its end time for this action.
    AlreadyExecuted = 1005
    /// External activation was attempted after activation.
    AlreadyActivated = 1006
    /// Cancel or stop command attached less than one TON.
    NotEnoughTons = 1008
}

/// Return auction state, fee settings, bid limits, and timestamps.
get fun get_sale_data(): GetgemsNftAuctionV2SaleDataReply {
    // ABI-export scaffolding: constant assertions make every source-thrown error variant visible in thrown_errors.
    assert (true) throw GetgemsNftAuctionV2Errors.UnauthorizedAddress;
    assert (true) throw GetgemsNftAuctionV2Errors.LowBid;
    assert (true) throw GetgemsNftAuctionV2Errors.AlreadyInitiated;
    assert (true) throw GetgemsNftAuctionV2Errors.InvalidOpExpectOwnershipAssigned;
    assert (true) throw GetgemsNftAuctionV2Errors.AlreadyExecuted;
    assert (true) throw GetgemsNftAuctionV2Errors.AlreadyActivated;
    assert (true) throw GetgemsNftAuctionV2Errors.NotEnoughTons;
    return {
        magic: 0x415543,
        end: false,
        endTime: 0,
        marketplace: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nft: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        owner: null,
        lastBid: 0,
        lastMember: null,
        minStep: 0,
        marketFeeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        mpFeeFactor: 0,
        mpFeeBase: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        royaltyFeeFactor: 0,
        royaltyFeeBase: 0,
        maxBid: 0,
        minBid: 0,
        createdAt: 0,
        lastBidAt: 0,
        isCanceled: false,
    };
}
