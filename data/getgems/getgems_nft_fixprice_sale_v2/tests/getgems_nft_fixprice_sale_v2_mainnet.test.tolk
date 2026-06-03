import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_fixprice_sale_v2.types"
import "../wrappers/GetgemsNftFixpriceSaleV2.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_fixprice_sale_v2/testdata/GetgemsNftFixpriceSaleV2.boc"
const MAINNET_SALE_ADDRESS = "EQDvcDAh-9Dr_C6Md-9NvoDmObEHm04363TcsNgE1Tm48feX"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x8278f4c5233de6fbedc969af519344a7a9bffc544856dba986a95c0bcf8571c9

fun mainnetGetgemsNftFixpriceSaleV2(): GetgemsNftFixpriceSaleV2 {
    return GetgemsNftFixpriceSaleV2.fromAddress(address(MAINNET_SALE_ADDRESS));
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun loadGetgemsNftFixpriceSaleV2StorageFromFork(
    sale: GetgemsNftFixpriceSaleV2,
): GetgemsNftFixpriceSaleV2Storage {
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
            return GetgemsNftFixpriceSaleV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems fixed-price sale v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems fixed-price sale v2 mainnet fixture account is frozen");
        }
    }
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test getgems sale v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("GetgemsNftFixpriceSaleV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems sale v2 rejects three byte null boc`() {
    var threeByteNull = beginCell().storeUint(0, 24).endCell().beginParse();
    expect(hasBocMagic(threeByteNull)).toBeFalse();
}

get fun `test getgems sale v2 mainnet getter matches fork storage`() {
    val sale = mainnetGetgemsNftFixpriceSaleV2();
    val storage = loadGetgemsNftFixpriceSaleV2StorageFromFork(sale);
    val fees = storage.fees.load();
    val data = sale.getSaleData();

    expect(scripts.isContractDeployed(sale.address)).toBeTrue();
    expect(data.magic).toEqual(0x46495850);
    expect(data.isComplete).toEqual(storage.isComplete);
    expect(data.createdAt).toEqual(storage.createdAt);
    expect(data.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(data.nftAddress).toEqual(storage.nftAddress);
    expectAnyAddressEqualsNullable(data.nftOwnerAddress, storage.nftOwnerAddress);
    expect(data.fullPrice).toEqual(storage.fullPrice);
    expect(data.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(data.marketplaceFee).toEqual(fees.marketplaceFee);
    expectAnyAddressEqualsNullable(data.royaltyAddress, fees.royaltyAddress);
    expect(data.royaltyAmount).toEqual(fees.royaltyAmount);

    println("GETGEMS_NFT_FIXPRICE_SALE_V2_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_FIXPRICE_SALE_V2_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V2_DATA={}", data);
}
