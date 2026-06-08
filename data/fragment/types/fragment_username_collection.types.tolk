/// Fragment Telegram username collection contract.
contract FragmentUsernameCollection {
    author: "Telegram"
    version: "1.0"
    description: "Fragment collection interface for Telegram username TeleMint items with DNS resolver support"
    storage: FragmentUsernameCollectionStorage
    incomingMessages: FragmentUsernameCollectionIncomingMessage
    outgoingMessages: FragmentUsernameCollectionOutgoingMessage
    thrownErrors: FragmentUsernameCollectionErrors
}

/// Root persistent collection data.
struct FragmentUsernameCollectionStorage {
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
    royaltyParams: Cell<FragmentUsernameCollectionRoyaltyParams>
}

/// NFT royalty payout parameters used by item deployments.
struct FragmentUsernameCollectionRoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    destination: address?
}

/// Auction configuration passed to newly deployed items.
struct FragmentUsernameCollectionAuctionConfig {
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

/// Signed collection deploy request for username items.
struct (0x4637289a) FragmentUsernameCollectionDeploy {
    /// Ed25519 signature over the command bytes after the signature field.
    signature: bits512
    /// Collection subwallet id.
    subwalletId: uint32
    /// Unix timestamp after which the request becomes valid.
    validSince: uint32
    /// Unix timestamp after which the request expires.
    validTill: uint32
    /// Raw deploy command tail with token name, content, auction config, and optional royalty.
    command: RemainingBitsAndRefs
}

/// Collection-to-item initialization and first-bid body.
struct (0x299a3e15) FragmentUsernameCollectionItemDeploy {
    /// First bidder address supplied by the collection.
    senderAddress: address
    /// First bid amount in nanotons.
    bid: coins
    /// Raw referenced token-info cell.
    tokenInfo: cell
    /// Referenced TEP-64 individual NFT content cell.
    nftContent: cell
    /// Referenced auction configuration.
    auctionConfig: Cell<FragmentUsernameCollectionAuctionConfig>
    /// Referenced royalty parameters.
    royaltyParams: Cell<FragmentUsernameCollectionRoyaltyParams>
}

/// Internal message bodies accepted by the username collection.
type FragmentUsernameCollectionIncomingMessage = FragmentUsernameCollectionDeploy

/// Internal message bodies emitted by the username collection.
type FragmentUsernameCollectionOutgoingMessage = FragmentUsernameCollectionItemDeploy

/// Structured result returned by `get_collection_data`.
struct FragmentUsernameCollectionDataReply {
    /// Constant collection item index value returned by Fragment collections.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionContent: cell
    /// Collection owner address returned by the NFT collection getter.
    ownerAddress: any_address
}

/// Structured result returned by `dnsresolve`.
struct FragmentUsernameCollectionDnsResolveReply {
    /// Number of bits resolved from the requested DNS subdomain.
    resolvedBits: uint32
    /// DNS next-resolver cell or null cell.
    result: cell
}

/// Fragment username collection exit-code catalog.
enum FragmentUsernameCollectionErrors {
    /// DNS subdomain length is not byte-aligned.
    BadSubdomainLength = 70
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
    /// Address workchain is not zero.
    IncorrectWorkchain = 333
    /// DNS subdomain does not start with the required zero byte.
    NoFirstZeroByte = 413
}

/// Return collection metadata and zero owner address.
get fun get_collection_data(): FragmentUsernameCollectionDataReply {
    throw 0;
}

/// Return full root domain slice.
get fun get_full_domain(): slice {
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

/// Resolve a DNS subdomain/category pair.
get fun dnsresolve(subdomain: slice, category: int): FragmentUsernameCollectionDnsResolveReply {
    throw 0;
}
