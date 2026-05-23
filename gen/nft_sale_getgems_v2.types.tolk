// Generated from XML ABI schemas.
// Source schema: schemas/nft_sale.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 8278f4c5233de6fbedc969af519344a7a9bffc544856dba986a95c0bcf8571c9

contract NftSaleGetgemsV2 {
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
