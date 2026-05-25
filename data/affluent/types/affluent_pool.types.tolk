contract AffluentPool {
    author: "Affluent"
    version: "1.0"
    description: "Curated Affluent pool interface"
    storage: AffluentPoolStorage
    forceAbiExport: AffluentPoolAssetStorageRecord | AffluentPoolBasicVariantData | AffluentPoolAdvancedVariantData
}

struct AffluentPoolStorage {
    isInitialized: bool
    id: coins
    ownerAddress: address?
    feeConfigurerAddress: address?
    protocolFeeRate: uint14
    oracleAddress: address?
    oracleConfig: cell
    maxLoanLeverageRatio: uint20
    maxLoanVarRatio: uint14
    liquidateLeverageRatio: uint20
    liquidateVarRatio: uint14
    minLiquidateCloseRatio: uint14
    maxLiquidateCloseRatio: uint14
    gasConfig: Cell<AffluentPoolGasConfig>
    assets: cell?
    variantData: cell
}

struct AffluentPoolGasConfig {
    unknownGas0: coins
    unknownGas1: coins
    unknownGas2: coins
    unknownGas3: coins
    unknownGas4: coins
    unknownGas5: coins
    unknownGas6: coins
    unknownGas7: coins
    unknownGas8: coins
}

struct AffluentPoolAssetStorageRecord {
    config: Cell<AffluentPoolAssetStorageConfig>
    lastUpdatedTime: uint40
    storedInterestRate: coins
    collectedProtocolFee: coins
    cash: coins
    totalSupply: coins
    totalBorrow: coins
    supplyShare: coins
    borrowShare: coins
}

struct AffluentPoolAssetStorageConfig {
    wallet: address
    irmAddress: address
    irmData: cell
    riskFactor: uint14
    liquidationIncentive: uint14
    isCollateral: bool
    isBorrowable: bool
}

struct AffluentPoolBasicVariantData {
    accountCode: cell
}

struct AffluentPoolAdvancedVariantData {
    version: uint16
    accountCode: cell
    advancedAccountCode: cell
}

struct GetPoolDataAssets {
    lastUpdatedTime: int32
    storedInterestRate: int
    collectedProtocolFee: int
    cash: int
    totalSupply: int
    totalBorrow: int
    supplyShare: int
    borrowShare: int
    wallet: address
    irmAddress: address
    irmData: cell
    riskFactor: int
    liquidationIncentive: int
    isCollateral: bool
    isBorrowable: bool
    assetAddress: address
}

struct GetPoolDataReply {
    isInitialized: bool
    id: int
    ownerAddress: address?
    feeConfigurerAddress: address?
    protocolFeeRate: int
    oracleAddress: address?
    oracleConfig: cell?
    maxLoanLeverageRatio: int
    maxLoanVarRatio: int
    liquidateLeverageRatio: int
    liquidateVarRatio: int
    minLiquidateCloseRatio: int
    maxLiquidateCloseRatio: int
    assets: lisp_list<GetPoolDataAssets>
    gasCell: cell?
    accountCode: cell
}

get fun get_pool_data(): GetPoolDataReply {
    return {
        isInitialized: false,
        id: 0,
        ownerAddress: null,
        feeConfigurerAddress: null,
        protocolFeeRate: 0,
        oracleAddress: null,
        oracleConfig: null,
        maxLoanLeverageRatio: 0,
        maxLoanVarRatio: 0,
        liquidateLeverageRatio: 0,
        liquidateVarRatio: 0,
        minLiquidateCloseRatio: 0,
        maxLiquidateCloseRatio: 0,
        assets: [],
        gasCell: null,
        accountCode: createEmptyCell(),
    };
}
