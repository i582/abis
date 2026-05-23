// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormReferralCollection {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
}

struct GetDefaultReferralFeesReply {
    discount: uint32
    rebate: uint32
}

enum Errors {
    NotAnOwner = 301
    ProvideVaultsMinValue = 302
    WrongVaultWc = 303
    VaultAlreadyAdded = 304
    MinReferralMintValue = 305
    WrongRefType = 306
    WrongOperation = 65535
}

get fun get_default_referral_fees(): GetDefaultReferralFeesReply {
    return {
        discount: 0,
        rebate: 0,
    };
}

get fun get_referral_vaults_whitelist(): cell {
    return createEmptyCell();
}
