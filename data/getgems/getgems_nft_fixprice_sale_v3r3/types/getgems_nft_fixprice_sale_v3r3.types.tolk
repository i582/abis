/// Getgems fixed-price NFT sale V3R3 interface for TON-only listings.
contract GetgemsNftFixpriceSaleV3R3 {
    author: "Getgems"
    version: "3.3"
    description: "Curated Getgems fixed-price NFT sale V3R3 interface"
    storage: GetgemsNftFixpriceSaleV3R3Storage
    incomingMessages: GetgemsNftFixpriceSaleV3R3IncomingMessage
    outgoingMessages: GetgemsNftFixpriceSaleV3R3OutgoingMessage
    forceAbiExport: GetgemsNftFixpriceSaleV3R3EmptyBuy
    thrownErrors: GetgemsNftFixpriceSaleV3R3Errors
}

/// Fee distribution cell referenced from the root sale storage.
struct GetgemsNftFixpriceSaleV3R3Fees {
    /// Marketplace fee payout address preserved when the seller changes price.
    marketplaceFeeAddress: address
    /// Marketplace fee amount in nanotons.
    marketplaceFee: coins
    /// Royalty payout address; source skips royalty transfer when this is `addr_none`.
    royaltyAddress: address?
    /// Royalty amount in nanotons.
    royaltyAmount: coins
}

/// Persistent sale state; `nftOwnerAddress = addr_none` marks the pre-initialized deployment state.
@overflow1023_policy("suppress")
struct GetgemsNftFixpriceSaleV3R3Storage {
    /// Completion flag stored as one bit; completed sales reject ordinary commands.
    isComplete: bool
    /// Unix timestamp supplied at deployment, stored as uint32.
    createdAt: uint32
    /// Marketplace address allowed to top up uninitialized sales and use rescue resend.
    marketplaceAddress: address
    /// NFT item address authorized to initialize the sale through `ownership_assigned`.
    nftAddress: address
    /// Current NFT owner before purchase; null until the NFT callback initializes the sale.
    nftOwnerAddress: address?
    /// Full sale price in nanotons, excluding the required 0.1 TON gas reserve.
    fullPrice: coins
    /// Referenced fee and royalty amounts paid during successful purchase.
    fees: Cell<GetgemsNftFixpriceSaleV3R3Fees>
    /// Unix timestamp set to `now()` on successful purchase and reset on cancel or price change.
    soldAt: uint32
    /// Query id from the successful purchase, reset on cancel or price change.
    queryId: uint64
}

/// Empty internal message body; when initialized, source treats it as a buy request with query id zero.
struct GetgemsNftFixpriceSaleV3R3EmptyBuy {
}

/// Opcode-zero body; exact UTF-8 `cancel` tail cancels, otherwise initialized source buys with query id zero.
struct (0x00000000) GetgemsNftFixpriceSaleV3R3ZeroOpcodeCommand {
    /// Raw tail after the zero opcode; source compares it to the exact text `cancel`.
    tail: RemainingBitsAndRefs
}

