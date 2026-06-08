import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/stakeed_minter.types"

const CODE_FIXTURE_BOC_PATH = "data/stakee/stakeed_minter/testdata/StakeedMinter.boc"
const DATA_FIXTURE_BOC_PATH = "data/stakee/stakeed_minter/testdata/StakeedMinter.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x47e271172ce0435edb09cb645f126057fdab0ac0f2efcc9bb8f155b97bed9dd7
const EXPECTED_POOL_ADMIN = "0:F6FF877DD4CE1355B101572045F09D54C29309737EB52CA542CFA6C195F7CC5B"
const EXPECTED_CONTENT_HASH = 0x9a4c32ccb5de65922c71b5cdb45f536ed66fd597aafc8a718fe5b1c3a8af4ef6
const EXPECTED_VOTING_CODE_HASH = 0x5485195452e514a2b0116013d6287bcd313daa998d5ff5d44bb6e1d7a04816f4

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test stakeed minter code and data fixtures are real BoCs`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("StakeedMinterData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test stakeed minter parses saved mainnet storage fixture`() {
    val data = build("StakeedMinterData", DATA_FIXTURE_BOC_PATH);
    val storage = StakeedMinterStorage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.totalSupply).toEqual(14587624389176187);
    expect(storage.adminAddress).toEqual(address(EXPECTED_POOL_ADMIN));
    expect(storage.jettonContent.hash()).toEqual(EXPECTED_CONTENT_HASH);
    expect(storage.votingId).toEqual(0);
    expect(storage.votingCode.hash()).toEqual(EXPECTED_VOTING_CODE_HASH);
}
