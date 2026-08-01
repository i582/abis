import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/moon_order_old.types"
import "../wrappers/MoonOrderOld.gen"

const ORDER_ADDRESS = "EQAv_Q12BIyI9IToOKMOG0QhqMaVG3DI-ytmkNsmEecaQG4B"
const CODE_FIXTURE_BOC_PATH = "data/moon/order/old/testdata/MoonOrderOld.boc"
const DATA_FIXTURE_BOC_PATH = "data/moon/order/old/testdata/MoonOrderOld.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xee07140b3ccfe261ed28580f60a16bda4c4b9c6d7da7ae05f5b7c7e2b1dfe226
const EXPECTED_DATA_HASH = 0x9d8c4516873fe590d5296d93e9b819bf5bbfb847c8c5131f0f29cf1ef104dd33
const PINNED_MAINNET_BLOCK = 83400035

fun order(): MoonOrderOld {
    return MoonOrderOld.fromAddress(address(ORDER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadOrderStorage(data: cell): MoonOrderOldStorage {
    val storage = MoonOrderOldStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun loadOrderFromFork(contract: MoonOrderOld): MoonOrderOldStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MoonOrderOld", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(build("MoonOrderOldData", DATA_FIXTURE_BOC_PATH).hash());
            return loadOrderStorage(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Moon Order old revision is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Moon Order old revision is frozen at the pinned block");
        }
    }
}

get fun `test moon order old exact code and data fixtures`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("MoonOrderOld", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("MoonOrderOldData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
    loadOrderStorage(build("MoonOrderOldData", DATA_FIXTURE_BOC_PATH));
}

get fun `test moon order old pinned storage and compatible getters`() {
    val contract = order();
    val storage = loadOrderFromFork(contract);
    val params = MoonOrderOldOrderParams.fromCell(storage.stateData);
    val assets = storage.assets.load();
    val wallets = storage.wallets.load();
    val quotedOut = contract.getFillOut(1000000000);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.status).toEqual(1);
    expect(contract.getStatus()).toEqual(storage.status);
    expect(contract.getOrderAmount()).toEqual(storage.remainingAmount as int);
    expect(contract.getOrder().hash()).toEqual(EXPECTED_DATA_HASH);
    expect(contract.getAssets().hash()).toEqual(assets.toCell().hash());
    expect(contract.getWallets().hash()).toEqual(wallets.toCell().hash());
    expect(assets.asset1).toBeNull();
    expect(assets.asset2).toBeNotNull();
    expect(wallets.asset1Wallet).toBeNull();
    expect(wallets.asset2Wallet).toBeNotNull();
    expect(params.rate).toBeGreater(0);
    expect(quotedOut).toBeGreater(0);
    expect(quotedOut).toBeLess(storage.remainingAmount as int);
    println("MOON_ORDER_OLD_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
