import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "./test_utils"
import "../types/fragment_username_item.types"

const CODE_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentUsernameItem.boc"
const DATA_FIXTURE_BOC_PATH = "data/fragment/testdata/FragmentUsernameItem.data.boc"
const EXPECTED_CODE_HASH = 0xa7a2616a4d639a076c2f67e7cce0423fd2a1c2ee550ad651c1eda16ee13bcaca
const EXPECTED_DATA_HASH = 0xa39df8be5b20ff3eac83abf4cbdec68f5c294e5beb158c2a33768f6fea7d8a39
const EXPECTED_ITEM_INDEX = 100841825488826490505932176862876133081761890731740429549340028651201309797431
const EXPECTED_COLLECTION_ADDRESS = "0:80D78A35F955A14B679FAA887FF4CD5BFC0F43B4A4EEA2A7E6927F3701B273C2"
const EXPECTED_OWNER_ADDRESS = "0:8E33E79D3F6169E7F677FAD7BBD71AA73570C357C27B2974AA63B0EF16FF56FB"
const EXPECTED_CONTENT_HASH = 0xd991b7f39235e59be7c6757469fbc70108460e9a7f7a9987579394c32da2d884
const EXPECTED_ROYALTY_HASH = 0x01ade34888aed64cca434ae7943d2455bca167d9090e575e1f70b89debb76468

get fun `test fragment username item code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    expect(build("FragmentUsernameItem", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("FragmentUsernameItemData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test fragment username item parses saved mainnet storage fixture`() {
    val data = build("FragmentUsernameItemData", DATA_FIXTURE_BOC_PATH);
    val storage = FragmentUsernameItemStorage.fromCell(data);
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
