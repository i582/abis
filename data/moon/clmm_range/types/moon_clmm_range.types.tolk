/// Moon.cx concentrated-liquidity range contract.
contract MoonClmmRange {
    author: "Moon.cx"
    description: "Moon.cx CLMM range with liquidity bins, sqrt-price-limited swaps, and NFT-backed LP positions."
    storage: MoonClmmRangeStorage
    incomingMessages: MoonClmmRangeIncomingMessage
    outgoingMessages: MoonClmmRangeOutgoingMessage
    thrownErrors: MoonClmmRangeErrors
    forceAbiExport: MoonClmmRangeSwapForwardPayload
        | MoonClmmRangeDepositLiquidityForwardPayload
        | MoonClmmRangeJettonSwapResultPayload
        | MoonClmmRangeExtraExport
}

/// Persistent state of one initialized CLMM price range.
struct MoonClmmRangeStorage {
    /// Parent Moon.cx CLMM pool that created and controls this range.
    poolAddress: address
    /// Signed range number used by the parent pool to derive this contract address.
    rangeNumber: int16
    /// Range Jetton wallet for asset X, or `addr_none` when X is native TON.
    jettonWalletX: address?
    /// Range Jetton wallet for asset Y, or `addr_none` when Y is native TON.
    jettonWalletY: address?
    /// Price-bin step configured by the parent pool.
    binStep: uint16
    /// Liquidity-provider fee parameter.
    lpFee: uint8
    /// Protocol fee parameter.
    protocolFee: uint8
    /// Next index allocated to an NFT liquidity position.
    nextPositionIndex: uint64
    /// Mutable active-bin, price, and accrued protocol-fee state.
    rangeState: Cell<MoonClmmRangeState>
    /// Optional NFT collection content used for liquidity positions.
    positionCollectionContent: cell?
    /// Code used to derive deterministic per-user LP accounts.
    lpAccountCode: cell
    /// Code used to derive NFT liquidity-position addresses.
    positionNftCode: cell
}

/// Mutable values stored by reference in the range state.
struct MoonClmmRangeState {
    /// Current active liquidity bin.
    currentBin: int64
    /// Current square-root price in Q128 fixed-point form.
    currentSqrtPriceX128: uint256
    /// Asset X protocol fees accrued by this range.
    xProtocolFees: coins
    /// Asset Y protocol fees accrued by this range.
    yProtocolFees: coins
}

/// Success or rejection routing selected by a swap caller.
struct MoonClmmRangeCallback {
    /// Address that receives the corresponding callback.
    recipient: address
    /// Optional application payload forwarded to the callback recipient.
    payload: cell?
}

/// Swap fields stored inside the compatibility wrapper payload.
struct MoonClmmRangeSwapPayload {
    /// Native TON input amount.
    swapAmount: coins
    /// Address that receives unused TON and the swap result.
    excessAddress: address
    /// Q128 square-root price boundary at which execution must stop.
    sqrtPriceLimitX128: uint256
    /// Optional callback used after successful execution.
    nextFulfill: Cell<MoonClmmRangeCallback>?
    /// Optional callback used when the input is rejected or refunded.
    nextReject: Cell<MoonClmmRangeCallback>?
}

/// Direct native TON swap accepted by a Moon.cx CLMM range.
struct (0xd151210f) MoonClmmRangeSwap {
    /// Caller-selected query id copied to result messages.
    queryId: uint64
    /// Native TON input amount.
    swapAmount: coins
    /// Address that receives unused TON and the swap result.
    excessAddress: address
    /// Q128 square-root price boundary at which execution must stop.
    sqrtPriceLimitX128: uint256
    /// Optional callback used after successful execution.
    nextFulfill: Cell<MoonClmmRangeCallback>?
    /// Optional callback used when the input is rejected or refunded.
    nextReject: Cell<MoonClmmRangeCallback>?
}

/// Compatibility wrapper that carries a referenced native swap payload.
struct (0x9d142643) MoonClmmRangeWrappedSwap {
    /// Query id copied to the nested swap and its result.
    queryId: uint64
    /// Native TON amount reserved by the wrapper path.
    swapAmount: coins
    /// Referenced swap request without a repeated opcode or query id.
    swap: Cell<MoonClmmRangeSwapPayload>
}

/// Amounts assigned to one signed liquidity-bin index.
struct MoonClmmRangeDepositBin {
    /// Asset X amount assigned to the bin.
    xAmount: coins
    /// Asset Y amount assigned to the bin.
    yAmount: coins
}

/// Direct native TON liquidity deposit into selected bins.
struct (0xec401442) MoonClmmRangeDepositLiquidity {
    /// Caller-selected query id copied through the deposit flow.
    queryId: uint64
    /// Native TON amount supplied by this side of the deposit.
    depositAmount: coins
    /// `-1` for a single-sided deposit and `0` for a paired deposit.
    isSingle: int1
    /// Amounts assigned to signed 64-bit liquidity-bin indexes.
    bins: map<int64, MoonClmmRangeDepositBin>
}

