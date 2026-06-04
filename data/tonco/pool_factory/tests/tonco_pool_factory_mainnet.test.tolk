import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonco_pool_factory.types"
import "../wrappers/ToncoPoolFactory.gen"

const FIXTURE_BOC_PATH = "data/tonco/pool_factory/testdata/ToncoPoolFactory.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb5b46a506af6a118fe1a1853f43dc3d53d65c36a3c2ad5722feef343ecb7b857
const PINNED_MAINNET_BLOCK = 71245765

const MAINNET_TONCO_POOL_FACTORY_ADDRESS = "EQCXrVg3we6FKI4NKjBe9vlJKM5aGcDQB61LdfI_KmN_2Kj2"
const MAINNET_TONCO_ROUTER_ADDRESS = "EQC_-t0nCnOFMdp7E7qPxAOCbCWGFz-e3pwxb6tTvFmshjt5"
const MAINNET_TONCO_ORDER_ADDRESS = "EQDzWTF1G0Fb9Nm1tBqO_gq2KfZd_pUa8yw0Q-In76ByNx4G"
const MAINNET_TONCO_POOL_TOKEN0_WALLET = "EQCF6CLf33voJEJ04jmb3ZXlEOhtfjXRoFTSoKmTisgWoOqy"
const MAINNET_TONCO_POOL_TOKEN1_WALLET = "EQCHHakhWxSQIWbw6ioW21YnjVKBCDd_gVjF9Mz9_dIuFy23"

fun mainnetToncoPoolFactory(): ToncoPoolFactory {
    return ToncoPoolFactory.fromAddress(address(MAINNET_TONCO_POOL_FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadToncoPoolFactoryStorageFromFork(factory: ToncoPoolFactory): ToncoPoolFactoryStorage {
    val account = testing.getAccountState(factory.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("ToncoPoolFactory", FIXTURE_BOC_PATH).hash());
            return ToncoPoolFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TONCO PoolFactory mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TONCO PoolFactory mainnet fixture account is frozen");
        }
    }
}

get fun `test tonco pool factory code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("ToncoPoolFactory", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonco pool factory mainnet getters storage and order address`() {
    val factory = mainnetToncoPoolFactory();
    val storage = loadToncoPoolFactoryStorageFromFork(factory);
    val data = factory.getPoolFactoryData();
    val whitelist = factory.getWhitelist();
    val orderAddress = factory.getOrderAddress(
        address(MAINNET_TONCO_POOL_TOKEN0_WALLET),
        address(MAINNET_TONCO_POOL_TOKEN1_WALLET),
    );

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();

    expect(data.adminAddress).toEqual(storage.adminAddress);
    expect(data.routerAddress).toEqual(storage.routerAddress);
    expect(data.routerAddress).toEqual(address(MAINNET_TONCO_ROUTER_ADDRESS));
    expect(data.tonPrice).toEqual(storage.tonPrice as int);
    expect(data.nftv3Content.hash()).toEqual(storage.nftv3Content.hash());
    expect(data.nftv3itemContent.hash()).toEqual(storage.nftv3itemContent.hash());
    expect(storage.orderCode.hash()).toBeGreater(0);

    if (storage.whitelist == null) {
        expect(whitelist).toBeNull();
    } else {
        expect(whitelist).toBeNotNull();
        expect(whitelist!.hash()).toEqual(storage.whitelist!.hash());
    }

    expect(orderAddress.orderAddress).toEqual(address(MAINNET_TONCO_ORDER_ADDRESS));

    println("TONCO_POOL_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONCO_POOL_FACTORY_ADDRESS={}", factory.address);
    println("TONCO_POOL_FACTORY_STORAGE={}", storage);
    println("TONCO_POOL_FACTORY_DATA={}", data);
    println("TONCO_POOL_FACTORY_ORDER_ADDRESS={}", orderAddress);
}
