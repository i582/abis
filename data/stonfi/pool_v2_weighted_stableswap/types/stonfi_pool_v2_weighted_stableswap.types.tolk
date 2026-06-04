/// STON.fi DEX v2 Pool interface for a `weighted_stableswap` pool, including common Pool v2 getters/messages and weighted parameter setters.
contract StonfiPoolV2WeightedStableswap {
    author: "STON.fi"
    version: "2.0"
    description: "STON.fi DEX v2 WeightedStableSwap Pool ABI with source-proven wire layout and documentation aligned to docs.ston.fi PoolData, getter, opcode, fee, and weighted parameter descriptions"
    storage: StonfiPoolV2WeightedStableswapStorage
    incomingMessages: StonfiPoolV2WeightedStableswapIncomingMessage
    outgoingMessages: StonfiPoolV2WeightedStableswapOutgoingMessage
}

/// Persistent weighted StableSwap parameter ref stored between common Pool data and static router/token/code data.
struct StonfiPoolV2WeightedStableswapParams {
    /// Weighted stableswap amplification parameter.
    amp: uint128
    /// Stable token ratio parameter; initial storage uses zero before a ratio is configured.
    rate: uint128
    /// Token 0 weight parameter; source allows one-time initialization while stored `w0` is zero.
    w0: uint128
    /// Address with rights to change `rate`, or `addr_none` before a setter is configured.
    rateSetterAddress: address?
}

/// Static Pool data ref used for deterministic LP Account and LP Jetton wallet address derivation.
struct StonfiPoolV2WeightedStableswapStaticData {
    /// Address of the STON.fi Router authorized to send swap, provide-liquidity, and governance messages.
    routerAddress: address
    /// Address of the first Jetton token wallet after source-level hash ordering.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet after source-level hash ordering.
    token1WalletAddress: address
    /// Code of the LP Jetton wallet.
    jettonLpWalletCode: cell
    /// Code of the user's deterministic LP Account.
    lpAccountCode: cell
}

/// Persistent pool data cell loaded by `storage::load`.
struct StonfiPoolV2WeightedStableswapStorage {
    /// True if `transfer_notification` operations are locked for `swap` and `provide_lp`.
    isLocked: bool
    /// Amount of the first token stored as liquidity, in basic token units.
    reserve0: coins
    /// Amount of the second token stored as liquidity, in basic token units.
    reserve1: coins
    /// Total supply of LP tokens, in basic token units.
    totalSupply: coins
    /// Amount of collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Amount of collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: coins
    /// Address for receiving protocol fees, initially `addr_none` in pool state init.
    protocolFeeAddress: address?
    /// Liquidity pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Referenced weighted StableSwap PoolData tail: `amp`, `rate`, `w0`, and `rate_setter`.
    weightedParams: Cell<StonfiPoolV2WeightedStableswapParams>
    /// Referenced static router, token wallet, LP wallet code, and LP Account code data.
    staticData: Cell<StonfiPoolV2WeightedStableswapStaticData>
}

/// Referenced swap body nested inside the router-to-pool swap dex payload.
struct StonfiPoolV2WeightedStableswapSwapBody {
    /// Minimum output amount accepted by the user.
    minOut: coins
    /// Output receiver; `addr_none` makes the pool use `fromUser`.
    receiver: address?
    /// Nanotons forwarded with the router payout transfer.
    fwdGas: coins
    /// Optional payload forwarded on successful payout.
    customPayload: cell?
    /// Nanotons forwarded if the swap is refunded.
    refundFwdGas: coins
    /// Optional payload forwarded on refund payout.
    refundPayload: cell?
    /// Referral fee value validated against router/pool fee bounds.
    refFee: uint16
    /// Referral address; `addr_none` disables referral-fee payout.
    refAddress: address?
}

