/// Coffee Swap native-asset vault for routing TON swaps, deposits, pool creation, and payouts.
contract CoffeeVaultNative {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee Swap Native Vault ABI for TON swaps, liquidity deposits, pool creation, payouts, and factory updates."
    storage: CoffeeVaultNativeStorage
    incomingMessages: CoffeeVaultNativeIncomingMessage
    outgoingMessages: CoffeeVaultNativeOutgoingMessage
    thrownErrors: Errors
}

/// Runtime root data cell for the native vault.
struct CoffeeVaultNativeStorage {
    /// Code cell paired with `initData` for deterministic child-contract proofs.
    initCode: cell
    /// Referenced vault init data containing Factory address, vault type tag, and the native asset tag.
    initData: Cell<CoffeeVaultInitData>
}

/// Vault init-data cell shared by Coffee vault variants and proof references.
struct CoffeeVaultInitData {
    /// Factory address that owns and authenticates this vault family.
    factoryAddress: address
    /// Two-bit contract type tag for vault.
    contractType: uint2
    /// Native asset variant represented by this vault.
    asset: CoffeeAsset
}

/// Native TON asset tag.
struct (0b00) CoffeeNativeAsset {}

/// Jetton asset tag with workchain byte and account hash.
struct (0b01) CoffeeJettonAsset {
    /// Jetton minter workchain id encoded by Coffee as uint8.
    chain: uint8
    /// Jetton minter account hash.
    hash: uint256
}

/// Extra-currency asset tag.
struct (0b10) CoffeeExtraAsset {
    /// Extra-currency id from the inbound message currency collection.
    id: uint32
}

/// Coffee asset variants used by vault init data, pool params, and swap hints.
type CoffeeAsset =
    | CoffeeNativeAsset
    | CoffeeJettonAsset
    | CoffeeExtraAsset

/// Empty previous-asset hint for first-hop vault-to-pool swaps.
struct (0b0) CoffeeNoPreviousAssetHint {}

/// Present previous-asset hint used by later same-pair swap hops.
struct (0b1) CoffeeSomePreviousAssetHint {
    /// Asset received on the previous swap step.
    asset: CoffeeAsset
}

/// Inline `Maybe Asset` wrapper used by Coffee swap-step internal params.
type CoffeePreviousAssetHint =
    | CoffeeNoPreviousAssetHint
    | CoffeeSomePreviousAssetHint

/// Constant-product AMM tag.
struct (0b000) CoffeeConstantProductAmm {}

/// Curve.fi-style stable AMM tag.
struct (0b001) CoffeeCurveFiStableAmm {}

/// Three-bit Coffee AMM strategy tag.
type CoffeeAmm =
    | CoffeeConstantProductAmm
    | CoffeeCurveFiStableAmm

/// No condition for a liquidity deposit.
struct (0b00) CoffeeNoDepositLiquidityCondition {}

/// Minimum LP-token quantity condition.
struct (0b01) CoffeeLpQuantityDepositLiquidityCondition {
    /// Minimum acceptable LP amount.
    minLpAmount: coins
}

/// Pool-reserve ratio guard for liquidity deposits.
struct (0b10) CoffeeReservesRatioDepositLiquidityCondition {
    /// Ratio denominator used with both nominators.
    denominator: uint16
    /// Minimum acceptable reserve ratio numerator.
    minNominator: uint16
    /// Maximum acceptable reserve ratio numerator.
    maxNominator: uint16
}

/// Combined LP-quantity and reserve-ratio liquidity condition.
struct (0b11) CoffeeComplexDepositLiquidityCondition {
    /// Minimum acceptable LP amount.
    minLpAmount: coins
    /// Ratio denominator used with both nominators.
    denominator: uint16
    /// Minimum acceptable reserve ratio numerator.
    minNominator: uint16
    /// Maximum acceptable reserve ratio numerator.
    maxNominator: uint16
}

/// Deposit-liquidity condition variants used inside trimmed deposit params.
type CoffeeDepositLiquidityCondition =
    | CoffeeNoDepositLiquidityCondition
    | CoffeeLpQuantityDepositLiquidityCondition
    | CoffeeReservesRatioDepositLiquidityCondition
    | CoffeeComplexDepositLiquidityCondition

/// Pool identity tuple used in public vault messages and factory requests.
struct CoffeePoolParams {
    /// First pool asset supplied in the pool identity tuple.
    first: CoffeeAsset
    /// Second pool asset supplied in the pool identity tuple.
    second: CoffeeAsset
    /// Three-bit AMM strategy.
    amm: CoffeeAmm
    /// Optional AMM settings reference.
    ammSettings: cell?
}

