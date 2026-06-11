import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/dedust_uranus_meme_wallet_v3.types"
import "../wrappers/DedustUranusMemeWalletV3.gen"

const FIXTURE_BOC_PATH = "data/dedust/uranus/meme_wallet/testdata/DedustUranusMemeWalletV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe2da88070dcf9d1b2ed4ab9079b8c473625bf320f38423ed86ee03ef5c326858
const WALLET_ADDRESS = "0:08430FA877B36AF1926B9F8D15407CD73859B737B5ED795805E084E9F868A206"
const OWNER_ADDRESS = "0:08ED8DCC9D3AA0B8EBC5BAA95577C085347BEA5E5DBEAA1E8998AA42A18C723A"
const MEME_ADDRESS = "0:3A74678A21C1D45508212869867B57C47F27D8698C8B0B9F783E460EE6E21B12"
const DATA_BOC_BASE64 = "te6ccgEBAQEARgAAhwgAEdsbmTp1QXHXi3VSqu+BCmj31Ly7fVQ9EzFUhUMY5HUADp0Z4ohwdRVCCEoaYZ7V8R/J9hpjIsLn3g+Rg7m4hsSg"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust uranus meme wallet v3 code fixture hash matches live account`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("DedustUranusMemeWalletV3", FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustUranusMemeWalletV3");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test dedust uranus meme wallet v3 storage parses saved mainnet data cell`() {
    val data = parseCellFromBase64(DATA_BOC_BASE64);
    val storage = DedustUranusMemeWalletV3Storage.fromCell(data);

    expect(storage.balance).toEqual(0);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.memeAddress).toEqual(address(MEME_ADDRESS));
}

get fun `test dedust uranus meme wallet v3 wrapper can target verified address`() {
    val walletAddress = address(WALLET_ADDRESS);
    val wallet = DedustUranusMemeWalletV3.fromAddress(walletAddress);

    expect(wallet.address).toEqual(walletAddress);
    expect(wallet.stateInit).toBeNull();
}
