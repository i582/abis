import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_pool_curve_fi_stable.types"
import "../wrappers/CoffeePoolCurveFiStable.gen"

const FIXTURE_BOC_PATH = "data/coffee/pool_curve_fi_stable/testdata/CoffeePoolCurveFiStable.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5da7430c2fd4196297a2321db8bfc70871f5980fe488997e045cc1ded763e23c
const EXPECTED_FACTORY_ADDRESS = "EQAsf2sDPfoo-0IjnRA7l_gJBB9jyo4zqfCG_1IFCCI_Qbef"
const EXPECTED_BMTON_MINTER_HASH = 0x92c4664f1ea6b74ed9ce0e031a9fc0843348dfe87a58faea27fcd31e1608caaa
const PINNED_MAINNET_BLOCK = 71349505

const MAINNET_COFFEE_POOL_CURVE_FI_STABLE_ADDRESS = "EQA7fZK6kuU_6qfrJFqzMZ7hqEJwKvrzT6Xu24eu0xRDp4uv"

fun mainnetCoffeePoolCurveFiStable(): CoffeePoolCurveFiStable {
    return CoffeePoolCurveFiStable.fromAddress(
        address(MAINNET_COFFEE_POOL_CURVE_FI_STABLE_ADDRESS),
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

fun expectNativeAsset(asset: CoffeePoolAsset): void {
    match (asset) {
        CoffeePoolNativeAsset => {}
        CoffeePoolJettonAsset => {
            Assert.fail("Expected native Coffee pool asset");
        }
        CoffeePoolExtraAsset => {
            Assert.fail("Expected native Coffee pool asset");
        }
    }
}

fun expectBmtonAsset(asset: CoffeePoolAsset): void {
    match (asset) {
        CoffeePoolNativeAsset => {
            Assert.fail("Expected bmTON Coffee pool asset");
        }
        CoffeePoolJettonAsset => {
            expect(asset.chain).toEqual(0);
            expect(asset.hash).toEqual(EXPECTED_BMTON_MINTER_HASH);
        }
        CoffeePoolExtraAsset => {
            Assert.fail("Expected bmTON Coffee pool asset");
        }
    }
}

fun expectNativeAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(2)).toEqual(0);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun expectBmtonAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(2)).toEqual(1);
    expect(asset.loadUint(8)).toEqual(0);
    expect(asset.loadUint(256)).toEqual(EXPECTED_BMTON_MINTER_HASH);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun loadCoffeePoolCurveFiStableStorageFromFork(
    pool: CoffeePoolCurveFiStable,
): CoffeePoolCurveFiStableStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeePoolCurveFiStable", FIXTURE_BOC_PATH).hash());
            return CoffeePoolCurveFiStableStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee CurveFi stable Pool mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee CurveFi stable Pool mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee curve fi stable pool code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeePoolCurveFiStable", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee curve fi stable pool mainnet storage and getters`() {
    val pool = mainnetCoffeePoolCurveFiStable();
    val storage = loadCoffeePoolCurveFiStableStorageFromFork(pool);
    val proof = storage.initData.load();
    val poolData = pool.getPoolData();
    val jettonData = pool.getJettonData();
    val walletAddress = pool.getWalletAddress(pool.address);
    val asset1Cell = poolData.asset1.toCell();
    val asset2Cell = poolData.asset2.toCell();
    val swapOut = pool.estimateSwapAmount(asset1Cell.beginParse(), 1000000);
    val withdrawOut = pool.estimateLiquidityWithdrawAmount(1000);
    val depositOut = pool.estimateLiquidityDepositAmount(1000000, 1000000);
    val ammSettings = poolData.ammSettings!.load();
    var getterAsset1 = asset1Cell.beginParse();
    var getterAsset2 = asset2Cell.beginParse();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(proof.factoryAddress).toEqual(address(EXPECTED_FACTORY_ADDRESS));
    match (proof.body) {
        CoffeePoolVaultProofBody => {
            Assert.fail("Expected Pool proof body in Coffee CurveFi stable Pool storage");
        }
        CoffeePoolPoolProofBody => {
            expectNativeAsset(proof.body.asset1);
            expectBmtonAsset(proof.body.asset2);
            expect(proof.body.asset1.toCell().hash()).toEqual(asset1Cell.hash());
            expect(proof.body.asset2.toCell().hash()).toEqual(asset2Cell.hash());
            expect(proof.body.amm).toEqual(1);
            expect(proof.body.ammSettings).toBeNotNull();
            expect(proof.body.ammSettings!.hash()).toEqual(poolData.ammSettings!.hash());
        }
        CoffeePoolLiquidityDepositoryProofBody => {
            Assert.fail("Expected Pool proof body in Coffee CurveFi stable Pool storage");
        }
        CoffeePoolCreatorProofBody => {
            Assert.fail("Expected Pool proof body in Coffee CurveFi stable Pool storage");
        }
    }

    expect(storage.initCode.hash()).toBeGreater(0);
    expect(storage.isActive).toEqual(poolData.active);
    expect(storage.reserve1).toEqual(poolData.reserve1);
    expect(storage.reserve2).toEqual(poolData.reserve2);
    expect(storage.totalSupply).toEqual(poolData.totalSupply);
    expect(storage.protocolFee).toEqual(poolData.protocolFee);
    expect(storage.lpFee).toEqual(poolData.lpFee);
    expect(storage.protocolFeeCollectedAsset1).toBeGreaterOrEqual(0);
    expect(storage.protocolFeeCollectedAsset2).toBeGreaterOrEqual(0);
    expect(storage.lpWalletCode.hash()).toEqual(jettonData.jettonWalletCode.hash());

    expect(poolData.poolVersion).toEqual(1);
    expect(poolData.amm).toEqual(1);
    expect(poolData.ammSettings).toBeNotNull();
    expect(poolData.active).toBeTrue();
    expect(poolData.reserve1).toBeGreater(0);
    expect(poolData.reserve2).toBeGreater(0);
    expect(poolData.totalSupply).toBeGreater(0);
    expect(ammSettings.amplification).toBeGreater(0);
    expect(ammSettings.asset1Weight).toBeGreater(0);
    expect(ammSettings.asset2Weight).toBeGreater(0);

    expectNativeAssetSlice(mutate getterAsset1);
    expectBmtonAssetSlice(mutate getterAsset2);

    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(address(EXPECTED_FACTORY_ADDRESS));
    expect(jettonData.jettonContent.hash()).toBeGreater(0);
    expect(jettonData.jettonWalletCode.hash()).toBeGreater(0);
    expectInternalAddress(walletAddress);

    expect(swapOut.inputAmount).toBeGreater(0);
    expect(swapOut.inputAmount).toBeLessOrEqual(1000000);
    expect(swapOut.outputAmount).toBeGreater(0);
    expect(withdrawOut.amount1).toBeGreaterOrEqual(0);
    expect(withdrawOut.amount2).toBeGreaterOrEqual(0);
    expect(depositOut.amount1Used).toBeGreaterOrEqual(0);
    expect(depositOut.amount2Used).toBeGreaterOrEqual(0);
    expect(depositOut.lpAmount).toBeGreaterOrEqual(0);
    expect(depositOut.lpToLock).toEqual(0);

    println("COFFEE_POOL_CURVE_FI_STABLE_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_POOL_CURVE_FI_STABLE_ADDRESS={}", pool.address);
    println("COFFEE_POOL_CURVE_FI_STABLE_STORAGE={}", storage);
    println("COFFEE_POOL_CURVE_FI_STABLE_PROOF={}", proof);
}
