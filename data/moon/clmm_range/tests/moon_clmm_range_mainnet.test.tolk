import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/moon_clmm_range.types"
import "../wrappers/MoonClmmRange.gen"

const CODE_FIXTURE_PATH = "data/moon/clmm_range/testdata/MoonClmmRange.boc"
const DATA_FIXTURE_PATH = "data/moon/clmm_range/testdata/MoonClmmRange.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xdfa9fd42df3347715c99841052ac7395927fa3bf00dec27912ae922387beac91
const EXPECTED_DATA_HASH = 0x4e07aa3bc46b593ac4d28f550e2f205974e0edf41935f92f1a29faaec3544391
const PINNED_MAINNET_BLOCK = 83416870

const TON_USDT_RANGE_ADDRESS = "EQCzsA2cULtgsoTSGi47JsR-R7KGjkSVQdQY5cJqR2GJJ00w"
const TON_USDT_POOL_ADDRESS = "EQCz63ICU65UuX41uHhXb1k6_qblbgWAaMhcSagxyeNzQy32"

fun expectBocMagic(path: string): void {
    val rawBoc = fs.readBytes(path);
    expect(rawBoc).toBeNotNull();
    expect(rawBoc!.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadRangeStorageFromFork(range: MoonClmmRange): MoonClmmRangeStorage {
    val account = testing.getAccountState(range.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MoonClmmRange", CODE_FIXTURE_PATH).hash());
            return MoonClmmRangeStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Moon.cx CLMM range mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Moon.cx CLMM range mainnet fixture account is frozen");
        }
    }
}

get fun `test moon clmm range code and data fixtures are exact`() {
    expectBocMagic(CODE_FIXTURE_PATH);
    expectBocMagic(DATA_FIXTURE_PATH);

    val code = build("MoonClmmRange", CODE_FIXTURE_PATH);
    val data = build("MoonClmmRangeData", DATA_FIXTURE_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = MoonClmmRangeStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.poolAddress).toEqual(address(TON_USDT_POOL_ADDRESS));
    expect(storage.rangeNumber).toEqual(0);
    expect(storage.jettonWalletX).toBeNull();
    expect(storage.jettonWalletY).toBeNotNull();
    expect(storage.binStep).toEqual(100);
    expect(storage.rangeState.load().currentSqrtPriceX128).toBeGreater(0);
    expect(storage.lpAccountCode.hash()).toBeGreater(0);
    expect(storage.positionNftCode.hash()).toBeGreater(0);
}

get fun `test moon clmm range mainnet storage and getters match`() {
    val range = MoonClmmRange.fromAddress(address(TON_USDT_RANGE_ADDRESS));
    val storage = loadRangeStorageFromFork(range);
    val rangeState = storage.rangeState.load();

    expect(scripts.isContractDeployed(range.address)).toBeTrue();
    expect(range.getCurrentBin()).toEqual(rangeState.currentBin as int);
    expect(range.getCurrentSqrtPrice()).toEqual(rangeState.currentSqrtPriceX128 as int);
    expect(range.getRange().hash()).toEqual(storage.toCell().hash());
    expect(range.getBins()).toBeNotNull();

    val lpAccount = range.getLpAccount(range.address);
    val firstPosition = range.getNftAddressByIndex(0);
    expectInternalAddress(lpAccount);
    expectInternalAddress(firstPosition);

    println("MOON_CLMM_RANGE_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("MOON_CLMM_RANGE_MAINNET_ADDRESS={}", range.address);
    println("MOON_CLMM_RANGE_PARENT_POOL={}", storage.poolAddress);
    println("MOON_CLMM_RANGE_CURRENT_BIN={}", rangeState.currentBin);
    println("MOON_CLMM_RANGE_SQRT_PRICE_X128={}", rangeState.currentSqrtPriceX128);
}
