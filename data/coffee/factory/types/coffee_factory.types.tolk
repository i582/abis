/// Curated ABI for the Coffee Swap DEX Factory contract.
contract CoffeeFactory {
    author: "Coffee Swap"
    version: "1.0"
    description: "Coffee Swap Factory ABI for deterministic child deployment, vault, pool, helper address derivation, pool administration, code-cell updates, and protocol-fee withdrawal."
    storage: CoffeeFactoryStorage
    incomingMessages: CoffeeFactoryIncomingMessage
    outgoingMessages: CoffeeFactoryOutgoingMessage
    forceAbiExport: CoffeeFactoryDeployAction | CoffeeFactoryVaultProof | CoffeeFactoryPoolCreatorProof | CoffeeFactoryPoolUpdateParams
}

/// Root Factory storage loaded by `factory.fc`.
struct CoffeeFactoryStorage {
    /// Factory administrator authorized for administrative messages.
    adminAddress: address
    /// Address authorized to request protocol-fee withdrawals.
    withdrawerAddress: address
    /// Child contract code cells stored in the first storage reference.
    codeCells: Cell<CoffeeFactoryCodeCells>
    /// Vault and Pool implementation dictionaries stored in the second storage reference.
    codeDictionaries: Cell<CoffeeFactoryCodeDictionaries>
    /// Optional initialization tail retained by upstream builder serializers.
    compatibilityTail: RemainingBitsAndRefs
}

/// First code-cell bundle: four refs validated by `update_code_cells`.
struct CoffeeFactoryCodeCells {
    /// LP Jetton wallet code forwarded into newly deployed pools.
    lpWalletCode: cell
    /// Blank Init code used for deterministic child deployments.
    initCode: cell
    /// Liquidity Depository implementation code.
    liquidityDepositoryCode: cell
    /// Pool Creator implementation code.
    poolCreatorCode: cell
}

/// Second code-cell bundle: two dictionaries validated by `update_code_cells`.
struct CoffeeFactoryCodeDictionaries {
    /// Vault implementation code dictionary keyed by two-bit Coffee asset type.
    vaultCodeByAssetType: map<uint2, cell>
    /// Pool implementation code dictionary keyed by three-bit Coffee AMM type.
    poolCodeByAmm: map<uint3, cell>
}

/// Native TON asset tag.
struct (0b00) CoffeeFactoryNativeAsset {}

/// Jetton asset tag with workchain id and address hash.
struct (0b01) CoffeeFactoryJettonAsset {
    /// Jetton master workchain id encoded as uint8 by upstream serializers.
    chain: uint8
    /// Jetton master address hash.
    hash: uint256
}

/// Extra-currency asset tag with 32-bit currency id.
struct (0b10) CoffeeFactoryExtraAsset {
    /// Extra-currency id.
    id: uint32
}

/// Coffee asset variants accepted by `load_asset`.
type CoffeeFactoryAsset =
    | CoffeeFactoryNativeAsset
    | CoffeeFactoryJettonAsset
    | CoffeeFactoryExtraAsset

/// Constant-product AMM tag encoded as three bits.
struct (0b000) CoffeeFactoryConstantProductAmm {}

/// Curve.fi-style stable AMM tag encoded as three bits.
struct (0b001) CoffeeFactoryCurveFiStableAmm {}

/// Coffee AMM variants installed by the upstream Factory code dictionary.
type CoffeeFactoryAmm =
    | CoffeeFactoryConstantProductAmm
    | CoffeeFactoryCurveFiStableAmm

/// Pool identity used for address derivation and deployment requests.
struct CoffeeFactoryPoolParams {
    /// First user-supplied asset before canonical sorting.
    first: CoffeeFactoryAsset
    /// Second user-supplied asset before canonical sorting.
    second: CoffeeFactoryAsset
    /// AMM implementation selector stored as a three-bit value.
    amm: CoffeeFactoryAmm
    /// Optional AMM settings cell included in stable/custom derivation.
    ammSettings: cell?
}

