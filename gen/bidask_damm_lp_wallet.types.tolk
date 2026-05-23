// Generated from XML ABI schemas.
// Source schema: schemas/bidask.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract BidaskDammLpWallet {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bidask.xml"
    incomingMessages: BidaskDammLpWalletIncomingMessage
    outgoingMessages: BidaskDammLpWalletOutgoingMessage
}

struct BidaskDammInternalBurnFees {
    feesPerLpXLast: uint220
    feesPerLpYLast: uint220
    claimedX: uint220
    claimedY: uint220
}

struct BidaskDammInternalClaimFees {
    feesPerLpXLast: uint220
    feesPerLpYLast: uint220
    claimedX: uint220
    claimedY: uint220
}

// TL-B message bodies.
struct (0x71e4a09a) BidaskDammBurn {
    queryId: uint64
    burnAmount: coins
    isAccount: bool
    receiver: address
    additionalData: cell?
    forwardPayload: cell?
}

struct (0x26fa12a4) BidaskDammClaimFees {
    queryId: uint64
    isAccount: bool
    receiver: address
    forwardPayload: cell?
}

struct (0xadb8eb49) BidaskDammInternalBurn {
    queryId: uint64
    burner: address
    burnAmount: coins
    isAccount: bool
    receiver: address
    fees: Cell<BidaskDammInternalBurnFees>
    additionalData: cell?
    forwardPayload: cell?
}

struct (0x983b6933) BidaskDammInternalClaim {
    queryId: uint64
    owner: address
    isAccount: bool
    receiver: address
    walletBalance: coins
    fees: Cell<BidaskDammInternalClaimFees>
    forwardPayload: cell?
}

// Message unions used by Acton ABI.
type BidaskDammLpWalletIncomingMessage =
    | BidaskDammBurn
    | BidaskDammClaimFees

type BidaskDammLpWalletOutgoingMessage =
    | BidaskDammInternalBurn
    | BidaskDammInternalClaim

struct GetUserFeesInfoReply {
    feesPerLpXLast: int
    feesPerLpYLast: int
    claimedX: int
    claimedY: int
}

get fun get_user_fees_info(): GetUserFeesInfoReply {
    return {
        feesPerLpXLast: 0,
        feesPerLpYLast: 0,
        claimedX: 0,
        claimedY: 0,
    };
}
