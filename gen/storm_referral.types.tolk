// Generated from XML ABI schemas.
// Source schema: schemas/storm.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StormReferral {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storm.xml"
    incomingMessages: StormReferralIncomingMessage
    outgoingMessages: StormReferralOutgoingMessage
}

// TL-B helper types referenced by messages.
struct Parameters {
    discount: uint32
    rebate: uint32
}

// TL-B message bodies.
struct (0xcb4ddc3c) StormMintReferral {
    nftOwner: address
    refType: uint2
    redirectAddress: address
    parameters: Cell<Parameters>
    balancesDict: cell
}

struct (0x84dced7a) StormAddReferralAmount {
    referralAmount: coins
    originAddr: address
}

struct (0xf5d4eb52) StormWithdrawReferralAmount {
    index: uint64
    referralAmount: coins
    ownerAddr: address
}

// Message unions used by Acton ABI.
type StormReferralIncomingMessage =
    | StormMintReferral
    | StormAddReferralAmount

type StormReferralOutgoingMessage = StormWithdrawReferralAmount

struct GetReferralDataReply {
    referralType: int32
    discount: uint32
    rebate: uint32
    balancesDict: cell
}

enum Errors {
    NotAnOwner = 301
    WrongVaultWc = 303
    CanNotTransferKol = 307
    NegativeResponseValue = 308
    NotACollection = 309
    MinAddAmountValue = 311
    MinProvideFeesValue = 312
    VaultWasNotAdded = 313
    MinTonForClaim = 314
    VaultNotFound = 315
    UnauthorizedBatchRequest = 316
    WrongOperation = 65535
}

get fun get_referral_data(): GetReferralDataReply {
    return {
        referralType: 0,
        discount: 0,
        rebate: 0,
        balancesDict: createEmptyCell(),
    };
}
