import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/fragment_marketapp_proxy_jetton.types"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun loadJettonCodeFixture(): cell {
    val data = fs.readBytes("data/fragment/marketapp_proxy/testdata/FragmentMarketappProxyJetton.boc");
    expect(data).toBeNotNull();
    var bytes = data!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build("FragmentMarketappProxyJetton", "data/fragment/marketapp_proxy/testdata/FragmentMarketappProxyJetton.boc");
}

fun loadJettonDataFixture(): cell {
    val data = fs.readBytes("data/fragment/marketapp_proxy/testdata/FragmentMarketappProxyJetton.data.boc");
    expect(data).toBeNotNull();
    var bytes = data!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build("FragmentMarketappProxyJettonData", "data/fragment/marketapp_proxy/testdata/FragmentMarketappProxyJetton.data.boc");
}

get fun `test marketapp proxy jetton parses saved mainnet storage fixture`() {
    val code = loadJettonCodeFixture();
    val data = loadJettonDataFixture();
    expect(code.hash()).toEqual(0x889170121b62550b64c19044c3bef93b7abbad11a0b0e672e1605096ddcc85ec);
    expect(data.hash()).toEqual(0x07ba06de2d36a3f5001325ba92502393aafa23d0f1201c421c6959e473d0bb99);

    val storage = FragmentMarketappProxyJettonStorage.fromCell(data);
    expect(storage.publicKey).toEqual(
        bits256FromUint(0x4c74159e5365fbf058865d93b9952da6dbd80a6745674896f4edbf615d87be96),
    );
    expect(storage.adminAddress).toEqual(address("EQCanLgK370WYvUQh2bXM1WsLAMwT9odJaR5Zw40781ysx2O"));
}
