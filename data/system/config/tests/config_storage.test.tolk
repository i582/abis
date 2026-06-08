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
import "../types/config.types"
import "../wrappers/Config.gen"

const FIXTURE_BOC_PATH = "data/system/config/testdata/Config.boc"
const DATA_FIXTURE_BOC_PATH = "data/system/config/testdata/Config.data.boc"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xc4844c82c82277d65fba7dd320b390f16e89e9c106812e367b679bf0de1313e0
const EXPECTED_DATA_HASH = 0x77362a1cc4bf0f1c2eee2f15008247217dda7f2ced3bf78f7fa21afda777ba9f
const MIN_OBSERVED_LAST_TRANSACTION_LT = 82255380000003
const PINNED_MAINNET_BLOCK = 71907711

const MAINNET_CONFIG_ADDRESS = "Ef9VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVbxn"

struct LoadedConfigStorage {
    data: cell
    storage: ConfigStorage
    votingSetup: ConfigVotingSetup
    normalSetup: ConfigProposalSetup
    criticalSetup: ConfigProposalSetup
    currentValidatorSet: ConfigValidatorSetExt
}

fun mainnetConfig(): Config {
    return Config.fromAddress(address(MAINNET_CONFIG_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun dataFixtureCell(): cell {
    return build("ConfigData", DATA_FIXTURE_BOC_PATH);
}

fun loadConfigStorageFromData(data: cell): LoadedConfigStorage {
    val storage = ConfigStorage.fromCell(data);
    val votingSetup = ConfigVotingSetup.fromCell(storage.config.mustGet(11));
    val normalSetup = votingSetup.normalParams.load();
    val criticalSetup = votingSetup.criticalParams.load();
    val currentValidatorSet = ConfigValidatorSetExt.fromCell(storage.config.mustGet(34));

    expect(storage.toCell().hash()).toEqual(data.hash());
    return LoadedConfigStorage {
        data,
        storage,
        votingSetup,
        normalSetup,
        criticalSetup,
        currentValidatorSet,
    };
}

fun loadConfigStorageFromFork(config: Config): LoadedConfigStorage {
    val account = testing.getAccountState(config.address);
    expect(account).toBeNotNull();

    expect(account!.storage.lastTransLt).toBeGreaterOrEqual(MIN_OBSERVED_LAST_TRANSACTION_LT);

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("Config", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toBeGreater(0);
            return loadConfigStorageFromData(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Config mainnet system account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Config mainnet system account is frozen");
        }
    }
}

fun expectVotingSetupBounds(setup: ConfigProposalSetup): void {
    expect(setup.minTotalRounds).toBeGreater(0);
    expect(setup.maxTotalRounds).toBeGreaterOrEqual(setup.minTotalRounds);
    expect(setup.minWins).toBeGreater(0);
    expect(setup.maxLosses).toBeGreater(0);
    expect(setup.minStoreSec).toBeGreater(0);
    expect(setup.maxStoreSec).toBeGreaterOrEqual(setup.minStoreSec);
    expect(setup.bitPrice).toBeGreater(0);
    expect(setup.cellPrice).toBeGreater(0);
}

fun expectConfigStorageCore(loaded: LoadedConfigStorage): void {
    val storage = loaded.storage;
    val normalSetup = loaded.normalSetup;
    val criticalSetup = loaded.criticalSetup;
    val currentValidatorSet = loaded.currentValidatorSet;

    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.config.isEmpty()).toBeFalse();
    expect(storage.publicKey).toBeGreater(0);
    expect(storage.config.mustGet(11).hash()).toEqual(loaded.votingSetup.toCell().hash());
    expect(storage.config.mustGet(34).hash()).toEqual(currentValidatorSet.toCell().hash());

    expectVotingSetupBounds(normalSetup);
    expectVotingSetupBounds(criticalSetup);

    expect(currentValidatorSet.utimeSince).toBeGreater(0);
    expect(currentValidatorSet.utimeUntil).toBeGreater(currentValidatorSet.utimeSince);
    expect(currentValidatorSet.total).toBeGreater(0);
    expect(currentValidatorSet.main).toBeGreater(0);
    expect(currentValidatorSet.total).toBeGreaterOrEqual(currentValidatorSet.main);
    expect(currentValidatorSet.totalWeight).toBeGreater(0);
}

fun expectConfigGettersMatchStorage(config: Config, loaded: LoadedConfigStorage): void {
    val storage = loaded.storage;
    val normalSetup = loaded.normalSetup;
    val criticalSetup = loaded.criticalSetup;

    expect(scripts.isContractDeployed(config.address)).toBeTrue();
    expect(config.seqno()).toEqual(storage.storedSeqno);

    val proposals = config.listProposals();
    expect(proposals.isEmpty()).toEqual(storage.voteDict.isEmpty());
    expect(proposals.calculateSize()).toBeGreaterOrEqual(0);
    expect(config.getProposal(0)).toBeNull();

    val normalBelowMinPrice = config.proposalStoragePrice(
        0,
        (normalSetup.minStoreSec as int) - 1,
        0,
        0,
    );
    val normalBasePrice = config.proposalStoragePrice(0, normalSetup.minStoreSec as int, 0, 0);
    val normalPayloadPrice = config.proposalStoragePrice(0, normalSetup.minStoreSec as int, 256, 1);
    val normalMaxPrice = config.proposalStoragePrice(0, normalSetup.maxStoreSec as int, 0, 0);
    val criticalBasePrice = config.proposalStoragePrice(1, criticalSetup.minStoreSec as int, 0, 0);

    expect(normalBelowMinPrice).toEqual(-1);
    expect(normalBasePrice).toBeGreater(0);
    expect(normalPayloadPrice).toBeGreater(normalBasePrice);
    expect(normalMaxPrice).toBeGreaterOrEqual(normalBasePrice);
    expect(criticalBasePrice).toBeGreater(0);
}

get fun `test config code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("Config", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test config saved data fixture parses storage`() {
    val loaded = loadConfigStorageFromData(dataFixtureCell());
    expect(loaded.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expectConfigStorageCore(loaded);

    println("CONFIG_STORAGE_FIXTURE_DATA_HASH={}", loaded.data.hash());
    println("CONFIG_STORAGE_FIXTURE_SEQNO={}", loaded.storage.storedSeqno);
    println("CONFIG_STORAGE_FIXTURE_PUBLIC_KEY={}", loaded.storage.publicKey);
    println("CONFIG_STORAGE_FIXTURE_VOTE_DICT_EMPTY={}", loaded.storage.voteDict.isEmpty());
    println("CONFIG_STORAGE_FIXTURE_VOTING_SETUP_HASH={}", loaded.votingSetup.toCell().hash());
    println("CONFIG_STORAGE_FIXTURE_CURRENT_VALIDATORS={}", loaded.currentValidatorSet.total);
}

get fun `test config mainnet fork storage and getters`() {
    val config = mainnetConfig();
    val loaded = loadConfigStorageFromFork(config);

    expectConfigStorageCore(loaded);
    expectConfigGettersMatchStorage(config, loaded);

    println("CONFIG_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("CONFIG_MAINNET_ADDRESS={}", config.address);
    println("CONFIG_MAINNET_MIN_OBSERVED_LAST_TRANSACTION_LT={}", MIN_OBSERVED_LAST_TRANSACTION_LT);
    println("CONFIG_MAINNET_LIVE_DATA_HASH={}", loaded.data.hash());
    println("CONFIG_MAINNET_SEQNO={}", loaded.storage.storedSeqno);
    println("CONFIG_MAINNET_LIST_PROPOSALS_EMPTY={}", config.listProposals().isEmpty());
}
