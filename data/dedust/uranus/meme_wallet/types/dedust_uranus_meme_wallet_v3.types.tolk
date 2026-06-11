/// DeDust Uranus Meme Wallet v3 interface for Jetton and curve-sell messages.
contract DedustUranusMemeWalletV3 {
    author: "DeDust"
    version: "3.0"
    description: "Curated ABI for Uranus Meme Wallet v3 Jetton wallet operations and sell-token routing."
    storage: DedustUranusMemeWalletV3Storage
    incomingMessages: DedustUranusMemeWalletV3IncomingMessage
    outgoingMessages: DedustUranusMemeWalletV3OutgoingMessage
    thrownErrors: DedustUranusErrors
}

/// Affiliate partner configuration used by sell-token routing.
struct DedustUranusPartnerConfig {
    /// Partner identifier.
    partnerId: uint256
    /// Partner fee share in basis points.
    partnerFeeBps: uint16
}

/// Affiliate referrer configuration used by sell-token routing.
struct DedustUranusReferrerConfig {
    /// Referrer identifier.
    referrerId: uint256
    /// Referrer fee share in basis points.
    referrerFeeBps: uint16
}

/// Runtime wallet state stored in the root data cell.
struct DedustUranusMemeWalletV3Storage {
    /// Token balance held by this wallet.
    balance: coins
    /// Wallet owner address.
    ownerAddress: address
    /// Meme minter/master address.
    memeAddress: address
}

/// Owner-originated TEP-74 transfer request.
struct (0x0f8a7ea5) DedustUranusJettonTransfer {
    /// Caller-selected query id.
    queryId: uint64
    /// Token amount to transfer.
    amount: coins
    /// Destination owner address.
    destination: address
    /// Optional response address for excess TON.
    responseDestination: address?
    /// Optional custom payload.
    customPayload: cell?
    /// TON amount forwarded to the destination owner.
    forwardTonAmount: coins
    /// Raw TEP-74 forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet or minter-to-wallet TEP-74 internal transfer.
struct (0x178d4519) DedustUranusJettonInternalTransfer {
    /// Query id copied from the source transfer or mint.
    queryId: uint64
    /// Token amount credited to this wallet.
    amount: coins
    /// Source owner address.
    from: address
    /// Optional response address for excess TON.
    responseAddress: address?
    /// TON amount forwarded to the owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated burn request.
struct (0x595f07bc) DedustUranusJettonBurn {
    /// Caller-selected query id.
    queryId: uint64
    /// Token amount to burn.
    amount: coins
    /// Optional response address for excess TON.
    responseDestination: address?
    /// Optional custom payload.
    customPayload: cell?
}

/// Owner-originated sell request routed from wallet to Meme.
struct (0xb7459e2c) DedustUranusSellTokensMessage {
    /// Caller-selected query id.
    queryId: uint64
    /// Token amount to sell.
    amount: coins
    /// Minimum acceptable TON output.
    minimalAmountOut: coins
    /// Optional excess receiver.
    excessesTo: address?
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusPartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusReferrerConfig>?
}

/// Wallet-to-Meme sell request emitted after owner sell authorization.
struct (0x646ad424) DedustUranusSellMessage {
    /// Query id copied from the wallet sell request.
    queryId: uint64
    /// Token amount sold into the curve.
    amount: coins
    /// Minimum acceptable TON output.
    minimalAmountOut: coins
    /// Owner address that initiated the sell.
    from: address
    /// Optional excess receiver.
    excessesTo: address?
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusPartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusReferrerConfig>?
}

/// Burn notification emitted to the Meme minter.
struct (0x7bdd97de) DedustUranusBurnNotification {
    /// Query id copied from the burn request.
    queryId: uint64
    /// Burned token amount.
    amount: coins
    /// Wallet owner address.
    sender: address
    /// Optional response address for excess TON.
    responseDestination: address?
}

/// Owner notification emitted when an incoming transfer forwards TON.
struct (0x7362d09c) DedustUranusTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received token amount.
    amount: coins
    /// Source owner address.
    sender: address
    /// Raw TEP-74 forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response.
struct (0xd53276db) DedustUranusExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Structured result returned by `get_wallet_data`.
struct DedustUranusMemeWalletDataReply {
    /// Token balance.
    balance: int
    /// Wallet owner address.
    ownerAddress: address
    /// Meme minter/master address.
    memeAddress: address
    /// Referenced wallet code.
    walletCode: cell
}

/// Internal message bodies accepted by Uranus Meme Wallet v3.
type DedustUranusMemeWalletV3IncomingMessage =
    | DedustUranusJettonTransfer
    | DedustUranusJettonInternalTransfer
    | DedustUranusJettonBurn
    | DedustUranusSellTokensMessage

/// Internal message bodies emitted by Uranus Meme Wallet v3.
type DedustUranusMemeWalletV3OutgoingMessage =
    | DedustUranusJettonInternalTransfer
    | DedustUranusBurnNotification
    | DedustUranusTransferNotification
    | DedustUranusSellMessage
    | DedustUranusExcesses

/// Uranus exit-code catalog shared by Factory, Meme, and Meme Wallet.
enum DedustUranusErrors {
    /// Bonding curve parameters are malformed.
    BondingCurveParametersMalformed = 20,
    /// Output amount is below the supplied slippage limit.
    SlippageExceeded = 21,
    /// Selected meme preset does not exist.
    PresetNotExist = 22,
    /// Attached TON value is not enough for the requested operation.
    MessageValueTooLow = 23,
    /// Meme state was already initialized.
    AlreadyInitialized = 24,
    /// Sender is not authorized for the operation.
    SenderUnauthorized = 25,
    /// Initial buy exceeds the configured limit.
    InitialBuyLimitExceeded = 26,
    /// Requested amount exceeds the available balance.
    BalanceExceeded = 27,
    /// Meme state has not been initialized yet.
    NotInitialized = 28,
    /// Meme already graduated and no longer accepts curve trading.
    AlreadyGraduated = 29,
    /// Cross-workchain transfer is rejected.
    CrossWorkchainTransfer = 30,
    /// Supplied address is incorrect for the operation.
    IncorrectAddress = 31,
    /// Selected fee preset does not exist.
    FeePresetNotExist = 34,
    /// Selected total-supply preset does not exist.
    TotalSupplyPresetNotExist = 35,
    /// Fundraising target is outside the accepted range.
    RaisingFundsOutOfRange = 36,
    /// Partner fee is outside the accepted range.
    PartnerFeeOutOfRange = 37,
    /// On-sell supply percentage is outside the accepted range.
    OnSellSupplyPercentOutOfRange = 38,
    /// Migrated CPMM pool partner fee is outside the accepted range.
    PoolPartnerFeeOutOfRange = 39,
    /// Invalid low-level tag in a bounced wallet flow.
    InvalidTag = 63,
    /// Incoming message body tag is unknown.
    UnknownOperation = 65535,
}

/// Return Jetton wallet data for this Meme owner wallet.
get fun get_wallet_data(): DedustUranusMemeWalletDataReply {
    throw 0;
}