/// Public part of Pool creation parameters.
struct CoffeeFactoryPublicPoolCreationParams {
    /// Recipient of LP tokens on success, and optionally refund recipient on failure.
    recipient: address
    /// If true, failure refunds go to `recipient` instead of the transaction initiator.
    useRecipientOnFailure: int1
    /// Optional notification-data cell proposed by the initiator.
    notificationData: cell?
}

/// Private/admin-only part of Pool creation parameters.
struct CoffeeFactoryPrivatePoolCreationParams {
    /// Initial Pool active flag.
    isActive: uint1
    /// Reserved extra settings cell; non-admin public pool creation requires this to be absent.
    extraSettings: cell?
}

/// Full Pool creation parameters.
struct CoffeeFactoryPoolCreationParams {
    /// Publicly usable creation parameters.
    publicParams: CoffeeFactoryPublicPoolCreationParams
    /// Private/admin-only creation parameters.
    privateParams: CoffeeFactoryPrivatePoolCreationParams
}

/// Optional notification target and payload.
struct CoffeeFactoryNotificationDataSingle {
    /// Receiver of the notification message.
    receiver: address
    /// Forwarded gas amount.
    fwdGas: coins
    /// Payload cell sent to the receiver.
    payload: cell
}

/// Success/failure notification pair.
struct CoffeeFactoryNotificationData {
    /// Optional success notification.
    onSuccess: Cell<CoffeeFactoryNotificationDataSingle>?
    /// Optional failure notification.
    onFailure: Cell<CoffeeFactoryNotificationDataSingle>?
}

/// Deposit condition: no lower-bound check.
struct (0b00) CoffeeFactoryDepositNoCondition {}

/// Deposit condition: require a minimum LP amount.
struct (0b01) CoffeeFactoryDepositLpQuantityCondition {
    /// Minimum LP amount required by the initiator.
    minLpAmount: coins
}

/// Deposit condition: require reserve ratio bounds.
struct (0b10) CoffeeFactoryDepositReservesRatioCondition {
    /// Ratio denominator.
    denominator: uint16
    /// Lower numerator bound.
    minNominator: uint16
    /// Upper numerator bound.
    maxNominator: uint16
}

/// Deposit condition: require both minimum LP and reserve ratio bounds.
struct (0b11) CoffeeFactoryDepositComplexCondition {
    /// Minimum LP amount required by the initiator.
    minLpAmount: coins
    /// Ratio denominator.
    denominator: uint16
    /// Lower numerator bound.
    minNominator: uint16
    /// Upper numerator bound.
    maxNominator: uint16
}

/// Liquidity-deposit condition variants.
type CoffeeFactoryDepositLiquidityCondition =
    | CoffeeFactoryDepositNoCondition
    | CoffeeFactoryDepositLpQuantityCondition
    | CoffeeFactoryDepositReservesRatioCondition
    | CoffeeFactoryDepositComplexCondition

/// Referenced user parameters for liquidity deposit.
struct CoffeeFactoryDepositLiquidityParamsTrimmed {
    /// Recipient of LP tokens on success.
    recipient: address
    /// If true, failure refunds go to `recipient` instead of the transaction initiator.
    useRecipientOnFailure: int1
    /// Optional referral address; `addr_none` disables referral.
    referral: address?
    /// Unix timestamp deadline.
    deadline: uint32
    /// Deposit condition.
    condition: CoffeeFactoryDepositLiquidityCondition
    /// Optional AMM-specific extra settings.
    extraSettings: cell?
    /// Optional notification-data pair.
    notificationData: Cell<CoffeeFactoryNotificationData>?
}

/// Full liquidity-deposit parameters: trimmed params and pool identity refs.
struct CoffeeFactoryDepositLiquidityParams {
    /// Referenced user parameters.
    params: Cell<CoffeeFactoryDepositLiquidityParamsTrimmed>
    /// Referenced target Pool identity.
    poolParams: Cell<CoffeeFactoryPoolParams>
}