/// Public parameters for creating a pool from a vault request.
struct CoffeePublicPoolCreationParams {
    /// Recipient of LP tokens on success and optionally funds on failure.
    recipient: address
    /// One-bit flag selecting recipient instead of initiator for failure returns.
    useRecipientOnFailure: int1
    /// Optional notification settings cell forwarded to pool-creator/factory flows.
    notificationData: cell?
}

/// Private/admin-side pool creation parameters.
struct CoffeePrivatePoolCreationParams {
    /// Initial pool activity flag.
    isActive: uint1
    /// Optional reserved settings for future pool features.
    extraSettings: cell?
}

/// Full pool creation parameters stored inline in user messages and by ref in factory requests.
struct CoffeePoolCreationParams {
    /// Public recipient and notification parameters.
    publicValue: CoffeePublicPoolCreationParams
    /// Private activation and extra-settings parameters.
    privateValue: CoffeePrivatePoolCreationParams
}

/// Single notification routing instruction.
struct CoffeeNotificationDataSingle {
    /// Notification receiver; `addr_none` means the payout recipient.
    receiver: address?
    /// TON value attached when sending a separate notification message.
    fwdGas: coins
    /// Referenced notification payload.
    payload: cell
}

/// Success/failure notification routing options.
struct CoffeeNotificationData {
    /// Optional success notification.
    onSuccess: Cell<CoffeeNotificationDataSingle>?
    /// Optional failure notification.
    onFailure: Cell<CoffeeNotificationDataSingle>?
}

/// Whole-swap parameters referenced from swap messages.
struct CoffeeSwapParams {
    /// Unix deadline for downstream pool validation.
    deadline: uint32
    /// Final recipient of swap proceeds.
    recipient: address
    /// Optional referral address; `addr_none` disables referral attribution.
    referral: address?
    /// Optional success/failure notification settings.
    notificationData: Cell<CoffeeNotificationData>?
}

/// Public swap step parameters.
struct CoffeeSwapStepParams {
    /// Hash part of the target pool address in basechain.
    poolAddressHash: uint256
    /// Minimum output amount accepted for this step.
    minOutputAmount: coins
    /// Optional next hop.
    next: Cell<CoffeeSwapStepParams>?
}

/// Internal swap-step parameters sent from a vault to a pool.
struct CoffeeSwapStepInternalParams {
    /// Amount supplied to the current pool step.
    previousAmount: coins
    /// Inline maybe-asset hint for first-hop or later swap steps.
    previousAssetHint: CoffeePreviousAssetHint
    /// Minimum output amount accepted for this step.
    minOutputAmount: coins
    /// Optional next hop copied from the user step.
    next: Cell<CoffeeSwapStepParams>?
}

/// Trimmed liquidity-deposit params referenced inside `CoffeeDepositLiquidityParams`.
struct CoffeeDepositLiquidityParamsTrimmed {
    /// Recipient of LP tokens on success and optionally funds on failure.
    recipient: address
    /// One-bit flag selecting recipient instead of initiator for failure returns.
    useRecipientOnFailure: int1
    /// Referral address recorded for analytics.
    referral: address
    /// Unix deadline for downstream liquidity-deposit validation.
    deadline: uint32
    /// User-selected deposit condition.
    condition: CoffeeDepositLiquidityCondition
    /// Optional reserved settings for future pool features.
    extraSettings: cell?
    /// Optional success/failure notification settings.
    notificationData: Cell<CoffeeNotificationData>?
}

/// Public liquidity-deposit params: trimmed params ref plus pool params ref.
struct CoffeeDepositLiquidityParams {
    /// Referenced recipient/deadline/condition data.
    params: Cell<CoffeeDepositLiquidityParamsTrimmed>
    /// Referenced pool identity tuple.
    poolParams: Cell<CoffeePoolParams>
}

/// Optional code/data update payload accepted only from the Factory.
struct CoffeeContractUpdate {
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement data cell.
    data: cell?
}

/// Pool-authorized payout request accepted by vaults.
struct (0xc0ffee21) CoffeePayoutInternal {
    /// Query id copied into payout or notification messages.
    queryId: uint64
    /// Recipient that receives the native payout.
    recipient: address
    /// Amount of native TON released by the vault.
    amount: coins
    /// Optional notification instruction.
    notificationData: Cell<CoffeeNotificationDataSingle>?
    /// Optional deterministic proof for authenticating the sender.
    proof: cell?
}

/// User-originated native TON swap request.
struct (0xc0ffee00) CoffeeSwapNative {
    /// User-selected query id.
    queryId: uint64
    /// Native TON amount to swap; must be lower than inbound message value.
    amount: coins
    /// First-hop pool hash, slippage limit, and optional next step.
    step: CoffeeSwapStepParams
    /// Referenced whole-swap options.
    params: Cell<CoffeeSwapParams>
}

