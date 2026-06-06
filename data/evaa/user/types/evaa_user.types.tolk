/// EVAA user position contract interface.
contract EvaaUser {
    author: "EVAA"
    version: "9"
    description: "EVAA user position ABI with runtime storage, upgrade-wrapped user commands, responses, and public getters."
    storage: EvaaUserStorage
    storageAtDeployment: EvaaUserDeploymentStorage
    incomingMessages: EvaaUserIncomingMessage
    outgoingMessages: EvaaUserOutgoingMessage
    forceAbiExport: EvaaUserGetStoreRequest | EvaaUserUpgradeInfo
}

/// Runtime value stored in the user principal dictionary.
struct EvaaUserPrincipal {
    /// Signed asset principal; positive values are supplied assets and negative values are borrowed assets.
    principal: int64
    /// Optional inline borrow metadata after negative principals.
    borrowTail: RemainingBitsAndRefs
}

/// Per-asset reward tracking value stored in the user reward dictionary.
struct EvaaUserReward {
    /// Base tracking index used to accrue future supply or borrow rewards.
    trackingIndex: uint64
    /// Accrued tracking amount for this user and asset.
    trackingAccrued: uint64
}

/// Runtime storage after user-code initialization has appended reward and backup fields.
struct EvaaUserStorage {
    /// User code version stored as TON `Coins` in the root cell.
    codeVersion: coins
    /// Master contract address authorized to send upgrade-wrapped user commands.
    masterAddress: address
    /// Owner address of this user position.
    ownerAddress: address
    /// Principal dictionary keyed by 256-bit EVAA asset id.
    userPrincipals: map<uint256, EvaaUserPrincipal>
    /// Lock state: zero is free, negative values are supply-withdraw locks, positive values count liquidations.
    state: int64
    /// Reward dictionary keyed by 256-bit EVAA asset id.
    userRewards: map<uint256, EvaaUserReward>
    /// Reserved optional backup cell for future-compatible storage.
    backupCell1: cell?
    /// Reserved optional backup cell for future-compatible storage.
    backupCell2: cell?
}

/// Initial user storage shape before the runtime upgrade hook appends reward and backup fields.
struct EvaaUserDeploymentStorage {
    /// User code version stored as TON `Coins` in the root cell.
    codeVersion: coins
    /// Master contract address authorized to complete initialization.
    masterAddress: address
    /// Owner address used for the user position.
    ownerAddress: address
    /// Initial principal dictionary keyed by 256-bit EVAA asset id.
    userPrincipals: map<uint256, EvaaUserPrincipal>
    /// Initial lock state.
    state: int64
}

/// Extended boolean encoded in two bits: `00` for false and `11` for true.
type EvaaUserBoolExtended = int2

/// EVAA price dictionary keyed by 256-bit asset id with compressed coin prices.
type EvaaUserPriceDict = map<uint256, coins>

/// Asset configuration parameters stored in the referenced config-params cell.
struct EvaaUserAssetConfigParams {
    /// Collateral factor scaled by the protocol coefficient scale.
    collateralFactor: uint16
    /// Liquidation threshold scaled by the protocol coefficient scale.
    liquidationThreshold: uint16
    /// Liquidation bonus scaled by the protocol coefficient scale.
    liquidationBonus: uint16
    /// Base borrow rate.
    baseBorrowRate: uint64
    /// Low-slope borrow-rate parameter.
    borrowRateSlopeLow: uint64
    /// High-slope borrow-rate parameter.
    borrowRateSlopeHigh: uint64
    /// Low-slope supply-rate parameter.
    supplyRateSlopeLow: uint64
    /// High-slope supply-rate parameter.
    supplyRateSlopeHigh: uint64
    /// Target utilization for the asset.
    targetUtilization: uint64
    /// Borrow origination fee scale value.
    originationFee: uint64
    /// Dust threshold for small principals.
    dustValue: uint64
    /// Maximum total supply principal, or zero when uncapped.
    maxTotalSupply: uint64
    /// Reserve factor scaled by the protocol coefficient scale.
    reserveFactor: uint16
    /// Liquidation reserve factor scaled by the reserve liquidation scale.
    liquidationReserveFactor: uint16
    /// Minimum principal used for reward eligibility.
    minPrincipalForRewards: uint64
    /// Base tracking speed for supplied positions.
    baseTrackingSupplySpeed: uint64
    /// Base tracking speed for borrowed positions.
    baseTrackingBorrowSpeed: uint64
    /// Signed borrow cap for this asset.
    borrowCap: int64
    /// High-efficiency category id.
    heCategory: uint8
    /// High-efficiency collateral factor.
    heCollateralFactor: uint16
    /// High-efficiency liquidation threshold.
    heLiquidationThreshold: uint16
}

