import "@acton/build"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_auction_v1.types"
import "../wrappers/GetgemsNftAuctionV1.gen"

const MAINNET_GETGEMS_NFT_AUCTION_V1_ADDRESS = "EQC7XGlsctb-Z7nyZn3lwEwHxeCtY2A8JlXh_BfE0LfuvvH_"

fun mainnetGetgemsNftAuctionV1(): GetgemsNftAuctionV1 {
    return GetgemsNftAuctionV1.fromAddress(address(MAINNET_GETGEMS_NFT_AUCTION_V1_ADDRESS));
}

fun loadGetgemsNftAuctionV1StorageFromFork(
    auction: GetgemsNftAuctionV1,
): GetgemsNftAuctionV1Storage {
    val account = testing.getAccountState(auction.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftAuctionV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT auction v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT auction v1 mainnet fixture account is frozen");
        }
    }
}

fun expectGetgemsNftAuctionV1CodeFromFork(auction: GetgemsNftAuctionV1) {
    val account = testing.getAccountState(auction.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(build("GetgemsNftAuctionV1").hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT auction v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT auction v1 mainnet fixture account is frozen");
        }
    }
}
