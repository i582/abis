/// Coffee DEX PoolCreator helper that escrows first-side pool-creation liquidity until the second asset arrives.
contract CoffeePoolCreator {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee DEX PoolCreator utility contract ABI for initial pool-creation escrow, cancellation, Factory callbacks, and update handling."
    storage: CoffeePoolCreatorStorage
    incomingMessages: CoffeePoolCreatorIncomingMessage
    outgoingMessages: CoffeePoolCreatorOutgoingMessage
}

/// Runtime storage cell installed by Factory deploy for a derived PoolCreator address.
struct CoffeePoolCreatorStorage {
    /// Shared init/deploy code cell used to derive vault and child contract addresses.
    initCodeCell: cell
    /// Proof/init data cell containing factory, owner, asset pair, AMM, and AMM settings.
    initDataCell: Cell<CoffeePoolCreatorInitData>
    /// Amount of sorted first asset currently escrowed for initial pool creation.
    amount1: coins
    /// Amount of sorted second asset currently escrowed for initial pool creation.
    amount2: coins
}

/// PoolCreator init/proof data stored by reference and reused as inter-contract proof.
struct CoffeePoolCreatorInitData {
    /// Factory address that deployed and authenticates this derived contract.
    factoryAddress: address
    /// Two-bit Coffee contract type; PoolCreator uses `3`.
    contractType: uint2
    /// User/admin that initiated the pool creation and can withdraw a half deposit.
    ownerAddress: address
    /// Referenced sorted pair and AMM identity for this PoolCreator instance.
    poolParams: Cell<CoffeePoolCreatorInitPoolParams>
}

/// Referenced pair/AMM tail inside PoolCreator init data.
struct CoffeePoolCreatorInitPoolParams {
    /// First asset after Coffee canonical sorting.
    asset1: CoffeePoolCreatorAsset
    /// Second asset after Coffee canonical sorting.
    asset2: CoffeePoolCreatorAsset
    /// AMM strategy encoded on 3 bits.
    amm: CoffeePoolCreatorAmm
    /// Optional AMM-specific settings cell.
    ammSettings: cell?
}

/// Native TON asset tag used by Coffee asset cells.
struct (0b00) CoffeePoolCreatorAssetNative {}

/// Jetton asset tag carrying workchain and address hash.
struct (0b01) CoffeePoolCreatorAssetJetton {
    /// Workchain id copied from the Jetton master address.
    chain: uint8
    /// Jetton master address hash bits.
    hash: uint256
}

/// Extra-currency asset tag carrying the currency id.
struct (0b10) CoffeePoolCreatorAssetExtra {
    /// Extra-currency id.
    id: uint32
}

/// Coffee asset union used in PoolCreator storage proofs and messages.
type CoffeePoolCreatorAsset =
    | CoffeePoolCreatorAssetNative
    | CoffeePoolCreatorAssetJetton
    | CoffeePoolCreatorAssetExtra

/// Constant-product AMM tag.
struct (0b000) CoffeePoolCreatorAmmConstantProduct {}

/// Curve.fi-style stable AMM tag.
struct (0b001) CoffeePoolCreatorAmmCurveFiStable {}

/// Coffee AMM strategy union encoded on three bits.
type CoffeePoolCreatorAmm =
    | CoffeePoolCreatorAmmConstantProduct
    | CoffeePoolCreatorAmmCurveFiStable

/// Optional notification target/payload cell used by generic Coffee payout messages.
struct CoffeePoolCreatorNotificationDataSingle {
    /// Receiver for the notification; `addr_none` uses the operation recipient.
    receiver: address?
    /// Nanotons forwarded with the notification.
    fwdGas: coins
    /// Referenced user payload.
    payload: cell
}

/// Public pool-creation parameters supplied by the transaction initiator.
struct CoffeePoolCreatorPublicPoolCreationParams {
    /// LP recipient on success and optional failure recipient.
    recipient: address
    /// If true, failed first-side funds are returned to `recipient`; otherwise to the owner.
    useRecipientOnFailure: int1
    /// Optional raw notification-data cell.
    notificationData: cell?
}

/// Private pool-creation parameters controlled by the Factory/admin path.
struct CoffeePoolCreatorPrivatePoolCreationParams {
    /// Initial pool active flag forwarded into Pool deployment.
    isActive: uint1
    /// Optional AMM-specific or future pool settings.
    extraSettings: cell?
}

/// Full pool-creation parameter cell passed through PoolCreator to Factory.
struct CoffeePoolCreatorPoolCreationParams {
    /// Public user-selected creation parameters.
    publicParams: CoffeePoolCreatorPublicPoolCreationParams
    /// Private/admin creation parameters.
    privateParams: CoffeePoolCreatorPrivatePoolCreationParams
}

