import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/bidask_damm_pool.types"
import "../wrappers/BidaskDammPool.gen"

const D7CE_CODE_BOC_PATH = "data/bidask/damm_pool/testdata/BidaskDammPoolD7cecc.boc"
const D7CE_DATA_BOC_PATH = "data/bidask/damm_pool/testdata/BidaskDammPoolD7cecc.data.boc"
const D7CE_ADDRESS = "EQDs6EBg0IfDk1FmWqy4vBdvYDJIM4r2bk9P8TUpu1lGhoOY"
const D7CE_CODE_HASH = 0xd7ceccfcb49243dc7fddfa0037a195c73236b76d5581f8f5ece0fbee4d6d82b6
const D7CE_DATA_HASH = 0x93a83e6a2091ec7a1d12fd5f66e008144b89ad9dacf9f95be5974097be4fced1

fun loadD7ceStorage(pool: BidaskDammPool): BidaskDammPoolStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(D7CE_CODE_HASH);
            expect(code!.hash()).toEqual(build("BidaskDammPool", D7CE_CODE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(D7CE_DATA_HASH);

            val storage = BidaskDammPoolStorage.fromCell(data!);
            expect(storage.toCell().hash()).toEqual(data!.hash());
            return storage;
        }
        TlbAccountStateUninit => {
            Assert.fail("D7CE DAMM Pool is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("D7CE DAMM Pool is frozen at the pinned block");
        }
    }
}

get fun `test bidask damm d7ce code and data fixtures are exact`() {
    expect(build("BidaskDammPool", D7CE_CODE_BOC_PATH).hash()).toEqual(D7CE_CODE_HASH);
    expect(build("BidaskDammPool", D7CE_DATA_BOC_PATH).hash()).toEqual(D7CE_DATA_HASH);
}

get fun `test current bidask damm ABI decodes d7ce revision`() {
    val pool = BidaskDammPool.fromAddress(address(D7CE_ADDRESS));
    val storage = loadD7ceStorage(pool);
    val config = storage.config.load();
    val accumulators = storage.accumulators.load();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    val protocolFees = pool.getProtocolFees();
    expect(protocolFees.protocolFeeX).toEqual(storage.protocolFeeX);
    expect(protocolFees.protocolFeeY).toEqual(storage.protocolFeeY);

    val poolInfo = pool.getPoolInfo();
    expect(poolInfo.tokenXPoolWallet).toEqual(config.tokenXPoolWallet);
    expect(poolInfo.tokenYPoolWallet).toEqual(config.tokenYPoolWallet);
    expect(poolInfo.baseFee).toEqual(config.baseFee);

    val poolTokens = pool.getPoolTokens();
    expect(poolTokens.tokenXPoolWallet).toEqual(config.tokenXPoolWallet);
    expect(poolTokens.tokenYPoolWallet).toEqual(config.tokenYPoolWallet);
    expect(pool.getAdminAddress()).toEqual(config.adminAddress);
    expect(pool.getStatus()).toEqual(config.statusFlags);
    expect(pool.getStartTradeTime()).toEqual(config.startTradeTime);

    val tvl = pool.getTvl();
    expect(tvl.tokenXAmount).toEqual(storage.liquidityXAmount + storage.accountedXAmount);
    expect(tvl.tokenYAmount).toEqual(storage.liquidityYAmount + storage.accountedYAmount);

    val liquidityInfo = pool.getLiquidityInfo();
    expect(liquidityInfo.liquidityXAmount).toEqual(storage.liquidityXAmount);
    expect(liquidityInfo.liquidityYAmount).toEqual(storage.liquidityYAmount);
    expect(liquidityInfo.virtualXAmount).toEqual(accumulators.virtualXAmount);
    expect(liquidityInfo.virtualYAmount).toEqual(accumulators.virtualYAmount);
    expect(liquidityInfo.totalSupplyLp).toEqual(
        storage.unlockedLpSupply + accumulators.lockedLpSupply,
    );
    expect(liquidityInfo.lockedLp).toEqual(accumulators.lockedLpSupply);

    val feesInfo = pool.getFeesInfo();
    expect(feesInfo.dynamicFee).toEqual(storage.dynamicFee);
    expect(feesInfo.dynamicFeeFactor).toEqual(config.dynamicFeeFactor);
    expect(feesInfo.previousSwapTime).toEqual(storage.previousSwapTime);
    expect(feesInfo.timeFilter).toEqual(config.timeFilter);
    expect(feesInfo.timeDecay).toEqual(config.timeDecay);
    expect(feesInfo.protocolFeeReductionFactor).toEqual(config.protocolFeeReductionFactor);
    expect(pool.getDynamicFeeByTimestamp(1766246507)).toBeGreaterOrEqual(0);

    val farmingInfo = pool.getFarmingInfo();
    if (storage.farming == null) {
        expect(farmingInfo.farmingXPerSecond).toEqual(0);
        expect(farmingInfo.farmingYPerSecond).toEqual(0);
        expect(farmingInfo.previousCall).toEqual(0);
        expect(farmingInfo.endOfFarming).toEqual(0);
    } else {
        val farming = storage.farming.load();
        expect(farmingInfo.farmingXPerSecond).toEqual(farming.farmingXPerSecond);
        expect(farmingInfo.farmingYPerSecond).toEqual(farming.farmingYPerSecond);
        expect(farmingInfo.previousCall).toEqual(farming.previousCall);
        expect(farmingInfo.endOfFarming).toEqual(farming.endOfFarming);
    }

    val collectedFees = pool.getCollectedFeesInfo();
    expect(collectedFees.feesPerLpX).toEqual(accumulators.feesPerLpX);
    expect(collectedFees.feesPerLpY).toEqual(accumulators.feesPerLpY);
    expect(pool.getStorage().hash()).toEqual(storage.toCell().hash());
    expect(pool.whoami()).toEqual("DAMM");

    val jettonData = pool.getJettonData();
    expect(jettonData.totalSupply).toEqual(storage.unlockedLpSupply + accumulators.lockedLpSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toBeNoneAddress();
    expect(jettonData.jettonWalletCode.hash()).toEqual(config.lpWalletCode.hash());

    val lpAccountAddress = pool.getLpAccountAddress(pool.address);
    val lpWalletAddress = pool.getWalletAddress(pool.address);
    val tradeAccountAddress = pool.getTradeAccountAddress(pool.address, createEmptyCell());
    expect((lpAccountAddress as any_address).castToInternal()).toEqual(lpAccountAddress);
    expect((lpWalletAddress as any_address).castToInternal()).toEqual(lpWalletAddress);
    expect((tradeAccountAddress as any_address).castToInternal()).toEqual(tradeAccountAddress);
}
