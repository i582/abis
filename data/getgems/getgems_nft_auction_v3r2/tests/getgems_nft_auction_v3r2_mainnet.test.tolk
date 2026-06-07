import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_auction_v3r2.types"
import "../wrappers/GetgemsNftAuctionV3R2.gen"

const MAINNET_GETGEMS_NFT_AUCTION_V3R2_ADDRESS = "EQAaZQJxXZyIvM-EFKojUx9m9eklJAA8igVMu948RIgqwWeh"

fun mainnetGetgemsNftAuctionV3R2(): GetgemsNftAuctionV3R2 {
    return GetgemsNftAuctionV3R2.fromAddress(address(MAINNET_GETGEMS_NFT_AUCTION_V3R2_ADDRESS));
}

fun loadGetgemsNftAuctionV3R2StorageFromFork(
    auction: GetgemsNftAuctionV3R2,
): GetgemsNftAuctionV3R2Storage {
    val account = testing.getAccountState(auction.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftAuctionV3R2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT auction V3R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT auction V3R2 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft auction v3r2 mainnet getter and storage`() {
    val auction = mainnetGetgemsNftAuctionV3R2();
    val storage = loadGetgemsNftAuctionV3R2StorageFromFork(auction);
    val saleData = auction.getSaleData();

    expect(scripts.isContractDeployed(auction.address)).toBeTrue();
    expect(saleData.magic).toEqual(0x415543);
    expect(saleData.end).toEqual(storage.end);
    expect(saleData.endTime).toEqual(storage.endTime);
    expect(saleData.lastBid).toEqual(storage.lastBid);
    expect(saleData.lastBidAt).toEqual(storage.lastBidAt);
    expect(saleData.isCanceled).toEqual(storage.isCanceled);
    expect(saleData.minBid).toBeGreaterOrEqual(0);
    expect(saleData.maxBid).toBeGreaterOrEqual(0);

    println("GETGEMS_NFT_AUCTION_V3R2_ADDRESS={}", auction.address);
    println("GETGEMS_NFT_AUCTION_V3R2_STORAGE={}", storage);
    println("GETGEMS_NFT_AUCTION_V3R2_SALE_DATA={}", saleData);
}
