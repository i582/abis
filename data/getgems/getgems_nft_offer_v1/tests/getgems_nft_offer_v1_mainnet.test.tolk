import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_offer_v1.types"
import "../wrappers/GetgemsNftOfferV1.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_offer_v1/testdata/GetgemsNftOfferV1.boc"
const MAINNET_GETGEMS_NFT_OFFER_V1_ADDRESS = "EQA8t5MDB-nkuaivEe6GBHpPCP_tA8r5RORQUzI-XhVWWwFt"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x7aa13161df5469acb9daab5ad3b9cb14a2c9754395e6355ccdb8dded6482092b

fun mainnetGetgemsNftOfferV1(): GetgemsNftOfferV1 {
    return GetgemsNftOfferV1.fromAddress(address(MAINNET_GETGEMS_NFT_OFFER_V1_ADDRESS));
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun hasBocMagic(mutate bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.loadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadGetgemsNftOfferV1StorageFromFork(offer: GetgemsNftOfferV1): GetgemsNftOfferV1Storage {
    val account = testing.getAccountState(offer.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return GetgemsNftOfferV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT offer V1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT offer V1 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft offer v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expect(hasBocMagic(mutate bytes)).toBeTrue();

    val code = build("GetgemsNftOfferV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems nft offer v1 rejects three byte null boc`() {
    var threeByteNull = beginCell().storeUint(0x9ee965, 24).endCell().beginParse();

    expect(hasBocMagic(mutate threeByteNull)).toBeFalse();
}

get fun `test getgems nft offer v1 mainnet code getter and storage`() {
    val offer = mainnetGetgemsNftOfferV1();
    val storage = loadGetgemsNftOfferV1StorageFromFork(offer);
    val fees = storage.fees.load();
    val offerData = offer.getOfferData();

    expect(scripts.isContractDeployed(offer.address)).toBeTrue();

    expect(offerData.magic).toEqual(0x4f46464552);
    expect(offerData.isComplete).toEqual(storage.isComplete);
    expect(offerData.createdAt).toEqual(storage.createdAt);
    expect(offerData.finishAt).toEqual(storage.finishAt);
    expect(offerData.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(offerData.nftAddress).toEqual(storage.nftAddress);
    expect(offerData.offerOwnerAddress).toEqual(storage.offerOwnerAddress);
    expect(offerData.fullPrice).toEqual(storage.fullPrice);
    expect(offerData.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(offerData.marketplaceFactor).toEqual(fees.marketplaceFactor);
    expect(offerData.marketplaceBase).toEqual(fees.marketplaceBase);
    expectAnyAddressEqualsNullable(offerData.royaltyAddress, fees.royaltyAddress);
    expect(offerData.royaltyFactor).toEqual(fees.royaltyFactor);
    expect(offerData.royaltyBase).toEqual(fees.royaltyBase);

    println("GETGEMS_NFT_OFFER_V1_ADDRESS={}", offer.address);
    println("GETGEMS_NFT_OFFER_V1_STORAGE={}", storage);
    println("GETGEMS_NFT_OFFER_V1_DATA={}", offerData);
}
