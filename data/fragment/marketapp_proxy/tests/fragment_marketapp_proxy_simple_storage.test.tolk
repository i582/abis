import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/fragment_marketapp_proxy_simple.types"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun loadSimpleCodeFixture(): cell {
    val data = fs.readBytes("data/fragment/marketapp_proxy/testdata/FragmentMarketappProxySimple.boc");
    expect(data).toBeNotNull();
    var bytes = data!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build("FragmentMarketappProxySimple", "data/fragment/marketapp_proxy/testdata/FragmentMarketappProxySimple.boc");
}

fun loadSimpleDataFixture(): cell {
    val data = fs.readBytes("data/fragment/marketapp_proxy/testdata/FragmentMarketappProxySimple.data.boc");
    expect(data).toBeNotNull();
    var bytes = data!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build("FragmentMarketappProxySimpleData", "data/fragment/marketapp_proxy/testdata/FragmentMarketappProxySimple.data.boc");
}

get fun `test marketapp proxy simple parses saved mainnet storage fixture`() {
    val code = loadSimpleCodeFixture();
    val data = loadSimpleDataFixture();
    expect(code.hash()).toEqual(0xd4b299082778659ee541537db4f082d9b13fedc0f61b74cf7390ca0b255d9238);
    expect(data.hash()).toEqual(0x97b267b4908a137390522453864a7649b16feb91280e1b0b6a7d27c0a31c0a98);

    val storage = FragmentMarketappProxySimpleStorage.fromCell(data);
    expect(storage.publicKey).toEqual(
        bits256FromUint(0xafe029d50c74a91ada33de266e3a639bd7ff5517fccd3a3a3417bec9af8736cf),
    );
    expect(storage.adminAddress).toEqual(address("EQBXCwdud0ECN-BNThLHaGJXKAzovUK4iBGt40XbSVZ_mvcv"));
}
