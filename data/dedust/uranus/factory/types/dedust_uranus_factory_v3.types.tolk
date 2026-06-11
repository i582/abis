/// DeDust Uranus Meme Factory v3 interface for meme deployment messages.
contract DedustUranusFactoryV3 {
    author: "DeDust"
    version: "3.0"
    description: "Curated ABI for the deployed Uranus Meme Factory v3 contract."
    storage: DedustUranusFactoryV3Storage
    incomingMessages: DedustUranusFactoryV3IncomingMessage
    outgoingMessages: DedustUranusFactoryV3OutgoingMessage
    thrownErrors: DedustUranusErrors
}

/// Root Factory state; the v3 dispatcher authenticates the controller address from this cell.
struct DedustUranusFactoryV3Storage {
    /// Controller or authority address used by the Factory during meme deployment.
    controllerAddress: address
}

/// Metadata URI wrapper used by factory deployment bodies.
struct DedustUranusMemeMetadata {
    /// Token metadata URI encoded as a Tolk string.
    uri: string
}

/// Affiliate partner configuration stored inline or in an optional ref depending on the parent message.
struct DedustUranusPartnerConfig {
    /// Partner identifier.
    partnerId: uint256
    /// Partner fee share in basis points.
    partnerFeeBps: uint16
}

/// Affiliate referrer configuration stored inline or in an optional ref depending on the parent message.
struct DedustUranusReferrerConfig {
    /// Referrer identifier.
    referrerId: uint256
    /// Referrer fee share in basis points.
    referrerFeeBps: uint16
}

/// Deploy a new meme from a predefined Uranus preset.
struct (0x6ff416dc) DedustUranusDeployMeme {
    /// Caller-selected tracing id.
    queryId: uint64
    /// Uranus preset id.
    presetId: uint4
    /// Meme metadata URI.
    metadata: DedustUranusMemeMetadata
    /// Initial TON amount used for the creator buy.
    initialBuy: coins
    /// Optional inline partner attribution.
    partnerConfig: DedustUranusPartnerConfig?
    /// Optional inline referrer attribution.
    referrerConfig: DedustUranusReferrerConfig?
}

/// Deploy a customized v3 meme with explicit economics and migration settings.
struct (0x632f5d1c) DedustUranusDeployCustomizedMeme {
    /// Caller-selected tracing id.
    queryId: uint64
    /// Total-supply preset id.
    totalSupplyPresetId: uint4
    /// Base-fee preset id for bonding-curve trading.
    baseFeePresetId: uint4
    /// Graduation fundraising target.
    raisingFunds: coins
    /// Percentage of supply allocated for bonding-curve sales.
    onSellSupplyPercent: uint8
    /// Partner address eligible for bonding-curve and pool fees.
    partnerAddress: address
    /// Partner share of the bonding-curve base fee in basis points.
    partnerFeeBps: uint16
    /// Partner share of the migrated CPMM pool base fee in basis points.
    poolPartnerFeeBps: uint16
    /// CPMM pool base-fee preset id after migration.
    poolBaseFeePresetId: uint16
    /// Optional owner of migrated pool liquidity.
    poolLiquidityOwnerAddress: address?
    /// Metadata URI encoded as a Tolk string.
    metadataUri: string
    /// Initial TON amount used for the creator buy.
    initialBuy: coins
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusPartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusReferrerConfig>?
}

/// Factory-to-Meme initialization body emitted after deterministic child deployment.
struct (0x796f5a0c) DedustUranusInitMeme {
    /// Deployment query id copied from the Factory request.
    queryId: uint64
    /// Initial TON amount used for the creator buy.
    initialBuy: coins
    /// Optional inline partner attribution.
    partnerConfig: DedustUranusPartnerConfig?
    /// Optional inline referrer attribution.
    referrerConfig: DedustUranusReferrerConfig?
}

/// Internal message bodies accepted by Uranus Factory v3.
type DedustUranusFactoryV3IncomingMessage =
    | DedustUranusDeployMeme
    | DedustUranusDeployCustomizedMeme

/// Internal message bodies emitted by Uranus Factory v3.
type DedustUranusFactoryV3OutgoingMessage = DedustUranusInitMeme

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
    /// Incoming message body tag is unknown.
    UnknownOperation = 65535,
}
