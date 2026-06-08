import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "./test_utils"
import "../types/fragment_numbers_collection.types"

const CODE_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentNumbersCollection.boc"
const DATA_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentNumbersCollection.data.boc"
const EXPECTED_CODE_HASH = 0x88410c220f822181668269ce83eb9cc0d3b39c21999c8b55de03360a20e7c282
const EXPECTED_DATA_HASH = 0x4050e232e646c7ffcd0d46212a515a0b0f7383ed6169fa8ada59e78641bfda06
const EXPECTED_PUBLIC_KEY = 0x71de902f194a53293a0aa982070ca71acdbda490056d0ee8e821cc088451cda9
const EXPECTED_CONTENT_HASH = 0x273760e369dc724ad6fdc446abcf28f689247aa871b9ee2131722b751d8f9bc5
const EXPECTED_ITEM_CODE_HASH = 0x5b092991650fbc48b3288b08acc7677b22e4c25d48458c56d2a17f23e806b6b4
const EXPECTED_ROYALTY_HASH = 0x01ade34888aed64cca434ae7943d2455bca167d9090e575e1f70b89debb76468

get fun `test fragment numbers collection code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    expect(build("FragmentNumbersCollection", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("FragmentNumbersCollectionData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test fragment numbers collection parses saved mainnet storage fixture`() {
    val data = build("FragmentNumbersCollectionData", DATA_FIXTURE_BOC_PATH);
    val storage = FragmentNumbersCollectionStorage.fromCell(data);

    expect(storage.touched).toBeTrue();
    expect(storage.subwalletId).toEqual(12);
    expect(storage.publicKey).toEqual(bits256FromUint(EXPECTED_PUBLIC_KEY));
    expect(storage.content.hash()).toEqual(EXPECTED_CONTENT_HASH);
    expect(storage.itemCode.hash()).toEqual(EXPECTED_ITEM_CODE_HASH);
    expect(storage.fullDomain.hash()).toBeGreater(0);
    expect(storage.royaltyParams.hash()).toEqual(EXPECTED_ROYALTY_HASH);
}
