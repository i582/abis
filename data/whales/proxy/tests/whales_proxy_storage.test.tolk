import "@acton/build"
import "@acton/emulation/testing"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/whales_proxy.types"
import "../wrappers/WhalesProxy.gen"

const CODE_FIXTURE_BOC_PATH = "data/whales/proxy/testdata/WhalesProxy.boc"
const DATA_FIXTURE_BOC_PATH = "data/whales/proxy/testdata/WhalesProxy.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x6097b64a3b9db526a6b26497afeae3f224a8f639d37b6534d46df21fe0589c21
const EXPECTED_DATA_HASH = 0xd84f88e5d563659d6f9bb16715f4583bfa71e41c10f11fd7f8cbffaab3af381e
const EXPECTED_TAIL = 18317754388212709697
const PINNED_MAINNET_BLOCK = 71810991

const MAINNET_WHALES_PROXY_ADDRESS = "Ef8W1vCpA1tr9xr6QSXSxcVSdn1Sm7SYX_PCWQdClaWhales"
const EXPECTED_ELECTOR_ADDRESS = "Ef8zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0vF"
const EXPECTED_POOL_ADDRESS = "EQCkR1cGmnsE45N4K0otPl5EnxnRakmGqeJUNua5fkWhales"

struct LoadedWhalesProxyStorage {
    data: cell
    storage: WhalesProxyStorage
}

fun mainnetWhalesProxy(): WhalesProxy {
    return WhalesProxy.fromAddress(address(MAINNET_WHALES_PROXY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadFromDataCell(data: cell): LoadedWhalesProxyStorage {
    return LoadedWhalesProxyStorage {
        data,
        storage: WhalesProxyStorage.fromCell(data),
    };
}

fun loadFromDataFixture(): LoadedWhalesProxyStorage {
    val rawBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val data = build("WhalesProxyData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return loadFromDataCell(data);
}

fun loadFromFork(proxy: WhalesProxy): LoadedWhalesProxyStorage {
    val account = testing.getAccountState(proxy.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return loadFromDataCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Whales Proxy mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Whales Proxy mainnet account is frozen");
        }
    }
}

fun expectKnownProxyStorage(loaded: LoadedWhalesProxyStorage): void {
    val storage = loaded.storage;
    expect(loaded.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.address0).toEqual(address(EXPECTED_ELECTOR_ADDRESS));
    expect(storage.address1).toEqual(address(EXPECTED_POOL_ADDRESS));
    expect(storage.tail).toEqual(EXPECTED_TAIL);
}

get fun `test whales proxy code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("WhalesProxy", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("WhalesProxyData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test whales proxy saved data fixture parses storage`() {
    val loaded = loadFromDataFixture();
    expectKnownProxyStorage(loaded);

    println("WHALES_PROXY_DATA_FIXTURE_STORAGE={}", loaded.storage);
}

get fun `test whales proxy mainnet storage parses real state`() {
    val proxy = mainnetWhalesProxy();
    val loaded = loadFromFork(proxy);
    expectKnownProxyStorage(loaded);

    println("WHALES_PROXY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("WHALES_PROXY_ADDRESS={}", proxy.address);
    println("WHALES_PROXY_DATA_HASH={}", loaded.data.hash());
    println("WHALES_PROXY_STORAGE={}", loaded.storage);
}
