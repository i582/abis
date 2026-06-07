/// Low-level ABI for the STON.fi DEX v2 Router family.
contract StonfiRouterV2 {
    author: "STON.fi"
    version: "2.0"
    description: "Curated low-level STON.fi DEX v2 Router ABI for getter methods, Jetton transfer payloads, admin operations, and Pool/Vault callbacks. Covers constant_product, stableswap, weighted_stableswap, and weighted_const_product router variants."
    storage: StonfiRouterV2Storage
    incomingMessages: StonfiRouterV2IncomingMessage
    outgoingMessages: StonfiRouterV2OutgoingMessage
    forceAbiExport: StonfiRouterV2SwapForwardPayload | StonfiRouterV2CrossSwapForwardPayload | StonfiRouterV2ProvideLpForwardPayload | StonfiRouterV2SetStableSwapParams | StonfiRouterV2SetWeightedStableSwapParams | StonfiRouterV2SetWeightedConstProductParams | StonfiRouterV2PoolInternalSetStableSwapParams | StonfiRouterV2PoolInternalSetWeightedStableSwapParams | StonfiRouterV2PoolInternalSetWeightedConstProductParams
}

/// Persistent Router state stored in the root data cell and exposed by `get_router_data`.
struct StonfiRouterV2Storage {
    /// True when `transfer_notification` operations are locked, blocking `swap` and `provide_lp` routing.
    isLocked: bool
    /// Contract admin account authorized to run Router governance operations.
    adminAddress: address
    /// Pending code, admin, and pool-code upgrade state; zero deadlines mean no pending upgrade.
    tempUpgrade: Cell<StonfiRouterV2TempUpgrade>
    /// Router id and contract code cells used for deterministic Pool, LP wallet/account, and Vault derivation.
    staticData: Cell<StonfiRouterV2StaticData>
    /// Finalized Pool code staged by pool-code upgrade finalization and forwarded by `update_pool_code`.
    upgradePoolCode: cell
}

/// Pending upgrade data stored as the `tempUpgrade` storage ref.
struct StonfiRouterV2TempUpgrade {
    /// Unix timestamp when the pending router-code upgrade may be finalized, or zero.
    codeUpgradeDeadline: uint64
    /// Unix timestamp when the pending admin upgrade may be finalized, or zero.
    adminUpgradeDeadline: uint64
    /// Unix timestamp when the pending pool-code upgrade may be finalized, or zero.
    poolCodeUpgradeDeadline: uint64
    /// Pending admin address; source stores `addr_none` when no admin upgrade is active.
    pendingAdminAddress: address?
    /// Pending router code cell, empty when no router-code upgrade is active.
    pendingRouterCode: cell
    /// Pending pool code cell, empty when no pool-code upgrade is active.
    pendingPoolCode: cell
}

/// Static Router data returned by `get_router_data` as code cells and used for address derivation.
struct StonfiRouterV2StaticData {
    /// Router id returned as the first `get_router_data` result.
    id: uint64
    /// Code of the LP wallet contract.
    jettonLpWalletCode: cell
    /// Code of the Router's liquidity Pool contract.
    poolCode: cell
    /// Code of the LP account contract.
    lpAccountCode: cell
    /// Code of the referral-fee Vault contract.
    vaultCode: cell
}

/// `pay_to` additional-data cell describing the token transfer amount and wallet side.
struct StonfiPayToV2AdditionalInfo {
    /// Gas forwarded in the Jetton `transfer_notification` when a custom payload is present.
    fwdTonAmount: coins
    /// Amount of the first Jetton token in basic token units; exactly one side is normally non-zero.
    amount0Out: coins
    /// Router-owned wallet address of the first Jetton.
    token0Address: address
    /// Amount of the second Jetton token in basic token units; exactly one side is normally non-zero.
    amount1Out: coins
    /// Router-owned wallet address of the second Jetton.
    token1Address: address
}

/// `pay_vault` additional-data cell describing the referral-fee token side.
struct StonfiPayVaultV2AdditionalInfo {
    /// Referral-fee amount of the first Jetton in basic token units; exactly one side is normally non-zero.
    amount0Out: coins
    /// Router-owned wallet address of the first Jetton.
    token0Address: address
    /// Referral-fee amount of the second Jetton in basic token units; exactly one side is normally non-zero.
    amount1Out: coins
    /// Router-owned wallet address of the second Jetton.
    token1Address: address
}

