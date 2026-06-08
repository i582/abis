/// Fragment anonymous Telegram number collection contract.
contract FragmentNumbersCollection {
    author: "Telegram"
    version: "1.0"
    description: "Fragment collection interface for anonymous Telegram number TeleMint items"
    storage: FragmentNumbersCollectionStorage
    incomingMessages: FragmentNumbersCollectionIncomingMessage
    outgoingMessages: FragmentNumbersCollectionOutgoingMessage
    thrownErrors: FragmentNumbersCollectionErrors
}

/// Root persistent collection data.
struct FragmentNumbersCollectionStorage {
    /// One-bit touch flag set by the first accepted external message.
    touched: bool
    /// Collection subwallet id checked in signed deploy requests.
    subwalletId: uint32
    /// Ed25519 public key used for signed deploy requests.
    publicKey: bits256
    /// Referenced collection metadata cell returned by `get_collection_data`.
    content: cell
    /// Referenced item code cell used to derive item addresses.
    itemCode: cell
    /// Referenced length-prefixed root domain text cell.
    fullDomain: cell
    /// Referenced default royalty parameters.
    royaltyParams: Cell<FragmentNumbersCollectionRoyaltyParams>
}

/// NFT royalty payout parameters used by item deployments.
struct FragmentNumbersCollectionRoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: address?
}

/// Auction configuration passed to newly deployed items.
struct FragmentNumbersCollectionAuctionConfig {
    /// Beneficiary receiving auction proceeds after royalties.
    beneficiaryAddress: address
    /// Minimum first bid in nanotons.
    initialMinBid: coins
    /// Instant-win bid in nanotons, or zero when disabled.
    maxBid: coins
    /// Minimum bid increase percent.
    minBidStep: uint8
    /// Minimum extension window in seconds.
    minExtendTime: uint32
    /// Auction duration in seconds.
    duration: uint32
}

/// Signed collection deploy request for anonymous number items.
struct (0x4637289b) FragmentNumbersCollectionDeploy {
    /// Ed25519 signature over the command bytes after the signature field.
    signature: bits512
    /// Collection subwallet id.
    subwalletId: uint32
    /// Unix timestamp after which the request becomes valid.
    validSince: uint32
    /// Unix timestamp after which the request expires.
    validTill: uint32
    /// Raw deploy command tail with token name, content, auction config, optional royalty, and optional restrictions.
    command: RemainingBitsAndRefs
}

/// Collection-to-item initialization and first-bid body.
struct (0x299a3e15) FragmentNumbersCollectionItemDeploy {
    /// First bidder address supplied by the collection.
    senderAddress: address
    /// First bid amount in nanotons.
    bid: coins
    /// Raw referenced token-info cell.
    tokenInfo: cell
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// Referenced auction configuration.
    auctionConfig: Cell<FragmentNumbersCollectionAuctionConfig>
    /// Referenced royalty parameters.
    royaltyParams: Cell<FragmentNumbersCollectionRoyaltyParams>
}

/// Internal message bodies accepted by the anonymous number collection.
type FragmentNumbersCollectionIncomingMessage = FragmentNumbersCollectionDeploy

/// Internal message bodies emitted by the anonymous number collection.
type FragmentNumbersCollectionOutgoingMessage = FragmentNumbersCollectionItemDeploy

/// Structured result returned by `get_collection_data`.
struct FragmentNumbersCollectionDataReply {
    /// Constant collection item index value returned by Fragment collections.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionContent: cell
    /// Collection owner address returned by the NFT collection getter.
    ownerAddress: any_address
}

/// Fragment anonymous number collection exit-code catalog.
enum FragmentNumbersCollectionErrors {
    /// Text payload length is invalid.
    InvalidLength = 201
    /// Signed deploy request signature is invalid.
    InvalidSignature = 202
    /// Signed deploy request subwallet id does not match storage.
    WrongSubwalletId = 203
    /// Signed deploy request is not valid yet.
    NotYetValidSignature = 204
    /// Signed deploy request is expired.
    ExpiredSignature = 205
    /// Incoming deploy value is below the auction minimum.
    NotEnoughFunds = 206
    /// Plain top-up transfer does not contain the required comment.
    WrongTopupComment = 207
    /// Incoming internal message opcode is not supported.
    UnknownOp = 208
    /// External touch was already accepted.
    ForbiddenTouch = 218
    /// Forced sender restriction does not match the inbound sender.
    InvalidSenderAddress = 224
    /// Address workchain is not zero.
    IncorrectWorkchain = 333
}

/// Return collection metadata and zero owner address.
get fun get_collection_data(): FragmentNumbersCollectionDataReply {
    throw 0;
}

/// Return deterministic item address for an item index.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return full NFT content from the individual item content.
get fun get_nft_content(index: int, individualContent: cell): cell {
    throw 0;
}
