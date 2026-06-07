/// Getgems fixed-price NFT sale V3R2 interface for TON-only listings.
contract GetgemsNftFixpriceSaleV3R2 {
    author: "Getgems"
    version: "3.2"
    description: "Curated Getgems fixed-price NFT sale V3R2 interface"
    storage: GetgemsNftFixpriceSaleV3R2Storage
    incomingMessages: GetgemsNftFixpriceSaleV3R2IncomingMessage
    incomingExternal: GetgemsNftFixpriceSaleV3R2IncomingExternalMessage
    outgoingMessages: GetgemsNftFixpriceSaleV3R2OutgoingMessage
    forceAbiExport: GetgemsNftFixpriceSaleV3R2EmptyBuy
    thrownErrors: GetgemsNftFixpriceSaleV3R2Errors
}

/// Fee distribution cell referenced from the root sale storage.
struct GetgemsNftFixpriceSaleV3R2Fees {
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
struct GetgemsNftFixpriceSaleV3R2Storage {
    /// Completion flag stored as one bit; completed sales reject buy and cancel flows.
    isComplete: bool
    /// Unix timestamp supplied at deployment, stored as uint32.
    createdAt: uint32
    /// Marketplace address allowed to top up uninitialized sales and use rescue resend.
    marketplaceAddress: address
    /// NFT item address authorized to initialize the sale through `ownership_assigned`.
    nftAddress: address
    /// Current NFT owner before purchase; null until the NFT callback initializes the sale.
    nftOwnerAddress: address?
    /// Full sale price in nanotons, excluding the required one-ton gas reserve.
    fullPrice: coins
    /// Referenced fee and royalty amounts paid during successful purchase.
    fees: Cell<GetgemsNftFixpriceSaleV3R2Fees>
    /// One-bit deployment flag allowing a single external message to clear itself.
    canDeployByExternal: bool
}

/// Empty internal message body; when initialized, source treats it as a buy request with query id zero.
struct GetgemsNftFixpriceSaleV3R2EmptyBuy {}

/// Zero-op text/comment body; exact tail `cancel` is a cancel request, other tails buy with query id zero.
struct (0x00000000) GetgemsNftFixpriceSaleV3R2ZeroOpcodeBody {
    /// Raw tail after the zero opcode; source compares it to ASCII `cancel` and otherwise leaves it unread.
    tail: RemainingBitsAndRefs
}

/// NFT ownership callback accepted only from the configured NFT address before sale initialization.
struct (0x05138d91) GetgemsNftFixpriceSaleV3R2OwnershipAssigned {
    /// Query id supplied by the NFT transfer callback; source parses it but does not store it.
    queryId: uint64
    /// Previous owner address stored as the seller address.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves any remaining bits and refs unread.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal command that only accepts attached coins and leaves sale state unchanged.
struct (0x00000001) GetgemsNftFixpriceSaleV3R2AcceptCoins {
    /// Caller-selected query id parsed before the no-op branch returns.
    queryId: uint64
}

/// Internal command that purchases the NFT when enough nanotons are attached.
struct (0x00000002) GetgemsNftFixpriceSaleV3R2Buy {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
}

/// Internal command that cancels the sale and returns the NFT to the seller.
struct (0x00000003) GetgemsNftFixpriceSaleV3R2CancelSale {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
}

/// Referenced rescue envelope used by the marketplace-only resend command.
struct GetgemsNftFixpriceSaleV3R2ResendEnvelope {
    /// Raw `send_raw_message` mode loaded from the envelope.
    mode: uint8
    /// Complete raw message cell passed to `send_raw_message`.
    rawMessage: cell
}

/// Marketplace-only rescue command accepted when the sale is complete or not yet initialized.
struct (0x0000022b) GetgemsNftFixpriceSaleV3R2ResendRawMessage {
    /// Parsed but otherwise unused query id.
    queryId: uint64
    /// Referenced envelope containing send mode and raw message ref.
    resendEnvelope: Cell<GetgemsNftFixpriceSaleV3R2ResendEnvelope>
}

/// External-in body accepted only when storage `canDeployByExternal` is set.
struct GetgemsNftFixpriceSaleV3R2ExternalDeploy {
    /// Source ignores the external body, so this captures any supplied tail.
    ignoredBody: RemainingBitsAndRefs
}

/// NFT transfer message emitted to the NFT item on buy or cancel.
struct (0x5fcc3d14) GetgemsNftFixpriceSaleV3R2NftTransfer {
    /// Query id from the buy/cancel request, or zero for empty/zero-op buys and text cancel.
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

/// Internal message bodies accepted by Getgems fixed-price sale V3R2.
type GetgemsNftFixpriceSaleV3R2IncomingMessage =
    | GetgemsNftFixpriceSaleV3R2ZeroOpcodeBody
    | GetgemsNftFixpriceSaleV3R2OwnershipAssigned
    | GetgemsNftFixpriceSaleV3R2AcceptCoins
    | GetgemsNftFixpriceSaleV3R2Buy
    | GetgemsNftFixpriceSaleV3R2CancelSale
    | GetgemsNftFixpriceSaleV3R2ResendRawMessage

/// External-in message bodies accepted by Getgems fixed-price sale V3R2.
type GetgemsNftFixpriceSaleV3R2IncomingExternalMessage = GetgemsNftFixpriceSaleV3R2ExternalDeploy

/// Outgoing message bodies emitted by Getgems fixed-price sale V3R2.
type GetgemsNftFixpriceSaleV3R2OutgoingMessage = GetgemsNftFixpriceSaleV3R2NftTransfer

/// Structured result returned by `get_sale_data`.
struct GetgemsNftFixpriceSaleV3R2SaleDataReply {
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

/// Source-level exit-code catalog for Getgems fixed-price sale V3R2.
enum GetgemsNftFixpriceSaleV3R2Errors {
    /// Sale was already bought or cancelled.
    AlreadySoldOrCancelled = 404
    /// Purchase did not attach `fullPrice + 1 TON`.
    NotEnoughTonsForSale = 450
    /// Cancellation did not attach the required one-ton gas reserve.
    NotEnoughTonsForCancellation = 457
    /// Cancellation sender was neither seller nor marketplace.
    UnauthorizedCancellation = 458
    /// Uninitialized sale was messaged by an address other than marketplace or NFT.
    UnauthorizedInitiation = 500
    /// Initialization body opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 501
    /// External deployment message arrived after the deployment flag was cleared.
    ExternalDeployNotAllowed = 65534
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return fixed-price sale state, fee, and royalty data.
get fun get_sale_data(): GetgemsNftFixpriceSaleV3R2SaleDataReply {
    throw 0;
}
