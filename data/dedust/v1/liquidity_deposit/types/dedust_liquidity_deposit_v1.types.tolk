/// DeDust Liquidity Deposit v1 interface for short-lived deposit coordinator contracts.
contract DedustLiquidityDepositV1 {
    author: "DeDust"
    version: "1.0"
    description: "DeDust Liquidity Deposit v1 ABI for pending two-asset liquidity deposits, pool callbacks, cancellation, and asset payouts."
    storage: DedustLiquidityDepositV1Storage
    incomingMessages: DedustLiquidityDepositV1IncomingMessage
    outgoingMessages: DedustLiquidityDepositV1OutgoingMessage
    thrownErrors: DedustLiquidityDepositV1Errors
}

/// Runtime storage after the Liquidity Deposit implementation is installed.
struct DedustLiquidityDepositV1Storage {
    /// Proof authenticating this deterministic Liquidity Deposit address.
    proof: Cell<DedustLiquidityDepositProof>
    /// Factory address stored separately and returned by `get_factory_addr`.
    factoryAddr: address
    /// Code cell used with the proof to authenticate deterministic DeDust child addresses.
    proofCode: cell
    /// User address that owns this pending liquidity deposit.
    ownerAddr: address
    /// Current asset0 balance held by this deposit.
    asset0Balance: coins
    /// Current asset1 balance held by this deposit.
    asset1Balance: coins
    /// True while the deposit is actively processing the liquidity operation.
    isProcessing: bool
    /// Minimum LP amount accepted by the user.
    minLpAmount: coins
    /// Referenced tail with optional payloads, pool params, and target balances.
    details: Cell<DedustLiquidityDepositV1StorageDetails>
}

/// Referenced Liquidity Deposit runtime tail cell.
struct DedustLiquidityDepositV1StorageDetails {
    /// Optional payload sent after successful liquidity provisioning.
    fulfillPayload: cell?
    /// Optional payload sent after rejected liquidity provisioning.
    rejectPayload: cell?
    /// Target pool identity bound into this deposit.
    poolParams: DedustPoolParams
    /// Target asset0 amount selected by the user.
    asset0TargetBalance: coins
    /// Target asset1 amount selected by the user.
    asset1TargetBalance: coins
}

/// Native TON asset tag used by DeDust asset and pool parameter cells.
struct (0b0000) DedustAssetNative {}

/// Jetton asset tag used by DeDust asset and pool parameter cells.
struct (0b0001) DedustAssetJetton {
    /// Jetton master workchain id encoded as signed 8-bit integer.
    workchainId: int8
    /// Jetton master address hash encoded without the standard address tag.
    address: bits256
}

/// DeDust asset cell variants used by Liquidity Deposit messages and pool params.
type DedustAsset =
    | DedustAssetNative
    | DedustAssetJetton

/// Pool identity embedded in proof and liquidity messages.
struct DedustPoolParams {
    /// False for volatile pools and true for stable pools.
    isStable: bool
    /// First pool asset in canonical DeDust order.
    asset0: DedustAsset
    /// Second pool asset in canonical DeDust order.
    asset1: DedustAsset
}

/// Referenced params proving the Liquidity Deposit address owner and target pool.
struct DedustLiquidityDepositProofParams {
    /// User address that owns the pending liquidity deposit.
    ownerAddr: address
    /// Target pool parameters bound into the deposit address proof.
    poolParams: DedustPoolParams
}

/// Generic DeDust proof specialized to Liquidity Deposit params.
struct DedustLiquidityDepositProof {
    /// Factory address that installed or derived the contract.
    factoryAddr: address
    /// DeDust contract type tag; `0x03` means Liquidity Deposit.
    contractType: uint8
    /// Referenced owner and pool parameters for the Liquidity Deposit proof.
    params: Cell<DedustLiquidityDepositProofParams>
}

/// Generic DeDust proof specialized to Pool params.
struct DedustPoolProof {
    /// Factory address that installed or derived the pool.
    factoryAddr: address
    /// DeDust contract type tag; `0x02` means Pool.
    contractType: uint8
    /// Pool parameters carried inline in the pool proof.
    params: DedustPoolParams
}

/// Blank-installer deployment body received before Liquidity Deposit code is installed.
struct (0x9b3aa3fa) DedustLiquidityDepositInstall {
    /// Query id selected by the Factory.
    queryId: uint64
    /// Blank contract code installed before the versioned Liquidity Deposit code.
    blankCode: cell
    /// Version number for the Liquidity Deposit code cell.
    codeVersion: uint16
    /// Versioned Liquidity Deposit code installed by the Factory.
    code: cell
    /// Child-specific initialization tail encoded inline after the installed code.
    extraParams: RemainingBitsAndRefs
}

/// Factory-originated notice that one side of the pending deposit was received.
struct (0x54240fe5) DedustDepositAsset {
    /// Query id propagated from the Factory flow.
    queryId: uint64
    /// Asset that was deposited into this Liquidity Deposit.
    asset: DedustAsset
    /// Deposited amount in basic asset units.
    amount: coins
}

/// Pool-originated success callback after all pending liquidity was accepted.
struct (0xaae79256) DedustFulfillDeposit {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Proof that the callback came from the target pool.
    proof: Cell<DedustPoolProof>
    /// Amount of asset0 consumed by the pool.
    asset0Deposit: coins
    /// Amount of asset1 consumed by the pool.
    asset1Deposit: coins
}

/// Pool-originated rejection callback when pending liquidity cannot be accepted.
struct (0xe1a36cd4) DedustRejectDeposit {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Proof that the callback came from the target pool.
    proof: Cell<DedustPoolProof>
    /// Optional payload forwarded with returned funds.
    payload: cell?
}

