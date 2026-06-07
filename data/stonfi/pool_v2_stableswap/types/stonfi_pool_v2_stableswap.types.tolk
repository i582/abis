/// STON.fi DEX v2 StableSwap Pool interface: common Pool ABI plus the StableSwap `amp` PoolData tail.
contract StonfiPoolV2Stableswap {
    author: "STON.fi"
    version: "2.2"
    description: "Curated STON.fi DEX v2 StableSwap Pool interface for common Pool state, on-chain getter messages, LP-minter getters, and the stableswap amp parameter"
    storage: StonfiPoolV2StableswapStorage
    incomingMessages: StonfiPoolV2StableswapIncomingMessage
    outgoingMessages: StonfiPoolV2StableswapOutgoingMessage
    forceAbiExport: StonfiPoolV2StableswapRouterSetParams
    thrownErrors: StonfiPoolV2StableswapErrors
}

/// Runtime Pool data cell: common Pool storage followed by StableSwap `amp` and a static-data ref.
struct StonfiPoolV2StableswapStorage {
    /// Docs `is_locked`: true if transfer-notification operations are locked (`swap`, `provide_lp`).
    isLocked: bool
    /// Docs `reserve0`: amount of the first token in basic token units, encoded as TL-B `Coins`.
    reserve0: coins
    /// Docs `reserve1`: amount of the second token in basic token units, encoded as TL-B `Coins`.
    reserve1: coins
    /// Docs `total_supply`: total supply of LP tokens in basic token units.
    totalSupplyLp: coins
    /// Docs `collected_token0_protocol_fee`: collected protocol fees of the first token.
    collectedToken0ProtocolFee: coins
    /// Docs `collected_token1_protocol_fee`: collected protocol fees of the second token.
    collectedToken1ProtocolFee: coins
    /// Docs `protocol_fee_address`: address for receiving protocol fees; source permits `addr_none`.
    protocolFeeAddress: address?
    /// Docs `lp_fee`: liquidity-pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Docs `protocol_fee`: protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Docs StableSwap `PoolData` index 12: stableswap amplification parameter, stored as `uint32`.
    amp: uint32
    /// Referenced static Pool data with router, token wallet, and child-code cells.
    staticData: Cell<StonfiPoolV2StableswapStaticData>
}

/// Static Pool data stored in the referenced storage cell.
struct StonfiPoolV2StableswapStaticData {
    /// Docs `router_address`: address of the Router authorized for routed Pool operations.
    routerAddress: address
    /// Docs `token0_wallet_address`: address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Docs `token1_wallet_address`: address of the second Jetton token wallet.
    token1WalletAddress: address
    /// LP wallet code used for deterministic LP wallet deployment and minting.
    jettonLpWalletCode: cell
    /// LP account code used for deterministic user LP account deployment.
    lpAccountCode: cell
}

/// Referenced swap call payload inside a router-to-pool swap.
struct StonfiPoolV2StableswapSwapBody {
    /// Minimum token amount the caller accepts from the swap.
    minOut: coins
    /// Final receiver, or `addr_none` to default to the original user.
    receiver: address?
    /// Nanotons forwarded by the router with the outgoing token transfer.
    fwdGas: coins
    /// Optional custom payload forwarded on successful payout.
    customPayload: cell?
    /// Nanotons forwarded with the refund transfer on failure.
    refundFwdGas: coins
    /// Optional payload forwarded on refund.
    refundPayload: cell?
    /// Referral fee numerator over the STON.fi fee divider.
    refFee: uint16
    /// Referral owner address, or `addr_none` when referral fees are disabled.
    refAddress: address?
}

/// Router-provided swap metadata and referenced swap body.
struct StonfiPoolV2StableswapSwapDexPayload {
    /// Original transferred operation copied from the router payload.
    transferredOp: uint32
    /// Counterparty token wallet address selected by the router.
    tokenWallet1: address
    /// Address that receives a refund payout if swap validation fails.
    refundAddress: address
    /// Address that receives remaining excess value after router payouts.
    excessesAddress: address
    /// Unix timestamp after which the swap must refund.
    txDeadline: uint64
    /// Referenced swap-specific body parsed by the pool.
    swapBody: Cell<StonfiPoolV2StableswapSwapBody>
}

