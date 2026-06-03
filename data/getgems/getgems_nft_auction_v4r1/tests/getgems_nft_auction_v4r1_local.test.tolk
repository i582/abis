import "@acton/build"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_auction_v4r1.types"
import "../wrappers/GetgemsNftAuctionV4R1.gen"

const GETGEMS_NFT_AUCTION_V4R1_CODE_BOC = "data/getgems/getgems_nft_auction_v4r1/testdata/GetgemsNftAuctionV4R1.boc"
const GETGEMS_NFT_AUCTION_V4R1_END_TIME = 1924992000
const GETGEMS_NFT_AUCTION_V4R1_CREATED_AT = 1924905600
const GETGEMS_NFT_AUCTION_V4R1_MIN_BID = 1000000000
const GETGEMS_NFT_AUCTION_V4R1_MAX_BID = 5000000000
const GETGEMS_NFT_AUCTION_V4R1_MIN_STEP = 5
const GETGEMS_NFT_AUCTION_V4R1_STEP_TIME = 900
const GETGEMS_NFT_AUCTION_V4R1_MP_FEE_FACTOR = 500
const GETGEMS_NFT_AUCTION_V4R1_MP_FEE_BASE = 10000
const GETGEMS_NFT_AUCTION_V4R1_ROYALTY_FACTOR = 250
const GETGEMS_NFT_AUCTION_V4R1_ROYALTY_BASE = 10000

struct GetgemsNftAuctionV4R1Fixture {
    auction: GetgemsNftAuctionV4R1
    storage: GetgemsNftAuctionV4R1Storage
}

fun getgemsNftAuctionV4R1Fixture(): GetgemsNftAuctionV4R1Fixture {
    val marketplace = testing.treasury("getgems-auction-v4r1-marketplace");
    val marketFee = testing.treasury("getgems-auction-v4r1-market-fee");
    val royalty = testing.treasury("getgems-auction-v4r1-royalty");
    val nft = testing.treasury("getgems-auction-v4r1-nft");

    val fees = GetgemsNftAuctionV4R1Fees {
        marketFeeAddress: marketFee.address,
        royaltyAddress: royalty.address,
        mpFeeFactor: GETGEMS_NFT_AUCTION_V4R1_MP_FEE_FACTOR,
        mpFeeBase: GETGEMS_NFT_AUCTION_V4R1_MP_FEE_BASE,
        royaltyFeeFactor: GETGEMS_NFT_AUCTION_V4R1_ROYALTY_FACTOR,
        royaltyFeeBase: GETGEMS_NFT_AUCTION_V4R1_ROYALTY_BASE,
    };
    val constants = GetgemsNftAuctionV4R1Constants {
        marketplace: marketplace.address,
        minBid: GETGEMS_NFT_AUCTION_V4R1_MIN_BID,
        maxBid: GETGEMS_NFT_AUCTION_V4R1_MAX_BID,
        minStep: GETGEMS_NFT_AUCTION_V4R1_MIN_STEP,
        stepTime: GETGEMS_NFT_AUCTION_V4R1_STEP_TIME,
        nft: nft.address,
        createdAt: GETGEMS_NFT_AUCTION_V4R1_CREATED_AT,
    };
    val storage = GetgemsNftAuctionV4R1Storage {
        end: false,
        isCanceled: false,
        lastMember: null,
        lastBid: 0,
        lastBidAt: 0,
        endTime: GETGEMS_NFT_AUCTION_V4R1_END_TIME,
        nftOwner: null,
        lastQueryId: 0,
        fees: fees.toCell(),
        constants: constants.toCell(),
        jettonData: null,
    };
    val stateInit = ContractState {
        code: build("GetgemsNftAuctionV4R1", GETGEMS_NFT_AUCTION_V4R1_CODE_BOC),
        data: storage.toCell(),
    };
    val address = AutoDeployAddress { stateInit }.calculateAddress();
    val auction = GetgemsNftAuctionV4R1 { address, stateInit };
    return GetgemsNftAuctionV4R1Fixture { auction, storage };
}

