import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_fixprice_sale_v4r1.types"
import "../wrappers/GetgemsNftFixpriceSaleV4R1.gen"

const MAINNET_GETGEMS_NFT_FIXPRICE_SALE_V4R1_ADDRESS = "EQA51TGedQ5nhKqKA-3lvJ5_dovuBRP5QUIM0zfYHjjxZhBm"
const GETGEMS_NFT_FIXPRICE_SALE_V4R1_BOC = "data/getgems/getgems_nft_fixprice_sale_v4r1/testdata/GetgemsNftFixpriceSaleV4R1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x6b95a6418b9c9d2359045d1e7559b8d549ae0e506f24caab58fa30c8fb1feb86

fun mainnetGetgemsNftFixpriceSaleV4R1(): GetgemsNftFixpriceSaleV4R1 {
    return GetgemsNftFixpriceSaleV4R1.fromAddress(
        address(MAINNET_GETGEMS_NFT_FIXPRICE_SALE_V4R1_ADDRESS),
    );
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

fun loadGetgemsNftFixpriceSaleV4R1StorageFromFork(
    sale: GetgemsNftFixpriceSaleV4R1,
): GetgemsNftFixpriceSaleV4R1Storage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftFixpriceSaleV4R1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT fixprice sale V4R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT fixprice sale V4R1 mainnet fixture account is frozen");
        }
    }
}

fun expectGetgemsNftFixpriceSaleV4R1CodeFromFork(sale: GetgemsNftFixpriceSaleV4R1) {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("GetgemsNftFixpriceSaleV4R1", GETGEMS_NFT_FIXPRICE_SALE_V4R1_BOC).hash(),
            );
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT fixprice sale V4R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT fixprice sale V4R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft fixprice sale v4r1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(GETGEMS_NFT_FIXPRICE_SALE_V4R1_BOC);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expect(hasBocMagic(mutate bytes)).toBeTrue();

    val code = build("GetgemsNftFixpriceSaleV4R1", GETGEMS_NFT_FIXPRICE_SALE_V4R1_BOC);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems nft fixprice sale v4r1 rejects three byte null boc`() {
    var threeByteNull = beginCell().storeUint(0x9ee965, 24).endCell().beginParse();

    expect(hasBocMagic(mutate threeByteNull)).toBeFalse();
}

get fun `test getgems nft fixprice sale v4r1 mainnet code getter and storage`() {
    val sale = mainnetGetgemsNftFixpriceSaleV4R1();
    val storage = loadGetgemsNftFixpriceSaleV4R1StorageFromFork(sale);
    val staticData = storage.staticData.load();
    val saleData = sale.getFixPriceDataV4();

    expect(scripts.isContractDeployed(sale.address)).toBeTrue();
    expectGetgemsNftFixpriceSaleV4R1CodeFromFork(sale);

    expect(saleData.isComplete).toEqual(storage.isComplete);
    expect(saleData.createdAt).toEqual(staticData.createdAt);
    expect(saleData.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(saleData.nftAddress).toEqual(staticData.nftAddress);
    expectAnyAddressEqualsNullable(saleData.nftOwnerAddress, storage.nftOwnerAddress);
    expect(saleData.fullPrice).toEqual(storage.fullTonPrice);
    expectAnyAddressEqualsNullable(saleData.feeAddress, staticData.marketplaceFeeAddress);
    expect(saleData.feePercent).toEqual(staticData.marketplaceFeePercent);
    expectAnyAddressEqualsNullable(saleData.royaltyAddress, staticData.royaltyAddress);
    expect(saleData.royaltyPercent).toEqual(staticData.royaltyPercent);
    expect(saleData.soldAt).toEqual(storage.soldAt);
    expect(saleData.soldQueryId).toEqual(storage.soldQueryId);
    expect(saleData.jettonPriceDict.isEmpty()).toEqual(storage.jettonPrices.isEmpty());

    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_STATIC_DATA={}", staticData);
    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_DATA={}", saleData);
}