/// Per-asset static configuration value in the asset config collection.
struct EvaaUserAssetConfig {
    /// Jetton-wallet address hash for the asset.
    jwAddressHash: uint256
    /// Asset decimals.
    decimals: uint8
    /// Referenced configuration parameters.
    params: Cell<EvaaUserAssetConfigParams>
}

/// Per-asset dynamic accounting value in the asset dynamics collection.
struct EvaaUserAssetDynamics {
    /// Current supply rate.
    sRate: uint64
    /// Current borrow rate.
    bRate: uint64
    /// Total supplied principal.
    totalSupplyPrincipal: int64
    /// Total borrowed principal.
    totalBorrowPrincipal: int64
    /// Unix timestamp of the last accrual.
    lastAccrual: uint32
    /// Current token balance.
    tokenBalance: uint64
    /// Current supply tracking index.
    trackingSupplyIndex: uint64
    /// Current borrow tracking index.
    trackingBorrowIndex: uint64
    /// Awaited supply balance.
    awaitedSupply: uint64
}

/// Upgrade payload cell carrying replacement code and data.
struct EvaaUserUpgradeInfo {
    /// New user code cell.
    newCode: cell
    /// New user data cell.
    newData: cell
}

/// Header prepended to normal user commands sent by the EVAA master.
struct EvaaUserUpgradeHeader {
    /// Code version expected by the master for this command.
    userCodeVersion: coins
    /// Optional upgrade payload with new code and data.
    upgradeInfo: Cell<EvaaUserUpgradeInfo>?
    /// Two-bit extended boolean deciding whether to execute upgrade logic.
    upgradeExec: EvaaUserBoolExtended
}

/// Internal body wrapper used for master-to-user commands.
@overflow1023_policy("suppress")
struct EvaaUserPackedCommand {
    /// Upgrade header parsed before the command opcode.
    upgradeHeader: EvaaUserUpgradeHeader
    /// User command body parsed after the upgrade header.
    command: EvaaUserCommand
}

/// On-chain storage request body that stores the operation id as a `Coins` value.
struct EvaaUserGetStoreRequest {
    /// Request selector encoded as TON `Coins`; expected value is `0x9998`.
    op: coins
    /// Query id copied into the storage response.
    queryId: uint64
    /// Request payload returned unchanged in the response.
    bodyData: cell
}

/// Extra ref attached to `supply_user`.
struct EvaaUserSupplyUserExtra {
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Two-bit flag asking the master to return repay remainings.
    returnRepayRemainingsFlag: EvaaUserBoolExtended
    /// Optional custom-payload recipient; absent when the master request had no recipient.
    customPayloadRecipient: address?
    /// Two-bit flag asking the user to saturate the custom response payload.
    customPayloadSaturationFlag: EvaaUserBoolExtended
    /// Optional initial sender address from the master-side operation.
    initialSender: address?
}

