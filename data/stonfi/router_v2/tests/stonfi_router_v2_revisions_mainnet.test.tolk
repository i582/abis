import "@acton/build"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_router_v2.types"
import "../wrappers/StonfiRouterV2.gen"

const PINNED_MAINNET_BLOCK = 83585844

const ROUTER_F451DD_ADDRESS = "EQAz1D0ZUiG_9XCyjrJ1-xTx-CnmnQ3J3LMKQ7sZTr-XlNZP"
const ROUTER_4895B7_ADDRESS = "EQBqgCTdrtSod76UrcOeALSiLCp3WuNIFQBQvyjjlQMvwLkc"
const ROUTER_5C327A_ADDRESS = "EQD11suHkrO_1Mb5IIdYFx5ZPy38MuHoeHx6dA-QRaD8w0UJ"
const ROUTER_F9502B_ADDRESS = "EQC67o2-2UzR1cJFrUGL5M7OAnLgG8oY_tHaTgGmR63LQNV-"
const ROUTER_C39A85_ADDRESS = "EQAsa5p_UWxUDaU9n9bo3CAv2xRNrNFjadhm70JQAesdVt_5"
const ROUTER_5A1963_ADDRESS = "0:5df6f7d67e7e8c3aa0581046057b216a962398967d739c59257e9f01d36ce54b"
const DERIVATION_TOKEN0_WALLET = "EQCSLWJ9fY7b0A5OI72wxUp27l4fRlc6GvRBeFf6PiPpH4p3"
const DERIVATION_TOKEN1_WALLET = "EQCSIMGBps_qzRG3uPYhON8bucyCtu0mYdL1-u4gSz77IBa3"
const DERIVATION_VAULT_OWNER = "EQAiQHPch9EQA2EibZoczqqJ0bgkm9m5sixgE7NdIXD7S3bf"

fun verifyRouterRevision(
    routerAddress: address,
    fixtureCode: cell,
    expectedCodeHash: int,
    expectedDexType: string,
    expectedDevelopment: string,
) {
    expect(fixtureCode.hash()).toEqual(expectedCodeHash);

    val account = testing.getAccountState(routerAddress);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(expectedCodeHash);
            expect(code!.hash()).toEqual(fixtureCode.hash());

            val storage = StonfiRouterV2Storage.fromCell(data!);
            val staticData = storage.staticData.load();
            val router = StonfiRouterV2.fromAddress(routerAddress);
            val routerData = router.getRouterData();
            val routerVersion = router.getRouterVersion();
            val upgradedPoolCode = router.getUpgradedPoolCode();
            val poolAddress = router.getPoolAddress(
                address(DERIVATION_TOKEN0_WALLET),
                address(DERIVATION_TOKEN1_WALLET),
            );
            val vaultAddress = router.getVaultAddress(
                address(DERIVATION_VAULT_OWNER),
                address(DERIVATION_TOKEN0_WALLET),
            );

            expect(routerData.id).toEqual(staticData.id);
            expect(routerData.dexType).toEqual(expectedDexType);
            expect(routerData.isLocked).toEqual(storage.isLocked);
            expect(routerData.adminAddress).toEqual(storage.adminAddress);
            expect(routerData.tempUpgrade.hash()).toEqual(storage.tempUpgrade.hash());
            expect(routerData.poolCode.hash()).toEqual(staticData.poolCode.hash());
            expect(routerData.jettonLpWalletCode.hash()).toEqual(
                staticData.jettonLpWalletCode.hash(),
            );
            expect(routerData.lpAccountCode.hash()).toEqual(staticData.lpAccountCode.hash());
            expect(routerData.vaultCode.hash()).toEqual(staticData.vaultCode.hash());
            expect(upgradedPoolCode.hash()).toEqual(storage.upgradePoolCode.hash());
            expect(poolAddress).toNotEqual(routerAddress);
            expect(vaultAddress).toNotEqual(routerAddress);

            expect(routerVersion.major).toEqual(2);
            expect(routerVersion.minor).toEqual(2);
            expect(routerVersion.development).toEqual(expectedDevelopment);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Router v2 revision account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Router v2 revision account is frozen");
        }
    }
}

get fun `test stonfi router v2 f451dd weighted stableswap revision`() {
    verifyRouterRevision(
        address(ROUTER_F451DD_ADDRESS),
        build("StonfiRouterV2", "data/stonfi/router_v2/testdata/StonfiRouterV2_f451dd29.boc"),
        0xf451dd294a06530b6e4ec99790a595c1ac421829f78b9231245f8b51cba72556,
        "weighted_stableswap",
        "release",
    );
}

get fun `test stonfi router v2 4895b7 stableswap revision`() {
    verifyRouterRevision(
        address(ROUTER_4895B7_ADDRESS),
        build("StonfiRouterV2", "data/stonfi/router_v2/testdata/StonfiRouterV2_4895b7fc.boc"),
        0x4895b7fc5908648bcc77aad2373eae0526c4780a426ffd444c249230116791ce,
        "stableswap",
        "release",
    );
}

get fun `test stonfi router v2 5c327a constant product revision`() {
    verifyRouterRevision(
        address(ROUTER_5C327A_ADDRESS),
        build("StonfiRouterV2", "data/stonfi/router_v2/testdata/StonfiRouterV2_5c327aef.boc"),
        0x5c327aefd0f71a8c71a907f95e4655e4e72d403e118f255356075a0e8d6db547,
        "constant_product",
        "release",
    );
}

get fun `test stonfi router v2 f9502b constant product revision`() {
    verifyRouterRevision(
        address(ROUTER_F9502B_ADDRESS),
        build("StonfiRouterV2", "data/stonfi/router_v2/testdata/StonfiRouterV2_f9502b55.boc"),
        0xf9502b55cf962dac6d86af158405af50b281fb110cabfafb9a198db46f75b154,
        "constant_product",
        "release",
    );
}

get fun `test stonfi router v2 c39a85 constant product rev1 revision`() {
    verifyRouterRevision(
        address(ROUTER_C39A85_ADDRESS),
        build("StonfiRouterV2", "data/stonfi/router_v2/testdata/StonfiRouterV2_c39a85ac.boc"),
        0xc39a85ac98055c68309bcc6570432d88cc68a586e0dec124b607564a12cec3eb,
        "constant_product",
        "rev1",
    );
}

get fun `test stonfi router v2 5a1963 constant product rev1 revision`() {
    verifyRouterRevision(
        address(ROUTER_5A1963_ADDRESS),
        build("StonfiRouterV2", "data/stonfi/router_v2/testdata/StonfiRouterV2_5a19635c.boc"),
        0x5a19635c1dc8780c352c18b7cd6c2b0e6835ca4b9926608119cb032d12719aaa,
        "constant_product",
        "rev1",
    );
}

get fun `test stonfi router v2 revision suite records pinned block`() {
    expect(PINNED_MAINNET_BLOCK).toEqual(83585844);
}
