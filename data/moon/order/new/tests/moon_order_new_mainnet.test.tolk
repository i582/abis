import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/moon_order_new.types"
import "../wrappers/MoonOrderNew.gen"

const ORDER_ADDRESS = "EQDYBeAlOAUgG6DwWG9EdPSJaPjr5B1E1tNSKOhRxv7O6KiQ"
const CODE_FIXTURE_BOC_PATH = "data/moon/order/new/testdata/MoonOrderNew.boc"
const DATA_FIXTURE_BOC_PATH = "data/moon/order/new/testdata/MoonOrderNew.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x88c38d29586b5d748badbc7b4dbfe239c25cb85ca9c4586a44e05507a6edf6a6
const EXPECTED_DATA_HASH = 0x4a7c4e53e7b912480c9c20e473a192d9313c5bdd2e4b5f8f6f32956dca0b8098
const PINNED_MAINNET_BLOCK = 83400035

fun order(): MoonOrderNew {
    return MoonOrderNew.fromAddress(address(ORDER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadOrderStorage(data: cell): MoonOrderNewStorage {
    val storage = MoonOrderNewStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun loadOrderFromFork(contract: MoonOrderNew): MoonOrderNewStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MoonOrderNew", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(build("MoonOrderNewData", DATA_FIXTURE_BOC_PATH).hash());
            return loadOrderStorage(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Moon Order new revision is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Moon Order new revision is frozen at the pinned block");
        }
    }
}

get fun `test moon order new exact code and data fixtures`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("MoonOrderNew", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("MoonOrderNewData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
    loadOrderStorage(build("MoonOrderNewData", DATA_FIXTURE_BOC_PATH));
}

get fun `test moon order new pinned storage and compatible getters`() {
    val contract = order();
    val storage = loadOrderFromFork(contract);
    val vesting = MoonOrderNewVestingState.fromCell(storage.stateData);
    val getterVesting = contract.getVestingData();
    val assets = storage.assets.load();
    val wallets = storage.wallets.load();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.status).toEqual(0);
    expect(storage.remainingAmount).toEqual(0);
    expect(contract.getStatus()).toEqual(storage.status);
    expect(contract.getOrderAmount()).toEqual(storage.remainingAmount as int);
    expect(contract.getOrder().hash()).toEqual(EXPECTED_DATA_HASH);
    expect(contract.getAssets().hash()).toEqual(assets.toCell().hash());
    expect(contract.getWallets().hash()).toEqual(wallets.toCell().hash());
    expect(contract.getFillOut(1000000000)).toEqual(0);
    expect(getterVesting.vestingStartTime).toEqual(vesting.startTime);
    expect(getterVesting.vestingDuration).toEqual(vesting.duration);
    expect(getterVesting.recipient).toEqual(vesting.recipient);
    expect(assets.asset1).toBeNull();
    expect(assets.asset2).toBeNotNull();
    expect(wallets.asset1Wallet).toBeNull();
    expect(wallets.asset2Wallet).toBeNotNull();
    println("MOON_ORDER_NEW_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
