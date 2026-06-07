/// Getgems NFT auction v1 interface for TON-only English auctions.
contract GetgemsNftAuctionV1 {
    author: "Getgems"
    version: "1.0"
    description: "Curated Getgems NFT auction v1 interface"
    storage: GetgemsNftAuctionV1Storage
    incomingMessages: GetgemsNftAuctionV1IncomingMessage
    incomingExternal: GetgemsNftAuctionV1IncomingExternalMessage
    outgoingMessages: GetgemsNftAuctionV1OutgoingMessage
    forceAbiExport: GetgemsNftAuctionV1EmptyBid | GetgemsNftAuctionV1EmergencyRelayBox
    thrownErrors: GetgemsNftAuctionV1Errors
}

/// Fee distribution cell referenced from the auction root storage.
struct GetgemsNftAuctionV1Fees {
    /// Marketplace fee payout address.
    marketplaceFeeAddress: address
    /// Marketplace fee numerator.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty payout address.
    royaltyFeeAddress: address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
}

/// Bid state cell referenced from the auction root storage.
struct GetgemsNftAuctionV1BidState {
    /// Minimum first bid in nanotons.
    minBid: coins
    /// Instant-finish bid in nanotons, or zero when disabled.
    maxBid: coins
    /// Minimum increase over the previous bid in nanotons.
    minStep: coins
    /// Current highest bidder, or `addr_none` before the first bid.
    lastMemberAddress: address?
    /// Current highest bid in nanotons.
    lastBid: coins
    /// Unix timestamp of the current highest bid, or zero before the first bid.
    lastBidAt: uint32
    /// Unix timestamp when bidding ends.
    endTime: uint32
    /// Seconds added to endTime during anti-sniping extension.
    stepTime: uint32
    /// Extension window in seconds before endTime.
    tryStepTime: uint32
}

/// NFT state cell referenced from the auction root storage.
struct GetgemsNftAuctionV1NftState {
    /// Previous NFT owner/seller, or `addr_none` before ownership callback initialization.
    nftOwnerAddress: address?
    /// NFT item address authorized to initialize the auction.
    nftAddress: address
}

/// Persistent auction state stored in the root data cell.
struct GetgemsNftAuctionV1Storage {
    /// Auction finished flag stored as one bit.
    end: bool
    /// Marketplace address allowed to top up, repeat finalization, and relay emergency messages after end.
    marketplaceAddress: address
    /// True after external activation or NFT ownership callback initialization.
    activated: bool
    /// Deployment timestamp stored as uint32.
    createdAt: uint32
    /// True after cancellation returns the NFT to the seller.
    isCanceled: bool
    /// Referenced marketplace and royalty fee settings.
    fees: Cell<GetgemsNftAuctionV1Fees>
    /// Referenced mutable bid state.
    bids: Cell<GetgemsNftAuctionV1BidState>
    /// Referenced NFT owner and item addresses.
    nft: Cell<GetgemsNftAuctionV1NftState>
}

/// Empty internal body used for plain TON bids; bid amount is the attached message value.
struct GetgemsNftAuctionV1EmptyBid {
}

/// NFT ownership callback accepted only from the configured NFT address before initialization.
struct (0x05138d91) GetgemsNftAuctionV1OwnershipAssigned {
    /// Query id supplied by the NFT item; source skips it and does not store it.
    queryId: uint64
    /// Previous NFT owner stored as the auction seller.
    previousOwnerAddress: address?
    /// Raw standard NFT callback tail left unread by this auction source.
    forwardPayload: RemainingBitsAndRefs
}

/// Zero-op text command body; accepted strings are `cancel`, `stop`, `repeat_end_auction`, and `emergency_message`.
struct (0x00000000) GetgemsNftAuctionV1TextCommand {
    /// Raw text-comment tail after the zero opcode; `emergency_message` also carries a relay ref.
    command: RemainingBitsAndRefs
}

/// Box referenced by the `emergency_message` text command after its ASCII text tail.
struct GetgemsNftAuctionV1EmergencyRelayBox {
    /// Send mode loaded from the first 8 bits of the referenced box.
    mode: uint8
    /// Raw internal message cell forwarded through `send_raw_message`.
    message: cell
}

/// External-in body is ignored; a successful first external message only flips `activated`.
struct GetgemsNftAuctionV1ExternalActivate {
    /// Raw body bits and refs ignored by `recv_external`.
    rawBody: RemainingBitsAndRefs
}

