/// Coffee Swap CurveFi stable Pool interface for swaps, liquidity, LP Jetton minter operations, pool administration, and emitted events.
contract CoffeePoolCurveFiStable {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee Swap CurveFi stable Pool ABI for swaps, liquidity, LP Jetton minter operations, pool administration, getters, and events."
    storage: CoffeePoolCurveFiStableStorage
    incomingMessages: CoffeePoolCurveFiStableIncomingMessage
    outgoingMessages: CoffeePoolCurveFiStableOutgoingMessage
    thrownErrors: CoffeePoolCurveFiStableErrors
}

/// Runtime persistent Pool storage loaded by `contracts/pool/include/storage.fc`.
struct CoffeePoolCurveFiStableStorage {
    /// Code cell used with initData to verify deterministic Coffee child contract addresses.
    initCode: cell
    /// Pool init-data proof cell containing factory address, contract type, sorted assets, AMM id, and AMM settings.
    initData: Cell<CoffeePoolProof>
    /// Active flag checked by swap and non-creation liquidity paths.
    isActive: bool
    /// Current reserve of the first sorted pool asset.
    reserve1: coins
    /// Current reserve of the second sorted pool asset.
    reserve2: coins
    /// Total supply of LP Jettons minted by this Pool.
    totalSupply: coins
    /// Protocol fee numerator; denominator is `1000000`.
    protocolFee: uint16
    /// LP fee numerator; denominator is `1000000`.
    lpFee: uint16
    /// Accumulated protocol fees in the first asset.
    protocolFeeCollectedAsset1: coins
    /// Accumulated protocol fees in the second asset.
    protocolFeeCollectedAsset2: coins
    /// LP wallet code used for deterministic wallet derivation and mint transfers.
    lpWalletCode: cell
}

/// Native TON asset tag used by Coffee DEX asset identifiers.
struct (0b00) CoffeePoolNativeAsset {}

/// Jetton asset tag storing workchain byte and account hash, matching `load_asset`.
struct (0b01) CoffeePoolJettonAsset {
    /// Jetton minter workchain byte.
    chain: uint8
    /// Jetton minter account hash.
    hash: uint256
}

/// Extra-currency asset tag storing a 32-bit extra-currency id.
struct (0b10) CoffeePoolExtraAsset {
    /// Extra-currency id.
    id: uint32
}

/// Coffee DEX asset serialized inline in pool proofs, messages, and event bodies.
type CoffeePoolAsset =
    | CoffeePoolNativeAsset
    | CoffeePoolJettonAsset
    | CoffeePoolExtraAsset

/// CurveFi stable AMM settings parsed by `pool/amm/curve_fi_stable.fc`.
struct CoffeePoolCurveFiStableAmmSettings {
    /// StableSwap amplification parameter.
    amplification: uint16
    /// Weight multiplier applied to first-asset reserves and amounts.
    asset1Weight: coins
    /// Weight multiplier applied to second-asset reserves and amounts.
    asset2Weight: coins
}

/// Absent previous-asset hint encoded as the `Maybe Asset` zero bit.
struct (0b0) CoffeePoolPreviousAssetHintAbsent {}

/// Present native previous-asset hint encoded as maybe bit `1` plus native asset tag `00`.
struct (0b100) CoffeePoolPreviousNativeAssetHint {}

/// Present jetton previous-asset hint encoded as maybe bit `1` plus jetton asset tag `01`.
struct (0b101) CoffeePoolPreviousJettonAssetHint {
    /// Jetton minter workchain byte.
    chain: uint8
    /// Jetton minter account hash.
    hash: uint256
}

/// Present extra-currency previous-asset hint encoded as maybe bit `1` plus extra asset tag `10`.
struct (0b110) CoffeePoolPreviousExtraAssetHint {
    /// Extra-currency id.
    id: uint32
}

/// Optional previous-asset hint as encoded by `Maybe Asset` in `swap_step_internal_params`.
type CoffeePoolPreviousAssetHint =
    | CoffeePoolPreviousAssetHintAbsent
    | CoffeePoolPreviousNativeAssetHint
    | CoffeePoolPreviousJettonAssetHint
    | CoffeePoolPreviousExtraAssetHint

