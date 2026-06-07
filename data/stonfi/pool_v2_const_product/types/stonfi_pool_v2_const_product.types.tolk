/// STON.fi DEX v2 ConstantProduct Pool interface, including pool state, routed operations, async getter replies, and LP Jetton minter methods.
contract StonfiPoolV2ConstProduct {
    author: "STON.fi"
    version: "2.2"
    description: "Source-preserving STON.fi Pool v2 ConstantProduct ABI aligned with docs.ston.fi Pool v2 terminology for PoolData, LP account/wallet discovery, routed swap/provide_liquidity flows, fee collection, referral vault payouts, and async getter messages"
    storage: StonfiPoolV2ConstProductStorage
    incomingMessages: StonfiPoolV2ConstProductIncomingMessage
    outgoingMessages: StonfiPoolV2ConstProductOutgoingMessage
    thrownErrors: StonfiPoolV2ConstProductErrors
}

/// Root persistent ConstantProduct pool state stored by `storage::save`; mirrors the common PoolData fields exposed by `get_pool_data`.
struct StonfiPoolV2ConstProductStorage {
    /// Pool lock flag; when true, transfer-notification operations such as swaps and liquidity provision are locked.
    isLocked: bool
    /// Amount of the first token held by the pool, encoded as TL-B `Coins` in basic token units.
    reserve0: coins
    /// Amount of the second token held by the pool, encoded as TL-B `Coins` in basic token units.
    reserve1: coins
    /// Total supply of LP Jettons, encoded as TL-B `Coins` in basic token units.
    totalSupplyLp: coins
    /// Collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: coins
    /// Address that receives collected protocol fees and is authorized by source to call `collect_fees`.
    protocolFeeAddress: address
    /// Liquidity pool fee value; fee ratio is this value divided by `params::fee_divider` (10000).
    lpFee: uint16
    /// Protocol fee value; fee ratio is this value divided by `params::fee_divider` (10000).
    protocolFee: uint16
    /// Referenced static pool data with router, token wallet addresses, and code cells.
    staticData: Cell<StonfiPoolV2ConstProductStaticData>
}

/// Static ConstantProduct pool data stored in the root state's final reference and used for address derivation.
struct StonfiPoolV2ConstProductStaticData {
    /// Router address authorized by source to send routed swap/provide_lp and internal admin messages.
    routerAddress: address
    /// Address of the first Jetton token wallet used by this pool and returned by `get_pool_data`.
    token0Address: address
    /// Address of the second Jetton token wallet used by this pool and returned by `get_pool_data`.
    token1Address: address
    /// LP Jetton wallet code used for deterministic LP wallet derivation and minting.
    jettonLpWalletCode: cell
    /// LP Account code used for deterministic pending-liquidity account derivation.
    lpAccountCode: cell
}

/// Referenced swap-specific payload inside the Router-originated `swap` message.
struct StonfiPoolV2ConstProductSwapBody {
    /// Minimum required amount of output tokens; the swap is refunded if the result is lower.
    minOut: coins
    /// Address receiving output tokens after swap, or `addr_none` to use `fromUser`.
    receiver: address?
    /// Nanotons used to forward a transfer notification after swap when customPayload is present.
    fwdGas: coins
    /// Optional payload sent in the transfer notification after a successful swap.
    customPayload: cell?
    /// Nanotons used to forward a transfer notification when the swap fails and is refunded.
    refundFwdGas: coins
    /// Optional payload sent in the transfer notification if the swap is refunded.
    refundPayload: cell?
    /// Referral fee value; source enforces the same 0..100 range documented as up to 1%.
    refFee: uint16
    /// Referral owner whose Vault receives fees, or `addr_none` when referral fees are disabled.
    refAddress: address?
}

/// Routed swap payload sent by Router to Pool in a referenced cell.
struct StonfiPoolV2ConstProductSwapDexPayload {
    /// Original routed payload opcode retained by Router; source skips this value in Pool.
    transferredOp: uint32
    /// Other Router token wallet address from the routed payload; validation is handled by Router.
    tokenWallet1: address
    /// Address receiving Jettons if the swap is refunded.
    refundAddress: address
    /// Address receiving TON excesses from downstream Router and Jetton-wallet transfers.
    excessesAddress: address
    /// Unix deadline checked by Pool before applying the swap.
    txDeadline: uint64
    /// Referenced swap body with limits, receiver, forward payloads, and referral data.
    swapBody: Cell<StonfiPoolV2ConstProductSwapBody>
}

