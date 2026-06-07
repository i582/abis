import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/evaa_user.types"

const CODE_FIXTURE_BOC_PATH = "data/evaa/user/testdata/EvaaUser.boc"
const DATA_FIXTURE_BOC_PATH = "data/evaa/user/testdata/EvaaUser.data.boc"
const LIVE_DATA_BOC = "te6ccgEBAwEAsQACmRAYATpDq7+sgH+w7vszY2aQoYh4Hx+Pz1vlSaw4i8CI1GhXAA/csMDLQHOPaW77sl58pHnbPspKp8Is94ySwxjwAsRaYAAAAAAAAAASAQIAU6AbKS3zZPNJxNiT1suriPjzbb+9Qtk3XfUisU+/d3lYCUAAAAAACKzo8ABjoBspLfNk80nE2JPWy6uI+PNtv71C2Tdd9SKxT793eVgJQAAAAAAAAAAAAAAAAAAAABA="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x19fe8804c2c449c857b4c5478d9794dead72ce9b4eed00963fc27d0b95b4ad81
const EXPECTED_DATA_HASH = 0x1b662092970c26e467978dcadf144997e790fda98e8c04e864acfe8de1708183
const EXPECTED_CODE_VERSION = 1
const EXPECTED_MASTER_ADDRESS = "0:9d21d5dfd6403fd8777d99b1b34850c43c0f8fc7e7adf2a4d61c45e0446a342b"
const EXPECTED_OWNER_ADDRESS = "0:3f72c3032d01ce3da5bbeec979f291e76cfb292a9f08b3de324b0c63c00b1169"
const EXPECTED_ASSET_ID = 0xd9496f9b279a4e26c49eb65d5c47c79b6dfdea16c9baefa9158a7dfbbbcac04a
const EXPECTED_PRINCIPAL = 4548423

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun liveDataCell(): cell {
    return parseCellFromBase64(LIVE_DATA_BOC);
}

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test evaa user code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("EvaaUser", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(liveDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test evaa user parses saved live storage fixture`() {
    val data = liveDataCell();
    val storage = EvaaUserStorage.fromCell(data);
    val principal = storage.userPrincipals.mustGet(EXPECTED_ASSET_ID);
    val reward = storage.userRewards.mustGet(EXPECTED_ASSET_ID);
    var principalTail = principal.borrowTail;

    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.codeVersion).toEqual(EXPECTED_CODE_VERSION);
    expect(storage.masterAddress).toEqual(address(EXPECTED_MASTER_ADDRESS));
    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(storage.state).toEqual(0);
    expect(storage.userPrincipals).toHaveLength(1);
    expect(storage.userRewards).toHaveLength(1);
    expect(principal.principal).toEqual(EXPECTED_PRINCIPAL);
    expectNoTail(mutate principalTail);
    expect(reward.trackingIndex).toEqual(0);
    expect(reward.trackingAccrued).toEqual(0);
    expect(storage.backupCell1).toBeNull();
    expect(storage.backupCell2).toBeNull();

    println("EVAA_USER_STORAGE={}", storage);
}
