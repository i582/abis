import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_offer_v1r3.types"
import "../wrappers/GetgemsNftOfferV1R3.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_offer_v1r3/testdata/GetgemsNftOfferV1R3.boc"
const MAINNET_OFFER_ADDRESS = "EQBtEe4JkKx0zSMFRZsSkWH8m7x7YmHPn6fvRa_4GwVERj0x"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x6e5d667fa6efa8187c6d029efd4015601232fd2e36c291dbc346dedab6dc8024
const OFFER_MAGIC = 0x4f46464552

fun mainnetGetgemsNftOfferV1R3(): GetgemsNftOfferV1R3 {
    return GetgemsNftOfferV1R3.fromAddress(address(MAINNET_OFFER_ADDRESS));
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun loadGetgemsNftOfferV1R3StorageFromFork(
    offer: GetgemsNftOfferV1R3,
): GetgemsNftOfferV1R3Storage {
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
            return GetgemsNftOfferV1R3Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT offer V1R3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT offer V1R3 mainnet fixture account is frozen");
        }
    }
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test getgems offer v1r3 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("GetgemsNftOfferV1R3", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems offer v1r3 rejects three byte null boc`() {
    val threeByteNull = beginCell().storeUint(0, 24).endCell().beginParse();
    expect(hasBocMagic(threeByteNull)).toBeFalse();
}

get fun `test getgems offer v1r3 mainnet getters match fork storage`() {
    val offer = mainnetGetgemsNftOfferV1R3();
    val storage = loadGetgemsNftOfferV1R3StorageFromFork(offer);
    val fees = storage.fees.load();
    val data = offer.getOfferData();
    val dataV2 = offer.getOfferDataV2();

    expect(scripts.isContractDeployed(offer.address)).toBeTrue();
    expect(storage.canDeploy).toBeFalse();

    expect(data.magic).toEqual(OFFER_MAGIC);
    expect(data.isComplete).toEqual(storage.isComplete);
    expect(data.createdAt).toEqual(storage.createdAt);
    expect(data.finishAt).toEqual(storage.finishAt);
    expect(data.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(data.nftAddress).toEqual(storage.nftAddress);
    expect(data.offerOwnerAddress).toEqual(storage.offerOwnerAddress);
    expect(data.fullPrice).toEqual(storage.fullPrice);
    expect(data.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(data.marketplaceFeeFactor).toEqual(fees.marketplaceFeeFactor);
    expect(data.marketplaceFeeBase).toEqual(fees.marketplaceFeeBase);
    expectAnyAddressEqualsNullable(data.royaltyAddress, fees.royaltyAddress);
    expect(data.royaltyFeeFactor).toEqual(fees.royaltyFeeFactor);
    expect(data.royaltyFeeBase).toEqual(fees.royaltyFeeBase);

    expect(dataV2.magic).toEqual(OFFER_MAGIC);
    expect(dataV2.isComplete).toEqual(storage.isComplete);
    expect(dataV2.createdAt).toEqual(storage.createdAt);
    expect(dataV2.finishAt).toEqual(storage.finishAt);
    expect(dataV2.swapAt).toEqual(storage.swapAt);
    expect(dataV2.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(dataV2.nftAddress).toEqual(storage.nftAddress);
    expect(dataV2.offerOwnerAddress).toEqual(storage.offerOwnerAddress);
    expect(dataV2.fullPrice).toEqual(storage.fullPrice);
    expect(dataV2.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(dataV2.marketplaceFeeFactor).toEqual(fees.marketplaceFeeFactor);
    expect(dataV2.marketplaceFeeBase).toEqual(fees.marketplaceFeeBase);
    expectAnyAddressEqualsNullable(dataV2.royaltyAddress, fees.royaltyAddress);
    expect(dataV2.royaltyFeeFactor).toEqual(fees.royaltyFeeFactor);
    expect(dataV2.royaltyFeeBase).toEqual(fees.royaltyFeeBase);
    expect(dataV2.profitPrice).toEqual(data.profitPrice);

    println("GETGEMS_NFT_OFFER_V1R3_ADDRESS={}", offer.address);
    println("GETGEMS_NFT_OFFER_V1R3_STORAGE={}", storage);
    println("GETGEMS_NFT_OFFER_V1R3_DATA={}", data);
    println("GETGEMS_NFT_OFFER_V1R3_DATA_V2={}", dataV2);
}
