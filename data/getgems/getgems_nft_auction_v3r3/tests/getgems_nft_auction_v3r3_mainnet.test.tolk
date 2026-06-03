import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_auction_v3r3.types"
import "../wrappers/GetgemsNftAuctionV3R3.gen"

const MAINNET_GETGEMS_NFT_AUCTION_V3R3_ADDRESS = "EQDD4HW7_gDHSqWCWWdnqBe1W9YZ_S_fpb2lhaDb0zvqipFU"

fun mainnetGetgemsNftAuctionV3R3(): GetgemsNftAuctionV3R3 {
    return GetgemsNftAuctionV3R3.fromAddress(address(MAINNET_GETGEMS_NFT_AUCTION_V3R3_ADDRESS));
}

fun loadGetgemsNftAuctionV3R3StorageFromFork(auction: GetgemsNftAuctionV3R3): GetgemsNftAuctionV3R3Storage {
    val account = testing.getAccountState(auction.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftAuctionV3R3Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT auction V3R3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT auction V3R3 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft auction v3r3 mainnet getters and storage`() {
    val auction = mainnetGetgemsNftAuctionV3R3();
    val storage = loadGetgemsNftAuctionV3R3StorageFromFork(auction);
    val constants = storage.constants.load();
    val saleData = auction.getSaleData();
    val auctionData = auction.getAuctionData();

    expect(scripts.isContractDeployed(auction.address)).toBeTrue();
    expect(saleData.magic).toEqual(0x415543);
    expect(saleData.isEnded).toEqual(storage.isEnded);
    expect(saleData.endTime).toEqual(storage.endTime);
    expect(saleData.marketplaceAddress).toEqual(constants.marketplaceAddress);
    expect(saleData.nftAddress).toEqual(constants.nftAddress);
    expect(saleData.lastBid).toEqual(storage.lastBid);
    expect(saleData.minStep).toEqual(constants.minStep);
    expect(saleData.marketplaceFeeFactor).toEqual(storage.marketplaceFeeFactor);
    expect(saleData.marketplaceFeeBase).toEqual(storage.marketplaceFeeBase);
    expect(saleData.royaltyFeeFactor).toEqual(storage.royaltyFeeFactor);
    expect(saleData.royaltyFeeBase).toEqual(storage.royaltyFeeBase);
    expect(saleData.maxBid).toEqual(constants.maxBid);
    expect(saleData.createdAt).toEqual(constants.createdAt);
    expect(saleData.lastBidAt).toEqual(storage.lastBidAt);
    expect(saleData.isCanceled).toEqual(storage.isCanceled);

    expect(auctionData.isActivated).toEqual(storage.nftOwnerAddress != null);
    expect(auctionData.isEnded).toEqual(storage.isEnded);
    expect(auctionData.endTime).toEqual(storage.endTime);
    expect(auctionData.marketplaceAddress).toEqual(constants.marketplaceAddress);
    expect(auctionData.nftAddress).toEqual(constants.nftAddress);
    expect(auctionData.lastBid).toEqual(storage.lastBid);
    expect(auctionData.minStep).toEqual(constants.minStep);
    expect(auctionData.stepTime).toEqual(constants.stepTime);
    expect(auctionData.lastQueryId).toEqual(storage.lastQueryId);

    println("GETGEMS_NFT_AUCTION_V3R3_ADDRESS={}", auction.address);
    println("GETGEMS_NFT_AUCTION_V3R3_STORAGE={}", storage);
    println("GETGEMS_NFT_AUCTION_V3R3_SALE_DATA={}", saleData);
    println("GETGEMS_NFT_AUCTION_V3R3_AUCTION_DATA={}", auctionData);
}