/// Additional-data cell for `swap` and `cross_swap` token transfer payloads.
struct StonfiSwapV2DexPayloadSwapBody {
    /// Minimum required amount of output tokens; the swap fails below this amount.
    minOut: coins
    /// Address where output tokens are sent after swap; source treats `addr_none` as the original sender.
    receiver: address?
    /// Gas used to forward a Jetton `transfer_notification` after swap when `customPayload` is present.
    fwdGas: coins
    /// Payload sent in the Jetton `transfer_notification` after swap.
    customPayload: cell?
    /// Gas used to forward a Jetton `transfer_notification` if the swap fails and `refundPayload` is present.
    refundFwdGas: coins
    /// Payload sent in the Jetton `transfer_notification` if the swap fails.
    refundPayload: cell?
    /// Referrer fee value; official docs cap it at 100, which is 1% with fee divider 10000.
    refFee: uint16
    /// Referrer address; `addr_none` disables the referral-fee Vault path.
    refAddress: address?
}

/// DexPayload ref embedded in Router-to-Pool `swap` messages.
struct StonfiSwapV2DexPayload {
    /// Payload opcode; `cross_swap` is normalized to `swap` while preserving this original payload ref.
    transferredOp: uint32
    /// Address of the other Router-owned Jetton wallet in the pair.
    tokenWallet1: address
    /// Address where refunded Jettons are sent if routing or swap validation fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Execution deadline timestamp for this transaction.
    txDeadline: uint64
    /// Referenced additional-data cell for swap or cross-swap execution.
    swapBody: Cell<StonfiSwapV2DexPayloadSwapBody>
}

/// User Jetton forward payload for swapping one Jetton type for another.
struct (0x6664de2a) StonfiRouterV2SwapForwardPayload {
    /// Address of the other Router-owned Jetton wallet in the pair.
    tokenWallet1: address
    /// Address where refunded Jettons are sent if routing or swap validation fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Execution deadline timestamp for this transaction.
    txDeadline: uint64
    /// Referenced additional-data cell for swap execution.
    swapBody: Cell<StonfiSwapV2DexPayloadSwapBody>
}

/// Custom payload used to chain another swap through the same Router.
struct (0x69cf1a5b) StonfiRouterV2CrossSwapForwardPayload {
    /// Address of the other Router-owned Jetton wallet for the chained swap.
    tokenWallet1: address
    /// Address where refunded Jettons are sent if the chained swap fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Execution deadline timestamp for the chained swap.
    txDeadline: uint64
    /// Referenced additional-data cell; layout matches the normal swap body and `fwdGas` is ignored by docs.
    crossSwapBody: Cell<StonfiSwapV2DexPayloadSwapBody>
}

/// Additional-data cell for `provide_lp` token transfer payloads.
struct StonfiProvideLpV2DexPayloadProvideLpBody {
    /// Minimum required LP token amount to receive.
    minLpOut: coins
    /// Address where minted LP tokens are sent.
    toAddress: address
    /// When true, minting proceeds only if both deposited token balances are non-zero.
    bothPositive: bool
    /// Gas used to forward a Jetton `transfer_notification` after LP mint when `customPayload` is present.
    fwdAmount: coins
    /// Payload sent in the Jetton `transfer_notification` after LP mint.
    customPayload: cell?
}

/// DexPayload ref embedded in Router-to-Pool `provide_lp` messages.
struct StonfiProvideLpV2DexPayload {
    /// Payload opcode; source accepts only `provide_lp` for this routed message.
    transferredOp: uint32
    /// Address of the other Router-owned Jetton wallet in the pair.
    tokenWallet1: address
    /// Address where refunded Jettons are sent if routing or Pool validation fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Execution deadline timestamp for this transaction.
    txDeadline: uint64
    /// Referenced additional-data cell for liquidity provision.
    provideLpBody: Cell<StonfiProvideLpV2DexPayloadProvideLpBody>
}

