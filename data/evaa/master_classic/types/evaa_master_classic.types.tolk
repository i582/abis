/// EVAA v9 master interface for the main Classic-oracle pool.
contract EvaaMasterClassic {
    author: "EVAA"
    version: "3"
    description: "EVAA Master Classic ABI with master storage, public getters, admin messages, user-flow messages, oracle callbacks, and jetton notifications."
    storage: EvaaMasterClassicStorage
    incomingMessages: EvaaMasterClassicIncomingMessage
    outgoingMessages: EvaaMasterClassicOutgoingMessage
    forceAbiExport: EvaaMasterClassicGetConfigReply
        | EvaaMasterClassicGetUIVariablesReply
        | EvaaMasterClassicGetOraclesInfoReply
    thrownErrors: EvaaMasterClassicErrors
}

/// Runtime master data root.
struct EvaaMasterClassicStorage {
    /// Metadata cell.
    meta: cell
    /// Referenced master and user upgrade configuration.
    upgradeConfig: Cell<EvaaMasterClassicUpgradeConfig>
    /// Referenced market configuration.
    masterConfig: Cell<EvaaMasterClassicConfig>
    /// Asset dynamics keyed by EVAA asset id.
    assetDynamicsCollection: map<uint256, EvaaMasterClassicAssetDynamics>
}

/// Master and user code upgrade configuration.
struct EvaaMasterClassicUpgradeConfig {
    /// Current master code version.
    masterCodeVersion: coins
    /// Current user code version.
    userCodeVersion: coins
    /// Upgrade delay in seconds.
    timeout: uint32
    /// Earliest upgrade submit timestamp.
    updateTime: uint64
    /// Contract freeze timestamp.
    freezeTime: uint64
    /// Active user contract code.
    userCode: cell
    /// Pending master code.
    newMasterCode: cell?
    /// Pending user code.
    newUserCode: cell?
}

/// Market configuration stored in the master config reference.
struct EvaaMasterClassicConfig {
    /// Asset configs keyed by EVAA asset id.
    assetConfigCollection: map<uint256, EvaaMasterClassicAssetConfig>
    /// Signed activity flag.
    ifActive: int8
    /// Admin address.
    admin: address
    /// Oracle configuration.
    oraclesInfo: Cell<EvaaMasterClassicOraclesInfo>
    /// Jetton wallet hash to EVAA asset id map.
    tokensKeys: map<uint256, uint256>
    /// Supervisor address.
    supervisor: address
}

/// Classic oracle quorum settings.
struct EvaaMasterClassicOraclesInfo {
    /// Number of configured oracle signatures.
    totalOracles: uint16
    /// Minimum accepted oracle signatures.
    threshold: uint16
    /// Optional classic oracle dictionary cell.
    oracles: cell?
}

/// Oracle feed mapping dictionaries.
struct EvaaMasterClassicFeedsData {
    /// Pyth feed id to EVAA feed id mapping.
    pythToEvaaMap: map<uint256, EvaaMasterClassicMapItem>
    /// EVAA reference-token allowlist.
    evaaRefs: map<uint256, uint256>
}

/// Direct oracle feed mapping.
struct EvaaMasterClassicMapItem {
    /// EVAA feed id.
    evaaFeedId: uint256
    /// Optional multiplier feed id tail.
    multiplierTail: RemainingBitsAndRefs
}

/// Asset configuration stored by asset id.
struct EvaaMasterClassicAssetConfig {
    /// Jetton wallet address hash.
    jwAddressHash: uint256
    /// Asset decimals.
    decimals: uint8
    /// Referenced risk and reward parameters.
    params: Cell<EvaaMasterClassicAssetConfigParams>
}

/// Asset risk, interest, reward, and high-efficiency parameters.
struct EvaaMasterClassicAssetConfigParams {
    /// Collateral factor.
    collateralFactor: uint16
    /// Liquidation threshold.
    liquidationThreshold: uint16
    /// Liquidation bonus.
    liquidationBonus: uint16
    /// Base borrow rate.
    baseBorrowRate: uint64
    /// Low-slope borrow rate.
    borrowRateSlopeLow: uint64
    /// High-slope borrow rate.
    borrowRateSlopeHigh: uint64
    /// Low-slope supply rate.
    supplyRateSlopeLow: uint64
    /// High-slope supply rate.
    supplyRateSlopeHigh: uint64
    /// Target utilization.
    targetUtilization: uint64
    /// Origination fee.
    originationFee: uint64
    /// Dust threshold.
    dustValue: uint64
    /// Maximum total supply.
    maxTotalSupply: uint64
    /// Reserve factor.
    reserveFactor: uint16
    /// Liquidation reserve factor.
    liquidationReserveFactor: uint16
    /// Minimum principal for rewards.
    minPrincipalForRewards: uint64
    /// Base tracking supply speed.
    baseTrackingSupplySpeed: uint64
    /// Base tracking borrow speed.
    baseTrackingBorrowSpeed: uint64
    /// Borrow cap.
    borrowCap: int64
    /// High-efficiency category.
    heCategory: uint8
    /// High-efficiency collateral factor.
    heCollateralFactor: uint16
    /// High-efficiency liquidation threshold.
    heLiquidationThreshold: uint16
}

/// Asset accounting dynamics stored by asset id.
struct EvaaMasterClassicAssetDynamics {
    /// Current supply rate.
    sRate: uint64
    /// Current borrow rate.
    bRate: uint64
    /// Total supply principal.
    totalSupplyPrincipal: int64
    /// Total borrow principal.
    totalBorrowPrincipal: int64
    /// Last accrual timestamp.
    lastAccrual: uint32
    /// Current token balance.
    tokenBalance: uint64
    /// Supply reward tracking index.
    trackingSupplyIndex: uint64
    /// Borrow reward tracking index.
    trackingBorrowIndex: uint64
    /// Awaited supply amount.
    awaitedSupply: uint64
}

