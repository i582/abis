/// EVAA v9 master interface for the main Pyth-oracle pool.
contract EvaaMasterPyth {
    author: "EVAA"
    version: "10"
    description: "EVAA Master Pyth ABI with master storage, public getters, admin messages, user-flow messages, Pyth callbacks, and jetton notifications."
    storage: EvaaMasterPythStorage
    incomingMessages: EvaaMasterPythIncomingMessage
    outgoingMessages: EvaaMasterPythOutgoingMessage
    forceAbiExport: EvaaMasterPythGetConfigReply
        | EvaaMasterPythGetUIVariablesReply
        | EvaaMasterPythGetOraclesInfoReply
    thrownErrors: EvaaMasterPythErrors
}

/// Runtime master data root.
struct EvaaMasterPythStorage {
    /// Metadata cell.
    meta: cell
    /// Referenced master and user upgrade configuration.
    upgradeConfig: Cell<EvaaMasterPythUpgradeConfig>
    /// Referenced market configuration.
    masterConfig: Cell<EvaaMasterPythConfig>
    /// Asset dynamics keyed by EVAA asset id.
    assetDynamicsCollection: map<uint256, EvaaMasterPythAssetDynamics>
}

/// Master and user code upgrade configuration.
struct EvaaMasterPythUpgradeConfig {
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
struct EvaaMasterPythConfig {
    /// Asset configs keyed by EVAA asset id.
    assetConfigCollection: map<uint256, EvaaMasterPythAssetConfig>
    /// Signed activity flag.
    ifActive: int8
    /// Admin address.
    admin: address
    /// Pyth oracle configuration.
    oraclesInfo: Cell<EvaaMasterPythOraclesInfo>
    /// Jetton wallet hash to EVAA asset id map.
    tokensKeys: map<uint256, uint256>
    /// Supervisor address.
    supervisor: address
}

/// Pyth oracle settings used by master price callbacks.
struct EvaaMasterPythOraclesInfo {
    /// Pyth contract address.
    pythAddress: address
    /// Pyth-to-EVAA feed maps.
    feedsData: Cell<EvaaMasterPythFeedsData>
    /// Accepted price time-to-live.
    pricesTtl: uint32
    /// Base compute gas estimate for Pyth updates.
    pythComputeBaseGas: uint64
    /// Per-update compute gas estimate for Pyth updates.
    pythComputePerUpdateGas: uint64
    /// Per-update Pyth fee.
    pythSingleUpdateFee: uint64
}

/// Pyth feed mapping dictionaries.
struct EvaaMasterPythFeedsData {
    /// Pyth feed id to EVAA feed id mapping.
    pythToEvaaMap: map<uint256, EvaaMasterPythMapItem>
    /// EVAA reference-token allowlist.
    evaaRefs: map<uint256, uint256>
}

/// Direct Pyth feed mapping.
struct EvaaMasterPythMapItem {
    /// EVAA feed id.
    evaaFeedId: uint256
    /// Optional multiplier Pyth feed id tail.
    multiplierTail: RemainingBitsAndRefs
}

/// Asset configuration stored by asset id.
struct EvaaMasterPythAssetConfig {
    /// Jetton wallet address hash.
    jwAddressHash: uint256
    /// Asset decimals.
    decimals: uint8
    /// Referenced risk and reward parameters.
    params: Cell<EvaaMasterPythAssetConfigParams>
}

/// Asset risk, interest, reward, and high-efficiency parameters.
struct EvaaMasterPythAssetConfigParams {
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
struct EvaaMasterPythAssetDynamics {
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
struct EvaaMasterPythAssetRate {
    /// Supply rate.
    sRate: int
    /// Borrow rate.
    bRate: int
}

/// Packed supply and borrow rates stored as dictionary values by aggregate getters.
struct EvaaMasterPythPackedAssetRate {
    /// Supply rate stored with `store_sb_rate` as uint64.
    sRate: uint64
    /// Borrow rate stored with `store_sb_rate` as uint64.
    bRate: uint64
}

/// Pair of total supply and total borrow values.
struct EvaaMasterPythAssetTotals {
    /// Total supply.
    totalSupply: int
    /// Total borrow.
    totalBorrow: int
}

/// Upgrade config returned by `getUpgradeConfig`.
struct EvaaMasterPythUpgradeConfigReply {
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
struct EvaaMasterPythAssetTrackingInfo {
    /// Supply reward tracking index.
    trackingSupplyIndex: int
    /// Borrow reward tracking index.
    trackingBorrowIndex: int
    /// Last accrual timestamp.
    lastAccrual: int
}

/// Config cell returned by `getConfig`.
struct EvaaMasterPythGetConfigReply {
    /// Metadata cell.
    meta: cell
    /// Upgrade configuration.
    upgradeConfig: Cell<EvaaMasterPythUpgradeConfig>
    /// Market configuration.
    masterConfig: Cell<EvaaMasterPythConfig>
}

/// UI bundle returned by `getUIVariables`.
struct EvaaMasterPythGetUIVariablesReply {
    /// Asset dynamics collection.
    assetDynamicsCollection: map<uint256, EvaaMasterPythAssetDynamics>
    /// Metadata, upgrade config, and master config bundle.
    config: cell
    /// Asset rates dictionary.
    assetsRates: map<uint256, EvaaMasterPythPackedAssetRate>
    /// Asset reserves dictionary.
    assetsReserves: map<uint256, int65>
}

/// Pyth oracle info returned by `get_oracles_info`.
struct EvaaMasterPythGetOraclesInfoReply {
    /// Pyth contract address.
    pythAddress: address
    /// Pyth feed data cell.
    feedsData: cell
    /// Accepted price time-to-live.
    pricesTtl: int
    /// Base compute gas estimate for Pyth updates.
    pythComputeBaseGas: int
    /// Per-update compute gas estimate for Pyth updates.
    pythComputePerUpdateGas: int
    /// Per-update Pyth fee.
    pythSingleUpdateFee: int
}

/// Generic nested operation payload forwarded by Pyth.
struct EvaaMasterPythNestedOperation {
    /// Nested EVAA operation opcode.
    operationCode: uint32
    /// Nested operation query id.
    queryId: uint64
    /// Referenced nested operation body.
    operationPayload: cell
}

/// TON supply request to master.
struct (0x00000001) EvaaMasterPythSupplyMaster {
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
struct (0x00000011) EvaaMasterPythSupplyUser {
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
    extData: Cell<EvaaMasterPythSupplyUserExtData>
}

/// Extra data referenced by `supply_user`.
struct EvaaMasterPythSupplyUserExtData {
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
struct (0x0000011a) EvaaMasterPythSupplySuccess {
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
struct (0x0000011f) EvaaMasterPythSupplyFail {
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
struct (0x000011ae) EvaaMasterPythSupplyExcess {
    /// Query id copied from the supply flow.
    queryId: uint64
    /// Optional custom response payload suffix.
    tail: RemainingBitsAndRefs
}

/// Supply fail response with custom data.
struct (0x00011ae1) EvaaMasterPythSupplyFailWithData {
    /// Query id copied from the supply flow.
    queryId: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Supply success plus repay remainings response.
struct (0x000011ab) EvaaMasterPythSupplyExcessAndRepayRemainings {
    /// Query id copied from the supply flow.
    queryId: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Liquidation request with prices supplied through Pyth.
struct (0x00000003) EvaaMasterPythLiquidateMaster {
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
    responsePayload: Cell<EvaaMasterPythLiquidateResponsePayload>
}

/// Liquidation custom response payload and optional suffix.
struct EvaaMasterPythLiquidateResponsePayload {
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Tagless optional subaccount and custom-payload suffix.
    optionalTail: RemainingBitsAndRefs
}

/// Liquidation request sent from master to user.
struct (0x00000031) EvaaMasterPythLiquidateUser {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Asset configs.
    assetConfigCollection: map<uint256, EvaaMasterPythAssetConfig>
    /// Asset dynamics.
    assetDynamicsCollection: map<uint256, EvaaMasterPythAssetDynamics>
    /// Referenced liquidation user parameters.
    params: Cell<EvaaMasterPythLiquidateUserParams>
}

/// Parameters referenced by `liquidate_user`.
struct EvaaMasterPythLiquidateUserParams {
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
    customPayloadData: Cell<EvaaMasterPythCustomPayloadData>
}

/// Custom payload routing data.
struct EvaaMasterPythCustomPayloadData {
    /// Custom payload recipient.
    customPayloadRecipient: address
    /// Two-bit custom-payload saturation flag.
    customPayloadSaturationFlag: int2
}

/// Liquidation unsatisfied response from user to master.
struct (0x0000031f) EvaaMasterPythLiquidateUnsatisfied {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Referenced unsatisfied liquidation details.
    details: Cell<EvaaMasterPythLiquidateUnsatisfiedDetails>
}

/// Details referenced by `liquidate_unsatisfied`.
struct EvaaMasterPythLiquidateUnsatisfiedDetails {
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
struct (0x00000311) EvaaMasterPythLiquidateSatisfied {
    /// Query id copied from the liquidation request.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Liquidator address.
    liquidatorAddress: address
    /// Transferred asset id.
    transferredAssetId: uint256
    /// Referenced satisfied liquidation details.
    details: Cell<EvaaMasterPythLiquidateSatisfiedDetails>
}

/// Details referenced by `liquidate_satisfied`.
struct EvaaMasterPythLiquidateSatisfiedDetails {
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
    customPayloadData: Cell<EvaaMasterPythCustomPayloadData>
}

/// Liquidation success message sent from master to user.
struct (0x0000311a) EvaaMasterPythLiquidateSuccess {
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
struct (0x0000311f) EvaaMasterPythLiquidateFail {
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
struct (0x0000311d) EvaaMasterPythLiquidateSuccessReport {
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
struct EvaaMasterPythLiquidateFailReport {
    /// Liquidation master error body.
    error: RemainingBitsAndRefs
    /// Referenced custom response payload.
    customResponsePayload: cell
}

/// Supply-withdraw request to master.
struct (0x00000004) EvaaMasterPythSupplyWithdrawMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// Referenced supply data.
    supplyData: cell
    /// Referenced withdraw data.
    withdrawData: Cell<EvaaMasterPythSupplyWithdrawWithdrawData>
    /// Referenced general data.
    generalData: Cell<EvaaMasterPythSupplyWithdrawGeneralData>
}

/// Supply-withdraw request without prices.
struct (0x00000401) EvaaMasterPythSupplyWithdrawMasterWithoutPrices {
    /// Caller-selected query id.
    queryId: uint64
    /// Referenced supply data.
    supplyData: cell
    /// Referenced withdraw data.
    withdrawData: Cell<EvaaMasterPythSupplyWithdrawWithdrawData>
    /// Referenced general data.
    generalData: Cell<EvaaMasterPythSupplyWithdrawGeneralData>
}

/// Withdraw data referenced by supply-withdraw requests.
struct EvaaMasterPythSupplyWithdrawWithdrawData {
    /// Withdraw amount.
    withdrawAmount: uint64
    /// Withdraw asset id.
    withdrawAssetId: uint256
    /// Withdraw recipient.
    recipientAddressOfWithdraw: address
}

/// General data referenced by supply-withdraw requests.
struct EvaaMasterPythSupplyWithdrawGeneralData {
    /// Two-bit include-user-code flag.
    includeUserCode: int2
    /// Requested reference tokens dictionary or classic price cell.
    requestedRefTokens: cell
    /// TON amount for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Tagless optional subaccount and flags suffix.
    optionalTail: RemainingBitsAndRefs
}

/// Supply-withdraw request sent from master to user.
struct (0x00000041) EvaaMasterPythSupplyWithdrawUser {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply data.
    supplyData: Cell<EvaaMasterPythSupplyWithdrawUserSupplyData>
    /// Referenced withdraw data.
    withdrawData: Cell<EvaaMasterPythSupplyWithdrawUserWithdrawData>
    /// Referenced general data.
    generalData: Cell<EvaaMasterPythSupplyWithdrawUserGeneralData>
}

/// Supply data referenced by `supply_withdraw_user`.
struct EvaaMasterPythSupplyWithdrawUserSupplyData {
    /// Supply amount.
    supplyAmount: uint64
    /// Supply asset id.
    supplyAssetId: uint256
}

/// Withdraw data referenced by `supply_withdraw_user`.
struct EvaaMasterPythSupplyWithdrawUserWithdrawData {
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
struct EvaaMasterPythSupplyWithdrawUserGeneralData {
    /// Asset configs.
    assetConfigCollection: map<uint256, EvaaMasterPythAssetConfig>
    /// Asset dynamics.
    assetDynamicsCollection: map<uint256, EvaaMasterPythAssetDynamics>
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
struct (0x00000411) EvaaMasterPythSupplyWithdrawSatisfied {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply result data.
    supplyData: Cell<EvaaMasterPythSupplyWithdrawSatisfiedSupplyData>
    /// Referenced withdraw result data.
    withdrawData: Cell<EvaaMasterPythSupplyWithdrawSatisfiedWithdrawData>
    /// Referenced general result data.
    generalData: Cell<EvaaMasterPythSupplyWithdrawSatisfiedGeneralData>
}

/// Supply result data referenced by `supply_withdraw_satisfied`.
struct EvaaMasterPythSupplyWithdrawSatisfiedSupplyData {
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
struct EvaaMasterPythSupplyWithdrawSatisfiedWithdrawData {
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
struct EvaaMasterPythSupplyWithdrawSatisfiedGeneralData {
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
struct (0x0000041f) EvaaMasterPythSupplyWithdrawUnsatisfied {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply data.
    supplyData: Cell<EvaaMasterPythSupplyWithdrawUnsatisfiedSupplyData>
    /// Empty withdraw data cell.
    withdrawData: cell
    /// Referenced general data.
    generalData: Cell<EvaaMasterPythSupplyWithdrawUnsatisfiedGeneralData>
}

/// Supply data referenced by `supply_withdraw_unsatisfied`.
struct EvaaMasterPythSupplyWithdrawUnsatisfiedSupplyData {
    /// Owner address.
    ownerAddress: address
    /// Supply amount.
    supplyAmount: uint64
    /// Supply asset id.
    supplyAssetId: uint256
}

/// General data referenced by `supply_withdraw_unsatisfied`.
struct EvaaMasterPythSupplyWithdrawUnsatisfiedGeneralData {
    /// TON amount for repay remainings.
    tonAmountForRepayRemainings: uint64
    /// Referenced custom response payload.
    customResponsePayload: cell
    /// Subaccount id.
    subaccountId: int16
}

/// Supply-withdraw fail message sent from master to user.
struct (0x0000411f) EvaaMasterPythSupplyWithdrawFail {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply rollback data.
    supplyData: Cell<EvaaMasterPythSupplyWithdrawFailPrincipalData>
    /// Referenced withdraw rollback data.
    withdrawData: Cell<EvaaMasterPythSupplyWithdrawFailPrincipalData>
    /// Referenced subaccount data.
    generalData: Cell<EvaaMasterPythSubaccountData>
}

/// Supply-withdraw success message sent from master to user.
struct (0x0000411a) EvaaMasterPythSupplyWithdrawSuccess {
    /// Query id copied from the supply-withdraw request.
    queryId: uint64
    /// Referenced supply principal data.
    supplyData: Cell<EvaaMasterPythSupplyWithdrawSuccessPrincipalData>
    /// Referenced withdraw principal data.
    withdrawData: Cell<EvaaMasterPythSupplyWithdrawSuccessPrincipalData>
    /// Referenced config, dynamics, and subaccount data.
    generalData: Cell<EvaaMasterPythSupplyWithdrawSuccessGeneralData>
}

/// Signed principal delta data referenced by supply-withdraw fail callbacks.
struct EvaaMasterPythSupplyWithdrawFailPrincipalData {
    /// Asset id.
    assetId: uint256
    /// Signed principal amount.
    principalAmount: int64
}

/// Unsigned principal amount data referenced by supply-withdraw success callbacks.
struct EvaaMasterPythSupplyWithdrawSuccessPrincipalData {
    /// Asset id.
    assetId: uint256
    /// Principal amount.
    principalAmount: uint64
}

/// Subaccount-only referenced data.
struct EvaaMasterPythSubaccountData {
    /// Subaccount id.
    subaccountId: int16
}

/// Success general data referenced by `supply_withdraw_success`.
struct EvaaMasterPythSupplyWithdrawSuccessGeneralData {
    /// Asset configs.
    assetConfigCollection: map<uint256, EvaaMasterPythAssetConfig>
    /// Asset dynamics.
    assetDynamicsCollection: map<uint256, EvaaMasterPythAssetDynamics>
    /// Subaccount id.
    subaccountId: int16
}

/// Supply-withdraw satisfied plus repay remainings response.
struct (0x0000411b) EvaaMasterPythSupplyWithdrawSatisfiedAndRepayRemainings {
    /// Query id copied from the supply-withdraw flow.
    queryId: uint64
}

/// Idle request to master.
struct (0x00000008) EvaaMasterPythIdleMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// Target owner address.
    targetAddress: address
    /// Optional subaccount id suffix.
    tail: RemainingBitsAndRefs
}

/// Idle request sent from master to user.
struct (0x00000081) EvaaMasterPythIdleUser {
    /// Query id copied from the idle request.
    queryId: uint64
    /// Token keys dictionary.
    tokensKeys: cell?
    /// Originator address.
    originatorAddress: address
}

/// Idle excess response.
struct (0x0000081e) EvaaMasterPythIdleExcess {
    /// Query id copied from the idle request.
    queryId: uint64
}

/// Internal data-check request.
struct (0x0000d001) EvaaMasterPythDoDataChecks {
    /// Caller-selected query id.
    queryId: uint64
}

/// Pyth price-update callback to master.
struct (0x00000005) EvaaMasterPythParsePriceFeedUpdates {
    /// Number of Pyth price feeds.
    numPriceFeeds: uint8
    /// Linked Pyth price feed update cells.
    priceFeedsCell: cell
    /// Sender forwarded by Pyth.
    initialSender: address
    /// Referenced nested EVAA operation.
    operationPayload: Cell<EvaaMasterPythNestedOperation>
}

/// Pyth error callback to master.
struct (0x00010002) EvaaMasterPythResponseError {
    /// Pyth error code.
    errorCode: uint32
    /// Pyth operation code.
    operationCode: uint32
    /// Referenced nested EVAA operation.
    operationPayload: Cell<EvaaMasterPythNestedOperation>
}

/// On-chain storage request.
struct (0x00009998) EvaaMasterPythGetStoreRequest {
    /// Caller-selected query id.
    queryId: uint64
    /// Request body data.
    bodyData: cell
}

/// On-chain storage response.
struct (0x00009999) EvaaMasterPythGetStoreResponse {
    /// Query id copied from the request.
    queryId: uint64
    /// Request body data.
    bodyData: cell
    /// Full master storage.
    storage: Cell<EvaaMasterPythStorage>
}

/// Add-to-reserve request.
struct (0x00000a99) EvaaMasterPythAddToReserve {}

/// Jetton transfer notification accepted by master jetton flows.
struct (0x7362d09c) EvaaMasterPythJettonTransferNotification {
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
struct (0x000000a1) EvaaMasterPythInitMaster {
    /// Caller-selected query id.
    queryId: uint64
    /// New asset config collection.
    newAssetConfigCollection: Cell<map<uint256, EvaaMasterPythAssetConfig>>
    /// Referenced initial dynamics, tokens, and oracles data.
    packedData: Cell<EvaaMasterPythInitMasterPackedData>
}

/// Packed init-master data.
struct EvaaMasterPythInitMasterPackedData {
    /// New asset dynamics collection.
    newAssetDynamicsCollection: Cell<map<uint256, EvaaMasterPythAssetDynamics>>
    /// New token keys dictionary.
    tokensKeys: cell
    /// New oracles info.
    oraclesInfo: cell
}

/// Claim asset reserves request.
struct (0x000000a2) EvaaMasterPythClaimAssetReserves {
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
struct (0x000000e8) EvaaMasterPythDisableContractForUpgrade {
    /// Caller-selected query id.
    queryId: uint64
}

/// Initialize upgrade.
struct (0x000000c1) EvaaMasterPythInitUpgrade {
    /// Caller-selected query id.
    queryId: uint64
    /// Pending master code.
    newMasterCode: cell?
    /// Pending user code.
    newUserCode: cell?
}

/// Submit pending upgrade.
struct (0x000000c2) EvaaMasterPythSubmitUpgrade {
    /// Caller-selected query id.
    queryId: uint64
}

/// Cancel pending upgrade.
struct (0x000000c9) EvaaMasterPythCancelUpgrade {
    /// Caller-selected query id.
    queryId: uint64
}

/// Update market config.
struct (0x000000e4) EvaaMasterPythUpdateConfig {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement metadata cell.
    newMeta: cell
    /// Replacement master config cell.
    newConfig: Cell<EvaaMasterPythConfig>
}

/// Add new token request.
struct (0x00000a32) EvaaMasterPythAddNewToken {
    /// Caller-selected query id.
    queryId: uint64
    /// New asset id.
    assetKey: uint256
    /// New asset config.
    newAssetConfig: Cell<EvaaMasterPythAssetConfig>
    /// New asset dynamics.
    newAssetDynamics: Cell<EvaaMasterPythAssetDynamics>
}

/// Set supervisor request.
struct (0x000000a5) EvaaMasterPythSetNewSupervisor {
    /// Caller-selected query id.
    queryId: uint64
    /// New supervisor address.
    newSupervisor: address
}

/// Force-enable request.
struct (0x000000e1) EvaaMasterPythForceEnable {
    /// Caller-selected query id.
    queryId: uint64
}

/// Force-disable request.
struct (0x000000e9) EvaaMasterPythForceDisableContract {
    /// Caller-selected query id.
    queryId: uint64
}

/// Revert-call message.
struct (0x0000000f) EvaaMasterPythRevertCall {
    /// Caller-selected query id.
    queryId: uint64
    /// Owner address.
    ownerAddress: address
    /// Referenced revert body.
    revertBody: cell
}

/// Internal message bodies accepted by the Pyth master.
type EvaaMasterPythIncomingMessage =
    | EvaaMasterPythSupplyMaster
    | EvaaMasterPythSupplySuccess
    | EvaaMasterPythSupplyFail
    | EvaaMasterPythSupplyWithdrawMaster
    | EvaaMasterPythSupplyWithdrawMasterWithoutPrices
    | EvaaMasterPythSupplyWithdrawSatisfied
    | EvaaMasterPythSupplyWithdrawUnsatisfied
    | EvaaMasterPythLiquidateMaster
    | EvaaMasterPythLiquidateUnsatisfied
    | EvaaMasterPythLiquidateSatisfied
    | EvaaMasterPythIdleMaster
    | EvaaMasterPythDoDataChecks
    | EvaaMasterPythParsePriceFeedUpdates
    | EvaaMasterPythResponseError
    | EvaaMasterPythGetStoreRequest
    | EvaaMasterPythAddToReserve
    | EvaaMasterPythJettonTransferNotification
    | EvaaMasterPythInitMaster
    | EvaaMasterPythClaimAssetReserves
    | EvaaMasterPythDisableContractForUpgrade
    | EvaaMasterPythInitUpgrade
    | EvaaMasterPythSubmitUpgrade
    | EvaaMasterPythCancelUpgrade
    | EvaaMasterPythUpdateConfig
    | EvaaMasterPythAddNewToken
    | EvaaMasterPythSetNewSupervisor
    | EvaaMasterPythForceEnable
    | EvaaMasterPythForceDisableContract
    | EvaaMasterPythRevertCall

/// Internal message bodies emitted by the Pyth master.
type EvaaMasterPythOutgoingMessage =
    | EvaaMasterPythSupplyUser
    | EvaaMasterPythSupplyExcess
    | EvaaMasterPythSupplyFailWithData
    | EvaaMasterPythSupplyExcessAndRepayRemainings
    | EvaaMasterPythSupplyWithdrawUser
    | EvaaMasterPythSupplyWithdrawFail
    | EvaaMasterPythSupplyWithdrawSuccess
    | EvaaMasterPythSupplyWithdrawSatisfiedAndRepayRemainings
    | EvaaMasterPythLiquidateUser
    | EvaaMasterPythLiquidateSuccess
    | EvaaMasterPythLiquidateFail
    | EvaaMasterPythLiquidateSuccessReport
    | EvaaMasterPythIdleUser
    | EvaaMasterPythIdleExcess
    | EvaaMasterPythGetStoreResponse

/// Static EVAA master exit-code catalog.
enum EvaaMasterPythErrors {
    /// Insufficient fees for adding assets to reserves.
    AddToReserveNotEnoughFees = 0xa9e9
    /// Insufficient fees for reserve-claim transaction.
    ClaimAssetReservesTransactionFees = 0xa2e9
    /// Insufficient fees for incoming asset flow.
    IncomingAssetTransactionFees = 0x10e9
    /// Insufficient fees for liquidation asset flow.
    LiquidateAssetTransactionFees = 0x30e9
    /// Insufficient fees for Pyth feed updates.
    PythFeedsUpdateTransactionFees = 0x40e9
    /// Insufficient fees for supply-withdraw master flow.
    SupplyWithdrawMasterTransactionFees = 0x50e9
    /// Master attempted to liquidate too much.
    MasterLiquidatingTooMuch = 0x30f1
    /// Target position is not liquidatable.
    NotLiquidatable = 0x31f2
    /// Minimum collateral requirement is not met.
    MinCollateralNotSatisfied = 0x31f3
    /// User lacks required collateral.
    UserNotEnoughCollateral = 0x31f4
    /// User liquidation amount exceeds allowed limit.
    UserLiquidatingTooMuch = 0x31f5
    /// Master lacks available liquidity.
    MasterNotEnoughLiquidity = 0x31f6
    /// Required liquidation prices are absent.
    LiquidationPricesMissing = 0x31f7
    /// Liquidation execution failed.
    LiquidationExecutionCrashed = 0x31fe
    /// Jetton notification uses an unknown asset.
    ReceivedUnsupportedJetton = 0x40fd
    /// Jetton notification uses an unsupported opcode.
    UnsupportedJettonOpCode = 0x40fc
    /// Jetton flow execution failed.
    JettonExecutionCrashed = 0x40fe
    /// Reserve claim sender is not admin.
    ClaimAssetReservesNotAdmin = 0xa2fa
    /// Requested reserve amount is unavailable.
    ClaimAssetReservesNotEnough = 0xa2f1
    /// Reserve claim amount exceeds allowed limit.
    ClaimAssetReservesTooMuch = 0xa2f9
    /// Message sender is not admin.
    MessageNotFromAdmin = 0x00fa
    /// Message sender is not master.
    MessageNotFromMaster = 0x01fb
    /// Address workchain does not match.
    DifferentWorkchain = 0x55ff
    /// Supply success callback sender is invalid.
    SupplySuccessFakeSender = 0x1afc
    /// Supply fail callback sender is invalid.
    SupplyFailFakeSender = 0x1ffc
    /// Unsatisfied liquidation callback sender is invalid.
    LiquidateUnsatisfiedFakeSender = 0x3ffc
    /// Satisfied liquidation callback sender is invalid.
    LiquidateSatisfiedFakeSender = 0x31fc
    /// Revert callback sender is invalid.
    RevertFakeSender = 0xf0fc
    /// Unsatisfied supply-withdraw callback sender is invalid.
    SupplyWithdrawUnsatisfiedFakeSender = 0x4ffc
    /// Satisfied supply-withdraw callback sender is invalid.
    SupplyWithdrawSatisfiedFakeSender = 0x41fc
    /// Upgrade freeze interval is too short.
    UpgradeNotAllowedFreezeTooShort = 0xc2f1
    /// Upgrade submission is too early.
    UpgradeNotAllowedTooEarlyUpdate = 0xc2f2
    /// Upgrade freeze is too early.
    UpgradeNotAllowedTooEarlyFreeze = 0xc2f3
    /// Upgrade code cell is empty.
    UpgradeNotAllowedNewCodeIsEmpty = 0xc2f4
    /// User code version does not match.
    UserCodeVersionMismatch = 0xc4f4
    /// Upgrade configuration is inconsistent.
    BrokenUpgradeInfo = 0xc4f2
    /// Required optional value is empty.
    UnexpectedEmptyValue = 0xc4f0
    /// User data changed during operation.
    UserDataChanged = 0xc4f1
    /// Price timestamp is outside accepted range.
    PricesIncorrectTimestamp = 0x50fe
    /// Price value is not positive.
    PricesNotPositive = 0x50f6
    /// Reference token is not allowed.
    RefTokenNotAllowed = 0x50f7
    /// Reference token has no referred value.
    RefTokenNoReferredValue = 0x50f8
    /// Contract is disabled.
    Disabled = 0x70f0
    /// User withdraw flow is already in progress.
    UserWithdrawInProgress = 0x31f0
    /// Bounce arrived without expected payload.
    BouncedOnBlank = 0x60ff
    /// Provided address is invalid.
    InvalidAddressProvided = 0x80fa
    /// Custom response payload exceeds size limit.
    CustomResponsePayloadTooBig = 0x80fb
    /// Item already exists.
    AlreadyExists = 0x80fe
    /// Revert flow reached an inconsistent state.
    WeScrewedUpRevert = 0x80ff
    /// Signed split around zero is inconsistent.
    AroundZeroSplitMessedUp = 0x80f1
    /// Contract is already initialized.
    AlreadyInited = 0x80f2
    /// Input data is invalid.
    InvalidData = 0x8d00
    /// TON asset flow is unsupported.
    TonUnsupported = 0x0101
    /// Integer value is outside expected range.
    IntegerOutOfExpectedRange = 5
    /// Pyth callback sender is unauthorized.
    PythNotAuthorized = 0x90f0
    /// Feed operation is unsupported.
    UnsupportedFeedsOperation = 0x90f1
    /// Master Pyth operation is unsupported.
    UnsupportedMasterPythOperation = 0x90f2
    /// Pyth error response contains an unexpected operation.
    UnexpectedOperationInPythErrorResponse = 0x90f3
    /// Pyth error occurred during liquidation.
    PythErrorOnLiquidate = 0x90f4
    /// On-chain getter sender is invalid.
    OnchainGetterInvalidSender = 0x90f5
    /// Pyth error occurred during supply-withdraw.
    PythErrorOnSupplyWithdraw = 0x90f6
    /// Price feed id is unsupported.
    UnsupportedPriceId = 4000
    /// Price feed id is not saved.
    NotSavedPriceId = 4001
    /// Referred price feed id is missing.
    ReferredPriceIdNotFound = 4003
    /// Operation is unsupported.
    UnsupportedOperation = 0xffff
}

fun exportEvaaMasterPythErrors(): void {}

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
): EvaaMasterPythAssetRate {
    throw 0;
}

/// Return updated rates for every asset.
get fun getUpdatedRatesForAllAssets(timeElapsed: int): map<uint256, EvaaMasterPythPackedAssetRate> {
    throw 0;
}

/// Return current supply and borrow rates for one asset.
get fun getAssetRates(assetId: int): EvaaMasterPythAssetRate {
    throw 0;
}

/// Return current supply and borrow rates for every asset.
get fun get_assets_rates(): map<uint256, EvaaMasterPythPackedAssetRate> {
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
get fun getAssetTotals(assetId: int): EvaaMasterPythAssetTotals {
    throw 0;
}

/// Return asset dynamics collection.
get fun getAssetsData(): map<uint256, EvaaMasterPythAssetDynamics> {
    throw 0;
}

/// Return asset config collection.
get fun getAssetsConfig(): map<uint256, EvaaMasterPythAssetConfig> {
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
get fun getUIVariables(): EvaaMasterPythGetUIVariablesReply {
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
get fun get_asset_total_principals(assetId: int): EvaaMasterPythAssetTotals {
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
get fun get_asset_sb_rate(assetId: int): EvaaMasterPythAssetRate {
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
get fun getUpgradeConfig(): EvaaMasterPythUpgradeConfigReply {
    throw 0;
}

/// Return reward tracking indexes and last accrual timestamp for one asset.
get fun get_asset_tracking_info(assetId: int): EvaaMasterPythAssetTrackingInfo {
    throw 0;
}

/// Return supervisor address.
get fun get_supervisor(): address {
    throw 0;
}

/// Return oracle configuration fields.
get fun get_oracles_info(): EvaaMasterPythGetOraclesInfoReply {
    throw 0;
}
