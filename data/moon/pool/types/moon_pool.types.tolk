/// Moon.cx constant-product pool and LP Jetton master interface.
contract MoonPool {
    author: "Moon.cx"
    version: "f027fcc0"
    description: "Moon.cx pool for swaps, two-asset liquidity accounting, and LP Jetton minting and burning."
    storage: MoonPoolStorage
    storageAtDeployment: MoonPoolDeploymentStorage
    incomingMessages: MoonPoolIncomingMessage
    outgoingMessages: MoonPoolOutgoingMessage
    thrownErrors: MoonPoolErrors
    forceAbiExport: MoonPoolSwapParams
        | MoonPoolNextPayload
        | MoonPoolBalances
        | MoonPoolAssetsAndContent
        | MoonPoolAssetAmount
        | MoonPoolSwapForwardPayload
        | MoonPoolDepositLiquidityForwardPayload
        | MoonPoolBoostForwardPayload
        | MoonPoolJettonForwardPayloadInline
        | MoonPoolJettonForwardPayloadInRef
}

/// Pool state present before the one-time initialization message is accepted.
struct MoonPoolDeploymentStorage {
    /// Factory or administrator allowed to initialize and configure the pool.
    adminAddress: address
    /// Asset 1 Jetton master, or `addr_none` when asset 1 is native GRAM.
    asset1Id: address?
    /// Asset 2 Jetton master, or `addr_none` when asset 2 is native GRAM.
    asset2Id: address?
}

/// Initialized persistent Moon.cx pool state.
struct MoonPoolStorage {
    /// Factory or administrator allowed to collect fees and update configuration.
    adminAddress: address
    /// Pool wallet for asset 1, or `addr_none` when asset 1 is native GRAM.
    asset1Wallet: address?
    /// Pool wallet for asset 2, or `addr_none` when asset 2 is native GRAM.
    asset2Wallet: address?
    /// Swap fee deducted from input amounts in basis points.
    swapFeeBps: uint8
    /// Share of swap output accumulated for the protocol in basis points.
    protocolFeeBps: uint8
    /// Share of swap output sent to a referral address in basis points.
    referralFeeBps: uint8
    /// Total supply of Moon Pool LP Jettons.
    lpTotalSupply: coins
    /// Referenced reserves and collected protocol-fee balances.
    balances: Cell<MoonPoolBalances>
    /// Code used to derive and deploy LP Jetton wallets.
    lpWalletCode: cell
    /// Code used to derive per-user liquidity deposit accounts.
    lpAccountCode: cell
    /// Referenced asset identifiers and LP Jetton metadata content.
    assetsAndContent: Cell<MoonPoolAssetsAndContent>
}

/// Pool reserves and protocol fees stored in asset order.
struct MoonPoolBalances {
    /// Current reserve of asset 1 in its smallest units.
    asset1Reserve: coins
    /// Current reserve of asset 2 in its smallest units.
    asset2Reserve: coins
    /// Collected protocol fees denominated in asset 1.
    asset1ProtocolFees: coins
    /// Collected protocol fees denominated in asset 2.
    asset2ProtocolFees: coins
}

/// Asset identifiers and LP Jetton metadata retained by the pool.
struct MoonPoolAssetsAndContent {
    /// Asset 1 Jetton master, or `addr_none` for native GRAM.
    asset1Id: address?
    /// Asset 2 Jetton master, or `addr_none` for native GRAM.
    asset2Id: address?
    /// TEP-64 metadata content for the pool LP Jetton.
    lpJettonContent: cell
}

/// Asset identifier and amount cell accepted by pool quote getters.
struct MoonPoolAssetAmount {
    /// Jetton master address, or `addr_none` for native GRAM.
    assetId: address?
    /// Amount of the selected asset in its smallest units.
    amount: coins
}

/// Optional continuation selected after a swap succeeds or fails.
struct MoonPoolNextPayload {
    /// Contract that receives the continuation message.
    recipient: address?
    /// Optional referenced continuation body; an absent value means an empty body.
    payload: Cell<RemainingBitsAndRefs>?
}

