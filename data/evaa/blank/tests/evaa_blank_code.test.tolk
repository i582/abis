import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/evaa_blank.types"
import "../wrappers/EvaaBlank.gen"

const CODE_FIXTURE_BOC_PATH = "data/evaa/blank/testdata/EvaaBlank.boc"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe2f78a44f379cc7b03628d7d9c1a044e58eff0e87fea97944d29202263c68c20

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun noTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

get fun `test evaa blank code fixture is real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("EvaaBlank", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("EvaaBlank").hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test evaa blank state init storage fixture is deterministic`() {
    val masterAddress = address("0:9d21d5dfd6403fd8777d99b1b34850c43c0f8fc7e7adf2a4d61c45e0446a342b");
    val ownerAddress = address("0:3f72c3032d01ce3da5bbeec979f291e76cfb292a9f08b3de324b0c63c00b1169");
    val storage = EvaaBlankStorage {
        platformAddress: masterAddress,
        ownerAddress,
        typeId: 0,
        params: null,
        tail: noTail(),
    };
    val blank = EvaaBlank.fromStorage(storage);
    val liveStorage = EvaaBlankStorage.fromCell(blank.stateInit!.data);
    var liveTail = liveStorage.tail;

    expect(blank.stateInit).toBeNotNull();
    expect(blank.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(liveStorage.platformAddress).toEqual(masterAddress);
    expect(liveStorage.ownerAddress).toEqual(ownerAddress);
    expect(liveStorage.typeId).toEqual(0);
    expect(liveStorage.params).toBeNull();
    expect(liveTail.remainingBitsCount()).toEqual(0);
    expect(liveTail.remainingRefsCount()).toEqual(0);

    println("EVAA_BLANK_LOCAL_ADDRESS={}", blank.address);
    println("EVAA_BLANK_LOCAL_STORAGE={}", liveStorage);
}
