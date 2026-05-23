// Generated from XML ABI schemas.
// Source schema: schemas/affluent.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract AffluentMultiplyVaultV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/affluent.xml"
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
    globalDepositValueCap: int
    withdrawFeeRate: int
    queueWithdrawFeeRate: int
    depositQueueTotalSize: int
    depositQueueCounter: int
    depositQueuePendingDict: cell?
    depositQueueProcessingDict: cell?
    withdrawQueueTotalSize: int
    withdrawQueueCounter: int
    withdrawQueuePendingDict: cell?
    withdrawQueueProcessingDict: cell?
    interactiveVaults: cell?
    xchainConnectorAddress: cell
    xchainConfig: cell?
    xchainUpdateHash: int
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
        globalDepositValueCap: 0,
        withdrawFeeRate: 0,
        queueWithdrawFeeRate: 0,
        depositQueueTotalSize: 0,
        depositQueueCounter: 0,
        depositQueuePendingDict: null,
        depositQueueProcessingDict: null,
        withdrawQueueTotalSize: 0,
        withdrawQueueCounter: 0,
        withdrawQueuePendingDict: null,
        withdrawQueueProcessingDict: null,
        interactiveVaults: null,
        xchainConnectorAddress: createEmptyCell(),
        xchainConfig: null,
        xchainUpdateHash: 0,
    };
}

get fun is_strategy_vault(): bool {
    return false;
}

get fun get_rfq_address(index: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
