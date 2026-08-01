import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_offchain_offer_v3.types"

const TOLK_100_CODE_PATH = "data/getgems/getgems_offchain_offer_v3/testdata/GetgemsOffchainOfferV3Tolk100.boc"
const TOLK_100_DATA_PATH = "data/getgems/getgems_offchain_offer_v3/testdata/GetgemsOffchainOfferV3Tolk100.data.boc"
const TOLK_130_CODE_PATH = "data/getgems/getgems_offchain_offer_v3/testdata/GetgemsOffchainOfferV3.boc"
const TOLK_130_DATA_PATH = "data/getgems/getgems_offchain_offer_v3/testdata/GetgemsOffchainOfferV3.data.boc"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const TOLK_100_CODE_HASH = 0x0285e0ba8e03b38a80a5baf9198ad840510ac835af1e3bfe2ceac7eceba592c5
const TOLK_100_DATA_HASH = 0xab9ddf6735f3f525a305c8c19a4d5455453d3c08400b457e335847d1e7ddf586
const TOLK_130_CODE_HASH = 0xf0449dca7dd58b13607508839087668196aaef2c7df9ef5fe5b73e0a9177255e
const TOLK_130_DATA_HASH = 0x5be269bbb792a336f138407687804e2ba4972b86fdbd59cce4862c1aeb2e3456

fun loadFixture(label: string, path: string, expectedHash: uint256): cell {
    val bytes = fs.readBytes(path);
    expect(bytes).toBeNotNull();
    val fixtureBytes = bytes!;
    expect(fixtureBytes.remainingBitsCount()).toBeGreaterOrEqual(32);
    expect(fixtureBytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);

    val fixture = build(label, path);
    expect(fixture.hash()).toEqual(expectedHash);
    return fixture;
}

fun expectStorageFixtureParses(data: cell, expectedHash: uint256): GetgemsOffchainOfferV3Storage {
    val storage = GetgemsOffchainOfferV3Storage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(expectedHash);
    expect(storage.maxCount).toBeGreaterOrEqual(storage.boughtCount);
    expect(storage.fees.load().feeBase).toBeGreaterOrEqual(0);
    expect(storage.staticData.load().createdAt).toBeGreater(0);
    return storage;
}

get fun `test offchain offer v3 Tolk 1.0.0 exact code and storage fixtures`() {
    loadFixture("GetgemsOffchainOfferV3Tolk100Code", TOLK_100_CODE_PATH, TOLK_100_CODE_HASH);
    val data = loadFixture(
        "GetgemsOffchainOfferV3Tolk100Data",
        TOLK_100_DATA_PATH,
        TOLK_100_DATA_HASH,
    );
    val storage = expectStorageFixtureParses(data, TOLK_100_DATA_HASH);

    expect(storage.isComplete).toBeTrue();
    println("GETGEMS_OFFCHAIN_OFFER_V3_TOLK_100_STORAGE={}", storage);
}

get fun `test offchain offer v3 Tolk 1.3.0 exact code and storage fixtures`() {
    loadFixture("GetgemsOffchainOfferV3Tolk130Code", TOLK_130_CODE_PATH, TOLK_130_CODE_HASH);
    val data = loadFixture(
        "GetgemsOffchainOfferV3Tolk130Data",
        TOLK_130_DATA_PATH,
        TOLK_130_DATA_HASH,
    );
    val storage = expectStorageFixtureParses(data, TOLK_130_DATA_HASH);

    expect(storage.isComplete).toBeTrue();
    println("GETGEMS_OFFCHAIN_OFFER_V3_TOLK_130_STORAGE={}", storage);
}
