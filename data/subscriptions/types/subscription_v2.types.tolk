/// Tonkeeper native subscription extension interface with runtime storage, payments, cron trigger, wallet requests, and getters.
contract SubscriptionV2 {
    author: "Tonkeeper"
    version: "2.0"
    description: "Tonkeeper native subscription extension ABI"
    storage: SubscriptionV2Storage
    storageAtDeployment: SubscriptionV2DeploymentStorage
    incomingMessages: SubscriptionV2IncomingMessage
    incomingExternal: SubscriptionV2IncomingExternalMessage
    outgoingMessages: SubscriptionV2OutgoingMessage
    thrownErrors: SubscriptionV2Errors
}

/// Precompiled wallet request cached in subscription storage.
struct SubscriptionV2Precompiled {
    /// Nanotons required for the cached wallet request.
    forwardAmount: coins
    /// Raw Wallet V5 action register cell.
    requestPaymentC5: cell
}

/// Withdrawal destination and body used when collected funds are forwarded.
struct SubscriptionV2WithdrawInfo {
    /// Destination that receives subscription payments.
    withdrawAddress: address
    /// Message body sent to the withdrawal destination.
    withdrawMsgBody: cell
}

/// Deployment withdrawal information before the subscription is activated.
struct SubscriptionV2DeploymentWithdrawInfo {
    /// Optional withdrawal destination slot.
    withdrawAddress: address?
    /// Message body slot.
    withdrawMsgBody: cell
}

/// Active runtime data stored by the subscription extension.
struct SubscriptionV2Storage {
    /// Optional reward address for the caller that requested payment.
    rewardAddress: Cell<address>?
    /// Last external cron request Unix time.
    lastRequestTime: uint32
    /// Next charge Unix time.
    chargeDate: uint32
    /// Subscription state: not initialized, active, or cancelled.
    subscriptionState: uint2
    /// Cached wallet request payload.
    precompiled: Cell<SubscriptionV2Precompiled>
    /// Payment grace period in seconds.
    gracePeriod: uint32
    /// Caller reward in nanotons.
    callerFee: coins
    /// Wallet that owns the subscription extension.
    wallet: address
    /// Wallet protocol version.
    walletVersion: uint8
    /// Beneficiary allowed to reduce payments or cancel.
    beneficiary: address
    /// Project-local subscription identifier.
    subscriptionId: uint32
    /// Nanotons paid per period.
    paymentPerPeriod: coins
    /// Billing period in seconds.
    period: uint32
    /// Withdrawal settings for collected funds.
    withdrawInfo: Cell<SubscriptionV2WithdrawInfo>
    /// Encrypted or project-defined subscription metadata.
    metadata: cell
}

/// Initial data stored before the first deploy message activates the subscription.
struct SubscriptionV2DeploymentStorage {
    /// Optional reward address slot.
    rewardAddress: Cell<address>?
    /// Last external cron request Unix time.
    lastRequestTime: uint32
    /// Charge Unix time slot.
    chargeDate: uint32
    /// Subscription state.
    subscriptionState: uint2
    /// Cached wallet request payload slot.
    precompiled: Cell<SubscriptionV2Precompiled>
    /// Payment grace period slot.
    gracePeriod: uint32
    /// Caller reward slot.
    callerFee: coins
    /// Wallet that owns the subscription extension.
    wallet: address
    /// Wallet protocol version.
    walletVersion: uint8
    /// Beneficiary address.
    beneficiary: address
    /// Project-local subscription identifier.
    subscriptionId: uint32
    /// Payment amount slot.
    paymentPerPeriod: coins
    /// Billing period slot.
    period: uint32
    /// Withdrawal settings slot.
    withdrawInfo: Cell<SubscriptionV2DeploymentWithdrawInfo>
    /// Metadata slot.
    metadata: cell
}

/// Wallet payment confirmation body.
struct (0xf06c7567) SubscriptionV2PaymentConfirm {
    /// Request identifier forwarded by the wallet.
    queryId: uint64
}

/// Cancellation body accepted from the beneficiary or wallet.
struct (0x64737472) SubscriptionV2Destruct {
    /// Request identifier.
    queryId: int64
}

/// Beneficiary request that lowers the payment amount.
struct (0x508238ec) SubscriptionV2ReducePayment {
    /// Request identifier.
    queryId: int64
    /// New nanotons paid per period.
    newPaymentPerPeriod: coins
}

/// Wallet request that initializes and activates the subscription.
struct (0xf71783cb) SubscriptionV2Deploy {
    /// Request identifier.
    queryId: uint64
    /// First charge Unix time, or zero for immediate first payment.
    firstChargeDate: uint32
    /// Nanotons paid per period.
    paymentPerPeriod: coins
    /// Billing period in seconds.
    period: uint32
    /// Payment grace period in seconds.
    gracePeriod: uint32
    /// Caller reward in nanotons.
    callerFee: coins
    /// Destination that receives collected funds.
    withdrawAddress: address
    /// Message body sent with collected funds.
    withdrawMsgBody: cell
    /// Encrypted or project-defined subscription metadata.
    metadata: cell
}

/// External cron trigger body used to request payment.
struct (0x2114702d) SubscriptionV2CronTrigger {
    /// Reward destination for the trigger caller.
    rewardAddress: address
    /// Caller-selected anti-replay or randomization salt.
    salt: uint32
}

/// Internal message bodies accepted by the subscription extension.
type SubscriptionV2IncomingMessage =
    | SubscriptionV2PaymentConfirm
    | SubscriptionV2Destruct
    | SubscriptionV2ReducePayment
    | SubscriptionV2Deploy

