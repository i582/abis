/// DeDust Protocol v2 Liquidity Deposit interface for short-lived deposit coordinator contracts.
contract DedustLiquidityDepositV2 {
    author: "DeDust"
    version: "2.0"
    description: "Curated DeDust Protocol v2 Liquidity Deposit interface with trace-proven lifecycle messages, outgoing pool/vault messages, installed-code getter ids, and exit codes."
    storage: DedustLiquidityDepositV2Storage
    incomingMessages: DedustLiquidityDepositV2IncomingMessage
    outgoingMessages: DedustLiquidityDepositV2OutgoingMessage
}

/// Runtime storage written by the installed Liquidity Deposit code after the Factory install message.
struct DedustLiquidityDepositV2Storage {
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
    /// Referenced tail with optional payloads, pool params, and current balances.
    details: Cell<DedustLiquidityDepositV2StorageDetails>
}

/// Referenced Liquidity Deposit runtime tail cell.
struct DedustLiquidityDepositV2StorageDetails {
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
    /// Workchain id from the Jetton master address.
    workchainId: int8
    /// Jetton master address hash bits.
    address: bits256
}

/// DeDust asset cell variants proven by SDK, Toncenter TL-B, and trace bodies for this contract.
type DedustAsset =
    | DedustAssetNative
    | DedustAssetJetton

/// Pool identity embedded in proof and liquidity messages.
struct DedustPoolParams {
    /// False for volatile pools, true for stable pools.
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
    /// Factory address that installed or derived the proven contract.
    factoryAddr: address
    /// DedustContractType tag; `0x03` means Liquidity Deposit.
    contractType: uint8
    /// Referenced owner/pool parameters for the Liquidity Deposit proof.
    params: Cell<DedustLiquidityDepositProofParams>
}

/// Generic DeDust proof specialized to Pool params.
struct DedustPoolProof {
    /// Factory address that installed or derived the proven pool.
    factoryAddr: address
    /// DedustContractType tag; `0x02` means Pool.
    contractType: uint8
    /// Pool parameters carried inline in the pool proof.
    params: DedustPoolParams
}

/// Blank-installer deployment body received by the address before Liquidity Deposit code is installed.
struct (0x9b3aa3fa) DedustLiquidityDepositInstall {
    /// Query id selected by the Factory.
    queryId: uint64
    /// Blank contract code installed before the versioned Liquidity Deposit code.
    blankCode: cell
    /// Version number for the Liquidity Deposit code cell.
    codeVersion: uint16
    /// Versioned Liquidity Deposit code installed by the Factory.
    code: cell
    /// Raw inline extra install params tail; Toncenter TL-B names this `extra_params:Cell`.
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

/// User-originated cancellation request documented by DeDust docs and SDK.
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

/// Internal message bodies accepted during the observed Liquidity Deposit lifecycle.
type DedustLiquidityDepositV2IncomingMessage =
    | DedustLiquidityDepositInstall
    | DedustDepositAsset
    | DedustFulfillDeposit
    | DedustRejectDeposit
    | DedustCancelDeposit

/// Internal message bodies emitted by the observed Liquidity Deposit lifecycle.
type DedustLiquidityDepositV2OutgoingMessage =
    | DedustDepositLiquidityAll
    | DedustPayOutFromDeposit

/// Owner address getter result.
struct DedustLiquidityDepositV2AddressReply {
    /// Internal address returned by the getter.
    addr: address
}

/// Pool params getter result; assets are returned as raw stack slices.
struct DedustLiquidityDepositV2PoolParamsReply {
    /// False for volatile pools, true for stable pools.
    isStable: bool
    /// First pool asset returned as a DeDust asset slice.
    asset0: slice
    /// Second pool asset returned as a DeDust asset slice.
    asset1: slice
}

/// Pair of target balances returned by `get_target_balances`.
struct DedustLiquidityDepositV2TargetBalancesReply {
    /// Target asset0 amount selected by the user.
    asset0TargetBalance: int
    /// Target asset1 amount selected by the user.
    asset1TargetBalance: int
}

/// Pair of currently held balances returned by `get_balances`.
struct DedustLiquidityDepositV2BalancesReply {
    /// Current asset0 balance in the deposit contract.
    asset0Balance: int
    /// Current asset1 balance in the deposit contract.
    asset1Balance: int
}

/// Boolean status returned by `is_processing`.
struct DedustLiquidityDepositV2ProcessingReply {
    /// True while the deposit is in the processing stage.
    status: bool
}

/// Minimum LP amount getter result.
struct DedustLiquidityDepositV2MinLpAmountReply {
    /// Minimum LP amount accepted by the user.
    minLpAmount: int
}

/// DeDust Liquidity Deposit v2 exit-code catalog.
enum DedustLiquidityDepositV2Errors {
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
get fun get_factory_addr(): DedustLiquidityDepositV2AddressReply {
    assert (true) throw DedustLiquidityDepositV2Errors.InvalidOwnerSender;
    assert (true) throw DedustLiquidityDepositV2Errors.InvalidFactorySender;
    assert (true) throw DedustLiquidityDepositV2Errors.InvalidAssetOrProof;
    assert (true) throw DedustLiquidityDepositV2Errors.InvalidPoolSender;
    assert (true) throw DedustLiquidityDepositV2Errors.InvalidProcessingState;
    assert (true) throw DedustLiquidityDepositV2Errors.UnsupportedOperation;
    return {
        addr: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Returns the user address that owns this pending deposit.
get fun get_owner_addr(): DedustLiquidityDepositV2AddressReply {
    return {
        addr: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Returns the target pool address for this pending deposit.
get fun get_pool_addr(): DedustLiquidityDepositV2AddressReply {
    return {
        addr: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Returns pool type and assets for this pending deposit.
get fun get_pool_params(): DedustLiquidityDepositV2PoolParamsReply {
    return {
        isStable: false,
        asset0: createEmptyCell().beginParse(),
        asset1: createEmptyCell().beginParse(),
    };
}

/// Returns user-selected target balances for the pool assets.
get fun get_target_balances(): DedustLiquidityDepositV2TargetBalancesReply {
    return {
        asset0TargetBalance: 0,
        asset1TargetBalance: 0,
    };
}

/// Returns currently accumulated balances for the pool assets.
get fun get_balances(): DedustLiquidityDepositV2BalancesReply {
    return {
        asset0Balance: 0,
        asset1Balance: 0,
    };
}

/// Returns whether this deposit is actively processing the liquidity operation.
get fun is_processing(): DedustLiquidityDepositV2ProcessingReply {
    return {
        status: false,
    };
}

/// Returns the minimum LP amount configured for this pending deposit.
get fun get_min_lp_amount(): DedustLiquidityDepositV2MinLpAmountReply {
    return {
        minLpAmount: 0,
    };
}
