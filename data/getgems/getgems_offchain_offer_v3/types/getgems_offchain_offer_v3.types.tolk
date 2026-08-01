/// Getgems Offchain Offer V3 interface shared by the Tolk 1.0.0 and 1.3.0 deployments.
contract GetgemsOffchainOfferV3 {
    author: "Getgems"
    version: "3"
    description: "Getgems Offchain Offer V3 escrows TON for signed off-chain NFT purchases against a collection or a single NFT."
    storage: GetgemsOffchainOfferV3Storage
    incomingMessages: GetgemsOffchainOfferV3IncomingMessage
    incomingExternal: GetgemsOffchainOfferV3IncomingExternalMessage
    outgoingMessages: GetgemsOffchainOfferV3OutgoingMessage
    forceAbiExport: GetgemsOffchainOfferV3EmptyBody
    thrownErrors: Errors
}

/// Marketplace and royalty payout configuration stored in a referenced cell.
struct GetgemsOffchainOfferV3Fees {
    /// Marketplace contract authorized to cancel offers and invoke emergency recovery.
    marketplaceAddress: address
    /// Recipient of the marketplace fee for each completed purchase.
    marketplaceFeeAddress: address
    /// Recipient of the NFT royalty for each completed purchase.
    royaltyAddress: address
    /// Marketplace fee numerator.
    feeFactor: uint16
    /// Marketplace fee denominator; zero disables the marketplace fee.
    feeBase: uint16
    /// Royalty numerator.
    royaltyFactor: uint16
    /// Royalty denominator; zero disables the royalty.
    royaltyBase: uint16
}

/// Collection-wide purchase target selected by an eight-bit zero tag.
struct (0x00) GetgemsOffchainOfferV3CollectionTarget {
    /// NFT collection whose items may satisfy the offer.
    collectionAddress: address
    /// Raw collection-attribute constraint used by the off-chain matcher.
    attributes: cell
}

/// Single-NFT purchase target selected by an eight-bit one tag.
struct (0x01) GetgemsOffchainOfferV3NftTarget {
    /// Exact NFT item that may satisfy the offer.
    nftAddress: address
}

/// Immutable target variant stored in the static-data reference.
type GetgemsOffchainOfferV3Target =
    | GetgemsOffchainOfferV3CollectionTarget
    | GetgemsOffchainOfferV3NftTarget

/// Immutable offer creation data stored in a referenced cell.
struct GetgemsOffchainOfferV3StaticData {
    /// Offer creation Unix timestamp.
    createdAt: uint32
    /// Collection-wide or single-NFT purchase target.
    target: GetgemsOffchainOfferV3Target
}

/// Persistent state shared by both verified compiler revisions.
struct GetgemsOffchainOfferV3Storage {
    /// Ed25519 public key used to authorize external purchase and close requests.
    publicKey: uint256
    /// Offer creator that receives cancellation refunds and cancellation notifications.
    ownerAddress: address
    /// True after cancellation, signed closure, expiration closure, or the final purchase.
    isComplete: bool
    /// Required price per NFT in nanotons.
    nftPrice: coins
    /// Maximum number of NFTs funded by this offer.
    maxCount: uint20
    /// Number of accepted signed purchase requests.
    boughtCount: uint20
    /// Offer expiry Unix timestamp.
    finishAt: uint32
    /// Referenced marketplace and royalty payout configuration.
    fees: Cell<GetgemsOffchainOfferV3Fees>
    /// Last cleaned replay-protection query id, or zero before deployment initialization.
    lastCleaned: uint64
    /// Raw `HashmapE 64` replay-protection set whose values are empty slices.
    queryIds: dict
    /// Referenced immutable creation timestamp and target.
    staticData: Cell<GetgemsOffchainOfferV3StaticData>
}

/// Initial funding command accepted once from the offer owner.
struct (0x00000000) GetgemsOffchainOfferV3Deploy {}