/// Optional code/data replacement used by update-contract messages.
struct CoffeeFactoryContractUpdate {
    /// Replacement code cell, if any.
    code: cell?
    /// Replacement data cell, if any.
    data: cell?
}

/// Pool update with no fee or status changes.
struct (0b00) CoffeeFactoryPoolNoUpdate {}

/// Pool update that replaces protocol and LP fee nominators.
struct (0b01) CoffeeFactoryPoolFeeUpdate {
    /// New protocol fee nominator.
    protocolFee: uint16
    /// New LP fee nominator.
    lpFee: uint16
}

/// Pool update that changes the active flag.
struct (0b10) CoffeeFactoryPoolStatusUpdate {
    /// New active flag.
    isActive: uint1
}

/// Pool update that changes both fees and active flag.
struct (0b11) CoffeeFactoryPoolFeeAndStatusUpdate {
    /// New protocol fee nominator.
    protocolFee: uint16
    /// New LP fee nominator.
    lpFee: uint16
    /// New active flag.
    isActive: uint1
}

/// Decoded flag variants for `PoolUpdateParams`.
type CoffeeFactoryPoolUpdateParams =
    | CoffeeFactoryPoolNoUpdate
    | CoffeeFactoryPoolFeeUpdate
    | CoffeeFactoryPoolStatusUpdate
    | CoffeeFactoryPoolFeeAndStatusUpdate

/// Proof contract-type tag for Vault children.
struct (0b00) CoffeeFactoryVaultContractType {}

/// Proof contract-type tag for Pool children.
struct (0b01) CoffeeFactoryPoolContractType {}

/// Proof contract-type tag for Liquidity Depository children.
struct (0b10) CoffeeFactoryLiquidityDepositoryContractType {}

/// Proof contract-type tag for Pool Creator children.
struct (0b11) CoffeeFactoryPoolCreatorContractType {}

/// Vault proof/initialization data committed to deterministic Vault addresses.
struct CoffeeFactoryVaultProof {
    /// Factory address committed to the proof.
    factoryAddress: address
    /// Contract-type tag; must be the Vault tag for Factory request senders.
    contractType: CoffeeFactoryVaultContractType
    /// Vault asset committed to the proof.
    asset: CoffeeFactoryAsset
}

/// Pool Creator proof/initialization data committed to deterministic Pool Creator addresses.
struct CoffeeFactoryPoolCreatorProof {
    /// Factory address committed to the proof.
    factoryAddress: address
    /// Contract-type tag; must be the Pool Creator tag for pool deployment requests.
    contractType: CoffeeFactoryPoolCreatorContractType
    /// Owner/initiator committed to the Pool Creator address.
    owner: address
    /// Referenced Pool identity.
    params: Cell<CoffeeFactoryPoolParams>
}

/// Vault request to create a Pool Creator for the second leg of pool creation.
struct (0xc0ffee23) CoffeeFactoryCreatePoolCreatorRequest {
    /// Query id propagated from the initiating Vault request.
    queryId: uint64
    /// Amount of the Vault asset supplied by the user.
    amount: coins
    /// Target Pool identity.
    params: CoffeeFactoryPoolParams
    /// Referenced Pool creation parameters.
    creationParams: Cell<CoffeeFactoryPoolCreationParams>
    /// Original transaction initiator.
    sender: address
    /// Vault proof authenticated by the Factory.
    proof: Cell<CoffeeFactoryVaultProof>
}

/// Vault request to create a Liquidity Depository for liquidity deposit.
struct (0xc0ffee27) CoffeeFactoryCreateLiquidityDepositoryRequest {
    /// Query id propagated from the initiating Vault request.
    queryId: uint64
    /// Amount of the Vault asset supplied by the user.
    amount: coins
    /// Liquidity-deposit parameters containing trimmed params and pool identity refs.
    params: CoffeeFactoryDepositLiquidityParams
    /// Original transaction initiator.
    sender: address
    /// Vault proof authenticated by the Factory.
    proof: Cell<CoffeeFactoryVaultProof>
}

