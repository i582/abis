/// Standard TON DNS resolver interface for root and delegated resolver contracts.
contract DnsRootResolver {
    author: "TON"
    version: "1.0"
    description: "Curated TON DNS resolver get-method interface"
    forceAbiExport: DnsRootRecord
}

/// DNS text record. The tail is the standard recursive `Text` chunk encoding.
struct (0x1eda) DnsRootTextRecord {
    /// Raw chunked text payload after the 16-bit `dns_text` tag.
    text: RemainingBitsAndRefs
}

/// DNS delegation record pointing at the next resolver contract.
struct (0xba93) DnsRootNextResolverRecord {
    /// Internal address of the resolver that should handle the unresolved suffix.
    resolver: address
}

/// DNS ADNL address record, usually stored under the `site` category.
struct (0xad01) DnsRootAdnlAddressRecord {
    /// ADNL address bits.
    adnlAddress: uint256
    /// Presence flag for the trailing protocol list; the standard restricts it to 0 or 1.
    flags: uint8
    /// Raw `ProtoList` tail when `flags == 1`, otherwise empty.
    protocolList: RemainingBitsAndRefs
}

/// DNS smart-contract address record, usually stored under the `wallet` category.
struct (0x9fd3) DnsRootSmcAddressRecord {
    /// Internal smart-contract address stored in the record.
    smartContractAddress: address
    /// Presence flag for the trailing capability list; the standard restricts it to 0 or 1.
    flags: uint8
    /// Raw `SmcCapList` tail when `flags == 1`, otherwise empty.
    capabilityList: RemainingBitsAndRefs
}

/// DNS storage record, usually stored under the `storage` category.
struct (0x7473) DnsRootStorageAddressRecord {
    /// TON Storage bag id.
    bagId: uint256
}

/// TL-B `DNSRecord` variants returned by `dnsresolve` result cells.
type DnsRootRecord =
    | DnsRootTextRecord
    | DnsRootNextResolverRecord
    | DnsRootAdnlAddressRecord
    | DnsRootSmcAddressRecord
    | DnsRootStorageAddressRecord

/// Structured result returned by the standard `dnsresolve` get method.
struct DnsRootResolveReply {
    /// Number of bits consumed from the requested DNS subdomain.
    resolvedBits: int64
    /// DNS record cell, DNS record-set dictionary cell, or null cell depending on resolution result.
    result: cell
}

/// Resolve a byte-aligned DNS subdomain/category pair.
get fun dnsresolve(subdomain: slice, category: int): DnsRootResolveReply {
    throw 0;
}