/// Referenced provide-liquidity call payload inside a router-to-pool request.
struct StonfiPoolV2StableswapProvideLpBody {
    /// Minimum LP tokens the caller accepts after provision.
    minLpOut: coins
    /// LP token receiver address.
    toAddress: address
    /// Whether both deposited sides were expected to be positive.
    bothPositive: bool
    /// Nanotons forwarded with the LP wallet mint notification.
    fwdAmount: coins
    /// Optional payload forwarded with the LP wallet mint notification.
    customPayload: cell?
}

/// Router-provided liquidity metadata and referenced provide-liquidity body.
struct StonfiPoolV2StableswapProvideLpDexPayload {
    /// Original transferred operation copied from the router payload.
    transferredOp: uint32
    /// Counterparty token wallet address selected by the router.
    tokenWallet1: address
    /// Address that receives refund payout if provision validation fails.
    refundAddress: address
    /// Address that receives remaining excess value after processing.
    excessesAddress: address
    /// Unix timestamp after which liquidity provision must refund.
    txDeadline: uint64
    /// Referenced provide-liquidity body parsed by the pool.
    provideLpBody: Cell<StonfiPoolV2StableswapProvideLpBody>
}

/// Extra addresses carried in pool-to-LP-account add-liquidity messages.
struct StonfiPoolV2StableswapAddLiquidityAdditionalFields {
    /// Address that receives token refunds from the LP account.
    refundAddress: address?
    /// Address that receives remaining excess value.
    excessAddress: address
}

/// Extra addresses carried in LP-account-to-pool liquidity callbacks.
struct StonfiPoolV2StableswapCbAddLiquidityAdditionalFields {
    /// LP token recipient for a successful mint.
    toUserAddress: address
    /// Address used when the pool must create a refund LP account.
    refundAddress: address?
    /// Address that receives remaining excess value.
    excessAddress: address
}

/// Additional payout details referenced by Pool `pay_to` messages sent to the Router.
struct StonfiPoolV2StableswapPayToAdditionalInfo {
    /// Nanotons forwarded with the final jetton transfer.
    fwdTonAmount: coins
    /// Token0 amount paid by the Router.
    amount0Out: coins
    /// Token0 wallet address for the payout.
    token0Address: address
    /// Token1 amount paid by the Router.
    amount1Out: coins
    /// Token1 wallet address for the payout.
    token1Address: address
}

/// Additional referral payout details referenced by Pool `pay_vault` messages.
struct StonfiPoolV2StableswapPayVaultAdditionalInfo {
    /// Token0 referral-fee amount paid through the Vault path.
    amount0Out: coins
    /// Token0 wallet address for the referral payout.
    token0Address: address
    /// Token1 referral-fee amount paid through the Vault path.
    amount1Out: coins
    /// Token1 wallet address for the referral payout.
    token1Address: address
}

/// Referenced `getter_pool_data` response details for common PoolData fields.
struct StonfiPoolV2StableswapGetterPoolDataDetails {
    /// Docs `lp_fee`: liquidity-pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Docs `protocol_fee`: protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Docs `router_address`: address of the Router.
    routerAddress: address
    /// Docs `protocol_fee_address`: address for receiving protocol fees; source permits `addr_none`.
    protocolFeeAddress: address?
    /// Docs `total_supply`: total amount of minted LP tokens.
    totalSupplyLp: coins
    /// Docs `collected_token0_protocol_fee`: collected protocol fees of the first token.
    collectedToken0ProtocolFee: coins
    /// Docs `collected_token1_protocol_fee`: collected protocol fees of the second token.
    collectedToken1ProtocolFee: coins
}

/// LP wallet burn notification accepted by the Pool to release liquidity.
struct (0x297437cf) StonfiPoolV2StableswapBurnNotificationExt {
    /// Query id copied from the original LP wallet burn request.
    queryId: uint64
    /// Amount of LP jettons burned by the LP wallet.
    jettonAmount: coins
    /// LP owner address whose deterministic wallet sent the notification.
    fromAddress: address
    /// Source requires this response address to be `addr_none`.
    responseAddress: address?
    /// Optional two-bit/ref payload split into token0 and token1 payout payloads.
    maybeCustomPayload: cell?
}