/// Swap limits, routing addresses, and optional success/failure continuations.
struct MoonPoolSwapParams {
    /// Minimum accepted output amount; zero disables this limit.
    minOut: coins
    /// Unix deadline; zero disables expiration checking.
    deadline: uint64
    /// Address receiving unused GRAM, or `addr_none` to use the swap sender.
    excessAddress: address?
    /// Optional referral address that receives the configured referral fee.
    referralAddress: address?
    /// Optional continuation sent after a successful swap.
    nextFulfill: Cell<MoonPoolNextPayload>?
    /// Optional continuation sent after a rejected swap.
    nextReject: Cell<MoonPoolNextPayload>?
}

/// Inline TEP-74 forward-payload variant.
struct (0b0) MoonPoolJettonForwardPayloadInline {
    /// Payload bits and references stored inline after the Either selector.
    value: RemainingBitsAndRefs
}

/// Referenced TEP-74 forward-payload variant.
struct (0b1) MoonPoolJettonForwardPayloadInRef {
    /// Referenced payload cell stored after the Either selector.
    value: Cell<RemainingBitsAndRefs>
}

/// Observed one-time pool initialization message accepted by deployment storage.
struct (0x6fd43893) MoonPoolInitialize {
    /// Query identifier copied into the initial LP mint.
    queryId: uint64
    /// Pool wallet for asset 1, or `addr_none` for native GRAM.
    asset1Wallet: address?
    /// Pool wallet for asset 2, or `addr_none` for native GRAM.
    asset2Wallet: address?
    /// Initial swap fee in basis points.
    swapFeeBps: uint8
    /// Initial protocol-fee share in basis points.
    protocolFeeBps: uint8
    /// Initial referral-fee share in basis points.
    referralFeeBps: uint8
    /// Initial reserves and zeroed or preloaded fee balances.
    balances: Cell<MoonPoolBalances>
    /// LP Jetton wallet implementation code.
    lpWalletCode: cell
    /// Per-user liquidity deposit account implementation code.
    lpAccountCode: cell
    /// Asset identifiers and LP Jetton metadata content.
    assetsAndContent: Cell<MoonPoolAssetsAndContent>
}

/// Direct native-asset Moon.cx swap request.
struct (0xb37a900b) MoonPoolSwap {
    /// Query identifier propagated to downstream transfers and callbacks.
    queryId: uint64
    /// Native asset amount supplied by the caller.
    amount: coins
    /// Swap limit, deadline, referral, and continuation parameters.
    swapParams: MoonPoolSwapParams
}

/// Moon swap payload carried inside a Jetton transfer notification.
struct (0xb37a900b) MoonPoolSwapForwardPayload {
    /// Swap limit, deadline, referral, and continuation parameters.
    swapParams: MoonPoolSwapParams
}

/// Direct native-asset liquidity deposit record request.
struct (0xb31db781) MoonPoolDepositLiquidity {
    /// Query identifier propagated to the per-user LP account.
    queryId: uint64
    /// Minimum LP Jetton amount accepted by the depositor.
    minLpOut: coins
}

/// Liquidity deposit payload carried inside a Jetton transfer notification.
struct (0xb31db781) MoonPoolDepositLiquidityForwardPayload {
    /// Minimum LP Jetton amount accepted by the depositor.
    minLpOut: coins
}

/// Adds native GRAM to the pool reserve without minting LP Jettons.
struct (0x96aa1586) MoonPoolBoost {
    /// Query identifier used by Jetton notification and excess flows.
    queryId: uint64
}

/// Pool boost payload carried inside a Jetton transfer notification.
struct (0x96aa1586) MoonPoolBoostForwardPayload {
    /// Address receiving excess GRAM after the reserve is increased.
    responseAddress: address
}

/// Per-user LP account callback that commits a matched two-asset deposit.
struct (0x6b1b8a3f) MoonPoolProvideLiquidity {
    /// Query identifier propagated to mint and result messages.
    queryId: uint64
    /// Deposited amount of asset 1.
    amount1: coins
    /// Deposited amount of asset 2.
    amount2: coins
    /// Liquidity owner receiving newly minted LP Jettons.
    userAddress: address
    /// Minimum accepted LP Jetton amount.
    minLpAmount: coins
}

/// Per-user LP account callback that cancels unmatched deposits.
struct (0xc30a6fa3) MoonPoolCancelDeposit {
    /// Query identifier propagated to payout messages.
    queryId: uint64
    /// Asset 1 amount returned to the user.
    amount1: coins
    /// Asset 2 amount returned to the user.
    amount2: coins
    /// Liquidity owner receiving the returned assets.
    userAddress: address
}

