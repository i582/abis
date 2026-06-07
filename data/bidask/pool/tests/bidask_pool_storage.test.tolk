import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/bidask_pool.types"
import "../wrappers/BidaskPool.gen"

const FIXTURE_BOC_PATH = "data/bidask/pool/testdata/BidaskPool.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/pool/testdata/BidaskPool.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb1215034b293853339110766cdc83626a147787ec15d0c571cb53a8c8c2e7e12
const EXPECTED_DATA_HASH = 0xd47a1f11d60c253c0b8a12e8498be1b723e7c89437945405213b18685e26e70a

const MAINNET_BIDASK_POOL_ADDRESS = "EQDWP1o1Ov-3_URrkoz5XmJ3kUXS9uhAN9L9DKOe3Z_huoQh"
const DATA_FIXTURE_BOC = "te6ccgECCAEAAXgAAlsAASChQwb3SwAAAAAAAAAAAAAAAAAAAAAck6GZTByvFvTi30Pj6PtjGQAAAqEkAQIE+YAdatsTeuiOAQQeE0qNzusFYhpq8KYKhSwRkMUPKqGVyGAAoAAAAAAAAAAAAAAAIACgAKAAAAyAADADeGcsxrWwyUBisoRxTf9ZapiwQjlNB5F4ah1Fm4vUgYYAbF4iDTU6Gc2vq3mT74jjGWCMEXajzH48sIrqZ4k+vTxAAwQFBgFjAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAHCEICBSdYlaiO0SjKdSgKS1q2rlmfzLmbM2gGf8hghGhdrPsIQgLi2jTTG2IKMbJwIquwxf81vE2XtKQxDD+3g6HBKkRqgwhCAqMEPSg62gIQjerUUc+z28ckr5qZpUHT6Z9WAUMzExhZCEICOC0Axn751Dk8CWe9f0j5dvcF2GQVbjKPCgoIZxBpC4oAAA=="

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun bidaskPoolDataFixtureCell(): cell {
    return parseCellFromBase64(DATA_FIXTURE_BOC);
}

fun loadBidaskPoolStorageFixture(): BidaskPoolStorage {
    val data = bidaskPoolDataFixtureCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = BidaskPoolStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun expectBidaskPoolStorageShape(storage: BidaskPoolStorage): void {
    val staticData = storage.staticData.load();

    expect(storage.storageVersion).toEqual(1);
    expect(storage.tokenXAmount).toBeGreaterOrEqual(0);
    expect(storage.tokenYAmount).toBeGreaterOrEqual(0);
    expect(storage.collectedTokenXProtocolFee).toBeGreaterOrEqual(0);
    expect(storage.collectedTokenYProtocolFee).toBeGreaterOrEqual(0);
    expect(storage.sqrtPrice).toBeGreater(0);
    expect(storage.initStatus).toBeGreater(0);
    expect(storage.staticData.hash()).toBeGreater(0);
    expect(storage.tradeAccountAuxData.hash()).toBeGreater(0);

    expectInternalAddress(staticData.adminAddress);
    expectInternalAddress(staticData.jettonWalletX);
    expectInternalAddress(staticData.jettonWalletY);
    expect(staticData.lpFee).toBeGreater(0);
    expect(staticData.dynamicFeeFactor).toBeGreaterOrEqual(0);
    expect(staticData.timeFilter).toBeGreaterOrEqual(0);
    expect(staticData.timeDecay).toBeGreaterOrEqual(0);
    expect(staticData.protocolFeeReductionFactor).toBeGreaterOrEqual(0);
    expect(staticData.refFee).toBeGreaterOrEqual(0);
    expect(staticData.binStep).toBeGreater(0);
    expect(staticData.lpAccountCode.hash()).toBeGreater(0);
    expect(staticData.tradeAccountCode.hash()).toBeGreater(0);
    expect(staticData.childAccountCode.hash()).toBeGreater(0);
    expect(staticData.rangeCode.hash()).toBeGreater(0);
}

fun expectBidaskPoolGettersMatchStorage(pool: BidaskPool, storage: BidaskPoolStorage): void {
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

get fun `test bidask pool code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    var codeBytes = rawCodeBoc!;
    var dataBytes = rawDataBoc!;
    expectBocMagic(mutate codeBytes);
    expectBocMagic(mutate dataBytes);

    expect(build("BidaskPool", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("BidaskPool").hash()).toEqual(EXPECTED_CODE_HASH);
    expect(bidaskPoolDataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test bidask pool saved data fixture parses and derives local state address`() {
    val storage = loadBidaskPoolStorageFixture();
    val pool = BidaskPool.fromStorage(storage);

    expectBidaskPoolStorageShape(storage);
    expectInternalAddress(pool.address);
    expect(pool.address).toNotEqual(address(MAINNET_BIDASK_POOL_ADDRESS));

    println("BIDASK_POOL_STORAGE_FIXTURE={}", storage);
    println("BIDASK_POOL_STORAGE_STATIC={}", storage.staticData.load());
    println("BIDASK_POOL_STORAGE_ADDRESS={}", pool.address);
}

get fun `test bidask pool wrapper getters match saved local storage`() {
    val storage = loadBidaskPoolStorageFixture();
    val pool = BidaskPool.fromStorage(storage);
    val deployer = testing.treasury("bidask-pool-storage-deployer");

    pool.deploy(deployer.address, { value: ton("1"), bounce: false });
    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expectBidaskPoolGettersMatchStorage(pool, storage);

    println("BIDASK_POOL_LOCAL_GETTER_ADDRESS={}", pool.address);
}
