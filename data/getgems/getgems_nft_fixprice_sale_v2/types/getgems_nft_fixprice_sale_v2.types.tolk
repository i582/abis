/// Getgems fixed-price NFT sale v2 interface for TON-only listings.
contract GetgemsNftFixpriceSaleV2 {
    author: "Getgems"
    version: "2.0"
    description: "Curated Getgems fixed-price NFT sale v2 interface"
    storage: GetgemsNftFixpriceSaleV2Storage
    incomingMessages: GetgemsNftFixpriceSaleV2IncomingMessage
    outgoingMessages: GetgemsNftFixpriceSaleV2OutgoingMessage
    forceAbiExport: GetgemsNftFixpriceSaleV2EmptyBuy
}

/// Fee distribution cell referenced from the root sale storage.
struct GetgemsNftFixpriceSaleV2Fees {
    /// Marketplace fee payout address used by every successful purchase.
    marketplaceFeeAddress: address
    /// Marketplace fee amount in nanotons.
    marketplaceFee: coins
    /// Royalty payout address; source skips royalty transfer when this is `addr_none`.
    royaltyAddress: address?
    /// Royalty amount in nanotons.
    royaltyAmount: coins
}

/// Persistent sale state; `nftOwnerAddress = addr_none` marks the pre-initialized deployment state.
struct GetgemsNftFixpriceSaleV2Storage {
    /// Completion flag stored as one bit; completed sales reject all non-bounced internal messages.
    isComplete: bool
    /// Unix timestamp supplied at deployment, stored as uint32.
    createdAt: uint32
    /// Marketplace address allowed to top up the uninitialized sale and cancel initialized sales.
    marketplaceAddress: address
    /// NFT item address authorized to initialize the sale through `ownership_assigned`.
    nftAddress: address
    /// Current NFT owner before purchase; null until the NFT callback initializes the sale.
    nftOwnerAddress: address?
    /// Full sale price in nanotons, excluding the required one-ton gas reserve.
    fullPrice: coins
    /// Referenced fee and royalty amounts paid during successful purchase.
    fees: Cell<GetgemsNftFixpriceSaleV2Fees>
}

/// Empty internal message body; when initialized, source treats it as a buy request with query id zero.
struct GetgemsNftFixpriceSaleV2EmptyBuy {
}

/// NFT ownership callback accepted only from the configured NFT address before sale initialization.
struct (0x05138d91) GetgemsNftFixpriceSaleV2OwnershipAssigned {
    /// Query id supplied by the NFT transfer callback; source parses it but does not store it.
    queryId: uint64
    /// Previous owner address stored as the seller address.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves any remaining bits and refs unread.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal command that only accepts attached coins and leaves sale state unchanged.
struct (0x00000001) GetgemsNftFixpriceSaleV2AcceptCoins {
    /// Caller-selected query id parsed before the no-op branch returns.
    queryId: uint64
}

/// Internal command that purchases the NFT when enough nanotons are attached.
struct (0x00000002) GetgemsNftFixpriceSaleV2Buy {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
}

/// Internal command that cancels the sale and returns the NFT to the seller.
struct (0x00000003) GetgemsNftFixpriceSaleV2CancelSale {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
}

/// NFT transfer message emitted to the NFT item on buy or cancel.
struct (0x5fcc3d14) GetgemsNftFixpriceSaleV2NftTransfer {
    /// Query id from the buy/cancel request, or zero for empty-body buys.
    queryId: uint64
    /// New NFT owner: buyer on purchase, previous owner on cancellation.
    newOwnerAddress: address
    /// Response destination mirrors the new owner in this source.
    responseAddress: address
    /// Always absent in this source.
    customPayload: cell?
    /// Always zero; the sale does not forward nanotons to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Getgems fixed-price sale v2.
type GetgemsNftFixpriceSaleV2IncomingMessage =
    | GetgemsNftFixpriceSaleV2OwnershipAssigned
    | GetgemsNftFixpriceSaleV2AcceptCoins
    | GetgemsNftFixpriceSaleV2Buy
    | GetgemsNftFixpriceSaleV2CancelSale

/// Outgoing message bodies emitted by Getgems fixed-price sale v2.
type GetgemsNftFixpriceSaleV2OutgoingMessage =
    | GetgemsNftFixpriceSaleV2NftTransfer

/// Structured result returned by `get_sale_data`.
struct GetgemsNftFixpriceSaleV2SaleDataReply {
    /// Fixed magic `0x46495850`, ASCII `FIXP`.
    magic: uint64
    /// True after the sale is bought or cancelled.
    isComplete: bool
    /// Deployment timestamp loaded from uint32 storage.
    createdAt: uint32
    /// Marketplace address stored in sale state.
    marketplaceAddress: address
    /// NFT item address stored in sale state.
    nftAddress: address
    /// Seller address, or `addr_none` before the NFT ownership callback initializes the sale.
    nftOwnerAddress: any_address
    /// Full sale price in nanotons.
    fullPrice: coins
    /// Marketplace fee payout address.
    marketplaceFeeAddress: address
    /// Marketplace fee amount in nanotons.
    marketplaceFee: coins
    /// Royalty payout stack address, or `addr_none` when no royalty transfer should be sent.
    royaltyAddress: any_address
    /// Royalty amount in nanotons.
    royaltyAmount: coins
}

/// Source-level exit-code catalog for Getgems fixed-price sale v2.
enum GetgemsNftFixpriceSaleV2Errors {
    /// Sale was already bought or cancelled.
    AlreadySoldOrCancelled = 404
    /// Uninitialized sale was messaged by an address other than marketplace or NFT.
    UnauthorizedInitiation = 500
    /// Initialization body opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 501
    /// Purchase did not attach `fullPrice + 1 TON`.
    NotEnoughTonsForSale = 450
    /// Cancellation did not attach the required one-ton gas reserve.
    NotEnoughTonsForCancellation = 457
    /// Cancellation sender was neither seller nor marketplace.
    UnauthorizedCancellation = 458
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return fixed-price sale state, fee, and royalty data.
get fun get_sale_data(): GetgemsNftFixpriceSaleV2SaleDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.AlreadySoldOrCancelled;
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.UnauthorizedInitiation;
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.InvalidOpExpectedOwnershipAssigned;
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.NotEnoughTonsForSale;
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.NotEnoughTonsForCancellation;
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.UnauthorizedCancellation;
    assert (true) throw GetgemsNftFixpriceSaleV2Errors.UnknownOperation;
    return {
        magic: 0x46495850,
        isComplete: false,
        createdAt: 0,
        marketplaceAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftOwnerAddress: createAddressNone(),
        fullPrice: 0,
        marketplaceFeeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        marketplaceFee: 0,
        royaltyAddress: createAddressNone(),
        royaltyAmount: 0,
    };
}