/// Owner- or marketplace-authorized request to cancel the offer.
struct (0x9e548f0a) GetgemsOffchainOfferV3Cancel {
    /// Caller-selected identifier copied into the cancellation notification.
    queryId: uint64
}

/// Owner-authorized request to change the per-NFT purchase price.
struct (0x5cd0fa66) GetgemsOffchainOfferV3ChangePrice {
    /// Caller-selected request identifier.
    queryId: uint64
    /// Replacement per-NFT price in nanotons.
    newPrice: coins
}

/// Marketplace-only emergency relay accepted after offer completion.
struct (0x0000022b) GetgemsOffchainOfferV3MarketplaceEmergency {
    /// Caller-selected request identifier used only for traceability.
    queryId: uint64
    /// Raw send mode; the destroy-account bit is rejected.
    mode: uint8
    /// Complete outbound message cell relayed by the contract.
    message: cell
}

/// Cancellation acknowledgement sent to the offer owner before the contract carries out its balance.
struct (0xa8a9ada5) GetgemsOffchainOfferV3OfferWasCancelled {
    /// Identifier copied from the accepted cancellation request.
    queryId: uint64
}

/// Empty body emitted by close refunds and fee or royalty payouts.
struct GetgemsOffchainOfferV3EmptyBody {}

/// Seller and NFT identity referenced by a signed purchase request.
struct GetgemsOffchainOfferV3ChargeData {
    /// Seller address receiving proceeds after fees and royalties.
    sellerAddress: address
    /// NFT item being purchased; checked for single-NFT targets.
    nftAddress: address
}

/// Unsigned payload following the signature in an external purchase request.
struct GetgemsOffchainOfferV3ChargeRequest {
    /// Replay-protected query id whose high 32 bits encode a recent Unix timestamp.
    queryId: uint64
    /// Price that must equal the stored per-NFT price.
    price: coins
    /// Offer contract address that must equal the current contract address.
    offerAddress: address
    /// Referenced seller payout body forwarded unchanged.
    comment: cell
    /// Referenced seller and NFT identity.
    chargeData: Cell<GetgemsOffchainOfferV3ChargeData>
}

/// Unsigned external expiration close request selected by an eight-bit `0x2b` tag.
struct (0x2b) GetgemsOffchainOfferV3Expire {}

/// Signed external close request selected by an eight-bit `0x2c` tag.
struct (0x2c) GetgemsOffchainOfferV3SignedClose {
    /// Ed25519 signature over the remainder of this external body.
    signature: bits512
    /// Unix timestamp after which the signed request is rejected.
    validUntil: uint32
    /// Offer contract address that must equal the current contract address.
    offerAddress: address
}

/// Signed external NFT purchase request selected by an eight-bit `0x8f` tag.
struct (0x8f) GetgemsOffchainOfferV3SignedCharge {
    /// Ed25519 signature over the remaining charge payload.
    signature: bits512
    /// Signed purchase parameters.
    request: GetgemsOffchainOfferV3ChargeRequest
}

/// Internal message bodies accepted by Offchain Offer V3.
type GetgemsOffchainOfferV3IncomingMessage =
    | GetgemsOffchainOfferV3Deploy
    | GetgemsOffchainOfferV3Cancel
    | GetgemsOffchainOfferV3ChangePrice
    | GetgemsOffchainOfferV3MarketplaceEmergency

/// External-in bodies accepted by Offchain Offer V3.
type GetgemsOffchainOfferV3IncomingExternalMessage =
    | GetgemsOffchainOfferV3Expire
    | GetgemsOffchainOfferV3SignedClose
    | GetgemsOffchainOfferV3SignedCharge

/// Statically tagged internal body emitted by Offchain Offer V3.
///
/// Untagged empty payout bodies are exported separately as
/// `GetgemsOffchainOfferV3EmptyBody` because tagged and untagged bodies cannot
/// share an automatically discriminated Tolk union.
type GetgemsOffchainOfferV3OutgoingMessage = GetgemsOffchainOfferV3OfferWasCancelled