/// User Jetton forward payload for adding liquidity through the Router.
struct (0x37c096df) StonfiRouterV2ProvideLpForwardPayload {
    /// Address of the other Router-owned Jetton wallet in the pair.
    tokenWallet1: address
    /// Address where refunded Jettons are sent if routing or Pool validation fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Execution deadline timestamp for this transaction.
    txDeadline: uint64
    /// Referenced additional-data cell for liquidity provision.
    provideLpBody: Cell<StonfiProvideLpV2DexPayloadProvideLpBody>
}

/// Jetton wallet notification received after a user token transfer to a Router-owned wallet.
struct (0x7362d09c) StonfiRouterV2JettonTransferNotification {
    /// Query id copied from the user Jetton transfer.
    queryId: uint64
    /// Jetton amount in basic token units received by the Router-owned wallet.
    jettonAmount: coins
    /// User address reported by the notifying Jetton wallet.
    fromAddress: address
    /// Raw Jetton forward-payload tail; must contain a STON.fi `swap` or `provide_lp` payload ref.
    forwardPayload: RemainingBitsAndRefs
}

/// Admin request that toggles Router lock status, blocking or allowing `transfer_notification` routing.
struct (0x38a6022f) StonfiRouterV2UpdateStatus {
    /// Caller-selected query id; source does not inspect it after context parsing.
    queryId: uint64
}

/// Admin `reset_gas` request that reserves Router storage balance and returns excess TON to admin.
struct (0x29d22935) PtonResetGas {
    /// Caller-selected query id; source does not inspect it after context parsing.
    queryId: uint64
}

/// `set_fees` additional-data cell with the target Pool wallets and excess recipient.
struct StonfiRouterV2SetFeesJettonInfo {
    /// Address of the Router's wallet of the first Jetton.
    jettonWallet0: address
    /// Address of the Router's wallet of the second Jetton.
    jettonWallet1: address
    /// Address where TON excesses are sent; `addr_none` is replaced with the message sender.
    excessesRecipient: address?
}

/// Admin request that changes liquidity-pool and protocol fee parameters for a derived Pool.
struct (0x58274069) StonfiRouterV2SetFees {
    /// Caller-selected query id copied into the outgoing Pool message.
    queryId: uint64
    /// New liquidity-pool fee ratio; official docs use value / 10000, capped at 100.
    newLpFee: uint16
    /// New protocol fee ratio; official docs use value / 10000, capped at 100.
    newProtocolFee: uint16
    /// Address that receives protocol fees.
    newProtocolFeeAddress: address
    /// Referenced additional-data cell with Pool token wallets and excess recipient.
    jettonInfo: Cell<StonfiRouterV2SetFeesJettonInfo>
}

/// Admin request that forwards `reset_gas` to a derived Pool for the provided Jetton pair.
struct (0x66d0dff2) StonfiRouterV2ResetPoolGas {
    /// Caller-selected query id copied into the outgoing Pool reset message.
    queryId: uint64
    /// Address of the Router's wallet of the first Jetton.
    jettonWallet0: address
    /// Address of the Router's wallet of the second Jetton.
    jettonWallet1: address
    /// Address where TON excesses are sent; `addr_none` is replaced with the message sender.
    excessesRecipient: address?
}

/// Admin request that toggles lock status of a derived Pool.
struct (0x2af4607c) StonfiRouterV2UpdatePoolStatus {
    /// Caller-selected query id copied into the outgoing Pool status message.
    queryId: uint64
    /// Address of the Router's wallet of the first Jetton.
    jettonWallet0: address
    /// Address of the Router's wallet of the second Jetton.
    jettonWallet1: address
    /// Address where TON excesses are sent; `addr_none` is replaced with the message sender.
    excessesRecipient: address?
}

/// Source-only admin request that asks a derived Pool to install the Router's finalized Pool code upgrade.
struct (0x68e89380) StonfiRouterV2UpdatePoolCode {
    /// Caller-selected query id copied into the outgoing Pool code-update message.
    queryId: uint64
    /// Address of the Router's wallet of the first Jetton.
    jettonWallet0: address
    /// Address of the Router's wallet of the second Jetton.
    jettonWallet1: address
}