/// Standard LP Jetton burn notification used to withdraw proportional reserves.
struct (0x7bdd97de) MoonPoolLpBurnNotification {
    /// Query identifier propagated to withdrawal payouts.
    queryId: uint64
    /// LP Jetton amount burned by the owner.
    lpAmount: coins
    /// Owner receiving the withdrawn pool assets.
    ownerAddress: address
    /// Optional address notified after both payouts are sent.
    responseAddress: address?
}

/// Standard Jetton transfer notification carrying Moon forward payloads.
struct (0x7362d09c) MoonPoolJettonTransferNotification {
    /// Query identifier propagated through swap, deposit, or boost handling.
    queryId: uint64
    /// Jetton amount delivered to the pool wallet.
    amount: coins
    /// Previous Jetton owner that initiated the transfer.
    senderAddress: address
    /// Inline or referenced Moon swap, deposit, or boost payload.
    @abi.clientType(MoonPoolJettonForwardPayloadInline | MoonPoolJettonForwardPayloadInRef)
    forwardPayload: RemainingBitsAndRefs
}

/// Administrator command that transfers accumulated protocol fees.
struct (0x040beadd) MoonPoolCollectFees {
    /// Query identifier propagated to transfers and native payout callbacks.
    queryId: uint64
    /// Owner address receiving both collected asset balances.
    destination: address
}

/// Native protocol-fee payout emitted by the administrator collection flow.
struct (0x040beadd) MoonPoolCollectFeesPayout {
    /// Query identifier copied from the collection command.
    queryId: uint64
}

/// Administrator command that changes all three fee parameters.
struct (0x0e9c14a7) MoonPoolSetFees {
    /// Query identifier retained by the control message.
    queryId: uint64
    /// Replacement swap fee in basis points.
    swapFeeBps: uint8
    /// Replacement protocol-fee share in basis points.
    protocolFeeBps: uint8
    /// Replacement referral-fee share in basis points.
    referralFeeBps: uint8
}

/// Administrator command that replaces LP Jetton metadata content.
struct (0x4be2ac1e) MoonPoolSetContent {
    /// Query identifier retained by the control message.
    queryId: uint64
    /// Replacement TEP-64 metadata content cell.
    lpJettonContent: cell
}

/// Administrator command that replaces the pool code cell.
struct (0xe2689830) MoonPoolUpgradeCode {
    /// Query identifier retained by the control message.
    queryId: uint64
    /// Replacement executable code cell.
    newCode: cell
}

/// Standard excess-value body accepted as a no-op and emitted by pool flows.
struct (0xd53276db) MoonPoolExcess {
    /// Query identifier of the completed operation.
    queryId: uint64
}

/// Internal message bodies accepted by the exact deployed Moon Pool revision.
type MoonPoolIncomingMessage =
    | MoonPoolInitialize
    | MoonPoolSwap
    | MoonPoolDepositLiquidity
    | MoonPoolBoost
    | MoonPoolProvideLiquidity
    | MoonPoolCancelDeposit
    | MoonPoolLpBurnNotification
    | MoonPoolJettonTransferNotification
    | MoonPoolCollectFees
    | MoonPoolSetFees
    | MoonPoolSetContent
    | MoonPoolUpgradeCode
    | MoonPoolExcess

