import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_fixprice_sale_v3r2.types"
import "../wrappers/GetgemsNftFixpriceSaleV3R2.gen"

const MAINNET_GETGEMS_NFT_FIXPRICE_SALE_V3R2_ADDRESS = "EQDKXtnA6NMRRn1iRxmK30gY_xc0xXZjJBRyxsADC54iarMT"
const GETGEMS_NFT_FIXPRICE_SALE_V3R2_BOC = "data/getgems/getgems_nft_fixprice_sale_v3r2/testdata/GetgemsNftFixpriceSaleV3R2.boc"

fun mainnetGetgemsNftFixpriceSaleV3R2(): GetgemsNftFixpriceSaleV3R2 {
    return GetgemsNftFixpriceSaleV3R2.fromAddress(
        address(MAINNET_GETGEMS_NFT_FIXPRICE_SALE_V3R2_ADDRESS),
    );
}

fun loadGetgemsNftFixpriceSaleV3R2StorageFromFork(
    sale: GetgemsNftFixpriceSaleV3R2,
): GetgemsNftFixpriceSaleV3R2Storage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftFixpriceSaleV3R2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT fixprice sale V3R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT fixprice sale V3R2 mainnet fixture account is frozen");
        }
    }
}

fun expectGetgemsNftFixpriceSaleV3R2CodeFromFork(sale: GetgemsNftFixpriceSaleV3R2) {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(
                build("GetgemsNftFixpriceSaleV3R2", GETGEMS_NFT_FIXPRICE_SALE_V3R2_BOC).hash(),
            );
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT fixprice sale V3R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT fixprice sale V3R2 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft fixprice sale v3r2 mainnet code getter and storage`() {
    val sale = mainnetGetgemsNftFixpriceSaleV3R2();
    val storage = loadGetgemsNftFixpriceSaleV3R2StorageFromFork(sale);
    val fees = storage.fees.load();
    val saleData = sale.getSaleData();

    expect(scripts.isContractDeployed(sale.address)).toBeTrue();
    expectGetgemsNftFixpriceSaleV3R2CodeFromFork(sale);

    expect(saleData.magic).toEqual(0x46495850);
    expect(saleData.isComplete).toEqual(storage.isComplete);
    expect(saleData.createdAt).toEqual(storage.createdAt);
    expect(saleData.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(saleData.nftAddress).toEqual(storage.nftAddress);
    expect(saleData.fullPrice).toEqual(storage.fullPrice);
    expect(saleData.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(saleData.marketplaceFee).toEqual(fees.marketplaceFee);
    expect(saleData.royaltyAmount).toEqual(fees.royaltyAmount);

    if (storage.nftOwnerAddress == null) {
        expect(saleData.nftOwnerAddress).toBeNoneAddress();
    } else {
        expect(saleData.nftOwnerAddress).toEqual(storage.nftOwnerAddress! as any_address);
    }

    if (fees.royaltyAddress == null) {
        expect(saleData.royaltyAddress).toBeNoneAddress();
    } else {
        expect(saleData.royaltyAddress).toEqual(fees.royaltyAddress! as any_address);
    }

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R2_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3R2_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V3R2_SALE_DATA={}", saleData);
}