/// Router-to-Pool swap request.
struct (0x6664de2a) StonfiPoolV2StableswapSwap {
    /// Query id selected by the original routed token-transfer payload.
    queryId: uint64
    /// User address whose transferred jettons started the route.
    fromUser: address
    /// Token0 amount received by the Pool.
    leftAmount: coins
    /// Token1 amount received by the Pool.
    rightAmount: coins
    /// Referenced router payload containing refund, deadline, and swap parameters.
    dexPayload: Cell<StonfiPoolV2StableswapSwapDexPayload>
}

/// Router-to-Pool provide-liquidity request.
struct (0x37c096df) StonfiPoolV2StableswapProvideLp {
    /// Query id selected by the original routed token-transfer payload.
    queryId: uint64
    /// User address whose transferred jettons started the route.
    fromUser: address
    /// Token0 amount received by the Pool.
    leftAmount: coins
    /// Token1 amount received by the Pool.
    rightAmount: coins
    /// Referenced router payload containing refund, deadline, and provision parameters.
    dexPayload: Cell<StonfiPoolV2StableswapProvideLpDexPayload>
}

/// Router-to-Pool gas reset request that leaves `storage_fee::pool` nanotons and sends remaining TON as excesses.
struct (0x29d22935) StonfiPoolV2StableswapResetGas {
    /// Query id copied from the router admin request.
    queryId: uint64
    /// Docs `excesses_address`: address where excess TON will be sent; this source stores it after `query_id`.
    excessesRecipient: address
}

/// LP-account callback that asks the Pool to mint LP tokens or refund deposits.
struct (0x06ecd527) StonfiPoolV2StableswapCbAddLiquidity {
    /// Query id copied from the original add-liquidity flow.
    queryId: uint64
    /// Total token0 amount accumulated in the LP account.
    totAm0: coins
    /// Total token1 amount accumulated in the LP account.
    totAm1: coins
    /// User address whose deterministic LP account sent this callback.
    userAddress: address
    /// Minimum LP tokens accepted by the user.
    minLpOut: coins
    /// Nanotons forwarded with the LP wallet mint notification.
    fwdAmount: coins
    /// Optional payload forwarded with the LP wallet mint notification.
    customPayloadCs: cell?
    /// Referenced recipient, refund, and excess address cell.
    additionalFields: Cell<StonfiPoolV2StableswapCbAddLiquidityAdditionalFields>
}

/// LP-account callback that asks the Pool to refund deposited tokens.
struct (0x0f98e2b8) StonfiPoolV2StableswapCbRefundMe {
    /// Query id copied from the original refund flow.
    queryId: uint64
    /// Token0 amount to refund through the Router.
    totAm0: coins
    /// Token1 amount to refund through the Router.
    totAm1: coins
    /// User address whose deterministic LP account sent this callback.
    userAddress: address
    /// Optional token0 refund payload.
    leftMaybePayload: cell?
    /// Optional token1 refund payload.
    rightMaybePayload: cell?
}

/// Protocol-fee collection request accepted only from the configured fee address.
struct (0x1ee4911e) StonfiPoolV2StableswapCollectFees {
    /// Query id selected by the protocol-fee collector.
    queryId: uint64
    /// Optional token0 payout payload.
    maybePayload0: cell?
    /// Optional token1 payout payload.
    maybePayload1: cell?
}

/// Router-to-Pool fee update request for liquidity-pool fee, protocol fee, and protocol-fee recipient.
struct (0x75930d63) StonfiPoolV2StableswapInternalSetFees {
    /// Query id copied from the router admin request.
    queryId: uint64
    /// Docs `new_lp_fee`: new liquidity-pool fee value divided by `params::fee_divider` (10000).
    newLpFee: uint16
    /// Docs `new_protocol_fee`: new protocol fee value divided by `params::fee_divider` (10000).
    newProtocolFee: uint16
    /// Docs `new_protocol_fee_address`: address for receiving collected protocol fees.
    newProtocolFeeAddress: address?
    /// Docs `excesses_address`: address where TON excesses will be sent after update.
    excessesAddress: address
}

