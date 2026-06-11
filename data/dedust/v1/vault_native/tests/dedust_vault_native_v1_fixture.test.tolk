import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/dedust_vault_native_v1.types"
import "../wrappers/DedustVaultNativeV1.gen"

const FIXTURE_BOC_PATH = "data/dedust/v1/vault_native/testdata/DedustVaultNativeV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xcfbe57e36e7fb5be8bc133acbc0082d47638a23d9d7c894e27db1ff7c1553a47

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust native vault v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("DedustVaultNativeV1", FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustVaultNativeV1");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test dedust native vault v1 wrapper can target an address without live state`() {
    val placeholderAddress = address("0:0000000000000000000000000000000000000000000000000000000000000000");
    val vault = DedustVaultNativeV1.fromAddress(placeholderAddress);

    expect(vault.address).toEqual(placeholderAddress);
    expect(vault.stateInit).toBeNull();
}