/// NFT ownership callback accepted only from the configured NFT address before sale initialization.
struct (0x05138d91) GetgemsNftFixpriceSaleV3R3OwnershipAssigned {
    /// Query id supplied by the NFT transfer callback and persisted while the sale initializes.
    queryId: uint64
    /// Previous owner address stored as the seller address.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves any remaining bits and refs unread.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal command that only accepts attached coins and leaves sale state unchanged.
struct (0x00000001) GetgemsNftFixpriceSaleV3R3AcceptCoins {
    /// Caller-selected query id parsed before the no-op branch returns.
    queryId: uint64
}

/// Internal command that purchases the NFT when enough nanotons are attached.
struct (0x00000002) GetgemsNftFixpriceSaleV3R3Buy {
    /// Query id copied into the outgoing NFT transfer and persisted as the sale query id.
    queryId: uint64
}

/// Internal command that cancels the sale and returns the NFT to the seller.
struct (0x00000003) GetgemsNftFixpriceSaleV3R3CancelSale {
    /// Query id copied into the outgoing NFT transfer.
    queryId: uint64
}

/// Seller-only command that changes full price and fee amounts while preserving payout addresses.
struct (0x6c6c2080) GetgemsNftFixpriceSaleV3R3ChangePrice {
    /// Parsed before the price fields but otherwise unused by the source.
    queryId: uint64
    /// New full sale price in nanotons.
    newFullPrice: coins
    /// New marketplace fee amount in nanotons.
    newMarketplaceFee: coins
    /// New royalty amount in nanotons.
    newRoyaltyAmount: coins
}

/// Referenced rescue envelope used by the marketplace-only resend command.
struct GetgemsNftFixpriceSaleV3R3ResendEnvelope {
    /// Raw `send_raw_message` mode; source rejects values with bit 32 set.
    mode: uint8
    /// Complete raw message cell passed to `send_raw_message`.
    rawMessage: cell
}

/// Marketplace-only rescue command accepted when the sale is complete or not yet initialized.
struct (0x0000022b) GetgemsNftFixpriceSaleV3R3ResendRawMessage {
    /// Parsed but otherwise unused query id.
    queryId: uint64
    /// Referenced envelope containing send mode and raw message ref.
    resendEnvelope: Cell<GetgemsNftFixpriceSaleV3R3ResendEnvelope>
}

/// NFT transfer message emitted to the NFT item on buy or cancel.
struct (0x5fcc3d14) GetgemsNftFixpriceSaleV3R3NftTransfer {
    /// Query id from the buy/cancel request, or zero for empty-body and non-cancel zero-op buys.
    queryId: uint64
    /// New NFT owner: buyer on purchase, previous owner on cancellation.
    newOwnerAddress: address
    /// Response destination mirrors the new owner in this source.
    responseAddress: address
    /// Always absent in this source.
    customPayload: cell?
    /// Zero on cancellation, or 0.03 TON on purchase.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Getgems fixed-price sale V3R3.
type GetgemsNftFixpriceSaleV3R3IncomingMessage =
    | GetgemsNftFixpriceSaleV3R3ZeroOpcodeCommand
    | GetgemsNftFixpriceSaleV3R3OwnershipAssigned
    | GetgemsNftFixpriceSaleV3R3AcceptCoins
    | GetgemsNftFixpriceSaleV3R3Buy
    | GetgemsNftFixpriceSaleV3R3CancelSale
    | GetgemsNftFixpriceSaleV3R3ChangePrice
    | GetgemsNftFixpriceSaleV3R3ResendRawMessage

/// Outgoing message bodies emitted by Getgems fixed-price sale V3R3.
type GetgemsNftFixpriceSaleV3R3OutgoingMessage = GetgemsNftFixpriceSaleV3R3NftTransfer

/// Structured result returned by `get_sale_data`.
struct GetgemsNftFixpriceSaleV3R3SaleDataReply {
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

/// Structured result returned by `get_fix_price_data`.
struct GetgemsNftFixpriceSaleV3R3FixPriceDataReply {
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
    /// Unix timestamp of successful purchase, or zero before purchase and after cancel/change-price.
    soldAt: uint32
    /// Query id of successful purchase, or zero before purchase and after cancel/change-price.
    queryId: uint64
}

/// Source-level exit-code catalog for Getgems fixed-price sale V3R3.
enum GetgemsNftFixpriceSaleV3R3Errors {
    /// Sale was already bought or cancelled.
    AlreadySoldOrCancelled = 404
    /// Marketplace raw resend attempted send mode bit 32.
    Mode32NotAllowed = 405
    /// Marketplace raw resend attempted during the ten-minute sold-at window.
    CannotExecuteCommandAtThisTime = 406
    /// Price change would make seller proceeds less than one nanotons.
    InconsistentPriceAndFeesOnChangePrice = 408
    /// Legacy sale-data getter detected non-positive seller proceeds.
    InconsistentPriceAndFeesOnSaleData = 409
    /// V3R3 fix-price getter detected non-positive seller proceeds.
    InconsistentPriceAndFeesOnFixPriceData = 410
    /// Purchase did not attach `fullPrice + 0.1 TON`.
    NotEnoughTonsForSale = 450
    /// Cancellation did not attach the required 0.1 TON gas reserve.
    NotEnoughTonsForCancellation = 457
    /// Cancellation sender was neither seller nor marketplace.
    UnauthorizedCancellation = 458
    /// Uninitialized sale was messaged by an address other than marketplace or NFT.
    UnauthorizedInitiation = 500
    /// Initialization body opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 501
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return legacy fixed-price sale state, fee, and royalty data.
get fun get_sale_data(): GetgemsNftFixpriceSaleV3R3SaleDataReply {
    throw 0;
}

/// Return V3R3 fixed-price sale state including sold timestamp and purchase query id.
get fun get_fix_price_data(): GetgemsNftFixpriceSaleV3R3FixPriceDataReply {
    throw 0;
}
