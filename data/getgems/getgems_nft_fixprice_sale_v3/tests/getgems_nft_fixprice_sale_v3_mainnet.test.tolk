import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/testing/expect"
import "./test_utils"
import "../types/getgems_nft_fixprice_sale_v3.types"
import "../wrappers/GetgemsNftFixpriceSaleV3.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_fixprice_sale_v3/testdata/GetgemsNftFixpriceSaleV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x32050dfac44f64866bcc86f2cd9e1305fe9dcadb3959c002237cfb0902d44323

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

get fun `test getgems nft fixprice sale v3 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expect(hasBocMagic(mutate bytes)).toBeTrue();

    val code = build("GetgemsNftFixpriceSaleV3", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems nft fixprice sale v3 rejects three byte null boc`() {
    var threeByteNull = beginCell().storeUint(0, 24).endCell().beginParse();

    expect(hasBocMagic(mutate threeByteNull)).toBeFalse();
}

get fun `test getgems nft fixprice sale v3 mainnet code getter and storage`() {
    val sale = mainnetGetgemsNftFixpriceSaleV3();
    val storage = loadGetgemsNftFixpriceSaleV3StorageFromFork(sale);
    val fees = storage.fees.load();
    val saleData = sale.getSaleData();

    expect(scripts.isContractDeployed(sale.address)).toBeTrue();
    expectGetgemsNftFixpriceSaleV3CodeFromFork(sale);

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

    println("GETGEMS_NFT_FIXPRICE_SALE_V3_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3_SALE_DATA={}", saleData);
}
