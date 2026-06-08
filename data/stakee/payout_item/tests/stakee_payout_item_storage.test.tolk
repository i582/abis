import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/stakee_payout_item.types"

const CODE_FIXTURE_BOC_PATH = "data/stakee/payout_item/testdata/StakeePayoutItem.boc"
const DATA_FIXTURE_BOC_PATH = "data/stakee/payout_item/testdata/StakeePayoutItem.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x34927a0b10ed5e998cdb2bdef7040f073f9675f7fee2482a558ae49f2b1ac815
const EXPECTED_OWNER = "0:E8B913C2CE2504CCB0B5B29B62D4B19D750A3984FD9CC6624626E01094785EA7"
const EXPECTED_COLLECTION = "0:28BF64ED4FE71C32CBCBCFFCA1524A74315E4C1B62747CAC76AB1FF1BBDAD771"
const EXPECTED_PREV = "0:2A3EFB321DCDA0CA0C6FAAEDCE764B350279FF6ABCAF8E9346952E3BEAB512AA"
const EXPECTED_NEXT = "0:855B2C18758F8A058EF85419196B2A9B306C8653BBCE1A164EEC31A75FA87551"

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test stakee payout item code and data fixtures are real BoCs`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("StakeePayoutItemData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test stakee payout item parses saved mainnet storage fixture`() {
    val data = build("StakeePayoutItemData", DATA_FIXTURE_BOC_PATH);
    val storage = StakeePayoutItemStorage.fromCell(data);
    val next = storage.nextItemAddress.load();

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.isInitialized).toBeTrue();
    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER));
    expect(storage.collectionAddress).toEqual(address(EXPECTED_COLLECTION));
    expect(storage.itemIndex).toEqual(1);
    expect(storage.amount).toEqual(1797996969);
    expect(storage.previousItemAddress).toEqual(address(EXPECTED_PREV));
    expect(next.nextItemAddress).toEqual(address(EXPECTED_NEXT));
}
