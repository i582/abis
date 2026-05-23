// Generated from XML ABI schemas.
// Source schema: schemas/subscriptions_v2.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 48942963827c5147fe935cd22e88ba418011fe656eab78b79c5c6343d84d421a

contract SubscriptionV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/subscriptions_v2.xml"
    incomingMessages: SubscriptionV2IncomingMessage
}

// TL-B message bodies.
struct (0x508238ec) SubscriptionReducePayment {
    queryId: uint64
    newPayment: coins
}

struct (0xf71783cb) SubscriptionDeploy {
    queryId: uint64
    firstChargingDate: uint32
    paymentPerPeriod: coins
    period: uint32
    gracePeriod: uint32
    callerFee: coins
    withdrawAddress: address
    withdrawMsgBody: cell
    metadata: cell
}

// Message unions used by Acton ABI.
type SubscriptionV2IncomingMessage =
    | SubscriptionReducePayment
    | SubscriptionDeploy

struct GetSubscriptionInfoReply {
    wallet: address
    walletVersion: uint8
    admin: address
    subscriptionId: uint64
    withdrawAddress: address
    withdrawMsgBody: cell
    metadata: cell
}

struct GetPaymentInfoReply {
    contractState: uint8
    paymentPerPeriod: coins
    period: uint32
    chargeDate: uint32
    gracePeriod: uint32
    lastRequestTime: uint32
    callerFee: coins
}

enum Errors {
    NotEnoughFunds = 460
    TooEarlyRequest = 461
    TooManyRequests = 462
    SenderIsNotWallet = 463
    NotInitialized = 464
    Initialized = 465
    SenderIsNotOwner = 466
    SenderIsNotBeneficiary = 467
    InvalidChargingDate = 468
    InvalidReducePaymentAmount = 469
    SubscriptionIsNotActivated = 470
    WalletAddressIsWithdrawAddress = 471
}

get fun get_subscription_info(): GetSubscriptionInfoReply {
    return {
        wallet: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        walletVersion: 0,
        admin: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        subscriptionId: 0,
        withdrawAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        withdrawMsgBody: createEmptyCell(),
        metadata: createEmptyCell(),
    };
}

get fun get_payment_info(): GetPaymentInfoReply {
    return {
        contractState: 0,
        paymentPerPeriod: 0,
        period: 0,
        chargeDate: 0,
        gracePeriod: 0,
        lastRequestTime: 0,
        callerFee: 0,
    };
}