/// Common sorted-asset tuple embedded in owned child init-data refs.
struct CoffeePoolDoubleAssetParams {
    /// First sorted asset.
    asset1: CoffeePoolAsset
    /// Second sorted asset.
    asset2: CoffeePoolAsset
    /// AMM id loaded as 3 bits; `0` means constant product, `1` means CurveFi stable.
    amm: uint3
    /// Optional AMM settings ref for CurveFi stable pool parameters.
    ammSettings: Cell<CoffeePoolCurveFiStableAmmSettings>?
}

/// Proof body for a Vault child contract.
struct (0b00) CoffeePoolVaultProofBody {
    /// Vault asset.
    asset: CoffeePoolAsset
}

/// Proof body for a Pool child contract.
struct (0b01) CoffeePoolPoolProofBody {
    /// First sorted pool asset.
    asset1: CoffeePoolAsset
    /// Second sorted pool asset.
    asset2: CoffeePoolAsset
    /// AMM id loaded as 3 bits.
    amm: uint3
    /// Optional AMM settings ref.
    ammSettings: Cell<CoffeePoolCurveFiStableAmmSettings>?
}

/// Proof body for a LiquidityDepository child contract.
struct (0b10) CoffeePoolLiquidityDepositoryProofBody {
    /// Owner address committed into the deterministic depository address.
    owner: address
    /// Referenced sorted-asset and AMM tuple.
    params: Cell<CoffeePoolDoubleAssetParams>
}

/// Proof body for a PoolCreator child contract.
struct (0b11) CoffeePoolCreatorProofBody {
    /// Owner address committed into the deterministic pool-creator address.
    owner: address
    /// Referenced sorted-asset and AMM tuple.
    params: Cell<CoffeePoolDoubleAssetParams>
}

/// Child-contract proof/init-data body selected by the 2-bit contract type.
type CoffeePoolProofBody =
    | CoffeePoolVaultProofBody
    | CoffeePoolPoolProofBody
    | CoffeePoolLiquidityDepositoryProofBody
    | CoffeePoolCreatorProofBody

/// Deterministic child-contract init data used as an authentication proof.
struct CoffeePoolProof {
    /// Coffee Factory address committed into the child address.
    factoryAddress: address
    /// Contract-type tagged proof body.
    body: CoffeePoolProofBody
}

/// Optional notification destination and payload used by Coffee operations.
struct CoffeePoolNotificationDataSingle {
    /// Notification receiver; `addr_none` means the operation recipient.
    receiver: address?
    /// Nanotons sent with the notification message.
    fwdGas: coins
    /// Referenced user payload wrapped into `notification#c0ffee36`.
    payload: cell
}

/// Success and failure notification settings.
struct CoffeePoolNotificationData {
    /// Optional success notification settings.
    onSuccess: Cell<CoffeePoolNotificationDataSingle>?
    /// Optional failure notification settings.
    onFailure: Cell<CoffeePoolNotificationDataSingle>?
}

/// Shared swap parameters referenced by every swap step.
struct CoffeePoolSwapParams {
    /// Unix deadline checked before applying the swap.
    deadline: uint32
    /// Final recipient for the swap output or refund.
    recipient: address
    /// Referral address used for analytics; `addr_none` disables referral attribution.
    referral: address?
    /// Optional success/failure notification data.
    notificationData: Cell<CoffeePoolNotificationData>?
}

/// Public next-hop swap-step parameters.
struct CoffeePoolSwapStepParams {
    /// Hash part of the next pool address.
    poolAddressHash: uint256
    /// Minimum output amount required at the next step.
    minOutputAmount: coins
    /// Optional next step for multihop swaps.
    next: Cell<CoffeePoolSwapStepParams>?
}

/// Inter-contract swap step payload loaded by Pool `swap_internal`.
struct CoffeePoolSwapStepInternalParams {
    /// Amount received from the previous vault or pool step.
    previousAmount: coins
    /// Optional asset hint used when the previous sender is another pool.
    previousAssetHint: CoffeePoolPreviousAssetHint
    /// Minimum output amount required for this step.
    minOutputAmount: coins
    /// Optional next public step for multihop swaps.
    next: Cell<CoffeePoolSwapStepParams>?
}

/// No deposit-liquidity condition.
struct (0b00) CoffeePoolDepositConditionNone {}

/// Minimum LP amount condition.
struct (0b01) CoffeePoolDepositConditionLpQuantity {
    /// Minimum LP amount accepted by the depositor.
    minLpAmount: coins
}

