/// Getgems fixed-price NFT sale V4R1 interface for TON and Jetton listings.
contract GetgemsNftFixpriceSaleV4R1 {
    author: "Getgems"
    version: "4r1"
    description: "Curated Getgems fixed-price NFT sale V4R1 interface with TON and Jetton sale support"
    storage: GetgemsNftFixpriceSaleV4R1Storage
    storageAtDeployment: GetgemsNftFixpriceSaleV4R1DeploymentStorage
    incomingMessages: GetgemsNftFixpriceSaleV4R1IncomingMessage
    outgoingMessages: GetgemsNftFixpriceSaleV4R1OutgoingMessage
    forceAbiExport: GetgemsNftFixpriceSaleV4R1EmptyTonBuy
    thrownErrors: GetgemsNftFixpriceSaleV4R1Errors
}

/// Persistent runtime sale state after `save_data` rewrites the root cell.
struct GetgemsNftFixpriceSaleV4R1Storage {
    /// Completion flag stored as one bit; completed sales reject ordinary internal messages.
    isComplete: bool
    /// Marketplace address allowed to cancel and to use the post-sale rescue command.
    marketplaceAddress: address
    /// Current NFT owner before purchase; null before the NFT ownership callback initializes the sale.
    nftOwnerAddress: address?
    /// TON sale price encoded as TL-B `Coins`; zero disables TON purchases.
    fullTonPrice: coins
    /// Unix timestamp of successful sale, or zero for active/cancelled state.
    soldAt: uint32
    /// Query id from the successful sale, or zero after cancellation.
    soldQueryId: uint64
    /// Referenced immutable addresses, percentages, NFT address, and creation timestamp.
    staticData: Cell<GetgemsNftFixpriceSaleV4R1StaticData>
    /// Jetton price dictionary keyed by the sale Jetton wallet address hash.
    jettonPrices: map<uint256, GetgemsNftFixpriceSaleV4R1JettonPrice>
}

/// Deployment state may append a one-time public key after the Jetton price dictionary.
struct GetgemsNftFixpriceSaleV4R1DeploymentStorage {
    /// Completion flag stored as one bit; deployment builders set it false.
    isComplete: bool
    /// Initial marketplace/deployer address, replaced by signed Jetton deploy when present.
    marketplaceAddress: address
    /// Current NFT owner before purchase; null before the NFT ownership callback initializes the sale.
    nftOwnerAddress: address?
    /// TON sale price encoded as TL-B `Coins`; zero disables TON purchases.
    fullTonPrice: coins
    /// Unix timestamp of successful sale, or zero at deployment.
    soldAt: uint32
    /// Query id from the successful sale, or zero at deployment.
    soldQueryId: uint64
    /// Referenced immutable addresses, percentages, NFT address, and creation timestamp.
    staticData: Cell<GetgemsNftFixpriceSaleV4R1StaticData>
    /// Initial Jetton price dictionary keyed by the sale Jetton wallet address hash.
    jettonPrices: map<uint256, GetgemsNftFixpriceSaleV4R1JettonPrice>
    /// Optional Ed25519 public key authorizing the signed Jetton deploy message.
    publicKey: uint256?
}

/// Static sale configuration stored as a referenced cell from root storage.
struct GetgemsNftFixpriceSaleV4R1StaticData {
    /// Marketplace fee payout address; source skips the fee transfer when this is `addr_none`.
    marketplaceFeeAddress: address?
    /// Royalty payout address; source skips the royalty transfer when this is `addr_none`.
    royaltyAddress: address?
    /// Marketplace fee fraction multiplied by 100000 and stored in 17 bits.
    marketplaceFeePercent: uint17
    /// Royalty fee fraction multiplied by 100000 and stored in 17 bits.
    royaltyPercent: uint17
    /// NFT item address that initializes the sale and receives transfer commands.
    nftAddress: address
    /// Sale creation Unix timestamp.
    createdAt: uint32
}

/// Jetton dictionary value stored under the Jetton wallet address hash key.
struct GetgemsNftFixpriceSaleV4R1JettonPrice {
    /// Required Jetton amount for this sale currency.
    price: coins
    /// Jetton master address paired with the wallet hash key for off-chain decoding.
    jettonMaster: address
}

/// Empty internal message body; when initialized, source treats it as a TON buy with query id zero.
struct GetgemsNftFixpriceSaleV4R1EmptyTonBuy {
}

/// Explicit zero-op body; a text tail equal to `cancel` is treated as cancellation, otherwise as TON buy.
struct (0x00000000) GetgemsNftFixpriceSaleV4R1ZeroOpcodeBuyOrTextCancel {
    /// Unread tail after opcode zero; exact text `cancel` selects the cancel branch.
    tail: RemainingBitsAndRefs
}

