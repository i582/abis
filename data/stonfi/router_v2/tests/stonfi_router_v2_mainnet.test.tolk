import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_router_v2.types"
import "../wrappers/StonfiRouterV2.gen"

const FIXTURE_BOC_PATH = "data/stonfi/router_v2/testdata/StonfiRouterV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa7e2f92c4bccbdbaaa0c083aa1da9762b52023134234adeb3b7bc8e72dbd1182
const PINNED_MAINNET_BLOCK = 71167154

const MAINNET_STONFI_ROUTER_V2_ADDRESS = "EQCS4UEa5UaJLzOyyKieqQOQ2P9M-7kXpkO5HnP3Bv250cN3"
const MAINNET_POOL_TOKEN0_WALLET = "EQCSLWJ9fY7b0A5OI72wxUp27l4fRlc6GvRBeFf6PiPpH4p3"
const MAINNET_POOL_TOKEN1_WALLET = "EQCSIMGBps_qzRG3uPYhON8bucyCtu0mYdL1-u4gSz77IBa3"
const MAINNET_CONST_PRODUCT_POOL = "EQCGScrZe1xbyWqWDvdI6mzP-GAcAWFv6ZXuaJOuSqemxku4"
const MAINNET_VAULT_OWNER = "EQAiQHPch9EQA2EibZoczqqJ0bgkm9m5sixgE7NdIXD7S3bf"
const MAINNET_VAULT_TOKEN_WALLET = MAINNET_POOL_TOKEN0_WALLET
const MAINNET_REFERRAL_VAULT = "EQBCFLAnWCc_heRtp78zmT_1h2XhyX7wcEwaiNHry27Mtxw6"

fun mainnetStonfiRouterV2(): StonfiRouterV2 {
    return StonfiRouterV2.fromAddress(address(MAINNET_STONFI_ROUTER_V2_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiRouterV2StorageFromFork(router: StonfiRouterV2): StonfiRouterV2Storage {
    val account = testing.getAccountState(router.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiRouterV2", FIXTURE_BOC_PATH).hash());
            return StonfiRouterV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Router v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Router v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi router v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StonfiRouterV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi router v2 mainnet getters storage and derived addresses`() {
    val router = mainnetStonfiRouterV2();
    val storage = loadStonfiRouterV2StorageFromFork(router);
    val staticData = storage.staticData.load();
    val routerData = router.getRouterData();
    val routerVersion = router.getRouterVersion();
    val upgradedPoolCode = router.getUpgradedPoolCode();
    val poolAddress = router.getPoolAddress(
        address(MAINNET_POOL_TOKEN0_WALLET),
        address(MAINNET_POOL_TOKEN1_WALLET),
    );
    val vaultAddress = router.getVaultAddress(
        address(MAINNET_VAULT_OWNER),
        address(MAINNET_VAULT_TOKEN_WALLET),
    );

    expect(scripts.isContractDeployed(router.address)).toBeTrue();

    expect(routerData.id).toEqual(staticData.id);
    expect(routerData.dexType).toEqual("constant_product");
    expect(routerData.isLocked).toEqual(storage.isLocked);
    expect(routerData.adminAddress).toEqual(storage.adminAddress);
    expect(routerData.tempUpgrade.hash()).toEqual(storage.tempUpgrade.hash());
    expect(routerData.poolCode.hash()).toEqual(staticData.poolCode.hash());
    expect(routerData.jettonLpWalletCode.hash()).toEqual(staticData.jettonLpWalletCode.hash());
    expect(routerData.lpAccountCode.hash()).toEqual(staticData.lpAccountCode.hash());
    expect(routerData.vaultCode.hash()).toEqual(staticData.vaultCode.hash());
    expect(upgradedPoolCode.hash()).toEqual(storage.upgradePoolCode.hash());

    expect(routerVersion.major).toEqual(2);
    expect(routerVersion.minor).toEqual(2);
    expect(routerVersion.development).toEqual("release");

    expect(poolAddress).toEqual(address(MAINNET_CONST_PRODUCT_POOL));
    expect(vaultAddress).toEqual(address(MAINNET_REFERRAL_VAULT));

    println("STONFI_ROUTER_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_ROUTER_V2_ADDRESS={}", router.address);
    println("STONFI_ROUTER_V2_STORAGE={}", storage);
    println("STONFI_ROUTER_V2_ROUTER_DATA={}", routerData);
    println("STONFI_ROUTER_V2_ROUTER_VERSION={}", routerVersion);
    println("STONFI_ROUTER_V2_POOL_ADDRESS={}", poolAddress);
    println("STONFI_ROUTER_V2_VAULT_ADDRESS={}", vaultAddress);
}
