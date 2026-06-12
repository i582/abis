import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dns_domain_item.types"
import "../wrappers/DnsDomainItem.gen"
import "../wrappers/DnsRootResolver.gen"

const MAINNET_DNS_ROOT_RESOLVER_ADDRESS = "Ef_lZ1T4NCb2mwkme9h2rJfESCE0W34ma9lWp7-_uY3zXDvq"
const MAINNET_DNS_FOUNDATION_ITEM_ADDRESS = "EQB43-VCmf17O7YMd51fAvOjcMkCw46N_3JMCoegH_ZDo40e"
const MAINNET_DNS_AUCTION_ITEM_ADDRESS = "EQAPA39ZpqDXHsT0FJ1KQ3rhXTn7UctxiIeZ6aX8s7VEYguv"

fun mainnetDnsRootResolver(): DnsRootResolver {
    return DnsRootResolver.fromAddress(address(MAINNET_DNS_ROOT_RESOLVER_ADDRESS));
}

fun mainnetDnsFoundationItem(): DnsDomainItem {
    return DnsDomainItem.fromAddress(address(MAINNET_DNS_FOUNDATION_ITEM_ADDRESS));
}

fun mainnetDnsAuctionItem(): DnsDomainItem {
    return DnsDomainItem.fromAddress(address(MAINNET_DNS_AUCTION_ITEM_ADDRESS));
}

fun dnsTonRootSubdomain(): slice {
    return beginCell().storeUint(0x746f6e00, 32).endCell().beginParse();
}

fun dnsSelfSubdomain(): slice {
    return beginCell().storeUint(0, 8).endCell().beginParse();
}

fun dnsInlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun loadDnsDomainItemStorageFromFork(item: DnsDomainItem): DnsDomainItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return DnsDomainItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DNS domain item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DNS domain item mainnet fixture account is frozen");
        }
    }
}
