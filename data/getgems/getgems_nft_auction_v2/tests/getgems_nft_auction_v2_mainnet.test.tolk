import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_auction_v2.types"
import "../wrappers/GetgemsNftAuctionV2.gen"

const MAINNET_GETGEMS_NFT_AUCTION_V2_ADDRESS = "EQBNuknMQASMChLilIzdGKc8mDApF-ZRNtGJN4qbe_z2klfF"

fun mainnetGetgemsNftAuctionV2(): GetgemsNftAuctionV2 {
    return GetgemsNftAuctionV2.fromAddress(address(MAINNET_GETGEMS_NFT_AUCTION_V2_ADDRESS));
}

fun loadGetgemsNftAuctionV2StorageFromFork(auction: GetgemsNftAuctionV2): GetgemsNftAuctionV2Storage {
    val account = testing.getAccountState(auction.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftAuctionV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("GetgemsNftAuctionV2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("GetgemsNftAuctionV2 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft auction v2 mainnet getter and storage`() {
    val auction = mainnetGetgemsNftAuctionV2();
    val storage = loadGetgemsNftAuctionV2StorageFromFork(auction);
    val fees = storage.fees.load();
    val constants = storage.constants.load();
    val saleData = auction.getSaleData();

    expect(scripts.isContractDeployed(auction.address)).toBeTrue();
    expect(saleData.magic).toEqual(0x415543);
    expect(saleData.end).toEqual(storage.end);
    expect(saleData.endTime).toEqual(storage.endTime);
    expect(saleData.marketplace).toEqual(constants.marketplace);
    expect(saleData.nft).toEqual(constants.nft);
    expect(saleData.owner).toEqual(storage.nftOwner);
    expect(saleData.lastBid).toEqual(storage.lastBid);
    expect(saleData.lastMember).toEqual(storage.lastMember);
    expect(saleData.minStep).toEqual(constants.minStep);
    expect(saleData.marketFeeAddress).toEqual(fees.marketFeeAddress);
    expect(saleData.mpFeeFactor).toEqual(fees.mpFeeFactor);
    expect(saleData.mpFeeBase).toEqual(fees.mpFeeBase);
    expect(saleData.royaltyAddress).toEqual(fees.royaltyAddress);
    expect(saleData.royaltyFeeFactor).toEqual(fees.royaltyFeeFactor);
    expect(saleData.royaltyFeeBase).toEqual(fees.royaltyFeeBase);
    expect(saleData.maxBid).toEqual(constants.maxBid);
    expect(saleData.minBid).toEqual(constants.minBid);
    expect(saleData.createdAt).toEqual(constants.createdAt);
    expect(saleData.lastBidAt).toEqual(storage.lastBidAt);
    expect(saleData.isCanceled).toEqual(storage.isCanceled);

    println("GETGEMS_NFT_AUCTION_V2_ADDRESS={}", auction.address);
    println("GETGEMS_NFT_AUCTION_V2_STORAGE={}", storage);
    println("GETGEMS_NFT_AUCTION_V2_SALE_DATA={}", saleData);
}
