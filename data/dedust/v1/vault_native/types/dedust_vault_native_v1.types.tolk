/// Curated ABI for the DeDust Native Vault v1 implementation.
contract DedustVaultNativeV1 {
    author: "DeDust"
    version: "1.0"
    description: "DeDust Native Vault v1 ABI for native swap routing, liquidity deposit routing, pool and liquidity-deposit payouts, storage, getters, and upgrade messages."
    storage: DedustVaultNativeV1Storage
    incomingMessages: DedustVaultNativeV1IncomingMessage
    outgoingMessages: DedustVaultNativeV1OutgoingMessage
    thrownErrors: DedustVaultNativeV1Errors
}

/// Runtime storage loaded by the Native Vault v1 root data cell.
struct DedustVaultNativeV1Storage {
    /// Cached Vault proof forwarded to Factory and Pool messages.
    cachedProof: Cell<DedustVaultNativeV1VaultProof>
    /// Factory address authorized to upgrade this Vault and authenticate proofs.
    factoryAddress: address
    /// Blank contract code used for deterministic child address checks.
    blankCode: cell
    /// Vault code version returned by `get_version`.
    version: uint16
}

/// Vault proof data committed into Native Vault storage.
struct DedustVaultNativeV1VaultProof {
    /// Factory address committed into this Vault proof.
    factoryAddress: address
    /// DeDust contract type tag for Vault proofs.
    contractType: uint8
    /// Asset served by this Vault.
    asset: DedustVaultNativeV1Asset
}

/// Native TON asset tag used by the Native Vault.
struct (0b0000) DedustVaultNativeV1NativeAsset {}

/// Jetton asset tag used in Pool and proof parameters.
struct (0b0001) DedustVaultNativeV1JettonAsset {
    /// Jetton master workchain id.
    workchainId: int8
    /// Jetton master address hash.
    address: bits256
}

/// Asset variants accepted by DeDust v1 Pool parameter cells.
type DedustVaultNativeV1Asset =
    | DedustVaultNativeV1NativeAsset
    | DedustVaultNativeV1JettonAsset

/// Pool identity encoded in native deposit and proof bodies.
struct DedustVaultNativeV1PoolParams {
    /// Pool curve flag; false for volatile pools and true for stable pools.
    isStable: bool
    /// First sorted Pool asset.
    asset0: DedustVaultNativeV1Asset
    /// Second sorted Pool asset.
    asset1: DedustVaultNativeV1Asset
}

/// Pool proof accepted by the pool payout callback.
struct DedustVaultNativeV1PoolProof {
    /// Factory address committed into the Pool proof.
    factoryAddress: address
    /// DeDust contract type tag for Pool proofs.
    contractType: uint8
    /// Pool identity committed into the deterministic Pool address.
    poolParams: DedustVaultNativeV1PoolParams
}

/// Liquidity Deposit proof accepted by the deposit payout callback.
struct DedustVaultNativeV1LiquidityDepositProof {
    /// Factory address committed into the Liquidity Deposit proof.
    factoryAddress: address
    /// DeDust contract type tag for Liquidity Deposit proofs.
    contractType: uint8
    /// Owner and Pool identity committed into the Liquidity Deposit address.
    params: Cell<DedustVaultNativeV1LiquidityDepositProofParams>
}

/// Referenced owner and Pool identity in a Liquidity Deposit proof.
struct DedustVaultNativeV1LiquidityDepositProofParams {
    /// Owner address committed into the Liquidity Deposit address.
    ownerAddress: address
    /// Pool identity committed into the Liquidity Deposit address.
    poolParams: DedustVaultNativeV1PoolParams
}

/// Swap kind flag encoded in native swap steps.
struct (0b0) DedustVaultNativeV1GivenIn {}

/// Reserved swap kind flag for exact-out style steps.
struct (0b1) DedustVaultNativeV1GivenOut {}

/// One-bit swap direction encoded in a swap step.
type DedustVaultNativeV1SwapKind =
    | DedustVaultNativeV1GivenIn
    | DedustVaultNativeV1GivenOut

/// Swap-step parameters forwarded to a Pool.
struct DedustVaultNativeV1SwapStepParams {
    /// Swap kind for the routed step.
    kind: DedustVaultNativeV1SwapKind
    /// Step limit amount.
    limit: coins
    /// Optional next-step reference forwarded unchanged.
    next: cell?
}

/// First swap step selected by a user-originated native swap.
struct DedustVaultNativeV1SwapStep {
    /// Pool receiving this swap step.
    poolAddress: address
    /// Parameters forwarded to the Pool for this step.
    params: DedustVaultNativeV1SwapStepParams
}

/// User-originated native TON swap accepted by the Native Vault.
struct (0xea06185d) DedustVaultNativeV1Swap {
    /// Query id copied into the Pool routing message.
    queryId: uint64
    /// Native TON amount credited into swap routing.
    amount: coins
    /// First Pool step and step parameters.
    step: DedustVaultNativeV1SwapStep
    /// Required swap parameter reference forwarded unchanged.
    swapParams: cell
}

/// Ref-backed Native Vault liquidity-deposit constraints.
struct DedustVaultNativeV1DepositLiquidityParams {
    /// Minimum acceptable LP amount.
    minLpAmount: coins
    /// Required target balance for Pool asset0.
    asset0TargetBalance: coins
    /// Required target balance for Pool asset1.
    asset1TargetBalance: coins
}