/// Standard LP Jetton internal transfer used by the initial and later mint paths.
struct (0x178d4519) MoonPoolJettonInternalTransfer {
    /// Query identifier copied from the liquidity operation.
    queryId: uint64
    /// LP Jetton amount minted or transferred.
    amount: coins
    /// Previous LP Jetton owner; the pool uses its own address while minting.
    fromAddress: address
    /// Optional address receiving excess GRAM.
    responseAddress: address?
    /// Nanograms forwarded with the destination wallet notification.
    forwardTonAmount: coins
    /// Inline or referenced forward payload.
    @abi.clientType(MoonPoolJettonForwardPayloadInline | MoonPoolJettonForwardPayloadInRef)
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton transfer emitted to an asset wallet.
struct (0x0f8a7ea5) MoonPoolJettonTransfer {
    /// Query identifier copied from the triggering operation.
    queryId: uint64
    /// Jetton amount transferred from the pool wallet.
    amount: coins
    /// Owner address receiving the transferred Jettons.
    destination: address
    /// Optional address receiving excess GRAM from the wallet.
    responseDestination: address?
    /// Optional application payload passed to the destination wallet.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// Nanograms forwarded with the destination wallet notification.
    forwardTonAmount: coins
    /// Inline or referenced Moon result or arbitrary continuation payload.
    @abi.clientType(MoonPoolJettonForwardPayloadInline | MoonPoolJettonForwardPayloadInRef)
    forwardPayload: RemainingBitsAndRefs
}

/// Successful swap callback; custom continuation bytes may follow the opcode.
struct (0xcb7f38d6) MoonPoolSwapSucceed {
    /// Optional callback tail supplied by the swap caller.
    tail: RemainingBitsAndRefs
}

/// Failed swap callback; custom continuation bytes may follow the opcode.
struct (0xc47c1f57) MoonPoolSwapFailed {
    /// Optional callback tail supplied by the swap caller.
    tail: RemainingBitsAndRefs
}

/// Successful two-asset liquidity provision callback.
struct (0x737b4eb6) MoonPoolProvideLiquiditySucceed {}

/// Failed liquidity provision callback in either refund form.
struct (0x7daf7060) MoonPoolProvideLiquidityFailed {
    /// Optional query and refund amounts used by the LP-account callback form.
    tail: RemainingBitsAndRefs
}

/// Records one side of a liquidity deposit in the per-user LP account.
struct (0xbaaa2c1b) MoonPoolDepositRecord {
    /// Query identifier shared by both deposit sides.
    queryId: uint64
    /// Asset side: `1` for asset 1 and `2` for asset 2.
    assetNumber: uint8
    /// Amount deposited for this asset side.
    depositAmount: coins
    /// Minimum accepted LP Jetton amount for the combined deposit.
    minLpAmount: coins
}

/// Native asset payout emitted during LP withdrawal.
struct (0x90d3b4ad) MoonPoolWithdrawLiquidityPayout {
    /// Query identifier copied from the LP burn notification.
    queryId: uint64
}

/// Completion notification emitted after both withdrawal payouts.
struct (0xff86f067) MoonPoolWithdrawLiquidityNotify {
    /// Query identifier copied from the LP burn notification.
    queryId: uint64
}

/// Native asset refund emitted when a pending deposit is cancelled.
struct (0x16b463b4) MoonPoolCancelDepositPayout {
    /// Query identifier copied from the cancellation request.
    queryId: uint64
}

/// Native referral-fee payout emitted for a swap with a referral address.
struct (0x68b13fc5) MoonPoolReferralPayout {
    /// Query identifier copied from the swap request.
    queryId: uint64
}

/// Body-bearing messages emitted by direct and nested Moon Pool send sites.
type MoonPoolOutgoingMessage =
    | MoonPoolJettonInternalTransfer
    | MoonPoolJettonTransfer
    | MoonPoolSwapSucceed
    | MoonPoolSwapFailed
    | MoonPoolProvideLiquiditySucceed
    | MoonPoolProvideLiquidityFailed
    | MoonPoolDepositRecord
    | MoonPoolWithdrawLiquidityPayout
    | MoonPoolWithdrawLiquidityNotify
    | MoonPoolCancelDepositPayout
    | MoonPoolReferralPayout
    | MoonPoolCollectFeesPayout
    | MoonPoolExcess

/// Asset and reserve tuple returned by `get_reserves`.
struct MoonPoolReservesReply {
    /// Asset 1 Jetton master, or `addr_none` for native GRAM.
    asset1Id: any_address
    /// Current reserve of asset 1.
    asset1Reserve: int
    /// Asset 2 Jetton master, or `addr_none` for native GRAM.
    asset2Id: any_address
    /// Current reserve of asset 2.
    asset2Reserve: int
}

/// Asset identifiers returned by `get_assets`.
struct MoonPoolAssetsReply {
    /// Asset 1 Jetton master, or `addr_none` for native GRAM.
    asset1Id: any_address
    /// Asset 2 Jetton master, or `addr_none` for native GRAM.
    asset2Id: any_address
}

/// Pool wallet addresses returned by `get_wallets`.
struct MoonPoolWalletsReply {
    /// Pool wallet for asset 1, or `addr_none` for native GRAM.
    asset1Wallet: any_address
    /// Pool wallet for asset 2, or `addr_none` for native GRAM.
    asset2Wallet: any_address
}

/// Fee parameters returned by `get_fees`.
struct MoonPoolFeesReply {
    /// Swap fee in basis points.
    swapFeeBps: int
    /// Protocol-fee share in basis points.
    protocolFeeBps: int
    /// Referral-fee share in basis points.
    referralFeeBps: int
}

/// Collected protocol fees returned by `get_collected_fees`.
struct MoonPoolCollectedFeesReply {
    /// Collected protocol fees denominated in asset 1.
    asset1Fees: int
    /// Collected protocol fees denominated in asset 2.
    asset2Fees: int
}

/// Proportional reserve amounts returned by `get_estimated_lp_burn`.
struct MoonPoolEstimatedLpBurnReply {
    /// Asset 1 Jetton master, or `addr_none` for native GRAM.
    asset1Id: any_address
    /// Estimated asset 1 amount returned for the burned LP amount.
    asset1Amount: int
    /// Asset 2 Jetton master, or `addr_none` for native GRAM.
    asset2Id: any_address
    /// Estimated asset 2 amount returned for the burned LP amount.
    asset2Amount: int
}

/// Swap quote returned by `get_estimated_swap_out`.
struct MoonPoolEstimatedSwapOutReply {
    /// Opposite pool asset returned by the swap.
    outputAssetId: any_address
    /// Estimated output amount after all configured fees.
    outputAmount: int
}

/// Standard LP Jetton master data returned by `get_jetton_data`.
struct MoonPoolJettonDataReply {
    /// Total LP Jetton supply.
    totalSupply: int
    /// True because the pool mints LP Jettons for valid liquidity deposits.
    mintable: bool
    /// Pool address reported as the LP Jetton administrator.
    adminAddress: any_address
    /// TEP-64 LP Jetton metadata content.
    jettonContent: cell
    /// LP Jetton wallet implementation code.
    jettonWalletCode: cell
}

/// Return both asset identifiers and current reserves.
get fun get_reserves(): MoonPoolReservesReply {
    throw 0;
}

/// Return both pool asset identifiers.
get fun get_assets(): MoonPoolAssetsReply {
    throw 0;
}

/// Return both pool asset-wallet addresses.
get fun get_wallets(): MoonPoolWalletsReply {
    throw 0;
}

/// Return swap, protocol, and referral fee parameters.
get fun get_fees(): MoonPoolFeesReply {
    throw 0;
}

/// Return accumulated protocol-fee balances for both assets.
get fun get_collected_fees(): MoonPoolCollectedFeesReply {
    throw 0;
}

/// Return the total supply of LP Jettons.
get fun get_lp_total(): int {
    throw 0;
}

/// Derive the per-user Moon liquidity deposit account address.
get fun get_lp_account(userAddress: address): any_address {
    throw 0;
}

/// Derive the standard LP Jetton wallet address for an owner.
get fun get_wallet_address(ownerAddress: address): any_address {
    throw 0;
}

/// Estimate both asset payouts for an LP Jetton burn amount.
get fun get_estimated_lp_burn(lpAmount: int): MoonPoolEstimatedLpBurnReply {
    throw 0;
}

/// Estimate LP Jettons minted for two cells containing asset id and amount.
get fun get_estimated_lp(asset1Amount: cell, asset2Amount: cell): int {
    throw 0;
}

/// Estimate swap output for a cell containing input asset id and amount.
get fun get_estimated_swap_out(assetAndAmount: cell): MoonPoolEstimatedSwapOutReply {
    throw 0;
}

/// Return standard LP Jetton master data.
get fun get_jetton_data(): MoonPoolJettonDataReply {
    throw 0;
}

/// Return the complete serialized pool data cell.
get fun get_pool(): cell {
    throw 0;
}

/// Exit codes thrown by the exact Moon Pool revision.
enum MoonPoolErrors {
    /// Sender is not the administrator, expected wallet, or derived LP account.
    InvalidSender = 300
    /// A native-liquidity operation was requested for a non-native asset side.
    NativeLiquidityUnavailable = 420
    /// Attached GRAM value cannot cover the operation gas budget.
    InsufficientValue = 500
    /// Native deposit or boost value is below the accepted minimum.
    DepositValueTooSmall = 510
    /// Liquidity amounts, resulting reserves, or LP payout are invalid.
    InvalidLiquidityAmounts = 666
    /// Amount or fee parameter is outside its accepted range.
    InvalidAmountOrFee = 700
    /// A native swap or boost was requested for a non-native asset side.
    NativeSwapUnavailable = 702
    /// Asset identifier or message opcode is unsupported.
    UnsupportedAssetOrOperation = 900
}
