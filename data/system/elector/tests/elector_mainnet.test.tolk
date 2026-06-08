import "@stdlib/lisp-lists"
import "@acton/build"
import "@acton/fmt"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/elector.types"
import "../wrappers/Elector.gen"

const FIXTURE_BOC_PATH = "data/system/elector/testdata/Elector.boc"
const EXPECTED_CODE_HASH = 0x6217f872c99fafcb870f2c11a362f59339be95095f70d00b9cff2f6dcd69d3dd
const PINNED_MAINNET_BLOCK = 71907711
const MAINNET_ELECTOR_ADDRESS = "Ef8zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0vF"

struct LoadedElectorStorage {
    data: cell
    storage: ElectorStorage
}

fun mainnetElector(): Elector {
    return Elector.fromAddress(address(MAINNET_ELECTOR_ADDRESS));
}

fun loadElectorStorageFromData(data: cell): LoadedElectorStorage {
    val storage = ElectorStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return LoadedElectorStorage { data, storage };
}

fun loadElectorStorageFromFork(elector: Elector): LoadedElectorStorage {
    val account = testing.getAccountState(elector.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("Elector", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toBeGreater(0);
            return loadElectorStorageFromData(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Elector mainnet system account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Elector mainnet system account is frozen");
        }
    }
}

fun expectCurrentElectionGetters(elector: Elector, storage: ElectorStorage): void {
    val activeElectionId = elector.activeElectionId();
    val participantList = elector.participantList();
    val extended = elector.participantListExtended();

    if (storage.currentElection == null) {
        expect(activeElectionId).toEqual(0);
        expect(participantList.calculateSize()).toEqual(0);
        expect(extended.participants.calculateSize()).toEqual(0);
        expect(extended.electionAt).toEqual(0);
    } else {
        val current = storage.currentElection!.load();
        expect(activeElectionId).toEqual(current.electionAt);
        expect(current.members.isEmpty()).toBeFalse();
        expect(participantList.calculateSize()).toBeGreater(0);
        expect(extended.electionAt).toEqual(current.electionAt);
        expect(extended.electionClose).toEqual(current.electionClose);
        expect(extended.minStake).toEqual(current.minStake);
        expect(extended.totalStake).toEqual(current.totalStake);
        expect(extended.failed).toEqual(current.failed);
        expect(extended.finished).toEqual(current.finished);
        expect(extended.participants.calculateSize()).toEqual(participantList.calculateSize());
    }
}

fun expectPastElectionGetters(elector: Elector, storage: ElectorStorage): void {
    val pastIds = elector.pastElectionIds();
    val pastShort = elector.pastElectionsList();
    val pastFull = elector.pastElections();

    expect(storage.pastElections.isEmpty()).toBeFalse();
    expect(pastIds.calculateSize()).toBeGreater(0);
    expect(pastShort.calculateSize()).toEqual(pastIds.calculateSize());
    expect(pastFull.calculateSize()).toEqual(pastIds.calculateSize());
}

fun expectComplaintGetters(elector: Elector): void {
    val emptyComplaints = elector.getPastComplaints(0);
    val emptyComplaint = elector.showComplaint(0, 0);
    val complaintList = elector.listComplaints(0);
    val price = elector.complaintStoragePrice(0, 0, 3600);

    expect(emptyComplaints).toBeNull();
    expect(emptyComplaint).toBeNull();
    expect(complaintList.calculateSize()).toEqual(0);
    expect(price).toBeGreater(0);
}

get fun `test elector mainnet fork storage and getters`() {
    val elector = mainnetElector();
    val loaded = loadElectorStorageFromFork(elector);
    val storage = loaded.storage;

    expect(scripts.isContractDeployed(elector.address)).toBeTrue();
    expect(storage.pastElections.isEmpty()).toBeFalse();
    expect(storage.activeHash).toBeGreater(0);
    expect(elector.computeReturnedStake(0)).toBeGreaterOrEqual(0);
    expect(elector.participatesIn(0)).toBeGreaterOrEqual(0);

    expectCurrentElectionGetters(elector, storage);
    expectPastElectionGetters(elector, storage);
    expectComplaintGetters(elector);

    println("ELECTOR_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("ELECTOR_MAINNET_ADDRESS={}", elector.address);
    println("ELECTOR_MAINNET_LIVE_DATA_HASH={}", loaded.data.hash());
    println("ELECTOR_MAINNET_ACTIVE_ID={}", storage.activeId);
}