/// Referenced provide-liquidity payload inside the Router-originated `provide_lp` message.
struct StonfiPoolV2ConstProductProvideLpBody {
    /// Minimum required LP Jetton amount to receive; minting is refunded if the result is lower.
    minLpOut: coins
    /// Address receiving newly minted LP Jettons.
    toAddress: address
    /// One-bit flag requiring both deposited token amounts to be non-zero before minting.
    bothPositive: uint1
    /// Nanotons forwarded with the eventual LP wallet transfer notification.
    fwdAmount: coins
    /// Optional payload sent in the transfer notification after LP minting.
    customPayload: cell?
}

/// Routed provide-liquidity payload sent by Router to Pool in a referenced cell.
struct StonfiPoolV2ConstProductProvideLpDexPayload {
    /// Original routed payload opcode retained by Router; source skips this value in Pool.
    transferredOp: uint32
    /// Other Router token wallet address from the routed payload; validation is handled by Router.
    tokenWallet1: address
    /// Address receiving Jettons if liquidity provision is refunded.
    refundAddress: address
    /// Address receiving excess TON from downstream transfers.
    excessesAddress: address
    /// Unix deadline checked by Pool before sending `add_liquidity` to the user's LP Account.
    txDeadline: uint64
    /// Referenced provide-liquidity body with mint constraints and forwarding data.
    provideLpBody: Cell<StonfiPoolV2ConstProductProvideLpBody>
}

/// Referenced receiver/refund/excess destinations for the LP Account `cb_add_liquidity` callback.
struct StonfiPoolV2ConstProductCbAddLiquidityAdditionalFields {
    /// Owner of newly minted LP Jettons.
    toUserAddress: address
    /// Address whose LP Account receives a forced refund if liquidity minting is unsuccessful.
    refundAddress: address
    /// Address where all TON excesses are sent after mint or refund handling.
    excessAddress: address
}

/// Referenced refund/excess destinations emitted to LP Account `add_liquidity`.
struct StonfiPoolV2ConstProductAddLiquidityAdditionalFields {
    /// Address used by LP Account if liquidity is later refunded through Pool.
    refundAddress: address?
    /// Address where TON excesses are sent after LP Account processing.
    excessAddress: address
}

/// Referenced payout data carried by Pool-to-Router `pay_to` messages.
struct StonfiPoolV2ConstProductPayToAdditionalInfo {
    /// Nanotons forwarded by Router's outgoing Jetton transfer.
    fwdTonAmount: coins
    /// Amount of the first token to transfer, in basic token units.
    amount0Out: coins
    /// First token wallet address that should pay amount0Out.
    token0Address: address
    /// Amount of the second token to transfer, in basic token units.
    amount1Out: coins
    /// Second token wallet address that should pay amount1Out.
    token1Address: address
}

/// Referenced referral-vault payout data carried by Pool-to-Router `pay_vault`.
struct StonfiPoolV2ConstProductPayVaultAdditionalInfo {
    /// First-token referral amount to deposit into the referrer's Vault, in basic token units.
    amount0Out: coins
    /// First token wallet address whose Vault receives amount0Out.
    token0Address: address
    /// Second-token referral amount to deposit into the referrer's Vault, in basic token units.
    amount1Out: coins
    /// Second token wallet address whose Vault receives amount1Out.
    token1Address: address
}

/// Referenced extra fields in the async pool-data getter response.
struct StonfiPoolV2ConstProductGetterPoolDataExtra {
    /// Current liquidity pool fee value; divide by 10000 to obtain the fee ratio.
    lpFee: uint16
    /// Current protocol fee value; divide by 10000 to obtain the fee ratio.
    protocolFee: uint16
    /// Router address stored in static pool data.
    routerAddress: address
    /// Protocol fee collection address.
    protocolFeeAddress: address
    /// Total amount of minted LP Jettons.
    totalSupply: coins
    /// Collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: coins
}

