/// Low-level STON.fi DEX v2 weighted constant product Pool interface.
contract StonfiPoolV2WeightedConstProduct {
    author: "STON.fi"
    version: "2.2"
    description: "Source-proven STON.fi Pool v2 Weighted Constant Product interface aligned with official Pool v2 docs; storage/getter layout wins where docs conflict"
    storage: StonfiPoolV2WeightedConstProductStorage
    incomingMessages: StonfiPoolV2WeightedConstProductIncomingMessage
    outgoingMessages: StonfiPoolV2WeightedConstProductOutgoingMessage
    thrownErrors: StonfiPoolV2WeightedConstProductErrors
}

/// Persistent weighted constant product Pool state stored in the root data cell.
struct StonfiPoolV2WeightedConstProductStorage {
    /// True when router-routed `transfer_notification` operations are locked for `swap` and `provide_lp`.
    isLocked: bool
    /// Amount of the first token held by the pool, in basic token units.
    reserve0: coins
    /// Amount of the second token held by the pool, in basic token units.
    reserve1: coins
    /// Total supply of minted LP Jettons, in basic token units.
    totalSupplyLp: coins
    /// Collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: coins
    /// Address for receiving protocol fees; deployment stores `addr_none` before fee configuration.
    protocolFeeAddress: address?
    /// Liquidity pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Token 0 weight parameter; source stores it with 64-bit width even though docs describe PoolData `w0` as `uint128`.
    w0: uint64
    /// Referenced static pool data shared by all runtime states.
    staticData: Cell<StonfiPoolV2WeightedConstProductStaticData>
}

/// Static pool data stored in the referenced storage cell.
struct StonfiPoolV2WeightedConstProductStaticData {
    /// Address of the Router that routes swaps, liquidity deposits, and governance updates.
    routerAddress: address
    /// Address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Code of the LP Jetton wallet used for wallet address derivation and minting.
    jettonLpWalletCode: cell
    /// LP Account code used to derive deterministic per-user LP accounts.
    lpAccountCode: cell
}

/// Referenced swap body with slippage, receiver, forwarding, refund, and referral settings.
struct StonfiPoolV2WeightedConstProductSwapBody {
    /// Minimum required amount of tokens to receive; the swap refunds if output is lower.
    minOut: coins
    /// Address where tokens are sent after swap; `addr_none` means use the original user address.
    receiver: address?
    /// TON used to forward `transfer_notification` after swap when `customPayload` is present.
    fwdGas: coins
    /// Optional payload sent in `transfer_notification` after a successful swap.
    customPayload: cell?
    /// TON used to forward `transfer_notification` if the swap refunds and `refundPayload` is present.
    refundFwdGas: coins
    /// Optional payload sent in `transfer_notification` if the swap refunds.
    refundPayload: cell?
    /// Referral fee value; official docs cap this at 100, or 1%.
    refFee: uint16
    /// Referral address whose Vault receives fees; `addr_none` disables referral fee routing.
    refAddress: address?
}

/// Router-routed swap payload ref parsed by the pool after top-level incoming token amounts.
struct StonfiPoolV2WeightedConstProductSwapDexPayload {
    /// Original transferred opcode carried in the user payload.
    transferredOp: uint32
    /// Address of the other Router token wallet.
    tokenWallet1: address
    /// Address where a refund is sent if the swap fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Unix deadline checked by the pool before executing the swap.
    txDeadline: uint64
    /// Referenced swap body with slippage, receiver, forward, refund, and referral data.
    swapBody: Cell<StonfiPoolV2WeightedConstProductSwapBody>
}

/// Referenced provide-liquidity body with minting, forwarding, and receiver settings.
struct StonfiPoolV2WeightedConstProductProvideLpBody {
    /// Minimum required amount of LP tokens to receive.
    minLpOut: coins
    /// Address where LP tokens are sent after minting.
    toAddress: address
    /// Trigger liquidity deposit only if both token amounts are non-zero.
    bothPositive: uint1
    /// TON used to forward `transfer_notification` after LP mint when `customPayload` is present.
    fwdAmount: coins
    /// Optional payload sent in `transfer_notification` after LP mint.
    customPayload: cell?
}

/// Router-routed provide-liquidity payload ref parsed by the pool.
struct StonfiPoolV2WeightedConstProductProvideLpDexPayload {
    /// Original transferred opcode carried in the user payload.
    transferredOp: uint32
    /// Address of the other Router token wallet.
    tokenWallet1: address
    /// Address where a refund is sent if liquidity provision fails.
    refundAddress: address
    /// Address where TON excesses are sent.
    excessesAddress: address
    /// Unix deadline checked by the pool before creating/updating the LP account.
    txDeadline: uint64
    /// Referenced provide-liquidity body with minting and forwarding parameters.
    provideLpBody: Cell<StonfiPoolV2WeightedConstProductProvideLpBody>
}