/// Structured result returned by `get_offchain_offer_v2`.
struct GetgemsOffchainOfferV3DataReply {
    /// True before deployment initialization or after the offer completes.
    isComplete: bool
    /// Offer creator address.
    ownerAddress: address
    /// Offer creation Unix timestamp.
    createdAt: uint32
    /// Offer expiry Unix timestamp.
    finishAt: uint32
    /// Ed25519 public key used by signed external requests.
    publicKey: uint256
    /// Required price per NFT in nanotons.
    nftPrice: coins
    /// Maximum number of funded purchases.
    maxCount: uint20
    /// Number of accepted purchases.
    boughtCount: uint20
    /// Marketplace contract address.
    marketplaceAddress: address
    /// Marketplace fee recipient.
    marketplaceFeeAddress: address
    /// Royalty recipient.
    royaltyAddress: address
    /// Marketplace fee numerator.
    feeFactor: uint16
    /// Marketplace fee denominator.
    feeBase: uint16
    /// Royalty numerator.
    royaltyFactor: uint16
    /// Royalty denominator.
    royaltyBase: uint16
    /// Seller proceeds after marketplace and royalty deductions.
    profit: int
    /// Raw collection attribute constraint, or an empty cell for a single-NFT target.
    attributes: cell
    /// Collection address for a collection target, otherwise null.
    collectionAddress: address?
    /// NFT address for a single-NFT target, otherwise null.
    nftAddress: address?
}

/// Exit codes emitted by the verified Offchain Offer V3 source.
enum Errors {
    /// Signed purchase query id was already processed.
    DuplicateQueryId = 105
    /// Signed purchase price differs from storage.
    WrongPrice = 107
    /// Funded purchase capacity has been exhausted.
    PurchaseLimitReached = 108
    /// Signature is invalid or the offer has expired.
    InvalidSignatureOrExpired = 109
    /// Offer is already complete.
    OfferAlreadyComplete = 110
    /// Contract balance cannot cover the requested purchase.
    InsufficientBalance = 111
    /// Fee configuration leaves no positive seller proceeds.
    NonPositiveSellerProfit = 112
    /// Signed request is expired or its query id is too old.
    ExpiredRequest = 113
    /// Signed request targets a different contract address.
    WrongOfferAddress = 115
    /// Single-NFT offer was charged for a different NFT item.
    WrongNftAddress = 116
    /// Unsigned expiry close is attempted before the funded offer expires.
    ExpiryCloseTooEarly = 1001
    /// External expiry or signed close is attempted after offer completion.
    ExternalCloseAfterCompletion = 1002
    /// Initial funding does not cover the configured purchase capacity.
    InitialFundingTooLow = 2001
    /// Initial funding was already completed.
    AlreadyInitialized = 2002
    /// Initial funding sender is not the offer owner.
    UnauthorizedInitializer = 2003
    /// Internal cancellation is attempted after completion.
    CancellationAfterCompletion = 3002
    /// Cancellation sender is neither the owner nor marketplace.
    UnauthorizedCancellation = 3003
    /// Emergency relay sender is not the marketplace.
    UnauthorizedEmergencyRelay = 4001
    /// Emergency relay is attempted before completion.
    EmergencyRelayBeforeCompletion = 4002
    /// Emergency relay is attempted within thirty seconds after completion.
    EmergencyRelayTooEarly = 4003
    /// Emergency relay send mode includes the destroy-account bit.
    EmergencyRelayDestroyMode = 4004
    /// Price change is attempted after completion.
    PriceChangeAfterCompletion = 6001
    /// Price change sender is not the offer owner.
    UnauthorizedPriceChange = 6002
    /// Internal or external body has an unsupported opcode.
    UnknownOperation = 65535
}

/// Return offer state, target, price, purchase counters, fees, and computed seller proceeds.
get fun get_offchain_offer_v2(): GetgemsOffchainOfferV3DataReply {
    throw 0;
}