/// Generic Coffee contract-update payload.
struct CoffeePoolCreatorContractUpdate {
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement persistent data cell.
    data: cell?
}

/// Factory deploy body for installing PoolCreator code and storage.
struct (0xc0ffee22) CoffeePoolCreatorDeploy {
    /// Query id for the install operation.
    queryId: uint64
    /// Runtime PoolCreator code installed by the shared init contract.
    code: cell
    /// Runtime PoolCreator storage cell.
    data: cell
    /// Optional action body recursively executed after code/data installation.
    action: cell?
}

/// Factory-to-PoolCreator deposit notice for one side of initial liquidity.
struct (0xc0ffee24) CoffeePoolCreatorCreatePoolCreatorInternal {
    /// Query id propagated from the initiating vault request.
    queryId: uint64
    /// Asset carried by the sending vault and matched against this PoolCreator pair.
    asset: CoffeePoolCreatorAsset
    /// Amount of that asset deposited for pool creation.
    amount: coins
    /// Referenced pool-creation parameters forwarded when both assets arrive.
    creationParams: Cell<CoffeePoolCreatorPoolCreationParams>
}

/// Owner cancellation request that returns the currently escrowed side and destroys the helper.
struct (0xc0ffee07) CoffeePoolCreatorWithdrawDeposit {
    /// Query id copied into the payout request.
    queryId: uint64
}

/// Factory administrative update body accepted by PoolCreator.
struct (0xc0ffee2e) CoffeePoolCreatorUpdateContractInternal {
    /// Query id copied into the outgoing excesses response.
    queryId: uint64
    /// Address receiving remaining TON after the update.
    excessesReceiver: address
    /// Optional code/data update payload.
    update: CoffeePoolCreatorContractUpdate
}

/// PoolCreator-to-Factory request emitted once both initial liquidity sides are present.
struct (0xc0ffee25) CoffeePoolCreatorCreatePoolRequest {
    /// Query id propagated through the pool-creation flow.
    queryId: uint64
    /// Stored first-asset amount.
    amount1: coins
    /// Stored second-asset amount.
    amount2: coins
    /// Original pool-creation initiator stored as owner in init data.
    txInitiator: address
    /// Referenced creation parameters from the latest deposit message.
    creationParams: Cell<CoffeePoolCreatorPoolCreationParams>
    /// PoolCreator init/proof cell proving the sender-derived address.
    proof: Cell<CoffeePoolCreatorInitData>
}

/// PoolCreator-to-Vault payout request for duplicate deposits or owner cancellation.
struct (0xc0ffee21) CoffeePoolCreatorPayoutInternal {
    /// Query id propagated from the triggering message.
    queryId: uint64
    /// Address that should receive the returned asset amount.
    recipient: address
    /// Amount to pay out through the target asset vault.
    amount: coins
    /// Optional notification data.
    notificationData: Cell<CoffeePoolCreatorNotificationDataSingle>?
    /// Optional PoolCreator proof cell.
    proof: Cell<CoffeePoolCreatorInitData>?
}

/// Standard Jetton-style excesses body emitted after a successful contract update.
struct (0xd53276db) CoffeePoolCreatorExcesses {
    /// Query id copied from `update_contract_internal`.
    queryId: uint64
}

/// Internal message bodies accepted by Coffee PoolCreator.
type CoffeePoolCreatorIncomingMessage =
    | CoffeePoolCreatorCreatePoolCreatorInternal
    | CoffeePoolCreatorDeploy
    | CoffeePoolCreatorWithdrawDeposit
    | CoffeePoolCreatorUpdateContractInternal

/// Internal message bodies emitted by Coffee PoolCreator.
type CoffeePoolCreatorOutgoingMessage =
    | CoffeePoolCreatorCreatePoolRequest
    | CoffeePoolCreatorPayoutInternal
    | CoffeePoolCreatorExcesses

/// PoolCreator error codes.
enum CoffeePoolCreatorErrors {
    /// Incoming opcode is not supported by PoolCreator.
    UnknownOpcode = 6
    /// Deposit asset is not one of the two assets bound to this helper.
    InvalidRequest = 251
    /// Owner-only cancellation was sent by another address.
    WrongSender = 252
    /// Factory-only message was sent by another address.
    NotAFactory = 253
    /// Duplicate side deposit caused PoolCreator to refund and throw.
    InvalidLiquidity = 264
    /// Asset tag was not one of native, jetton, or extra.
    InvalidAssetType = 267
}
