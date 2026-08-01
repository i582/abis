/// Megaton Finance constant-product Exchange and LP Jetton master.
contract MegatonExchange {
    author: "Ozys / Megaton Finance"
    version: "legacy"
    description: "Megaton Exchange manages a two-jetton pool, LP supply, liquidity mining, and deterministic LP wallets."
    storage: MegatonExchangeStorage
    incomingMessages: MegatonExchangeIncomingMessage
    outgoingMessages: MegatonExchangeOutgoingMessage
    emittedEvents: MegatonExchangeEvent
    thrownErrors: MegatonExchangeErrors
}

/// Persistent Exchange state stored in the root data cell.
struct MegatonExchangeStorage {
    /// Total issued LP Jetton supply.
    totalSupply: coins
    /// Swap-fee value used with a denominator of 10000.
    swapFee: coins
    /// Minimum LP position retained when a provider partially exits.
    minimumLpAmount: coins
    /// Whether liquidity and mining operations are stopped.
    stopped: bool
    /// Number of entries in the LP-provider dictionary.
    liquidityProviderCount: uint32
    /// Maximum permitted LP-provider count.
    maxLiquidityProviderCount: uint32
    /// Administrator authorized to update pool configuration.
    adminAddress: address
    /// Megaton Router authorized to initialize and coordinate the pool.
    routerAddress: address
    /// Referenced reserves, token identities, wallets, and mining state.
    poolState: Cell<MegatonExchangePoolState>
    /// Referenced liquidity-provider and operation-fee dictionaries.
    dictionaries: Cell<MegatonExchangeDictionaries>
    /// TEP-64 LP Jetton metadata returned by `get_jetton_data`.
    content: cell
    /// LP Jetton wallet code used for deterministic wallet derivation.
    walletCode: cell
}

/// Pool reserves and mining state stored in the first root reference.
struct MegatonExchangePoolState {
    /// Accounted balance of token A.
    tokenABalance: coins
    /// Accounted balance of token B.
    tokenBBalance: coins
    /// Pending token A amount awaiting pool accounting.
    tokenAPendingBalance: coins
    /// Pending token B amount awaiting pool accounting.
    tokenBPendingBalance: coins
    /// Token A and token B master addresses.
    tokenMasters: Cell<MegatonExchangeTokenPair>
    /// Exchange-owned token A and token B wallet addresses.
    tokenWallets: Cell<MegatonExchangeTokenPair>
    /// Mining emission schedule.
    miningSchedule: Cell<MegatonExchangeMiningSchedule>
    /// Accumulated mining index and schedule-chain state.
    miningState: Cell<MegatonExchangeMiningState>
}

/// Ordered token-address pair used for masters and wallets.
struct MegatonExchangeTokenPair {
    /// Token A address.
    tokenA: address
    /// Token B address.
    tokenB: address
}

/// Exact-width mining schedule stored by the deployed Exchange code.
struct MegatonExchangeMiningSchedule {
    /// Total mining amount cap.
    miningAmount: uint256
    /// Mining emission amount for the current schedule.
    datetimeAmount: uint256
    /// Unix time from which the schedule can emit rewards.
    minableTime: uint64
    /// Half-life duration used by the emission function.
    halfLife: uint64
}

/// Mining accumulator and referenced rate-transition chain.
struct MegatonExchangeMiningState {
    /// Last computed mining index.
    lastIndex: uint256
    /// Last accumulated mined amount.
    lastMined: uint256
    /// Linked rate schedule encoded as `uint32, uint64, Maybe ^next` nodes.
    miningRateCell: cell
}

/// Dictionaries stored together in the second root reference.
struct MegatonExchangeDictionaries {
    /// LP provider records keyed by the 256-bit account hash.
    liquidityProviders: map<uint256, MegatonExchangeLiquidityProvider>
    /// Required attached-value amounts keyed by operation opcode.
    operationFees: map<uint32, coins>
}