/// Reserve-ratio condition.
struct (0b10) CoffeePoolDepositConditionReservesRatio {
    /// Ratio denominator.
    denominator: uint16
    /// Minimum numerator accepted for reserve1/reserve2.
    minNominator: uint16
    /// Maximum numerator accepted for reserve1/reserve2.
    maxNominator: uint16
}

/// Combined minimum-LP and reserve-ratio condition.
struct (0b11) CoffeePoolDepositConditionComplex {
    /// Minimum LP amount accepted by the depositor.
    minLpAmount: coins
    /// Ratio denominator.
    denominator: uint16
    /// Minimum numerator accepted for reserve1/reserve2.
    minNominator: uint16
    /// Maximum numerator accepted for reserve1/reserve2.
    maxNominator: uint16
}

/// Deposit-liquidity condition encoded inline after the 2-bit condition tag.
type CoffeePoolDepositLiquidityCondition =
    | CoffeePoolDepositConditionNone
    | CoffeePoolDepositConditionLpQuantity
    | CoffeePoolDepositConditionReservesRatio
    | CoffeePoolDepositConditionComplex

/// Trimmed liquidity-deposit parameters referenced by inter-contract pool deposits.
struct CoffeePoolDepositLiquidityParamsTrimmed {
    /// LP recipient on success.
    recipient: address
    /// One-bit flag choosing recipient instead of transaction initiator on failure.
    useRecipientOnFailure: int1
    /// Referral address used for analytics only.
    referral: address?
    /// Unix deadline checked before adding liquidity.
    deadline: uint32
    /// Slippage/range condition checked against pool reserves and LP output.
    condition: CoffeePoolDepositLiquidityCondition
    /// Reserved optional settings ref.
    extraSettings: cell?
    /// Optional success/failure notification data.
    notificationData: Cell<CoffeePoolNotificationData>?
}

/// No withdraw-liquidity condition.
struct (0b00) CoffeePoolWithdrawConditionNone {}

/// Minimum withdrawn asset amounts condition.
struct (0b01) CoffeePoolWithdrawConditionAssetsQuantity {
    /// Minimum first-asset amount.
    minFirstAmount: coins
    /// Minimum second-asset amount.
    minSecondAmount: coins
}

/// Reserve-ratio condition checked before withdrawing liquidity.
struct (0b10) CoffeePoolWithdrawConditionReservesRatio {
    /// Ratio denominator.
    denominator: uint16
    /// Minimum numerator accepted for reserve1/reserve2.
    minNominator: uint16
    /// Maximum numerator accepted for reserve1/reserve2.
    maxNominator: uint16
}

/// Combined minimum-amount and reserve-ratio withdrawal condition.
struct (0b11) CoffeePoolWithdrawConditionComplex {
    /// Minimum first-asset amount.
    minFirstAmount: coins
    /// Minimum second-asset amount.
    minSecondAmount: coins
    /// Ratio denominator.
    denominator: uint16
    /// Minimum numerator accepted for reserve1/reserve2.
    minNominator: uint16
    /// Maximum numerator accepted for reserve1/reserve2.
    maxNominator: uint16
}

/// Withdraw-liquidity condition encoded in the LP wallet burn custom payload.
type CoffeePoolWithdrawLiquidityCondition =
    | CoffeePoolWithdrawConditionNone
    | CoffeePoolWithdrawConditionAssetsQuantity
    | CoffeePoolWithdrawConditionReservesRatio
    | CoffeePoolWithdrawConditionComplex

/// Optional burn custom payload supported by Coffee LP wallets and consumed by Pool withdrawal.
struct CoffeePoolWithdrawLiquidityParams {
    /// One-bit flag choosing response address as failure recipient and minting target.
    useRecipientOnFailure: int1
    /// Unix deadline checked before releasing reserves.
    deadline: uint32
    /// Withdrawal condition checked against computed asset amounts or reserve ratio.
    condition: CoffeePoolWithdrawLiquidityCondition
    /// Reserved optional settings ref.
    extraSettings: cell?
    /// Optional success notification settings used by the final pool payout path.
    onSuccess: Cell<CoffeePoolNotificationDataSingle>?
}

/// Optional code/data replacement payload used by Factory-originated contract updates.
struct CoffeePoolContractUpdate {
    /// Replacement code cell when present.
    code: cell?
    /// Replacement data cell when present.
    data: cell?
}

/// Pool update with neither fee nor active flag changes.
struct (0b00) CoffeePoolUpdateNoop {}