/// Supply request sent from the master to the user contract.
struct (0x00000011) EvaaUserSupplyUser {
    /// Query id copied into supply responses.
    queryId: uint64
    /// Supplied asset id.
    assetId: uint256
    /// Current supplied amount.
    supplyAmountCurrent: uint64
    /// Current asset supply rate.
    sRate: uint64
    /// Current asset borrow rate.
    bRate: uint64
    /// Dust threshold for the asset.
    dust: uint64
    /// Maximum allowed token amount, or zero when uncapped.
    maxTokenAmount: uint64
    /// Total supply principal before this operation.
    totalSupply: int64
    /// Total borrow principal before this operation.
    totalBorrow: int64
    /// Current supply tracking index.
    trackingSupplyIndex: uint64
    /// Current borrow tracking index.
    trackingBorrowIndex: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Referenced supply metadata.
    extra: Cell<EvaaUserSupplyUserExtra>
}

/// Extra ref attached to `liquidate_user`.
struct EvaaUserLiquidateUserExtra {
    /// Referenced price dictionary used by liquidation calculations.
    pricesPacked: Cell<EvaaUserPriceDict>
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Minimum collateral amount accepted by the liquidator.
    minCollateralAmount: uint64
    /// Liquidator address that initiated the master-side operation.
    liquidatorAddress: address
    /// Transferred loan asset id.
    transferredAssetId: uint256
    /// Transferred loan asset amount.
    transferedAmount: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Referenced custom-payload delivery settings.
    customPayload: Cell<EvaaUserLiquidateCustomPayload>
}

/// Custom-payload delivery settings used by liquidation responses.
struct EvaaUserLiquidateCustomPayload {
    /// Optional recipient for the custom payload.
    customPayloadRecipient: address?
    /// Two-bit flag asking the user to saturate the custom response payload.
    customPayloadSaturationFlag: EvaaUserBoolExtended
}

/// Liquidation request sent from the master to the user contract.
struct (0x00000031) EvaaUserLiquidateUser {
    /// Query id copied into liquidation responses.
    queryId: uint64
    /// Asset configuration dictionary keyed by 256-bit asset id.
    assetConfigCollection: map<uint256, EvaaUserAssetConfig>
    /// Asset dynamics dictionary keyed by 256-bit asset id.
    assetDynamicsCollection: map<uint256, EvaaUserAssetDynamics>
    /// Referenced liquidation request metadata.
    extra: Cell<EvaaUserLiquidateUserExtra>
}

/// Liquidation success callback sent from the master to the user contract.
struct (0x0000311a) EvaaUserLiquidateSuccess {
    /// Query id copied from the liquidation operation.
    queryId: uint64
    /// Transferred loan asset id.
    transferredAssetId: uint256
    /// Delta applied to the loan principal.
    deltaLoanPrincipal: int64
    /// Loan asset supply tracking index.
    loanTrackingSupplyIndex: uint64
    /// Loan asset borrow tracking index.
    loanTrackingBorrowIndex: uint64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Delta applied to the collateral principal.
    deltaCollateralPrincipal: int64
    /// Collateral asset supply tracking index.
    collateralTrackingSupplyIndex: uint64
    /// Collateral asset borrow tracking index.
    collateralTrackingBorrowIndex: uint64
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
}

/// Liquidation failure callback sent from the master to the user contract.
struct (0x0000311f) EvaaUserLiquidateFail {
    /// Query id copied from the liquidation operation.
    queryId: uint64
    /// Transferred loan asset id.
    transferredAssetId: uint256
    /// Delta that must be reverted on the loan principal.
    deltaLoanPrincipal: int64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Delta that must be reverted on the collateral principal.
    deltaCollateralPrincipal: int64
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
}

/// Supply leg of a supply-withdraw user command.
struct EvaaUserSwSupplyUser {
    /// Supplied amount.
    supplyAmount: uint64
    /// Supplied asset id.
    supplyAssetId: uint256
}

/// Withdraw leg of a supply-withdraw user command.
struct EvaaUserSwWithdrawUser {
    /// Requested withdraw amount, or max uint64 for full withdrawal.
    withdrawAmount: uint64
    /// Withdrawn asset id.
    withdrawAssetId: uint256
    /// Recipient address for withdrawn assets.
    recipientAddressOfWithdraw: address
    /// Price dictionary used by withdraw calculations.
    pricesPacked: EvaaUserPriceDict
}

