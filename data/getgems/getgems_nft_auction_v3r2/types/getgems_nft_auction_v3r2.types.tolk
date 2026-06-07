/// Getgems NFT auction V3R2 interface for TON-denominated auctions.
contract GetgemsNftAuctionV3R2 {
    author: "Getgems"
    version: "3.2"
    description: "Curated Getgems NFT auction V3R2 interface"
    storage: GetgemsNftAuctionV3R2Storage
    incomingMessages: GetgemsNftAuctionV3R2IncomingMessage
    incomingExternal: GetgemsNftAuctionV3R2IncomingExternalMessage
    outgoingMessages: GetgemsNftAuctionV3R2OutgoingMessage
    forceAbiExport: GetgemsNftAuctionV3R2Bid | GetgemsNftAuctionV3R2ExternalActivation | GetgemsNftAuctionV3R2EmergencyRelayBox
    thrownErrors: GetgemsNftAuctionV3R2Errors
}

/// Fee configuration cell referenced from the auction root storage.
struct GetgemsNftAuctionV3R2Fees {
    /// Marketplace fee payout address.
    marketplaceFeeAddress: address
    /// Marketplace fee numerator used by `math::get_percent`.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator used by `math::get_percent`.
    marketplaceFeeBase: uint32
    /// Royalty fee payout address.
    royaltyFeeAddress: address
    /// Royalty fee numerator used by `math::get_percent`.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator used by `math::get_percent`.
    royaltyFeeBase: uint32
}

/// Constant deployment parameters referenced from the auction root storage.
struct GetgemsNftAuctionV3R2Constants {
    /// Nanotons subtracted from a returned bid before refunding the previous bidder.
    subGasPriceFromBid: int32
    /// Marketplace address allowed to deploy, cancel, stop, repeat ending, and relay emergency messages.
    marketplaceAddress: address
    /// Minimum first bid, serialized with the TON `Coins` varuint layout.
    minBid: coins
    /// Buy-now bid threshold; zero disables immediate auction finalization.
    maxBid: coins
    /// Minimum bid step stored as `Coins` but used by source as a percent increment.
    minStep: coins
    /// Seconds added to the auction end when a bid arrives near the end.
    stepTime: uint32
    /// NFT item address authorized to initialize the auction through `ownership_assigned`.
    nftAddress: address
    /// Deployment timestamp stored as uint32.
    createdAt: uint32
}

/// Persistent auction state; nullable addresses are encoded as `addr_none` before initialization/bids.
struct GetgemsNftAuctionV3R2Storage {
    /// True after cancellation or successful auction finalization.
    end: bool
    /// True after the first external activation or NFT ownership callback.
    activated: bool
    /// True when the owner/marketplace cancellation path returned the NFT.
    isCanceled: bool
    /// Last bidder address, or null before the first bid.
    lastMember: address?
    /// Last bid amount in nanotons, or zero before the first bid.
    lastBid: coins
    /// Unix timestamp of the last accepted bid, or zero before the first bid.
    lastBidAt: uint32
    /// Current auction end unix timestamp.
    endTime: uint32
    /// NFT owner/seller address, or null before the NFT callback initializes the auction.
    nftOwner: address?
    /// Referenced marketplace and royalty fee configuration.
    fees: Cell<GetgemsNftAuctionV3R2Fees>
    /// Referenced immutable auction constants supplied at deployment.
    constants: Cell<GetgemsNftAuctionV3R2Constants>
}

/// Unstructured bid body; bid amount is the attached TON value and source does not parse the body.
struct GetgemsNftAuctionV3R2Bid {
    /// Raw body bits and refs for non-command bid messages; often empty.
    payload: RemainingBitsAndRefs
}

/// NFT ownership callback accepted only from the configured NFT item before initialization.
struct (0x05138d91) GetgemsNftAuctionV3R2OwnershipAssigned {
    /// Query id supplied by the NFT transfer callback; source skips it.
    queryId: uint64
    /// Previous NFT owner stored as the seller address.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves remaining bits and refs unread.
    forwardPayload: RemainingBitsAndRefs
}

/// Zero-op text command body accepted for cancel, stop/finish, deploy, repeat-end, and emergency flows.
struct (0x00000000) GetgemsNftAuctionV3R2TextCommand {
    /// Raw text-comment tail; source accepts exact ASCII tails such as `cancel`, `stop`, `finish`, and `deploy`.
    command: RemainingBitsAndRefs
}

/// External activation body accepted only while storage `activated` is false; source does not parse it.
struct GetgemsNftAuctionV3R2ExternalActivation {
    /// Raw external body ignored by the activation branch.
    payload: RemainingBitsAndRefs
}

