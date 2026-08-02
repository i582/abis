import "@acton/build"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/frt_gram_coordinator.types"
import "../types/frt_gram_dispatcher.types"
import "../types/frt_gram_executor.types"
import "../types/frt_gram_orchestrator.types"
import "../types/frt_gram_worker.types"
import "../wrappers/FrtGramAdapterCoordinator.gen"
import "../wrappers/FrtGramAdapterDispatcher.gen"
import "../wrappers/FrtGramAdapterExecutor.gen"
import "../wrappers/FrtGramAdapterOrchestrator.gen"
import "../wrappers/FrtGramAdapterWorker.gen"

const COORDINATOR_ADDRESS = "EQAOYIpqiuS0blDySfqSPKHhYoJRRV8RxUHGQUw_hw8WUQth"
const DISPATCHER_ADDRESS = "EQBazGjn2UgiOom47yy_fGdRoxU1tWNBNqWnkil5T9fP-xuK"
const ORCHESTRATOR_ADDRESS = "EQD9m4NA8WNC5UCq8aprfptsdi6mkGblH59W8Id8Dlo6AXXp"
const WORKER_ADDRESS = "EQBAwM79vmhxxLpSqrTdznRYTcyP2bJEa-s97wxx4jeO8HwK"
const EXECUTOR_ADDRESS = "EQAG_1ccmTW0aBW97sKa0xEqMJuY-INSAG9JQPYsVW473RLf"

const COORDINATOR_CODE_HASH = 0xdec2e3a6bfbb5839a0207d76bb91ba27e1e8bd5215848ce3555f7532c4408245
const DISPATCHER_CODE_HASH = 0xe343e4dc1a3b1c6fcbf4dcc0c5c15a61a7d86fa11f647cfed568f5a2693a3aa6
const ORCHESTRATOR_CODE_HASH = 0x492a2a4afcf063f5e83ee09fee03dc569e298d79465095ba357dc78d70d74116
const WORKER_CODE_HASH = 0x9932b5fd61bb9ed0533ad3787f956b6783163920f7071ebfe1581aa1feb1f8c9
const EXECUTOR_CODE_HASH = 0x249c127b9790738bbb4d8da018bd2c03b8d5f85d04d4b038cb5594bc5c73b969

fun loadActiveData(contractAddress: address, expectedCodeHash: int): cell {
    val account = testing.getAccountState(contractAddress);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(expectedCodeHash);
            return data!;
        }
        TlbAccountStateUninit => {
            Assert.fail("FRT/GRAM adapter account is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("FRT/GRAM adapter account is frozen at the pinned block");
        }
    }
}

get fun `test frt gram coordinator pinned storage and getter`() {
    val contract = FrtGramAdapterCoordinator.fromAddress(address(COORDINATOR_ADDRESS));
    val data = loadActiveData(contract.address, COORDINATOR_CODE_HASH);
    val storage = FrtGramAdapterCoordinatorStorage.fromCell(data);
    val (primaryAddress, secondaryAddress, storedAmount) = contract.info();

    expect(build("FrtGramAdapterCoordinator").hash()).toEqual(COORDINATOR_CODE_HASH);
    expect(primaryAddress).toEqual(storage.primaryAddress);
    expect(secondaryAddress).toEqual(storage.secondaryAddress);
    expect(storedAmount).toEqual(storage.balance);
    expect(contract.destination()).toEqual(storage.callbackAddress);
    expect(contract.getMethod90728Elpq()).toEqual(storage.enabled);
}

get fun `test frt gram dispatcher pinned storage and getter`() {
    val contract = FrtGramAdapterDispatcher.fromAddress(address(DISPATCHER_ADDRESS));
    val data = loadActiveData(contract.address, DISPATCHER_CODE_HASH);
    val storage = FrtGramAdapterDispatcherStorage.fromCell(data);

    expect(build("FrtGramAdapterDispatcher").hash()).toEqual(DISPATCHER_CODE_HASH);
    expect(contract.owner()).toEqual(storage.ownerAddress);
    expect(contract.storageReserve()).toEqual(50000000);
}

get fun `test frt gram orchestrator pinned storage and getter`() {
    val contract = FrtGramAdapterOrchestrator.fromAddress(address(ORCHESTRATOR_ADDRESS));
    val data = loadActiveData(contract.address, ORCHESTRATOR_CODE_HASH);
    val storage = FrtGramAdapterOrchestratorStorage.fromCell(data);
    val (ownerAddress, primaryAmount, parameter0) = contract.info();

    expect(build("FrtGramAdapterOrchestrator").hash()).toEqual(ORCHESTRATOR_CODE_HASH);
    expect(ownerAddress).toEqual(storage.ownerAddress);
    expect(primaryAmount).toEqual(storage.primaryAmount);
    expect(parameter0).toEqual(storage.parameter0);
    expect(contract.startTime()).toEqual(storage.stateValue1);
    expect(contract.getMethod112100Ayxm()).toEqual(storage.enabled);
}

get fun `test frt gram worker pinned storage and getter`() {
    val contract = FrtGramAdapterWorker.fromAddress(address(WORKER_ADDRESS));
    val data = loadActiveData(contract.address, WORKER_CODE_HASH);
    val storage = FrtGramAdapterWorkerStorage.fromCell(data);
    val (selector0, selector1, primaryAddress, secondaryAddress) = contract.info();

    expect(build("FrtGramAdapterWorker").hash()).toEqual(WORKER_CODE_HASH);
    expect(selector0).toEqual(storage.selector0);
    expect(selector1).toEqual(storage.selector1);
    expect(primaryAddress).toEqual(storage.primaryAddress);
    expect(secondaryAddress).toEqual(storage.secondaryAddress);
    expect(contract.getMethod67522Ffrz()).toEqual(storage.stateValue);
    expect(contract.getMethod83655Chdd()).toEqual(storage.limit);
}

get fun `test frt gram executor pinned storage and getter`() {
    val contract = FrtGramAdapterExecutor.fromAddress(address(EXECUTOR_ADDRESS));
    val data = loadActiveData(contract.address, EXECUTOR_CODE_HASH);
    val storage = FrtGramAdapterExecutorStorage.fromCell(data);
    val (ownerAddress, secondaryAddress) = contract.info();
    val manager = contract.manager();
    val jettonWallet = contract.jettonWallet();

    expect(build("FrtGramAdapterExecutor").hash()).toEqual(EXECUTOR_CODE_HASH);
    expect(ownerAddress).toEqual(storage.ownerAddress);
    expect(secondaryAddress).toEqual(storage.secondaryAddress);
    expect((manager as any_address).castToInternal()).toEqual(manager);
    expect((jettonWallet as any_address).castToInternal()).toEqual(jettonWallet);
    expect(contract.owner()).toEqual(storage.ownerAddress);
}
