contract AffluentPool {
    author: "Affluent"
    version: "1.0"
    description: "Curated Affluent pool interface"
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
