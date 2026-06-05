import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_damm_pool.types"
import "../wrappers/BidaskDammPool.gen"

const FIXTURE_BOC_PATH = "data/bidask/damm_pool/testdata/BidaskDammPool.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/damm_pool/testdata/BidaskDammPool.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x760f60fe228f87c709ec85690bf592904c20386f06cbe4c478faf9453eded124
const EXPECTED_DATA_HASH = 0x5aa804d49d88af2db5392c527016e164b437982da065703cf184e0b7b6c63585

const MAINNET_BIDASK_DAMM_POOL_ADDRESS = "EQDqTVF57qRXQwHnD5Zj-fM1Iy40V8v2DWrV3TQ1SRP3mGwi"
const EXPECTED_ADMIN_ADDRESS = "EQDrVtib10RwCCDwmlRud1grENNXhTBUKWCMhih5VQyuQ7Q6"
const EXPECTED_TOKEN_X_POOL_WALLET = "EQDkUsyBC-sGCKSh18RgCcJ6uWJ5PAG0Q9an7-RHxqAP3wse"
const EXPECTED_NATIVE_SENTINEL = "EQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM9c"

const SAVED_DATA_BOC_BASE64 = "te6ccgECBgEAAUkAAiUAACg8UQcAAAAGQAAAAAAAAAAEAQID+YAdatsTeuiOAQQeE0qNzusFYhpq8KYKhSwRkMUPKqGVyHADkUsyBC+sGCKSh18RgCcJ6uWJ5PAG0Q9an7+RHxqAP34AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAyAAKEAwQFAIkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARggPogIQgKq4VhMopO3HGubrLd3WBroqIyGJzgMF3pHz/fueF1CFAhCAiQz4Afr5XEg18SAnGwtds31toDrHDCcVra/jzVsNtE1CEICVsMESX8tp/0ikVdccjydVEaXWJUdPtXbCV9zsCdV6+w="

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDataCell(): cell {
    return parseCellFromBase64(SAVED_DATA_BOC_BASE64);
}

fun loadSavedBidaskDammPoolStorage(): BidaskDammPoolStorage {
    val data = savedDataCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return BidaskDammPoolStorage.fromCell(data);
}

fun compileBidaskDammPoolGetterSurface(pool: BidaskDammPool): void {
    val protocolFees = pool.getProtocolFees();
    val poolInfo = pool.getPoolInfo();
    val lpAccountAddress = pool.getLpAccountAddress(pool.address);
    val lpWalletAddress = pool.getWalletAddress(pool.address);
    val tradeAccountAddress = pool.getTradeAccountAddress(pool.address, createEmptyCell());
    val poolTokens = pool.getPoolTokens();
    val adminAddress = pool.getAdminAddress();
    val tvl = pool.getTvl();
    val liquidityInfo = pool.getLiquidityInfo();
    val dynamicFee = pool.getDynamicFeeByTimestamp(0);
    val status = pool.getStatus();
    val feesInfo = pool.getFeesInfo();
    val farmingInfo = pool.getFarmingInfo();
    val quote = pool.getExpectedSwapResult(1, 0, address(EXPECTED_TOKEN_X_POOL_WALLET), 0, 0);
    val collectedFees = pool.getCollectedFeesInfo();
    val rawStorage = pool.getStorage();
    val poolKind = pool.whoami();
    val jettonData = pool.getJettonData();
    val startTradeTime = pool.getStartTradeTime();
}

get fun `test bidask damm pool code and data fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("BidaskDammPool", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test bidask damm pool parses saved storage fixture`() {
    val storage = loadSavedBidaskDammPoolStorage();
    val config = storage.config.load();
    val accumulators = storage.accumulators.load();

    expect(storage.storagePrefix).toEqual(0);
    expect(storage.liquidityXAmount).toEqual(33733);
    expect(storage.liquidityYAmount).toEqual(7);
    expect(storage.accountedXAmount).toEqual(0);
    expect(storage.accountedYAmount).toEqual(0);
    expect(storage.protocolFeeX).toEqual(0);
    expect(storage.protocolFeeY).toEqual(0);
    expect(storage.unlockedLpSupply).toEqual(0);
    expect(storage.dynamicFee).toEqual(100);
    expect(storage.previousSwapTime).toEqual(0);
    expect(storage.farming).toBeNull();

    expect(config.adminAddress).toEqual(address(EXPECTED_ADMIN_ADDRESS));
    expect(config.tokenXPoolWallet).toEqual(address(EXPECTED_TOKEN_X_POOL_WALLET));
    expect(config.tokenYPoolWallet).toEqual(address(EXPECTED_NATIVE_SENTINEL));
    expect(config.startTradeTime).toEqual(0);
    expect(config.dynamicFeeFactor).toEqual(0);
    expect(config.timeFilter).toEqual(0);
    expect(config.timeDecay).toEqual(1);
    expect(config.baseFee).toEqual(100);
    expect(config.protocolFeeReductionFactor).toEqual(5);
    expect(config.statusFlags).toEqual(0);
    expect(config.lpAccountCode.hash()).toBeGreater(0);
    expect(config.lpWalletCode.hash()).toBeGreater(0);
    expect(config.tradeAccountCode.hash()).toBeGreater(0);

    expect(accumulators.feesPerLpX).toEqual(0);
    expect(accumulators.feesPerLpY).toEqual(0);
    expect(accumulators.virtualXAmount).toEqual(0);
    expect(accumulators.virtualYAmount).toEqual(24);
    expect(accumulators.lockedLpSupply).toEqual(1000);
    expect(storage.toCell().hash()).toEqual(EXPECTED_DATA_HASH);

    println("BIDASK_DAMM_POOL_SAVED_STORAGE={}", storage);
    println("BIDASK_DAMM_POOL_SAVED_CONFIG={}", config);
    println("BIDASK_DAMM_POOL_SAVED_ACCUMULATORS={}", accumulators);
}

get fun `test bidask damm pool wrapper and getter surface compiles`() {
    val pool = BidaskDammPool.fromAddress(address(MAINNET_BIDASK_DAMM_POOL_ADDRESS));

    expect(pool.address).toEqual(address(MAINNET_BIDASK_DAMM_POOL_ADDRESS));
}