/// Referenced receiver/refund/excess data carried by LP Account liquidity callbacks.
struct StonfiPoolV2WeightedConstProductCbAddLiquidityAdditionalFields {
    /// LP token receiver requested by the original liquidity operation.
    toUserAddress: address
    /// Destination used when pool-side liquidity validation refunds the deposit.
    refundAddress: address
    /// Destination for excess TON after the liquidity operation.
    excessAddress: address
}

/// Referenced refund/excess data sent from Pool to LP Account.
struct StonfiPoolV2WeightedConstProductAddLiquidityAdditionalFields {
    /// Destination used when the LP Account later requests a refund path.
    refundAddress: address?
    /// Destination for excess TON after the LP Account step.
    excessAddress: address
}

/// Referenced token payout information carried by pool-to-router `pay_to`.
struct StonfiPoolV2WeightedConstProductPayToAdditionalInfo {
    /// Nanotons forwarded by the router to the final recipient.
    fwdTonAmount: coins
    /// Token0 amount paid or refunded through the router.
    amount0Out: coins
    /// Token0 wallet address for the payout.
    token0Address: address
    /// Token1 amount paid or refunded through the router.
    amount1Out: coins
    /// Token1 wallet address for the payout.
    token1Address: address
}

/// Referenced referral vault payment information carried by pool-to-router `pay_vault`.
struct StonfiPoolV2WeightedConstProductPayVaultAdditionalInfo {
    /// Token0 referral-fee amount to deposit into a vault.
    amount0Out: coins
    /// Token0 wallet address for the vault deposit.
    token0Address: address
    /// Token1 referral-fee amount to deposit into a vault.
    amount1Out: coins
    /// Token1 wallet address for the vault deposit.
    token1Address: address
}

/// Swap request received from the Router when a user initiates a token swap.
struct (0x6664de2a) StonfiPoolV2WeightedConstProductSwap {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Original user address reported by the router.
    fromUser: address
    /// Amount of incoming first token.
    leftAmount: coins
    /// Amount of incoming second token.
    rightAmount: coins
    /// Referenced router/user swap payload.
    dexPayload: Cell<StonfiPoolV2WeightedConstProductSwapDexPayload>
}

/// Provide-liquidity request received from the Router and routed toward the user's LP Account.
struct (0x37c096df) StonfiPoolV2WeightedConstProductProvideLp {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Original user address reported by the router.
    fromUser: address
    /// Amount of incoming first token.
    leftAmount: coins
    /// Amount of incoming second token.
    rightAmount: coins
    /// Referenced router/user provide-liquidity payload.
    dexPayload: Cell<StonfiPoolV2WeightedConstProductProvideLpDexPayload>
}

/// LP wallet callback accepted after burning LP Jettons.
struct (0x297437cf) StonfiPoolV2WeightedConstProductBurnNotificationExt {
    /// Query id copied from the original LP wallet burn.
    queryId: uint64
    /// Burned LP Jetton amount in base units.
    jettonAmount: coins
    /// LP owner whose liquidity should be released.
    fromAddress: address
    /// Response address forwarded by the LP wallet; pool source accepts only `addr_none`.
    responseAddress: address?
    /// Optional payload ref holding left/right maybe-payload refs for router payouts.
    maybeCustomPayload: cell?
}

/// LP Account callback requesting LP minting after pending liquidity is complete.
struct (0x06ecd527) StonfiPoolV2WeightedConstProductCbAddLiquidity {
    /// Query id carried by the STON.fi callback message builder.
    queryId: uint64
    /// Total token0 amount supplied to the pool.
    totAm0: coins
    /// Total token1 amount supplied to the pool.
    totAm1: coins
    /// User whose LP account funded the callback.
    userAddress: address
    /// Minimum LP tokens expected by the user.
    minLpOut: coins
    /// Nanotons forwarded by the eventual LP wallet mint notification.
    fwdAmount: coins
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayloadCs: cell?
    /// Referenced receiver, refund, and excess destinations.
    additionalFields: Cell<StonfiPoolV2WeightedConstProductCbAddLiquidityAdditionalFields>
}

