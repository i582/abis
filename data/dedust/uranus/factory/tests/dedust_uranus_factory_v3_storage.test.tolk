import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/dedust_uranus_factory_v3.types"
import "../wrappers/DedustUranusFactoryV3.gen"

const FIXTURE_BOC_PATH = "data/dedust/uranus/factory/testdata/DedustUranusFactoryV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb4577491b68c6e37f4b7fbe8cb135e19467fee7653cde48ce28940e4d0ee311a
const FACTORY_ADDRESS = "0:3A8AF848381409BEA3B5498DC8BEEB6696E33577CD7B8190DE12389A54D04B78"
const CONTROLLER_ADDRESS = "0:33664F9813E0BFD936B1333362EF5BA92DFC0B601591A5608AE8CD6F85B00EB4"
const DATA_BOC_BASE64 = "te6ccgEBAQEAJAAAQ4AGbMnzAnwX+ybWJmZsXet1Jb+BbAKyNKwRXRmt8LYB1pA="

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust uranus factory v3 code fixture hash matches live account`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("DedustUranusFactoryV3", FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustUranusFactoryV3");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test dedust uranus factory v3 storage parses saved mainnet data cell`() {
    val data = parseCellFromBase64(DATA_BOC_BASE64);
    val storage = DedustUranusFactoryV3Storage.fromCell(data);

    expect(storage.controllerAddress).toEqual(address(CONTROLLER_ADDRESS));
}

get fun `test dedust uranus factory v3 wrapper can target verified address`() {
    val factoryAddress = address(FACTORY_ADDRESS);
    val factory = DedustUranusFactoryV3.fromAddress(factoryAddress);

    expect(factory.address).toEqual(factoryAddress);
    expect(factory.stateInit).toBeNull();
}
