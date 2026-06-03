import "@acton/build"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_fixprice_sale_v3.types"
import "../wrappers/GetgemsNftFixpriceSaleV3.gen"

const MAINNET_GETGEMS_NFT_FIXPRICE_SALE_V3_ADDRESS = "EQC5jtWNb7d6kBK_AZZJ-VhTpQqKRmKz-x3dtVCjJ6pb2amz"

fun mainnetGetgemsNftFixpriceSaleV3(): GetgemsNftFixpriceSaleV3 {
    return GetgemsNftFixpriceSaleV3.fromAddress(address(MAINNET_GETGEMS_NFT_FIXPRICE_SALE_V3_ADDRESS));
}

fun loadGetgemsNftFixpriceSaleV3StorageFromFork(
    sale: GetgemsNftFixpriceSaleV3,
): GetgemsNftFixpriceSaleV3Storage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftFixpriceSaleV3Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT fixprice sale v3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT fixprice sale v3 mainnet fixture account is frozen");
        }
    }
}

fun expectGetgemsNftFixpriceSaleV3CodeFromFork(sale: GetgemsNftFixpriceSaleV3) {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(build("GetgemsNftFixpriceSaleV3").hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT fixprice sale v3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT fixprice sale v3 mainnet fixture account is frozen");
        }
    }
}
