import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/bidask_damm_pool.types"
import "../wrappers/BidaskDammPool.gen"

const FIXTURE_BOC_PATH = "data/bidask/damm_pool/testdata/BidaskDammPool.boc"
const EXPECTED_CODE_HASH = 0x760f60fe228f87c709ec85690bf592904c20386f06cbe4c478faf9453eded124
const PINNED_MAINNET_BLOCK = 57889573

const MAINNET_BIDASK_DAMM_POOL_ADDRESS = "EQDqTVF57qRXQwHnD5Zj-fM1Iy40V8v2DWrV3TQ1SRP3mGwi"

fun mainnetBidaskDammPool(): BidaskDammPool {
    return BidaskDammPool.fromAddress(address(MAINNET_BIDASK_DAMM_POOL_ADDRESS));
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadBidaskDammPoolStorageFromFork(pool: BidaskDammPool): BidaskDammPoolStorage {
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
            expect(code!.hash()).toEqual(build("BidaskDammPool", FIXTURE_BOC_PATH).hash());
            return BidaskDammPoolStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Bidask DAMM Pool mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Bidask DAMM Pool mainnet fixture account is frozen");
        }
    }
}

get fun `test bidask damm pool mainnet storage and safe getters`() {
    val pool = mainnetBidaskDammPool();
    val storage = loadBidaskDammPoolStorageFromFork(pool);
    val config = storage.config.load();
    val accumulators = storage.accumulators.load();
    val protocolFees = pool.getProtocolFees();
    val poolInfo = pool.getPoolInfo();
    val poolTokens = pool.getPoolTokens();
    val tvl = pool.getTvl();
    val liquidityInfo = pool.getLiquidityInfo();
    val feesInfo = pool.getFeesInfo();
    val farmingInfo = pool.getFarmingInfo();
    val collectedFees = pool.getCollectedFeesInfo();
    val storageCell = pool.getStorage();
    val jettonData = pool.getJettonData();
    val ownerAddress = pool.address;
    val lpAccountAddress = pool.getLpAccountAddress(ownerAddress);
    val lpWalletAddress = pool.getWalletAddress(ownerAddress);
    val tradeAccountAddress = pool.getTradeAccountAddress(ownerAddress, createEmptyCell());

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(protocolFees.protocolFeeX).toEqual(storage.protocolFeeX);
    expect(protocolFees.protocolFeeY).toEqual(storage.protocolFeeY);
    expect(poolInfo.tokenXPoolWallet).toEqual(config.tokenXPoolWallet);
    expect(poolInfo.tokenYPoolWallet).toEqual(config.tokenYPoolWallet);
    expect(poolInfo.baseFee).toEqual(config.baseFee);
    expect(poolTokens.tokenXPoolWallet).toEqual(config.tokenXPoolWallet);
    expect(poolTokens.tokenYPoolWallet).toEqual(config.tokenYPoolWallet);
    expect(pool.getAdminAddress()).toEqual(config.adminAddress);
    expect(pool.getStatus()).toEqual(config.statusFlags);
    expect(pool.getStartTradeTime()).toEqual(config.startTradeTime);

    expect(tvl.tokenXAmount).toEqual(storage.liquidityXAmount + storage.accountedXAmount);
    expect(tvl.tokenYAmount).toEqual(storage.liquidityYAmount + storage.accountedYAmount);
    expect(liquidityInfo.liquidityXAmount).toEqual(storage.liquidityXAmount);
    expect(liquidityInfo.liquidityYAmount).toEqual(storage.liquidityYAmount);
    expect(liquidityInfo.virtualXAmount).toEqual(accumulators.virtualXAmount);
    expect(liquidityInfo.virtualYAmount).toEqual(accumulators.virtualYAmount);
    expect(liquidityInfo.totalSupplyLp).toEqual(
        storage.unlockedLpSupply + accumulators.lockedLpSupply,
    );
    expect(liquidityInfo.lockedLp).toEqual(accumulators.lockedLpSupply);

    expect(feesInfo.dynamicFee).toEqual(storage.dynamicFee);
    expect(feesInfo.dynamicFeeFactor).toEqual(config.dynamicFeeFactor);
    expect(feesInfo.previousSwapTime).toEqual(storage.previousSwapTime);
    expect(feesInfo.timeFilter).toEqual(config.timeFilter);
    expect(feesInfo.timeDecay).toEqual(config.timeDecay);
    expect(feesInfo.protocolFeeReductionFactor).toEqual(config.protocolFeeReductionFactor);
    expect(pool.getDynamicFeeByTimestamp(PINNED_MAINNET_BLOCK)).toBeGreaterOrEqual(0);

    if (storage.farming == null) {
        expect(farmingInfo.farmingXPerSecond).toEqual(0);
        expect(farmingInfo.farmingYPerSecond).toEqual(0);
        expect(farmingInfo.previousCall).toEqual(0);
        expect(farmingInfo.endOfFarming).toEqual(0);
    } else {
        val farming = storage.farming!.load();
        expect(farmingInfo.farmingXPerSecond).toEqual(farming.farmingXPerSecond);
        expect(farmingInfo.farmingYPerSecond).toEqual(farming.farmingYPerSecond);
        expect(farmingInfo.previousCall).toEqual(farming.previousCall);
        expect(farmingInfo.endOfFarming).toEqual(farming.endOfFarming);
    }

    expect(collectedFees.feesPerLpX).toEqual(accumulators.feesPerLpX);
    expect(collectedFees.feesPerLpY).toEqual(accumulators.feesPerLpY);
    expect(storageCell.hash()).toEqual(storage.toCell().hash());
    expect(pool.whoami()).toEqual("DAMM");

    expect(jettonData.totalSupply).toEqual(storage.unlockedLpSupply + accumulators.lockedLpSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toBeNoneAddress();
    expect(jettonData.jettonContent.hash()).toBeGreater(0);
    expect(jettonData.jettonWalletCode.hash()).toEqual(config.lpWalletCode.hash());

    expectInternalAddress(lpAccountAddress);
    expectInternalAddress(lpWalletAddress);
    expectInternalAddress(tradeAccountAddress);

    println("BIDASK_DAMM_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("BIDASK_DAMM_POOL_ADDRESS={}", pool.address);
    println("BIDASK_DAMM_POOL_STORAGE={}", storage);
    println("BIDASK_DAMM_POOL_POOL_INFO={}", poolInfo);
    println("BIDASK_DAMM_POOL_JETTON_DATA={}", jettonData);
    println("BIDASK_DAMM_POOL_LP_ACCOUNT={}", lpAccountAddress);
    println("BIDASK_DAMM_POOL_LP_WALLET={}", lpWalletAddress);
    println("BIDASK_DAMM_POOL_TRADE_ACCOUNT={}", tradeAccountAddress);
}