/// Admin request that initiates a delayed Router code upgrade; source uses a seven-day cooldown.
struct (0x03601fc8) StonfiRouterV2InitCodeUpgrade {
    /// Caller-selected query id; source does not store it.
    queryId: uint64
    /// Code of the new Router contract stored in the temp-upgrade cell.
    newCode: cell
}

/// Admin request that initiates a delayed Router admin change; source uses a two-day cooldown.
struct (0x0b02fd5b) StonfiRouterV2InitAdminUpgrade {
    /// Caller-selected query id; source does not store it.
    queryId: uint64
    /// New Router admin address stored in the temp-upgrade cell.
    newAdminAddress: address
}

/// Source-only admin request that initiates a delayed Pool code upgrade; source uses a two-day cooldown.
struct (0x29be3423) StonfiRouterV2InitPoolCodeUpgrade {
    /// Caller-selected query id; source does not store it.
    queryId: uint64
    /// New pool code staged in temp-upgrade before finalization.
    newPoolCode: cell
}

/// Admin request that cancels a pending Router code upgrade.
struct (0x1f72111a) StonfiRouterV2CancelCodeUpgrade {
    /// Caller-selected query id; source does not inspect it after context parsing.
    queryId: uint64
}

/// Admin request that cancels a pending Router admin change.
struct (0x72d6b3b4) StonfiRouterV2CancelAdminUpgrade {
    /// Caller-selected query id; source does not inspect it after context parsing.
    queryId: uint64
}

/// Source-only admin request that cancels a pending Pool code upgrade.
struct (0x3d51269b) StonfiRouterV2CancelPoolCodeUpgrade {
    /// Caller-selected query id; source does not inspect it after context parsing.
    queryId: uint64
}

/// Admin request that finalizes matured Router code, admin, and Pool code upgrades.
struct (0x4e6707b7) StonfiRouterV2FinalizeUpgrades {
    /// Caller-selected query id; source does not inspect it after context parsing.
    queryId: uint64
}

/// Generic admin request that changes pool-specific parameters; concrete router variants use different tails.
struct (0x2b8b3b62) StonfiRouterV2SetParamsRaw {
    /// Caller-selected query id copied into the outgoing Pool parameter message.
    queryId: uint64
    /// Variant-specific tail for stableswap, weighted stableswap, or weighted constant product Routers.
    params: RemainingBitsAndRefs
}

/// StableSwap Router `set_params` request; shares opcode with other Router variants.
struct (0x2b8b3b62) StonfiRouterV2SetStableSwapParams {
    /// Caller-selected query id copied into the outgoing Pool parameter message.
    queryId: uint64
    /// New StableSwap amplification coefficient.
    newAmp: uint32
    /// Address of the Router's wallet of the first Jetton.
    leftJettonWallet: address
    /// Address of the Router's wallet of the second Jetton.
    rightJettonWallet: address
    /// Address where TON excesses are sent; `addr_none` is replaced with the message sender.
    excessesRecipient: address?
}

/// Referenced token-wallet data used by weighted Router `set_params`.
struct StonfiRouterV2WeightedSetParamsRefData {
    /// Address of the Router's wallet of the first Jetton.
    leftJettonWallet: address
    /// Address of the Router's wallet of the second Jetton.
    rightJettonWallet: address
    /// Address where TON excesses are sent; `addr_none` is replaced with the message sender.
    excessesRecipient: address?
}

/// Weighted StableSwap Router `set_params` request; shares opcode with other Router variants.
struct (0x2b8b3b62) StonfiRouterV2SetWeightedStableSwapParams {
    /// Caller-selected query id copied into the outgoing Pool parameter message.
    queryId: uint64
    /// New amplification value encoded as uint128.
    newAmp: uint128
    /// Optional new rate; source treats zero as "leave unchanged" in the Pool.
    newRate: uint128
    /// New weight for the selected side.
    newW: uint128
    /// Pool side wallet whose weight is being initialized.
    sideWallet: address
    /// Optional future rate setter address accepted by source with nofail workchain check.
    newSetter: address?
    /// Referenced Pool wallets and optional excess recipient.
    refData: Cell<StonfiRouterV2WeightedSetParamsRefData>
}

