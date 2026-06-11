/// DeDust Uranus Meme v3 jetton minter with bonding-curve trading.
contract DedustUranusMemeV3 {
    author: "DeDust"
    version: "3.0"
    description: "Curated ABI for Uranus Meme v3 trading, Jetton minter getters, events, and fee-claim messages."
    storage: DedustUranusMemeV3Storage
    incomingMessages: DedustUranusMemeV3IncomingMessage
    outgoingMessages: DedustUranusMemeV3OutgoingMessage
    thrownErrors: DedustUranusErrors
}

/// Metadata URI wrapper used by Uranus meme config and deploy messages.
struct DedustUranusMemeMetadata {
    /// Token metadata URI encoded as a Tolk string.
    uri: string
}

/// Affiliate partner configuration.
struct DedustUranusPartnerConfig {
    /// Partner identifier.
    partnerId: uint256
    /// Partner fee share in basis points.
    partnerFeeBps: uint16
}

/// Affiliate referrer configuration.
struct DedustUranusReferrerConfig {
    /// Referrer identifier.
    referrerId: uint256
    /// Referrer fee share in basis points.
    referrerFeeBps: uint16
}

/// Referenced immutable meme configuration.
struct DedustUranusMemeConfig {
    /// Meme creator address.
    creatorAddress: address
    /// Uranus controller address.
    controllerAddress: address
    /// Referenced token metadata URI.
    metadata: DedustUranusMemeMetadata
    /// Graduation fundraising target.
    raisingFunds: coins
    /// Token amount reserved for post-graduation liquidity.
    liquidityTokens: coins
    /// Deterministic seed used for child addresses and token identity.
    seed: uint128
}

/// Bonding-curve state stored in the root Meme data cell.
struct DedustUranusBondingCurve {
    /// Whether the token has reached graduation.
    graduated: bool
    /// Bonding-curve alpha parameter.
    alpha: coins
    /// Bonding-curve beta parameter.
    beta: coins
    /// Supply amount allocated for curve sells.
    onSellSupply: coins
    /// TON raised so far.
    raisedFunds: coins
    /// Current circulating supply.
    currentSupply: coins
}

/// Runtime Meme v3 root storage.
struct DedustUranusMemeV3Storage {
    /// Whether the Meme has been initialized by the Factory.
    initialized: bool
    /// Whether liquidity has migrated to CPMM.
    migrated: bool
    /// Referenced immutable config cell.
    config: Cell<DedustUranusMemeConfig>
    /// Bonding-curve base trading fee in basis points.
    baseFeeBps: uint16
    /// Current bonding-curve state.
    curve: DedustUranusBondingCurve
    /// Maximum token supply.
    totalSupply: coins
    /// Accumulated creator fee.
    creatorFee: coins
    /// v3 fee, partner, and migration extension fields after the documented v2 prefix.
    v3Tail: RemainingBitsAndRefs
}

/// Fee breakdown emitted by bonding-curve trade events.
struct DedustUranusTradeFees {
    /// Creator fee charged on the trade.
    creatorFee: coins
    /// Protocol fee charged on the trade.
    protocolFee: coins
    /// Partner fee charged on the trade.
    partnerFee: coins
    /// Referrer fee charged on the trade.
    referrerFee: coins
}

/// Factory-to-Meme initialization body.
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

/// User buy request accepted by the Meme contract.
struct (0x94826557) DedustUranusBuyMessage {
    /// Caller-selected tracing id.
    queryId: uint64
    /// TON input amount accounted by the bonding curve.
    amount: coins
    /// Minimum acceptable token output.
    minimalAmountOut: coins
    /// Address receiving excess TON and callbacks.
    excessesTo: address
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusPartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusReferrerConfig>?
}

/// Wallet-to-Meme sell request emitted by Uranus Meme Wallet.
struct (0x646ad424) DedustUranusSellMessage {
    /// Query id copied from the wallet sell request.
    queryId: uint64
    /// Token amount sold into the curve.
    amount: coins
    /// Minimum acceptable TON output.
    minimalAmountOut: coins
    /// Owner address that initiated the sell.
    from: address
    /// Optional address receiving excess TON and callbacks.
    excessesTo: address?
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusPartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusReferrerConfig>?
}

/// Standard Jetton burn notification accepted from deterministic Meme wallets.
struct (0x7bdd97de) DedustUranusBurnNotification {
    /// Query id copied from the wallet burn request.
    queryId: uint64
    /// Burned token amount.
    amount: coins
    /// Owner address whose wallet burned tokens.
    sender: address
    /// Optional excess receiver.
    responseDestination: address?
}

/// TEP-89 wallet discovery request accepted by the Meme minter.
struct (0x2c76b973) DedustUranusProvideWalletAddress {
    /// Caller-selected query id.
    queryId: uint64
    /// Owner address whose deterministic wallet is requested.
    ownerAddress: address?
    /// Whether the response should include the owner address.
    includeAddress: bool
}

/// Claim accumulated creator fees.
struct (0xad7269a8) DedustUranusClaimCreatorFee {
    /// Caller-selected query id.
    queryId: uint64
    /// Optional payout address.
    to: address?
    /// Optional excess receiver.
    excessesTo: address?
}

/// Claim accumulated partner fees.
struct (0x7f4bcbf4) DedustUranusClaimPartnerFee {
    /// Caller-selected query id.
    queryId: uint64
    /// Optional payout address.
    to: address?
    /// Optional excess receiver.
    excessesTo: address?
}

/// Unnamed v3 fee-claim request with one optional payout address.
struct (0xf14b54f3) DedustUranusOpcodeF14b54f3 {
    /// Caller-selected query id.
    queryId: uint64
    /// Optional payout or excess receiver address.
    to: address?
}