/// Pair of cumulative supply and borrow rates.
struct EvaaMasterClassicAssetRate {
    /// Supply rate.
    sRate: int
    /// Borrow rate.
    bRate: int
}

/// Packed supply and borrow rates stored as dictionary values by aggregate getters.
struct EvaaMasterClassicPackedAssetRate {
    /// Supply rate stored with `store_sb_rate` as uint64.
    sRate: uint64
    /// Borrow rate stored with `store_sb_rate` as uint64.
    bRate: uint64
}

/// Pair of total supply and total borrow values.
struct EvaaMasterClassicAssetTotals {
    /// Total supply.
    totalSupply: int
    /// Total borrow.
    totalBorrow: int
}

/// Upgrade config returned by `getUpgradeConfig`.
struct EvaaMasterClassicUpgradeConfigReply {
    /// Current master code version.
    masterCodeVersion: int
    /// Current user code version.
    userCodeVersion: int
    /// Upgrade delay in seconds.
    timeout: int
    /// Earliest upgrade submit timestamp.
    updateTime: int
    /// Contract freeze timestamp.
    freezeTime: int
    /// Active user contract code.
    userCode: cell
    /// Pending master code.
    newMasterCode: cell?
    /// Pending user code.
    newUserCode: cell?
}

/// Tracking indexes and last accrual timestamp for one asset.
struct EvaaMasterClassicAssetTrackingInfo {
    /// Supply reward tracking index.
    trackingSupplyIndex: int
    /// Borrow reward tracking index.
    trackingBorrowIndex: int
    /// Last accrual timestamp.
    lastAccrual: int
}

/// Config cell returned by `getConfig`.
struct EvaaMasterClassicGetConfigReply {
    /// Metadata cell.
    meta: cell
    /// Upgrade configuration.
    upgradeConfig: Cell<EvaaMasterClassicUpgradeConfig>
    /// Market configuration.
    masterConfig: Cell<EvaaMasterClassicConfig>
}

/// UI bundle returned by `getUIVariables`.
struct EvaaMasterClassicGetUIVariablesReply {
    /// Asset dynamics collection.
    assetDynamicsCollection: map<uint256, EvaaMasterClassicAssetDynamics>
    /// Metadata, upgrade config, and master config bundle.
    config: cell
    /// Asset rates dictionary.
    assetsRates: map<uint256, EvaaMasterClassicPackedAssetRate>
    /// Asset reserves dictionary.
    assetsReserves: map<uint256, int65>
}

/// Classic oracle info returned by `get_oracles_info`.
struct EvaaMasterClassicGetOraclesInfoReply {
    /// Number of configured oracle signatures.
    totalOracles: int
    /// Minimum accepted oracle signatures.
    threshold: int
    /// Classic oracle dictionary cell.
    oracles: cell
}

/// Generic nested operation payload forwarded by the oracle callback.
struct EvaaMasterClassicNestedOperation {
    /// Nested EVAA operation opcode.
    operationCode: uint32
    /// Nested operation query id.
    queryId: uint64
    /// Referenced nested operation body.
    operationPayload: cell
}

/// TON supply request to master.
struct (0x00000001) EvaaMasterClassicSupplyMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// Two-bit include-user-code flag.
    includeUserCode: int2
    /// TON amount supplied.
    supplyAmount: uint64
    /// User or subaccount owner address.
    recipientAddress: address
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Tagless optional subaccount and custom-payload suffix.
    optionalTail: RemainingBitsAndRefs
}

/// Supply request sent from master to user.
struct (0x00000011) EvaaMasterClassicSupplyUser {
    /// Query id copied from the master request.
    queryId: uint64
    /// Supplied asset id.
    assetId: uint256
    /// Current supplied amount.
    supplyAmountCurrent: uint64
    /// Supply rate.
    sRate: uint64
    /// Borrow rate.
    bRate: uint64
    /// Asset dust threshold.
    dust: uint64
    /// Maximum token amount.
    maxTokenAmount: uint64
    /// Total supply principal.
    totalSupply: int64
    /// Total borrow principal.
    totalBorrow: int64
    /// Supply tracking index.
    trackingSupplyIndex: uint64
    /// Borrow tracking index.
    trackingBorrowIndex: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Referenced subaccount, custom-payload, and sender data.
    extData: Cell<EvaaMasterClassicSupplyUserExtData>
}

/// Extra data referenced by `supply_user`.
struct EvaaMasterClassicSupplyUserExtData {
    /// Subaccount id.
    subaccountId: int16
    /// Two-bit return-repay-remainings flag.
    returnRepayRemainingsFlag: int2
    /// Custom payload recipient.
    customPayloadRecipient: address
    /// Two-bit custom-payload saturation flag.
    customPayloadSaturationFlag: int2
    /// Initial sender address.
    initialSender: address
}

/// Supply success response from user to master.
struct (0x0000011a) EvaaMasterClassicSupplySuccess {
    /// Query id copied from the supply request.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Supplied asset id.
    assetId: uint256
    /// Supplied amount.
    amountSupplied: uint64
    /// New user principal.
    userNewPrincipal: int64
    /// Repaid principal amount.
    repayAmountPrincipal: int64
    /// Supply principal amount.
    supplyAmountPrincipal: int64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Two-bit return-repay-remainings flag.
    returnRepayRemainingsFlag: int2
    /// Referenced custom payload recipient.
    customPayloadRecipient: Cell<address>
    /// Two-bit custom-payload saturation flag.
    customPayloadSaturationFlag: int2
}