/// Weighted constant product Router `set_params` request; shares opcode with other Router variants.
struct (0x2b8b3b62) StonfiRouterV2SetWeightedConstProductParams {
    /// Caller-selected query id copied into the outgoing Pool parameter message.
    queryId: uint64
    /// New weight for the selected side.
    newW: uint128
    /// Pool side wallet whose weight is being initialized.
    sideWallet: address
    /// Referenced Pool wallets and optional excess recipient.
    refData: Cell<StonfiRouterV2WeightedSetParamsRefData>
}

/// Pool-originated callback that asks the Router to transfer Jettons to a user or continue a cross-swap.
struct (0x657b54f5) StonfiPayToV2 {
    /// Query id copied from the upstream swap/provide/burn/refund flow.
    queryId: uint64
    /// Receiver address for the outgoing Jetton transfer.
    toAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Original transaction sender used for cross-swap continuation.
    originalCaller: address
    /// Pool exit/status code reported with the transfer flow.
    exitCode: uint32
    /// Payload sent in the outgoing Jetton `transfer_notification`; may contain `cross_swap`.
    customPayload: cell?
    /// Referenced additional-data cell with forward gas, output amounts, and token wallets.
    additionalInfo: Cell<StonfiPayToV2AdditionalInfo>
}

/// Pool-originated callback that asks the Router to deposit referral fees into a Vault.
struct (0x63381632) StonfiPayVaultV2 {
    /// Query id copied from the upstream swap flow.
    queryId: uint64
    /// Referral-fee owner used to derive the target Vault.
    owner: address
    /// Address where TON excesses are sent after the Vault deposit.
    excessesAddress: address
    /// Referenced additional-data cell with referral-fee amounts and token wallet addresses.
    additionalInfo: Cell<StonfiPayVaultV2AdditionalInfo>
}

/// Vault-originated callback that asks the Router to transfer withdrawn referral fees to the owner.
struct (0x2100c922) StonfiVaultPayToV2 {
    /// Query id copied from the Vault withdrawal request.
    queryId: uint64
    /// Jetton amount in basic token units to transfer to `toAddress`.
    amountOut: coins
    /// Router-owned Jetton wallet address that sends the withdrawn fees.
    tokenAddress: address
    /// Receiver address for the withdrawn Jettons.
    toAddress: address
}

/// On-chain getter request asking the Router to derive a Pool address for two assets.
struct (0x2993ade0) StonfiRouterV2GetterPoolAddressRequest {
    /// Caller-selected query id copied into the async response.
    queryId: uint64
    /// Address of the Router's wallet of the first Jetton.
    token0: address
    /// Address of the Router's wallet of the second Jetton.
    token1: address
}

/// On-chain getter response containing the derived Pool address; shares opcode with the request.
struct (0x2993ade0) StonfiRouterV2GetterPoolAddressResponse {
    /// Query id copied from the async request.
    queryId: uint64
    /// Deterministically derived Pool address.
    poolAddress: address
}

/// Router-to-Pool `swap` message built after a valid Jetton transfer notification.
struct (0x6664de2a) StonfiSwapV2 {
    /// Query id copied from the user Jetton transfer notification.
    queryId: uint64
    /// User address reported by the notifying Jetton wallet.
    fromUser: address
    /// Amount credited as the first token input; one side is zero.
    leftAmount: coins
    /// Amount credited as the second token input; one side is zero.
    rightAmount: coins
    /// Original swap or cross-swap DexPayload ref forwarded to the Pool.
    dexPayload: Cell<StonfiSwapV2DexPayload>
}

/// Router-to-Pool `provide_lp` message built after a valid Jetton transfer notification.
struct (0x37c096df) StonfiProvideLpV2 {
    /// Query id copied from the user Jetton transfer notification.
    queryId: uint64
    /// User address reported by the notifying Jetton wallet.
    fromUser: address
    /// Amount credited as the first token input; one side may be zero.
    leftAmount: coins
    /// Amount credited as the second token input; one side may be zero.
    rightAmount: coins
    /// Original provide-liquidity DexPayload ref forwarded to the Pool.
    dexPayload: Cell<StonfiProvideLpV2DexPayload>
}

