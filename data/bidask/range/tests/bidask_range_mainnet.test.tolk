import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_range.types"
import "../wrappers/BidaskRange.gen"

const CODE_FIXTURE_BOC_PATH = "data/bidask/range/testdata/BidaskRange.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/range/testdata/BidaskRange.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x4bd7191b24823ced9a44089739a58213cd5bc562f8980289855af9626646b91e
const EXPECTED_DATA_HASH = 0x8485b286f9b5783e4be14a31b32976ecef68193afca3b6fccf193dfc5d2ed86f
const EXPECTED_CURRENT_BIN = 0x2a1
const EXPECTED_SQRT_PRICE = 0x1c93a1994c1caf16f4e2df43e3e8fb6319
const EXPECTED_BIN_STEP = 0x64

const MAINNET_BIDASK_RANGE_ADDRESS = "EQDW7k0yROoOvyfSpSi4SVj5ZRYimiaE4uJElsTfTfW--e5b"
const MAINNET_BIDASK_POOL_ADDRESS = "0:D63F5A353AFFB7FD446B928CF95E62779145D2F6E84037D2FD0CA39EDD9FE1BA"

const SAVED_DATA_BOC = "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"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedBidaskRangeDataCell(): cell {
    return parseCellFromBase64(SAVED_DATA_BOC);
}

fun loadBidaskRangeStorageFromSavedData(): BidaskRangeStorage {
    return BidaskRangeStorage.fromCell(savedBidaskRangeDataCell());
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun expectBidaskRangeStorageCore(storage: BidaskRangeStorage): BidaskRangeStaticData {
    val staticData = storage.staticData.load();

    expect(storage.status).toEqual(1);
    expect(storage.precalculated).toBeTrue();
    expect(storage.currentBin).toEqual(EXPECTED_CURRENT_BIN);
    expect(storage.sqrtPrice).toEqual(EXPECTED_SQRT_PRICE);
    expect(storage.isMain).toBeTrue();
    expect(storage.liquidityDict).toBeNotNull();
    expect(storage.lpSupplyDict).toBeNotNull();
    expect(storage.ignoredRootTail.remainingBitsCount()).toEqual(592);
    expect(storage.ignoredRootTail.remainingRefsCount()).toEqual(0);
    expect(storage.toCell().hash()).toEqual(EXPECTED_DATA_HASH);

    expect(staticData.poolAddress).toBeNotNull();
    expect(staticData.poolAddress!).toEqual(address(MAINNET_BIDASK_POOL_ADDRESS));
    expect(staticData.leftRangeAddress).toBeNull();
    expect(staticData.rightRangeAddress).toBeNull();
    expect(staticData.firstBin).toEqual(-1024);
    expect(staticData.firstBin).toBeLessOrEqual(storage.currentBin);
    expect(staticData.baseFee).toEqual(5);
    expect(staticData.binStep).toEqual(EXPECTED_BIN_STEP);
    expect(staticData.dynamicFeeFactor).toEqual(0);
    expect(staticData.timeFilter).toEqual(0);
    expect(staticData.timeDecay).toEqual(1);
    expect(staticData.ignoredStaticRef.hash()).toBeGreater(0);

    return staticData;
}

get fun `test bidask range code and data boc fixtures are real and hash verified`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    val codeFromFixture = build("BidaskRange", CODE_FIXTURE_BOC_PATH);
    val codeFromManifest = build("BidaskRange");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
    expect(savedBidaskRangeDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test bidask range generated wrapper compiles from address`() {
    val range = BidaskRange.fromAddress(address(MAINNET_BIDASK_RANGE_ADDRESS));
    expect(range.address).toEqual(address(MAINNET_BIDASK_RANGE_ADDRESS));
}

get fun `test bidask range saved data boc parses as storage`() {
    val data = savedBidaskRangeDataCell();
    val storage = loadBidaskRangeStorageFromSavedData();
    val staticData = expectBidaskRangeStorageCore(storage);
    val range = BidaskRange.fromStorage(storage);

    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(range.stateInit).toBeNotNull();
    expect(range.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(range.stateInit!.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expectInternalAddress(staticData.poolAddress!);

    println("BIDASK_RANGE_SAVED_STORAGE={}", storage);
    println("BIDASK_RANGE_SAVED_STATIC_DATA={}", staticData);
}
