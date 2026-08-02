import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tgusd_liquid_staking.types"
import "../wrappers/TgUsdLiquidStaking.gen"

const STAKING_ADDRESS = "EQDsRxOvYyhOAi-zHBSN2NkHcjwFB1aaMSnqJG7Chm14x02P"
const SELF_UNSTAKE_ACCOUNT = "EQBw4jef0do1FPP5e08usM5CpQn7YgtQr0VQAJBPaBX8W_IV"
const FIXTURE_BOC_PATH = "data/tgusd/testdata/TgUsdLiquidStaking.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5012a44c584f85ce0af2b6032b9308743db065a5a407ec8d2ad855dd24ac55ff
const EXPECTED_TOTAL_ACTIVE_STAKE = 890023340462
const EXPECTED_TOTAL_SHARES = 869946192801
const PINNED_MAINNET_BLOCK = 49133473

fun staking(): TgUsdLiquidStaking {
    return TgUsdLiquidStaking.fromAddress(address(STAKING_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStakingStorage(contract: TgUsdLiquidStaking): TgUsdLiquidStakingStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TgUsdLiquidStaking", FIXTURE_BOC_PATH).hash());
            return TgUsdLiquidStakingStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("tgUSD liquid staking is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("tgUSD liquid staking is frozen at the pinned block");
        }
    }
}

get fun `test tgUSD liquid staking code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("TgUsdLiquidStaking", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tgUSD liquid staking parses pinned storage and getters`() {
    val contract = staking();
    val storage = loadStakingStorage(contract);
    val stakeInfo = storage.stakeInfo.load();
    val ratio = contract.conversionRatio();
    val unstakeAccount = contract.unstakeAccount(address(STAKING_ADDRESS) as any_address);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(ratio.totalActiveStake).toEqual(EXPECTED_TOTAL_ACTIVE_STAKE);
    expect(ratio.totalShares).toEqual(EXPECTED_TOTAL_SHARES);
    expect(ratio.totalShares).toEqual(stakeInfo.totalShares);
    expect(ratio.totalActiveStake <= stakeInfo.totalStaked).toBeTrue();
    expect(storage.admin).toBeNotNull();
    expect(storage.stakedManager).toBeNotNull();
    expect(unstakeAccount.castToInternal()).toEqual(address(SELF_UNSTAKE_ACCOUNT));

    println("TGUSD_LIQUID_STAKING_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println(
        "TGUSD_TOTAL_ACTIVE_STAKE={} TOTAL_SHARES={} TOTAL_STAKED={}",
        ratio.totalActiveStake,
        ratio.totalShares,
        stakeInfo.totalStaked,
    );
}
