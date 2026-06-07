import "@stdlib/lisp-lists"
import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/nominator_pool.types"
import "../wrappers/NominatorPool.gen"

const FIXTURE_BOC_PATH = "data/nominator_pool/pool/testdata/NominatorPool.boc"
const DATA_FIXTURE_BOC_PATH = "data/nominator_pool/pool/testdata/NominatorPool.data.boc"
const LIVE_DATA_BOC = "te6ccgEBAwEAogACfQIAAXCEWfoCLjD2ClkGhNY6molTwhEzPSTR3kA0AoBIAbmVwhrm3Oj28qicyfCDcRRjDQkeQFqJU+3AACAAEAECAGIg2yiIUbcJT60ET05YOpIz0ILEWpjryMEoCg5JMx2Pdgu4AAFekQP9oAcBENkxbsAAAFOgBUjwiw1dV3TvHUUNOH88kwqHQcE1J7B4zYkaqOR6+9eOEHXYnZkHlBA="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9a3ec14bc098f6b44064c305222caea2800f17dda85ee6a8198a7095ede10dcf
const EXPECTED_DATA_HASH = 0xb5c02ed5f2c2c957b1b96cb5a2461075adc739df6efb29f75d56278734be3a31
const EXPECTED_VALIDATOR_HASH = 0x20db288851b7094fad044f4e583a9233d082c45a98ebc8c1280a0e49331d8f76

const MAINNET_NOMINATOR_POOL_ADDRESS = "Ef-Ob4ib3dI6SyugRcZHLwLEyhsTz0Uhi9RW-AszqL1xR4D4"
const MAINNET_NOMINATOR_POOL_RAW = "-1:8E6F889BDDD23A4B2BA045C6472F02C4CA1B13CF45218BD456F80B33A8BD7147"
const SNAPSHOT_LAST_TRANSACTION_LT = 82127309000003

struct LoadedNominatorPoolStorage {
    data: cell
    storage: NominatorPoolStorage
    config: NominatorPoolConfig
}

