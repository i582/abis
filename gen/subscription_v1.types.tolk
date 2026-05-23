// Generated from XML ABI schemas.
// Source schema: schemas/subscriptions_v1.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract SubscriptionV1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/subscriptions_v1.xml"
    outgoingMessages: SubscriptionV1OutgoingMessage
}

// TL-B message bodies.
struct (0x756e6b77) SubscriptionFallback {}

// Message unions used by Acton ABI.
type SubscriptionV1OutgoingMessage = SubscriptionFallback

struct GetSubscriptionDataWallet {
    workchain: uint32
    address: uint256
}

struct GetSubscriptionDataBeneficiary {
    workchain: uint32
    address: uint256
}

struct GetSubscriptionDataReply {
    wallet: GetSubscriptionDataWallet
    beneficiary: GetSubscriptionDataBeneficiary
    amount: uint64
    period: uint64
    startTime: uint64
    timeout: uint64
    lastPaymentTime: uint64
    lastRequestTime: uint64
    failedAttempts: uint32
    subscriptionId: uint64
}

get fun get_subscription_data(): GetSubscriptionDataReply {
    return {
        wallet: {
        workchain: 0,
        address: 0,
    },
        beneficiary: {
        workchain: 0,
        address: 0,
    },
        amount: 0,
        period: 0,
        startTime: 0,
        timeout: 0,
        lastPaymentTime: 0,
        lastRequestTime: 0,
        failedAttempts: 0,
        subscriptionId: 0,
    };
}