/// General data ref of a supply-withdraw user command.
struct EvaaUserSwGeneralUser {
    /// Asset configuration dictionary keyed by 256-bit asset id.
    assetConfigCollection: map<uint256, EvaaUserAssetConfig>
    /// Asset dynamics dictionary keyed by 256-bit asset id.
    assetDynamicsCollection: map<uint256, EvaaUserAssetDynamics>
    /// TON amount reserved for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Two-bit flag asking the master to return repay remainings.
    returnRepayRemainingsFlag: EvaaUserBoolExtended
    /// Two-bit flag asking the user to saturate the custom response payload.
    customPayloadSaturationFlag: EvaaUserBoolExtended
}

/// Combined supply and withdraw request sent from the master to the user contract.
struct (0x00000041) EvaaUserSupplyWithdrawUser {
    /// Query id copied into supply-withdraw responses.
    queryId: uint64
    /// Referenced supply leg.
    supplyData: Cell<EvaaUserSwSupplyUser>
    /// Referenced withdraw leg.
    withdrawData: Cell<EvaaUserSwWithdrawUser>
    /// Referenced general data.
    generalData: Cell<EvaaUserSwGeneralUser>
}

/// Signed supply-withdraw principal delta used by failure callbacks.
struct EvaaUserSupplyWithdrawFailPrincipalDelta {
    /// Asset id whose principal delta is carried by this cell.
    assetId: uint256
    /// Signed principal delta for the asset.
    principalAmount: int64
}

/// Unsigned supply-withdraw principal amount used by success callbacks.
struct EvaaUserSupplyWithdrawSuccessPrincipalAmount {
    /// Asset id whose principal amount is carried by this cell.
    assetId: uint256
    /// Principal amount for the asset.
    principalAmount: uint64
}

/// Supply-withdraw callback general data with only subaccount id.
struct EvaaUserSupplyWithdrawSubaccount {
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
}

/// Supply-withdraw failure callback sent from the master to the user contract.
struct (0x0000411f) EvaaUserSupplyWithdrawFail {
    /// Query id copied from the supply-withdraw operation.
    queryId: uint64
    /// Referenced supply principal delta.
    supplyData: Cell<EvaaUserSupplyWithdrawFailPrincipalDelta>
    /// Referenced withdraw principal delta.
    withdrawData: Cell<EvaaUserSupplyWithdrawFailPrincipalDelta>
    /// Referenced subaccount data.
    generalData: Cell<EvaaUserSupplyWithdrawSubaccount>
}

/// Supply-withdraw success callback general data.
struct EvaaUserSupplyWithdrawSuccessGeneral {
    /// Asset configuration dictionary keyed by 256-bit asset id.
    assetConfigCollection: map<uint256, EvaaUserAssetConfig>
    /// Asset dynamics dictionary keyed by 256-bit asset id.
    assetDynamicsCollection: map<uint256, EvaaUserAssetDynamics>
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
}

/// Supply-withdraw success callback sent from the master to the user contract.
struct (0x0000411a) EvaaUserSupplyWithdrawSuccess {
    /// Query id copied from the supply-withdraw operation.
    queryId: uint64
    /// Referenced supply principal amount.
    supplyData: Cell<EvaaUserSupplyWithdrawSuccessPrincipalAmount>
    /// Referenced withdraw principal amount.
    withdrawData: Cell<EvaaUserSupplyWithdrawSuccessPrincipalAmount>
    /// Referenced success general data.
    generalData: Cell<EvaaUserSupplyWithdrawSuccessGeneral>
}

/// Idle command sent by the master during user upgrades.
struct (0x00000081) EvaaUserIdleUser {
    /// Query id copied into the idle excess response.
    queryId: uint64
    /// Address that receives remaining TON value.
    originatorAddress: address
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
}