/// LP Account callback requesting refund of pending liquidity through the router.
struct (0x0f98e2b8) StonfiPoolV2WeightedConstProductCbRefundMe {
    /// Query id carried by the STON.fi callback message builder.
    queryId: uint64
    /// Token0 amount to refund.
    totAm0: coins
    /// Token1 amount to refund.
    totAm1: coins
    /// User whose LP account funded the refund callback.
    userAddress: address
    /// Optional payload forwarded with token0 refund.
    leftMaybePayload: cell?
    /// Optional payload forwarded with token1 refund.
    rightMaybePayload: cell?
}

/// Collect protocol fees and route both token payouts to the configured protocol fee address.
struct (0x1ee4911e) StonfiPoolV2WeightedConstProductCollectFees {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Optional payload forwarded with collected token0 fees.
    maybePayload0: cell?
    /// Optional payload forwarded with collected token1 fees.
    maybePayload1: cell?
}

/// Pool-specific reset-gas command that keeps pool storage TON and sends the remainder to `excessesRecipient`.
struct (0x29d22935) StonfiPoolV2WeightedConstProductResetGas {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Recipient for excess TON after reserving pool storage rent.
    excessesRecipient: address
}

/// Router governance command that sets liquidity-pool fee, protocol fee, and protocol-fee recipient.
struct (0x75930d63) StonfiPoolV2WeightedConstProductInternalSetFees {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// New liquidity pool fee ratio value divided by `params::fee_divider` (10000).
    newLpFee: uint16
    /// New protocol fee ratio value divided by `params::fee_divider` (10000).
    newProtocolFee: uint16
    /// New protocol fee recipient.
    newProtocolFeeAddress: address
    /// Recipient for excess TON after applying the update.
    excessesAddress: address
}

/// Router governance command that toggles the pool lock flag.
struct (0x62752512) StonfiPoolV2WeightedConstProductInternalUpdateStatus {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Recipient for excess TON after toggling the lock flag.
    excessesRecipient: address
}

/// Router governance command that replaces the pool code.
struct (0x355d097e) StonfiPoolV2WeightedConstProductInternalUpdatePoolCode {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Referenced replacement pool code cell.
    upgradePoolCode: cell
}

/// Router-to-pool weighted parameter update; source applies it only while stored `w0` is empty.
struct (0xf163444a) StonfiPoolV2WeightedConstProductInternalSetParams {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Recipient for excess TON after applying the parameter update.
    excessesAddress: address
    /// Token wallet side whose requested weight is supplied by `newW`.
    sideWallet: address
    /// Requested side weight on the wire; if the side is token1, source stores the complement as token0 `w0`.
    newW: uint128
}

/// On-chain equivalent of `get_pool_data`; asks the pool to send its current state to the sender.
struct (0x26df39fc) StonfiPoolV2WeightedConstProductGetterPoolDataRequest {
    /// Query id copied into the asynchronous pool-data response.
    queryId: uint64
}

/// On-chain equivalent of `get_lp_account_address`; asks for a user's deterministic LP Account address.
struct (0x15fbca95) StonfiPoolV2WeightedConstProductGetterLpAccountAddressRequest {
    /// Query id copied into the asynchronous LP-account-address response.
    queryId: uint64
    /// User address whose deterministic LP account address is requested.
    userAddress: address
}

/// On-chain equivalent of `get_wallet_address`; asks for a user's deterministic LP wallet address.
struct (0x2c76b973) StonfiPoolV2WeightedConstProductProvideWalletAddress {
    /// Query id copied into the `take_wallet_address` response.
    queryId: uint64
    /// LP wallet owner address whose deterministic wallet is requested.
    ownerAddress: address
    /// Include the owner address in the response reference when true.
    includeAddress: bool
}

/// Pool-to-router payout or refund message.
struct (0x657b54f5) StonfiPoolV2WeightedConstProductPayTo {
    /// Query id copied from the operation that produced the payout.
    queryId: uint64
    /// Final token owner recipient for the router payout.
    toAddress: address
    /// Excess TON recipient.
    excessesAddress: address
    /// Original user/caller address used by router accounting.
    originalCaller: address
    /// STON.fi callback or error code describing the payout reason.
    exitCode: uint32
    /// Optional payload forwarded by the router payout.
    customPayload: cell?
    /// Referenced token amounts and wallet addresses.
    additionalInfo: Cell<StonfiPoolV2WeightedConstProductPayToAdditionalInfo>
}

/// Pool-to-router referral vault payment request.
struct (0x63381632) StonfiPoolV2WeightedConstProductPayVault {
    /// Query id copied from the swap that produced referral fees.
    queryId: uint64
    /// Referral owner whose vault receives the fee.
    owner: address
    /// Excess TON recipient.
    excessesAddress: address
    /// Referenced token amounts and wallet addresses for vault deposits.
    additionalInfo: Cell<StonfiPoolV2WeightedConstProductPayVaultAdditionalInfo>
}