/// Router-provided swap dex payload ref decoded by the pool after common amounts.
struct StonfiPoolV2WeightedStableswapSwapDexPayload {
    /// Original transferred operation copied from the user's Jetton forward payload.
    transferredOp: uint32
    /// Other token wallet address supplied by the router.
    tokenWallet1: address
    /// Address used by the pool when it refunds input tokens.
    refundAddress: address
    /// Address used by router payouts for excess TON.
    excessesAddress: address
    /// Unix timestamp after which the swap is refunded.
    txDeadline: uint64
    /// Referenced swap parameters consumed by the pool.
    swapBody: Cell<StonfiPoolV2WeightedStableswapSwapBody>
}

/// Referenced provide-liquidity body nested inside the router-to-pool provide dex payload.
struct StonfiPoolV2WeightedStableswapProvideLpBody {
    /// Minimum LP Jettons accepted by the user.
    minLpOut: coins
    /// LP token receiver passed to the LP Account.
    toAddress: address
    /// One-bit flag requiring both sides of the LP Account balance to be positive before minting.
    bothPositive: uint1
    /// Nanotons forwarded by the eventual LP wallet mint notification.
    fwdAmount: coins
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayload: cell?
}

/// Router-provided liquidity dex payload ref decoded by the pool after common amounts.
struct StonfiPoolV2WeightedStableswapProvideLpDexPayload {
    /// Original transferred operation copied from the user's Jetton forward payload.
    transferredOp: uint32
    /// Other token wallet address supplied by the router.
    tokenWallet1: address
    /// Address used by the pool/router path when liquidity is refunded.
    refundAddress: address
    /// Address used for excess TON after liquidity processing.
    excessesAddress: address
    /// Unix timestamp after which the liquidity operation is refunded.
    txDeadline: uint64
    /// Referenced provide-liquidity parameters consumed by the pool.
    provideLpBody: Cell<StonfiPoolV2WeightedStableswapProvideLpBody>
}

/// Referenced callback destinations carried by LP Account `cb_add_liquidity`.
struct StonfiPoolV2WeightedStableswapCbAddLiquidityAdditionalFields {
    /// LP token receiver requested by the original liquidity operation.
    toUserAddress: address
    /// Destination used when the pool pushes liquidity back to a fresh LP Account for refunding.
    refundAddress: address
    /// Destination for excess TON after mint or refund handling.
    excessAddress: address
}

/// Referenced refund/excess destinations sent from Pool to LP Account in `add_liquidity`.
struct StonfiPoolV2WeightedStableswapAddLiquidityAdditionalFields {
    /// Destination used by the pool/router path when liquidity is refunded.
    refundAddress: address?
    /// Destination for excess TON after liquidity handling.
    excessAddress: address
}

/// Referenced payout amounts and token wallets in router `pay_to`.
struct StonfiPoolV2WeightedStableswapPayToAdditionalInfo {
    /// Nanotons forwarded from router to the final Jetton recipient.
    fwdTonAmount: coins
    /// Token0 amount to transfer through the router path.
    amount0Out: coins
    /// Token0 wallet address used by the router for the transfer.
    token0Address: address
    /// Token1 amount to transfer through the router path.
    amount1Out: coins
    /// Token1 wallet address used by the router for the transfer.
    token1Address: address
}

/// Referenced referral-fee payout amounts and token wallets in router `pay_vault`.
struct StonfiPoolV2WeightedStableswapPayVaultAdditionalInfo {
    /// Token0 referral-fee amount to deposit into a Vault.
    amount0Out: coins
    /// Token0 wallet address used by the router/vault path.
    token0Address: address
    /// Token1 referral-fee amount to deposit into a Vault.
    amount1Out: coins
    /// Token1 wallet address used by the router/vault path.
    token1Address: address
}

/// Referenced common PoolData fields emitted by asynchronous `getter_pool_data` responses.
struct StonfiPoolV2WeightedStableswapGetterPoolDataAdditionalInfo {
    /// Liquidity pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Address of the Router.
    routerAddress: address
    /// Address for receiving protocol fees, or `addr_none` in initial state.
    protocolFeeAddress: address?
    /// Total amount of minted LP tokens.
    totalSupply: coins
    /// Amount of collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Amount of collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: coins
}