/// Internal upgrade self-check command.
struct (0x0000d001) EvaaUserDoDataChecks {
    /// Query id carried by the self-check body.
    queryId: uint64
}

/// User command variants parsed after the upgrade header.
type EvaaUserCommand =
    | EvaaUserSupplyUser
    | EvaaUserLiquidateUser
    | EvaaUserLiquidateSuccess
    | EvaaUserLiquidateFail
    | EvaaUserSupplyWithdrawUser
    | EvaaUserSupplyWithdrawFail
    | EvaaUserSupplyWithdrawSuccess
    | EvaaUserIdleUser
    | EvaaUserDoDataChecks

/// Internal message body accepted by the initialized user contract.
type EvaaUserIncomingMessage = EvaaUserPackedCommand

/// Successful supply response sent from user to master.
struct (0x0000011a) EvaaUserSupplySuccess {
    /// Query id copied from `supply_user`.
    queryId: uint64
    /// User owner address.
    ownerAddress: address
    /// Supplied asset id.
    assetId: uint256
    /// Amount supplied in current units.
    amountSupplied: uint64
    /// New user principal after supply processing.
    userNewPrincipal: int64
    /// Repaid amount in principal units.
    repayAmountPrincipal: int64
    /// Supplied amount in principal units.
    supplyAmountPrincipal: int64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Two-bit flag asking the master to return repay remainings.
    returnRepayRemainingsFlag: EvaaUserBoolExtended
    /// Referenced custom-payload recipient.
    customPayloadRecipient: Cell<address?>
    /// Two-bit flag asking the master to treat the custom payload as saturated.
    customPayloadSaturationFlag: EvaaUserBoolExtended
}

/// Failed supply response sent from user to master.
struct (0x0000011f) EvaaUserSupplyFail {
    /// Query id copied from `supply_user`.
    queryId: uint64
    /// User owner address.
    ownerAddress: address
    /// Supplied asset id.
    assetId: uint256
    /// Amount that failed to supply.
    amount: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Two-bit flag asking the master to return repay remainings.
    returnRepayRemainingsFlag: EvaaUserBoolExtended
    /// Referenced initial sender address.
    initialSender: Cell<address>
}

/// Liquidation error body with query id and optional amount payload.
type EvaaUserLiquidationError =
    | EvaaUserWithdrawInProgressError
    | EvaaUserNotLiquidatableError
    | EvaaUserLiquidationPricesMissingError
    | EvaaUserMinCollateralNotSatisfiedError
    | EvaaUserNotEnoughCollateralError
    | EvaaUserLiquidatingTooMuchError
    | EvaaUserLiquidationExecutionCrashedError

/// Liquidation error for a user locked by supply-withdraw processing.
struct (0x000031f0) EvaaUserWithdrawInProgressError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
}

/// Liquidation error for a non-liquidatable account.
struct (0x000031f2) EvaaUserNotLiquidatableError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
}

/// Liquidation error for missing price data.
struct (0x000031f7) EvaaUserLiquidationPricesMissingError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
}

/// Liquidation error carrying the available collateral amount.
struct (0x000031f3) EvaaUserMinCollateralNotSatisfiedError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
    /// Collateral amount available for the request.
    collateralAmount: uint64
}

/// Liquidation error carrying currently present collateral.
struct (0x000031f4) EvaaUserNotEnoughCollateralError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
    /// Collateral amount present in current units.
    collateralPresent: uint64
}

/// Liquidation error carrying the maximum non-excessive liquidation amount.
struct (0x000031f5) EvaaUserLiquidatingTooMuchError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
    /// Maximum amount considered not too much.
    maxNotTooMuch: uint64
}

/// Liquidation error for an exception during execution.
struct (0x000031fe) EvaaUserLiquidationExecutionCrashedError {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
}