/// Per-provider liquidity and mining accounting record.
struct MegatonExchangeLiquidityProvider {
    /// LP amount owned by the provider.
    lpAmount: coins
    /// Accumulated reward amount not yet claimed.
    rewardAmount: coins
    /// Mining index at the provider's last accounting update.
    lastIndex: uint256
}

/// Router initialization of token identities, supply, limits, and mining schedule.
struct (0x53370e2e) MegatonExchangeInitialize {
    /// Router-selected correlation id.
    queryId: uint64
    /// Initial LP Jetton supply.
    totalSupply: coins
    /// Initial maximum provider count.
    maxLiquidityProviderCount: uint32
    /// Exchange-owned token A wallet.
    tokenAWalletAddress: address
    /// Exchange-owned token B wallet.
    tokenBWalletAddress: address
    /// Initial mining schedule.
    miningSchedule: Cell<MegatonExchangeMiningSchedule>
}

/// Token-wallet callback that supplies both assets and requests LP minting.
struct (0xcf3eede9) MegatonExchangeAddLiquidity {
    /// Correlation id copied to refunds and LP minting.
    queryId: uint64
    /// Liquidity provider that receives LP tokens.
    ownerAddress: address
    /// Token A amount delivered to the pool.
    tokenAAmount: coins
    /// Token B amount delivered to the pool.
    tokenBAmount: coins
    /// Minimum token A amount that may be consumed.
    minimumTokenAAmount: coins
    /// Minimum token B amount that may be consumed.
    minimumTokenBAmount: coins
}

/// Optional minimum asset amounts attached to an LP burn.
struct MegatonExchangeBurnMinimumAmounts {
    /// Minimum token A payout.
    minimumTokenAAmount: coins
    /// Minimum token B payout.
    minimumTokenBAmount: coins
}

/// LP-wallet burn request used to withdraw both pool assets.
struct (0x595f07bc) MegatonExchangeBurnLiquidity {
    /// Correlation id copied to payouts and burn accounting.
    queryId: uint64
    /// LP amount requested for burning.
    lpAmount: coins
    /// Optional minimum token A and token B payouts.
    minimumAmounts: Cell<MegatonExchangeBurnMinimumAmounts>?
}

/// Router-authorized full withdrawal for a provider.
struct (0x462e8d07) MegatonExchangeRouterBurnLiquidity {
    /// Router-selected correlation id.
    queryId: uint64
    /// Provider whose entire LP position is withdrawn.
    ownerAddress: address
}

/// TEP-89 request for the deterministic LP wallet address of an owner.
struct (0x2c76b973) MegatonExchangeProvideWalletAddress {
    /// Correlation id copied to the response.
    queryId: uint64
    /// Owner whose deterministic LP wallet is requested.
    ownerAddress: address
    /// Whether to include the owner address in a referenced response cell.
    includeOwnerAddress: bool
}

/// LP-wallet transfer callback carrying the original owner and remaining payload.
struct (0x0f8a7ea5) MegatonExchangeLpTransferCallback {
    /// Correlation id copied through the LP transfer flow.
    queryId: uint64
    /// LP amount transferred.
    amount: coins
    /// Recipient provider address.
    recipientAddress: address
    /// Response destination used by the resulting LP-wallet transfer.
    responseDestination: address?
    /// Nanotons forwarded to the recipient LP wallet.
    forwardTonAmount: coins
    /// Referenced original-owner address used to authenticate the sending LP wallet.
    originalOwner: Cell<address>
    /// Remaining payload forwarded without interpretation.
    forwardPayload: RemainingBitsAndRefs
}

/// Token-wallet notification used for swaps and routed token delivery.
struct (0x7362d09c) MegatonExchangeSwapNotification {
    /// Correlation id copied to token transfers and swap events.
    queryId: uint64
    /// Input token amount.
    amount: coins
    /// Original token sender or Router address.
    senderAddress: address
    /// Optional branch-specific swap parameters.
    swapPayload: cell?
}

/// Provider request to account and claim newly accrued mining rewards.
struct (0x6b14cfe1) MegatonExchangeClaimRewards {
    /// Correlation id copied to reward delivery and events.
    queryId: uint64
}

