/// Official `.ton` DNS domain item contract interface.
contract DnsDomainItem {
    author: "TON"
    version: "1.0"
    description: "Curated TON DNS domain NFT item interface with DNS record management"
    storage: DnsDomainItemStorage
    storageAtDeployment: DnsDomainItemDeploymentStorage
    incomingMessages: DnsDomainItemIncomingMessage
    outgoingMessages: DnsDomainItemOutgoingMessage
    forceAbiExport: DnsDomainItemInit | DnsDomainRecord
}

/// Deployment storage present before the DNS collection initializes the domain item.
struct DnsDomainItemDeploymentStorage {
    /// Domain item index, equal to the SHA-256 hash of the domain label.
    itemIndex: uint256
    /// DNS collection address authorized to initialize this item.
    collectionAddress: address
}

/// Initialized storage for a `.ton` DNS domain item.
struct DnsDomainItemStorage {
    /// Domain item index, equal to the SHA-256 hash of the domain label.
    itemIndex: uint256
    /// DNS collection address used for static-data reports and auction settlement.
    collectionAddress: address
    /// Current owner address; the zero address is used while an auction has no final owner.
    ownerAddress: address
    /// On-chain NFT content cell with DNS records.
    content: Cell<DnsDomainItemContent>
    /// Domain label cell, for example `foundation` without a trailing zero byte.
    domain: cell
    /// Active auction state, absent after ownership has been settled.
    auction: Cell<DnsDomainAuction>?
    /// Unix timestamp of the last fill-up/renewal.
    lastFillUpTime: uint64
}

/// On-chain content cell used by the official DNS domain item.
struct DnsDomainItemContent {
    /// TEP-64 on-chain content tag; official source expects zero.
    onchainTag: uint8
    /// DNS record dictionary keyed by 256-bit category hash with record cells as values.
    dnsRecords: map<uint256, cell>
}

/// Stored active auction state.
struct DnsDomainAuction {
    /// Current highest bidder.
    maxBidAddress: address
    /// Current highest bid in nanotons.
    maxBidAmount: coins
    /// Unix timestamp when the active auction ends.
    auctionEndTime: uint64
}

/// Collection-to-item initialization body accepted while storage is uninitialized.
struct DnsDomainItemInit {
    /// Initial bidder address supplied by the DNS collection.
    bidderAddress: address
    /// Referenced domain label cell.
    domain: cell
}

/// DNS text record. The tail is the standard recursive `Text` chunk encoding.
struct (0x1eda) DnsDomainTextRecord {
    /// Raw chunked text payload after the 16-bit `dns_text` tag.
    text: RemainingBitsAndRefs
}

/// DNS delegation record pointing at the next resolver contract.
struct (0xba93) DnsDomainNextResolverRecord {
    /// Internal address of the resolver that should handle the unresolved suffix.
    resolver: address
}

/// DNS ADNL address record, usually stored under the `site` category.
struct (0xad01) DnsDomainAdnlAddressRecord {
    /// ADNL address bits.
    adnlAddress: uint256
    /// Presence flag for the trailing protocol list; the standard restricts it to 0 or 1.
    flags: uint8
    /// Raw `ProtoList` tail when `flags == 1`, otherwise empty.
    protocolList: RemainingBitsAndRefs
}

/// DNS smart-contract address record, usually stored under the `wallet` category.
struct (0x9fd3) DnsDomainSmcAddressRecord {
    /// Internal smart-contract address stored in the record.
    smartContractAddress: address
    /// Presence flag for the trailing capability list; the standard restricts it to 0 or 1.
    flags: uint8
    /// Raw `SmcCapList` tail when `flags == 1`, otherwise empty.
    capabilityList: RemainingBitsAndRefs
}

/// DNS storage record, usually stored under the `storage` category.
struct (0x7473) DnsDomainStorageAddressRecord {
    /// TON Storage bag id.
    bagId: uint256
}

/// TL-B `DNSRecord` variants stored in DNS record cells.
type DnsDomainRecord =
    | DnsDomainTextRecord
    | DnsDomainNextResolverRecord
    | DnsDomainAdnlAddressRecord
    | DnsDomainSmcAddressRecord
    | DnsDomainStorageAddressRecord

/// Owner-originated TEP-62 ownership transfer request.
struct (0x5fcc3d14) DnsDomainItemTransfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address; source restricts it to basechain.
    newOwnerAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Optional custom payload from the inherited NFT transfer layout.
    customPayload: cell?
    /// Nanotons forwarded to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated full content replacement request.
