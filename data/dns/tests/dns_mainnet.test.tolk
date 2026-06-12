import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/dns_collection.types"
import "../types/dns_domain_item.types"
import "../types/dns_root_resolver.types"
import "../wrappers/DnsCollection.gen"
import "../wrappers/DnsDomainItem.gen"
import "../wrappers/DnsRootResolver.gen"

const DNS_COLLECTION_FIXTURE_BOC_PATH = "data/dns/testdata/DnsCollection.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DNS_COLLECTION_CODE_HASH = 0xeec5bbc25065628799468860d8fd48031585f649c32fa382c888ba48831625a3
const EXPECTED_DNS_COLLECTION_DATA_HASH = 0x49431e32a3fe3fbc923b60b3f77dc771de2a41a15640b64db71c847227fe2e6c

fun hasDnsBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

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

get fun `test dns collection code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(DNS_COLLECTION_FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasDnsBocMagic(rawBoc!)).toBeTrue();

    val code = build("DnsCollection", DNS_COLLECTION_FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_DNS_COLLECTION_CODE_HASH);

    println("DNS_COLLECTION_CODE_HASH={}", code.hash());
}

get fun `test dns collection mainnet getters storage and dnsresolve`() {
    val collection = mainnetDnsCollection();
    val foundationItem = mainnetDnsFoundationItem();
    val storage = loadDnsCollectionStorageFromFork(collection);
    val collectionData = collection.getCollectionData();
    val content = storage.collectionContent.load();
    val foundationStorage = loadDnsDomainItemStorageFromFork(foundationItem);
    val foundationAddress = collection.getNftAddressByIndex(foundationStorage.itemIndex as int);
    val resolved = collection.dnsresolve(dnsFoundationSubdomain(), 0);
    val nextResolver = DnsCollectionNextResolverRecord.fromCell(resolved.result);
    val rootResolved = collection.dnsresolve(dnsSelfSubdomain(), 0);
    val individualContent = collection.getNftContent(foundationStorage.itemIndex as int, foundationStorage.content);

    expect(scripts.isContractDeployed(collection.address)).toBeTrue();
    expect(build("DnsCollection", DNS_COLLECTION_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DNS_COLLECTION_CODE_HASH);
    expect(storage.toCell().hash()).toEqual(EXPECTED_DNS_COLLECTION_DATA_HASH);
    expect(collectionData.nextItemIndex).toEqual(-1);
    expect(collectionData.collectionContent.hash()).toEqual(storage.collectionContent.hash());
    expect(collectionData.ownerAddress).toBeNoneAddress();
    expect(content.offchainTag).toEqual(1);
    expect(storage.nftItemCode.hash()).toEqual(build("DnsDomainItem", "data/dns/testdata/DnsDomainItem.boc").hash());
    expect(foundationAddress).toEqual(foundationItem.address);
    expect(resolved.resolvedBits).toEqual(80);
    expect(nextResolver.resolver).toEqual(foundationItem.address);
    expect(rootResolved.resolvedBits).toEqual(8);
    expect(individualContent.hash()).toEqual(foundationStorage.content.hash());

    println("DNS_COLLECTION_ADDRESS={}", collection.address);
    println("DNS_COLLECTION_STORAGE={}", storage);
    println("DNS_COLLECTION_DATA={}", collectionData);
    println("DNS_COLLECTION_FOUNDATION_ADDRESS={}", foundationAddress);
    println("DNS_COLLECTION_RESOLVE_FOUNDATION={}", resolved);
    println("DNS_COLLECTION_ROOT_RESOLVE={}", rootResolved);
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
    expect(storage.ownerAddress).toBeNotNull();
    expect(data.ownerAddress.castToInternal()).toEqual(storage.ownerAddress!);
    expect(data.content.hash()).toEqual(storage.content.hash());
    expect(editor.castToInternal()).toEqual(storage.ownerAddress!);
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

get fun `test dns domain item mainnet auction storage uses addr none owner`() {
    val item = mainnetDnsAuctionItem();
    val storage = loadDnsDomainItemStorageFromFork(item);
    val data = item.getNftData();
    val editor = item.getEditor();
    val domain = item.getDomain();
    val auctionInfo = item.getAuctionInfo();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(storage.ownerAddress).toBeNull();
    expect(data.ownerAddress).toBeNoneAddress();
    expect(editor).toBeNoneAddress();
    expect(storage.auction).toBeNotNull();
    expect(auctionInfo.maxBidAddress.castToInternal()).toEqual(storage.auction!.load().maxBidAddress);
    expect(auctionInfo.maxBidAmount).toEqual(storage.auction!.load().maxBidAmount);
    expect(auctionInfo.auctionEndTime).toEqual(storage.auction!.load().auctionEndTime);

    println("DNS_DOMAIN_AUCTION_ITEM_ADDRESS={}", item.address);
    println("DNS_DOMAIN_AUCTION_ITEM_STORAGE={}", storage);
    println("DNS_DOMAIN_AUCTION_ITEM_DATA={}", data);
    println("DNS_DOMAIN_AUCTION_ITEM_DOMAIN={}", domain);
    println("DNS_DOMAIN_AUCTION_ITEM_AUCTION={}", auctionInfo);
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