/// Standard Jetton transfer notification accepted by the range.
struct (0x7362d09c) MoonClmmRangeJettonTransferNotification {
    /// Query id copied from the originating Jetton transfer.
    queryId: uint64
    /// Jetton amount received by the range wallet.
    amount: coins
    /// Logical sender reported by the Jetton wallet.
    sender: address?
    /// Raw TEP-74 `Either Cell ^Cell` tail carrying a Moon.cx forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Swap payload carried by a Jetton transfer notification.
struct (0xd151210f) MoonClmmRangeSwapForwardPayload {
    /// Address that receives unused TON and the swap result.
    excessAddress: address
    /// Q128 square-root price boundary at which execution must stop.
    sqrtPriceLimitX128: uint256
    /// Optional callback used after successful execution.
    nextFulfill: Cell<MoonClmmRangeCallback>?
    /// Optional callback used when the input is rejected or refunded.
    nextReject: Cell<MoonClmmRangeCallback>?
}

/// Liquidity-deposit payload carried by a Jetton transfer notification.
struct (0xec401442) MoonClmmRangeDepositLiquidityForwardPayload {
    /// `-1` for a single-sided deposit and `0` for a paired deposit.
    isSingle: int1
    /// Amounts assigned to signed 64-bit liquidity-bin indexes.
    bins: map<int64, MoonClmmRangeDepositBin>
}

/// Native swap result returned to a caller-selected callback address.
struct (0x9d142643) MoonClmmRangeNativeSwapResult {
    /// Query id copied from the swap request.
    queryId: uint64
    /// Output native TON amount.
    amount: coins
    /// Optional application payload selected by the success callback.
    payload: cell?
}

/// Swap result carried as the forward payload of a Jetton transfer.
struct (0x9d142643) MoonClmmRangeJettonSwapResultPayload {
    /// Optional application payload selected by the success callback.
    payload: cell?
}

/// Native swap rejection or refund returned to a callback address.
struct (0xff32da99) MoonClmmRangeNativeSwapRefund {
    /// Query id copied from the rejected swap request.
    queryId: uint64
    /// Refunded native TON amount.
    amount: coins
    /// Optional application payload selected by the rejection callback.
    payload: cell?
}

/// Standard Jetton transfer emitted for swap output or Jetton refunds.
struct (0x0f8a7ea5) MoonClmmRangeJettonTransfer {
    /// Query id copied from the range operation.
    queryId: uint64
    /// Jetton amount transferred.
    amount: coins
    /// Destination owner address for the receiving Jetton wallet.
    destination: address
    /// Address that receives excess TON.
    responseDestination: address
    /// Optional custom payload for the receiving Jetton wallet.
    customPayload: cell?
    /// Nanotons forwarded with the Jetton transfer notification.
    forwardTonAmount: coins
    /// Optional forward payload for the destination owner.
    forwardPayload: cell?
}

/// Internal messages accepted directly by the range.
type MoonClmmRangeIncomingMessage =
    | MoonClmmRangeSwap
    | MoonClmmRangeWrappedSwap
    | MoonClmmRangeDepositLiquidity
    | MoonClmmRangeJettonTransferNotification

/// Internal messages emitted by observed swap success and rejection paths.
type MoonClmmRangeOutgoingMessage =
    | MoonClmmRangeNativeSwapResult
    | MoonClmmRangeNativeSwapRefund
    | MoonClmmRangeJettonTransfer

/// Additional cells exported for wrapper consumers.
type MoonClmmRangeExtraExport =
    | MoonClmmRangeState
    | MoonClmmRangeCallback
    | MoonClmmRangeSwapPayload
    | MoonClmmRangeDepositBin

/// Contract exit codes observed in authenticated dispatch and input validation.
enum MoonClmmRangeErrors {
    /// Message sender is not authorized for the requested operation.
    UnauthorizedSender = 300
    /// Attached TON value is below the operation's gas budget.
    InsufficientGas = 500
    /// Input token amount is invalid for the requested operation.
    InvalidAmount = 510
    /// Fee or administrative configuration is outside its accepted range.
    InvalidConfiguration = 700
    /// Message opcode is not supported by the range.
    UnsupportedOpcode = 900
}

/// Return the complete serialized range state.
get fun get_range(): cell {
    throw 0;
}

/// Return the optional dictionary of initialized liquidity bins.
get fun get_bins(): cell? {
    throw 0;
}

/// Return the deterministic per-user LP account address.
get fun get_lp_account(ownerAddress: address): address {
    throw 0;
}

/// Return the current active liquidity bin.
get fun get_current_bin(): int {
    throw 0;
}

/// Return the deterministic NFT liquidity-position address for an index.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return the current Q128 square-root price.
get fun get_current_sqrt_price(): int {
    throw 0;
}