/// Referenced weighted setter field used by Pool-side `internal_set_params`.
struct StonfiPoolV2WeightedStableswapInternalSetParamsAdditionalFields {
    /// Address with rights to change `rate`, or `addr_none` to clear it.
    setterAddress: address?
}

/// Router-originated swap request accepted by common Pool v2 code.
struct (0x6664de2a) StonfiPoolV2WeightedStableswapSwap {
    /// Query id copied from the upstream router flow.
    queryId: uint64
    /// User address reported by the router.
    fromUser: address
    /// Token0 input amount; exactly one side is expected to be positive.
    leftAmount: coins
    /// Token1 input amount; exactly one side is expected to be positive.
    rightAmount: coins
    /// Referenced router dex payload containing refund, deadline, and swap parameters.
    dexPayload: Cell<StonfiPoolV2WeightedStableswapSwapDexPayload>
}

/// Router-originated provide-liquidity request accepted by common Pool v2 code.
struct (0x37c096df) StonfiPoolV2WeightedStableswapProvideLp {
    /// Query id copied from the upstream router flow.
    queryId: uint64
    /// User address reported by the router.
    fromUser: address
    /// Token0 amount delivered to the pool.
    leftAmount: coins
    /// Token1 amount delivered to the pool.
    rightAmount: coins
    /// Referenced router dex payload containing refund, deadline, and LP mint parameters.
    dexPayload: Cell<StonfiPoolV2WeightedStableswapProvideLpDexPayload>
}

/// LP wallet callback accepted after burning LP Jettons.
struct (0x297437cf) StonfiPoolV2WeightedStableswapBurnNotificationExt {
    /// Query id copied from the LP wallet burn request.
    queryId: uint64
    /// Burned LP Jetton amount.
    jettonAmount: coins
    /// LP owner whose liquidity is released.
    fromAddress: address
    /// Response address forwarded by the LP wallet; source accepts only `addr_none`.
    responseAddress: address?
    /// Optional payload ref, commonly holding left/right maybe payload refs.
    maybeCustomPayload: cell?
}

/// LP Account callback that aggregates both token sides and requests LP minting.
struct (0x06ecd527) StonfiPoolV2WeightedStableswapCbAddLiquidity {
    /// Query id carried by the STON.fi callback message builder.
    queryId: uint64
    /// Total token0 amount supplied from the LP Account.
    totAm0: coins
    /// Total token1 amount supplied from the LP Account.
    totAm1: coins
    /// User whose LP Account funded the callback.
    userAddress: address
    /// Minimum LP Jettons accepted by the user.
    minLpOut: coins
    /// Nanotons forwarded by the eventual LP wallet mint notification.
    fwdAmount: coins
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayloadCs: cell?
    /// Referenced receiver, refund, and excess destinations.
    additionalFields: Cell<StonfiPoolV2WeightedStableswapCbAddLiquidityAdditionalFields>
}

/// LP Account callback requesting refund of pending token balances.
struct (0x0f98e2b8) StonfiPoolV2WeightedStableswapCbRefundMe {
    /// Query id carried by the STON.fi callback message builder.
    queryId: uint64
    /// Token0 amount to refund through the router path.
    totAm0: coins
    /// Token1 amount to refund through the router path.
    totAm1: coins
    /// User whose LP Account funded the refund callback.
    userAddress: address
    /// Optional payload forwarded with the token0 refund transfer.
    leftMaybePayload: cell?
    /// Optional payload forwarded with the token1 refund transfer.
    rightMaybePayload: cell?
}

/// Protocol-fee collector request to withdraw accrued fees through router payouts.
struct (0x1ee4911e) StonfiPoolV2WeightedStableswapCollectFees {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Optional payload forwarded with the token0 protocol-fee transfer.
    maybePayload0: cell?
    /// Optional payload forwarded with the token1 protocol-fee transfer.
    maybePayload1: cell?
}

/// Router admin request that reserves pool storage rent and returns remaining TON.
struct (0x29d22935) StonfiPoolV2WeightedStableswapResetGas {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Excesses recipient normalized by the router before forwarding to the pool.
    excessesRecipient: address
}