/// Supply failure response from user to master.
struct (0x0000011f) EvaaMasterClassicSupplyFail {
    /// Query id copied from the supply request.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Supplied asset id.
    assetId: uint256
    /// Amount to refund.
    amount: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Two-bit return-repay-remainings flag.
    returnRepayRemainingsFlag: int2
    /// Referenced initial sender.
    initialSender: Cell<address>
}

/// Supply excess or excess-with-data response.
struct (0x000011ae) EvaaMasterClassicSupplyExcess {
    /// Query id copied from the supply flow.
    queryId: uint64
    /// Optional custom response payload suffix.
    tail: RemainingBitsAndRefs
}

/// Supply fail response with custom data.
struct (0x00011ae1) EvaaMasterClassicSupplyFailWithData {
    /// Query id copied from the supply flow.
    queryId: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Supply success plus repay remainings response.
struct (0x000011ab) EvaaMasterClassicSupplyExcessAndRepayRemainings {
    /// Query id copied from the supply flow.
    queryId: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Liquidation request with prices supplied through oracle flow.
struct (0x00000003) EvaaMasterClassicLiquidateMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// Borrower address.
    borrowerAddress: address
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Minimum collateral amount.
    minCollateralAmount: uint64
    /// Two-bit include-user-code flag.
    includeUserCode: int2
    /// Incoming liquidation amount.
    liquidateIncomingAmount: uint64
    /// Requested reference tokens dictionary.
    requestedRefTokens: cell
    /// Referenced custom response payload and optional suffix.
    responsePayload: Cell<EvaaMasterClassicLiquidateResponsePayload>
}

/// Liquidation custom response payload and optional suffix.
struct EvaaMasterClassicLiquidateResponsePayload {
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Tagless optional subaccount and custom-payload suffix.
    optionalTail: RemainingBitsAndRefs
}

/// Liquidation request sent from master to user.
struct (0x00000031) EvaaMasterClassicLiquidateUser {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Asset configs.
    assetConfigCollection: map<uint256, EvaaMasterClassicAssetConfig>
    /// Asset dynamics.
    assetDynamicsCollection: map<uint256, EvaaMasterClassicAssetDynamics>
    /// Referenced liquidation user parameters.
    params: Cell<EvaaMasterClassicLiquidateUserParams>
}

/// Parameters referenced by `liquidate_user`.
struct EvaaMasterClassicLiquidateUserParams {
    /// Referenced packed prices.
    pricesPacked: cell
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Minimum collateral amount.
    minCollateralAmount: uint64
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Transferred amount.
    transferredAmount: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Referenced custom-payload recipient and saturation flag.
    customPayloadData: Cell<EvaaMasterClassicCustomPayloadData>
}

/// Custom payload routing data.
struct EvaaMasterClassicCustomPayloadData {
    /// Custom payload recipient.
    customPayloadRecipient: address
    /// Two-bit custom-payload saturation flag.
    customPayloadSaturationFlag: int2
}

/// Liquidation unsatisfied response from user to master.
struct (0x0000031f) EvaaMasterClassicLiquidateUnsatisfied {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Referenced unsatisfied liquidation details.
    details: Cell<EvaaMasterClassicLiquidateUnsatisfiedDetails>
}

/// Details referenced by `liquidate_unsatisfied`.
struct EvaaMasterClassicLiquidateUnsatisfiedDetails {
    /// Transferred amount.
    transferredAmount: uint64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Minimum collateral amount.
    minCollateralAmount: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Liquidation error body.
    error: RemainingBitsAndRefs
}

/// Liquidation satisfied response from user to master.
struct (0x00000311) EvaaMasterClassicLiquidateSatisfied {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Referenced satisfied liquidation details.
    details: Cell<EvaaMasterClassicLiquidateSatisfiedDetails>
}

/// Details referenced by `liquidate_satisfied`.
struct EvaaMasterClassicLiquidateSatisfiedDetails {
    /// Delta loan principal.
    deltaLoanPrincipal: int64
    /// Liquidatable amount.
    liquidatableAmount: uint64
    /// Protocol gift amount.
    protocolGift: uint64
    /// New user loan principal.
    newUserLoanPrincipal: int64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Delta collateral principal.
    deltaCollateralPrincipal: int64
    /// Collateral reward amount.
    collateralReward: uint64
    /// Minimum collateral amount.
    minCollateralAmount: uint64
    /// New user collateral principal.
    newUserCollateralPrincipal: int64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Referenced custom-payload recipient and saturation flag.
    customPayloadData: Cell<EvaaMasterClassicCustomPayloadData>
}

/// Liquidation success message sent from master to user.
struct (0x0000311a) EvaaMasterClassicLiquidateSuccess {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Delta loan principal.
    deltaLoanPrincipal: int64
    /// Loan supply tracking index.
    loanTrackingSupplyIndex: uint64
    /// Loan borrow tracking index.
    loanTrackingBorrowIndex: uint64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Delta collateral principal.
    deltaCollateralPrincipal: int64
    /// Collateral supply tracking index.
    collateralTrackingSupplyIndex: uint64
    /// Collateral borrow tracking index.
    collateralTrackingBorrowIndex: uint64
    /// Subaccount id.
    subaccountId: int16
}

/// Liquidation fail message sent from master to user.
struct (0x0000311f) EvaaMasterClassicLiquidateFail {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Delta loan principal.
    deltaLoanPrincipal: int64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Delta collateral principal.
    deltaCollateralPrincipal: int64
    /// Subaccount id.
    subaccountId: int16
}

/// Liquidation success report sent to liquidator.
struct (0x0000311d) EvaaMasterClassicLiquidateSuccessReport {
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Transferred amount.
    transferredAmount: uint64
    /// Collateral asset id.
    collateralAssetId: uint256
    /// Collateral reward amount.
    collateralReward: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Liquidation fail report with embedded master error.
struct EvaaMasterClassicLiquidateFailReport {
    /// Liquidation master error body.
    error: RemainingBitsAndRefs
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Supply-withdraw request to master.
struct (0x00000004) EvaaMasterClassicSupplyWithdrawMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// Referenced supply data.
    supplyData: cell
    /// Referenced withdraw data.
    withdrawData: Cell<EvaaMasterClassicSupplyWithdrawWithdrawData>
    /// Referenced general data.
    generalData: Cell<EvaaMasterClassicSupplyWithdrawGeneralData>
}

/// Supply-withdraw request without prices.
struct (0x00000401) EvaaMasterClassicSupplyWithdrawMasterWithoutPrices {
    /// Caller-selected query id.
    queryId: uint64
    /// Referenced supply data.
    supplyData: cell
    /// Referenced withdraw data.
    withdrawData: Cell<EvaaMasterClassicSupplyWithdrawWithdrawData>
    /// Referenced general data.
    generalData: Cell<EvaaMasterClassicSupplyWithdrawGeneralData>
}

/// Withdraw data referenced by supply-withdraw requests.
struct EvaaMasterClassicSupplyWithdrawWithdrawData {
    /// Withdraw amount.
    withdrawAmount: uint64
    /// Withdraw asset id.
    withdrawAssetId: uint256
    /// Withdraw recipient.
    recipientAddressOfWithdraw: address
}

/// General data referenced by supply-withdraw requests.
struct EvaaMasterClassicSupplyWithdrawGeneralData {
    /// Two-bit include-user-code flag.
    includeUserCode: int2
    /// Requested reference tokens dictionary.
    requestedRefTokens: cell
    /// TON amount for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Tagless optional subaccount and flags suffix.
    optionalTail: RemainingBitsAndRefs
}

/// Supply-withdraw request sent from master to user.
struct (0x00000041) EvaaMasterClassicSupplyWithdrawUser {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply data.
    supplyData: Cell<EvaaMasterClassicSupplyWithdrawUserSupplyData>
    /// Referenced withdraw data.
    withdrawData: Cell<EvaaMasterClassicSupplyWithdrawUserWithdrawData>
    /// Referenced general data.
    generalData: Cell<EvaaMasterClassicSupplyWithdrawUserGeneralData>
}

/// Supply data referenced by `supply_withdraw_user`.
struct EvaaMasterClassicSupplyWithdrawUserSupplyData {
    /// Supply amount.
    supplyAmount: uint64
    /// Supply asset id.
    supplyAssetId: uint256
}

/// Withdraw data referenced by `supply_withdraw_user`.
struct EvaaMasterClassicSupplyWithdrawUserWithdrawData {
    /// Withdraw amount.
    withdrawAmount: uint64
    /// Withdraw asset id.
    withdrawAssetId: uint256
    /// Withdraw recipient.
    recipientAddressOfWithdraw: address
    /// Packed prices dictionary cell.
    pricesPacked: cell
}

/// General data referenced by `supply_withdraw_user`.
struct EvaaMasterClassicSupplyWithdrawUserGeneralData {
    /// Asset configs.
    assetConfigCollection: map<uint256, EvaaMasterClassicAssetConfig>
    /// Asset dynamics.
    assetDynamicsCollection: map<uint256, EvaaMasterClassicAssetDynamics>
    /// TON amount for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Two-bit return-repay-remainings flag.
    returnRepayRemainingsFlag: int2
    /// Two-bit custom-payload saturation flag.
    customPayloadSaturationFlag: int2
}

/// Supply-withdraw satisfied response from user to master.
struct (0x00000411) EvaaMasterClassicSupplyWithdrawSatisfied {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply result data.
    supplyData: Cell<EvaaMasterClassicSupplyWithdrawSatisfiedSupplyData>
    /// Referenced withdraw result data.
    withdrawData: Cell<EvaaMasterClassicSupplyWithdrawSatisfiedWithdrawData>
    /// Referenced general result data.
    generalData: Cell<EvaaMasterClassicSupplyWithdrawSatisfiedGeneralData>
}

/// Supply result data referenced by `supply_withdraw_satisfied`.
struct EvaaMasterClassicSupplyWithdrawSatisfiedSupplyData {
    /// Owner address.
    ownerAddress: address
    /// Supply amount.
    supplyAmount: uint64
    /// Supply asset id.
    supplyAssetId: uint256
    /// New supply principal.
    supplyNewPrincipal: int64
    /// Repaid principal amount.
    repayAmountPrincipal: int64
    /// Supply principal amount.
    supplyAmountPrincipal: int64
}

/// Withdraw result data referenced by `supply_withdraw_satisfied`.
struct EvaaMasterClassicSupplyWithdrawSatisfiedWithdrawData {
    /// Withdraw amount.
    withdrawAmount: uint64
    /// Withdraw asset id.
    withdrawAssetId: uint256
    /// Withdraw recipient.
    recipientAddressOfWithdraw: address
    /// New withdraw principal.
    withdrawNewPrincipal: int64
    /// Borrow principal amount.
    borrowAmountPrincipal: int64
    /// Reclaim principal amount.
    reclaimAmountPrincipal: int64
}

/// General result data referenced by `supply_withdraw_satisfied`.
struct EvaaMasterClassicSupplyWithdrawSatisfiedGeneralData {
    /// TON amount for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
    /// Two-bit return-repay-remainings flag.
    returnRepayRemainingsFlag: int2
    /// Two-bit custom-payload saturation flag.
    customPayloadSaturationFlag: int2
}

/// Supply-withdraw unsatisfied response from user to master.
struct (0x0000041f) EvaaMasterClassicSupplyWithdrawUnsatisfied {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply data.
    supplyData: Cell<EvaaMasterClassicSupplyWithdrawUnsatisfiedSupplyData>
    /// Empty withdraw data cell.
    withdrawData: cell
    /// Referenced general data.
    generalData: Cell<EvaaMasterClassicSupplyWithdrawUnsatisfiedGeneralData>
}

/// Supply data referenced by `supply_withdraw_unsatisfied`.
struct EvaaMasterClassicSupplyWithdrawUnsatisfiedSupplyData {
    /// Owner address.
    ownerAddress: address
    /// Supply amount.
    supplyAmount: uint64
    /// Supply asset id.
    supplyAssetId: uint256
}

/// General data referenced by `supply_withdraw_unsatisfied`.
struct EvaaMasterClassicSupplyWithdrawUnsatisfiedGeneralData {
    /// TON amount for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
}

/// Supply-withdraw fail message sent from master to user.
struct (0x0000411f) EvaaMasterClassicSupplyWithdrawFail {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply rollback data.
    supplyData: Cell<EvaaMasterClassicSupplyWithdrawFailPrincipalData>
    /// Referenced withdraw rollback data.
    withdrawData: Cell<EvaaMasterClassicSupplyWithdrawFailPrincipalData>
    /// Referenced subaccount data.
    generalData: Cell<EvaaMasterClassicSubaccountData>
}

/// Supply-withdraw success message sent from master to user.
struct (0x0000411a) EvaaMasterClassicSupplyWithdrawSuccess {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply principal data.
    supplyData: Cell<EvaaMasterClassicSupplyWithdrawSuccessPrincipalData>
    /// Referenced withdraw principal data.
    withdrawData: Cell<EvaaMasterClassicSupplyWithdrawSuccessPrincipalData>
    /// Referenced config, dynamics, and subaccount data.
    generalData: Cell<EvaaMasterClassicSupplyWithdrawSuccessGeneralData>
}

/// Signed principal delta data referenced by supply-withdraw fail callbacks.
struct EvaaMasterClassicSupplyWithdrawFailPrincipalData {
    /// Asset id.
    assetId: uint256
    /// Signed principal amount.
    principalAmount: int64
}

/// Unsigned principal amount data referenced by supply-withdraw success callbacks.
struct EvaaMasterClassicSupplyWithdrawSuccessPrincipalData {
    /// Asset id.
    assetId: uint256
    /// Principal amount.
    principalAmount: uint64
}

/// Subaccount-only referenced data.
struct EvaaMasterClassicSubaccountData {
    /// Subaccount id.
    subaccountId: int16
}

/// Success general data referenced by `supply_withdraw_success`.
struct EvaaMasterClassicSupplyWithdrawSuccessGeneralData {
    /// Asset configs.
    assetConfigCollection: map<uint256, EvaaMasterClassicAssetConfig>
    /// Asset dynamics.
    assetDynamicsCollection: map<uint256, EvaaMasterClassicAssetDynamics>
    /// Subaccount id.
    subaccountId: int16
}

/// Supply-withdraw satisfied plus repay remainings response.
struct (0x0000411b) EvaaMasterClassicSupplyWithdrawSatisfiedAndRepayRemainings {
    /// Query id copied from the supply-withdraw flow.
    queryId: uint64
}

/// Idle request to master.
struct (0x00000008) EvaaMasterClassicIdleMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// Target owner address.
    targetAddress: address
    /// Optional subaccount id suffix.
    tail: RemainingBitsAndRefs
}

/// Idle request sent from master to user.
struct (0x00000081) EvaaMasterClassicIdleUser {
    /// Query id copied from the idle request.
    queryId: uint64
    /// Token keys dictionary.
    tokensKeys: cell?
    /// Originator address.
    originatorAddress: address
}

/// Idle excess response.
struct (0x0000081e) EvaaMasterClassicIdleExcess {
    /// Query id copied from the idle request.
    queryId: uint64
}

/// Internal data-check request.
struct (0x0000d001) EvaaMasterClassicDoDataChecks {
    /// Caller-selected query id.
    queryId: uint64
}

/// Oracle price-update callback to master.
struct (0x00000005) EvaaMasterClassicParsePriceFeedUpdates {
    /// Number of price feeds.
    numPriceFeeds: uint8
    /// Linked price feed update cells.
    priceFeedsCell: cell
    /// Sender forwarded by the oracle callback.
    initialSender: address
    /// Referenced nested EVAA operation.
    operationPayload: Cell<EvaaMasterClassicNestedOperation>
}

/// Oracle error callback to master.
struct (0x00010002) EvaaMasterClassicResponseError {
    /// Oracle error code.
    errorCode: uint32
    /// Oracle operation code.
    operationCode: uint32
    /// Referenced nested EVAA operation.
    operationPayload: Cell<EvaaMasterClassicNestedOperation>
}

/// On-chain storage request.
struct (0x00009998) EvaaMasterClassicGetStoreRequest {
    /// Caller-selected query id.
    queryId: uint64
    /// Request body data.
    bodyData: cell
}

/// On-chain storage response.
struct (0x00009999) EvaaMasterClassicGetStoreResponse {
    /// Query id copied from the request.
    queryId: uint64
    /// Request body data.
    bodyData: cell
    /// Full master storage.
    storage: Cell<EvaaMasterClassicStorage>
}

/// Add-to-reserve request.
struct (0x00000a99) EvaaMasterClassicAddToReserve {}

/// Jetton transfer notification accepted by master jetton flows.
struct (0x7362d09c) EvaaMasterClassicJettonTransferNotification {
    /// Jetton transfer query id.
    queryId: uint64
    /// Jetton amount.
    amount: coins
    /// Initial sender address from jetton wallet notification.
    sender: any_address
    /// Raw Either forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Init-master request.
struct (0x000000a1) EvaaMasterClassicInitMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// New asset config collection.
    newAssetConfigCollection: Cell<map<uint256, EvaaMasterClassicAssetConfig>>
    /// Referenced initial dynamics, tokens, and oracles data.
    packedData: Cell<EvaaMasterClassicInitMasterPackedData>
}

/// Packed init-master data.
struct EvaaMasterClassicInitMasterPackedData {
    /// New asset dynamics collection.
    newAssetDynamicsCollection: Cell<map<uint256, EvaaMasterClassicAssetDynamics>>
    /// New token keys dictionary.
    tokensKeys: cell
    /// New oracles info.
    oraclesInfo: cell
}

/// Claim asset reserves request.
struct (0x000000a2) EvaaMasterClassicClaimAssetReserves {
    /// Caller-selected query id.
    queryId: uint64
    /// Reserve receiver.
    targetAddress: address
    /// Asset id.
    assetId: uint256
    /// Amount to claim.
    amountToClaim: uint64
}

/// Disable contract for upgrade.
struct (0x000000e8) EvaaMasterClassicDisableContractForUpgrade {
    /// Caller-selected query id.
    queryId: uint64
}

/// Initialize upgrade.
struct (0x000000c1) EvaaMasterClassicInitUpgrade {
    /// Caller-selected query id.
    queryId: uint64
    /// Pending master code.
    newMasterCode: cell?
    /// Pending user code.
    newUserCode: cell?
}

/// Submit pending upgrade.
struct (0x000000c2) EvaaMasterClassicSubmitUpgrade {
    /// Caller-selected query id.
    queryId: uint64
}

/// Cancel pending upgrade.
struct (0x000000c9) EvaaMasterClassicCancelUpgrade {
    /// Caller-selected query id.
    queryId: uint64
}

/// Update market config.
struct (0x000000e4) EvaaMasterClassicUpdateConfig {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement metadata cell.
    newMeta: cell
    /// Replacement master config cell.
    newConfig: Cell<EvaaMasterClassicConfig>
}

/// Add new token request.
struct (0x00000a32) EvaaMasterClassicAddNewToken {
    /// Caller-selected query id.
    queryId: uint64
    /// New asset id.
    assetKey: uint256
    /// New asset config.
    newAssetConfig: Cell<EvaaMasterClassicAssetConfig>
    /// New asset dynamics.
    newAssetDynamics: Cell<EvaaMasterClassicAssetDynamics>
}

/// Set supervisor request.
struct (0x000000a5) EvaaMasterClassicSetNewSupervisor {
    /// Caller-selected query id.
    queryId: uint64
    /// New supervisor address.
    newSupervisor: address
}

/// Force-enable request.
struct (0x000000e1) EvaaMasterClassicForceEnable {
    /// Caller-selected query id.
    queryId: uint64
}

/// Force-disable request.
struct (0x000000e9) EvaaMasterClassicForceDisableContract {
    /// Caller-selected query id.
    queryId: uint64
}

/// Revert-call message.
struct (0x0000000f) EvaaMasterClassicRevertCall {
    /// Caller-selected query id.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Referenced revert body.
    revertBody: cell
}

/// Internal message bodies accepted by the Classic master.
type EvaaMasterClassicIncomingMessage =
    | EvaaMasterClassicSupplyMaster
    | EvaaMasterClassicSupplySuccess
    | EvaaMasterClassicSupplyFail
    | EvaaMasterClassicSupplyWithdrawMaster
    | EvaaMasterClassicSupplyWithdrawMasterWithoutPrices
    | EvaaMasterClassicSupplyWithdrawSatisfied
    | EvaaMasterClassicSupplyWithdrawUnsatisfied
    | EvaaMasterClassicLiquidateMaster
    | EvaaMasterClassicLiquidateUnsatisfied
    | EvaaMasterClassicLiquidateSatisfied
    | EvaaMasterClassicIdleMaster
    | EvaaMasterClassicDoDataChecks
    | EvaaMasterClassicParsePriceFeedUpdates
    | EvaaMasterClassicResponseError
    | EvaaMasterClassicGetStoreRequest
    | EvaaMasterClassicAddToReserve
    | EvaaMasterClassicJettonTransferNotification
    | EvaaMasterClassicInitMaster
    | EvaaMasterClassicClaimAssetReserves
    | EvaaMasterClassicDisableContractForUpgrade
    | EvaaMasterClassicInitUpgrade
    | EvaaMasterClassicSubmitUpgrade
    | EvaaMasterClassicCancelUpgrade
    | EvaaMasterClassicUpdateConfig
    | EvaaMasterClassicAddNewToken
    | EvaaMasterClassicSetNewSupervisor
    | EvaaMasterClassicForceEnable
    | EvaaMasterClassicForceDisableContract
    | EvaaMasterClassicRevertCall

/// Internal message bodies emitted by the Classic master.
type EvaaMasterClassicOutgoingMessage =
    | EvaaMasterClassicSupplyUser
    | EvaaMasterClassicSupplyExcess
    | EvaaMasterClassicSupplyFailWithData
    | EvaaMasterClassicSupplyExcessAndRepayRemainings
    | EvaaMasterClassicSupplyWithdrawUser
    | EvaaMasterClassicSupplyWithdrawFail
    | EvaaMasterClassicSupplyWithdrawSuccess
    | EvaaMasterClassicSupplyWithdrawSatisfiedAndRepayRemainings
    | EvaaMasterClassicLiquidateUser
    | EvaaMasterClassicLiquidateSuccess
    | EvaaMasterClassicLiquidateFail
    | EvaaMasterClassicLiquidateSuccessReport
    | EvaaMasterClassicIdleUser
    | EvaaMasterClassicIdleExcess
    | EvaaMasterClassicGetStoreResponse

/// Static EVAA master exit-code catalog.
enum EvaaMasterClassicErrors {
    /// Add-to-reserve message lacks required fees.
    AddToReserveNotEnoughFees = 0xa9e9
    /// Claim-reserves flow lacks transaction fees.
    ClaimAssetReservesTransactionFees = 0xa2e9
    /// Incoming asset flow lacks transaction fees.
    IncomingAssetTransactionFees = 0x10e9
    /// Liquidation flow lacks transaction fees.
    LiquidateAssetTransactionFees = 0x30e9
    /// Pyth feed update lacks transaction fees.
    PythFeedsUpdateTransactionFees = 0x40e9
    /// Supply-withdraw master flow lacks transaction fees.
    SupplyWithdrawMasterTransactionFees = 0x50e9
    /// Master liquidation amount exceeds allowed bounds.
    MasterLiquidatingTooMuch = 0x30f1
    /// Account is not eligible for liquidation.
    NotLiquidatable = 0x31f2
    /// Minimum collateral requirement is not met.
    MinCollateralNotSatisfied = 0x31f3
    /// User has insufficient collateral.
    UserNotEnoughCollateral = 0x31f4
    /// User-side liquidation amount exceeds allowed bounds.
    UserLiquidatingTooMuch = 0x31f5
    /// Master has insufficient liquidity.
    MasterNotEnoughLiquidity = 0x31f6
    /// Liquidation price data is missing.
    LiquidationPricesMissing = 0x31f7
    /// Liquidation execution failed.
    LiquidationExecutionCrashed = 0x31fe
    /// Received jetton wallet is not supported.
    ReceivedUnsupportedJetton = 0x40fd
    /// Jetton notification opcode is unsupported.
    UnsupportedJettonOpCode = 0x40fc
    /// Jetton message execution failed.
    JettonExecutionCrashed = 0x40fe
    /// Claim-reserves sender is not admin.
    ClaimAssetReservesNotAdmin = 0xa2fa
    /// Claim-reserves amount is below required minimum.
    ClaimAssetReservesNotEnough = 0xa2f1
    /// Claim-reserves amount exceeds available reserves.
    ClaimAssetReservesTooMuch = 0xa2f9
    /// Message sender is not admin.
    MessageNotFromAdmin = 0x00fa
    /// Message sender is not the master contract.
    MessageNotFromMaster = 0x01fb
    /// Address belongs to a different workchain.
    DifferentWorkchain = 0x55ff
    /// Supply-success sender is not the expected user contract.
    SupplySuccessFakeSender = 0x1afc
    /// Supply-fail sender is not the expected user contract.
    SupplyFailFakeSender = 0x1ffc
    /// Liquidation-unsatisfied sender is not the expected user contract.
    LiquidateUnsatisfiedFakeSender = 0x3ffc
    /// Liquidation-satisfied sender is not the expected user contract.
    LiquidateSatisfiedFakeSender = 0x31fc
    /// Revert sender is not the expected contract.
    RevertFakeSender = 0xf0fc
    /// Supply-withdraw-unsatisfied sender is not the expected user contract.
    SupplyWithdrawUnsatisfiedFakeSender = 0x4ffc
    /// Supply-withdraw-satisfied sender is not the expected user contract.
    SupplyWithdrawSatisfiedFakeSender = 0x41fc
    /// Upgrade freeze period is too short.
    UpgradeNotAllowedFreezeTooShort = 0xc2f1
    /// Upgrade submission is too early.
    UpgradeNotAllowedTooEarlyUpdate = 0xc2f2
    /// Upgrade freeze is too early.
    UpgradeNotAllowedTooEarlyFreeze = 0xc2f3
    /// Upgrade code cell is empty.
    UpgradeNotAllowedNewCodeIsEmpty = 0xc2f4
    /// User code version does not match.
    UserCodeVersionMismatch = 0xc4f4
    /// Upgrade configuration is malformed.
    BrokenUpgradeInfo = 0xc4f2
    /// Required optional value is empty.
    UnexpectedEmptyValue = 0xc4f0
    /// User data changed during processing.
    UserDataChanged = 0xc4f1
    /// Price timestamp is outside accepted range.
    PricesIncorrectTimestamp = 0x50fe
    /// Price value is not positive.
    PricesNotPositive = 0x50f6
    /// Reference token is not allowed.
    RefTokenNotAllowed = 0x50f7
    /// Reference token has no referred price value.
    RefTokenNoReferredValue = 0x50f8
    /// Contract is disabled.
    Disabled = 0x70f0
    /// User withdrawal is already in progress.
    UserWithdrawInProgress = 0x31f0
    /// Bounce arrived for blank state.
    BouncedOnBlank = 0x60ff
    /// Provided address is invalid.
    InvalidAddressProvided = 0x80fa
    /// Custom response payload exceeds size limit.
    CustomResponsePayloadTooBig = 0x80fb
    /// Entry already exists.
    AlreadyExists = 0x80fe
    /// Internal revert invariant failed.
    WeScrewedUpRevert = 0x80ff
    /// Near-zero split invariant failed.
    AroundZeroSplitMessedUp = 0x80f1
    /// Contract is already initialized.
    AlreadyInited = 0x80f2
    /// Input data is invalid.
    InvalidData = 0x8d00
    /// TON asset is unsupported in this path.
    TonUnsupported = 0x0101
    /// Integer is outside the expected range.
    IntegerOutOfExpectedRange = 5
    /// Pyth sender is not authorized.
    PythNotAuthorized = 0x90f0
    /// Feeds operation is unsupported.
    UnsupportedFeedsOperation = 0x90f1
    /// Master Pyth operation is unsupported.
    UnsupportedMasterPythOperation = 0x90f2
    /// Pyth error response contains an unexpected operation.
    UnexpectedOperationInPythErrorResponse = 0x90f3
    /// Pyth callback failed for liquidation.
    PythErrorOnLiquidate = 0x90f4
    /// On-chain getter sender is invalid.
    OnchainGetterInvalidSender = 0x90f5
    /// Pyth callback failed for supply-withdraw.
    PythErrorOnSupplyWithdraw = 0x90f6
    /// Price id is unsupported.
    UnsupportedPriceId = 4000
    /// Price id is not saved.
    NotSavedPriceId = 4001
    /// Referred price id was not found.
    ReferredPriceIdNotFound = 4003
    /// Operation is unsupported.
    UnsupportedOperation = 0xffff
}

fun exportEvaaMasterClassicErrors(): void {}

/// Return collateral quote for a borrow/collateral liquidation pair.
get fun getCollateralQuote(
    borrowAssetId: int,
    borrowLiquidateAmount: int,
    collateralAssetId: int,
    pricesPacked: cell,
): int {
    throw 0;
}

/// Return updated rates for one asset and elapsed time.
get fun getUpdatedRates(
    assetConfigCollection: cell,
    assetDynamicsCollection: cell,
    assetId: int,
    timeElapsed: int,
): EvaaMasterClassicAssetRate {
    throw 0;
}

/// Return updated rates for every asset.
get fun getUpdatedRatesForAllAssets(timeElapsed: int): map<uint256, EvaaMasterClassicPackedAssetRate> {
    throw 0;
}

/// Return current supply and borrow rates for one asset.
get fun getAssetRates(assetId: int): EvaaMasterClassicAssetRate {
    throw 0;
}

/// Return current supply and borrow rates for every asset.
get fun get_assets_rates(): map<uint256, EvaaMasterClassicPackedAssetRate> {
    throw 0;
}

/// Return protocol reserve amount for one asset.
get fun getAssetReserves(assetId: int): int {
    throw 0;
}

/// Return protocol reserve amounts for every asset.
get fun get_assets_reserves(): map<uint256, int65> {
    throw 0;
}

/// Return total supply and total borrow for one asset.
get fun getAssetTotals(assetId: int): EvaaMasterClassicAssetTotals {
    throw 0;
}

/// Return asset dynamics collection.
get fun getAssetsData(): map<uint256, EvaaMasterClassicAssetDynamics> {
    throw 0;
}

/// Return asset config collection.
get fun getAssetsConfig(): map<uint256, EvaaMasterClassicAssetConfig> {
    throw 0;
}

/// Return metadata, upgrade config, and master config bundle.
get fun getConfig(): cell {
    throw 0;
}

/// Return full master storage cell.
get fun getStore(): cell {
    throw 0;
}

/// Return asset dynamics, config, rates, and reserves bundle.
get fun getUIVariables(): EvaaMasterClassicGetUIVariablesReply {
    throw 0;
}

/// Return user contract address for the default subaccount.
get fun get_user_address(ownerAddress: address): address {
    throw 0;
}

/// Return user contract address for a subaccount.
get fun get_user_subaccount_address(ownerAddress: address, subaccountId: int): address {
    throw 0;
}

/// Return minimum attachment for reserve claiming.
get fun claim_asset_reserves_min_attachment(fwdFee: int): int {
    throw 0;
}

/// Return a dummy `supply_user` message body.
get fun dummy_supply_user_message(): cell {
    throw 0;
}

/// Return minimum attachment for supply.
get fun supply_min_attachment(fwdFee: int, supplyUserMessage: cell): int {
    throw 0;
}

/// Return minimum attachment for withdraw.
get fun withdraw_min_attachment(fwdFee: int, withdrawUserMessage: cell): int {
    throw 0;
}

/// Return a dummy `liquidate_user` message body.
get fun dummy_liquidate_user_message(): cell {
    throw 0;
}

/// Return minimum attachment for liquidation.
get fun liquidate_min_attachment(fwdFee: int, liquidateUserMessage: cell): int {
    throw 0;
}

/// Return total supply and borrow principals for one asset.
get fun get_asset_total_principals(assetId: int): EvaaMasterClassicAssetTotals {
    throw 0;
}

/// Return a dummy `supply_withdraw_user` message body.
get fun dummy_supply_withdraw_user_message(): cell {
    throw 0;
}

/// Return minimum attachment for supply-withdraw.
get fun supply_withdraw_min_attachment(fwdFee: int, supplyWithdrawUserMessage: cell): int {
    throw 0;
}

/// Return asset token balance.
get fun get_asset_balance(assetId: int): int {
    throw 0;
}

/// Return asset liquidity.
get fun get_asset_liquidity_by_id(assetId: int): int {
    throw 0;
}

/// Return asset liquidity minus reserves.
get fun get_asset_liquidity_minus_reserves_by_id(assetId: int): int {
    throw 0;
}

/// Return stored supply and borrow rates for one asset.
get fun get_asset_sb_rate(assetId: int): EvaaMasterClassicAssetRate {
    throw 0;
}

/// Return signed activity flag.
get fun get_active(): int {
    throw 0;
}

/// Return token keys dictionary.
get fun getTokensKeys(): map<uint256, uint256> {
    throw 0;
}

/// Return last user contract version.
get fun getLastUserScVersion(): int {
    throw 0;
}

/// Return upgrade configuration.
get fun getUpgradeConfig(): EvaaMasterClassicUpgradeConfigReply {
    throw 0;
}

/// Return reward tracking indexes and last accrual timestamp for one asset.
get fun get_asset_tracking_info(assetId: int): EvaaMasterClassicAssetTrackingInfo {
    throw 0;
}

/// Return supervisor address.
get fun get_supervisor(): address {
    throw 0;
}

/// Return oracle configuration fields.
get fun get_oracles_info(): EvaaMasterClassicGetOraclesInfoReply {
    throw 0;
}
