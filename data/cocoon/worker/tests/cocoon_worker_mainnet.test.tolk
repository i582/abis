import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/cocoon_worker.types"
import "../wrappers/CocoonWorker.gen"

const FIXTURE_BOC_PATH = "data/cocoon/worker/testdata/CocoonWorker.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb100aeadcb1b1cb9274172044c1c27b041748ef4d2bbb8fe0f5c4da4dae67a3c
const EXPECTED_DATA_HASH = 0xc1ffc4e79be9e397340ec31ab2982f995b877c9c1569840b849cd4d1992bcdd3
const WORKER_ADDRESS = "EQApvPxqhVE0mRjg-ZxlogKyfr_BUJ2ppEzcp7i8Ahupo4RD"
const PROXY_ADDRESS = "EQDGkQM7RIWp6yGW79i8oV3zJ-vdnpV68pdZ2W8mrpE3cJ2y"
const PINNED_MAINNET_BLOCK = 83377290

fun worker(): CocoonWorker {
    return CocoonWorker.fromAddress(address(WORKER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadWorkerStorage(contract: CocoonWorker): CocoonWorkerStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CocoonWorker", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return CocoonWorkerStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("COCOON Worker is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("COCOON Worker is frozen at the pinned block");
        }
    }
}

get fun `test cocoon worker code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("CocoonWorker", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test cocoon worker parses pinned storage and getter`() {
    val contract = worker();
    val storage = loadWorkerStorage(contract);
    val params = storage.params.load();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.proxyAddress).toEqual(address(PROXY_ADDRESS));
    expect(storage.state).toEqual(0);
    expect(storage.tokens > 0).toBeTrue();
    expect(params.structVersion).toEqual(4);
    expect(params.isTest).toBeFalse();

    val data = contract.getCocoonWorkerData();
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.proxyAddress).toEqual(storage.proxyAddress);
    expect(data.proxyPublicKey).toEqual(storage.proxyPublicKey);
    expect(data.state).toEqual(storage.state);
    expect(data.tokens).toEqual(storage.tokens);
    println("COCOON_WORKER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