/// Router-originated admin request that updates liquidity pool and protocol fee ratios inside the pool.
struct (0x75930d63) StonfiPoolV2WeightedStableswapInternalSetFees {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// New liquidity pool fee ratio; the stored value is divided by `params::fee_divider` (10000).
    newLpFee: uint16
    /// New protocol fee ratio; the stored value is divided by `params::fee_divider` (10000).
    newProtocolFee: uint16
    /// Address for receiving collected protocol fees.
    newProtocolFeeAddress: address
    /// Address where TON excesses will be sent.
    excessesAddress: address
}

/// Router admin request that toggles the pool lock flag.
struct (0x62752512) StonfiPoolV2WeightedStableswapInternalUpdateStatus {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Excesses recipient normalized by the router before forwarding to the pool.
    excessesRecipient: address
}

/// Router admin request that replaces the pool code with the router's staged upgrade code.
struct (0x355d097e) StonfiPoolV2WeightedStableswapInternalUpdatePoolCode {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Referenced replacement pool code cell.
    upgradePoolCode: cell
}

/// On-chain getter request for common pool data; the response uses the same opcode with fields appended.
struct (0x26df39fc) StonfiPoolV2WeightedStableswapGetterPoolDataRequest {
    /// Query id copied into the asynchronous getter response.
    queryId: uint64
}

/// On-chain getter request for a user's deterministic LP Account address.
struct (0x15fbca95) StonfiPoolV2WeightedStableswapGetterLpAccountAddressRequest {
    /// Query id copied into the asynchronous getter response.
    queryId: uint64
    /// User address used to derive the deterministic LP Account.
    userAddress: address
}