/// Referenced emergency relay box after the `emergency_message` text command tail.
struct GetgemsNftAuctionV3R2EmergencyRelayBox {
    /// Send mode loaded from the relay box and passed to `send_raw_message`.
    mode: uint8
    /// Raw outbound message cell supplied by the marketplace.
    message: cell
}

/// NFT transfer message emitted to return or settle the auctioned NFT.
struct (0x5fcc3d14) GetgemsNftAuctionV3R2NftTransfer {
    /// Current logical time used as outgoing query id.
    queryId: uint64
    /// NFT recipient: seller on cancellation, last bidder on successful settlement.
    newOwnerAddress: address
    /// Response destination copied from the caller that triggered cancel/settlement.
    responseDestination: address
    /// Always absent in this source.
    customPayload: cell?
    /// Zero on cancellation, or 0.01 TON when transferring to the winning bidder.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Zero-op text notification emitted with TON refunds, fee payouts, royalty payouts, and seller profit.
struct (0x00000000) GetgemsNftAuctionV3R2TextNotification {
    /// Raw text-comment tail, for example `Marketplace fee`, `Royalty`, `Profit`, or outbid/cancel text.
    text: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Getgems NFT auction V3R2.
type GetgemsNftAuctionV3R2IncomingMessage =
    | GetgemsNftAuctionV3R2OwnershipAssigned
    | GetgemsNftAuctionV3R2TextCommand

/// External-in message bodies accepted by Getgems NFT auction V3R2.
type GetgemsNftAuctionV3R2IncomingExternalMessage = GetgemsNftAuctionV3R2TextCommand

/// Outgoing message bodies emitted by Getgems NFT auction V3R2 with static ABI.
type GetgemsNftAuctionV3R2OutgoingMessage =
    | GetgemsNftAuctionV3R2NftTransfer
    | GetgemsNftAuctionV3R2TextNotification

/// Structured result returned by `get_sale_data`.
struct GetgemsNftAuctionV3R2SaleDataReply {
    /// Fixed magic `0x415543`, ASCII `AUC`.
    magic: uint64
    /// True after cancellation or successful auction finalization.
    end: bool
    /// Current auction end unix timestamp.
    endTime: uint32
    /// Marketplace address stored in the constants cell.
    marketplace: address
    /// NFT item address stored in the constants cell.
    nft: address
    /// NFT owner/seller stack address, or `addr_none` before initialization.
    owner: any_address
    /// Last bid amount in nanotons.
    lastBid: coins
    /// Last bidder stack address, or `addr_none` before the first bid.
    lastMember: any_address
    /// Minimum bid step returned as a stack integer; source stores it with `Coins` but uses it as a percent.
    minStep: int
    /// Marketplace fee payout address.
    marketFeeAddress: address
    /// Marketplace fee numerator.
    mpFeeFactor: uint32
    /// Marketplace fee denominator.
    mpFeeBase: uint32
    /// Royalty fee payout address.
    royaltyAddress: address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
    /// Buy-now bid threshold in nanotons; zero disables immediate settlement.
    maxBid: coins
    /// Minimum first bid in nanotons.
    minBid: coins
    /// Deployment timestamp stored in constants.
    createdAt: uint32
    /// Unix timestamp of the last accepted bid.
    lastBidAt: uint32
    /// True when the cancellation path returned the NFT to the seller.
    isCanceled: bool
}

/// Callsite-proven exit-code catalog for Getgems NFT auction V3R2.
enum GetgemsNftAuctionV3R2Errors {
    /// Sender is not authorized for cancel/stop.
    UnauthorizedAddress = 403
    /// Bid amount is below the required minimum.
    LowBid = 1000
    /// NFT ownership callback arrived after the auction was already initialized.
    AlreadyInitiated = 1001
    /// NFT callback opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 1002
    /// Auction was already cancelled/ended or cannot accept more bids.
    AlreadyExecuted = 1005
    /// Attached or available TON is below the required one-ton reserve.
    NotEnoughTons = 1008
    /// Cancellation is forbidden after a bid has been accepted.
    AlreadyHasBid = 1009
    /// Stop/finish was requested before the auction end time.
    AuctionInProgress = 1010
    /// External-in message is not a supported stop/finish command after activation.
    UnknownOperation = 65535
}

/// Return auction state, bid state, fee parameters, and cancellation status.
get fun get_sale_data(): GetgemsNftAuctionV3R2SaleDataReply {
    throw 0;
}