/// Router-to-Vault message that deposits a swap referral-fee amount into the derived Vault.
struct (0x0490f09b) StonfiDepositRefFeeV2 {
    /// Query id copied from the upstream Pool callback.
    queryId: uint64
    /// Referral-fee Jetton amount in basic token units deposited into the derived Vault.
    jettonAmount: coins
    /// Address where TON excesses are sent after the Vault reserves storage balance.
    excessesAddress: address
}

/// Router-to-Jetton-wallet TEP-74 transfer body used for swaps, refunds, LP mints, and Vault withdrawals.
struct (0x0f8a7ea5) StonfiRouterV2JettonTransfer {
    /// Query id copied from the upstream router flow.
    queryId: uint64
    /// Jetton amount in basic token units sent by the token wallet.
    amount: coins
    /// Owner address that receives the Jettons.
    destination: address
    /// Address where Jetton wallet excesses are sent.
    responseDestination: address
    /// Optional payload attached to the transfer.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner with the transfer notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Router-to-Pool fee update body emitted from admin `set_fees`.
struct (0x75930d63) StonfiRouterV2PoolInternalSetFees {
    /// Query id copied from the admin `set_fees` request.
    queryId: uint64
    /// New liquidity-pool fee ratio.
    newLpFee: uint16
    /// New protocol fee ratio.
    newProtocolFee: uint16
    /// Address that receives protocol fees.
    newProtocolFeeAddress: address
    /// Address where TON excesses are sent after Router-side `addr_none` substitution.
    excessesAddress: address
}

/// Router-to-Pool `reset_gas` body emitted from admin `reset_pool_gas`.
struct (0x29d22935) StonfiRouterV2PoolResetGas {
    /// Query id copied from the admin `reset_pool_gas` request.
    queryId: uint64
    /// Address where TON excesses are sent after Router-side `addr_none` substitution.
    excessesRecipient: address
}

/// Router-to-Pool status toggle body emitted from admin `update_pool_status`.
struct (0x62752512) StonfiRouterV2PoolInternalUpdateStatus {
    /// Query id copied from the admin `update_pool_status` request.
    queryId: uint64
    /// Address where TON excesses are sent after Router-side `addr_none` substitution.
    excessesRecipient: address
}

/// Source-only Router-to-Pool code update body emitted from admin `update_pool_code`.
struct (0x355d097e) StonfiRouterV2PoolInternalUpdatePoolCode {
    /// Query id copied from the admin `update_pool_code` request.
    queryId: uint64
    /// Pool code cell staged in Router storage and forwarded to the Pool.
    upgradePoolCode: cell
}

/// Generic Router-to-Pool parameter update body; concrete Pool variants use different tails.
struct (0xf163444a) StonfiRouterV2PoolInternalSetParamsRaw {
    /// Query id copied from the admin `set_params` request.
    queryId: uint64
    /// Variant-specific tail for stableswap, weighted stableswap, or weighted constant product Pools.
    params: RemainingBitsAndRefs
}

/// Router-to-StableSwap-Pool parameter update emitted from admin `set_params`.
struct (0xf163444a) StonfiRouterV2PoolInternalSetStableSwapParams {
    /// Query id copied from the admin `set_params` request.
    queryId: uint64
    /// Address where TON excesses are sent after Router-side `addr_none` substitution.
    excessesAddress: address
    /// New StableSwap amplification coefficient.
    newAmp: uint32
}

/// Referenced optional setter address for weighted StableSwap Pool parameter updates.
struct StonfiRouterV2PoolInternalWeightedStableSwapParamsAdditionalData {
    /// New rate setter address forwarded to the Pool.
    newSetterAddress: address?
}

/// Router-to-WeightedStableSwap-Pool parameter update emitted from admin `set_params`.
struct (0xf163444a) StonfiRouterV2PoolInternalSetWeightedStableSwapParams {
    /// Query id copied from the admin `set_params` request.
    queryId: uint64
    /// Address where TON excesses are sent after Router-side `addr_none` substitution.
    excessesAddress: address
    /// Pool side wallet whose weight is being initialized.
    sideWallet: address
    /// New amplification value encoded as uint128.
    newAmp: uint128
    /// Optional new rate; zero means "leave unchanged" in the Pool source.
    newRate: uint128
    /// New weight for the selected side.
    newW: uint128
    /// Referenced setter-address cell.
    additionalData: Cell<StonfiRouterV2PoolInternalWeightedStableSwapParamsAdditionalData>
}

/// Router-to-WeightedConstProduct-Pool parameter update emitted from admin `set_params`.
struct (0xf163444a) StonfiRouterV2PoolInternalSetWeightedConstProductParams {
    /// Query id copied from the admin `set_params` request.
    queryId: uint64
    /// Address where TON excesses are sent after Router-side `addr_none` substitution.
    excessesAddress: address
    /// Pool side wallet whose weight is being initialized.
    sideWallet: address
    /// New weight for the selected side.
    newW: uint128
}

/// Internal message bodies accepted by STON.fi Router v2.
type StonfiRouterV2IncomingMessage =
    | StonfiRouterV2JettonTransferNotification
    | PtonResetGas
    | StonfiRouterV2UpdateStatus
    | StonfiRouterV2SetFees
    | StonfiRouterV2ResetPoolGas
    | StonfiRouterV2UpdatePoolStatus
    | StonfiRouterV2UpdatePoolCode
    | StonfiRouterV2InitCodeUpgrade
    | StonfiRouterV2InitAdminUpgrade
    | StonfiRouterV2InitPoolCodeUpgrade
    | StonfiRouterV2CancelCodeUpgrade
    | StonfiRouterV2CancelAdminUpgrade
    | StonfiRouterV2CancelPoolCodeUpgrade
    | StonfiRouterV2FinalizeUpgrades
    | StonfiRouterV2SetParamsRaw
    | StonfiPayToV2
    | StonfiPayVaultV2
    | StonfiVaultPayToV2
    | StonfiRouterV2GetterPoolAddressRequest

/// Internal message bodies emitted by STON.fi Router v2.
type StonfiRouterV2OutgoingMessage =
    | StonfiSwapV2
    | StonfiProvideLpV2
    | StonfiDepositRefFeeV2
    | StonfiRouterV2JettonTransfer
    | StonfiRouterV2PoolInternalSetFees
    | StonfiRouterV2PoolResetGas
    | StonfiRouterV2PoolInternalUpdateStatus
    | StonfiRouterV2PoolInternalUpdatePoolCode
    | StonfiRouterV2PoolInternalSetParamsRaw
    | StonfiRouterV2GetterPoolAddressResponse

/// Structured result returned by `get_router_data`, the current Router state getter.
struct GetRouterDataReply {
    /// Router id returned as a TVM stack integer.
    id: uint64
    /// Router type string: `constant_product`, `stableswap`, `weighted_stableswap`, or `weighted_const_product`.
    dexType: string
    /// True when `transfer_notification` operations are locked.
    isLocked: bool
    /// Address of the contract admin account.
    adminAddress: address
    /// Raw upgrade-state cell; zero deadlines indicate that no upgrade is pending.
    tempUpgrade: cell
    /// Code of the Router's liquidity Pool contract.
    poolCode: cell
    /// Code of the LP wallet contract.
    jettonLpWalletCode: cell
    /// Code of the LP account contract.
    lpAccountCode: cell
    /// Code of the referral-fee Vault contract.
    vaultCode: cell
}

/// Structured result returned by `get_router_version`.
struct GetRouterVersionReply {
    /// Major router version constant.
    major: uint32
    /// Minor router version constant.
    minor: uint32
    /// Additional version information, for example `release`.
    development: string
}

/// Return the deterministic Pool address for a pair of Router-owned Jetton wallets.
get fun get_pool_address(token0: address, token1: address): address {
    throw 0;
}

/// Return the deterministic referral-fee Vault address for a Vault owner and Router-owned Jetton wallet.
get fun get_vault_address(user: address, token: address): address {
    throw 0;
}

/// Return Router id, type, lock/admin state, upgrade state, and contract code cells.
get fun get_router_data(): GetRouterDataReply {
    throw 0;
}

/// Return the finalized Pool code cell staged for Pool code updates.
get fun get_upgraded_pool_code(): cell {
    throw 0;
}

/// Return major, minor, and development version constants compiled into the Router.
get fun get_router_version(): GetRouterVersionReply {
    throw 0;
}
