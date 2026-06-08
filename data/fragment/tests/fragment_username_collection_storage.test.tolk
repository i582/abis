import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "./test_utils"
import "../types/fragment_username_collection.types"

const CODE_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentUsernameCollection.boc"
const DATA_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentUsernameCollection.data.boc"
const EXPECTED_CODE_HASH = 0x4d4eb9bfa2b210d890833a712be244081fddadb07f031f361ea5cf7f1a130651
const EXPECTED_DATA_HASH = 0x045962c91d5af209ec8a9a50b624e24940fd708aaf628d3fc7f677f2ba9e5c21
const EXPECTED_PUBLIC_KEY = 0x71de902f194a53293a0aa982070ca71acdbda490056d0ee8e821cc088451cda9
const EXPECTED_CONTENT_HASH = 0x7581e434f7468a3c1042802711efb0b4a9841c6c087e9614bd8865bdd823f7aa
const EXPECTED_ITEM_CODE_HASH = 0xa7a2616a4d639a076c2f67e7cce0423fd2a1c2ee550ad651c1eda16ee13bcaca
const EXPECTED_FULL_DOMAIN_HASH = 0x98eb9f4fe1ee14a08965473b78115313f8d3f709f66e7355e1c2ea96fde2d906
const EXPECTED_ROYALTY_HASH = 0x01ade34888aed64cca434ae7943d2455bca167d9090e575e1f70b89debb76468

get fun `test fragment username collection code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    expect(build("FragmentUsernameCollection", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("FragmentUsernameCollectionData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test fragment username collection parses saved mainnet storage fixture`() {
    val data = build("FragmentUsernameCollectionData", DATA_FIXTURE_BOC_PATH);
    val storage = FragmentUsernameCollectionStorage.fromCell(data);

    expect(storage.touched).toBeTrue();
    expect(storage.subwalletId).toEqual(3);
    expect(storage.publicKey).toEqual(bits256FromUint(EXPECTED_PUBLIC_KEY));
    expect(storage.content.hash()).toEqual(EXPECTED_CONTENT_HASH);
    expect(storage.itemCode.hash()).toEqual(EXPECTED_ITEM_CODE_HASH);
    expect(storage.fullDomain.hash()).toEqual(EXPECTED_FULL_DOMAIN_HASH);
    expect(storage.royaltyParams.hash()).toEqual(EXPECTED_ROYALTY_HASH);
}
