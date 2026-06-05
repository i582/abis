/// Coffee DEX LiquidityDepository helper that escrows two-sided liquidity before forwarding it to a Pool.
contract CoffeeLiquidityDepository {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee DEX LiquidityDepository utility contract ABI for liquidity escrow, cancellation, Pool forwarding, Factory callbacks, and update handling."
    storage: CoffeeLiquidityDepositoryStorage
    incomingMessages: CoffeeLiquidityDepositoryIncomingMessage
    outgoingMessages: CoffeeLiquidityDepositoryOutgoingMessage
}

/// Runtime storage cell installed by Factory deploy for a derived LiquidityDepository address.
struct CoffeeLiquidityDepositoryStorage {
    /// Shared init/deploy code cell used to derive pool and vault addresses.
    initCodeCell: cell
    /// Proof/init data cell containing factory, owner, asset pair, AMM, and AMM settings.
    initDataCell: Cell<CoffeeLiquidityDepositoryInitData>
    /// Amount of sorted first asset currently escrowed for liquidity provisioning.
    amount1: coins
    /// Amount of sorted second asset currently escrowed for liquidity provisioning.
    amount2: coins
}

/// LiquidityDepository init/proof data stored by reference and reused as inter-contract proof.
struct CoffeeLiquidityDepositoryInitData {
    /// Factory address that deployed and authenticates this derived contract.
    factoryAddress: address
    /// Two-bit Coffee contract type; LiquidityDepository uses `2`.
    contractType: uint2
    /// User that initiated the deposit and can withdraw a half deposit.
    ownerAddress: address
    /// Referenced sorted pair and AMM identity for this LiquidityDepository instance.
    poolParams: Cell<CoffeeLiquidityDepositoryInitPoolParams>
}

/// Referenced pair/AMM tail inside LiquidityDepository init data.
struct CoffeeLiquidityDepositoryInitPoolParams {
    /// First asset after Coffee canonical sorting.
    asset1: CoffeeLiquidityDepositoryAsset
    /// Second asset after Coffee canonical sorting.
    asset2: CoffeeLiquidityDepositoryAsset
    /// AMM strategy encoded on 3 bits.
    amm: CoffeeLiquidityDepositoryAmm
    /// Optional AMM-specific settings cell.
    ammSettings: cell?
}

/// Native TON asset tag used by Coffee asset cells.
struct (0b00) CoffeeLiquidityDepositoryAssetNative {}

/// Jetton asset tag carrying workchain and address hash.
struct (0b01) CoffeeLiquidityDepositoryAssetJetton {
    /// Workchain id copied from the Jetton master address.
    chain: uint8
    /// Jetton master address hash bits.
    hash: uint256
}

/// Extra-currency asset tag carrying the currency id.
struct (0b10) CoffeeLiquidityDepositoryAssetExtra {
    /// Extra-currency id.
    id: uint32
}

/// Coffee asset union used in LiquidityDepository storage proofs and messages.
type CoffeeLiquidityDepositoryAsset =
    | CoffeeLiquidityDepositoryAssetNative
    | CoffeeLiquidityDepositoryAssetJetton
    | CoffeeLiquidityDepositoryAssetExtra

/// Constant-product AMM tag.
struct (0b000) CoffeeLiquidityDepositoryAmmConstantProduct {}

/// Curve.fi-style stable AMM tag.
struct (0b001) CoffeeLiquidityDepositoryAmmCurveFiStable {}

/// Coffee AMM strategy union encoded on three bits.
type CoffeeLiquidityDepositoryAmm =
    | CoffeeLiquidityDepositoryAmmConstantProduct
    | CoffeeLiquidityDepositoryAmmCurveFiStable

/// No liquidity-deposit guard condition.
struct (0b00) CoffeeLiquidityDepositoryDepositConditionNone {}

