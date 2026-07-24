import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/wton_minter.types"
import "../types/wton_wallet.types"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const WTON_MINTER_CODE_PATH = "data/megatonfi/testdata/WtonMinter.boc"
const WTON_MINTER_DATA_PATH = "data/megatonfi/testdata/WtonMinter.data.boc"
const WTON_WALLET_CODE_PATH = "data/megatonfi/testdata/WtonWallet.boc"
const WTON_WALLET_DATA_PATH = "data/megatonfi/testdata/WtonWallet.data.boc"

fun loadBocFixture(name: string, path: string): cell {
    val raw = fs.readBytes(path);
    expect(raw).toBeNotNull();
    var bytes = raw!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build(name, path);
}

get fun `test wton minter parses real mainnet storage`() {
    // Toncenter snapshot for the WTON minter at logical time 92162575000100.
    val code = loadBocFixture("WtonMinter", WTON_MINTER_CODE_PATH);
    val data = loadBocFixture("WtonMinterData", WTON_MINTER_DATA_PATH);
    val storage = WtonMinterStorage.fromCell(data);

    expect(code.hash()).toEqual(0x32cb6360cb659a7d9a6f12ef58b86b9de8595f9d963a978b5cd77fb913252283);
    expect(data.hash()).toEqual(0x886b2a778d0deabce35cd98e5f6b75cf58253b809eb2fcbb9ae3e1decddd75d4);
    expect(storage.totalSupply).toEqual(67391509063935);
    expect(storage.adminAddress).toEqual(
        address("0:84E9070FC38C31FDD1B9AB7BA80834959AF44E86C74F921831440024F35CB6AF"),
    );
    expect(storage.nextAdminAddress).toBeNull();
    expect(storage.content.hash()).toEqual(
        0x39da673ee943c15628a3f7a446a009232d2137549f16d1b287eb220d117e51a6,
    );
    expect(storage.walletCode.hash()).toEqual(
        0xc12275085ec7dd21925c33a919680186022c6f2a4ced45dbce3d3e14d438dc0f,
    );
}

get fun `test wton wallet parses real mainnet storage`() {
    // Toncenter snapshot for the depositor wallet at logical time 92162575000098.
    val code = loadBocFixture("WtonWallet", WTON_WALLET_CODE_PATH);
    val data = loadBocFixture("WtonWalletData", WTON_WALLET_DATA_PATH);
    val storage = WtonWalletStorage.fromCell(data);

    expect(code.hash()).toEqual(0xc12275085ec7dd21925c33a919680186022c6f2a4ced45dbce3d3e14d438dc0f);
    expect(data.hash()).toEqual(0x1e0c99a32fb210a6e3de3d642169ced2825f4cd6741d0b92a87e7d4d281cb153);
    expect(storage.balance).toEqual(0);
    expect(storage.ownerAddress).toEqual(
        address("0:A186B2888BF01BF9CC177D7C34A45318D4CC041957DBDACEA0C0328DB8665DA2"),
    );
    expect(storage.minterAddress).toEqual(
        address("0:9A8DA514D575D20234C3FB1395EE9138F5F1AD838ABC905DC42C2389B46BD015"),
    );
    expect(storage.walletCode.hash()).toEqual(code.hash());
}