/// Router-to-Pool lock-status toggle request.
struct (0x62752512) StonfiPoolV2StableswapInternalUpdateStatus {
    /// Query id copied from the router admin request.
    queryId: uint64
    /// Address that receives pool excesses after the toggle.
    excessesRecipient: address
}

/// Router-to-Pool code upgrade request.
struct (0x355d097e) StonfiPoolV2StableswapInternalUpdatePoolCode {
    /// Query id copied from the router admin request.
    queryId: uint64
    /// New Pool code cell installed by `set_code`.
    upgradePoolCode: cell
}

/// StableSwap-specific Router-to-Pool pool-params update; source updates only `amp`.
struct (0xf163444a) StonfiPoolV2StableswapInternalSetParams {
    /// Query id copied from the router admin request.
    queryId: uint64
    /// Address where TON excesses will be sent after the amplification update.
    excessesAddress: address
    /// Replacement StableSwap amplification parameter stored as `PoolData.amp:uint32`.
    newAmp: uint32
}

/// On-chain request for current common PoolData; response is sent to the message sender.
struct (0x26df39fc) StonfiPoolV2StableswapGetterPoolDataRequest {
    /// Query id copied into the Pool data response.
    queryId: uint64
}

/// On-chain request for the deterministic LP account address of a user.
struct (0x15fbca95) StonfiPoolV2StableswapGetterLpAccountAddressRequest {
    /// Query id copied into the LP account address response.
    queryId: uint64
    /// User address whose LP account address is requested.
    userAddress: address
}

/// TEP-89 wallet-address discovery request accepted by the Pool as LP minter.
struct (0x2c76b973) StonfiPoolV2StableswapProvideWalletAddress {
    /// Caller-selected query id copied into `TakeWalletAddress`.
    queryId: uint64
    /// Owner address whose deterministic LP wallet address is requested.
    ownerAddress: address
    /// True when the response should include a referenced owner-address copy.
    includeAddress: bool
}

/// Pool-to-LP-account add-liquidity message.
struct (0x50c6a654) StonfiPoolV2StableswapAddLiquidity {
    /// Query id copied from the provide-liquidity flow.
    queryId: uint64
    /// New token0 amount sent to the LP account.
    newAmount0: coins
    /// New token1 amount sent to the LP account.
    newAmount1: coins
    /// Minimum LP tokens accepted by the user.
    minLpOut: coins
    /// Nanotons forwarded with the final LP wallet mint.
    fwdAmount: coins
    /// Whether both deposited sides are expected to be positive.
    bothPositive: bool
    /// LP token receiver, or `addr_none` in pool-driven refund loops.
    toUser: address?
    /// Optional payload forwarded with successful LP mint.
    customPayloadCs: cell?
    /// Referenced refund and excess address cell.
    additionalFields: Cell<StonfiPoolV2StableswapAddLiquidityAdditionalFields>
}

/// Pool-to-Router token payout or refund request.
struct (0x657b54f5) StonfiPoolV2StableswapPayTo {
    /// Query id copied from the flow that produced the payout.
    queryId: uint64
    /// Final token receiver.
    toAddress: address
    /// Address that receives remaining excess value.
    excessesAddress: address
    /// Original user address used by Router payout logic.
    originalCaller: address
    /// STON.fi success or refund code explaining the payout.
    exitCode: uint32
    /// Optional payload forwarded with the payout.
    customPayload: cell?
    /// Referenced token amount, token address, and forward-ton data.
    additionalInfo: Cell<StonfiPoolV2StableswapPayToAdditionalInfo>
}

/// Pool-to-Router referral-vault payout request.
struct (0x63381632) StonfiPoolV2StableswapPayVault {
    /// Query id copied from the swap flow.
    queryId: uint64
    /// Referral owner address for the Vault deposit.
    owner: address
    /// Address that receives remaining excess value.
    excessesAddress: address
    /// Referenced token amount and token address data.
    additionalInfo: Cell<StonfiPoolV2StableswapPayVaultAdditionalInfo>
}

