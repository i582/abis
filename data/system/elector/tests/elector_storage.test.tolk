import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/elector.types"

const FIXTURE_BOC_PATH = "data/system/elector/testdata/Elector.boc"
const DATA_FIXTURE_BOC_PATH = "data/system/elector/testdata/Elector.data.boc"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x6217f872c99fafcb870f2c11a362f59339be95095f70d00b9cff2f6dcd69d3dd
const EXPECTED_DATA_HASH = 0x5dad4efaec08b04e55aa556fb847a1369ef8014f1ef44a8a6efa4ae79e25ea72
const EXPECTED_ACTIVE_VALIDATOR_SET_ID = 1780829960
const EXPECTED_ACTIVE_VALIDATOR_SET_HASH = 0x44ccf493477900d00a012006e657086b9b73a3dbcaa27327c20dc4518c342479
const EXPECTED_STORAGE_GRAMS = 191712586
const EXPECTED_CURRENT_ELECTION_ID = 1780895496
const EXPECTED_CURRENT_ELECTION_CLOSE = 1780887304
const EXPECTED_CURRENT_MIN_STAKE = 300000000000000
const EXPECTED_CURRENT_TOTAL_STAKE = 569703725278816595
const EXPECTED_REAL_STAKE_VALIDATOR_PUBKEY = 0x4e37d594cf7d002f7cf0be46f55e64c971ff8139f4a93ed807fb4ac64b2c2e05
const EXPECTED_REAL_STAKE_SOURCE_ADDRESS = 0x98160c62cf5cbcf6e900540cb237daf0ab19481036e04661b5f8375b59d61be3
const EXPECTED_REAL_STAKE_ADNL_ADDRESS = 0x96c7dc17eb2f7e3152f8900af374b45794b2bfa55ad6defaf453117d63a260e2
const EXPECTED_REAL_STAKE_VALUE = 2497824596720407
const EXPECTED_REAL_STAKE_TIMESTAMP = 1780872657
const EXPECTED_REAL_STAKE_MAX_FACTOR = 294912

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun dataFixtureCell(): cell {
    return build("ElectorData", DATA_FIXTURE_BOC_PATH);
}

fun expectSavedElectorStorage(storage: ElectorStorage): void {
    expect(storage.activeId).toEqual(EXPECTED_ACTIVE_VALIDATOR_SET_ID);
    expect(storage.activeHash).toEqual(EXPECTED_ACTIVE_VALIDATOR_SET_HASH);
    expect(storage.grams).toEqual(EXPECTED_STORAGE_GRAMS);
    expect(storage.pastElections.isEmpty()).toBeFalse();
    expect(storage.currentElection).toBeNotNull();

    val current = storage.currentElection!.load();
    expect(current.electionAt).toEqual(EXPECTED_CURRENT_ELECTION_ID);
    expect(current.electionClose).toEqual(EXPECTED_CURRENT_ELECTION_CLOSE);
    expect(current.electionClose).toBeLessOrEqual(current.electionAt);
    expect(current.minStake).toEqual(EXPECTED_CURRENT_MIN_STAKE);
    expect(current.totalStake).toEqual(EXPECTED_CURRENT_TOTAL_STAKE);
    expect(current.failed).toEqual(0);
    expect(current.finished).toEqual(0);
    expect(current.members.isEmpty()).toBeFalse();

    val realStakeMember = current.members.mustGet(EXPECTED_REAL_STAKE_VALIDATOR_PUBKEY);
    expect(realStakeMember.stake).toEqual(EXPECTED_REAL_STAKE_VALUE);
    expect(realStakeMember.timestamp).toEqual(EXPECTED_REAL_STAKE_TIMESTAMP);
    expect(realStakeMember.maxFactor).toEqual(EXPECTED_REAL_STAKE_MAX_FACTOR);
    expect(realStakeMember.sourceAddress).toEqual(EXPECTED_REAL_STAKE_SOURCE_ADDRESS);
    expect(realStakeMember.adnlAddress).toEqual(EXPECTED_REAL_STAKE_ADNL_ADDRESS);
}

get fun `test elector code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("Elector", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test elector saved data fixture parses storage`() {
    val data = dataFixtureCell();
    val storage = ElectorStorage.fromCell(data);

    expect(storage.toCell().hash()).toEqual(data.hash());
    expectSavedElectorStorage(storage);

    println("ELECTOR_STORAGE_FIXTURE={}", storage);
}