/// Minimum LP output guard condition.
struct (0b01) CoffeeLiquidityDepositoryDepositConditionLpQuantity {
    /// Minimum LP amount accepted by the user.
    minLpAmount: coins
}

/// Reserve-ratio guard condition.
struct (0b10) CoffeeLiquidityDepositoryDepositConditionReservesRatio {
    /// Ratio denominator.
    denominator: uint16
    /// Minimum accepted numerator.
    minNominator: uint16
    /// Maximum accepted numerator.
    maxNominator: uint16
}

/// Combined LP quantity and reserve-ratio guard condition.
struct (0b11) CoffeeLiquidityDepositoryDepositConditionComplex {
    /// Minimum LP amount accepted by the user.
    minLpAmount: coins
    /// Ratio denominator.
    denominator: uint16
    /// Minimum accepted numerator.
    minNominator: uint16
    /// Maximum accepted numerator.
    maxNominator: uint16
}

/// Deposit-liquidity guard condition union encoded on two bits.
type CoffeeLiquidityDepositoryDepositLiquidityCondition =
    | CoffeeLiquidityDepositoryDepositConditionNone
    | CoffeeLiquidityDepositoryDepositConditionLpQuantity
    | CoffeeLiquidityDepositoryDepositConditionReservesRatio
    | CoffeeLiquidityDepositoryDepositConditionComplex

/// Optional notification target/payload cell used by Coffee liquidity messages.
struct CoffeeLiquidityDepositoryNotificationDataSingle {
    /// Receiver for the notification; `addr_none` uses the operation recipient.
    receiver: address?
    /// Nanotons forwarded with the notification.
    fwdGas: coins
    /// Referenced user payload.
    payload: cell
}

/// Notification pair used by deposit-liquidity params.
struct CoffeeLiquidityDepositoryNotificationData {
    /// Optional success notification data.
    onSuccess: Cell<CoffeeLiquidityDepositoryNotificationDataSingle>?
    /// Optional failure notification data.
    onFailure: Cell<CoffeeLiquidityDepositoryNotificationDataSingle>?
}

/// Trimmed liquidity params used after the Factory removes pool params.
struct CoffeeLiquidityDepositoryDepositLiquidityParamsTrimmed {
    /// LP recipient on success and optional failure recipient.
    recipient: address
    /// If true, failed funds are returned to `recipient`; otherwise to the owner.
    useRecipientOnFailure: int1
    /// Referral address kept for off-chain analytics.
    referral: address
    /// Unix deadline checked by the Pool, not by LiquidityDepository itself.
    deadline: uint32
    /// User-selected liquidity guard condition.
    condition: CoffeeLiquidityDepositoryDepositLiquidityCondition
    /// Optional future/concentrated-liquidity settings cell.
    extraSettings: cell?
    /// Optional success/failure notification bundle.
    notificationData: Cell<CoffeeLiquidityDepositoryNotificationData>?
}

/// Generic Coffee contract-update payload.
struct CoffeeLiquidityDepositoryContractUpdate {
    /// Optional replacement code cell.
    code: cell?
    /// Optional replacement persistent data cell.
    data: cell?
}

/// Factory deploy body for installing LiquidityDepository code and storage.
struct (0xc0ffee22) CoffeeLiquidityDepositoryDeploy {
    /// Query id for the install operation.
    queryId: uint64
    /// Runtime LiquidityDepository code installed by the shared init contract.
    code: cell
    /// Runtime LiquidityDepository storage cell.
    data: cell
    /// Optional action body recursively executed after code/data installation.
    action: cell?
}

/// Factory-to-LiquidityDepository deposit notice for one side of liquidity.
struct (0xc0ffee28) CoffeeLiquidityDepositoryCreateLiquidityDepositoryInternal {
    /// Query id propagated from the initiating vault request.
    queryId: uint64
    /// Asset carried by the sending vault and matched against this depository pair.
    asset: CoffeeLiquidityDepositoryAsset
    /// Amount of that asset deposited for liquidity provisioning.
    amount: coins
    /// Referenced trimmed liquidity params forwarded when both assets arrive.
    params: Cell<CoffeeLiquidityDepositoryDepositLiquidityParamsTrimmed>
}