struct (0x1a0b9d51) DnsDomainItemEditContent {
    /// Caller-selected query id parsed by the common dispatcher.
    queryId: uint64
    /// New content cell with on-chain DNS record dictionary.
    content: Cell<DnsDomainItemContent>
}

/// Owner-originated DNS record update or delete request.
struct (0x4eb1f0f9) DnsDomainItemChangeDnsRecord {
    /// Caller-selected query id.
    queryId: uint64
    /// DNS category key, normally `sha256(categoryName)`.
    key: uint256
    /// Raw tail: either one referenced `DNSRecord` cell or empty to delete the key.
    value: RemainingBitsAndRefs
}

/// Governance-triggered command processed by DNS domain contracts.
struct (0x44beae41) DnsDomainItemProcessGovernanceDecision {
    /// Caller-selected query id.
    queryId: uint64
}

/// Request to release an expired DNS domain balance and restart auction flow.
struct (0x4ed14b65) DnsDomainItemBalanceRelease {
    /// Caller-selected query id copied into the corresponding response when emitted.
    queryId: uint64
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) DnsDomainItemGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Ownership assignment notification sent to a transfer target.
struct (0x05138d91) DnsDomainItemOwnershipAssigned {
    /// Query id copied from transfer requests.
    queryId: uint64
    /// Previous owner address.
    previousOwnerAddress: address
    /// Raw forwarded payload copied from the transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to the requester.
struct (0x8b771735) DnsDomainItemReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// Domain item index encoded as uint256.
    itemIndex: uint256
    /// DNS collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response sent after transfer.
struct (0xd53276db) DnsDomainItemExcesses {
    /// Query id copied from the transfer request.
    queryId: uint64
}

/// Outbid notification sent to the previous bidder during an active auction.
struct (0x557cea20) DnsDomainItemOutbidNotification {
    /// Current logical time used as the outgoing query id.
    queryId: uint64
}

/// Auction or expired-domain balance top-up sent back to the DNS collection or owner.
struct (0x370fec51) DnsDomainItemFillUp {
    /// Query id copied from the triggering request or current logical time.
    queryId: uint64
}

/// Internal message bodies accepted by the official DNS domain item.
type DnsDomainItemIncomingMessage =
    | DnsDomainItemTransfer
    | DnsDomainItemEditContent
    | DnsDomainItemChangeDnsRecord
    | DnsDomainItemProcessGovernanceDecision
    | DnsDomainItemBalanceRelease
    | DnsDomainItemGetStaticData

/// Internal message bodies emitted by the official DNS domain item.
type DnsDomainItemOutgoingMessage =
    | DnsDomainItemOwnershipAssigned
    | DnsDomainItemReportStaticData
    | DnsDomainItemExcesses
    | DnsDomainItemOutbidNotification
    | DnsDomainItemFillUp
    | DnsDomainItemBalanceRelease

/// Structured result returned by `get_nft_data`.
struct DnsDomainItemDataReply {
    /// True when runtime storage includes owner/content/domain fields.
    isInitialized: bool
    /// Domain item index returned as a TVM stack integer.
    itemIndex: int
    /// DNS collection address stored by the item.
    collectionAddress: address
    /// Current owner address, or zero address while an auction is active.
    ownerAddress: address
    /// Referenced content cell with DNS record dictionary.
    content: cell
}

/// Structured result returned by `get_auction_info`.
struct DnsDomainAuctionInfoReply {
    /// Highest bidder address, or `addr_none` when no auction is active.
    maxBidAddress: any_address
    /// Highest bid amount in nanotons.
    maxBidAmount: coins
    /// Unix timestamp when the active auction ends, or zero when absent.
    auctionEndTime: uint64
}

/// Structured result returned by the standard `dnsresolve` get method.
struct DnsDomainResolveReply {
    /// Number of bits consumed from the requested DNS subdomain.
    resolvedBits: int64
    /// DNS record cell, DNS record-set dictionary cell, or null cell depending on resolution result.
    result: cell
}

/// Source-level exit-code catalog from the official DNS domain item source.
enum DnsDomainItemErrors {
    /// DNS subdomain length is not byte-aligned.
    BadSubdomainLength = 70
    /// Domain item auction has not started yet.
    AuctionNotStarted = 199
    /// Domain label is too short.
    DomainTooShort = 200
    /// Domain label is too long.
    DomainTooLong = 201
    /// Domain label length is not byte-aligned.
    BadDomainLength = 202
    /// Domain label contains an invalid character.
    BadDomainString = 203
    /// Incoming amount is below the current minimum price.
    AmountBelowMinimum = 204
    /// Domain is already blocked by DNS config.
    DomainReservedByConfig = 205
    /// Address workchain is not basechain.
    InvalidWorkchain = 333
    /// Transfer sender is not the current owner.
    UnauthorizedTransfer = 401
    /// Remaining balance after storage, forward amount, and fees would be negative.
    InsufficientRestAmount = 402
    /// Initialization sender is not the DNS collection.
    UnauthorizedCollectionInit = 405
    /// Owner-only top-up attempted by another sender after auction end.
    UnauthorizedFillUp = 406
    /// Bid or expired-domain release amount is too small.
    BidTooSmall = 407
    /// Content replacement sender is not the current owner.
    UnauthorizedEditContent = 410
    /// DNS record change sender is not the current owner.
    UnauthorizedChangeDns = 411
    /// Content cell is not the expected on-chain DNS content shape.
    BadContentTag = 412
    /// Governance/action precondition failed, or `dnsresolve` subdomain did not start with zero byte.
    BadDnsPrecondition = 413
    /// Domain cannot be released yet.
    CannotReleaseBalance = 414
    /// Governance config entry for this domain was not found.
    GovernanceConfigNotFound = 415
    /// Governance config opcode is unsupported.
    UnsupportedGovernanceOp = 416
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return item initialization flag, index, collection, owner, and content.
get fun get_nft_data(): DnsDomainItemDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw DnsDomainItemErrors.BadSubdomainLength;
    assert (true) throw DnsDomainItemErrors.AuctionNotStarted;
    assert (true) throw DnsDomainItemErrors.DomainTooShort;
    assert (true) throw DnsDomainItemErrors.DomainTooLong;
    assert (true) throw DnsDomainItemErrors.BadDomainLength;
    assert (true) throw DnsDomainItemErrors.BadDomainString;
    assert (true) throw DnsDomainItemErrors.AmountBelowMinimum;
    assert (true) throw DnsDomainItemErrors.DomainReservedByConfig;
    assert (true) throw DnsDomainItemErrors.InvalidWorkchain;
    assert (true) throw DnsDomainItemErrors.UnauthorizedTransfer;
    assert (true) throw DnsDomainItemErrors.InsufficientRestAmount;
    assert (true) throw DnsDomainItemErrors.UnauthorizedCollectionInit;
    assert (true) throw DnsDomainItemErrors.UnauthorizedFillUp;
    assert (true) throw DnsDomainItemErrors.BidTooSmall;
    assert (true) throw DnsDomainItemErrors.UnauthorizedEditContent;
    assert (true) throw DnsDomainItemErrors.UnauthorizedChangeDns;
    assert (true) throw DnsDomainItemErrors.BadContentTag;
    assert (true) throw DnsDomainItemErrors.BadDnsPrecondition;
    assert (true) throw DnsDomainItemErrors.CannotReleaseBalance;
    assert (true) throw DnsDomainItemErrors.GovernanceConfigNotFound;
    assert (true) throw DnsDomainItemErrors.UnsupportedGovernanceOp;
    assert (true) throw DnsDomainItemErrors.UnsupportedOperation;
    return {
        isInitialized: false,
        itemIndex: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        content: createEmptyCell(),
    };
}

/// Return the current DNS domain item editor/owner address.
get fun get_editor(): any_address {
    return createAddressNone();
}

/// Return the domain label slice stored by the item.
get fun get_domain(): slice {
    return createEmptyCell().beginParse();
}

/// Return active auction information, or zero values with `addr_none` when no auction is active.
get fun get_auction_info(): DnsDomainAuctionInfoReply {
    return {
        maxBidAddress: createAddressNone(),
        maxBidAmount: 0,
        auctionEndTime: 0,
    };
}

/// Return the unix timestamp of the last fill-up/renewal.
get fun get_last_fill_up_time(): int64 {
    return 0;
}

/// Resolve a DNS subdomain/category pair through the item's DNS record dictionary.
get fun dnsresolve(subdomain: slice, category: int): DnsDomainResolveReply {
    return {
        resolvedBits: 0,
        result: createEmptyCell(),
    };
}