fun deployGetgemsNftAuctionV4R1Fixture(): GetgemsNftAuctionV4R1Fixture {
    val fixture = getgemsNftAuctionV4R1Fixture();
    val deployer = testing.treasury("getgems-auction-v4r1-local-deployer");
    if (fixture.auction.stateInit == null) {
        Assert.fail("Getgems NFT auction V4R1 fixture has no state init");
    }

    val deployMsg = createMessage({
        bounce: false,
        value: ton("0.05"),
        dest: { stateInit: fixture.auction.stateInit },
        body: GetgemsNftAuctionV4R1DeployAuction { queryId: 0 },
    });
    val txs = net.send(deployer.address, deployMsg);
    expect(txs).toHaveSuccessfulDeploy<GetgemsNftAuctionV4R1DeployAuction>({
        from: deployer.address,
        to: fixture.auction.address,
        exitCode: 0,
    });
    expect(testing.isDeployed(fixture.auction.address)).toBeTrue();
    return fixture;
}

fun loadGetgemsNftAuctionV4R1Storage(auction: GetgemsNftAuctionV4R1): GetgemsNftAuctionV4R1Storage {
    val account = testing.getAccountState(auction.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftAuctionV4R1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT auction V4R1 local fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT auction V4R1 local fixture account is frozen");
        }
    }
}

get fun `test getgems nft auction v4r1 local getters and storage`() {
    val fixture = deployGetgemsNftAuctionV4R1Fixture();
    val storage = loadGetgemsNftAuctionV4R1Storage(fixture.auction);
    val data = fixture.auction.getAuctionDataV4();
    val fees = storage.fees.load();
    val constants = storage.constants.load();

    expect(data.activated).toBeFalse();
    expect(data.end).toEqual(storage.end);
    expect(data.endTime).toEqual(storage.endTime);
    expect(data.marketplace).toEqual(constants.marketplace);
    expect(data.nft).toEqual(constants.nft);
    expect(data.owner).toBeNoneAddress();
    expect(data.lastBid).toEqual(storage.lastBid);
    expect(data.lastMember).toBeNoneAddress();
    expect(data.minStep).toEqual(constants.minStep);
    expect(data.marketFeeAddress).toEqual(fees.marketFeeAddress);
    expect(data.mpFeeFactor).toEqual(fees.mpFeeFactor);
    expect(data.mpFeeBase).toEqual(fees.mpFeeBase);
    expect(data.royaltyAddress).toEqual(fees.royaltyAddress);
    expect(data.royaltyFeeFactor).toEqual(fees.royaltyFeeFactor);
    expect(data.royaltyFeeBase).toEqual(fees.royaltyFeeBase);
    expect(data.maxBid).toEqual(constants.maxBid);
    expect(data.minBid).toEqual(constants.minBid);
    expect(data.createdAt).toEqual(constants.createdAt);
    expect(data.lastBidAt).toEqual(storage.lastBidAt);
    expect(data.isCanceled).toEqual(storage.isCanceled);
    expect(data.stepTime).toEqual(constants.stepTime);
    expect(data.lastQueryId).toEqual(storage.lastQueryId);
    expect(data.jettonWallet).toBeNoneAddress();
    expect(data.jettonMaster).toBeNoneAddress();
    expect(data.isBrokenState).toBeFalse();
    expect(data.publicKey).toEqual(0);
    expect(storage.lastMember).toBeNull();
    expect(storage.nftOwner).toBeNull();
    expect(storage.jettonData).toBeNull();

    println("GETGEMS_NFT_AUCTION_V4R1_ADDRESS={}", fixture.auction.address);
    println("GETGEMS_NFT_AUCTION_V4R1_STORAGE={}", storage);
    println("GETGEMS_NFT_AUCTION_V4R1_DATA={}", data);
}
