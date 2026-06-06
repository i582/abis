import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonstakers_payout_item.types"

const CODE_FIXTURE_BOC_PATH = "data/tonstakers/payout_item/testdata/TonstakersPayoutItem.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonstakers/payout_item/testdata/TonstakersPayoutItem.data.boc"
const CODE_FIXTURE_BOC = "te6ccgECGQEAAzoAART/APSkE/S88sgLAQIBYgIDAgLLBAUCASAVFgIBIAYHAgFIDxAEsdmRDjgEkvgfBoaYGAuNhJL4HwfSB9IBj9ABj6Ahj9ABj9ABg51NoAAWmP6Z+s+AmA2fGBEUEIL+Yeil1xgRmaGhHBCHiT/yddR0IZgO2ecBgBQQgX5ZNRXUCAkKCwARu/SIYYAB5cKbAMIwMTMzhA/4QljHBfL0AfpA+gD6QPpAMCNVIPAWghAFXUqAcvsCcIIQBRONkSHIywFwAcoAEDRBMIEAgsiAEAHLBVAGzxZQBPoCcAHLalkCyx/LPyFus5MBzxeRMeLJAfsAAqIyQARRNMcF8uGR+kAh8A36QNIAMfoAINdJwgDy4sQHghAFXUqAoSGUUxWgod4i1wsBwwAgkgahkTbiIML/8uGSIZQQJzZb4w0CkxNfA+MN8BUMDQHO8BRSYscFUWTHBRax8uGRJNcLAcMAjjUEggiYloCCEPEn/k4lbXHIgBABywVQBs8WUAT6AnABy2pZAssfyz8hbrOTAc8XkTHiyQH7AJE04nCCEO1YsLLIUAb6AlAGzxbLPxRDMIEAoA4AiI498BRfA3CCEIt3FzUCyMv/UAPPFkEwgEDIgBABywVQBs8WUAT6AnABy2pZAssfyz8hbrOTAc8XkTHiyQH7AOBb8sGWAHyCEAUTjZHIUAjPFlAIzxZxJEgUVEaQyIAQAcsFUAbPFlAE+gJwActqWQLLH8s/IW6zkwHPF5Ex4skB+wAQNABoI/ANQzCCENUydtsBbXHIgBABywVQBs8WUAT6AnABy2pZAssfyz8hbrOTAc8XkTHiyQH7AABMyIAQAcsFUAbPFlAE+gJwActqWQLLH8s/IW6zkwHPF5Ex4skB+wAAK/dqJoaQAQyn0gfDDwEHww/SAYfDE2wCASAREgIBIBMUADlMgBzxbJyH8BygBQBM8W+EHPFlj6AgHPFszJ7VSAAhPhB+kDTP/oA+kDXTND6QDCAAHzIfwHKAAHPFvhBzxbJ7VSAAF7/OD4Ca34CggSL4JAIBSBcYABu1+f4CfgKLeQA/QFkicAAxtEOwUga6zt7Vjca86r1Hia+vnq7sT2OeEA=="
const DATA_FIXTURE_BOC = "te6ccgEBAgEAmAAB4cADts5k+4+l5AXl9nyT3nSpkz1Z9IOqfZZY+zoSRZHrxmgA5bXWgMzEby67pfcskBjIhWBRPu0hwDUNWBzCsg0/nqwAAAAAAAAAjI1UzRgwAlHxououJY0qzZRuq39wY3qqdSGbt48KA+6VDpuztX8KAQBDgAGEW06sM0SNEw6TwUGCiySERMA9TVjUjjqhK68XbrGVUA=="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x6acd958dceb085713fd3f2657993d446c238fa01dcd3c550b8f6216c79f67032
const EXPECTED_DATA_HASH = 0x0e45c682a6a25bc596687ade3ac496d352fa1bbe5d7ead44e52b6231f2be68ac
const EXPECTED_OWNER_ADDRESS = "0:3b6ce64fb8fa5e405e5f67c93de74a9933d59f483aa7d9658fb3a124591ebc66"
const EXPECTED_COLLECTION_ADDRESS = "0:72daeb40666237975dd2fb96480c6442b0289f7690e01a86ac0e6159069fcf56"
const EXPECTED_PREVIOUS_ITEM_ADDRESS = "0:947c68ba8b89634ab3651baadfdc18deaa9d4866ede3c280fba543a6eced5fc2"
const EXPECTED_NEXT_ITEM_ADDRESS = "0:0c22da75619a246898749e0a0c145924222601ea6ac6a471d5095d78bb758caa"
const EXPECTED_ITEM_INDEX = 70
const EXPECTED_AMOUNT = 1789290689

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadLiveDataFixture(): TonstakersPayoutItemStorage {
    val data = parseCellFromBase64(DATA_FIXTURE_BOC);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val cursor = data.beginParse();
    expect(cursor.remainingBitsCount()).toEqual(902);
    expect(cursor.remainingRefsCount()).toEqual(1);

    return TonstakersPayoutItemStorage.fromCell(data);
}

get fun `test tonstakers payout item local boc fixtures are real and hash verified`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val code = parseCellFromBase64(CODE_FIXTURE_BOC);
    val data = parseCellFromBase64(DATA_FIXTURE_BOC);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test tonstakers payout item live data fixture parses runtime storage`() {
    val storage = loadLiveDataFixture();
    val next = storage.nextItemAddress.load();

    expect(storage.isInitialized).toBeTrue();
    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(storage.collectionAddress).toEqual(address(EXPECTED_COLLECTION_ADDRESS));
    expect(storage.itemIndex).toEqual(EXPECTED_ITEM_INDEX);
    expect(storage.amount).toEqual(EXPECTED_AMOUNT);
    expect(storage.previousItemAddress).toEqual(address(EXPECTED_PREVIOUS_ITEM_ADDRESS));
    expect(next.nextItemAddress).toEqual(address(EXPECTED_NEXT_ITEM_ADDRESS));

    println("TONSTAKERS_PAYOUT_ITEM_STORAGE={}", storage);
    println("TONSTAKERS_PAYOUT_ITEM_NEXT={}", next);
}