/// Unsatisfied liquidation response sent from user to master.
struct (0x0000031f) EvaaUserLiquidateUnsatisfied {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
    /// User owner address.
    ownerAddress: address
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred loan asset id.
    transferredAssetId: uint256
    /// Referenced liquidation failure details.
    extra: Cell<EvaaUserLiquidateUnsatisfiedExtra>
}

/// Referenced details for an unsatisfied liquidation response.
struct EvaaUserLiquidateUnsatisfiedExtra {
    /// Transferred amount in current units.
    transferedAmount: uint64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Minimum collateral amount requested by the liquidator.
    minCollateralAmount: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Inline liquidation error body.
    error: EvaaUserLiquidationError
}

/// Satisfied liquidation response sent from user to master.
struct (0x00000311) EvaaUserLiquidateSatisfied {
    /// Query id copied from `liquidate_user`.
    queryId: uint64
    /// User owner address.
    ownerAddress: address
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred loan asset id.
    transferredAssetId: uint256
    /// Referenced liquidation success details.
    extra: Cell<EvaaUserLiquidateSatisfiedExtra>
}

/// Referenced details for a satisfied liquidation response.
struct EvaaUserLiquidateSatisfiedExtra {
    /// Delta applied to the loan principal.
    deltaLoanPrincipal: int64
    /// Liquidated amount in current units.
    liquidatableAmount: uint64
    /// Protocol gift amount.
    protocolGift: uint64
    /// New user loan principal.
    newUserLoanPrincipal: int64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Delta applied to collateral principal.
    deltaCollateralPrincipal: int64
    /// Collateral reward amount.
    collateralReward: uint64
    /// Minimum collateral amount requested by the liquidator.
    minCollateralAmount: uint64
    /// New user collateral principal.
    newUserCollateralPrincipal: int64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Referenced custom-payload delivery settings.
    customPayload: Cell<EvaaUserLiquidateCustomPayload>
}

/// Supply leg details for a satisfied supply-withdraw response.
struct EvaaUserSupplyWithdrawSatisfiedSupply {
    /// User owner address.
    ownerAddress: address
    /// Supplied amount.
    supplyAmount: uint64
    /// Supplied asset id.
    supplyAssetId: uint256
    /// New supply principal.
    supplyNewPrincipal: int64
    /// Repaid amount in principal units.
    repayAmountPrincipal: int64
    /// Supplied amount in principal units.
    supplyAmountPrincipal: int64
}

/// Withdraw leg details for a satisfied supply-withdraw response.
struct EvaaUserSupplyWithdrawSatisfiedWithdraw {
    /// Withdrawn amount.
    withdrawAmount: uint64
    /// Withdrawn asset id.
    withdrawAssetId: uint256
    /// Recipient address for withdrawn assets.
    recipientAddressOfWithdraw: address
    /// New withdraw principal.
    withdrawNewPrincipal: int64
    /// Borrowed amount in principal units.
    borrowAmountPrincipal: int64
    /// Reclaimed amount in principal units.
    reclaimAmountPrincipal: int64
}

/// General details for a supply-withdraw response.
struct EvaaUserSupplyWithdrawResponseGeneral {
    /// TON amount reserved for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
    /// Two-bit flag asking the master to return repay remainings.
    returnRepayRemainingsFlag: EvaaUserBoolExtended
    /// Two-bit flag asking the master to treat the custom payload as saturated.
    customPayloadSaturationFlag: EvaaUserBoolExtended
}

/// Satisfied supply-withdraw response sent from user to master.
struct (0x00000411) EvaaUserSupplyWithdrawSatisfied {
    /// Query id copied from `supply_withdraw_user`.
    queryId: uint64
    /// Referenced supply leg response.
    supplyData: Cell<EvaaUserSupplyWithdrawSatisfiedSupply>
    /// Referenced withdraw leg response.
    withdrawData: Cell<EvaaUserSupplyWithdrawSatisfiedWithdraw>
    /// Referenced response general data.
    generalData: Cell<EvaaUserSupplyWithdrawResponseGeneral>
}