/// Request forwarded to the deterministic LP wallet for the same owner.
struct (0x32139810) MegatonExchangeLpWalletRequest {
    /// Correlation id copied to the LP wallet.
    queryId: uint64
}

/// LP-wallet callback that releases a pending token amount.
struct (0xbf1461f8) MegatonExchangeReleasePendingTokens {
    /// Correlation id copied to the token-wallet transfer.
    queryId: uint64
    /// Pending amount to release.
    amount: coins
    /// Token master selecting token A or token B.
    tokenMasterAddress: address
    /// Owner used to authenticate the sending LP wallet.
    ownerAddress: address
}

/// Router update of the current and next mining-rate schedule nodes.
struct (0x70ae1f34) MegatonExchangeUpdateMiningRate {
    /// Router-selected correlation id.
    queryId: uint64
    /// Next rate numerator.
    miningRate: uint32
    /// Unix time at which the next rate starts.
    startsAt: uint64
}

/// Router update of the total mining amount cap.
struct (0x20b88d2e) MegatonExchangeSetMiningAmount {
    /// Router-selected correlation id.
    queryId: uint64
    /// Replacement total mining amount cap.
    miningAmount: uint256
}

/// Router update of the minimum retained LP position.
struct (0x5cbfb251) MegatonExchangeSetMinimumLpAmount {
    /// Router-selected correlation id.
    queryId: uint64
    /// Replacement minimum retained LP amount.
    minimumLpAmount: uint256
}

/// Router-authorized administrator replacement.
struct (0x66447dad) MegatonExchangeChangeAdmin {
    /// Router-selected correlation id.
    queryId: uint64
    /// Replacement administrator.
    adminAddress: address
}

/// Router-authorized Router replacement.
struct (0x1403d27a) MegatonExchangeChangeRouter {
    /// Router-selected correlation id.
    queryId: uint64
    /// Replacement Router address.
    routerAddress: address
}

/// Router-authorized LP Jetton metadata replacement.
struct (0x743f8e58) MegatonExchangeChangeContent {
    /// Router-selected correlation id.
    queryId: uint64
    /// Replacement TEP-64 content cell.
    content: cell
}

/// Administrator update of the swap fee.
struct (0x63c996a5) MegatonExchangeSetSwapFee {
    /// Administrator-selected correlation id.
    queryId: uint64
    /// Replacement fee in ten-thousandths; accepted range is 5 through 100.
    swapFee: coins
}

/// Administrator pause-state update.
struct (0x72ee6e80) MegatonExchangeSetStopped {
    /// Administrator-selected correlation id.
    queryId: uint64
    /// Replacement stopped state.
    stopped: bool
}

/// Administrator update of the LP-provider-count limit.
struct (0x584c27b7) MegatonExchangeSetMaxLiquidityProviders {
    /// Administrator-selected correlation id.
    queryId: uint64
    /// Replacement provider-count limit.
    maxLiquidityProviderCount: uint32
}

/// Administrator update of the attached-value requirement for an opcode.
struct (0x4bc288a4) MegatonExchangeSetOperationFee {
    /// Administrator-selected correlation id.
    queryId: uint64
    /// Operation opcode used as the fee-dictionary key.
    operation: uint32
    /// Required attached nanotons for the operation.
    amount: coins
}

/// All 20 non-empty ordinary internal bodies dispatched by the Exchange.
type MegatonExchangeIncomingMessage =
    | MegatonExchangeInitialize
    | MegatonExchangeAddLiquidity
    | MegatonExchangeBurnLiquidity
    | MegatonExchangeRouterBurnLiquidity
    | MegatonExchangeProvideWalletAddress
    | MegatonExchangeLpTransferCallback
    | MegatonExchangeSwapNotification
    | MegatonExchangeClaimRewards
    | MegatonExchangeLpWalletRequest
    | MegatonExchangeReleasePendingTokens
    | MegatonExchangeUpdateMiningRate
    | MegatonExchangeSetMiningAmount
    | MegatonExchangeSetMinimumLpAmount
    | MegatonExchangeChangeAdmin
    | MegatonExchangeChangeRouter
    | MegatonExchangeChangeContent
    | MegatonExchangeSetSwapFee
    | MegatonExchangeSetStopped
    | MegatonExchangeSetMaxLiquidityProviders
    | MegatonExchangeSetOperationFee

