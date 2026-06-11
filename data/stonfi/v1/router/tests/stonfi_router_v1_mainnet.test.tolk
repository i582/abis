import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_router_v1.types"
import "../wrappers/StonfiRouterV1.gen"

const FIXTURE_BOC_PATH = "data/stonfi/v1/router/testdata/StonfiRouterV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x276f7c2058931d4685750a9856a5ac2dfa04d1b83c932d1e429fa3ceecd42faf
const PINNED_MAINNET_BLOCK = 71167154

const MAINNET_STONFI_ROUTER_V1_ADDRESS = "EQB3ncyBUTjZUA5EnFKR5_EnOMI9V1tTEAAPaiU71gc4TiUt"
const MAINNET_SWAP_TOKEN0_WALLET = "0:306CF19A0860B02ECB4079142F34C59A602DABFBCDEE122EA31917152314BCB1"
const MAINNET_SWAP_TOKEN1_WALLET = "0:4EEC921B9D4D56A0D94676016D49C26B39B1D7901A7E153E66033F146A0886F4"
const MAINNET_SWAP_POOL = "0:FB018F68BFBBAB4E8BB4EBDC8E377EA91F43A477E6E9775871631039F92A79E0"

fun mainnetStonfiRouterV1(): StonfiRouterV1 {
    return StonfiRouterV1.fromAddress(address(MAINNET_STONFI_ROUTER_V1_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiRouterV1StorageFromFork(router: StonfiRouterV1): StonfiRouterV1Storage {
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
            expect(code!.hash()).toEqual(build("StonfiRouterV1", FIXTURE_BOC_PATH).hash());
            return StonfiRouterV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Router v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Router v1 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi router v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StonfiRouterV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi router v1 mainnet getters storage and derived pool address`() {
    val router = mainnetStonfiRouterV1();
    val storage = loadStonfiRouterV1StorageFromFork(router);
    val routerData = router.getRouterData();
    val poolAddress = router.getPoolAddress(
        address(MAINNET_SWAP_TOKEN0_WALLET),
        address(MAINNET_SWAP_TOKEN1_WALLET),
    );

    expect(scripts.isContractDeployed(router.address)).toBeTrue();

    expect(routerData.isLocked).toEqual(storage.isLocked == 1);
    expect(routerData.adminAddress).toEqual(storage.adminAddress);
    expect(routerData.tempUpgrade.hash()).toEqual(storage.tempUpgrade.hash());
    expect(routerData.poolCode.hash()).toEqual(storage.poolCode.hash());
    expect(routerData.jettonLpWalletCode.hash()).toEqual(storage.jettonLpWalletCode.hash());
    expect(routerData.lpAccountCode.hash()).toEqual(storage.lpAccountCode.hash());
    expect(poolAddress).toEqual(address(MAINNET_SWAP_POOL));

    println("STONFI_ROUTER_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_ROUTER_V1_ADDRESS={}", router.address);
    println("STONFI_ROUTER_V1_STORAGE={}", storage);
    println("STONFI_ROUTER_V1_ROUTER_DATA={}", routerData);
    println("STONFI_ROUTER_V1_POOL_ADDRESS={}", poolAddress);
}
