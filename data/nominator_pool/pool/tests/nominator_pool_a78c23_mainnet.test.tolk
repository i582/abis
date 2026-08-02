import "@stdlib/lisp-lists"
import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/nominator_pool.types"
import "../wrappers/NominatorPool.gen"

const FIXTURE_BOC_PATH = "data/nominator_pool/pool/testdata/NominatorPool_a78c23db.boc"
const EXPECTED_CODE_HASH = 0xa78c23dbc9f5093339d17e28afbe97e28a963411a20286856c9f76ae1ef6f130
const EXPECTED_DATA_HASH = 0x33783c63bf7409774bf3be91309d0729ac7a4ef0c205e47f04624dd0bbe8b082
const PINNED_MAINNET_BLOCK = 83587997
const MAINNET_POOL_ADDRESS = "Ef9_YdqILIo-z4aUI0HTgM2Mu9ZcYxyKhvUKVzPEc-71ZN04"

get fun `test nominator pool a78c23 code fixture is exact`() {
    val fixtureCode = build("NominatorPool", FIXTURE_BOC_PATH);
    expect(fixtureCode.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test nominator pool a78c23 storage and getters match current abi`() {
    val pool = NominatorPool.fromAddress(address(MAINNET_POOL_ADDRESS));
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
            expect(code!.hash()).toEqual(build("NominatorPool", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);

            val storage = NominatorPoolStorage.fromCell(data!);
            val config = storage.config.load();
            val poolData = pool.getPoolData();
            val hasWithdrawRequests = pool.hasWithdrawRequests();
            val nominators = pool.listNominators();
            val votes = pool.listVotes();
            val maxPunishment = pool.getMaxPunishment(1000000000000);

            expect(scripts.isContractDeployed(pool.address)).toBeTrue();
            expect(storage.toCell().hash()).toEqual(data!.hash());
            expect(poolData.state).toEqual(storage.state);
            expect(poolData.nominatorsCount).toEqual(storage.nominatorsCount);
            expect(poolData.stakeAmountSent).toEqual(storage.stakeAmountSent);
            expect(poolData.validatorAmount).toEqual(storage.validatorAmount);
            expect(poolData.validatorAddress).toEqual(config.validatorAddress);
            expect(poolData.validatorRewardShare).toEqual(config.validatorRewardShare);
            expect(poolData.maxNominatorsCount).toEqual(config.maxNominatorsCount);
            expect(poolData.minValidatorStake).toEqual(config.minValidatorStake);
            expect(poolData.minNominatorStake).toEqual(config.minNominatorStake);
            expect(poolData.stakeAt).toEqual(storage.stakeAt);
            expect(poolData.savedValidatorSetHash).toEqual(storage.savedValidatorSetHash);
            expect(poolData.validatorSetChangesCount).toEqual(storage.validatorSetChangesCount);
            expect(poolData.validatorSetChangeTime).toEqual(storage.validatorSetChangeTime);
            expect(poolData.stakeHeldFor).toEqual(storage.stakeHeldFor);
            expect(poolData.nominators.isEmpty()).toEqual(storage.nominators.isEmpty());
            expect(poolData.withdrawRequests.isEmpty()).toEqual(storage.withdrawRequests.isEmpty());
            expect(poolData.configProposalVotings.isEmpty()).toEqual(
                storage.configProposalVotings.isEmpty(),
            );
            expect(hasWithdrawRequests).toEqual(!storage.withdrawRequests.isEmpty());
            expect(nominators.calculateSize()).toEqual(storage.nominatorsCount);
            expect(votes.calculateSize()).toEqual(0);
            expect(maxPunishment).toEqual(101000000000);

            println("NOMINATOR_POOL_A78C23_PINNED_BLOCK={}", PINNED_MAINNET_BLOCK);
            println("NOMINATOR_POOL_A78C23_STORAGE={}", storage);
            println("NOMINATOR_POOL_A78C23_CONFIG={}", config);
        }
        TlbAccountStateUninit => {
            Assert.fail("Nominator Pool a78c23 account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Nominator Pool a78c23 account is frozen");
        }
    }
}