/// Pool update carrying protocol and LP fee numerators.
struct (0b01) CoffeePoolUpdateFees {
    /// New protocol fee numerator.
    protocolFee: uint16
    /// New LP fee numerator.
    lpFee: uint16
}

/// Pool update carrying only the active flag.
struct (0b10) CoffeePoolUpdateActive {
    /// Replacement active flag.
    isActive: bool
}

/// Pool update carrying fee numerators and the active flag.
struct (0b11) CoffeePoolUpdateFeesAndActive {
    /// New protocol fee numerator.
    protocolFee: uint16
    /// New LP fee numerator.
    lpFee: uint16
    /// Replacement active flag.
    isActive: bool
}

/// Pool update params encoded as two flag bits plus conditional fields.
type CoffeePoolUpdateParams =
    | CoffeePoolUpdateNoop
    | CoffeePoolUpdateFees
    | CoffeePoolUpdateActive
    | CoffeePoolUpdateFeesAndActive

/// Pair of reserve or supply values encoded as two consecutive `Coins`.
struct CoffeePoolValuePair {
    /// First value.
    first: coins
    /// Second value.
    second: coins
}

/// Vault/Pool-to-Pool swap message.
struct (0xc0ffee20) CoffeePoolCurveFiStableSwapInternal {
    /// Query id propagated from the initiating operation.
    queryId: uint64
    /// Current step amount, optional previous-asset hint, minimum output, and next-step ref.
    step: CoffeePoolSwapStepInternalParams
    /// Referenced swap-wide parameters.
    params: Cell<CoffeePoolSwapParams>
    /// Referenced child-contract proof of the sender.
    proof: Cell<CoffeePoolProof>
}

/// LiquidityDepository-to-Pool deposit callback.
struct (0xc0ffee29) CoffeePoolCurveFiStableDepositLiquidityInternal {
    /// Query id propagated from the initiating deposit.
    queryId: uint64
    /// Amount of the first pool asset.
    amount1: coins
    /// Amount of the second pool asset.
    amount2: coins
    /// Transaction initiator recorded by the depository path.
    txInitiator: address
    /// Referenced trimmed deposit parameters.
    params: Cell<CoffeePoolDepositLiquidityParamsTrimmed>
    /// Referenced LiquidityDepository proof.
    proof: Cell<CoffeePoolProof>
}

/// LP wallet burn notification used to withdraw liquidity.
struct (0x7bdd97de) CoffeePoolCurveFiStableJettonBurnNotification {
    /// Query id copied from the LP wallet burn request.
    queryId: uint64
    /// LP amount burned.
    amount: coins
    /// LP owner address.
    fromAddress: address
    /// Response address; `addr_none` falls back to fromAddress.
    responseAddress: address?
    /// Optional Coffee-specific withdrawal parameters stored as a referenced custom payload.
    customPayload: Cell<CoffeePoolWithdrawLiquidityParams>?
}

/// TEP-89 wallet discovery request accepted by the Pool as LP Jetton minter.
struct (0x2c76b973) CoffeePoolCurveFiStableProvideWalletAddress {
    /// Query id copied into the response.
    queryId: uint64
    /// LP owner whose deterministic wallet address is requested.
    ownerAddress: address
    /// True when the response should include the owner address in a ref.
    includeAddress: bool
}

/// Factory-to-Pool protocol-fee withdrawal request.
struct (0xc0ffee2d) CoffeePoolCurveFiStableWithdrawInternal {
    /// Query id propagated by the Factory.
    queryId: uint64
    /// Pool asset whose collected protocol fee is withdrawn.
    asset: CoffeePoolAsset
    /// Amount of collected protocol fee to withdraw.
    amount: coins
    /// Final receiver address.
    receiver: address
}

/// Factory-to-Pool settings update.
struct (0xc0ffee2b) CoffeePoolCurveFiStableUpdatePoolInternal {
    /// Query id propagated by the Factory.
    queryId: uint64
    /// Address receiving excess TON; `addr_none` suppresses the excesses message.
    excessesReceiver: address?
    /// Referenced two-flag update parameter cell.
    params: Cell<CoffeePoolUpdateParams>
}

/// Factory-to-Pool code/data update.
struct (0xc0ffee2e) CoffeePoolCurveFiStableUpdateContractInternal {
    /// Query id propagated by the Factory.
    queryId: uint64
    /// Address receiving excess TON after update.
    excessesReceiver: address?
    /// Optional replacement code and data cells.
    update: CoffeePoolContractUpdate
}