/// Pool-to-LP-Account deposit update message.
struct (0x50c6a654) StonfiPoolV2WeightedConstProductAddLiquidity {
    /// Query id carried by the STON.fi message builder.
    queryId: uint64
    /// Newly received token0 amount for the pending LP account.
    newAmount0: coins
    /// Newly received token1 amount for the pending LP account.
    newAmount1: coins
    /// Minimum LP tokens expected; zero can keep funds pending or force a refund path.
    minLpOut: coins
    /// Nanotons forwarded by the eventual LP wallet mint notification.
    fwdAmount: coins
    /// One-bit flag requiring both token balances to be positive before minting.
    bothPositive: uint1
    /// LP token receiver; pool refund fallback can force `addr_none`.
    toUser: address?
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayloadCs: cell?
    /// Referenced refund and excess destinations.
    additionalFields: Cell<StonfiPoolV2WeightedConstProductAddLiquidityAdditionalFields>
}

/// Pool-to-LP-wallet mint transfer body using the STON.fi LP wallet's Jetton layout.
struct (0x178d4519) StonfiPoolV2WeightedConstProductJettonInternalTransfer {
    /// Query id copied from the liquidity callback that produced the mint.
    queryId: uint64
    /// LP Jetton amount minted to the recipient wallet.
    amount: coins
    /// User address reported as the mint source.
    fromAddress: address
    /// Optional response address for LP wallet excesses.
    responseAddress: address?
    /// Nanotons forwarded to the LP token owner notification.
    forwardTonAmount: coins
    /// Raw Jetton forward-payload tail; pool source writes it with `store_maybe_ref`.
    forwardPayload: RemainingBitsAndRefs
}

/// On-chain pool-data response carrying the pool's current common state.
struct (0x26df39fc) StonfiPoolV2WeightedConstProductGetterPoolDataResponse {
    /// Query id copied from the asynchronous getter request.
    queryId: uint64
    /// True when router-routed `transfer_notification` operations are locked for `swap` and `provide_lp`.
    isLocked: bool
    /// Amount of the first token, in basic token units.
    reserve0: coins
    /// Amount of the second token, in basic token units.
    reserve1: coins
    /// Address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Referenced fee, router, supply, and collected protocol-fee data.
    additionalInfo: Cell<StonfiPoolV2WeightedConstProductGetterPoolDataAdditionalInfo>
}

/// Referenced tail emitted by asynchronous pool-data response.
struct StonfiPoolV2WeightedConstProductGetterPoolDataAdditionalInfo {
    /// Liquidity pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Address of the Router.
    routerAddress: address
    /// Address for receiving protocol fees; can be `addr_none` before fee configuration.
    protocolFeeAddress: address?
    /// Total supply of minted LP tokens.
    totalSupplyLp: coins
    /// Collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: coins
}

/// Asynchronous LP-account-address response emitted to a getter requester.
struct (0x15fbca95) StonfiPoolV2WeightedConstProductGetterLpAccountAddressResponse {
    /// Query id copied from the asynchronous getter request.
    queryId: uint64
    /// Deterministic LP Account address for the requested user.
    lpAccountAddress: address
}