fun mainnetNominatorPool(): NominatorPool {
    return NominatorPool.fromAddress(address(MAINNET_NOMINATOR_POOL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedLiveDataCell(): cell {
    return parseCellFromBase64(LIVE_DATA_BOC);
}

fun savedDataFixtureCell(): cell {
    return build("NominatorPoolData", DATA_FIXTURE_BOC_PATH);
}

fun loadNominatorPoolStorageFromData(data: cell): LoadedNominatorPoolStorage {
    val storage = NominatorPoolStorage.fromCell(data);
    val config = storage.config.load();

    expect(storage.toCell().hash()).toEqual(data.hash());
    return LoadedNominatorPoolStorage { data, storage, config };
}

fun loadNominatorPoolStorageFromFork(pool: NominatorPool): LoadedNominatorPoolStorage {
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
            return loadNominatorPoolStorageFromData(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Nominator Pool representative mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Nominator Pool representative mainnet account is frozen");
        }
    }
}

fun nominatorPoolGetData(pool: NominatorPool): NominatorPoolDataReply {
    return pool.getPoolData();
}

fun nominatorPoolHasWithdrawRequests(pool: NominatorPool): bool {
    return pool.hasWithdrawRequests();
}

fun nominatorPoolListNominators(pool: NominatorPool): lisp_list<NominatorPoolListNominatorsEntry> {
    return pool.listNominators();
}

fun nominatorPoolListVotes(pool: NominatorPool): lisp_list<NominatorPoolListVotesEntry> {
    return pool.listVotes();
}

fun expectNominatorPoolStorageCore(loaded: LoadedNominatorPoolStorage): void {
    val storage = loaded.storage;
    val config = loaded.config;

    expect(config.validatorAddress).toEqual(EXPECTED_VALIDATOR_HASH);
    expect(config.validatorRewardShare).toBeGreaterOrEqual(0);
    expect(config.validatorRewardShare).toBeLessOrEqual(10000);
    expect(config.maxNominatorsCount).toBeGreater(0);
    expect(config.minValidatorStake).toBeGreater(0);
    expect(config.minNominatorStake).toBeGreater(0);
    expect(storage.nominators).toHaveLength(storage.nominatorsCount);
    expect(storage.nominatorsCount).toBeLessOrEqual(config.maxNominatorsCount);
    expect(storage.stakeAmountSent).toBeGreaterOrEqual(0);
    expect(storage.validatorAmount).toBeGreaterOrEqual(0);
    expect(storage.validatorSetChangesCount).toBeLessOrEqual(3);
}

fun expectNominatorPoolGettersMatchStorage(
    pool: NominatorPool,
    loaded: LoadedNominatorPoolStorage,
): void {
    val storage = loaded.storage;
    val config = loaded.config;
    val data = nominatorPoolGetData(pool);
    val hasWithdrawRequests = nominatorPoolHasWithdrawRequests(pool);
    val nominators = nominatorPoolListNominators(pool);
    val votes = nominatorPoolListVotes(pool);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expect(data.state).toEqual(storage.state);
    expect(data.nominatorsCount).toEqual(storage.nominatorsCount);
    expect(data.stakeAmountSent).toEqual(storage.stakeAmountSent);
    expect(data.validatorAmount).toEqual(storage.validatorAmount);
    expect(data.validatorAddress).toEqual(config.validatorAddress);
    expect(data.validatorRewardShare).toEqual(config.validatorRewardShare);
    expect(data.maxNominatorsCount).toEqual(config.maxNominatorsCount);
    expect(data.minValidatorStake).toEqual(config.minValidatorStake);
    expect(data.minNominatorStake).toEqual(config.minNominatorStake);
    expect(data.stakeAt).toEqual(storage.stakeAt);
    expect(data.savedValidatorSetHash).toEqual(storage.savedValidatorSetHash);
    expect(data.validatorSetChangesCount).toEqual(storage.validatorSetChangesCount);
    expect(data.validatorSetChangeTime).toEqual(storage.validatorSetChangeTime);
    expect(data.stakeHeldFor).toEqual(storage.stakeHeldFor);
    expect(hasWithdrawRequests).toEqual(!storage.withdrawRequests.isEmpty());
    expect(nominators.calculateSize()).toEqual(storage.nominatorsCount);
    expect(votes.calculateSize()).toBeGreaterOrEqual(0);
}

get fun `test nominator pool code and data bocs are real and hash verified`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val code = build("NominatorPool", FIXTURE_BOC_PATH);
    val data = savedDataFixtureCell();
    val liveData = savedLiveDataCell();
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(liveData.hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test nominator pool parses saved live storage fixture`() {
    val loaded = loadNominatorPoolStorageFromData(savedLiveDataCell());

    expectNominatorPoolStorageCore(loaded);

    println("NOMINATOR_POOL_SNAPSHOT_LAST_LT={}", SNAPSHOT_LAST_TRANSACTION_LT);
    println("NOMINATOR_POOL_RAW_ADDRESS={}", MAINNET_NOMINATOR_POOL_RAW);
    println("NOMINATOR_POOL_SAVED_STORAGE={}", loaded.storage);
    println("NOMINATOR_POOL_SAVED_CONFIG={}", loaded.config);
}

get fun `test nominator pool mainnet storage and getters`() {
    val pool = mainnetNominatorPool();
    val loaded = loadNominatorPoolStorageFromFork(pool);

    expectNominatorPoolStorageCore(loaded);
    expectNominatorPoolGettersMatchStorage(pool, loaded);

    println("NOMINATOR_POOL_ADDRESS={}", pool.address);
    println("NOMINATOR_POOL_STORAGE={}", loaded.storage);
    println("NOMINATOR_POOL_CONFIG={}", loaded.config);
}