/// User-originated native liquidity-deposit request.
struct (0xc0ffee04) CoffeeDepositLiquidityNative {
    /// User-selected query id.
    queryId: uint64
    /// Native TON amount to deposit.
    inputAmount: coins
    /// Referenced deposit and pool parameters.
    params: CoffeeDepositLiquidityParams
}

/// User-originated native pool-creation request.
struct (0xc0ffee02) CoffeeCreatePoolNative {
    /// User-selected query id.
    queryId: uint64
    /// Native TON amount used as initial liquidity.
    amount: coins
    /// Pool identity tuple.
    params: CoffeePoolParams
    /// Public/private creation parameters.
    creationParams: CoffeePoolCreationParams
}

/// Factory-originated code/data update request.
struct (0xc0ffee2e) CoffeeUpdateContractInternal {
    /// Query id copied into the outgoing excesses message.
    queryId: uint64
    /// Address that receives post-update excesses.
    excessesReceiver: address
    /// Optional replacement code/data cells.
    update: CoffeeContractUpdate
}

/// Notification body sent when payout notification data is present.
struct (0xc0ffee36) CoffeeNotification {
    /// Query id copied from the triggering request.
    queryId: uint64
    /// Original user notification payload.
    body: cell
}

/// Native payout marker body sent to the payout recipient.
struct (0xc0ffee32) CoffeePayout {
    /// Query id copied from `payout_internal`.
    queryId: uint64
}

/// Vault-to-pool swap message for the first hop.
struct (0xc0ffee20) CoffeeSwapInternal {
    /// Query id copied from the user request.
    queryId: uint64
    /// Amount, optional asset hint, minimum output, and continuation.
    step: CoffeeSwapStepInternalParams
    /// Referenced whole-swap options.
    params: Cell<CoffeeSwapParams>
    /// Vault init-data proof reference.
    proof: cell
}

/// Vault-to-factory liquidity-depository creation request.
struct (0xc0ffee27) CoffeeCreateLiquidityDepositoryRequest {
    /// Query id copied from the user request.
    queryId: uint64
    /// Amount of this vault asset supplied by the user.
    amount: coins
    /// Referenced deposit and pool parameters.
    params: CoffeeDepositLiquidityParams
    /// Address that initiated the vault request.
    sender: address
    /// Vault init-data proof reference.
    proof: cell
}

/// Vault-to-factory pool-creator creation request.
struct (0xc0ffee23) CoffeeCreatePoolCreatorRequest {
    /// Query id copied from the user request.
    queryId: uint64
    /// Amount of this vault asset supplied as initial liquidity.
    amount: coins
    /// Sorted pool identity tuple.
    params: CoffeePoolParams
    /// Referenced public/private creation parameters.
    creationParams: Cell<CoffeePoolCreationParams>
    /// Address that initiated the vault request.
    sender: address
    /// Vault init-data proof reference.
    proof: cell
}

/// Standard excesses body emitted by the shared update helper.
struct (0xd53276db) CoffeeExcesses {
    /// Query id copied from `update_contract_internal`.
    queryId: uint64
}

/// Internal message bodies accepted by Coffee Native Vault.
type CoffeeVaultNativeIncomingMessage =
    | CoffeePayoutInternal
    | CoffeeSwapNative
    | CoffeeDepositLiquidityNative
    | CoffeeCreatePoolNative
    | CoffeeUpdateContractInternal

/// Internal message bodies emitted by Coffee Native Vault.
type CoffeeVaultNativeOutgoingMessage =
    | CoffeeNotification
    | CoffeePayout
    | CoffeeSwapInternal
    | CoffeeCreateLiquidityDepositoryRequest
    | CoffeeCreatePoolCreatorRequest
    | CoffeeExcesses

/// Exit codes surfaced by native vault operations.
enum Errors {
    /// Incoming internal message opcode is unsupported.
    UnknownOpcode = 6
    /// Attached TON or requested amount fails the gas requirement.
    NotEnoughGas = 40
    /// Internal parser or asset-ordering invariant failed.
    Unexpected = 250
    /// Sender is not the configured Factory address.
    NotAFactory = 253
    /// Address workchain is not supported by this vault.
    WrongChain = 255
    /// Pool identity contains the same asset twice.
    SameAssets = 257
    /// Deterministic proof cell does not authenticate the sender.
    WrongSignature = 258
    /// Serialized asset tag is unsupported.
    InvalidAssetType = 267
}

/// Return the serialized Coffee asset represented by this vault.
get fun get_asset(): slice {
    throw 0;
}

/// Return whether the native vault is active.
get fun is_active(): bool {
    throw 0;
}