/// Factory-to-Pool initial liquidity action used during pool creation.
struct (0xc0ffee26) CoffeePoolCurveFiStableCreatePoolInternal {
    /// Query id propagated by the Factory.
    queryId: uint64
    /// Initial amount of the first pool asset.
    amount1: coins
    /// Initial amount of the second pool asset.
    amount2: coins
    /// User who initiated pool creation.
    txInitiator: address
    /// LP recipient on success.
    recipient: address
    /// One-bit flag choosing recipient instead of transaction initiator on failure.
    useRecipientOnFailure: int1
    /// Reserved optional settings ref.
    extraSettings: cell?
    /// Optional success/failure notification data.
    notificationData: Cell<CoffeePoolNotificationData>?
}

/// Factory deploy message; Pool interprets the optional action ref as a create-pool action body.
struct (0xc0ffee22) CoffeePoolCurveFiStableDeploy {
    /// Replacement/new code cell.
    code: cell
    /// Replacement/new data cell.
    data: cell
    /// Optional action body consumed after deployment.
    action: cell?
}

/// Pool-to-Vault payout request emitted for swaps, refunds, withdrawals, and protocol-fee withdrawals.
struct (0xc0ffee21) CoffeePoolCurveFiStablePayoutInternal {
    /// Query id propagated from the Pool operation.
    queryId: uint64
    /// Final asset receiver.
    recipient: address
    /// Asset amount paid through the target vault.
    amount: coins
    /// Optional notification data for the vault payout.
    notificationData: Cell<CoffeePoolNotificationDataSingle>?
    /// Optional proof, normally the Pool init-data cell.
    proof: Cell<CoffeePoolProof>?
}

/// Pool-to-Pool continuation swap for multihop routes.
struct (0xc0ffee20) CoffeePoolCurveFiStableSwapInternalOut {
    /// Query id propagated from the current swap step.
    queryId: uint64
    /// Next step amount, output-asset hint, minimum output, and continuation.
    step: CoffeePoolSwapStepInternalParams
    /// Original swap-wide parameters ref.
    params: Cell<CoffeePoolSwapParams>
    /// Pool init-data proof sent to the next pool.
    proof: Cell<CoffeePoolProof>
}

/// Pool notification wrapper sent to a notification receiver.
struct (0xc0ffee36) CoffeePoolCurveFiStableNotification {
    /// Query id propagated from the triggering operation.
    queryId: uint64
    /// Original user payload stored as a referenced cell.
    body: cell
}

/// External event emitted after a successful swap step.
struct (0xc0ffee30) CoffeePoolCurveFiStableSwapSucceeded {
    /// Query id propagated from the swap.
    queryId: uint64
    /// Input asset serialized inline.
    input: CoffeePoolAsset
    /// Gross input amount before fee deduction.
    inputAmount: coins
    /// Output amount produced by the AMM.
    outputAmount: coins
    /// Reserve pair before the state update.
    reserves: CoffeePoolValuePair
    /// Protocol fee charged from the input amount.
    protocolFee: coins
}

/// External event emitted before a failed swap step is refunded.
struct (0xc0ffee31) CoffeePoolCurveFiStableSwapFailed {
    /// Query id propagated from the swap.
    queryId: uint64
    /// Input asset serialized inline.
    input: CoffeePoolAsset
    /// Gross input amount.
    inputAmount: coins
    /// Optional reserve pair ref present for slippage failures.
    reserves: Cell<CoffeePoolValuePair>?
}

/// External event emitted after successful liquidity provision.
struct (0xc0ffee33) CoffeePoolCurveFiStableDepositLiquiditySucceeded {
    /// Query id propagated from the deposit.
    queryId: uint64
    /// First-asset amount accepted by the pool.
    amount1: coins
    /// Second-asset amount accepted by the pool.
    amount2: coins
    /// LP amount minted to the recipient, excluding locked initial LP.
    lpAmount: coins
    /// Old and new total supply, encoded as two consecutive `Coins`.
    totalSupply: CoffeePoolValuePair
    /// Reserve1 and reserve2 before the update, encoded inline.
    reserves: CoffeePoolValuePair
}