/// Pool Creator request to deploy the final Pool.
struct (0xc0ffee25) CoffeeFactoryCreatePoolRequest {
    /// Query id propagated from Pool Creator.
    queryId: uint64
    /// Amount of the first sorted asset.
    amount1: coins
    /// Amount of the second sorted asset.
    amount2: coins
    /// Original transaction initiator.
    txInitiator: address
    /// Referenced Pool creation parameters.
    creationParams: Cell<CoffeeFactoryPoolCreationParams>
    /// Pool Creator proof authenticated by the Factory.
    proof: Cell<CoffeeFactoryPoolCreatorProof>
}

/// Public request to deploy a Vault for an asset.
struct (0xc0ffee06) CoffeeFactoryCreateVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose deterministic Vault should be deployed.
    asset: CoffeeFactoryAsset
}

/// Admin request to update the Factory administrator.
struct (0xc0ffee40) CoffeeFactoryUpdateAdmin {
    /// Caller-selected query id.
    queryId: uint64
    /// New administrator address.
    address: address?
}

/// Admin request to update the protocol-fee withdrawer.
struct (0xc0ffee46) CoffeeFactoryUpdateWithdrawer {
    /// Caller-selected query id.
    queryId: uint64
    /// New withdrawer address.
    address: address?
}

/// Admin request to replace child code-cell bundles.
struct (0xc0ffee44) CoffeeFactoryUpdateCodeCells {
    /// Caller-selected query id.
    queryId: uint64
    /// First code-cell bundle containing four refs.
    first: Cell<CoffeeFactoryCodeCells>
    /// Second code-cell bundle containing two refs.
    second: Cell<CoffeeFactoryCodeDictionaries>
}

/// Admin request to update the Factory itself or forward an update to another Coffee contract.
struct (0xc0ffee45) CoffeeFactoryUpdateContract {
    /// Caller-selected query id.
    queryId: uint64
    /// Destination contract; `addr_none` means update the Factory itself.
    contractAddress: address?
    /// Optional replacement code/data.
    update: CoffeeFactoryContractUpdate
}

/// Admin request to update a derived Pool.
struct (0xc0ffee41) CoffeeFactoryUpdatePool {
    /// Caller-selected query id.
    queryId: uint64
    /// Target Pool identity.
    poolParams: CoffeeFactoryPoolParams
    /// Referenced Pool update parameters.
    params: Cell<CoffeeFactoryPoolUpdateParams>
}

/// Admin request to activate a Jetton Vault with its wallet address.
struct (0xc0ffee42) CoffeeFactoryActivateVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Jetton asset whose Vault should be activated.
    asset: CoffeeFactoryAsset
    /// Non-empty Vault Jetton wallet address.
    wallet: address
}

/// Withdrawer request to withdraw collected protocol fees through a Pool.
struct (0xc0ffee43) CoffeeFactoryWithdraw {
    /// Caller-selected query id.
    queryId: uint64
    /// Pool that holds collected protocol fees.
    poolAddress: address
    /// Asset to withdraw.
    asset: CoffeeFactoryAsset
    /// Amount to withdraw.
    amount: coins
    /// Receiver of the withdrawn asset.
    receiver: address
}

/// Factory-to-Init install payload.
struct (0xc0ffee22) CoffeeFactoryDeploy {
    /// Query id copied from the Factory request that triggered deployment.
    queryId: uint64
    /// Replacement code installed by the Init contract.
    code: cell
    /// Replacement storage installed by the Init contract.
    data: cell
    /// Optional action body executed after code/data installation.
    action: Cell<CoffeeFactoryDeployAction>?
}