/// User-originated native TON liquidity deposit accepted by the Native Vault.
struct (0xd55e4686) DedustVaultNativeV1DepositLiquidity {
    /// Query id copied into the Factory liquidity-deposit request.
    queryId: uint64
    /// Native TON amount credited into deposit routing.
    amount: coins
    /// Pool identity for the target Liquidity Deposit.
    poolParams: DedustVaultNativeV1PoolParams
    /// Ref-backed deposit constraints.
    params: Cell<DedustVaultNativeV1DepositLiquidityParams>
    /// Optional payload forwarded on successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded on rejection.
    rejectPayload: cell?
}

/// Pool-authorized payout callback accepted by the Native Vault.
struct (0xad4eb6f5) DedustVaultNativeV1PayOutFromPool {
    /// Query id copied into the final payout body.
    queryId: uint64
    /// Pool proof used to authenticate the sender.
    proof: Cell<DedustVaultNativeV1PoolProof>
    /// Native TON amount released to the recipient.
    amount: coins
    /// Final recipient address for the outgoing payout.
    recipientAddress: address?
    /// Optional payload attached to the outgoing payout.
    payload: cell?
}

/// Liquidity Deposit-authorized payout callback accepted by the Native Vault.
struct (0x6b0b787f) DedustVaultNativeV1PayOutFromDeposit {
    /// Query id copied into the final payout body.
    queryId: uint64
    /// Liquidity Deposit proof used to authenticate the sender.
    proof: Cell<DedustVaultNativeV1LiquidityDepositProof>
    /// Native TON amount released to the proof owner.
    amount: coins
    /// Optional payload attached to the outgoing payout.
    payload: cell?
}

/// Factory-authorized Vault code upgrade message.
struct (0x000001bc) DedustVaultNativeV1UpgradeChildCode {
    /// Query id carried by the Factory upgrade command.
    queryId: uint64
    /// Replacement code version.
    codeVersion: uint16
    /// Replacement contract code cell.
    code: cell
}

/// Vault-to-Pool swap routing message constructed after a native swap.
struct (0x61ee542d) DedustVaultNativeV1SwapExternal {
    /// Query id copied from the incoming native swap.
    queryId: uint64
    /// Cached Vault proof proving the sender vault.
    proof: Cell<DedustVaultNativeV1VaultProof>
    /// Native TON amount routed into the Pool.
    amount: coins
    /// Original user sender address from the inbound internal message.
    senderAddress: address
    /// Current step parameters forwarded to the Pool.
    current: DedustVaultNativeV1SwapStepParams
    /// Required swap parameter reference forwarded unchanged.
    swapParams: cell
}

/// Referenced amount cell inside `create_liquidity_deposit`.
struct DedustVaultNativeV1CreateLiquidityDepositExtra {
    /// Target balance for Pool asset0.
    asset0TargetBalance: coins
    /// Target balance for Pool asset1.
    asset1TargetBalance: coins
    /// Asset deposited by this Vault.
    depositAsset: DedustVaultNativeV1Asset
    /// Native TON amount deposited through this Vault.
    depositAmount: coins
    /// Minimum acceptable LP amount.
    minLpAmount: coins
}

/// Vault-to-Factory request constructed after a native liquidity deposit.
struct (0xf04ec526) DedustVaultNativeV1CreateLiquidityDeposit {
    /// Query id copied from the incoming native deposit.
    queryId: uint64
    /// Cached Vault proof proving the sender vault.
    proof: Cell<DedustVaultNativeV1VaultProof>
    /// Original user sender address from the inbound internal message.
    ownerAddress: address
    /// Pool identity used by the Factory to address the Liquidity Deposit contract.
    poolParams: DedustVaultNativeV1PoolParams
    /// Referenced deposit amount and target-balance cell.
    extra: Cell<DedustVaultNativeV1CreateLiquidityDepositExtra>
    /// Optional payload forwarded on successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded on rejection.
    rejectPayload: cell?
}

/// Final native payout body emitted by the Vault to recipients.
struct (0x474f86cf) DedustVaultNativeV1Payout {
    /// Query id copied from the Pool or Liquidity Deposit payout callback.
    queryId: uint64
    /// Optional recipient payload.
    payload: cell?
}

/// Internal message bodies accepted by the Native Vault v1 dispatcher.
type DedustVaultNativeV1IncomingMessage =
    | DedustVaultNativeV1UpgradeChildCode
    | DedustVaultNativeV1DepositLiquidity
    | DedustVaultNativeV1PayOutFromDeposit
    | DedustVaultNativeV1PayOutFromPool
    | DedustVaultNativeV1Swap

/// Internal message bodies constructed by the Native Vault v1 code.
type DedustVaultNativeV1OutgoingMessage =
    | DedustVaultNativeV1SwapExternal
    | DedustVaultNativeV1CreateLiquidityDeposit
    | DedustVaultNativeV1Payout

/// DeDust Native Vault v1 exit-code catalog.
enum DedustVaultNativeV1Errors {
    /// Factory message sender is not the stored Factory.
    InvalidFactorySender = 259
    /// Asset tag, user payload, or proof shape is invalid for this Vault.
    InvalidAssetOrPayload = 261
    /// Attached value cannot cover the required downstream fee budget.
    InsufficientValue = 263
    /// Pool payout sender is not the authenticated Pool.
    InvalidPoolSender = 265
    /// Liquidity-deposit payout sender is not the authenticated Liquidity Deposit.
    InvalidLiquidityDepositSender = 272
    /// Liquidity-deposit target amounts must be positive.
    InvalidDepositAmounts = 276
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return the Native Vault v1 storage version.
get fun get_version(): uint16 {
    throw 0;
}

/// Return the authenticated Factory address stored in Native Vault state.
get fun get_factory_addr(): address {
    throw 0;
}

/// Return the raw native asset slice.
get fun get_asset(): slice {
    throw 0;
}
