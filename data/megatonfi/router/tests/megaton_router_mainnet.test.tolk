import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/megaton_router.types"
import "../wrappers/MegatonRouter.gen"

const MAINNET_ROUTER_ADDRESS = "EQAWcJ0nO3WtNlSmUjKcqv4735YCviRqu7LMNJoPXsdHVLC9"
const EXPECTED_CODE_HASH = 0xcb97a903780dc5e37eab03de61f2dfce18f91db05c4ada8dd3f73f0c0fb3d862
const EXPECTED_DATA_HASH = 0x6a242a06b0fc7b9d2963cb38fa38494916a6a88eab9dca31d9e1d416308ef690
const ROUTER_CODE_PATH = "data/megatonfi/router/testdata/MegatonRouter.boc"
const ROUTER_DATA_PATH = "data/megatonfi/router/testdata/MegatonRouter.data.boc"

fun mainnetMegatonRouter(): MegatonRouter {
    return MegatonRouter.fromAddress(address(MAINNET_ROUTER_ADDRESS));
}

fun loadMegatonRouterStorageFromFork(router: MegatonRouter): MegatonRouterStorage {
    val account = testing.getAccountState(router.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MegatonRouter", ROUTER_CODE_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(build("MegatonRouterData", ROUTER_DATA_PATH).hash());
            return MegatonRouterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Megaton Router mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Megaton Router mainnet fixture account is frozen");
        }
    }
}

get fun `test megaton router pinned mainnet storage and getters`() {
    val router = mainnetMegatonRouter();
    expect(scripts.isContractDeployed(router.address)).toBeTrue();

    val storage = loadMegatonRouterStorageFromFork(router);
    val mining = storage.mining.load();
    val miningData = router.getMiningData();
    val lpData = router.getLpData();

    expect(miningData.totalMiningAmount).toEqual(mining.totalMiningAmount);
    expect(miningData.totalMiningRate).toEqual(1000000);
    expect(miningData.miningAmountPerSecond).toEqual(mining.miningAmountPerSecond);
    expect(miningData.miningStartTime).toEqual(mining.miningStartTime);
    expect(miningData.miningHalfLife).toEqual(mining.miningHalfLife);
    expect(miningData.distributedRewardAmount).toEqual(mining.distributedRewardAmount);
    expect(lpData.poolCount).toEqual(mining.poolCount);

    val pools = storage.pools.load();
    expect(lpData.pairHashToPool.hash()).toEqual(pools.pairHashToPool.toLowLevelDict()!.hash());
    expect(lpData.poolHashToPair.hash()).toEqual(pools.poolHashToPair.toLowLevelDict()!.hash());
}
