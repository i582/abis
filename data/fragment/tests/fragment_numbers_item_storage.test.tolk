import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "./test_utils"
import "../types/fragment_numbers_item.types"

const CODE_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentNumbersItem.boc"
const DATA_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentNumbersItem.data.boc"
const EXPECTED_CODE_HASH = 0x5b092991650fbc48b3288b08acc7677b22e4c25d48458c56d2a17f23e806b6b4
const EXPECTED_DATA_HASH = 0xf87e74136c58b3025ba960cd748965b5044732029854b01849d31b43a4ffa2ea
const EXPECTED_ITEM_INDEX = 34605260397254811988745750992812754674202088532486674203981630661894884735995
const EXPECTED_COLLECTION_ADDRESS = "0:0E41DC1DC3C9067ED24248580E12B3359818D83DEE0304FABCF80845EAFAFDB2"
const EXPECTED_OWNER_ADDRESS = "0:3A9CFE127594AC05E7BCE307845691488B2260E238E65005AC1A26F9FE094532"
const EXPECTED_CONTENT_HASH = 0xbdeb62f3b3909fd55507db720ad8a326ab8ec0091cf88701b97642d53f0e68d0
const EXPECTED_ROYALTY_HASH = 0x01ade34888aed64cca434ae7943d2455bca167d9090e575e1f70b89debb76468

get fun `test fragment numbers item code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    expect(build("FragmentNumbersItem", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("FragmentNumbersItemData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test fragment numbers item parses saved mainnet storage fixture`() {
    val data = build("FragmentNumbersItemData", DATA_FIXTURE_BOC_PATH);
    val storage = FragmentNumbersItemStorage.fromCell(data);
    val config = storage.config.load();
    val state = storage.state!.load();
    val content = state.content.load();

    expect(config.itemIndex).toEqual(EXPECTED_ITEM_INDEX);
    expect(config.collectionAddress).toEqual(address(EXPECTED_COLLECTION_ADDRESS));
    expect(state.ownerAddress!).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(state.content.hash()).toEqual(EXPECTED_CONTENT_HASH);
    expect(state.auction).toBeNull();
    expect(state.royaltyParams.hash()).toEqual(EXPECTED_ROYALTY_HASH);
    expect(content.nftContent.hash()).toBeGreater(0);
    expect(content.tokenInfo.hash()).toBeGreater(0);
}
