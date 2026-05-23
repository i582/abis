// Generated from XML ABI schemas.
// Source schema: schemas/nft_sale.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 24221fa571e542e055c77bedfdbf527c7af460cfdc7f344c450787b4cfa1eb4d
// Code hash: deb53b6c5765c1e6cd238bf47bc5e83ba596bdcc04b0b84cd50ab1e474a08f31
// Code hash: 32050dfac44f64866bcc86f2cd9e1305fe9dcadb3959c002237cfb0902d44323

contract NftSaleGetgemsV3 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/nft_sale.xml"
}

struct GetSaleDataReply {
    magic: uint64
    end: bool
    endTime: uint32
    marketplace: address
    nft: address
    owner: address
    lastBid: uint64
    lastMember: address
    minStep: uint64
    marketFeeAddress: address
    mpFeeFactor: uint32
    mpFeeBase: uint32
    royaltyAddress: address
    royaltyFeeFactor: uint32
    royaltyFeeBase: uint32
    maxBid: uint64
    minBid: uint64
    createdAt: uint32
    lastBidAt: uint32
    isCanceled: bool
}

enum Errors {
    AlreadySoldOrCancelled = 404
    Mode32NotAllowed = 405
    CanTExecuteCommandAtThisTime = 406
    InconsistentPriceAndFees = 408
    InconsistentPriceAndFees2 = 409
    InconsistentPriceAndFees3 = 410
    UnauthorizedInitiation = 500
    InvalidOpExpectedOwnershipAssigned = 501
    NotEnoughTonsForSale = 450
    NotEnoughTonsForCancellation = 457
    UnauthorizedCancellation = 458
    UnknownOperation = 65535
}

get fun get_sale_data(): GetSaleDataReply {
    return {
        magic: 0,
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
    };
}
