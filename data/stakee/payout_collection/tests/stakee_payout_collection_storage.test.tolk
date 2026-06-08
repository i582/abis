import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/stakee_payout_collection.types"

const CODE_FIXTURE_BOC_PATH = "data/stakee/payout_collection/testdata/StakeePayoutCollection.boc"
const DATA_FIXTURE_BOC_PATH = "data/stakee/payout_collection/testdata/StakeePayoutCollection.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x889f23347fd1c720e9528d1279321e24cf20fa2eff8647db4d354b55b1ff3c04
const EXPECTED_ADMIN = "0:F6FF877DD4CE1355B101572045F09D54C29309737EB52CA542CFA6C195F7CC5B"
const EXPECTED_PREV = "0:855B2C18758F8A058EF85419196B2A9B306C8653BBCE1A164EEC31A75FA87551"
const EXPECTED_CURRENT = "0:57491AF607E4AAC371B76671CD0BDEFC31A3EF0F449C7850D3F06A12E0047A53"
const EXPECTED_NEXT = "0:2A3EFB321DCDA0CA0C6FAAEDCE764B350279FF6ABCAF8E9346952E3BEAB512AA"

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test stakee payout collection code and data fixtures are real BoCs`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("StakeePayoutCollectionData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test stakee payout collection parses saved mainnet storage fixture`() {
    val data = build("StakeePayoutCollectionData", DATA_FIXTURE_BOC_PATH);
    val storage = StakeePayoutCollectionStorage.fromCell(data);
    val cursor = storage.nftCursor.load();

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.issuedBills).toEqual(1351194863093);
    expect(storage.admin).toEqual(address(EXPECTED_ADMIN));
    expect(storage.distribution).toBeNotNull();

    val distribution = storage.distribution!.load();
    match (distribution) {
        StakeePayoutCollectionPendingTonDistribution => {
            expect(distribution.volume).toEqual(0);
        }
        StakeePayoutCollectionPendingJettonDistribution => {
            expect(false).toBeTrue();
        }
        StakeePayoutCollectionStartedTonDistribution => {
            expect(false).toBeTrue();
        }
        StakeePayoutCollectionStartedJettonDistribution => {
            expect(false).toBeTrue();
        }
    }

    expect(cursor.nextItemIndex).toEqual(2);
    expect(cursor.prev).toEqual(address(EXPECTED_PREV));
    expect(cursor.current).toEqual(address(EXPECTED_CURRENT));
    expect(cursor.next).toEqual(address(EXPECTED_NEXT));
}