/// TEP-89 wallet discovery request accepted by the pool as LP Jetton minter.
struct (0x2c76b973) StonfiPoolV2WeightedStableswapProvideWalletAddress {
    /// Query id copied into the `TakeWalletAddress` response.
    queryId: uint64
    /// LP token owner whose deterministic LP wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// Pool-side weighted parameter update forwarded by Router admin `set_params`.
struct (0xf163444a) StonfiPoolV2WeightedStableswapInternalSetParams {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Address where TON excesses will be sent after the update.
    excessesAddress: address
    /// Side wallet used by source to decide whether `newW` is stored directly as token 0 weight or as its complement.
    sideWallet: address
    /// New weighted stableswap amplification parameter.
    newAmp: uint128
    /// New stable token ratio parameter; source keeps the previous `rate` when this value is zero.
    newRate: uint128
    /// New token weight parameter; source applies it only while stored `w0` is still zero.
    newW: uint128
    /// Referenced address with rights to later change `rate` via `set_rate`.
    additionalFields: Cell<StonfiPoolV2WeightedStableswapInternalSetParamsAdditionalFields>
}

/// Request from the configured rate setter to change the weighted pool's stable token ratio.
struct (0x4a2bddb0) StonfiPoolV2WeightedStableswapSetRate {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// New nonzero stable token ratio parameter stored by the pool.
    newRate: uint128
}

/// Router callback emitted by the pool to transfer output or refunded tokens.
struct (0x657b54f5) StonfiPoolV2WeightedStableswapPayTo {
    /// Query id copied from the pool flow that produced the payout.
    queryId: uint64
    /// Final owner address that receives router Jetton transfers.
    toAddress: address
    /// Address used by the router for excess TON.
    excessesAddress: address
    /// Original user/caller address reported for diagnostics and routing.
    originalCaller: address
    /// STON.fi exit/comment code describing success or refund reason.
    exitCode: uint32
    /// Optional payload forwarded with the selected Jetton transfer.
    customPayload: cell?
    /// Referenced payout amounts and token wallet addresses.
    additionalInfo: Cell<StonfiPoolV2WeightedStableswapPayToAdditionalInfo>
}

/// Router callback emitted by the pool to deposit referral fees into Vault contracts.
struct (0x63381632) StonfiPoolV2WeightedStableswapPayVault {
    /// Query id copied from the swap flow that produced referral fees.
    queryId: uint64
    /// Referral owner whose Vault receives fees.
    owner: address
    /// Address used for excess TON after Vault deposit routing.
    excessesAddress: address
    /// Referenced referral-fee amounts and token wallet addresses.
    additionalInfo: Cell<StonfiPoolV2WeightedStableswapPayVaultAdditionalInfo>
}

/// Pool-to-LP-Account message that updates pending balances or forces a refund path.
struct (0x50c6a654) StonfiPoolV2WeightedStableswapAddLiquidity {
    /// Query id copied from the provide-liquidity flow.
    queryId: uint64
    /// Newly received token0 amount for the LP Account.
    newAmount0: coins
    /// Newly received token1 amount for the LP Account.
    newAmount1: coins
    /// Minimum LP Jettons accepted by the user.
    minLpOut: coins
    /// Nanotons forwarded by the eventual LP wallet mint notification.
    fwdAmount: coins
    /// One-bit flag requiring both token balances to be positive before minting.
    bothPositive: uint1
    /// LP token receiver requested by the liquidity operation; refund fallback may use `addr_none`.
    toUser: address?
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayloadCs: cell?
    /// Referenced refund and excess destinations.
    additionalFields: Cell<StonfiPoolV2WeightedStableswapAddLiquidityAdditionalFields>
}

/// Pool-to-LP-wallet mint transfer for newly issued LP Jettons.
struct (0x178d4519) StonfiPoolV2WeightedStableswapLpWalletInternalTransfer {
    /// Query id copied from the liquidity callback.
    queryId: uint64
    /// LP Jetton amount minted to the recipient wallet.
    amount: coins
    /// User address reported as the source owner in the LP wallet notification path.
    fromAddress: address
    /// Optional response address for LP wallet excesses.
    responseAddress: address?
    /// Nanotons forwarded to the LP wallet owner notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` tail; the pool source writes it with `store_maybe_ref`.
    forwardPayload: RemainingBitsAndRefs
}

/// Asynchronous common PoolData response emitted to an on-chain `getter_pool_data` requester.
struct (0x26df39fc) StonfiPoolV2WeightedStableswapGetterPoolDataResponse {
    /// Query id copied from the asynchronous getter request.
    queryId: uint64
    /// True if this Pool is locked.
    isLocked: bool
    /// Amount of the first token stored as liquidity, in basic token units.
    reserve0: coins
    /// Amount of the second token stored as liquidity, in basic token units.
    reserve1: coins
    /// Address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Referenced common fee, router, total supply, and collected protocol-fee fields.
    additionalInfo: Cell<StonfiPoolV2WeightedStableswapGetterPoolDataAdditionalInfo>
}

/// Asynchronous LP Account address response emitted to an on-chain getter requester.
struct (0x15fbca95) StonfiPoolV2WeightedStableswapGetterLpAccountAddressResponse {
    /// Query id copied from the asynchronous getter request.
    queryId: uint64
    /// Deterministic LP Account address for the requested user.
    lpAccountAddress: address
}

/// TEP-89 wallet discovery response emitted by the pool as LP Jetton minter.
struct (0xd1735400) StonfiPoolV2WeightedStableswapTakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Deterministic LP wallet address, or `addr_none` when the owner workchain is unsupported.
    walletAddress: address?
    /// Optional referenced copy of the requested owner address.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by STON.fi WeightedStableSwap Pool v2.
type StonfiPoolV2WeightedStableswapIncomingMessage =
    | StonfiPoolV2WeightedStableswapSwap
    | StonfiPoolV2WeightedStableswapProvideLp
    | StonfiPoolV2WeightedStableswapBurnNotificationExt
    | StonfiPoolV2WeightedStableswapCbAddLiquidity
    | StonfiPoolV2WeightedStableswapCbRefundMe
    | StonfiPoolV2WeightedStableswapCollectFees
    | StonfiPoolV2WeightedStableswapResetGas
    | StonfiPoolV2WeightedStableswapInternalSetFees
    | StonfiPoolV2WeightedStableswapInternalUpdateStatus
    | StonfiPoolV2WeightedStableswapInternalUpdatePoolCode
    | StonfiPoolV2WeightedStableswapGetterPoolDataRequest
    | StonfiPoolV2WeightedStableswapGetterLpAccountAddressRequest
    | StonfiPoolV2WeightedStableswapProvideWalletAddress
    | StonfiPoolV2WeightedStableswapInternalSetParams
    | StonfiPoolV2WeightedStableswapSetRate

/// Internal message bodies emitted by STON.fi WeightedStableSwap Pool v2.
type StonfiPoolV2WeightedStableswapOutgoingMessage =
    | StonfiPoolV2WeightedStableswapPayTo
    | StonfiPoolV2WeightedStableswapPayVault
    | StonfiPoolV2WeightedStableswapAddLiquidity
    | StonfiPoolV2WeightedStableswapLpWalletInternalTransfer
    | StonfiPoolV2WeightedStableswapGetterPoolDataResponse
    | StonfiPoolV2WeightedStableswapGetterLpAccountAddressResponse
    | StonfiPoolV2WeightedStableswapTakeWalletAddress

/// Structured `PoolData` returned by `get_pool_data`: common Pool state plus weighted stableswap tail fields.
struct StonfiPoolV2WeightedStableswapPoolDataReply {
    /// True if `transfer_notification` operations are locked for `swap` and `provide_lp`.
    isLocked: bool
    /// Address of the Router.
    routerAddress: address
    /// Total supply of LP tokens returned as a TVM stack integer.
    totalSupply: int
    /// Amount of the first token, in basic token units, returned as a TVM stack integer.
    reserve0: int
    /// Amount of the second token, in basic token units, returned as a TVM stack integer.
    reserve1: int
    /// Address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Liquidity pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Address for receiving protocol fees, or `addr_none` in initial state.
    protocolFeeAddress: any_address
    /// Amount of collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: int
    /// Amount of collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: int
    /// Weighted stableswap amplification parameter.
    amp: uint128
    /// Stable token ratio parameter.
    rate: uint128
    /// Token 0 weight parameter.
    w0: uint128
    /// Address with rights to change `rate`, or `addr_none` before one is configured.
    rateSetter: any_address
}

/// Structured result returned by standard Jetton minter `get_jetton_data` for the pool's LP Jetton.
struct StonfiPoolV2WeightedStableswapJettonDataReply {
    /// Total token supply of LP tokens, in basic token units.
    totalSupply: int
    /// Always true for this Pool, matching the LP Jetton minter getter.
    mintable: bool
    /// Router address returned in the Jetton admin slot.
    routerAddress: address
    /// Off-chain LP Jetton metadata content cell.
    contentLp: cell
    /// Code of the LP Jetton wallet.
    jettonLpWalletCode: cell
}

/// Return this Pool type string; for this contract it is `weighted_stableswap`.
get fun get_pool_type(): string {
    return "weighted_stableswap";
}

/// Return the deterministic LP Account address of a user.
get fun get_lp_account_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return common Pool state plus weighted stableswap `amp`, `rate`, `w0`, and `rate_setter` fields.
get fun get_pool_data(): StonfiPoolV2WeightedStableswapPoolDataReply {
    return {
        isLocked: false,
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        totalSupply: 0,
        reserve0: 0,
        reserve1: 0,
        token0WalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        token1WalletAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        lpFee: 0,
        protocolFee: 0,
        protocolFeeAddress: createAddressNone(),
        collectedToken0ProtocolFee: 0,
        collectedToken1ProtocolFee: 0,
        amp: 0,
        rate: 0,
        w0: 0,
        rateSetter: createAddressNone(),
    };
}

/// Return LP Jetton supply, mintability, router/admin address, generated content, and LP wallet code.
get fun get_jetton_data(): StonfiPoolV2WeightedStableswapJettonDataReply {
    return {
        totalSupply: 0,
        mintable: true,
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        contentLp: createEmptyCell(),
        jettonLpWalletCode: createEmptyCell(),
    };
}

/// Return the deterministic LP Jetton wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