/// External event emitted before a failed liquidity provision is refunded.
struct (0xc0ffee34) CoffeePoolCurveFiStableDepositLiquidityFailed {
    /// Query id propagated from the deposit.
    queryId: uint64
    /// First-asset amount attempted.
    amount1: coins
    /// Second-asset amount attempted.
    amount2: coins
    /// Minimum LP amount used by the failing condition.
    minLpAmount: coins
    /// Total LP supply before the failed operation.
    totalSupply: coins
    /// Reserve1 and reserve2 before the failed operation.
    reserves: CoffeePoolValuePair
}

/// External event emitted after successful liquidity withdrawal.
struct (0xc0ffee35) CoffeePoolCurveFiStableWithdrawLiquiditySucceeded {
    /// Query id copied from the LP burn notification.
    queryId: uint64
    /// First-asset amount released.
    amount1: coins
    /// Second-asset amount released.
    amount2: coins
    /// LP amount burned.
    lpAmount: coins
    /// Old and new total supply, encoded as two consecutive `Coins`.
    totalSupply: CoffeePoolValuePair
    /// Reserve1 and reserve2 before the update, encoded inline.
    reserves: CoffeePoolValuePair
}

/// TEP-89 wallet discovery response emitted by the Pool as LP Jetton minter.
struct (0xd1735400) CoffeePoolCurveFiStableTakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Deterministic LP wallet address for ownerAddress.
    walletAddress: address
    /// Optional referenced owner address when includeAddress was true.
    ownerAddress: Cell<address>?
}

/// Jetton excesses response emitted after a Pool settings update when requested.
struct (0xd53276db) CoffeePoolCurveFiStableExcesses {
    /// Query id copied from the update request.
    queryId: uint64
}