/// Unsatisfied supply-withdraw response supply leg.
struct EvaaUserSupplyWithdrawUnsatisfiedSupply {
    /// User owner address.
    ownerAddress: address
    /// Supplied amount.
    supplyAmount: uint64
    /// Supplied asset id.
    supplyAssetId: uint256
}

/// Empty withdraw leg for an unsatisfied supply-withdraw response.
struct EvaaUserSupplyWithdrawEmptyWithdraw {
}

/// Unsatisfied supply-withdraw response general data.
struct EvaaUserSupplyWithdrawUnsatisfiedGeneral {
    /// TON amount reserved for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id selected by the master-side operation.
    subaccountId: int16
}

/// Unsatisfied supply-withdraw response sent from user to master.
struct (0x0000041f) EvaaUserSupplyWithdrawUnsatisfied {
    /// Query id copied from `supply_withdraw_user`.
    queryId: uint64
    /// Referenced supply leg response.
    supplyData: Cell<EvaaUserSupplyWithdrawUnsatisfiedSupply>
    /// Referenced empty withdraw leg.
    withdrawData: Cell<EvaaUserSupplyWithdrawEmptyWithdraw>
    /// Referenced unsatisfied general data.
    generalData: Cell<EvaaUserSupplyWithdrawUnsatisfiedGeneral>
}

/// Idle excess response sent to the command originator.
struct (0x0000081e) EvaaUserIdleExcess {
    /// Query id copied from `idle_user`.
    queryId: uint64
}

/// Supply-withdraw success excess response sent to the user owner.
struct (0x0000411a) EvaaUserSupplyWithdrawSuccessExcess {
    /// Query id copied from `supply_withdraw_success`.
    queryId: uint64
}

/// Supply-withdraw failure excess response sent to the user owner.
struct (0x0000411f) EvaaUserSupplyWithdrawFailExcess {
    /// Query id copied from `supply_withdraw_fail`.
    queryId: uint64
}

/// Liquidation excess text body sent to the user owner.
struct (0x00000000) EvaaUserLiquidationExcessText {
    /// Text-comment tail after the zero opcode.
    text: RemainingBitsAndRefs
}

/// Revert response sent when an unknown or failed upgraded command must be returned.
struct (0x0000000f) EvaaUserRevertCall {
    /// Fixed revert query id used by the user contract.
    queryId: uint64
    /// User owner address.
    ownerAddress: address
    /// Referenced original command body slice.
    revertBody: cell
}

/// Storage response emitted by the on-chain storage request.
struct (0x00009999) EvaaUserGetStoreResponse {
    /// Query id copied from the storage request.
    queryId: uint64
    /// Request payload returned unchanged.
    bodyData: cell
    /// Referenced current user storage cell.
    storage: Cell<EvaaUserStorage>
}

/// Internal message bodies emitted by the user contract.
type EvaaUserOutgoingMessage =
    | EvaaUserSupplySuccess
    | EvaaUserSupplyFail
    | EvaaUserLiquidateUnsatisfied
    | EvaaUserLiquidateSatisfied
    | EvaaUserSupplyWithdrawSatisfied
    | EvaaUserSupplyWithdrawUnsatisfied
    | EvaaUserIdleExcess
    | EvaaUserSupplyWithdrawSuccessExcess
    | EvaaUserSupplyWithdrawFailExcess
    | EvaaUserLiquidationExcessText
    | EvaaUserRevertCall
    | EvaaUserGetStoreResponse

/// Pair of aggregate supply and borrow balances.
struct EvaaUserAggregatedBalances {
    /// Aggregate supplied value.
    supply: int
    /// Aggregate borrowed value.
    borrow: int
}

