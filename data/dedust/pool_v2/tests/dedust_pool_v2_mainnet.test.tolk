import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_pool_v2.types"
import "../wrappers/DedustPoolV2.gen"

const FIXTURE_BOC_PATH = "data/dedust/pool_v2/testdata/DedustPoolV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x1275095b6da3911292406f4f4386f9e780099b854c6dee9ee2895ddce70927c1
const EXPECTED_VERSION = 7
const PINNED_MAINNET_BLOCK = 71186170

const MAINNET_DEDUST_FACTORY_V2_ADDRESS = "EQBfBWT7X2BHg9tXAxzhz2aKiNTU1tpt5NsiK0uSDW_YAJ67"
const MAINNET_DEDUST_POOL_V2_VOLATILE_ADDRESS = "EQA-X_yo3fzzbDbJ_0bzFWKqtRuZFIRa1sJsveZJ1YpViO3r"
const MAINNET_DEDUST_POOL_V2_STABLE_ADDRESS = "EQABt8YegyD7VJnZdFVwom8wwqp0E0X8tN2Y6NhrDmbrnSXP"

fun mainnetDedustPoolV2Volatile(): DedustPoolV2 {
    return DedustPoolV2.fromAddress(address(MAINNET_DEDUST_POOL_V2_VOLATILE_ADDRESS));
}

fun mainnetDedustPoolV2Stable(): DedustPoolV2 {
    return DedustPoolV2.fromAddress(address(MAINNET_DEDUST_POOL_V2_STABLE_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun nativeAssetSlice(): slice {
    return beginCell().storeUint(0, 4).endCell().beginParse();
}

fun expectNativeAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(4)).toEqual(0);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun expectJettonAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(4)).toEqual(1);
    expect(asset.loadInt(8)).toEqual(0);
    expect(asset.loadUint(256)).toBeGreater(0);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadDedustPoolV2StorageFromFork(pool: DedustPoolV2): DedustPoolV2Storage {
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
            expect(code!.hash()).toEqual(build("DedustPoolV2", FIXTURE_BOC_PATH).hash());
            return DedustPoolV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Pool v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Pool v2 mainnet fixture account is frozen");
        }
    }
}

fun expectDedustPoolV2SafeGetters(
    pool: DedustPoolV2,
    expectedStable: bool,
    expectedTradeFeeNumerator: uint16,
): void {
    val storage = loadDedustPoolV2StorageFromFork(pool);
    val proof = storage.proof.load();
    val config = storage.config.load();
    val tradeFee = pool.getTradeFee();
    val reserves = pool.getReserves();
    val protocolFees = pool.getProtocolFees();
    val assets = pool.getAssets();
    val depositOut = pool.estimateDepositOut(1000000, 2000000);
    val swapOut = pool.estimateSwapOut(nativeAssetSlice(), 1000000000);
    val jettonData = pool.getJettonData();
    val lpWalletAddress = pool.getWalletAddress(pool.address);
    var asset0 = assets.asset0;
    var asset1 = assets.asset1;
    var estimatedAssetOut = swapOut.assetOut;

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(proof.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(storage.proofCode.hash()).toBeGreater(0);
    expect(storage.lpWalletCode.hash()).toBeGreater(0);
    expect(config.asset0Decimals).toBeGreaterOrEqual(0);
    expect(config.asset0Decimals).toBeLessOrEqual(18);
    expect(config.asset1Decimals).toBeGreaterOrEqual(0);
    expect(config.asset1Decimals).toBeLessOrEqual(18);
    expectInternalAddress(config.asset0VaultAddr);
    expectInternalAddress(config.asset1VaultAddr);

    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(storage.tradeFeeNumerator).toEqual(expectedTradeFeeNumerator);
    expect(storage.reserve0).toEqual(reserves.reserve0);
    expect(storage.reserve1).toEqual(reserves.reserve1);
    expect(storage.asset0ProtocolFee).toEqual(protocolFees.asset0ProtocolFee);
    expect(storage.asset1ProtocolFee).toEqual(protocolFees.asset1ProtocolFee);
    expect(storage.cumulativePrice0).toBeGreater(0);
    expect(storage.cumulativePrice1).toBeGreater(0);

    expect(pool.getVersion()).toEqual(EXPECTED_VERSION);
    expect(pool.isStable()).toEqual(expectedStable);

    expect(tradeFee.tradeFeeNumerator).toEqual(expectedTradeFeeNumerator);
    expect(tradeFee.tradeFeeDenominator).toEqual(10000);

    expect(reserves.reserve0).toBeGreater(0);
    expect(reserves.reserve1).toBeGreater(0);
    expect(protocolFees.asset0ProtocolFee).toBeGreaterOrEqual(0);
    expect(protocolFees.asset1ProtocolFee).toBeGreaterOrEqual(0);

    expectNativeAssetSlice(mutate asset0);
    expectJettonAssetSlice(mutate asset1);

    expect(depositOut.asset0Deposit).toBeGreater(0);
    expect(depositOut.asset1Deposit).toBeGreater(0);
    expect(depositOut.fairSupply).toBeGreater(0);

    expectJettonAssetSlice(mutate estimatedAssetOut);
    expect(swapOut.amountOut).toBeGreater(0);
    expect(swapOut.tradeFee).toBeGreaterOrEqual(0);

    expect(jettonData.totalSupply).toBeGreater(0);
    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toBeNoneAddress();
    expect(jettonData.jettonContent.hash()).toBeGreater(0);
    expect(jettonData.jettonWalletCode.hash()).toBeGreater(0);
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.lpWalletCode.hash());
    expectInternalAddress(lpWalletAddress);

    println("DEDUST_POOL_V2_STORAGE={}", storage);
}

get fun `test dedust pool v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("DedustPoolV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust pool v2 volatile mainnet code hash and safe getters`() {
    val pool = mainnetDedustPoolV2Volatile();
    expectDedustPoolV2SafeGetters(pool, false, 10);

    println("DEDUST_POOL_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_POOL_V2_VOLATILE_ADDRESS={}", pool.address);
}

get fun `test dedust pool v2 stable mainnet code hash and safe getters`() {
    val pool = mainnetDedustPoolV2Stable();
    expectDedustPoolV2SafeGetters(pool, true, 5);

    println("DEDUST_POOL_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_POOL_V2_STABLE_ADDRESS={}", pool.address);
}