/// Pool-to-LP-wallet mint or refund transfer using the standard Jetton internal-transfer body.
struct (0x178d4519) CoffeePoolCurveFiStableLpWalletInternalTransfer {
    /// Query id copied from the liquidity operation.
    queryId: uint64
    /// LP Jetton amount minted or returned.
    amount: coins
    /// Pool address as internal-transfer sender.
    fromAddress: address
    /// LP owner or response address used by the wallet.
    responseAddress: address
    /// Nanotons forwarded to the wallet owner notification.
    forwardTonAmount: coins
    /// Raw Jetton forward-payload tail encoded as either empty or referenced notification data.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by CoffeePoolCurveFiStable.
type CoffeePoolCurveFiStableIncomingMessage =
    | CoffeePoolCurveFiStableSwapInternal
    | CoffeePoolCurveFiStableDepositLiquidityInternal
    | CoffeePoolCurveFiStableJettonBurnNotification
    | CoffeePoolCurveFiStableProvideWalletAddress
    | CoffeePoolCurveFiStableWithdrawInternal
    | CoffeePoolCurveFiStableUpdatePoolInternal
    | CoffeePoolCurveFiStableUpdateContractInternal
    | CoffeePoolCurveFiStableCreatePoolInternal
    | CoffeePoolCurveFiStableDeploy

/// Internal message bodies and external event bodies emitted by CoffeePoolCurveFiStable.
type CoffeePoolCurveFiStableOutgoingMessage =
    | CoffeePoolCurveFiStablePayoutInternal
    | CoffeePoolCurveFiStableSwapInternalOut
    | CoffeePoolCurveFiStableNotification
    | CoffeePoolCurveFiStableSwapSucceeded
    | CoffeePoolCurveFiStableSwapFailed
    | CoffeePoolCurveFiStableDepositLiquiditySucceeded
    | CoffeePoolCurveFiStableDepositLiquidityFailed
    | CoffeePoolCurveFiStableWithdrawLiquiditySucceeded
    | CoffeePoolCurveFiStableTakeWalletAddress
    | CoffeePoolCurveFiStableExcesses
    | CoffeePoolCurveFiStableLpWalletInternalTransfer

/// Stack reply returned by `get_pool_data`.
struct CoffeePoolCurveFiStableGetPoolDataReply {
    /// Pool code version, currently `1`.
    poolVersion: int
    /// Serialized first sorted asset.
    asset1: slice
    /// Serialized second sorted asset.
    asset2: slice
    /// AMM id, `1` for CurveFi stable.
    amm: int
    /// Optional AMM settings cell for CurveFi stable pools.
    ammSettings: Cell<CoffeePoolCurveFiStableAmmSettings>?
    /// Active flag returned as TVM boolean.
    active: bool
    /// Current reserve of asset1.
    reserve1: int
    /// Current reserve of asset2.
    reserve2: int
    /// Total LP supply.
    totalSupply: int
    /// Protocol fee numerator.
    protocolFee: int
    /// LP fee numerator.
    lpFee: int
}

/// Stack reply returned by Pool-as-LP-Jetton-minter `get_jetton_data`.
struct CoffeePoolCurveFiStableJettonDataReply {
    /// Total LP token supply.
    totalSupply: int
    /// Mintable flag.
    mintable: bool
    /// Factory address returned in the Jetton admin slot.
    adminAddress: address
    /// Off-chain LP metadata content cell.
    jettonContent: cell
    /// LP wallet code cell.
    jettonWalletCode: cell
}

/// Stack reply returned by `estimate_swap_amount`.
struct CoffeePoolCurveFiStableEstimateSwapAmountReply {
    /// Actual input amount used by the AMM after fee deduction.
    inputAmount: int
    /// Estimated output amount.
    outputAmount: int
}

/// Stack reply returned by `estimate_liquidity_withdraw_amount`.
struct CoffeePoolCurveFiStableEstimateLiquidityWithdrawAmountReply {
    /// Estimated first-asset withdrawal amount.
    amount1: int
    /// Estimated second-asset withdrawal amount.
    amount2: int
}

/// Stack reply returned by `estimate_liquidity_deposit_amount`.
struct CoffeePoolCurveFiStableEstimateLiquidityDepositAmountReply {
    /// First-asset amount that would be accepted.
    amount1Used: int
    /// Second-asset amount that would be accepted.
    amount2Used: int
    /// LP amount that would be minted to the user.
    lpAmount: int
    /// Permanently locked LP amount.
    lpToLock: int
}

/// Coffee CurveFi stable Pool error codes.
enum CoffeePoolCurveFiStableErrors {
    /// Unsupported opcode.
    UnknownOpcode = 6
    /// Attached value cannot cover downstream gas or notification forwarding.
    NotEnoughGas = 40
    /// Generic unexpected branch.
    Unexpected = 250
    /// Sender is not an expected vault, pool, LP wallet, depository, or factory.
    WrongSender = 252
    /// Factory-only operation was sent by a non-factory address.
    NotAFactory = 253
    /// Address is outside the base workchain.
    WrongChain = 255
    /// Asset proof or request asset does not match this pool.
    WrongAssets = 256
    /// Deterministic child-contract proof does not match sender.
    WrongSignature = 258
    /// AMM calculation failed.
    AmmFailed = 262
    /// AMM settings are missing or invalid for this AMM.
    InvalidAmmSettings = 263
    /// Liquidity amount is invalid.
    InvalidLiquidity = 264
    /// Fee value or protocol-fee withdrawal amount is invalid.
    InvalidFee = 265
    /// Deposit or withdraw condition is invalid.
    InvalidCondition = 266
    /// Asset tag is unsupported.
    InvalidAssetType = 267
    /// Deadline has passed.
    DeadlineExceeded = 268
    /// Slippage condition failed.
    SlippageTolerated = 269
    /// Creation attempted on an already initialized pool.
    PoolAlreadyExists = 270
    /// Reserve-ratio condition failed.
    ReservesRatioFailed = 271
    /// Activation requested for an already active pool.
    AlreadyActive = 272
    /// Operation requires an active pool.
    NotActive = 273
}

/// Return LP Jetton minter data for this Pool.
get fun get_jetton_data(): CoffeePoolCurveFiStableJettonDataReply {
    throw 0;
}

/// Return the deterministic LP wallet address for an owner.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return current Coffee Pool state and fee settings.
get fun get_pool_data(): CoffeePoolCurveFiStableGetPoolDataReply {
    throw 0;
}

/// Estimate swap input actually used and output amount for a serialized input asset.
get fun estimate_swap_amount(
    asset: slice,
    amount: int,
): CoffeePoolCurveFiStableEstimateSwapAmountReply {
    throw 0;
}

/// Estimate withdrawn asset amounts for an LP burn amount.
get fun estimate_liquidity_withdraw_amount(
    lpAmount: int,
): CoffeePoolCurveFiStableEstimateLiquidityWithdrawAmountReply {
    throw 0;
}

/// Estimate accepted liquidity amounts, minted LP, and locked LP for a proposed deposit.
get fun estimate_liquidity_deposit_amount(
    amount1: int,
    amount2: int,
): CoffeePoolCurveFiStableEstimateLiquidityDepositAmountReply {
    throw 0;
}
