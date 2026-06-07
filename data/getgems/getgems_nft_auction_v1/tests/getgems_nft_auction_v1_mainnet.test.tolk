import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/testing/expect"
import "./test_utils"
import "../types/getgems_nft_auction_v1.types"
import "../wrappers/GetgemsNftAuctionV1.gen"

get fun `test getgems nft auction v1 mainnet code getters and storage`() {
    val auction = mainnetGetgemsNftAuctionV1();
    val storage = loadGetgemsNftAuctionV1StorageFromFork(auction);
    val fees = storage.fees.load();
    val bids = storage.bids.load();
    val nft = storage.nft.load();
    val feesInfo = auction.getFeesInfo();
    val bidInfo = auction.getBidInfo();
    val sale = auction.getSaleData();

    expect(scripts.isContractDeployed(auction.address)).toBeTrue();
    expectGetgemsNftAuctionV1CodeFromFork(auction);

    expect(sale.magic).toEqual(0x415543);
    expect(sale.end).toEqual(storage.end);
    expect(sale.endTime).toEqual(bids.endTime);
    expect(sale.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(sale.nftAddress).toEqual(nft.nftAddress);
    expect(sale.lastBid).toEqual(bids.lastBid);
    expect(sale.minStep).toEqual(bids.minStep);
    expect(sale.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(sale.marketplaceFeeFactor).toEqual(fees.marketplaceFeeFactor);
    expect(sale.marketplaceFeeBase).toEqual(fees.marketplaceFeeBase);
    expect(sale.royaltyFeeAddress).toEqual(fees.royaltyFeeAddress);
    expect(sale.royaltyFeeFactor).toEqual(fees.royaltyFeeFactor);
    expect(sale.royaltyFeeBase).toEqual(fees.royaltyFeeBase);
    expect(sale.maxBid).toEqual(bids.maxBid);
    expect(sale.minBid).toEqual(bids.minBid);
    expect(sale.createdAt).toEqual(storage.createdAt);
    expect(sale.lastBidAt).toEqual(bids.lastBidAt);
    expect(sale.isCanceled).toEqual(storage.isCanceled);

    expect(feesInfo.marketplaceFeeFactor).toEqual(fees.marketplaceFeeFactor);
    expect(feesInfo.marketplaceFeeBase).toEqual(fees.marketplaceFeeBase);
    expect(feesInfo.royaltyFeeFactor).toEqual(fees.royaltyFeeFactor);
    expect(feesInfo.royaltyFeeBase).toEqual(fees.royaltyFeeBase);

    expect(bidInfo.minBid).toEqual(bids.minBid);
    expect(bidInfo.maxBid).toEqual(bids.maxBid);
    expect(bidInfo.minStep).toEqual(bids.minStep);
    expect(bidInfo.lastBid).toEqual(bids.lastBid);
    expect(bidInfo.endTime).toEqual(bids.endTime);

    println("GETGEMS_NFT_AUCTION_V1_ADDRESS={}", auction.address);
    println("GETGEMS_NFT_AUCTION_V1_STORAGE={}", storage);
    println("GETGEMS_NFT_AUCTION_V1_SALE={}", sale);
}