/// Router-originated swap routed from a user Jetton transfer notification; Pool sends `pay_to` and optionally `pay_vault`.
struct (0x6664de2a) StonfiPoolV2ConstProductSwap {
    /// Query id copied from the original routed transfer.
    queryId: uint64
    /// User address that initiated the swap.
    fromUser: address
    /// Incoming first-token amount received by the pool; one side is expected to be zero.
    leftAmount: coins
    /// Incoming second-token amount received by the pool; one side is expected to be zero.
    rightAmount: coins
    /// Referenced routed swap payload.
    dexPayload: Cell<StonfiPoolV2ConstProductSwapDexPayload>
}

/// Router-originated liquidity provision routed from a user Jetton transfer notification to the user's LP Account.
struct (0x37c096df) StonfiPoolV2ConstProductProvideLp {
    /// Query id copied from the original routed transfer.
    queryId: uint64
    /// User address whose deterministic LP Account receives the `add_liquidity` update.
    fromUser: address
    /// Incoming first-token amount received by the pool; single-side provision is allowed in v2.
    leftAmount: coins
    /// Incoming second-token amount received by the pool; single-side provision is allowed in v2.
    rightAmount: coins
    /// Referenced routed provide-liquidity payload.
    dexPayload: Cell<StonfiPoolV2ConstProductProvideLpDexPayload>
}

/// LP-wallet burn callback that releases both pool reserves through Router `pay_to` payouts.
struct (0x297437cf) StonfiPoolV2ConstProductBurnNotificationExt {
    /// Query id copied from the original LP wallet burn request.
    queryId: uint64
    /// Amount of LP tokens to burn, in basic token units.
    jettonAmount: coins
    /// LP token owner whose liquidity is released.
    fromAddress: address
    /// Response address field from Jetton burn; Pool source requires `addr_none` and rejects a real address.
    responseAddress: address?
    /// Optional payload ref that may contain payloads for token0 and token1 payouts.
    maybeCustomPayload: cell?
}

/// LP Account callback after tokens are accumulated; Pool mints LP Jettons or forces a refund.
struct (0x06ecd527) StonfiPoolV2ConstProductCbAddLiquidity {
    /// Query id carried by the STON.fi callback message builder.
    queryId: uint64
    /// Total first-token amount supplied by the LP Account, in basic token units.
    totAm0: coins
    /// Total second-token amount supplied by the LP Account, in basic token units.
    totAm1: coins
    /// Owner of the LP Account that funded the callback.
    userAddress: address
    /// Minimum LP Jettons expected by the user.
    minLpOut: coins
    /// Forward amount used to send customPayloadCs in the eventual LP wallet transfer notification.
    fwdAmount: coins
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayloadCs: cell?
    /// Referenced receiver, refund, and excess destinations.
    additionalFields: Cell<StonfiPoolV2ConstProductCbAddLiquidityAdditionalFields>
}

/// LP Account callback requesting refund of pending liquidity amounts through Router `pay_to`.
struct (0x0f98e2b8) StonfiPoolV2ConstProductCbRefundMe {
    /// Query id carried by the STON.fi callback message builder.
    queryId: uint64
    /// Total first-token amount to refund, in basic token units.
    totAm0: coins
    /// Total second-token amount to refund, in basic token units.
    totAm1: coins
    /// Owner of the LP Account requesting the refund.
    userAddress: address
    /// Optional payload forwarded with the left-token refund.
    leftMaybePayload: cell?
    /// Optional payload forwarded with the right-token refund.
    rightMaybePayload: cell?
}

/// Protocol-fee collection request accepted only from protocolFeeAddress; collected token fees are sent through Router `pay_to`.
struct (0x1ee4911e) StonfiPoolV2ConstProductCollectFees {
    /// Caller-selected query id carried by the STON.fi message builder.
    queryId: uint64
    /// Optional payload used for the first-token protocol-fee payout; may contain cross-swap data.
    maybePayload0: cell?
    /// Optional payload used for the second-token protocol-fee payout; may contain cross-swap data.
    maybePayload1: cell?
}

