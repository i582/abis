import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/bidask_pool.types"
import "../wrappers/BidaskPool.gen"

const FIXTURE_BOC_PATH = "data/bidask/pool/testdata/BidaskPool.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb1215034b293853339110766cdc83626a147787ec15d0c571cb53a8c8c2e7e12
const PINNED_MAINNET_BLOCK = 65012329

const MAINNET_BIDASK_POOL_ADDRESS = "EQDWP1o1Ov-3_URrkoz5XmJ3kUXS9uhAN9L9DKOe3Z_huoQh"

fun mainnetBidaskPool(): BidaskPool {
    return BidaskPool.fromAddress(address(MAINNET_BIDASK_POOL_ADDRESS));
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadBidaskPoolStorageFromFork(pool: BidaskPool): BidaskPoolStorage {
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
            expect(code!.hash()).toEqual(build("BidaskPool", FIXTURE_BOC_PATH).hash());
            return BidaskPoolStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Bidask Pool mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Bidask Pool mainnet fixture account is frozen");
        }
    }
}

fun expectBidaskPoolForkGettersMatchStorage(pool: BidaskPool, storage: BidaskPoolStorage): void {
    val staticData = storage.staticData.load();
    val poolInfo = pool.getPoolInfo();
    val feesInfo = pool.getFeesInfo();
    val poolTokens = pool.getPoolTokens();
    val dynamicFeesInfo = pool.getDynamicFeesInfo();
    val tvl = pool.getTvl();
    val protocolFees = pool.getProtocolFees();
    val farmingInfo = pool.getFarmingInfo();
    val activeRange = pool.getActiveRange();
    val rangeForCurrentBin = pool.getRangeAddress(storage.currentBin);
    val lpAccountAddress = pool.getLpAccountAddress(pool.address);
    val tradeAccountAddress = pool.getTradeAccountAddress(pool.address, createEmptyCell());

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(pool.whoami()).toEqual("DLMM");
    expect(pool.getStorage().hash()).toEqual(storage.toCell().hash());
    expect(pool.getAdminAddress()).toEqual(staticData.adminAddress);
    expect(pool.getCurrentBin()).toEqual(storage.currentBin as int);
    expect(pool.getSqrtP()).toEqual(storage.sqrtPrice as int);
    expect(pool.getIsInited()).toEqual(storage.initStatus as int);

    expect(poolInfo.jettonWalletX).toEqual(staticData.jettonWalletX);
    expect(poolInfo.jettonWalletY).toEqual(staticData.jettonWalletY);
    expect(poolInfo.binStep).toEqual(staticData.binStep as int);
    expect(poolInfo.lpFee).toEqual(staticData.lpFee as int);

    expect(feesInfo.refFee).toEqual(staticData.refFee as int);
    expect(feesInfo.protocolFeeReductionFactor).toEqual(
        staticData.protocolFeeReductionFactor as int,
    );
    expect(poolTokens.jettonWalletX).toEqual(staticData.jettonWalletX);
    expect(poolTokens.jettonWalletY).toEqual(staticData.jettonWalletY);

    expect(dynamicFeesInfo.baseFee).toEqual(staticData.lpFee as int);
    expect(dynamicFeesInfo.dynamicFeeFactor).toEqual(staticData.dynamicFeeFactor as int);
    expect(dynamicFeesInfo.timeFilter).toEqual(staticData.timeFilter as int);
    expect(dynamicFeesInfo.timeDecay).toEqual(staticData.timeDecay as int);

    expect(tvl.tokenXAmount).toEqual(storage.tokenXAmount as int);
    expect(tvl.tokenYAmount).toEqual(storage.tokenYAmount as int);
    expect(protocolFees.collectedTokenXProtocolFee).toEqual(
        storage.collectedTokenXProtocolFee as int,
    );
    expect(protocolFees.collectedTokenYProtocolFee).toEqual(
        storage.collectedTokenYProtocolFee as int,
    );

    if (storage.farmingData == null) {
        expect(farmingInfo.distributedXAmount).toEqual(0);
        expect(farmingInfo.distributedYAmount).toEqual(0);
        expect(farmingInfo.farmingXPerSecond).toEqual(0);
        expect(farmingInfo.farmingYPerSecond).toEqual(0);
        expect(farmingInfo.previousCall).toEqual(0);
        expect(farmingInfo.endOfFarming).toEqual(0);
    } else {
        val farmingData = storage.farmingData!.load();
        expect(farmingInfo.distributedXAmount).toEqual(farmingData.distributedXAmount as int);
        expect(farmingInfo.distributedYAmount).toEqual(farmingData.distributedYAmount as int);
        expect(farmingInfo.farmingXPerSecond).toEqual(farmingData.farmingXPerSecond as int);
        expect(farmingInfo.farmingYPerSecond).toEqual(farmingData.farmingYPerSecond as int);
        expect(farmingInfo.previousCall).toEqual(farmingData.previousCall as int);
        expect(farmingInfo.endOfFarming).toEqual(farmingData.endOfFarming as int);
    }

    expectInternalAddress(activeRange);
    expect(activeRange).toEqual(rangeForCurrentBin);
    expectInternalAddress(lpAccountAddress);
    expectInternalAddress(tradeAccountAddress);
}

get fun `test bidask pool code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("BidaskPool", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test bidask pool mainnet getters match fork storage`() {
    val pool = mainnetBidaskPool();
    val storage = loadBidaskPoolStorageFromFork(pool);

    expectBidaskPoolForkGettersMatchStorage(pool, storage);

    println("BIDASK_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("BIDASK_POOL_MAINNET_ADDRESS={}", pool.address);
    println("BIDASK_POOL_MAINNET_STORAGE={}", storage);
}
