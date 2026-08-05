/// DeDust Uranus Meme V2 jetton minter with bonding-curve trading.
contract DedustUranusMemeV2 {
    author: "DeDust"
    version: "2.0"
    description: "DeDust Uranus Meme V2 is a launchpad meme-token market with the pre-V3 storage and getter surface."
    storage: DedustUranusMemeV2Storage
    incomingMessages: DedustUranusMemeV2IncomingMessage
    outgoingMessages: DedustUranusMemeV2OutgoingMessage
    thrownErrors: DedustUranusMemeV2Errors
}

/// Metadata URI referenced by the immutable Meme configuration.
struct DedustUranusMemeV2Metadata {
    /// Token metadata URI encoded as a Tolk string.
    uri: string
}

/// Affiliate partner configuration carried by initialization and trades.
struct DedustUranusMemeV2PartnerConfig {
    /// Partner identifier.
    partnerId: uint256
    /// Partner fee share in basis points.
    partnerFeeBps: uint16
}

/// Affiliate referrer configuration carried by initialization and trades.
struct DedustUranusMemeV2ReferrerConfig {
    /// Referrer identifier.
    referrerId: uint256
    /// Referrer fee share in basis points.
    referrerFeeBps: uint16
}

/// Referenced immutable configuration of one Uranus Meme V2 instance.
struct DedustUranusMemeV2Config {
    /// Meme creator address.
    creatorAddress: address
    /// Uranus controller address.
    controllerAddress: address
    /// Referenced token metadata URI.
    metadata: DedustUranusMemeV2Metadata
    /// Graduation fundraising target.
    raisingFunds: coins
    /// Token amount reserved for post-graduation liquidity.
    liquidityTokens: coins
    /// Deterministic seed used for child addresses and token identity.
    seed: uint128
}

/// Mutable bonding-curve state stored in the Meme V2 root cell.
struct DedustUranusMemeV2BondingCurve {
    /// Whether the token has reached graduation.
    graduated: bool
    /// Bonding-curve alpha parameter.
    alpha: coins
    /// Bonding-curve beta parameter.
    beta: coins
    /// Supply amount allocated for curve sells.
    onSellSupply: coins
    /// GRAM raised so far.
    raisedFunds: coins
    /// Current circulating supply.
    currentSupply: coins
}

/// Complete runtime storage of the Uranus Meme V2 revision.
struct DedustUranusMemeV2Storage {
    /// Whether the Meme has been initialized by the Factory.
    initialized: bool
    /// Whether liquidity has migrated to CPMM.
    migrated: bool
    /// Referenced immutable configuration cell.
    config: Cell<DedustUranusMemeV2Config>
    /// Bonding-curve base trading fee in basis points.
    baseFeeBps: uint16
    /// Current bonding-curve state.
    curve: DedustUranusMemeV2BondingCurve
    /// Maximum token supply.
    totalSupply: coins
    /// Accumulated creator fee.
    creatorFee: coins
}