/// Router internal admin command that updates LP/protocol fee values and protocol fee recipient.
struct (0x75930d63) StonfiPoolV2ConstProductInternalSetFees {
    /// Router-selected query id carried by the admin message.
    queryId: uint64
    /// New liquidity pool fee value, multiplied by `params::fee_divider` (10000).
    newLpFee: uint16
    /// New protocol fee value, multiplied by `params::fee_divider` (10000).
    newProtocolFee: uint16
    /// Replacement protocol fee collection address.
    newProtocolFeeAddress: address
    /// Address receiving excess TON after the update.
    excessesAddress: address
}

/// Router internal admin command that reserves `storage_fee::pool` nanotons on the Pool and returns remaining TON.
struct (0x29d22935) StonfiPoolV2ConstProductResetGas {
    /// Router-selected query id carried by the admin message.
    queryId: uint64
    /// Address receiving excess TON after storage reserve; present in source Pool handler although the common opcode string omits it.
    excessesRecipient: address
}

/// Router internal admin command that toggles the pool lock flag.
struct (0x62752512) StonfiPoolV2ConstProductInternalUpdateStatus {
    /// Router-selected query id carried by the admin message.
    queryId: uint64
    /// Address receiving excess TON after the status update.
    excessesRecipient: address
}

/// Router admin command that replaces the Pool contract code.
struct (0x355d097e) StonfiPoolV2ConstProductInternalUpdatePoolCode {
    /// Router-selected query id carried by the admin message.
    queryId: uint64
    /// Referenced replacement code cell installed by `set_code`.
    upgradePoolCode: cell
}

/// On-chain getter request for the current PoolData snapshot; async equivalent of `get_pool_data`.
struct (0x26df39fc) StonfiPoolV2ConstProductGetterPoolDataRequest {
    /// Caller-selected query id copied into the async response.
    queryId: uint64
}

/// On-chain getter response carrying common PoolData fields plus an additional_data reference.
struct (0x26df39fc) StonfiPoolV2ConstProductGetterPoolDataResponse {
    /// Query id copied from the async getter request.
    queryId: uint64
    /// Pool lock flag at response time.
    isLocked: bool
    /// Amount of the first token at response time, in basic token units.
    reserve0: coins
    /// Amount of the second token at response time, in basic token units.
    reserve1: coins
    /// Address of the first Jetton token wallet at response time.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet at response time.
    token1WalletAddress: address
    /// Referenced additional_data with fees, Router, protocol-fee recipient, LP supply, and collected protocol fees.
    extra: Cell<StonfiPoolV2ConstProductGetterPoolDataExtra>
}

/// On-chain getter request for a user's deterministic LP Account address.
struct (0x15fbca95) StonfiPoolV2ConstProductGetterLpAccountAddressRequest {
    /// Caller-selected query id copied into the async response.
    queryId: uint64
    /// User address used with this pool to derive the LP Account address.
    userAddress: address
}

/// On-chain getter response carrying a deterministic LP Account address.
struct (0x15fbca95) StonfiPoolV2ConstProductGetterLpAccountAddressResponse {
    /// Query id copied from the async getter request.
    queryId: uint64
    /// Deterministic LP Account address derived for the requested user.
    lpAccountAddress: address
}

/// TEP-89 wallet discovery request accepted by the Pool as LP Jetton minter; async equivalent of `get_wallet_address`.
struct (0x2c76b973) StonfiPoolV2ConstProductProvideWalletAddress {
    /// Caller-selected query id copied into the `take_wallet_address` response.
    queryId: uint64
    /// LP owner address whose deterministic LP wallet address is requested.
    ownerAddress: address
    /// True when the `take_wallet_address` response must include a referenced copy of ownerAddress.
    includeAddress: bool
}

/// TEP-89 wallet discovery response emitted by the Pool as LP Jetton minter.
struct (0xd1735400) StonfiPoolV2ConstProductTakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Calculated LP wallet address, or `addr_none` when owner workchain is unsupported.
    walletAddress: address?
    /// Optional referenced owner address when includeAddress was true.
    ownerAddress: Cell<address>?
}

