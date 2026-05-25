contract AffluentMultiplyVault {
    author: "Affluent"
    version: "1.0"
    description: "Curated Affluent multiply vault interface"
}

struct GetVaultDataAffluentVaultData {
    ownerAddress: address
    assets: cell
    factorialPools: cell?
    aggregatorIndex: int
    rfqIndex: int
    totalSupply: int
    collectedManagementFee: int
    collectedProtocolFee: int
    isExecutingStrategy: bool
    config: cell
    code: cell
    protocolFeeManagerAddress: address
    manager: address
    isPrivateVault: bool
    depositCloseTimestamp: int64
    withdrawCloseTimestamp: int64
    whitelistedMinters: cell?
    lastCollectedTime: int64
    managementFeeRatePerYear: int32
    protocolFeeRatePerYear: int32
    maxLeverageRatio: int32
    assetWalletDict: cell
    walletAssetDict: cell
    rfqConfig: cell?
    gasConfig: cell?
    oracleConfig: cell?
    managementFeeRecipientAddress: address?
    guardianAddress: address?
    timelock: int
    pendingOwnerActionIndex: int
    pendingOwnerActionCount: int
    pendingOwnerAction: address?
    walletCode: cell
    dataAggregatorCode: cell
    rfqCode: cell
    content: cell
}

get fun get_vault_data(): GetVaultDataAffluentVaultData {
    return {
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        assets: createEmptyCell(),
        factorialPools: null,
        aggregatorIndex: 0,
        rfqIndex: 0,
        totalSupply: 0,
        collectedManagementFee: 0,
        collectedProtocolFee: 0,
        isExecutingStrategy: false,
        config: createEmptyCell(),
        code: createEmptyCell(),
        protocolFeeManagerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        manager: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        isPrivateVault: false,
        depositCloseTimestamp: 0,
        withdrawCloseTimestamp: 0,
        whitelistedMinters: null,
        lastCollectedTime: 0,
        managementFeeRatePerYear: 0,
        protocolFeeRatePerYear: 0,
        maxLeverageRatio: 0,
        assetWalletDict: createEmptyCell(),
        walletAssetDict: createEmptyCell(),
        rfqConfig: null,
        gasConfig: null,
        oracleConfig: null,
        managementFeeRecipientAddress: null,
        guardianAddress: null,
        timelock: 0,
        pendingOwnerActionIndex: 0,
        pendingOwnerActionCount: 0,
        pendingOwnerAction: null,
        walletCode: createEmptyCell(),
        dataAggregatorCode: createEmptyCell(),
        rfqCode: createEmptyCell(),
        content: createEmptyCell(),
    };
}

get fun is_strategy_vault(): bool {
    return false;
}

get fun get_rfq_address(index: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
