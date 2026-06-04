import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/dns_domain_item.types"
import "../types/dns_root_resolver.types"
import "../wrappers/DnsDomainItem.gen"
import "../wrappers/DnsRootResolver.gen"
import "./test_utils"

get fun `test dns root resolver mainnet dnsresolve delegates ton zone`() {
    val root = mainnetDnsRootResolver();
    val result = root.dnsresolve(dnsTonRootSubdomain(), 0);
    val nextResolver = DnsRootNextResolverRecord.fromCell(result.result);

    expect(scripts.isContractDeployed(root.address)).toBeTrue();
    expect(result.resolvedBits).toEqual(24);

    println("DNS_ROOT_RESOLVER_ADDRESS={}", root.address);
    println("DNS_ROOT_RESOLVE_TON={}", result);
    println("DNS_ROOT_NEXT_RESOLVER={}", nextResolver);
}

get fun `test dns domain item mainnet getters storage and dnsresolve`() {
    val item = mainnetDnsFoundationItem();
    val storage = loadDnsDomainItemStorageFromFork(item);
    val content = storage.content.load();
    val data = item.getNftData();
    val editor = item.getEditor();
    val domain = item.getDomain();
    val auctionInfo = item.getAuctionInfo();
    val lastFillUpTime = item.getLastFillUpTime();
    val resolved = item.dnsresolve(dnsSelfSubdomain(), 0);

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.content.hash()).toEqual(storage.content.hash());
    expect(editor.castToInternal()).toEqual(storage.ownerAddress);
    expect(content.onchainTag).toEqual(0);
    expect(lastFillUpTime).toEqual(storage.lastFillUpTime as int64);
    expect(resolved.resolvedBits).toEqual(8);

    println("DNS_DOMAIN_ITEM_ADDRESS={}", item.address);
    println("DNS_DOMAIN_ITEM_STORAGE={}", storage);
    println("DNS_DOMAIN_ITEM_DATA={}", data);
    println("DNS_DOMAIN_ITEM_DOMAIN={}", domain);
    println("DNS_DOMAIN_ITEM_AUCTION={}", auctionInfo);
    println("DNS_DOMAIN_ITEM_RESOLVE_SELF={}", resolved);
}

get fun `test dns domain item rejects unauthorized transfer`() {
    val item = mainnetDnsFoundationItem();
    val sender = testing.treasury("dns-domain-item-unauthorized-transfer");
    val before = item.getNftData();

    val txs = item.sendDnsDomainItemTransfer(
        sender.address,
        2,
        sender.address,
        sender.address,
        null,
        0,
        dnsInlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<DnsDomainItemTransfer>({
        from: sender.address,
        to: item.address,
        exitCode: DnsDomainItemErrors.UnauthorizedTransfer,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}