/// Pool-to-LP-wallet mint message using the standard Jetton internal-transfer body.
struct (0x178d4519) StonfiPoolV2StableswapJettonInternalTransfer {
    /// Query id copied into the LP wallet mint flow.
    queryId: uint64
    /// LP jetton amount minted to the deterministic LP wallet.
    amount: coins
    /// User address recorded as the internal-transfer source.
    fromAddress: address
    /// Address that receives LP wallet excesses.
    responseAddress: address
    /// Nanotons forwarded with the LP wallet notification.
    forwardTonAmount: coins
    /// Optional forward payload supplied by the liquidity provider.
    forwardPayload: cell?
}

/// Pool response to `getter_pool_data`, the on-chain equivalent of `get_pool_data`.
struct (0x26df39fc) StonfiPoolV2StableswapGetterPoolDataResponse {
    /// Query id copied from the request.
    queryId: uint64
    /// Docs `is_locked`: true if this Pool is locked for transfer-notification operations.
    isLocked: bool
    /// Docs `reserve0`: amount of the first token in basic token units.
    reserve0: coins
    /// Docs `reserve1`: amount of the second token in basic token units.
    reserve1: coins
    /// Docs `token0_address`: address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Docs `token1_address`: address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Docs `additional_data`: fees, router, supply, and collected protocol fees in a referenced cell.
    details: Cell<StonfiPoolV2StableswapGetterPoolDataDetails>
}

/// Pool response to the on-chain LP account address request.
struct (0x15fbca95) StonfiPoolV2StableswapGetterLpAccountAddressResponse {
    /// Query id copied from the request.
    queryId: uint64
    /// Deterministic LP account address for the requested owner.
    lpAccountAddress: address
}

/// TEP-89 wallet-address discovery response emitted by the Pool as LP minter.
struct (0xd1735400) StonfiPoolV2StableswapTakeWalletAddress {
    /// Query id copied from the discovery request.
    queryId: uint64
    /// Deterministic LP wallet address, or `addr_none` for owners outside the configured workchain.
    walletAddress: address?
    /// Optional referenced owner address when `includeAddress` was true.
    ownerAddress: Cell<address>?
}

/// Router admin `set_params` message used to update StableSwap pool-specific params if present.
struct (0x2b8b3b62) StonfiPoolV2StableswapRouterSetParams {
    /// Query id selected by the router admin.
    queryId: uint64
    /// Replacement StableSwap amplification parameter validated by the Router extension.
    newAmp: uint32
    /// First pool token wallet address used to derive the target Pool.
    leftJettonWallet: address
    /// Second pool token wallet address used to derive the target Pool.
    rightJettonWallet: address
    /// Requested excess recipient; Router source maps `addr_none` to the sender.
    excessesRecipient: address?
}

/// Internal message bodies accepted by the StableSwap Pool.
type StonfiPoolV2StableswapIncomingMessage =
    | StonfiPoolV2StableswapBurnNotificationExt
    | StonfiPoolV2StableswapSwap
    | StonfiPoolV2StableswapProvideLp
    | StonfiPoolV2StableswapResetGas
    | StonfiPoolV2StableswapCbAddLiquidity
    | StonfiPoolV2StableswapCbRefundMe
    | StonfiPoolV2StableswapCollectFees
    | StonfiPoolV2StableswapInternalSetFees
    | StonfiPoolV2StableswapInternalUpdateStatus
    | StonfiPoolV2StableswapInternalUpdatePoolCode
    | StonfiPoolV2StableswapInternalSetParams
    | StonfiPoolV2StableswapGetterPoolDataRequest
    | StonfiPoolV2StableswapGetterLpAccountAddressRequest
    | StonfiPoolV2StableswapProvideWalletAddress

/// Internal message bodies emitted by the StableSwap Pool.
type StonfiPoolV2StableswapOutgoingMessage =
    | StonfiPoolV2StableswapAddLiquidity
    | StonfiPoolV2StableswapPayTo
    | StonfiPoolV2StableswapPayVault
    | StonfiPoolV2StableswapJettonInternalTransfer
    | StonfiPoolV2StableswapGetterPoolDataResponse
    | StonfiPoolV2StableswapGetterLpAccountAddressResponse
    | StonfiPoolV2StableswapTakeWalletAddress