/// Owner cancellation request that returns the currently escrowed side and destroys the helper.
struct (0xc0ffee07) CoffeeLiquidityDepositoryWithdrawDeposit {
    /// Query id copied into the payout request.
    queryId: uint64
}

/// Factory administrative update body accepted by LiquidityDepository.
struct (0xc0ffee2e) CoffeeLiquidityDepositoryUpdateContractInternal {
    /// Query id copied into the outgoing excesses response.
    queryId: uint64
    /// Address receiving remaining TON after the update.
    excessesReceiver: address
    /// Optional code/data update payload.
    update: CoffeeLiquidityDepositoryContractUpdate
}

/// LiquidityDepository-to-Pool message emitted once both liquidity sides are present.
struct (0xc0ffee29) CoffeeLiquidityDepositoryDepositLiquidityInternal {
    /// Query id propagated through the liquidity-provisioning flow.
    queryId: uint64
    /// Stored first-asset amount.
    amount1: coins
    /// Stored second-asset amount.
    amount2: coins
    /// Original liquidity provider stored as owner in init data.
    txInitiator: address
    /// Referenced trimmed liquidity params from the latest deposit message.
    params: Cell<CoffeeLiquidityDepositoryDepositLiquidityParamsTrimmed>
    /// LiquidityDepository init/proof cell proving the sender-derived address.
    proof: Cell<CoffeeLiquidityDepositoryInitData>
}

/// LiquidityDepository-to-Vault payout request for duplicate deposits or owner cancellation.
struct (0xc0ffee21) CoffeeLiquidityDepositoryPayoutInternal {
    /// Query id propagated from the triggering message.
    queryId: uint64
    /// Address that should receive the returned asset amount.
    recipient: address
    /// Amount to pay out through the target asset vault.
    amount: coins
    /// Optional notification data.
    notificationData: Cell<CoffeeLiquidityDepositoryNotificationDataSingle>?
    /// Optional LiquidityDepository proof cell.
    proof: Cell<CoffeeLiquidityDepositoryInitData>?
}

/// Standard Jetton-style excesses body emitted after a successful contract update.
struct (0xd53276db) CoffeeLiquidityDepositoryExcesses {
    /// Query id copied from `update_contract_internal`.
    queryId: uint64
}

/// Internal message bodies accepted by Coffee LiquidityDepository.
type CoffeeLiquidityDepositoryIncomingMessage =
    | CoffeeLiquidityDepositoryCreateLiquidityDepositoryInternal
    | CoffeeLiquidityDepositoryDeploy
    | CoffeeLiquidityDepositoryWithdrawDeposit
    | CoffeeLiquidityDepositoryUpdateContractInternal

/// Internal message bodies emitted by Coffee LiquidityDepository.
type CoffeeLiquidityDepositoryOutgoingMessage =
    | CoffeeLiquidityDepositoryDepositLiquidityInternal
    | CoffeeLiquidityDepositoryPayoutInternal
    | CoffeeLiquidityDepositoryExcesses

/// LiquidityDepository error codes.
enum CoffeeLiquidityDepositoryErrors {
    /// Incoming opcode is not supported by LiquidityDepository.
    UnknownOpcode = 6
    /// Deposit asset is not one of the two assets bound to this helper.
    InvalidRequest = 251
    /// Owner-only cancellation was sent by another address.
    WrongSender = 252
    /// Factory-only message was sent by another address.
    NotAFactory = 253
    /// Duplicate side deposit caused LiquidityDepository to refund and throw.
    InvalidLiquidity = 264
    /// Asset tag was not one of native, jetton, or extra.
    InvalidAssetType = 267
}
