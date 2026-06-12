/// Official `.ton` DNS collection resolver contract.
contract DnsCollection {
    author: "TON"
    version: "1.0"
    description: "Curated TON DNS `.ton` collection resolver and NFT collection interface"
    storage: DnsCollectionStorage
    incomingMessages: DnsCollectionIncomingMessage
    outgoingMessages: DnsCollectionOutgoingMessage
    forceAbiExport: DnsCollectionDomainItemInit | DnsCollectionRecord | DnsCollectionOffchainContent
    thrownErrors: DnsCollectionErrors
}

/// Persistent storage for the official `.ton` DNS collection resolver.
struct DnsCollectionStorage {
    /// Referenced collection metadata cell returned by `get_collection_data`.
    collectionContent: Cell<DnsCollectionOffchainContent>
    /// Referenced DNS domain item code cell used to derive item state init.
    nftItemCode: cell
}

/// TEP-64 off-chain collection content stored by the live `.ton` collection.
struct DnsCollectionOffchainContent {
    /// Off-chain content tag.
    offchainTag: uint8
    /// URL bytes after the TEP-64 off-chain tag, encoded as a snake tail.
    url: RemainingBitsAndRefs
}

/// Collection-to-item initialization body emitted when a domain NFT is deployed.
struct DnsCollectionDomainItemInit {
    /// Initial bidder address supplied by the collection.
    bidderAddress: address
    /// Referenced domain label cell.
    domain: cell
}

/// Plain text-comment purchase body accepted by the collection under opcode zero.
struct (0x00000000) DnsCollectionDeployDomain {
    /// Raw snake comment tail containing the requested domain label.
    domain: RemainingBitsAndRefs
}

/// Balance top-up body accepted and ignored by the collection.
struct (0x370fec51) DnsCollectionFillUp {
    /// Query id used by the domain item send site; the collection itself ignores the tail.
    queryId: uint64
}

/// DNS delegation record pointing at a domain item resolver.
struct (0xba93) DnsCollectionNextResolverRecord {
    /// Internal address of the resolver that should handle the unresolved suffix.
    resolver: address
}

/// DNS text record. The tail is the standard recursive `Text` chunk encoding.
struct (0x1eda) DnsCollectionTextRecord {
    /// Raw chunked text payload after the 16-bit `dns_text` tag.
    text: RemainingBitsAndRefs
}

/// DNS ADNL address record, usually stored under the `site` category.
struct (0xad01) DnsCollectionAdnlAddressRecord {
    /// ADNL address bits.
    adnlAddress: uint256
    /// Presence flag for the trailing protocol list; the standard restricts it to 0 or 1.
    flags: uint8
    /// Raw `ProtoList` tail when `flags == 1`, otherwise empty.
    protocolList: RemainingBitsAndRefs
}

/// DNS smart-contract address record, usually stored under the `wallet` category.
struct (0x9fd3) DnsCollectionSmcAddressRecord {
    /// Internal smart-contract address stored in the record.
    smartContractAddress: address
    /// Presence flag for the trailing capability list; the standard restricts it to 0 or 1.
    flags: uint8
    /// Raw `SmcCapList` tail when `flags == 1`, otherwise empty.
    capabilityList: RemainingBitsAndRefs
}

/// DNS storage record, usually stored under the `storage` category.
struct (0x7473) DnsCollectionStorageAddressRecord {
    /// TON Storage bag id.
    bagId: uint256
}

/// TL-B `DNSRecord` variants returned by `dnsresolve` result cells.
type DnsCollectionRecord =
    | DnsCollectionNextResolverRecord
    | DnsCollectionTextRecord
    | DnsCollectionAdnlAddressRecord
    | DnsCollectionSmcAddressRecord
    | DnsCollectionStorageAddressRecord

/// Internal message bodies accepted by the official `.ton` DNS collection.
type DnsCollectionIncomingMessage =
    | DnsCollectionDeployDomain
    | DnsCollectionFillUp

/// Internal message body emitted to a freshly deployed DNS domain item.
type DnsCollectionOutgoingMessage = DnsCollectionDomainItemInit

/// Structured result returned by `get_collection_data`.
struct DnsCollectionDataReply {
    /// The official `.ton` collection is unbounded and returns -1.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionContent: cell
    /// NFT collection owner address; the official `.ton` collection returns `addr_none`.
    ownerAddress: any_address
}

/// Structured result returned by the standard `dnsresolve` get method.
struct DnsCollectionResolveReply {
    /// Number of bits consumed from the requested DNS subdomain.
    resolvedBits: int64
    /// DNS next-resolver cell or null cell depending on resolution result.
    result: cell
}

/// Source-level exit-code catalog from the official DNS collection source.
enum DnsCollectionErrors {
    /// DNS subdomain length is not byte-aligned.
    BadSubdomainLength = 70
    /// Domain collection auction has not started yet.
    AuctionNotStarted = 199
    /// Domain label is too short.
    DomainTooShort = 200
    /// Domain label is too long, or a top domain label is empty in helper code.
    DomainTooLong = 201
    /// Domain label length is not byte-aligned or the snake comment has more than one continuation ref.
    BadDomainLength = 202
    /// Domain label contains an invalid character.
    BadDomainString = 203
    /// Incoming amount is below the current minimum price.
    AmountBelowMinimum = 204
    /// Domain is already blocked by DNS config.
    DomainReservedByConfig = 205
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return next item index, collection metadata, and collection owner address.
get fun get_collection_data(): DnsCollectionDataReply {
    throw 0;
}

/// Return deterministic DNS domain item address for a domain index.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return individual item content unchanged.
get fun get_nft_content(index: int, individualNftContent: cell): cell {
    throw 0;
}

/// Resolve a DNS subdomain/category pair through `.ton` domain item delegation.
get fun dnsresolve(subdomain: slice, category: int): DnsCollectionResolveReply {
    throw 0;
}