/// Pool-to-LP Account deposit update emitted from the provide-liquidity path.
struct (0x50c6a654) StonfiPoolV2ConstProductAddLiquidity {
    /// Query id copied from the routed provide-liquidity message.
    queryId: uint64
    /// New first-token amount to add to the user's LP Account.
    newAmount0: coins
    /// New second-token amount to add to the user's LP Account.
    newAmount1: coins
    /// Minimum LP Jettons expected; zero in the pool's forced refund branch.
    minLpOut: coins
    /// Forward amount used by LP Account/LP wallet mint path when a transfer notification is sent.
    fwdAmount: coins
    /// One-bit flag requiring both token balances to be positive before minting.
    bothPositive: uint1
    /// LP Jetton receiver, or `addr_none` in the pool's forced refund branch.
    toUser: address?
    /// Optional custom payload forwarded to the LP wallet mint path.
    customPayloadCs: cell?
    /// Referenced refund and excess destinations.
    additionalFields: Cell<StonfiPoolV2ConstProductAddLiquidityAdditionalFields>
}

/// Pool-to-Router payout or refund request; Router initiates the final Jetton transfer to `toAddress`.
struct (0x657b54f5) StonfiPoolV2ConstProductPayTo {
    /// Query id copied from the swap, burn, collect-fee, or refund flow.
    queryId: uint64
    /// Final user, protocol-fee recipient, or refund address receiving the token transfer.
    toAddress: address
    /// Address receiving TON excesses from Router and Jetton-wallet transfers.
    excessesAddress: address
    /// Original user or caller associated with the payout.
    originalCaller: address
    /// STON.fi success or refund code supplied by Pool.
    exitCode: uint32
    /// Optional payload forwarded with the final Jetton transfer; may contain cross-swap data.
    customPayload: cell?
    /// Referenced payout amounts, token wallets, and forward amount.
    additionalInfo: Cell<StonfiPoolV2ConstProductPayToAdditionalInfo>
}

/// Pool-to-Router referral-vault deposit request; Router deposits referral fees into the referrer's Vault.
struct (0x63381632) StonfiPoolV2ConstProductPayVault {
    /// Query id copied from the swap flow.
    queryId: uint64
    /// Referral owner whose deterministic Vault receives the fee.
    owner: address
    /// Address receiving excess TON after vault deposit.
    excessesAddress: address
    /// Referenced referral-fee amounts and token wallet addresses.
    additionalInfo: Cell<StonfiPoolV2ConstProductPayVaultAdditionalInfo>
}

