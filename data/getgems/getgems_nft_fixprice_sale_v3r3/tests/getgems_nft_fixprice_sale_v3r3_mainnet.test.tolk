import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_fixprice_sale_v3r3.types"
import "../wrappers/GetgemsNftFixpriceSaleV3R3.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_fixprice_sale_v3r3/testdata/GetgemsNftFixpriceSaleV3R3.boc"
const MAINNET_SALE_ADDRESS = "EQCUn-X9Uhe1EkNRhHGT-Jx0y5RX5nj7MB9WgHi7c04wYNZw"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const REJECTED_NULL_BOC_PREFIX = 0x9ee965
const EXPECTED_CODE_HASH = 0x24221fa571e542e055c77bedfdbf527c7af460cfdc7f344c450787b4cfa1eb4d

fun mainnetGetgemsNftFixpriceSaleV3R3(): GetgemsNftFixpriceSaleV3R3 {
    return GetgemsNftFixpriceSaleV3R3.fromAddress(address(MAINNET_SALE_ADDRESS));
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun hasRejectedNullBocPrefix(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 24) {
        return false;
    }
    return bytes.preloadUint(24) == REJECTED_NULL_BOC_PREFIX;
}

fun loadGetgemsNftFixpriceSaleV3R3StorageFromFork(
    sale: GetgemsNftFixpriceSaleV3R3,
): GetgemsNftFixpriceSaleV3R3Storage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return GetgemsNftFixpriceSaleV3R3Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems fixed-price sale V3R3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems fixed-price sale V3R3 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems sale v3r3 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();
    expect(hasRejectedNullBocPrefix(rawBoc!)).toBeFalse();

    val code = build("GetgemsNftFixpriceSaleV3R3", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems sale v3r3 rejects three byte null boc`() {
    val threeByteNull = beginCell().storeUint(REJECTED_NULL_BOC_PREFIX, 24).endCell().beginParse();

    expect(hasBocMagic(threeByteNull)).toBeFalse();
    expect(hasRejectedNullBocPrefix(threeByteNull)).toBeTrue();
}

get fun `test getgems sale v3r3 mainnet getters match fork storage`() {
    val sale = mainnetGetgemsNftFixpriceSaleV3R3();
    val storage = loadGetgemsNftFixpriceSaleV3R3StorageFromFork(sale);
    val fees = storage.fees.load();
    val saleData = sale.getSaleData();
    val fixPriceData = sale.getFixPriceData();

    expect(scripts.isContractDeployed(sale.address)).toBeTrue();

    expect(saleData.magic).toEqual(0x46495850);
    expect(saleData.isComplete).toEqual(storage.isComplete);
    expect(saleData.createdAt).toEqual(storage.createdAt);
    expect(saleData.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(saleData.nftAddress).toEqual(storage.nftAddress);
    expectAnyAddressEqualsNullable(saleData.nftOwnerAddress, storage.nftOwnerAddress);
    expect(saleData.fullPrice).toEqual(storage.fullPrice);
    expect(saleData.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(saleData.marketplaceFee).toEqual(fees.marketplaceFee);
    expectAnyAddressEqualsNullable(saleData.royaltyAddress, fees.royaltyAddress);
    expect(saleData.royaltyAmount).toEqual(fees.royaltyAmount);

    expect(fixPriceData.isComplete).toEqual(storage.isComplete);
    expect(fixPriceData.createdAt).toEqual(storage.createdAt);
    expect(fixPriceData.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(fixPriceData.nftAddress).toEqual(storage.nftAddress);
    expectAnyAddressEqualsNullable(fixPriceData.nftOwnerAddress, storage.nftOwnerAddress);
    expect(fixPriceData.fullPrice).toEqual(storage.fullPrice);
    expect(fixPriceData.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(fixPriceData.marketplaceFee).toEqual(fees.marketplaceFee);
    expectAnyAddressEqualsNullable(fixPriceData.royaltyAddress, fees.royaltyAddress);
    expect(fixPriceData.royaltyAmount).toEqual(fees.royaltyAmount);
    expect(fixPriceData.soldAt).toEqual(storage.soldAt);
    expect(fixPriceData.queryId).toEqual(storage.queryId);

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R3_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3R3_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3R3_SALE_DATA={}", saleData);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3R3_FIX_PRICE_DATA={}", fixPriceData);
}