/// Factory-created action body for a newly deployed Pool Creator.
struct (0xc0ffee24) CoffeeFactoryCreatePoolCreatorInternal {
    /// Query id copied from `create_pool_creator_request`.
    queryId: uint64
    /// Asset supplied through the requesting Vault.
    asset: CoffeeFactoryAsset
    /// Amount supplied through the requesting Vault.
    amount: coins
    /// Referenced Pool creation parameters.
    creationParams: Cell<CoffeeFactoryPoolCreationParams>
}

/// Factory-created action body for a newly deployed Liquidity Depository.
struct (0xc0ffee28) CoffeeFactoryCreateLiquidityDepositoryInternal {
    /// Query id copied from `create_liquidity_depository_request`.
    queryId: uint64
    /// Asset supplied through the requesting Vault.
    asset: CoffeeFactoryAsset
    /// Amount supplied through the requesting Vault.
    amount: coins
    /// Referenced trimmed liquidity-deposit parameters.
    params: Cell<CoffeeFactoryDepositLiquidityParamsTrimmed>
}

/// Factory-created action body for a newly deployed Pool.
struct (0xc0ffee26) CoffeeFactoryCreatePoolInternal {
    /// Query id copied from `create_pool_request`.
    queryId: uint64
    /// Initial amount of the first sorted asset.
    amount1: coins
    /// Initial amount of the second sorted asset.
    amount2: coins
    /// Original transaction initiator.
    txInitiator: address
    /// LP recipient on success.
    recipient: address
    /// If true, failure refunds go to `recipient`.
    useRecipientOnFailure: int1
    /// Optional AMM-specific extra settings.
    extraSettings: cell?
    /// Optional notification-data pair.
    notificationData: Cell<CoffeeFactoryNotificationData>?
}

/// Factory-created action body for newly deployed Jetton Vaults.
struct (0xc0ffee2a) CoffeeFactoryCreateVaultInternal {
    /// Query id copied from `create_vault`.
    queryId: uint64
}

/// Factory-to-Pool admin update.
struct (0xc0ffee2b) CoffeeFactoryUpdatePoolInternal {
    /// Query id copied from `update_pool`.
    queryId: uint64
    /// Admin sender address that receives excess TON.
    excessesReceiver: address
    /// Referenced Pool update parameters.
    params: Cell<CoffeeFactoryPoolUpdateParams>
}

/// Factory-to-Vault activation update.
struct (0xc0ffee2c) CoffeeFactoryActivateVaultInternal {
    /// Query id copied from `activate_vault`.
    queryId: uint64
    /// Vault Jetton wallet address.
    wallet: address
}

/// Factory-to-Pool protocol-fee withdrawal request.
struct (0xc0ffee2d) CoffeeFactoryWithdrawInternal {
    /// Query id copied from `withdraw`.
    queryId: uint64
    /// Asset to withdraw.
    asset: CoffeeFactoryAsset
    /// Amount to withdraw.
    amount: coins
    /// Receiver of the withdrawn asset.
    receiver: address
}

/// Factory-to-contract code/data update request.
struct (0xc0ffee2e) CoffeeFactoryUpdateContractInternal {
    /// Query id copied from `update_contract`.
    queryId: uint64
    /// Admin sender address that receives excess TON.
    excessesReceiver: address
    /// Optional replacement code/data.
    update: CoffeeFactoryContractUpdate
}

/// Standard TON excesses response emitted after successful local admin updates.
struct (0xd53276db) CoffeeFactoryExcesses {
    /// Query id copied from the admin request.
    queryId: uint64
}

/// Optional action body embedded in `CoffeeFactoryDeploy`.
type CoffeeFactoryDeployAction =
    | CoffeeFactoryCreatePoolCreatorInternal
    | CoffeeFactoryCreateLiquidityDepositoryInternal
    | CoffeeFactoryCreatePoolInternal
    | CoffeeFactoryCreateVaultInternal