/// Off-chain `get_pool_data` result: common PoolData fields plus StableSwap `amp` at index 12.
struct StonfiPoolV2StableswapPoolDataReply {
    /// Docs `is_locked` index 0: true if transfer-notification operations are locked.
    isLocked: bool
    /// Docs `router_address` index 1: address of the Router.
    routerAddress: address
    /// Docs `total_supply` index 2: total supply of LP tokens.
    totalSupply: int
    /// Docs `reserve0` index 3: amount of the first token in basic token units.
    reserve0: int
    /// Docs `reserve1` index 4: amount of the second token in basic token units.
    reserve1: int
    /// Docs `token0_wallet_address` index 5: address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Docs `token1_wallet_address` index 6: address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Docs `lp_fee` index 7: fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Docs `protocol_fee` index 8: fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Docs `protocol_fee_address` index 9: address for receiving protocol fees; source may return `addr_none`.
    protocolFeeAddress: any_address
    /// Docs `collected_token0_protocol_fee` index 10: collected protocol fees of the first token.
    collectedToken0ProtocolFee: int
    /// Docs `collected_token1_protocol_fee` index 11: collected protocol fees of the second token.
    collectedToken1ProtocolFee: int
    /// Docs StableSwap `amp` index 12: amplification parameter; no weighted `rate`, `w0`, or setter fields follow.
    amp: uint32
}

/// Structured result returned by Pool-as-LP-minter `get_jetton_data`.
struct StonfiPoolV2StableswapJettonDataReply {
    /// Total LP token supply returned by the Jetton minter getter.
    totalSupply: int
    /// Source returns true because the Pool can mint LP jettons.
    mintable: bool
    /// LP minter admin address is the Router address in this source.
    adminAddress: address
    /// Dynamically built LP token metadata content cell.
    jettonContent: cell
    /// LP wallet code cell used by deterministic wallet derivation.
    jettonWalletCode: cell
}

/// StableSwap Pool exit-code catalog from common Pool and StableSwap math source.
enum StonfiPoolV2StableswapErrors {
    /// StableSwap invariant iteration did not converge.
    NotConverge = 5103
    /// Pool has no liquidity for the requested operation.
    NoLiquidity = 80
    /// Calculated output amount is zero.
    ZeroOutput = 81
    /// Message sender is not the deterministic child contract expected by the Pool.
    InvalidCaller = 82
    /// Attached value is below the required gas budget.
    InsufficientGas = 83
    /// Message address is outside the configured workchain.
    WrongWorkchain = 85
    /// Message contains an address shape disallowed by the source path.
    WrongAddress = 86
    /// Initial liquidity is below the required minimum.
    LowLiquidity = 88
    /// Math helper reported an invalid calculation.
    MathError = 90
    /// Amount or reserve invariant check failed.
    InvalidAmount = 92
    /// Call is invalid for the current Pool state.
    InvalidCall = 93
    /// Fee value is outside configured bounds.
    FeeOutOfRange = 94
    /// Token wallet pair is invalid.
    InvalidToken = 95
    /// Empty internal message bodies are rejected.
    EmptyNotAllowed = 96
    /// Input amount exceeds the maximum ratio accepted by source math.
    MaxInRatio = 97
    /// Required cell data is empty.
    EmptyCell = 99
    /// Incoming internal message opcode is not supported by the Pool.
    WrongOperation = 65535
}

/// Return the pool type string; source returns `stableswap`.
get fun get_pool_type(): string {
    throw 0;
}

/// Return the deterministic LP account address for `ownerAddress`.
get fun get_lp_account_address(ownerAddress: address): address {
    throw 0;
}

/// Return LP minter data for the Pool's LP jetton.
get fun get_jetton_data(): StonfiPoolV2StableswapJettonDataReply {
    throw 0;
}

/// Return the deterministic LP wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return current StableSwap PoolData as common 12 fields plus `amp:uint32`.
get fun get_pool_data(): StonfiPoolV2StableswapPoolDataReply {
    throw 0;
}