/// Standard excess-value response.
struct (0xd53276db) DedustUranusExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// CPMM initialization result callback consumed after migration.
struct (0xce185bd7) DedustUranusCpmmInitResult {
    /// Query id copied from the migration request.
    queryId: uint64
    /// Signed exit code returned by the initialized pool.
    exitCode: int32
    /// Optional callback payload tail.
    payload: cell?
}

/// External-out event emitted after a successful buy.
@overflow1023_policy("suppress")
struct (0xa0aa6bc2) DedustUranusBuyEvent {
    /// Trader address.
    traderAddress: address
    /// TON input amount.
    amountIn: coins
    /// Token output amount.
    amountOut: coins
    /// Trade fee breakdown.
    fees: DedustUranusTradeFees
    /// Current circulating supply after the buy.
    currentSupply: coins
    /// Raised TON after the buy.
    raisedFunds: coins
    /// Whether the buy caused or observed graduation.
    isGraduated: bool
}

/// External-out event emitted after a successful sell.
@overflow1023_policy("suppress")
struct (0x3ab0fccc) DedustUranusSellEvent {
    /// Trader address.
    traderAddress: address
    /// Token input amount.
    amountIn: coins
    /// TON output amount.
    amountOut: coins
    /// Trade fee breakdown.
    fees: DedustUranusTradeFees
    /// Current circulating supply after the sell.
    currentSupply: coins
    /// Raised TON after the sell.
    raisedFunds: coins
}

/// Compact successful-buy callback emitted to the excess receiver.
struct (0x66c8ad72) DedustUranusOpcode66c8ad72 {
    /// Query id copied from the buy request.
    queryId: uint64
}

/// TEP-89 wallet discovery response emitted by the Meme minter.
struct (0xd1735400) DedustUranusTakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when unresolved.
    walletAddress: address?
    /// Optional referenced owner address.
    ownerAddress: Cell<address>?
}

/// Structured result returned by `get_meme_data`.
struct DedustUranusGetMemeDataReply {
    /// Whether the Meme has been initialized.
    initialized: bool
    /// Whether liquidity has migrated to CPMM.
    migrated: bool
    /// Controller address.
    controllerAddress: address
    /// Creator address.
    creatorAddress: address
    /// Accumulated creator fee.
    creatorFee: int
    /// Deterministic seed.
    seed: uint128
    /// Whether the Meme is graduated.
    isGraduated: bool
    /// Bonding-curve alpha parameter.
    alpha: int
    /// Bonding-curve beta parameter.
    beta: int
    /// Supply amount allocated for curve sells.
    onSellSupply: int
    /// Trading fee in basis points.
    tradeFeeBps: uint16
    /// TON raised so far.
    raisedFunds: int
    /// Current circulating supply.
    currentSupply: int
}

/// Structured result returned by `get_bonding_curve_data`.
struct DedustUranusGetBondingCurveDataReply {
    /// Whether the Meme is graduated.
    isGraduated: bool
    /// Maximum token supply.
    maxSupply: int
    /// Current circulating supply.
    currentSupply: int
    /// Token amount allocated for bonding-curve trading.
    bondingCurveSupply: int
    /// Token amount reserved for liquidity migration.
    liquiditySupply: int
    /// Graduation fundraising target.
    raisingFunds: int
    /// TON migration fee.
    migrationFee: int
    /// TON raised so far.
    raisedFunds: int
    /// Bonding-curve alpha parameter.
    alpha: int
    /// Bonding-curve beta parameter.
    beta: int
}

/// Structured result returned by `get_partner_data`.
struct DedustUranusGetPartnerDataReply {
    /// Accumulated partner fee.
    partnerFee: int
    /// Partner share in basis points.
    partnerFeeBps: uint16
    /// Partner payout address.
    partnerAddress: address
    /// Migrated CPMM pool partner share in basis points.
    poolPartnerFeeBps: uint16
}

/// Structured result returned by Jetton minter `get_jetton_data`.
struct DedustUranusJettonDataReply {
    /// Total issued token supply.
    totalSupply: int
    /// Uranus Meme tokens are mintable by protocol logic.
    mintable: bool
    /// Admin stack address; live Uranus Meme returns `addr_none`.
    adminAddress: any_address
    /// Token metadata content cell.
    jettonContent: cell
    /// Meme wallet code cell.
    jettonWalletCode: cell
}

/// Internal message bodies accepted by Uranus Meme v3.
type DedustUranusMemeV3IncomingMessage =
    | DedustUranusInitMeme
    | DedustUranusBuyMessage
    | DedustUranusSellMessage
    | DedustUranusBurnNotification
    | DedustUranusProvideWalletAddress
    | DedustUranusClaimCreatorFee
    | DedustUranusClaimPartnerFee
    | DedustUranusOpcodeF14b54f3
    | DedustUranusExcesses
    | DedustUranusCpmmInitResult

/// Internal and external-out message bodies emitted by Uranus Meme v3.
type DedustUranusMemeV3OutgoingMessage =
    | DedustUranusBuyEvent
    | DedustUranusSellEvent
    | DedustUranusOpcode66c8ad72
    | DedustUranusExcesses
    | DedustUranusTakeWalletAddress

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

/// Return the current Meme bonding-curve and fee state.
get fun get_meme_data(): DedustUranusGetMemeDataReply {
    throw 0;
}

/// Return the bonding-curve economics and progress.
get fun get_bonding_curve_data(): DedustUranusGetBondingCurveDataReply {
    throw 0;
}

/// Return partner-fee accounting data.
get fun get_partner_data(): DedustUranusGetPartnerDataReply {
    throw 0;
}

/// Return the deterministic Meme Wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return Jetton minter data for the Meme token.
get fun get_jetton_data(): DedustUranusJettonDataReply {
    throw 0;
}
