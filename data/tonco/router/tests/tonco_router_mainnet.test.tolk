import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonco_router.types"
import "../wrappers/ToncoRouter.gen"

const FIXTURE_BOC_PATH = "data/tonco/router/testdata/ToncoRouter.boc"
const POOL_FIXTURE_BOC_PATH = "data/tonco/pool/testdata/ToncoPool.boc"
const ACCOUNT_FIXTURE_BOC_PATH = "data/tonco/account/testdata/ToncoAccount.boc"
const POSITION_NFT_FIXTURE_BOC_PATH = "data/tonco/position_nft_v3/testdata/ToncoPositionNftV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9b9891eaa7db7becc6ccdda1bd9a8d25dc3df2817d57e4b27ec003daf81a4439
const EXPECTED_POOL_CODE_HASH = 0xbc947d16346c2fdc845b7a446382f59c86acb075e2a31dbfa956cd0c9e54678e
const EXPECTED_ACCOUNT_CODE_HASH = 0xa820f670f18a3afa05c5acb0f85e248c97b01b4d846aeeac4730622b832a8c20
const EXPECTED_POSITION_NFT_CODE_HASH = 0x23091475641789bbbd415b0396a1f0a7a22701086c99dab178a353fc04ce7983
const PINNED_MAINNET_BLOCK = 71245765

const MAINNET_TONCO_ROUTER_ADDRESS = "EQC_-t0nCnOFMdp7E7qPxAOCbCWGFz-e3pwxb6tTvFmshjt5"
const MAINNET_TONCO_POOL_FACTORY_ADDRESS = "EQCXrVg3we6FKI4NKjBe9vlJKM5aGcDQB61LdfI_KmN_2Kj2"
const MAINNET_TONCO_POOL_ADDRESS = "EQBk33mIwYXYAytv4beERPqjfdNHaQuSfpaRY7KmNmHqpVLY"
const MAINNET_TONCO_POOL_TOKEN0_WALLET = "EQCF6CLf33voJEJ04jmb3ZXlEOhtfjXRoFTSoKmTisgWoOqy"
const MAINNET_TONCO_POOL_TOKEN1_WALLET = "EQCHHakhWxSQIWbw6ioW21YnjVKBCDd_gVjF9Mz9_dIuFy23"

fun mainnetToncoRouter(): ToncoRouter {
    return ToncoRouter.fromAddress(address(MAINNET_TONCO_ROUTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadToncoRouterStorageFromFork(router: ToncoRouter): ToncoRouterStorage {
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
            expect(code!.hash()).toEqual(build("ToncoRouter", FIXTURE_BOC_PATH).hash());
            return ToncoRouterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TONCO Router mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TONCO Router mainnet fixture account is frozen");
        }
    }
}

get fun `test tonco router code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("ToncoRouter", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonco router mainnet getters storage and derived pool`() {
    val router = mainnetToncoRouter();
    val storage = loadToncoRouterStorageFromFork(router);
    val childContracts = storage.childContracts.load();
    val routerState = router.getRouterState();
    val childReply = router.getChildContracts();
    val poolAddress = router.getPoolAddress(
        address(MAINNET_TONCO_POOL_TOKEN0_WALLET),
        address(MAINNET_TONCO_POOL_TOKEN1_WALLET),
    );
    val poolInitialData = router.getPoolInitialData(
        address(MAINNET_TONCO_POOL_TOKEN0_WALLET),
        address(MAINNET_TONCO_POOL_TOKEN1_WALLET),
    );
    val poolStateInit = router.getPoolStateInit(
        address(MAINNET_TONCO_POOL_TOKEN0_WALLET),
        address(MAINNET_TONCO_POOL_TOKEN1_WALLET),
    );

    expect(scripts.isContractDeployed(router.address)).toBeTrue();

    expect(storage.adminAddress).toEqual(routerState.routerAdminAddress);
    expect(storage.poolAdminAddress).toEqual(routerState.poolAdminAddress);
    expect(storage.poolFactoryAddress).toEqual(address(MAINNET_TONCO_POOL_FACTORY_ADDRESS));
    expect(routerState.poolFactoryAddress).toEqual(address(MAINNET_TONCO_POOL_FACTORY_ADDRESS));
    expect(routerState.activeFlags).toEqual(storage.flags as int);
    expect(routerState.poolSeqno).toEqual(storage.poolSeqno as int);

    expect(childReply.poolCode.hash()).toEqual(childContracts.poolv3Code.hash());
    expect(childReply.accountCode.hash()).toEqual(childContracts.accountv3Code.hash());
    expect(childReply.positionNftCode.hash()).toEqual(childContracts.positionNftv3Code.hash());
    expect(childReply.poolCode.hash()).toEqual(EXPECTED_POOL_CODE_HASH);
    expect(childReply.accountCode.hash()).toEqual(EXPECTED_ACCOUNT_CODE_HASH);
    expect(childReply.positionNftCode.hash()).toEqual(EXPECTED_POSITION_NFT_CODE_HASH);
    expect(childReply.poolCode.hash()).toEqual(build("ToncoPool", POOL_FIXTURE_BOC_PATH).hash());
    expect(childReply.accountCode.hash()).toEqual(
        build("ToncoAccount", ACCOUNT_FIXTURE_BOC_PATH).hash(),
    );
    expect(childReply.positionNftCode.hash()).toEqual(
        build("ToncoPositionNftV3", POSITION_NFT_FIXTURE_BOC_PATH).hash(),
    );

    expect(poolAddress).toEqual(address(MAINNET_TONCO_POOL_ADDRESS));
    expect(poolInitialData.hash()).toBeGreater(0);
    expect(poolStateInit.hash()).toBeGreater(0);

    println("TONCO_ROUTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONCO_ROUTER_ADDRESS={}", router.address);
    println("TONCO_ROUTER_STORAGE={}", storage);
    println("TONCO_ROUTER_STATE={}", routerState);
    println("TONCO_ROUTER_POOL_ADDRESS={}", poolAddress);
}
