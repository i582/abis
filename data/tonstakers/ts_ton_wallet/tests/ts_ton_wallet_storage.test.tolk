import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/ts_ton_wallet.types"

const FIXTURE_BOC_PATH = "data/tonstakers/ts_ton_wallet/testdata/TsTonWallet.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonstakers/ts_ton_wallet/testdata/TsTonWallet.data.boc"
const LIVE_DATA_BOC = "te6ccgEBAgEAdQABnVHlTA+PyAFIti/lCBJFNvBsHGUghB4nyfxB8hr8V/GJWM4GSzxF9QAvfP6gJjRKbVLT3O1usXR4f2R6wVBacORbfyMzVNtEAAAAAAAAAAIBCEICEr67DcjiArfib3IeJUfha7nrrsk09lfRnyLnbWK+yHg="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x12bebb0dc8e202b7e26f721e2547e16bb9ebaec934f657d19f22e76d62bec878
const EXPECTED_DATA_HASH = 0x04e71a98fa89ec8abdfcef0c14add1c94b85c383ae6d217eef9f2f4495f3e084
const EXPECTED_BALANCE = 130270951676
const EXPECTED_OWNER_ADDRESS = "0:A45B17F28409229B78360E3290420F13E4FE20F90D7E2BF8C4AC6703259E22FA"
const EXPECTED_MASTER_ADDRESS = "kQC98_qAmNEptUtPc7W6xdHh_ZHrBUFpw5Ft_IzNU20QAC0l"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDataCell(): cell {
    return parseCellFromBase64(LIVE_DATA_BOC);
}

get fun `test ts ton wallet code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("TsTonWallet", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test ts ton wallet parses saved live storage fixture`() {
    val storage = TsTonWalletStorage.fromCell(savedDataCell());

    expect(storage.balance).toEqual(EXPECTED_BALANCE);
    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(address(EXPECTED_MASTER_ADDRESS));
    expect(storage.jettonWalletCode.hash()).toBeGreater(0);
    expect(storage.locked).toEqual(0);
    expect(storage.lockExpiration).toEqual(0);

    println("TSTON_WALLET_STORAGE={}", storage);
}