/// TEP-89 LP wallet discovery response emitted by the pool/minter interface.
struct (0xd1735400) StonfiPoolV2WeightedConstProductTakeWalletAddress {
    /// Query id copied from `provide_wallet_address`.
    queryId: uint64
    /// Deterministic LP wallet address, or `addr_none` if the owner workchain is unsupported.
    walletAddress: address?
    /// Optional referenced owner address copied from the request when `includeAddress` was true.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the STON.fi Pool v2 WeightedConstProduct contract.
type StonfiPoolV2WeightedConstProductIncomingMessage =
    | StonfiPoolV2WeightedConstProductSwap
    | StonfiPoolV2WeightedConstProductProvideLp
    | StonfiPoolV2WeightedConstProductBurnNotificationExt
    | StonfiPoolV2WeightedConstProductCbAddLiquidity
    | StonfiPoolV2WeightedConstProductCbRefundMe
    | StonfiPoolV2WeightedConstProductCollectFees
    | StonfiPoolV2WeightedConstProductResetGas
    | StonfiPoolV2WeightedConstProductInternalSetFees
    | StonfiPoolV2WeightedConstProductInternalUpdateStatus
    | StonfiPoolV2WeightedConstProductInternalUpdatePoolCode
    | StonfiPoolV2WeightedConstProductInternalSetParams
    | StonfiPoolV2WeightedConstProductGetterPoolDataRequest
    | StonfiPoolV2WeightedConstProductGetterLpAccountAddressRequest
    | StonfiPoolV2WeightedConstProductProvideWalletAddress

/// Internal message bodies emitted by the STON.fi Pool v2 WeightedConstProduct contract.
type StonfiPoolV2WeightedConstProductOutgoingMessage =
    | StonfiPoolV2WeightedConstProductPayTo
    | StonfiPoolV2WeightedConstProductPayVault
    | StonfiPoolV2WeightedConstProductAddLiquidity
    | StonfiPoolV2WeightedConstProductJettonInternalTransfer
    | StonfiPoolV2WeightedConstProductGetterPoolDataResponse
    | StonfiPoolV2WeightedConstProductGetterLpAccountAddressResponse
    | StonfiPoolV2WeightedConstProductTakeWalletAddress

/// Common PoolData returned by `get_pool_data` plus the weighted constant product `w0` field.
struct StonfiPoolV2WeightedConstProductDataReply {
    /// True when router-routed `transfer_notification` operations are locked for `swap` and `provide_lp`.
    isLocked: bool
    /// Router address stored in static pool data.
    routerAddress: address
    /// Total supply of LP tokens returned as a TVM stack integer.
    totalSupply: int
    /// Amount of the first token, in basic token units.
    reserve0: int
    /// Amount of the second token, in basic token units.
    reserve1: int
    /// Address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Liquidity pool fee value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Address for receiving protocol fees, or `addr_none` before fee configuration.
    protocolFeeAddress: any_address
    /// Collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: int
    /// Collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: int
    /// Token 0 weight parameter at PoolData index 12; source-proven storage/getter width is `uint64`.
    w0: uint64
}

/// Structured result returned by the LP Jetton minter-compatible `get_jetton_data`.
struct StonfiPoolV2WeightedConstProductJettonDataReply {
    /// Total issued LP supply returned as a TVM stack integer.
    totalSupply: int
    /// Source returns true because the pool can mint LP Jettons.
    mintable: bool
    /// Router address returned in the standard admin slot.
    adminAddress: address
    /// Generated LP Jetton metadata content cell.
    jettonContent: cell
    /// Referenced LP Jetton wallet code cell.
    jettonLpWalletCode: cell
}

/// Source-level exit-code catalog shared by STON.fi DEX core v2 pool handlers.
enum StonfiPoolV2WeightedConstProductErrors {
    /// Liquidity-dependent operation had no usable pool or LP-account liquidity.
    NoLiquidity = 80
    /// Computed output or supplied liquidity was zero.
    ZeroOutput = 81
    /// Sender was not the deterministic router, LP account, LP wallet, or protocol-fee address expected by a branch.
    InvalidCaller = 82
    /// Attached TON value cannot cover the required forward/storage/gas budget.
    InsufficientGas = 83
    /// Address workchain does not match the configured basechain.
    WrongWorkchain = 85
    /// Address field is invalid for the selected operation.
    WrongAddress = 86
    /// Initial liquidity is below the required minimum or not both-sided.
    LowLiquidity = 88
    /// Weighted math helper signaled an arithmetic failure.
    MathError = 90
    /// Amount, reserve, or weighted parameter is outside accepted bounds.
    InvalidAmount = 92
    /// Operation is invalid for current pool/router upgrade state.
    InvalidCall = 93
    /// LP or protocol fee is outside configured bounds.
    FeeOutOfRange = 94
    /// Pool token wallet pair is invalid.
    InvalidToken = 95
    /// Empty internal message body is rejected by the pool entrypoint.
    EmptyNotAllowed = 96
    /// Weighted swap input exceeds the max-in ratio.
    MaxInRatio = 97
    /// Required code cell is empty.
    EmptyCell = 99
    /// Incoming internal opcode is not supported by the selected sender branch.
    WrongOp = 65535
}

/// Return the STON.fi Pool type string, equal to the Router `dex_type` value.
get fun get_pool_type(): string {
    throw 0;
}

/// Return the deterministic LP Account address for `ownerAddress`.
get fun get_lp_account_address(ownerAddress: address): address {
    throw 0;
}

/// Return LP Jetton supply, mintability, router/admin address, content, and wallet code.
get fun get_jetton_data(): StonfiPoolV2WeightedConstProductJettonDataReply {
    throw 0;
}

/// Return the deterministic LP Jetton wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return common Pool v2 state plus weighted constant product `w0` at index 12.
get fun get_pool_data(): StonfiPoolV2WeightedConstProductDataReply {
    throw 0;
}