/// Full user storage tuple returned by `getAllUserScData`.
struct EvaaUserScData {
    /// Current user code version.
    codeVersion: int
    /// Stored master contract address.
    masterAddress: address
    /// Stored owner address.
    ownerAddress: address
    /// Principal dictionary keyed by 256-bit EVAA asset id.
    userPrincipals: map<uint256, EvaaUserPrincipal>
    /// Current user lock state.
    state: int64
    /// Reward dictionary keyed by 256-bit EVAA asset id.
    userRewards: map<uint256, EvaaUserReward>
    /// Reserved optional backup cell.
    backupCell1: cell?
    /// Reserved optional backup cell.
    backupCell2: cell?
}

/// User contract exit codes that can terminate user-message processing.
enum EvaaUserErrors {
    /// Incoming user message is from a different workchain than the user contract.
    DifferentWorkchain = 0x55ff
    /// Incoming upgraded command sender is not the stored master address.
    MessageNotFromMaster = 0x01fb
    /// Upgrade metadata is absent or malformed.
    BrokenUpgradeInfo = 0xc4f2
    /// Upgrade changed user data in a version where data change is not allowed.
    UserDataChanged = 0xc4f1
    /// Revert path throws after emitting `revert_call`.
    UserCodeVersionMismatch = 0xc4f4
    /// Around-zero principal split received an invalid lower/upper pair.
    AroundZeroSplitMessedUp = 0x80f1
}

/// Return current user code version.
get fun codeVersion(): int {
    assert (true) throw EvaaUserErrors.DifferentWorkchain;
    assert (true) throw EvaaUserErrors.MessageNotFromMaster;
    assert (true) throw EvaaUserErrors.BrokenUpgradeInfo;
    assert (true) throw EvaaUserErrors.UserDataChanged;
    assert (true) throw EvaaUserErrors.UserCodeVersionMismatch;
    assert (true) throw EvaaUserErrors.AroundZeroSplitMessedUp;
    return 0;
}

/// Return marker identifying a runtime user contract.
get fun isUserSc(): int {
    return -1;
}

/// Return the present balance for one asset and supplied rates.
get fun getAccountAssetBalance(assetId: int, sRate: int, bRate: int): int {
    return 0;
}

/// Return a raw dictionary of per-asset account balances.
get fun getAccountBalances(assetDynamicsCollection: cell): cell {
    return createEmptyCell();
}

/// Return account health for supplied config, dynamics, and price dictionaries.
get fun getAccountHealth(assetConfigCollection: cell, assetDynamicsCollection: cell, pricesPacked: cell): int {
    return 0;
}

/// Return available borrow amount for supplied config, dynamics, and price dictionaries.
get fun getAvailableToBorrow(assetConfigCollection: cell, assetDynamicsCollection: cell, pricesPacked: cell): int {
    return 0;
}

/// Return whether the account is liquidatable for supplied config, dynamics, and price dictionaries.
get fun getIsLiquidable(assetConfigCollection: cell, assetDynamicsCollection: cell, pricesPacked: cell): int {
    return 0;
}

/// Return aggregate supplied and borrowed values.
get fun getAggregatedBalances(assetConfigCollection: cell, assetDynamicsCollection: cell, pricesPacked: cell): EvaaUserAggregatedBalances {
    return {
        supply: 0,
        borrow: 0,
    };
}

/// Return the stored principal for one asset id.
get fun get_asset_principal(assetId: int): int {
    return 0;
}

/// Return the user principal dictionary keyed by 256-bit EVAA asset id.
get fun getPrincipals(): map<uint256, EvaaUserPrincipal> {
    return [];
}

/// Return the user reward dictionary keyed by 256-bit EVAA asset id.
get fun getRewards(): map<uint256, EvaaUserReward> {
    return [];
}

/// Return the full user storage tuple.
get fun getAllUserScData(): EvaaUserScData {
    return {
        codeVersion: 0,
        masterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        userPrincipals: [],
        state: 0,
        userRewards: [],
        backupCell1: null,
        backupCell2: null,
    };
}

/// Return maximum withdraw amount for one asset with supplied market state.
get fun get_maximum_withdraw_amount(assetId: int, pricesPacked: cell, assetConfigCollection: cell, assetDynamicsCollection: cell): int {
    return 0;
}