/// NFT transfer message emitted to the NFT item on cancel and auction finalization.
struct (0x5fcc3d14) GetgemsNftAuctionV1NftTransfer {
    /// Current logical time used as the query id.
    queryId: uint64
    /// NFT recipient: seller on cancellation/no-bid finish, or highest bidder on successful finish.
    newOwnerAddress: address?
    /// Response destination; source stores the seller address here.
    responseDestination: address?
    /// Always absent in this source.
    customPayload: cell?
    /// Forwarded nanotons: zero when returning to seller, 0.03 TON when transferring to winner.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Zero-op text notification emitted for refunds, fee withdrawals, and seller profit withdrawals.
struct (0x00000000) GetgemsNftAuctionV1TextNotification {
    /// Human-readable text-comment body after the zero opcode.
    text: string
}

/// Internal message bodies accepted by Getgems NFT auction v1.
type GetgemsNftAuctionV1IncomingMessage =
    | GetgemsNftAuctionV1OwnershipAssigned
    | GetgemsNftAuctionV1TextCommand

/// External message body accepted by Getgems NFT auction v1.
type GetgemsNftAuctionV1IncomingExternalMessage = GetgemsNftAuctionV1ExternalActivate

/// Outgoing message bodies emitted by Getgems NFT auction v1 when not using emergency relay.
type GetgemsNftAuctionV1OutgoingMessage =
    | GetgemsNftAuctionV1NftTransfer
    | GetgemsNftAuctionV1TextNotification

/// Workchain and 256-bit address parts returned by source address helper getters.
struct GetgemsNftAuctionV1AddressPartsReply {
    /// Parsed workchain id, or zero when the source getter substitutes a missing address.
    workchain: int
    /// Parsed 256-bit address value, or zero when the source getter substitutes a missing address.
    addressHash: int
}

/// Fee factors returned by `get_fees_info`.
struct GetgemsNftAuctionV1FeesInfoReply {
    /// Marketplace fee numerator.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
}

/// Bid summary returned by `get_bid_info`.
struct GetgemsNftAuctionV1BidInfoReply {
    /// Minimum first bid in nanotons.
    minBid: coins
    /// Instant-finish bid in nanotons, or zero when disabled.
    maxBid: coins
    /// Minimum increase over the previous bid in nanotons.
    minStep: coins
    /// Current highest bid in nanotons.
    lastBid: coins
    /// Unix timestamp when bidding ends.
    endTime: uint32
}

/// Full auction state returned by `get_sale_data`.
struct GetgemsNftAuctionV1SaleDataReply {
    /// Fixed magic `0x415543`, ASCII `AUC`.
    magic: uint64
    /// True after cancel or finalization.
    end: bool
    /// Unix timestamp when bidding ends.
    endTime: uint32
    /// Marketplace address stored in auction state.
    marketplaceAddress: address
    /// NFT item address stored in auction state.
    nftAddress: address
    /// Seller address, or `addr_none` before ownership callback initialization.
    nftOwnerAddress: any_address
    /// Current highest bid in nanotons.
    lastBid: coins
    /// Current highest bidder, or `addr_none` before the first bid.
    lastMemberAddress: any_address
    /// Minimum increase over the previous bid in nanotons.
    minStep: coins
    /// Marketplace fee payout address.
    marketplaceFeeAddress: address
    /// Marketplace fee numerator.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty fee payout address.
    royaltyFeeAddress: address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
    /// Instant-finish bid in nanotons, or zero when disabled.
    maxBid: coins
    /// Minimum first bid in nanotons.
    minBid: coins
    /// Deployment timestamp stored as uint32.
    createdAt: uint32
    /// Unix timestamp of the current highest bid, or zero before the first bid.
    lastBidAt: uint32
    /// True after owner or marketplace cancellation.
    isCanceled: bool
}

/// Source-level exit-code catalog for Getgems NFT auction v1.
enum GetgemsNftAuctionV1Errors {
    /// Attached value is below the first-bid minimum.
    LowBid = 1000
    /// NFT ownership callback arrived after the seller was already stored.
    AlreadyInitiated = 1001
    /// NFT initialization body opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 1002
    /// Owner or marketplace command body was not a zero-op text command.
    InvalidTextCommandOpcode = 1003
    /// Owner/marketplace cancel branch did not carry the exact `cancel` text.
    InvalidCancelText = 1004
    /// Bid path was reached after the auction had already ended.
    AuctionEnded = 1005
    /// External activation was attempted after the auction was already activated.
    AlreadyActivated = 1006
}

/// Return the stored seller address as workchain/hash parts, or `(0, 0)` before initialization.
get fun get_nft_owner(): GetgemsNftAuctionV1AddressPartsReply {
    throw 0;
}

/// Return the configured NFT item address as workchain/hash parts.
get fun get_nft_addr(): GetgemsNftAuctionV1AddressPartsReply {
    throw 0;
}

/// Return the highest bidder address as workchain/hash parts; source may throw before the first bid.
get fun get_last_member(): GetgemsNftAuctionV1AddressPartsReply {
    throw 0;
}

/// Return the marketplace address as workchain/hash parts.
get fun get_mp_addr(): GetgemsNftAuctionV1AddressPartsReply {
    throw 0;
}

/// Return the marketplace fee payout address as workchain/hash parts.
get fun get_mp_fee_addr(): GetgemsNftAuctionV1AddressPartsReply {
    throw 0;
}

/// Return the royalty fee payout address as workchain/hash parts.
get fun get_royalty_fee_addr(): GetgemsNftAuctionV1AddressPartsReply {
    throw 0;
}

/// Return marketplace and royalty fee factors.
get fun get_fees_info(): GetgemsNftAuctionV1FeesInfoReply {
    throw 0;
}

/// Return bid thresholds, current bid, and auction end time.
get fun get_bid_info(): GetgemsNftAuctionV1BidInfoReply {
    throw 0;
}

/// Return the full auction state used by Getgems sale indexers.
get fun get_sale_data(): GetgemsNftAuctionV1SaleDataReply {
    throw 0;
}