/// Internal message bodies accepted by the Coffee Factory dispatcher.
type CoffeeFactoryIncomingMessage =
    | CoffeeFactoryCreatePoolCreatorRequest
    | CoffeeFactoryCreateLiquidityDepositoryRequest
    | CoffeeFactoryCreatePoolRequest
    | CoffeeFactoryCreateVault
    | CoffeeFactoryUpdateAdmin
    | CoffeeFactoryUpdateWithdrawer
    | CoffeeFactoryUpdateCodeCells
    | CoffeeFactoryUpdateContract
    | CoffeeFactoryUpdatePool
    | CoffeeFactoryActivateVault
    | CoffeeFactoryWithdraw

/// Message bodies constructed by Factory send sites.
type CoffeeFactoryOutgoingMessage =
    | CoffeeFactoryDeploy
    | CoffeeFactoryCreatePoolCreatorInternal
    | CoffeeFactoryCreateLiquidityDepositoryInternal
    | CoffeeFactoryCreatePoolInternal
    | CoffeeFactoryCreateVaultInternal
    | CoffeeFactoryUpdatePoolInternal
    | CoffeeFactoryActivateVaultInternal
    | CoffeeFactoryWithdrawInternal
    | CoffeeFactoryUpdateContractInternal
    | CoffeeFactoryExcesses

/// Structured address/hash getter result.
struct CoffeeFactoryAddressWithHash {
    /// Serialized internal address.
    address: address
    /// Hash part of the returned address.
    hash: int
}

/// Structured `get_code` result containing the two root storage refs.
struct CoffeeFactoryCodeRefs {
    /// First child code-cell bundle.
    first: Cell<CoffeeFactoryCodeCells>
    /// Second child code dictionary bundle.
    second: Cell<CoffeeFactoryCodeDictionaries>
}

/// Factory error codes.
enum CoffeeFactoryErrors {
    /// Incoming opcode is not supported.
    UnknownOpcode = 6
    /// Attached value cannot cover required gas.
    NotEnoughGas = 40
    /// Internal invariant or dispatch branch failed.
    Unexpected = 250
    /// Sender is not authorized for the requested operation.
    WrongSender = 252
    /// Sender is not the Factory administrator.
    NotAnAdmin = 254
    /// Address is outside the base workchain.
    WrongChain = 255
    /// Pool derivation received identical assets.
    SameAssets = 257
    /// Deterministic child-address proof is invalid.
    WrongSignature = 258
    /// AMM selector is not installed.
    UnknownAmm = 261
    /// Asset tag is unsupported.
    InvalidAssetType = 267
}

/// Return deterministic Vault address and hash for a serialized Coffee asset.
get fun get_vault_address(asset: slice): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return deterministic Pool address and hash for serialized Coffee assets, AMM, and settings.
get fun get_pool_address(asset1: slice, asset2: slice, amm: int, ammSettings: cell): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return deterministic Pool address and hash without AMM settings.
get fun get_pool_address_no_settings(asset1: slice, asset2: slice, amm: int): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return deterministic Pool Creator address and hash for owner and Pool identity.
get fun get_pool_creator_address(owner: address, asset1: slice, asset2: slice, amm: int, ammSettings: cell): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return deterministic Pool Creator address and hash without AMM settings.
get fun get_pool_creator_address_no_settings(owner: address, asset1: slice, asset2: slice, amm: int): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return deterministic Liquidity Depository address and hash for owner and Pool identity.
get fun get_liquidity_depository_address(owner: address, asset1: slice, asset2: slice, amm: int, ammSettings: cell): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return deterministic Liquidity Depository address and hash without AMM settings.
get fun get_liquidity_depository_address_no_settings(owner: address, asset1: slice, asset2: slice, amm: int): CoffeeFactoryAddressWithHash {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

/// Return the Factory administrator address.
get fun get_admin_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the two child-code storage refs.
get fun get_code(): CoffeeFactoryCodeRefs {
    return {
        first: createEmptyCell() as Cell<CoffeeFactoryCodeCells>,
        second: createEmptyCell() as Cell<CoffeeFactoryCodeDictionaries>,
    };
}