/// NFT ownership callback accepted only from the configured NFT item before initialization.
struct (0x05138d91) GetgemsNftFixpriceSaleV4R1OwnershipAssigned {
    /// Query id supplied by the NFT transfer callback; source parses it but does not store it.
    queryId: uint64
    /// Previous owner address stored as the seller address.
    previousOwnerAddress: address
    /// Raw standard NFT callback tail; source leaves any remaining bits and refs unread.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 Jetton transfer notification used as a Jetton purchase attempt.
struct (0x7362d09c) GetgemsNftFixpriceSaleV4R1JettonTransferNotification {
    /// Jetton transfer query id copied into payouts, refunds, and the NFT transfer.
    queryId: uint64
    /// Jetton amount received by the sale's Jetton wallet.
    amount: coins
    /// Buyer address reported by the Jetton wallet notification.
    buyerAddress: address
    /// Raw TEP-74 forward payload tail ignored by the sale source.
    forwardPayload: RemainingBitsAndRefs
}

/// Funding-only deploy message accepted without state changes.
struct (0x664c0905) GetgemsNftFixpriceSaleV4R1DeployBlank {
    /// Caller-selected query id parsed by the shared dispatcher.
    queryId: uint64
}

/// Signed Jetton deploy message that replaces marketplace address and Jetton prices.
struct (0xfb5dbf47) GetgemsNftFixpriceSaleV4R1DeployJetton {
    /// Caller-selected query id parsed by the shared dispatcher.
    queryId: uint64
    /// Ed25519 signature over the remaining body after this field.
    signature: bits512
    /// Marketplace address to persist after signature validation.
    marketplaceAddress: address
    /// Jetton price dictionary keyed by the sale Jetton wallet address hash.
    jettonPrices: map<uint256, GetgemsNftFixpriceSaleV4R1JettonPrice>
}

/// Seller-only command that changes the TON price and Jetton price dictionary.
struct (0xfd135f7b) GetgemsNftFixpriceSaleV4R1ChangePrice {
    /// Caller-selected query id parsed by the shared dispatcher.
    queryId: uint64
    /// Replacement TON price encoded as TL-B `Coins`; zero disables TON purchases.
    newTonPrice: coins
    /// Replacement Jetton price dictionary, possibly empty.
    newJettonPrices: map<uint256, GetgemsNftFixpriceSaleV4R1JettonPrice>
}

/// Seller or marketplace command that cancels the sale and returns the NFT.
struct (0x00000003) GetgemsNftFixpriceSaleV4R1CancelSale {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
}

/// Explicit TON buy command accepted when enough nanotons are attached.
struct (0x00000002) GetgemsNftFixpriceSaleV4R1Buy {
    /// Query id copied into the outgoing NFT transfer body.
    queryId: uint64
}

/// Marketplace-only rescue command carrying one raw send action in a ref.
struct (0x0000022b) GetgemsNftFixpriceSaleV4R1ResendRawMessage {
    /// Parsed but otherwise unused query id.
    queryId: uint64
    /// Referenced action cell containing send mode and raw message ref.
    resendEnvelope: Cell<GetgemsNftFixpriceSaleV4R1RawSendAction>
}

/// Raw send action used only by the marketplace rescue command.
struct GetgemsNftFixpriceSaleV4R1RawSendAction {
    /// Raw mode passed directly to `send_raw_message`; mode bit 32 is rejected.
    mode: uint8
    /// Complete raw outbound message cell supplied by the marketplace.
    rawMessage: cell
}

/// TEP-62 NFT transfer body emitted to the NFT item on buy or cancellation.
struct (0x5fcc3d14) GetgemsNftFixpriceSaleV4R1NftTransfer {
    /// Query id from the buy/cancel request, or zero for empty-body and zero-op TON buys.
    queryId: uint64
    /// New NFT owner: buyer on purchase, previous owner on cancellation.
    newOwnerAddress: address
    /// Response destination: buyer on purchase, cancel sender on cancellation.
    responseAddress: address
    /// Always absent in this source.
    customPayload: cell?
    /// One nanotoken on purchase, zero on cancellation.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 Jetton transfer body emitted for Jetton payouts, refunds, and overpayment returns.
struct (0x0f8a7ea5) GetgemsNftFixpriceSaleV4R1JettonTransfer {
    /// Query id copied from the incoming Jetton transfer notification.
    queryId: uint64
    /// Jetton amount transferred from the sale's Jetton wallet.
    amount: coins
    /// Jetton transfer destination address.
    destination: address
    /// Response destination used for excesses or refund gas handling.
    responseDestination: address
    /// Always absent in this source.
    customPayload: cell?
    /// Nanoton amount forwarded by the Jetton wallet to the destination.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Getgems fixed-price sale V4R1.
type GetgemsNftFixpriceSaleV4R1IncomingMessage =
    | GetgemsNftFixpriceSaleV4R1ZeroOpcodeBuyOrTextCancel
    | GetgemsNftFixpriceSaleV4R1OwnershipAssigned
    | GetgemsNftFixpriceSaleV4R1JettonTransferNotification
    | GetgemsNftFixpriceSaleV4R1DeployBlank
    | GetgemsNftFixpriceSaleV4R1DeployJetton
    | GetgemsNftFixpriceSaleV4R1ChangePrice
    | GetgemsNftFixpriceSaleV4R1CancelSale
    | GetgemsNftFixpriceSaleV4R1Buy
    | GetgemsNftFixpriceSaleV4R1ResendRawMessage

/// Statically known internal message bodies emitted by Getgems fixed-price sale V4R1.
type GetgemsNftFixpriceSaleV4R1OutgoingMessage =
    | GetgemsNftFixpriceSaleV4R1NftTransfer
    | GetgemsNftFixpriceSaleV4R1JettonTransfer

/// Structured result returned by `get_fix_price_data_v4`.
struct GetgemsNftFixpriceSaleV4R1FixPriceDataReply {
    /// True after the sale is bought or cancelled.
    isComplete: bool
    /// Sale creation Unix timestamp loaded from static data.
    createdAt: uint32
    /// Marketplace address stored in sale state.
    marketplaceAddress: address
    /// NFT item address stored in static data.
    nftAddress: address
    /// Seller address, or `addr_none` before the NFT ownership callback initializes the sale.
    nftOwnerAddress: any_address
    /// TON sale price; zero means TON purchase is disabled.
    fullPrice: coins
    /// Marketplace fee payout stack address, or `addr_none` when the fee transfer is skipped.
    feeAddress: any_address
    /// Marketplace fee fraction multiplied by 100000.
    feePercent: uint32
    /// Royalty payout stack address, or `addr_none` when the royalty transfer is skipped.
    royaltyAddress: any_address
    /// Royalty fee fraction multiplied by 100000.
    royaltyPercent: uint32
    /// Unix timestamp of successful sale, or zero for active/cancelled state.
    soldAt: uint32
    /// Query id from the successful sale, or zero after cancellation.
    soldQueryId: uint64
    /// Jetton price dictionary keyed by sale Jetton wallet address hash.
    jettonPriceDict: map<uint256, GetgemsNftFixpriceSaleV4R1JettonPrice>
}

/// Source-level exit-code catalog for Getgems fixed-price sale V4R1.
enum GetgemsNftFixpriceSaleV4R1Errors {
    /// Signed Jetton deploy message arrived when deployment public key is absent.
    MissingDeployPublicKey = 350
    /// Signed Jetton deploy signature verification failed.
    InvalidDeploySignature = 35
    /// Sale was already bought or cancelled.
    AlreadySoldOrCancelled = 404
    /// Marketplace rescue send mode contains disallowed bit 32.
    Mode32NotAllowed = 405
    /// Marketplace rescue was attempted within ten minutes of sale time.
    CannotExecuteCommandAtThisTime = 406
    /// TON purchase did not attach `fullPrice + 0.1 TON`.
    NotEnoughTonsForSale = 450
    /// Fee, royalty, or seller proceeds calculated below zero.
    InconsistentPriceAndFees = 451
    /// Jetton notification sender is not in workchain zero.
    JettonWalletWrongWorkchain = 452
    /// Cancellation did not attach the required 0.1 TON gas reserve.
    NotEnoughTonsForCancellation = 457
    /// Cancellation sender was neither seller nor marketplace.
    UnauthorizedCancellation = 458
    /// TON purchase attempted while TON price is zero.
    TonPriceDisabled = 459
    /// Uninitialized sale was messaged by an address other than the NFT item.
    UnauthorizedInitiation = 500
    /// Initialization body opcode was not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 501
    /// Attached Jetton or TON amount is below the selected sale price.
    NotEnoughFundsForSale = 4501
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return fixed-price sale state, fee fractions, and Jetton price dictionary.
get fun get_fix_price_data_v4(): GetgemsNftFixpriceSaleV4R1FixPriceDataReply {
    throw 0;
}