/// User-originated cancellation request.
struct (0x166cedee) DedustCancelDeposit {
    /// Query id selected by the user.
    queryId: uint64
    /// Optional payload attached to returned funds.
    payload: cell?
}

/// Referenced asset/amount pair sent from Liquidity Deposit to Pool.
struct DedustDepositLiquidityAllAssets {
    /// First pool asset.
    asset0: DedustAsset
    /// Amount of asset0 supplied to the pool.
    asset0Amount: coins
    /// Second pool asset.
    asset1: DedustAsset
    /// Amount of asset1 supplied to the pool.
    asset1Amount: coins
}

/// Liquidity Deposit to Pool message that attempts to mint LP tokens with all stored balances.
struct (0xb56b9598) DedustDepositLiquidityAll {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Proof that this sender is the canonical Liquidity Deposit for owner and pool.
    proof: Cell<DedustLiquidityDepositProof>
    /// User address that owns the pending deposit.
    ownerAddr: address
    /// Minimum LP amount accepted by the user; zero disables the minimum.
    minLpAmount: coins
    /// Referenced asset and amount bundle.
    assets: Cell<DedustDepositLiquidityAllAssets>
    /// Optional payload for successful liquidity provisioning.
    fulfillPayload: cell?
    /// Optional payload for rejected liquidity provisioning.
    rejectPayload: cell?
}

/// Liquidity Deposit to Vault payout request for returning unconsumed funds.
struct (0x6b0b787f) DedustPayOutFromDeposit {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Proof that this sender is the canonical Liquidity Deposit for owner and pool.
    proof: Cell<DedustLiquidityDepositProof>
    /// Amount returned through the receiving vault.
    amount: coins
    /// Optional payload forwarded with the returned asset payout.
    payload: cell?
}

/// Internal message bodies accepted during the Liquidity Deposit lifecycle.
type DedustLiquidityDepositV1IncomingMessage =
    | DedustLiquidityDepositInstall
    | DedustDepositAsset
    | DedustFulfillDeposit
    | DedustRejectDeposit
    | DedustCancelDeposit

/// Internal message bodies emitted during the Liquidity Deposit lifecycle.
type DedustLiquidityDepositV1OutgoingMessage =
    | DedustDepositLiquidityAll
    | DedustPayOutFromDeposit

/// Address getter result.
struct DedustLiquidityDepositV1AddressReply {
    /// Internal address returned by the getter.
    addr: address
}

/// Pool params getter result; assets are returned as raw stack slices.
struct DedustLiquidityDepositV1PoolParamsReply {
    /// False for volatile pools and true for stable pools.
    isStable: bool
    /// First pool asset returned as a DeDust asset slice.
    asset0: slice
    /// Second pool asset returned as a DeDust asset slice.
    asset1: slice
}

/// Pair of target balances returned by `get_target_balances`.
struct DedustLiquidityDepositV1TargetBalancesReply {
    /// Target asset0 amount selected by the user.
    asset0TargetBalance: int
    /// Target asset1 amount selected by the user.
    asset1TargetBalance: int
}

/// Pair of currently held balances returned by `get_balances`.
struct DedustLiquidityDepositV1BalancesReply {
    /// Current asset0 balance in the deposit contract.
    asset0Balance: int
    /// Current asset1 balance in the deposit contract.
    asset1Balance: int
}

/// Boolean status returned by `is_processing`.
struct DedustLiquidityDepositV1ProcessingReply {
    /// True while the deposit is in the processing stage.
    status: bool
}

/// Minimum LP amount getter result.
struct DedustLiquidityDepositV1MinLpAmountReply {
    /// Minimum LP amount accepted by the user.
    minLpAmount: int
}

/// DeDust Liquidity Deposit v1 exit-code catalog.
enum DedustLiquidityDepositV1Errors {
    /// Cancellation sender is not the stored deposit owner.
    InvalidOwnerSender = 257
    /// Asset-deposit sender is not the Factory.
    InvalidFactorySender = 259
    /// Asset tag or proof shape is invalid for this Liquidity Deposit.
    InvalidAssetOrProof = 261
    /// Pool callback sender is not the authenticated Pool.
    InvalidPoolSender = 265
    /// Deposit lifecycle state is invalid for the requested operation.
    InvalidProcessingState = 276
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Returns the Factory address stored by the installed Liquidity Deposit code.
get fun get_factory_addr(): DedustLiquidityDepositV1AddressReply {
    throw 0;
}

/// Returns the user address that owns this pending deposit.
get fun get_owner_addr(): DedustLiquidityDepositV1AddressReply {
    throw 0;
}

/// Returns the target pool address for this pending deposit.
get fun get_pool_addr(): DedustLiquidityDepositV1AddressReply {
    throw 0;
}

/// Returns pool type and assets for this pending deposit.
get fun get_pool_params(): DedustLiquidityDepositV1PoolParamsReply {
    throw 0;
}

/// Returns user-selected target balances for the pool assets.
get fun get_target_balances(): DedustLiquidityDepositV1TargetBalancesReply {
    throw 0;
}

/// Returns currently accumulated balances for the pool assets.
get fun get_balances(): DedustLiquidityDepositV1BalancesReply {
    throw 0;
}

/// Returns whether this deposit is actively processing the liquidity operation.
get fun is_processing(): DedustLiquidityDepositV1ProcessingReply {
    throw 0;
}

/// Returns the minimum LP amount configured for this pending deposit.
get fun get_min_lp_amount(): DedustLiquidityDepositV1MinLpAmountReply {
    throw 0;
}
