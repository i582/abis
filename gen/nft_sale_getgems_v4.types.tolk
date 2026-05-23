// Generated from XML ABI schemas.
// Source schema: schemas/nft_sale.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 6b95a6418b9c9d2359045d1e7559b8d549ae0e506f24caab58fa30c8fb1feb86

contract NftSaleGetgemsV4 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/nft_sale.xml"
}

struct GetFixPriceDataV4Reply {
    isComplete: bool
    createdAt: uint32
    marketplaceAddress: address
    nftAddress: address
    nftOwnerAddress: address?
    fullPrice: int
    feeAddress: address
    feePercent: uint32
    royaltyAddress: address
    royaltyPercent: uint32
    soldAt: uint32
    soldQueryId: uint64
    jettonPriceDict: cell?
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
    ThisSaleIsBrokenRoyaltyFeeOrProfitIsLessThanZero = 451
    NotEnoughTonsForCancellation = 457
    UnauthorizedCancellation = 458
    ThisSaleIsOnlyForAJetton = 459
    NotEnoughFundsForSale = 4501
    UnknownOperation = 65535
}

get fun get_fix_price_data_v4(): GetFixPriceDataV4Reply {
    return {
        isComplete: false,
        createdAt: 0,
        marketplaceAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftOwnerAddress: null,
        fullPrice: 0,
        feeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        feePercent: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        royaltyPercent: 0,
        soldAt: 0,
        soldQueryId: 0,
        jettonPriceDict: null,
    };
}
