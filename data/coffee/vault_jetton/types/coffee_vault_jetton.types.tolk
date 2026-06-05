/// Coffee Swap jetton vault for routing jetton transfer notifications into swaps, deposits, pool creation, and payouts.
contract CoffeeVaultJetton {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee Swap Jetton Vault ABI for jetton transfer notifications, swaps, liquidity deposits, pool creation, payouts, and wallet activation."
    storage: CoffeeVaultJettonActiveStorage
    storageAtDeployment: CoffeeVaultJettonInactiveStorage
    incomingMessages: CoffeeVaultJettonIncomingMessage
    outgoingMessages: CoffeeVaultJettonOutgoingMessage
    forceAbiExport: CoffeeVaultJettonForwardPayload
}

/// Active runtime root data after the vault stores its jetton wallet address.
struct CoffeeVaultJettonActiveStorage {
    /// Code cell paired with `initData` for deterministic child-contract proofs.
    initCode: cell
    /// Referenced vault init data containing Factory address, vault type tag, and jetton asset tag.
    initData: Cell<CoffeeVaultInitData>
    /// Active flag.
    isActive: bool
    /// Vault-owned jetton wallet address present only in active storage.
    jettonWalletAddress: address
}

/// Inactive storage before `take_wallet_address` or `activate_vault_internal`.
struct CoffeeVaultJettonInactiveStorage {
    /// Code cell paired with `initData` for deterministic child-contract proofs.
    initCode: cell
    /// Referenced vault init data containing Factory address, vault type tag, and jetton asset tag.
    initData: Cell<CoffeeVaultInitData>
    /// Inactive flag; no wallet address follows this field.
    isActive: bool
}