/// Router callback emitted after Exchange initialization.
struct (0xf2c8682b) MegatonExchangeInitialized {
    /// Correlation id copied from initialization.
    queryId: uint64
    /// Token A master address.
    tokenAMasterAddress: address
    /// Token B master address.
    tokenBMasterAddress: address
    /// Initial LP Jetton supply.
    totalSupply: coins
}

/// Standard TEP-74 transfer sent to an underlying token wallet.
struct (0x0f8a7ea5) MegatonExchangeJettonTransfer {
    /// Correlation id copied from the triggering operation.
    queryId: uint64
    /// Jetton amount to transfer.
    amount: coins
    /// Jetton owner that receives the transfer.
    destination: address
    /// Address that receives remaining message value.
    responseDestination: address?
    /// Optional custom payload; Exchange sends no payload.
    customPayload: cell?
    /// Nanotons forwarded with the transfer notification.
    forwardTonAmount: coins
    /// Forward payload encoded inline or by reference.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard TEP-74 internal transfer used to mint or move LP Jettons.
struct (0x178d4519) MegatonExchangeLpInternalTransfer {
    /// Correlation id copied from the triggering operation.
    queryId: uint64
    /// LP Jetton amount.
    amount: coins
    /// LP owner represented as the transfer sender.
    fromAddress: address
    /// Address receiving remaining wallet value.
    responseDestination: address?
    /// Nanotons forwarded with the wallet notification.
    forwardTonAmount: coins
    /// Remaining branch-specific payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Burn instruction sent to the deterministic LP wallet.
struct (0x595f07bc) MegatonExchangeLpBurnInstruction {
    /// Correlation id copied from the withdrawal request.
    queryId: uint64
    /// LP amount to burn.
    amount: coins
    /// Address receiving the burn notification or remaining value.
    responseDestination: address?
    /// Optional custom burn payload; Exchange emits none.
    customPayload: cell?
}

/// Standard excess-value response.
struct (0xd53276db) MegatonExchangeExcesses {
    /// Correlation id of the completed operation.
    queryId: uint64
}

/// TEP-89 wallet-address response.
struct (0xd1735400) MegatonExchangeTakeWalletAddress {
    /// Correlation id copied from the discovery request.
    queryId: uint64
    /// Deterministic LP wallet address, or absent for an unsupported workchain.
    walletAddress: address?
    /// Optional referenced owner address requested by the caller.
    includedOwnerAddress: Cell<address>?
}

/// Router reward-delivery request.
struct (0x6b14cfe1) MegatonExchangeRouterClaimReward {
    /// Correlation id copied from provider accounting.
    queryId: uint64
    /// Provider that receives the reward.
    ownerAddress: address
    /// Reward amount to deliver.
    rewardAmount: coins
}

/// Request sent to an owner's deterministic LP wallet.
struct (0x32139810) MegatonExchangeLpWalletForward {
    /// Correlation id copied from the caller.
    queryId: uint64
}

/// LP-wallet initialization payload used after a routed token delivery.
struct (0x771b1c67) MegatonExchangeLpWalletLiquidityUpdate {
    /// Correlation id copied from the token notification.
    queryId: uint64
    /// Liquidity provider.
    ownerAddress: address
    /// Delivered token amount.
    amount: coins
    /// Token master selecting token A or token B.
    tokenMasterAddress: address
    /// First branch-specific accounting amount.
    accountingAmount0: coins
    /// Second branch-specific accounting amount.
    accountingAmount1: coins
}

/// External mint event emitted after LP issuance.
struct (0x00000015) MegatonExchangeMintEvent {
    /// Provider receiving the issued LP amount.
    ownerAddress: address
    /// LP supply before issuance.
    supplyBefore: coins
    /// Issued LP amount.
    lpAmount: coins
    /// Token A amount consumed.
    tokenAAmount: coins
    /// Token B amount consumed.
    tokenBAmount: coins
}

/// External burn event emitted after LP withdrawal.
struct (0x595f07bc) MegatonExchangeBurnEvent {
    /// Provider whose LP amount was burned.
    ownerAddress: address
    /// LP supply before burning.
    supplyBefore: coins
    /// Burned LP amount.
    lpAmount: coins
    /// Token A amount paid out.
    tokenAAmount: coins
    /// Token B amount paid out.
    tokenBAmount: coins
}

/// External swap event emitted for a successful exchange.
struct MegatonExchangeSwapEventResult {
    /// Output token master.
    tokenMasterAddress: address
    /// Output token amount.
    amount: coins
}

/// External swap event emitted for a successful exchange.
struct (0x7362d09c) MegatonExchangeSwapEvent {
    /// Swap recipient.
    ownerAddress: address
    /// Input token master.
    inputTokenAddress: address
    /// Input token amount.
    inputAmount: coins
    /// Referenced output token and amount.
    result: Cell<MegatonExchangeSwapEventResult>
}

/// Previous mining accumulator values referenced from update events.
struct MegatonExchangePreviousMiningState {
    /// Previous accumulated mined amount.
    lastMined: uint256
    /// Previous mining index.
    lastIndex: uint256
}

/// External event emitted whenever mining accumulation advances.
struct (0x56a8e920) MegatonExchangeMiningUpdateEvent {
    /// Exchange address whose mining state advanced.
    exchangeAddress: address
    /// Updated accumulated mined amount.
    lastMined: uint256
    /// Updated mining index.
    lastIndex: uint256
    /// Previous accumulated amount and index.
    previous: Cell<MegatonExchangePreviousMiningState>
}

/// Mining snapshot referenced from a reward-claim event.
struct MegatonExchangeClaimMiningSnapshot {
    /// Current mining index.
    currentIndex: uint256
    /// Provider's previous mining index.
    providerIndex: uint256
    /// Unix time used for the accounting update.
    updatedAt: uint64
}

/// External event emitted for an accrued reward claim.
struct (0x6b14cfe1) MegatonExchangeClaimEvent {
    /// Provider claiming the reward.
    ownerAddress: address
    /// Previously accumulated reward amount.
    previousRewardAmount: coins
    /// Newly accrued reward amount.
    rewardAmount: coins
    /// Referenced mining-index snapshot.
    mining: Cell<MegatonExchangeClaimMiningSnapshot>
}

/// External event emitted when the Router updates a rate-schedule node.
struct (0x70ae1f34) MegatonExchangeMiningRateEvent {
    /// Exchange address whose schedule changed.
    exchangeAddress: address
    /// Current rate numerator.
    currentRate: uint32
    /// Current rate start time.
    currentStartsAt: uint64
    /// Next rate numerator.
    nextRate: uint32
    /// Next rate start time.
    nextStartsAt: uint64
}

/// External event emitted when the administrator changes the swap fee.
struct (0x63c996a5) MegatonExchangeSwapFeeEvent {
    /// Exchange address whose fee changed.
    exchangeAddress: address
    /// Previous swap fee.
    previousSwapFee: coins
    /// Replacement swap fee.
    swapFee: coins
}

/// Ordinary internal bodies produced by the Exchange send sites.
type MegatonExchangeOutgoingMessage =
    | MegatonExchangeInitialized
    | MegatonExchangeJettonTransfer
    | MegatonExchangeLpInternalTransfer
    | MegatonExchangeLpBurnInstruction
    | MegatonExchangeExcesses
    | MegatonExchangeTakeWalletAddress
    | MegatonExchangeRouterClaimReward
    | MegatonExchangeLpWalletForward
    | MegatonExchangeLpWalletLiquidityUpdate

/// External event bodies produced by Exchange send sites.
type MegatonExchangeEvent =
    | MegatonExchangeMintEvent
    | MegatonExchangeBurnEvent
    | MegatonExchangeSwapEvent
    | MegatonExchangeMiningUpdateEvent
    | MegatonExchangeClaimEvent
    | MegatonExchangeMiningRateEvent
    | MegatonExchangeSwapFeeEvent

/// Standard Jetton master data returned by `get_jetton_data`.
struct MegatonExchangeJettonData {
    /// Total issued LP Jetton supply.
    totalSupply: int
    /// Always true for the LP Jetton master.
    mintable: bool
    /// Current pool administrator.
    adminAddress: address
    /// TEP-64 LP Jetton metadata.
    content: cell
    /// Deterministic LP wallet code.
    walletCode: cell
}

/// Swap-facing pool state returned by `get_lp_swap_data`.
struct MegatonExchangeSwapData {
    /// Swap fee in ten-thousandths.
    swapFee: int
    /// Minimum retained LP amount.
    minimumLpAmount: int
    /// Megaton Router address.
    routerAddress: address
    /// Token A master.
    tokenAMasterAddress: address
    /// Exchange-owned token A wallet.
    tokenAWalletAddress: address
    /// Accounted token A reserve.
    tokenABalance: int
    /// Pending token A amount.
    tokenAPendingBalance: int
    /// Token B master.
    tokenBMasterAddress: address
    /// Exchange-owned token B wallet.
    tokenBWalletAddress: address
    /// Accounted token B reserve.
    tokenBBalance: int
    /// Pending token B amount.
    tokenBPendingBalance: int
}

/// Mining state returned by `get_lp_mining_data` with deployed-code widths.
struct MegatonExchangeMiningData {
    /// Total mining amount cap.
    miningAmount: int
    /// Current schedule emission amount.
    datetimeAmount: int
    /// Unix time from which rewards can be emitted.
    minableTime: int
    /// Half-life duration used by the emission function.
    halfLife: int
    /// Last computed mining index.
    lastIndex: int
    /// Last accumulated mined amount.
    lastMined: int
    /// Linked mining-rate schedule cell.
    miningRateCell: cell
}

/// Exit codes reachable from public Exchange operations.
enum MegatonExchangeErrors {
    /// Attached value is below the configured operation requirement.
    InsufficientAttachedValue = 70
    /// Caller is not the administrator or Router required by the operation.
    Unauthorized = 73
    /// Sender is not the deterministic token or LP wallet required by the message.
    InvalidWalletSender = 74
    /// Attached value or supplied pool amount is insufficient.
    InsufficientAmount = 75
    /// Calculated LP issuance amount is zero.
    ZeroLiquidityMint = 76
    /// Liquidity calculation would consume more than the supplied assets.
    LiquidityCalculationOverflow = 77
    /// Requested LP burn exceeds the permitted amount.
    BurnAmountTooLarge = 78
    /// Asset payout is below the caller's minimum.
    PayoutBelowMinimum = 79
    /// Pending token release exceeds the recorded pending amount.
    PendingAmountExceeded = 91
    /// LP provider record does not exist.
    ProviderNotFound = 100
    /// LP provider balance is below the requested amount.
    ProviderBalanceTooLow = 101
    /// Address is outside the supported base workchain.
    UnsupportedWorkchain = 333
    /// Swap fee must be between 5 and 100 inclusive.
    InvalidSwapFee = 999
    /// Incoming opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return the deterministic LP wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return standard LP Jetton master data.
get fun get_jetton_data(): MegatonExchangeJettonData {
    throw 0;
}

/// Return mining schedule and accumulator state.
get fun get_lp_mining_data(): MegatonExchangeMiningData {
    throw 0;
}

/// Return token identities, reserves, pending balances, fee, and Router.
get fun get_lp_swap_data(): MegatonExchangeSwapData {
    throw 0;
}
