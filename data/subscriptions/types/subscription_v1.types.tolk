/// Tonkeeper Subscription V1 plugin interface with legacy payment, fallback, and destruct bodies.
contract SubscriptionV1 {
    author: "Tonkeeper"
    version: "1.0"
    description: "Curated interface for Tonkeeper Subscription V1 wallet plugin contracts"
    storage: SubscriptionV1Storage
    incomingMessages: SubscriptionV1IncomingMessage
    outgoingMessages: SubscriptionV1OutgoingMessage
}

/// Persistent Subscription V1 state stored in the root data cell.
struct SubscriptionV1Storage {
    /// Wallet address associated with the subscription.
    wallet: address
    /// Beneficiary address receiving fallback and remaining funds.
    beneficiary: address
    /// Subscription amount in nanotons.
    amount: coins
    /// Subscription period in seconds.
    period: uint32
    /// Initial subscription start timestamp.
    startTime: uint32
    /// Timeout window in seconds.
    timeout: uint32
    /// Last successful payment timestamp.
    lastPaymentTime: uint32
    /// Last payment request timestamp.
    lastRequestTime: uint32
    /// Number of failed payment attempts.
    failedAttempts: uint8
    /// Subscription identifier.
    subscriptionId: uint32
}

/// Structured result returned by `get_subscription_data`.
struct SubscriptionV1DataReply {
    /// Wallet address parts as `(workchain, address_hash)`.
    wallet: [int, uint256]
    /// Beneficiary address parts as `(workchain, address_hash)`.
    beneficiary: [int, uint256]
    /// Subscription amount in nanotons.
    amount: coins
    /// Subscription period in seconds.
    period: uint32
    /// Initial subscription start timestamp.
    startTime: uint32
    /// Timeout window in seconds.
    timeout: uint32
    /// Last successful payment timestamp.
    lastPaymentTime: uint32
    /// Last payment request timestamp.
    lastRequestTime: uint32
    /// Number of failed payment attempts.
    failedAttempts: uint8
    /// Subscription identifier.
    subscriptionId: uint32
}

/// Wallet-originated payment confirmation body.
struct (0xf06c7567) SubscriptionV1PaymentConfirmed {
    /// Wallet query identifier.
    queryId: uint64
}

/// Destruct request or forwarded wallet-plugin destruct body; tail may be empty or carry a wallet query id.
struct (0x64737472) SubscriptionV1WalletPluginDestruct {
    /// Opcode-compatible remaining destruct payload.
    tail: RemainingBitsAndRefs
}

/// Wallet payment request body emitted by the plugin.
struct (0x73756273) SubscriptionV1SubscriptionPayment {}

/// Fallback body emitted when a V1 message is unsupported or unauthorized.
struct (0x756e6b77) SubscriptionV1Fallback {}

/// Internal message bodies accepted by Subscription V1.
type SubscriptionV1IncomingMessage =
    | SubscriptionV1PaymentConfirmed
    | SubscriptionV1WalletPluginDestruct

/// Internal message bodies emitted by Subscription V1.
type SubscriptionV1OutgoingMessage =
    | SubscriptionV1SubscriptionPayment
    | SubscriptionV1Fallback
    | SubscriptionV1WalletPluginDestruct

/// Return legacy Subscription V1 storage data.
get fun get_subscription_data(): SubscriptionV1DataReply {
    throw 0;
}