/// Vault init-data cell shared by Coffee vault variants and proof references.
struct CoffeeVaultInitData {
    /// Factory address that owns and authenticates this vault family.
    factoryAddress: address
    /// Two-bit contract type tag for vault.
    contractType: uint2
    /// Jetton asset represented by this vault.
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

/// Pool identity tuple used in forward payloads and factory requests.
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

/// Public parameters for creating a pool from a forward payload.
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

/// Full pool creation parameters stored inline in user payloads and by ref in factory requests.
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

/// Whole-swap parameters referenced from swap payloads.
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

/// Jetton-wallet transfer notification accepted by active jetton vaults.
struct (0x7362d09c) CoffeeTransferNotification {
    /// Query id from the jetton transfer notification.
    queryId: uint64
    /// Jetton amount received by the vault-owned wallet.
    amount: coins
    /// Original owner that sent jettons.
    sender: address
    /// Required referenced Coffee forward payload.
    forwardPayload: Cell<CoffeeVaultJettonForwardPayload>
}

/// Jetton forward payload for swapping the transferred jettons.
struct (0xc0ffee10) CoffeeSwapJetton {
    /// First-hop pool hash, slippage limit, and optional next step.
    step: CoffeeSwapStepParams
    /// Referenced whole-swap options.
    params: Cell<CoffeeSwapParams>
}

/// Jetton forward payload for depositing the transferred jettons as liquidity.
struct (0xc0ffee12) CoffeeDepositLiquidityJetton {
    /// Referenced deposit and pool parameters.
    params: CoffeeDepositLiquidityParams
}

/// Jetton forward payload for pool creation with transferred jettons as initial liquidity.
struct (0xc0ffee11) CoffeeCreatePoolJetton {
    /// Pool identity tuple.
    params: CoffeePoolParams
    /// Public/private creation parameters.
    creationParams: CoffeePoolCreationParams
}

/// Supported Coffee forward payloads embedded in jetton transfer notifications.
type CoffeeVaultJettonForwardPayload =
    | CoffeeSwapJetton
    | CoffeeDepositLiquidityJetton
    | CoffeeCreatePoolJetton

/// Pool-authorized payout request accepted by active jetton vaults.
struct (0xc0ffee21) CoffeePayoutInternal {
    /// Query id copied into outgoing jetton transfer or notification messages.
    queryId: uint64
    /// Recipient that receives the jetton payout.
    recipient: address
    /// Jetton amount released by the vault-owned wallet.
    amount: coins
    /// Optional notification instruction.
    notificationData: Cell<CoffeeNotificationDataSingle>?
    /// Optional deterministic proof for authenticating the sender.
    proof: cell?
}

/// Factory request that asks an inactive vault to discover its jetton wallet.
struct (0xc0ffee2a) CoffeeCreateVaultInternal {
    /// Query id copied into the outgoing wallet-discovery request.
    queryId: uint64
}

/// Jetton master response that activates the vault.
struct (0xd1735400) CoffeeTakeWalletAddress {
    /// Query id from the jetton wallet-discovery response.
    queryId: uint64
    /// Vault-owned jetton wallet address to persist.
    walletAddress: address
    /// Remaining TEP-89 include-address bit/ref tail.
    tail: RemainingBitsAndRefs
}

/// Factory request that directly activates an inactive jetton vault.
struct (0xc0ffee2c) CoffeeActivateVaultInternal {
    /// Query id carried by the factory request.
    queryId: uint64
    /// Vault-owned jetton wallet address to persist.
    wallet: address
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

/// Vault-to-pool swap message for the first hop.
struct (0xc0ffee20) CoffeeSwapInternal {
    /// Query id copied from the jetton transfer notification.
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
    /// Query id copied from the jetton transfer notification.
    queryId: uint64
    /// Amount of this vault asset supplied by the user.
    amount: coins
    /// Referenced deposit and pool parameters.
    params: CoffeeDepositLiquidityParams
    /// Original jetton sender owner.
    sender: address
    /// Vault init-data proof reference.
    proof: cell
}

/// Vault-to-factory pool-creator creation request.
struct (0xc0ffee23) CoffeeCreatePoolCreatorRequest {
    /// Query id copied from the jetton transfer notification.
    queryId: uint64
    /// Amount of this vault asset supplied as initial liquidity.
    amount: coins
    /// Sorted pool identity tuple.
    params: CoffeePoolParams
    /// Referenced public/private creation parameters.
    creationParams: Cell<CoffeePoolCreationParams>
    /// Original jetton sender owner.
    sender: address
    /// Vault init-data proof reference.
    proof: cell
}

/// Jetton transfer body sent to the vault-owned wallet for payouts and safe refunds.
struct (0x0f8a7ea5) CoffeeJettonTransfer {
    /// Query id copied from the triggering request.
    queryId: uint64
    /// Jetton amount to transfer.
    amount: coins
    /// Jetton transfer destination.
    destination: address
    /// Address that receives transfer excesses.
    responseDestination: address
    /// Optional custom payload; Coffee vault stores `none`.
    customPayload: cell?
    /// TON amount attached to the recipient notification.
    forwardTonAmount: coins
    /// Raw TEP-74 forward-payload tail for empty or notification-ref forms.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-discovery request sent by an inactive vault to the jetton master.
struct (0x2c76b973) CoffeeProvideWalletAddress {
    /// Query id copied from `create_vault_internal`.
    queryId: uint64
    /// Owner address whose wallet is requested.
    ownerAddress: address
    /// Include-address flag.
    includeAddress: bool
}

/// Standard excesses body emitted by the shared update helper.
struct (0xd53276db) CoffeeExcesses {
    /// Query id copied from `update_contract_internal`.
    queryId: uint64
}

/// Internal message bodies accepted by Coffee Jetton Vault.
type CoffeeVaultJettonIncomingMessage =
    | CoffeeTransferNotification
    | CoffeePayoutInternal
    | CoffeeCreateVaultInternal
    | CoffeeTakeWalletAddress
    | CoffeeActivateVaultInternal
    | CoffeeUpdateContractInternal

/// Internal message bodies emitted by Coffee Jetton Vault.
type CoffeeVaultJettonOutgoingMessage =
    | CoffeeNotification
    | CoffeeSwapInternal
    | CoffeeCreateLiquidityDepositoryRequest
    | CoffeeCreatePoolCreatorRequest
    | CoffeeJettonTransfer
    | CoffeeProvideWalletAddress
    | CoffeeExcesses

/// Exit codes surfaced by jetton vault operations.
enum Errors {
    /// Incoming internal message opcode is unsupported.
    UnknownOpcode = 6
    /// Attached TON fails the gas requirement.
    NotEnoughGas = 40
    /// Internal parser or activation invariant failed.
    Unexpected = 250
    /// Sender is not the expected jetton wallet or jetton master.
    WrongSender = 252
    /// Sender is not the configured Factory address.
    NotAFactory = 253
    /// Address workchain is not supported by this vault.
    WrongChain = 255
    /// Pool identity contains the same asset twice.
    SameAssets = 257
    /// Deterministic proof cell does not authenticate the sender.
    WrongSignature = 258
    /// Inbound jetton amount is zero or invalid.
    InvalidBalance = 259
    /// Jetton wallet discovery response is malformed.
    InvalidJettonMaster = 260
    /// Serialized asset tag is unsupported.
    InvalidAssetType = 267
    /// Activation was requested after wallet address setup.
    AlreadyActive = 272
    /// Operation requires an active jetton vault.
    NotActive = 273
}

/// Return the serialized Coffee asset represented by this vault.
get fun get_asset(): slice {
    assert (true) throw Errors.UnknownOpcode;
    assert (true) throw Errors.NotEnoughGas;
    assert (true) throw Errors.Unexpected;
    assert (true) throw Errors.WrongSender;
    assert (true) throw Errors.NotAFactory;
    assert (true) throw Errors.WrongChain;
    assert (true) throw Errors.SameAssets;
    assert (true) throw Errors.WrongSignature;
    assert (true) throw Errors.InvalidBalance;
    assert (true) throw Errors.InvalidJettonMaster;
    assert (true) throw Errors.InvalidAssetType;
    assert (true) throw Errors.AlreadyActive;
    assert (true) throw Errors.NotActive;
    return createEmptyCell().beginParse();
}

/// Return active status.
get fun is_active(): bool {
    return false;
}