/// Fee breakdown emitted by Uranus Meme V2 trade events.
struct DedustUranusMemeV2TradeFees {
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
struct (0x796f5a0c) DedustUranusMemeV2InitMeme {
    /// Deployment query id copied from the Factory request.
    queryId: uint64
    /// Initial GRAM amount used for the creator buy.
    initialBuy: coins
    /// Optional inline partner attribution.
    partnerConfig: DedustUranusMemeV2PartnerConfig?
    /// Optional inline referrer attribution.
    referrerConfig: DedustUranusMemeV2ReferrerConfig?
}

/// User buy request accepted by the Meme contract.
struct (0x94826557) DedustUranusMemeV2BuyMessage {
    /// Caller-selected tracing id.
    queryId: uint64
    /// GRAM input amount accounted by the bonding curve.
    amount: coins
    /// Minimum acceptable token output.
    minimalAmountOut: coins
    /// Address receiving excess GRAM and callbacks.
    excessesTo: address
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusMemeV2PartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusMemeV2ReferrerConfig>?
}

/// Wallet-to-Meme sell request emitted by Uranus Meme Wallet.
struct (0x646ad424) DedustUranusMemeV2SellMessage {
    /// Query id copied from the wallet sell request.
    queryId: uint64
    /// Token amount sold into the curve.
    amount: coins
    /// Minimum acceptable GRAM output.
    minimalAmountOut: coins
    /// Owner address that initiated the sell.
    from: address
    /// Optional address receiving excess GRAM and callbacks.
    excessesTo: address?
    /// Optional ref-backed partner attribution.
    partnerConfig: Cell<DedustUranusMemeV2PartnerConfig>?
    /// Optional ref-backed referrer attribution.
    referrerConfig: Cell<DedustUranusMemeV2ReferrerConfig>?
}

/// Standard Jetton burn notification accepted from deterministic Meme wallets.
struct (0x7bdd97de) DedustUranusMemeV2BurnNotification {
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
struct (0x2c76b973) DedustUranusMemeV2ProvideWalletAddress {
    /// Caller-selected query id.
    queryId: uint64
    /// Owner address whose deterministic wallet is requested.
    ownerAddress: address?
    /// Whether the response should include the owner address.
    includeAddress: bool
}

/// Claim accumulated creator fees.
struct (0xad7269a8) DedustUranusMemeV2ClaimCreatorFee {
    /// Caller-selected query id.
    queryId: uint64
    /// Optional payout address.
    to: address?
    /// Optional excess receiver.
    excessesTo: address?
}

/// Unnamed fee-claim request with one optional payout address.
struct (0xf14b54f3) DedustUranusMemeV2OpcodeF14b54f3 {
    /// Caller-selected query id.
    queryId: uint64
    /// Optional payout or excess receiver address.
    to: address?
}

/// Standard excess-value response accepted during callback handling.
struct (0xd53276db) DedustUranusMemeV2Excesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// CPMM initialization result callback consumed after migration.
struct (0xce185bd7) DedustUranusMemeV2CpmmInitResult {
    /// Query id copied from the migration request.
    queryId: uint64
    /// Signed exit code returned by the initialized pool.
    exitCode: int32
    /// Optional callback payload tail.
    payload: cell?
}

/// External-out event emitted after a successful buy.
@overflow1023_policy("suppress")
struct (0xa0aa6bc2) DedustUranusMemeV2BuyEvent {
    /// Trader address.
    traderAddress: address
    /// GRAM input amount.
    amountIn: coins
    /// Token output amount.
    amountOut: coins
    /// Trade fee breakdown.
    fees: DedustUranusMemeV2TradeFees
    /// Current circulating supply after the buy.
    currentSupply: coins
    /// Raised GRAM after the buy.
    raisedFunds: coins
    /// Whether the token is graduated after the buy.
    isGraduated: bool
}

/// External-out event emitted after a successful sell.
@overflow1023_policy("suppress")
struct (0x3ab0fccc) DedustUranusMemeV2SellEvent {
    /// Trader address.
    traderAddress: address
    /// Token input amount.
    amountIn: coins
    /// GRAM output amount.
    amountOut: coins
    /// Trade fee breakdown.
    fees: DedustUranusMemeV2TradeFees
    /// Current circulating supply after the sell.
    currentSupply: coins
    /// Raised GRAM after the sell.
    raisedFunds: coins
}

/// Compact successful-buy callback emitted to the excess receiver.
struct (0x66c8ad72) DedustUranusMemeV2Opcode66c8ad72 {
    /// Query id copied from the buy request.
    queryId: uint64
}

/// TEP-89 wallet discovery response emitted by the Meme minter.
struct (0xd1735400) DedustUranusMemeV2TakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when unresolved.
    walletAddress: address?
    /// Optional referenced owner address.
    ownerAddress: Cell<address>?
}

/// Structured result returned by `get_meme_data`.
struct DedustUranusMemeV2GetMemeDataReply {
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
    /// GRAM raised so far.
    raisedFunds: int
    /// Current circulating supply.
    currentSupply: int
}

/// Structured result returned by Jetton minter `get_jetton_data`.
struct DedustUranusMemeV2JettonDataReply {
    /// Total issued token supply.
    totalSupply: int
    /// Whether additional tokens can be minted.
    mintable: bool
    /// Admin stack address; Uranus Meme V2 returns `addr_none`.
    adminAddress: any_address
    /// Token metadata content cell.
    jettonContent: cell
    /// Meme V2 wallet code cell.
    jettonWalletCode: cell
}

/// Internal message bodies accepted by Uranus Meme V2.
type DedustUranusMemeV2IncomingMessage =
    | DedustUranusMemeV2InitMeme
    | DedustUranusMemeV2BuyMessage
    | DedustUranusMemeV2SellMessage
    | DedustUranusMemeV2BurnNotification
    | DedustUranusMemeV2ProvideWalletAddress
    | DedustUranusMemeV2ClaimCreatorFee
    | DedustUranusMemeV2OpcodeF14b54f3
    | DedustUranusMemeV2Excesses
    | DedustUranusMemeV2CpmmInitResult

/// Internal and external-out message bodies emitted by Uranus Meme V2.
type DedustUranusMemeV2OutgoingMessage =
    | DedustUranusMemeV2BuyEvent
    | DedustUranusMemeV2SellEvent
    | DedustUranusMemeV2Opcode66c8ad72
    | DedustUranusMemeV2Excesses
    | DedustUranusMemeV2TakeWalletAddress

/// Exit codes used by the Uranus Meme V2 implementation.
enum DedustUranusMemeV2Errors {
    /// Output amount is below the supplied slippage limit.
    SlippageExceeded = 21
    /// Attached GRAM value is not enough for the requested operation.
    MessageValueTooLow = 23
    /// Meme state was already initialized.
    AlreadyInitialized = 24
    /// Sender is not authorized for the operation.
    SenderUnauthorized = 25
    /// Meme state has not been initialized yet.
    NotInitialized = 28
    /// Meme already graduated and no longer accepts curve trading.
    AlreadyGraduated = 29
    /// Required migration-state data is absent or invalid.
    MigrationStateRequired = 32
    /// Incoming message body tag is unknown.
    UnknownOperation = 65535
}

/// Return the current Meme bonding-curve and fee state.
get fun get_meme_data(): DedustUranusMemeV2GetMemeDataReply {
    throw 0;
}

/// Return the deterministic Meme V2 Wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return Jetton minter data for the Meme token.
get fun get_jetton_data(): DedustUranusMemeV2JettonDataReply {
    throw 0;
}
