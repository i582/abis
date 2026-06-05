import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_pool_constant_product.types"
import "../wrappers/CoffeePoolConstantProduct.gen"

const FIXTURE_BOC_PATH = "data/coffee/pool_constant_product/testdata/CoffeePoolConstantProduct.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xd236d360e53464a3a47837743602a9b04b501a329bbc20c356c24cfd355378cd
const EXPECTED_FACTORY_ADDRESS = "EQAsf2sDPfoo-0IjnRA7l_gJBB9jyo4zqfCG_1IFCCI_Qbef"
const EXPECTED_CES_MINTER_HASH = 0xa5d12e31be87867851a28d3ce271203c8fa1a28ae826256e73c506d94d49edad
const PINNED_MAINNET_BLOCK = 71349505

const MAINNET_COFFEE_POOL_CONSTANT_PRODUCT_ADDRESS = "EQA5NdnaYUsyg0E7MZuIRdvdCFfstdBr7CQoppfvhqqGkYnJ"

fun mainnetCoffeePoolConstantProduct(): CoffeePoolConstantProduct {
    return CoffeePoolConstantProduct.fromAddress(address(MAINNET_COFFEE_POOL_CONSTANT_PRODUCT_ADDRESS));
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

fun expectCesAsset(asset: CoffeePoolAsset): void {
    match (asset) {
        CoffeePoolNativeAsset => {
            Assert.fail("Expected CES Coffee pool asset");
        }
        CoffeePoolJettonAsset => {
            expect(asset.chain).toEqual(0);
            expect(asset.hash).toEqual(EXPECTED_CES_MINTER_HASH);
        }
        CoffeePoolExtraAsset => {
            Assert.fail("Expected CES Coffee pool asset");
        }
    }
}

fun expectNativeAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(2)).toEqual(0);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun expectCesAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(2)).toEqual(1);
    expect(asset.loadUint(8)).toEqual(0);
    expect(asset.loadUint(256)).toEqual(EXPECTED_CES_MINTER_HASH);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun loadCoffeePoolConstantProductStorageFromFork(pool: CoffeePoolConstantProduct): CoffeePoolConstantProductStorage {
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
            expect(code!.hash()).toEqual(build("CoffeePoolConstantProduct", FIXTURE_BOC_PATH).hash());
            return CoffeePoolConstantProductStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee constant-product Pool mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee constant-product Pool mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee constant product pool code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeePoolConstantProduct", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee constant product pool mainnet storage and getters`() {
    val pool = mainnetCoffeePoolConstantProduct();
    val storage = loadCoffeePoolConstantProductStorageFromFork(pool);
    val proof = storage.initData.load();
    val poolData = pool.getPoolData();
    val jettonData = pool.getJettonData();
    val walletAddress = pool.getWalletAddress(pool.address);
    val asset1Cell = poolData.asset1.toCell();
    val asset2Cell = poolData.asset2.toCell();
    val swapOut = pool.estimateSwapAmount(asset1Cell.beginParse(), 1000000);
    val withdrawOut = pool.estimateLiquidityWithdrawAmount(1000);
    val depositOut = pool.estimateLiquidityDepositAmount(1000000, 1000000);
    var getterAsset1 = asset1Cell.beginParse();
    var getterAsset2 = asset2Cell.beginParse();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(proof.factoryAddress).toEqual(address(EXPECTED_FACTORY_ADDRESS));
    match (proof.body) {
        CoffeePoolVaultProofBody => {
            Assert.fail("Expected Pool proof body in Coffee constant-product Pool storage");
        }
        CoffeePoolPoolProofBody => {
            expectNativeAsset(proof.body.asset1);
            expectCesAsset(proof.body.asset2);
            expect(proof.body.asset1.toCell().hash()).toEqual(asset1Cell.hash());
            expect(proof.body.asset2.toCell().hash()).toEqual(asset2Cell.hash());
            expect(proof.body.amm).toEqual(0);
            expect(proof.body.ammSettings).toBeNull();
        }
        CoffeePoolLiquidityDepositoryProofBody => {
            Assert.fail("Expected Pool proof body in Coffee constant-product Pool storage");
        }
        CoffeePoolCreatorProofBody => {
            Assert.fail("Expected Pool proof body in Coffee constant-product Pool storage");
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
    expect(poolData.amm).toEqual(0);
    expect(poolData.ammSettings).toBeNull();
    expect(poolData.active).toBeTrue();
    expect(poolData.reserve1).toBeGreater(0);
    expect(poolData.reserve2).toBeGreater(0);
    expect(poolData.totalSupply).toBeGreater(0);

    expectNativeAssetSlice(mutate getterAsset1);
    expectCesAssetSlice(mutate getterAsset2);

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

    println("COFFEE_POOL_CONSTANT_PRODUCT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_POOL_CONSTANT_PRODUCT_ADDRESS={}", pool.address);
    println("COFFEE_POOL_CONSTANT_PRODUCT_STORAGE={}", storage);
    println("COFFEE_POOL_CONSTANT_PRODUCT_PROOF={}", proof);
}