/// External-in message bodies accepted by the subscription extension.
type SubscriptionV2IncomingExternalMessage = SubscriptionV2CronTrigger

/// Wallet V5 extension request emitted to the owner wallet.
struct (0x6578746e) SubscriptionV2WalletV5RequestByExtension {
    /// Query identifier emitted by the extension.
    queryId: uint64
    /// Optional linked Wallet V5 out-action list.
    outActions: Cell<SubscriptionV2WalletOutActionSendMessage>?
    /// Optional Wallet V5 extended action.
    extendedActions: SubscriptionV2WalletExtendedAction?
}

/// Wallet V5 send-message action cell.
struct (0x0ec3c86d) SubscriptionV2WalletOutActionSendMessage {
    /// Previous linked action cell.
    prevAction: cell
    /// Send mode for the nested message.
    mode: uint8
    /// Raw nested outbound message cell.
    msg: cell
}

/// Wallet V5 extension-deletion action.
struct (0x03) SubscriptionV2WalletDeleteExtension {
    /// Extension address to remove.
    extension: address
    /// Optional continuation action cell.
    nextAction: cell?
}

/// Wallet V5 extended actions emitted by this extension.
type SubscriptionV2WalletExtendedAction = SubscriptionV2WalletDeleteExtension

/// Wallet V4 request asking the plugin wallet for funds.
struct (0x706c7567) SubscriptionV2WalletV4FundsRequest {
    /// Query identifier emitted by the extension.
    queryId: uint64
    /// Nanotons requested from the wallet.
    amount: coins
    /// Extra-currency dictionary.
    extra: dict
}

/// Wallet V4 body asking the wallet to remove this plugin.
struct (0x64737472) SubscriptionV2WalletV4RemovePlugin {
    /// Query identifier emitted by the extension.
    queryId: uint64
}

/// Structured outgoing bodies emitted by the subscription extension.
type SubscriptionV2OutgoingMessage =
    | SubscriptionV2WalletV5RequestByExtension
    | SubscriptionV2WalletV4FundsRequest
    | SubscriptionV2WalletV4RemovePlugin

/// Getter return for subscription ownership and withdrawal metadata.
struct SubscriptionV2SubscriptionInfoReply {
    /// Wallet that owns the extension.
    wallet: address
    /// Wallet protocol version.
    walletVersion: uint8
    /// Beneficiary address.
    beneficiary: address
    /// Project-local subscription identifier.
    subscriptionId: uint32
    /// Destination that receives collected funds.
    withdrawAddress: address
    /// Message body sent with collected funds.
    withdrawMsgBody: cell
    /// Encrypted or project-defined subscription metadata.
    metadata: cell
}

/// Getter return for billing state.
struct SubscriptionV2PaymentInfoReply {
    /// Subscription state: not initialized, active, or cancelled.
    subscriptionState: uint2
    /// Nanotons paid per period.
    paymentPerPeriod: coins
    /// Billing period in seconds.
    period: uint32
    /// Next charge Unix time.
    chargeDate: uint32
    /// Payment grace period in seconds.
    gracePeriod: uint32
    /// Last external cron request Unix time.
    lastRequestTime: uint32
    /// Caller reward in nanotons.
    callerFee: coins
}

/// Getter return for cron scheduling metadata.
struct SubscriptionV2CronInfoReply {
    /// Next planned cron call Unix time.
    nextCallTime: uint32
    /// Reward paid to the trigger caller in nanotons.
    reward: coins
    /// Contract balance minus reserved amounts.
    balanceMinusAmounts: int
    /// Repeat interval in seconds.
    repeatEvery: uint32
}

/// Source-level exit-code catalog.
enum SubscriptionV2Errors {
    /// Attached value is below the required payment or storage budget.
    NotEnoughFunds = 460
    /// External cron request arrived before the charge date.
    TooEarlyRequest = 461
    /// External cron request arrived before the retry interval elapsed.
    TooManyRequests = 462
    /// Internal sender is not the owner wallet.
    SenderIsNotWallet = 463
    /// Subscription storage is not initialized.
    NotInitialized = 464
    /// Deploy was attempted after initialization.
    Initialized = 465
    /// Internal sender is not the beneficiary.
    SenderIsNotBeneficiary = 467
    /// First charge date is not valid.
    InvalidChargingDate = 468
    /// Reduced payment is not lower than the current payment.
    InvalidReducePaymentAmount = 469
    /// Subscription is not active.
    SubscriptionIsNotActivated = 470
    /// Withdrawal address equals the owner wallet address.
    WalletAddressIsWithdrawAddress = 471
    /// Deployment or payment parameters are not valid.
    WrongInitializationParams = 472
    /// Payment confirmation arrived before the charge date.
    TooEarlyPayment = 473
    /// The body opcode is not accepted by this entrypoint.
    UnsupportedOperation = 65535
}

/// Return subscription ownership and withdrawal metadata.
get fun get_subscription_info(): SubscriptionV2SubscriptionInfoReply {
    throw 0;
}

/// Return billing state.
get fun get_payment_info(): SubscriptionV2PaymentInfoReply {
    throw 0;
}

/// Return nanotons reserved for storage and caller reward.
get fun get_reserved_amount(): coins {
    throw 0;
}

/// Return whether the subscription is currently active.
get fun get_is_subscription_active(): bool {
    throw 0;
}

/// Return cron scheduling metadata.
get fun get_cron_info(): SubscriptionV2CronInfoReply {
    throw 0;
}
