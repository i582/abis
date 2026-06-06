import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/bemo_unstake_request.types"
import "../wrappers/BemoUnstakeRequest.gen"

const FIXTURE_BOC_PATH = "data/bemo/unstake_request/testdata/BemoUnstakeRequest.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5b7a8516a9df1e8c9ffbeda43405223e3ba1696ee104465c5aa36b4a630a7e8c
const EXPECTED_DATA_HASH = 0x8d9a1dfaaad40b6b9f233aee19294556ab688636e2e098d241c6b40521842355
const EXPECTED_INDEX = 396
const EXPECTED_TON_AMOUNT = 99987377961
const EXPECTED_JETTON_AMOUNT = 99947706445
const EXPECTED_UNLOCK_TIMESTAMP = 1780833600
const PINNED_MAINNET_BLOCK = 71622046

const MAINNET_BEMO_UNSTAKE_REQUEST_ADDRESS = "EQB8if4poFsD7UKWnYIESQs2tN83Oe1CKqPAxnOeA-5O_CqF"
const MAINNET_BEMO_FINANCIAL_ADDRESS = "EQCSxGZPHqa3TtnODgMan8CEM0jf6HpY-uon_NMeFgjKqkEY"
const MAINNET_BEMO_OWNER_ADDRESS = "EQAdtoa9kIagpWX8tRFErQyFybG5KwHj7pB8go6om5yZvtcA"

struct LoadedBemoUnstakeRequestStorage {
    data: cell
    storage: BemoUnstakeRequestStorage
}

fun mainnetBemoUnstakeRequest(): BemoUnstakeRequest {
    return BemoUnstakeRequest.fromAddress(address(MAINNET_BEMO_UNSTAKE_REQUEST_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadBemoUnstakeRequestStorageFromFork(request: BemoUnstakeRequest): LoadedBemoUnstakeRequestStorage {
    val account = testing.getAccountState(request.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("BemoUnstakeRequest", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            val storage = BemoUnstakeRequestStorage.fromCell(data!);
            return LoadedBemoUnstakeRequestStorage { data: data!, storage };
        }
        TlbAccountStateUninit => {
            Assert.fail("Bemo Unstake Request mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Bemo Unstake Request mainnet fixture account is frozen");
        }
    }
}

fun expectBemoUnstakeRequestGettersMatchStorage(
    request: BemoUnstakeRequest,
    loaded: LoadedBemoUnstakeRequestStorage,
): void {
    val storage = loaded.storage;
    val reply = request.getUnstakeData();

    expect(scripts.isContractDeployed(request.address)).toBeTrue();
    expect(storage.index).toEqual(reply.index);
    expect(storage.financial).toEqual(reply.financial);
    expect(storage.owner).toEqual(reply.owner);
    expect(storage.tonAmount).toEqual(reply.tonAmount);
    expect(storage.jettonAmount).toEqual(reply.jettonAmount);
    expect(storage.unlockTimestamp).toEqual(reply.unlockTimestamp);
    expect(storage.forwardPayload).toBeNull();
    expect(reply.forwardPayload).toBeNull();

    expect(reply.index).toEqual(EXPECTED_INDEX);
    expect(reply.financial).toEqual(address(MAINNET_BEMO_FINANCIAL_ADDRESS));
    expect(reply.owner).toEqual(address(MAINNET_BEMO_OWNER_ADDRESS));
    expect(reply.tonAmount).toEqual(EXPECTED_TON_AMOUNT);
    expect(reply.jettonAmount).toEqual(EXPECTED_JETTON_AMOUNT);
    expect(reply.unlockTimestamp).toEqual(EXPECTED_UNLOCK_TIMESTAMP);
}

get fun `test bemo unstake request code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("BemoUnstakeRequest", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test bemo unstake request mainnet storage and getter`() {
    val request = mainnetBemoUnstakeRequest();
    val loaded = loadBemoUnstakeRequestStorageFromFork(request);

    expectBemoUnstakeRequestGettersMatchStorage(request, loaded);

    println("BEMO_UNSTAKE_REQUEST_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("BEMO_UNSTAKE_REQUEST_ADDRESS={}", request.address);
    println("BEMO_UNSTAKE_REQUEST_DATA_HASH={}", loaded.data.hash());
    println("BEMO_UNSTAKE_REQUEST_STORAGE={}", loaded.storage);
    println("BEMO_UNSTAKE_REQUEST_GET_UNSTAKE_DATA={}", request.getUnstakeData());
}
