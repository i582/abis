import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonstakers_payout_collection.types"

const FIXTURE_BOC_PATH = "data/tonstakers/payout_collection/testdata/TonstakersPayoutCollection.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonstakers/payout_collection/testdata/TonstakersPayoutCollection.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x8b60bab1c9f822536ea0b3e5fc11b7c649cd336125611616b6a75a770e60c9e8
const EXPECTED_ISSUED_BILLS = 477872344374168
const EXPECTED_NEXT_ITEM_INDEX = 71
const EXPECTED_ADMIN = "0:A45B17F28409229B78360E3290420F13E4FE20F90D7E2BF8C4AC6703259E22FA"
const EXPECTED_CURRENT_NFT = "0:7E47B99CAD6D664AB1C5C4FB41C6F23DE98C32514DD1F7F9E4BFCBCC192FB3AD"
const LIVE_DATA_BOC = "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"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun liveDataCell(): cell {
    return parseCellFromBase64(LIVE_DATA_BOC);
}

get fun `test tonstakers payout collection local boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(liveDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test tonstakers payout collection parses live storage fixture`() {
    val data = liveDataCell();
    val storage = TonstakersPayoutCollectionStorage.fromCell(data);
    val cursor = storage.nftCursor.load();

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.issuedBills).toEqual(EXPECTED_ISSUED_BILLS);
    expect(storage.admin).toEqual(address(EXPECTED_ADMIN));
    expectInternalAddress(storage.admin);
    expect(storage.distribution).toBeNotNull();
    expect(storage.collectionContent.hash()).toBeGreater(0);

    expect(cursor.nextItemIndex).toEqual(EXPECTED_NEXT_ITEM_INDEX);
    expect(cursor.current).toBeNotNull();
    expect(cursor.current!).toEqual(address(EXPECTED_CURRENT_NFT));
    expect(cursor.nextStateInit.hash()).toBeGreater(0);

    val distribution = storage.distribution!.load();
    match (distribution) {
        TonstakersPayoutCollectionPendingTonDistribution => {
            expect(distribution.volume).toEqual(0);
        }
        TonstakersPayoutCollectionPendingJettonDistribution => {
            expect(false).toBeTrue();
        }
        TonstakersPayoutCollectionStartedTonDistribution => {
            expect(false).toBeTrue();
        }
        TonstakersPayoutCollectionStartedJettonDistribution => {
            expect(false).toBeTrue();
        }
    }

    println("TONSTAKERS_PAYOUT_COLLECTION_STORAGE={}", storage);
    println("TONSTAKERS_PAYOUT_COLLECTION_CURSOR={}", cursor);
}
