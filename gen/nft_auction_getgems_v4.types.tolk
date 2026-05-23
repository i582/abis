// Generated from XML ABI schemas.
// Source schema: schemas/nft_sale.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: ce5a78534eaaa6ceed8dafd486d076eb60a9b0d6dbfb53676f662649c0689956

contract NftAuctionGetgemsV4 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/nft_sale.xml"
}

struct GetAuctionDataV4Reply {
    activated: bool
    end: bool
    endTime: uint32
    marketplace: address
    nft: address
    owner: address
    lastBid: int
    lastMember: address
    minStep: uint32
    marketFeeAddress: address
    mpFeeFactor: uint32
    mpFeeBase: uint32
    royaltyAddress: address
    royaltyFeeFactor: uint32
    royaltyFeeBase: uint32
    maxBid: int
    minBid: int
    createdAt: uint32
    lastBidAt: uint32
    isCanceled: bool
    stepTime: uint32
    lastQueryId: uint64
    jettonWallet: address
    jettonMaster: address
    isBrokenState: bool
    publicKey: int
}

enum Errors {
    UnauthorizedAddress = 403
    LowBid = 1000
    AlreadyInitiated = 1001
    InvalidOpExpectOwnershipAssigned = 1002
    InvalidOpExpectOwnershipAssigned2 = 1003
    AlreadyExecuted = 1005
    AlreadyActivated = 1006
    NotEnoughTons = 1008
    AlreadyHasBid = 1009
    AuctionInProgress = 1010
    AuctionIsInABrokenStateAuctionDurationIsTooLong = 1014
    AuctionHasNotBeenActivatedYet = 1015
    AuctionIsInABrokenState = 1016
    WrongCurrency = 1017
    UnknownOperation = 65535
}

get fun get_auction_data_v4(): GetAuctionDataV4Reply {
    return {
        activated: false,
        end: false,
        endTime: 0,
        marketplace: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nft: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        lastBid: 0,
        lastMember: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        minStep: 0,
        marketFeeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        mpFeeFactor: 0,
        mpFeeBase: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        royaltyFeeFactor: 0,
        royaltyFeeBase: 0,
        maxBid: 0,
        minBid: 0,
        createdAt: 0,
        lastBidAt: 0,
        isCanceled: false,
        stepTime: 0,
        lastQueryId: 0,
        jettonWallet: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMaster: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        isBrokenState: false,
        publicKey: 0,
    };
}
