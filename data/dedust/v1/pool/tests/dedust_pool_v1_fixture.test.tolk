import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/dedust_pool_v1.types"
import "../wrappers/DedustPoolV1.gen"

const FIXTURE_BOC_PATH = "data/dedust/v1/pool/testdata/DedustPoolV1.boc"
const LP_WALLET_FIXTURE_BOC_PATH = "data/dedust/v1/pool/testdata/DedustLpWalletV1.embedded.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xcbb3f4bcc2a4614b9ceaea404aca82ed8345c76f453c9aecf8a7744dcc3767ac
const EXPECTED_LP_WALLET_CODE_HASH = 0xa760d629d5343e76d045017d9dc216fc8a307a8377815feb2b0a5c490e733486

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust pool v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("DedustPoolV1", FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustPoolV1");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test dedust pool v1 embedded lp wallet code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(LP_WALLET_FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val lpWalletCode = build("DedustPoolV1", LP_WALLET_FIXTURE_BOC_PATH);
    expect(lpWalletCode.hash()).toEqual(EXPECTED_LP_WALLET_CODE_HASH);
}

get fun `test dedust pool v1 wrapper can target an address without live state`() {
    val placeholderAddress = address("0:0000000000000000000000000000000000000000000000000000000000000000");
    val pool = DedustPoolV1.fromAddress(placeholderAddress);

    expect(pool.address).toEqual(placeholderAddress);
    expect(pool.stateInit).toBeNull();
}
