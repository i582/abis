/// Legacy Getgems TON-only NFT sale interface from `packages/contracts/sources/nft-sale.fc`.
contract GetgemsNftSaleLegacy {
    author: "Getgems"
    version: "1.0-legacy"
    description: "Curated Getgems legacy NFT sale interface with three-field fee cell"
    storage: GetgemsNftSaleLegacyStorage
    incomingMessages: GetgemsNftSaleLegacyIncomingMessage
    outgoingMessages: GetgemsNftSaleLegacyOutgoingMessage
    forceAbiExport: GetgemsNftSaleLegacyEmptyBuy
}

/// Fee distribution cell referenced from the root legacy sale storage.
struct GetgemsNftSaleLegacyFees {
    /// Marketplace fee amount in nanotons; legacy source pays this to `marketplaceAddress`.
    marketplaceFee: coins
    /// Royalty payout address used by every successful purchase.
    royaltyAddress: address
    /// Royalty amount in nanotons.
    royaltyAmount: coins
}

/// Persistent legacy sale state; `nftOwnerAddress = addr_none` marks the pre-initialized state.
struct GetgemsNftSaleLegacyStorage {
    /// Marketplace address allowed to top up deployment and cancel an initialized sale.
    marketplaceAddress: address
    /// NFT item address authorized to initialize the sale through `ownership_assigned`.
    nftAddress: address
    /// Current NFT owner before purchase; null until the NFT callback initializes the sale.
    nftOwnerAddress: address?
    /// Full sale price in nanotons, excluding the required one-ton gas reserve.
    fullPrice: coins
    /// Referenced legacy fee and royalty amounts paid during successful purchase.
    fees: Cell<GetgemsNftSaleLegacyFees>
}

/// Empty internal message body; when initialized, source treats it as a buy request with query id zero.
struct GetgemsNftSaleLegacyEmptyBuy {
}

/// NFT ownership callback accepted only from the configured NFT address before sale initialization.
struct (0x05138d91) GetgemsNftSaleLegacyOwnershipAssigned {
    /// Query id supplied by the NFT transfer callback; source parses it but does not store it.
    queryId: uint64
    /// Previous owner address stored as the seller address.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves any remaining bits and refs unread.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal command that only accepts attached coins and leaves sale state unchanged.
struct (0x00000001) GetgemsNftSaleLegacyAcceptCoins {
    /// Caller-selected query id parsed before the no-op branch returns.
    queryId: uint64
    /// Source accepts and ignores any remaining body tail after the query id.
    ignoredTail: RemainingBitsAndRefs
}

/// Internal command that purchases the NFT when enough nanotons are attached.
struct (0x00000002) GetgemsNftSaleLegacyBuy {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
    /// Source accepts and ignores any remaining body tail after the query id.
    ignoredTail: RemainingBitsAndRefs
}

/// Internal command that cancels the sale and returns the NFT to the seller.
struct (0x00000003) GetgemsNftSaleLegacyCancelSale {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
    /// Source accepts and ignores any remaining body tail after the query id.
    ignoredTail: RemainingBitsAndRefs
}

/// NFT transfer message emitted to the NFT item on buy or cancel.
struct (0x5fcc3d14) GetgemsNftSaleLegacyNftTransfer {
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

/// Internal message bodies accepted by Getgems legacy NFT sale.
type GetgemsNftSaleLegacyIncomingMessage =
    | GetgemsNftSaleLegacyOwnershipAssigned
    | GetgemsNftSaleLegacyAcceptCoins
    | GetgemsNftSaleLegacyBuy
    | GetgemsNftSaleLegacyCancelSale

/// Outgoing message bodies emitted by Getgems legacy NFT sale.
type GetgemsNftSaleLegacyOutgoingMessage =
    | GetgemsNftSaleLegacyNftTransfer

/// Structured result returned by `get_sale_data`.
struct GetgemsNftSaleLegacySaleDataReply {
    /// Marketplace address stored in sale state.
    marketplaceAddress: address
    /// NFT item address stored in sale state.
    nftAddress: address
    /// Seller address, or `addr_none` before the NFT ownership callback initializes the sale.
    nftOwnerAddress: any_address
    /// Full sale price in nanotons.
    fullPrice: coins
    /// Marketplace fee amount in nanotons, paid to `marketplaceAddress` in this legacy source.
    marketplaceFee: coins
    /// Royalty payout address returned from the referenced fee cell.
    royaltyAddress: address
    /// Royalty amount in nanotons.
    royaltyAmount: coins
}

/// Source-level exit-code catalog for Getgems legacy NFT sale.
enum GetgemsNftSaleLegacyErrors {
    /// Purchase did not attach `fullPrice + 1 TON`.
    NotEnoughTonsForSale = 450
    /// Uninitialized sale was messaged by an address other than marketplace or NFT.
    UnauthorizedInitiation = 500
    /// Initialization body opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 501
    /// Cancellation did not attach the required one-ton gas reserve.
    NotEnoughTonsForCancellation = 457
    /// Cancellation sender was neither seller nor marketplace.
    UnauthorizedCancellation = 458
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return legacy sale state, marketplace fee, and royalty data.
get fun get_sale_data(): GetgemsNftSaleLegacySaleDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftSaleLegacyErrors.NotEnoughTonsForSale;
    assert (true) throw GetgemsNftSaleLegacyErrors.UnauthorizedInitiation;
    assert (true) throw GetgemsNftSaleLegacyErrors.InvalidOpExpectedOwnershipAssigned;
    assert (true) throw GetgemsNftSaleLegacyErrors.NotEnoughTonsForCancellation;
    assert (true) throw GetgemsNftSaleLegacyErrors.UnauthorizedCancellation;
    assert (true) throw GetgemsNftSaleLegacyErrors.UnknownOperation;
    return {
        marketplaceAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftOwnerAddress: createAddressNone(),
        fullPrice: 0,
        marketplaceFee: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        royaltyAmount: 0,
    };
}
