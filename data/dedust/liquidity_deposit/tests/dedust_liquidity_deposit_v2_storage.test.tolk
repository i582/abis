import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_liquidity_deposit_v2.types"
import "../wrappers/DedustLiquidityDepositV2.gen"

const FIXTURE_BOC_PATH = "data/dedust/liquidity_deposit/testdata/DedustLiquidityDepositV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x80edc8d7bbbb6526c3b06ccb7c2d02a82c20d8ccdf431bf4088b1f1470cc94cc
const PINNED_MAINNET_BLOCK = 71184765

const MAINNET_DEDUST_LIQUIDITY_DEPOSIT_V2_ADDRESS = "EQCDfi69jD02bImrXQGB_PXAOq3UO95ywF1-6Bnxkh90uU9Q"
const MAINNET_DEDUST_FACTORY_V2_ADDRESS = "EQBfBWT7X2BHg9tXAxzhz2aKiNTU1tpt5NsiK0uSDW_YAJ67"
const MAINNET_DEDUST_OWNER_ADDRESS = "EQCwhpDIOXevtrSRj6MTnR-flPM_EDH-AziwiP4uAJ0e6Z6z"
const MAINNET_USDT_ASSET_HASH = 0xb113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe

fun mainnetDedustLiquidityDepositV2(): DedustLiquidityDepositV2 {
    return DedustLiquidityDepositV2.fromAddress(
        address(MAINNET_DEDUST_LIQUIDITY_DEPOSIT_V2_ADDRESS),
    );
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun expectNativeAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(4)).toEqual(0);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun expectUsdtAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(4)).toEqual(1);
    expect(asset.loadInt(8)).toEqual(0);
    expect(asset.loadUint(256)).toEqual(MAINNET_USDT_ASSET_HASH);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun usdtAssetCell(): cell {
    return beginCell()
        .storeUint(1, 4)
        .storeInt(0, 8)
        .storeUint(MAINNET_USDT_ASSET_HASH, 256)
        .endCell();
}

fun expectNativeAsset(asset: DedustAsset): void {
    match (asset) {
        DedustAssetNative => {}
        DedustAssetJetton => {
            Assert.fail("Expected native DeDust asset");
        }
    }
}

fun expectUsdtAsset(asset: DedustAsset): void {
    match (asset) {
        DedustAssetNative => {
            Assert.fail("Expected USDT DeDust asset");
        }
        DedustAssetJetton => {
            expect(asset.workchainId).toEqual(0);
            expect(asset.toCell().hash()).toEqual(usdtAssetCell().hash());
        }
    }
}

fun loadDedustLiquidityDepositV2StorageFromFork(
    deposit: DedustLiquidityDepositV2,
): DedustLiquidityDepositV2Storage {
    val account = testing.getAccountState(deposit.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("DedustLiquidityDepositV2", FIXTURE_BOC_PATH).hash(),
            );
            return DedustLiquidityDepositV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Liquidity Deposit v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Liquidity Deposit v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test dedust liquidity deposit v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("DedustLiquidityDepositV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust liquidity deposit v2 historical mainnet storage and getters`() {
    val deposit = mainnetDedustLiquidityDepositV2();
    val storage = loadDedustLiquidityDepositV2StorageFromFork(deposit);
    val details = storage.details.load();
    val proof = storage.proof.load();
    val proofParams = proof.params.load();
    val factory = deposit.getFactoryAddr();
    val owner = deposit.getOwnerAddr();
    val pool = deposit.getPoolAddr();
    val poolParams = deposit.getPoolParams();
    val targetBalances = deposit.getTargetBalances();
    val balances = deposit.getBalances();
    val processing = deposit.isProcessing();
    val minLpAmount = deposit.getMinLpAmount();
    var getterAsset0 = poolParams.asset0;
    var getterAsset1 = poolParams.asset1;

    expect(scripts.isContractDeployed(deposit.address)).toBeTrue();
    expectInternalAddress(pool.addr);

    expect(storage.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(storage.ownerAddr).toEqual(address(MAINNET_DEDUST_OWNER_ADDRESS));
    expect(storage.proofCode.hash()).toBeGreater(0);
    expect(storage.asset0Balance).toBeGreaterOrEqual(0);
    expect(storage.asset1Balance).toBeGreaterOrEqual(0);
    expect(storage.minLpAmount).toBeGreaterOrEqual(0);

    expect(details.asset0TargetBalance).toBeGreaterOrEqual(0);
    expect(details.asset1TargetBalance).toBeGreaterOrEqual(0);
    expect(details.asset0TargetBalance + details.asset1TargetBalance).toBeGreater(0);
    expect(details.poolParams.isStable).toBeFalse();
    expectNativeAsset(details.poolParams.asset0);
    expectUsdtAsset(details.poolParams.asset1);

    expect(proof.factoryAddr).toEqual(storage.factoryAddr);
    expect(proof.contractType).toEqual(0x03);
    expect(proofParams.ownerAddr).toEqual(storage.ownerAddr);
    expect(proofParams.poolParams.isStable).toEqual(details.poolParams.isStable);
    expectNativeAsset(proofParams.poolParams.asset0);
    expectUsdtAsset(proofParams.poolParams.asset1);

    expect(factory.addr).toEqual(storage.factoryAddr);
    expect(owner.addr).toEqual(storage.ownerAddr);
    expect(poolParams.isStable).toEqual(details.poolParams.isStable);
    expectNativeAssetSlice(mutate getterAsset0);
    expectUsdtAssetSlice(mutate getterAsset1);
    expect(targetBalances.asset0TargetBalance).toEqual(details.asset0TargetBalance);
    expect(targetBalances.asset1TargetBalance).toEqual(details.asset1TargetBalance);
    expect(balances.asset0Balance).toEqual(storage.asset0Balance);
    expect(balances.asset1Balance).toEqual(storage.asset1Balance);
    expect(processing.status).toEqual(storage.isProcessing);
    expect(minLpAmount.minLpAmount).toEqual(storage.minLpAmount);

    println("DEDUST_LIQUIDITY_DEPOSIT_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_LIQUIDITY_DEPOSIT_V2_ADDRESS={}", deposit.address);
    println("DEDUST_LIQUIDITY_DEPOSIT_V2_STORAGE={}", storage);
}