/// Pool-to-LP-wallet mint transfer for newly issued LP Jettons, using the standard Jetton internal transfer body.
struct (0x178d4519) StonfiPoolV2ConstProductLpWalletInternalTransfer {
    /// Query id copied from the LP Account callback.
    queryId: uint64
    /// LP Jetton amount minted to the receiver wallet.
    amount: coins
    /// User address whose liquidity funded the mint.
    fromAddress: address
    /// Optional response address for LP wallet excesses.
    responseAddress: address?
    /// Nanotons forwarded to the LP wallet owner's transfer notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward payload tail emitted by Pool's mint builder.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by STON.fi Pool v2 ConstantProduct.
type StonfiPoolV2ConstProductIncomingMessage =
    | StonfiPoolV2ConstProductSwap
    | StonfiPoolV2ConstProductProvideLp
    | StonfiPoolV2ConstProductBurnNotificationExt
    | StonfiPoolV2ConstProductCbAddLiquidity
    | StonfiPoolV2ConstProductCbRefundMe
    | StonfiPoolV2ConstProductCollectFees
    | StonfiPoolV2ConstProductInternalSetFees
    | StonfiPoolV2ConstProductResetGas
    | StonfiPoolV2ConstProductInternalUpdateStatus
    | StonfiPoolV2ConstProductInternalUpdatePoolCode
    | StonfiPoolV2ConstProductGetterPoolDataRequest
    | StonfiPoolV2ConstProductGetterLpAccountAddressRequest
    | StonfiPoolV2ConstProductProvideWalletAddress

/// Internal message bodies emitted by STON.fi Pool v2 ConstantProduct.
type StonfiPoolV2ConstProductOutgoingMessage =
    | StonfiPoolV2ConstProductPayTo
    | StonfiPoolV2ConstProductPayVault
    | StonfiPoolV2ConstProductAddLiquidity
    | StonfiPoolV2ConstProductLpWalletInternalTransfer
    | StonfiPoolV2ConstProductGetterPoolDataResponse
    | StonfiPoolV2ConstProductGetterLpAccountAddressResponse
    | StonfiPoolV2ConstProductTakeWalletAddress

/// Structured result returned by `get_pool_data`; ConstantProduct has exactly the 12 common PoolData fields and no typed-pool tail.
struct StonfiPoolV2ConstProductDataReply {
    /// True if transfer-notification operations such as `swap` and `provide_lp` are locked.
    isLocked: bool
    /// Address of the Router.
    routerAddress: address
    /// Total supply of LP tokens, in basic token units.
    totalSupply: int
    /// Amount of the first token, in basic token units.
    reserve0: int
    /// Amount of the second token, in basic token units.
    reserve1: int
    /// Address of the first Jetton token wallet.
    token0WalletAddress: address
    /// Address of the second Jetton token wallet.
    token1WalletAddress: address
    /// Liquidity pool fee value; divide by `params::fee_divider` (10000) to obtain the fee ratio.
    lpFee: uint16
    /// Protocol fee value; divide by `params::fee_divider` (10000) to obtain the fee ratio.
    protocolFee: uint16
    /// Address for receiving protocol fees.
    protocolFeeAddress: address
    /// Amount of collected protocol fees of the first token, in basic token units.
    collectedToken0ProtocolFee: int
    /// Amount of collected protocol fees of the second token, in basic token units.
    collectedToken1ProtocolFee: int
}

/// Structured result returned by Pool's LP Jetton minter `get_jetton_data`.
struct StonfiPoolV2ConstProductJettonDataReply {
    /// Total token supply of LP tokens, in basic token units.
    totalSupply: int
    /// Always true in source because the Pool mints LP Jettons through liquidity callbacks.
    mintable: bool
    /// Router address returned in the Jetton admin slot.
    adminAddress: address
    /// Off-chain LP Jetton metadata content cell generated by source.
    jettonContent: cell
    /// Referenced LP wallet code cell.
    jettonWalletCode: cell
}

/// Source-level exit-code catalog for the ConstantProduct Pool paths represented here.
enum StonfiPoolV2ConstProductErrors {
    /// `provide_wallet_address` message value cannot cover the response budget.
    InsufficientProvideWalletAddressValue = 75
    /// Burn, collect, or liquidity flow would produce zero output.
    ZeroOutput = 81
    /// Sender is not the deterministic LP Account, LP Wallet, Router, or protocol-fee address expected by the branch.
    InvalidCaller = 82
    /// Attached value cannot cover the required downstream gas and forward fees.
    InsufficientGas = 83
    /// Sender, owner, receiver, or token wallet is outside the configured base workchain.
    WrongWorkchain = 85
    /// Address value is not allowed for this branch, including non-none burn response address.
    WrongAddress = 86
    /// Initial liquidity did not provide both token sides.
    LowLiquidity = 88
    /// Reserve or LP supply update would leave an invalid amount.
    InvalidAmount = 92
    /// Branch is not valid in the current pool state.
    InvalidCall = 93
    /// Stored token wallet addresses are identical.
    InvalidToken = 95
    /// Pool does not accept empty internal message bodies.
    EmptyNotAllowed = 96
    /// Incoming internal message opcode is not supported by the selected sender branch.
    UnsupportedOperation = 65535
}

/// Return the pool type string; live ConstantProduct pools return `constant_product`.
get fun get_pool_type(): string {
    throw 0;
}

/// Return the deterministic LP Account address for a user.
get fun get_lp_account_address(ownerAddress: address): address {
    throw 0;
}

/// Return LP Jetton minter data for this Pool.
get fun get_jetton_data(): StonfiPoolV2ConstProductJettonDataReply {
    throw 0;
}

/// Return the deterministic LP wallet address for an owner.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return current ConstantProduct PoolData; stableswap, weighted_stableswap, and weighted_const_product trailing fields are not present for this pool type.
get fun get_pool_data(): StonfiPoolV2ConstProductDataReply {
    throw 0;
}
