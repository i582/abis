import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/signed_cross_dex_executor.types"
import "../wrappers/SignedCrossDexExecutor.gen"

const MAINNET_EXECUTOR_ADDRESS = "EQChhrKIi_Ab-cwXfXw0pFMY1MwEGVfb2s6gwDKNuGZdolkm"
const CODE_FIXTURE_PATH = "data/signed_cross_dex/executor/testdata/SignedCrossDexExecutor.boc"
const DATA_FIXTURE_PATH = "data/signed_cross_dex/executor/testdata/SignedCrossDexExecutor.data.boc"
const EXPECTED_CODE_HASH = 0x5f47950a564bac34703f1b01bd95dcd7343ca80b3c014548fcdf7205d46336c3
const EXPECTED_DATA_HASH = 0x0a63bf4a255c0fb49f52efbf7b684c3587a7e5e03cf788488db383b7bc8eb60a
const EXPECTED_PUBLIC_KEY = 0xf2548941d2b55d0cd93f6590bcff5413d4d555fbd13b50e2347f17e064f4eb4d
const PINNED_MAINNET_BLOCK = 83514993

fun mainnetSignedCrossDexExecutor(): SignedCrossDexExecutor {
    return SignedCrossDexExecutor.fromAddress(address(MAINNET_EXECUTOR_ADDRESS));
}

fun loadStorageFromFork(executor: SignedCrossDexExecutor): SignedCrossDexExecutorStorage {
    val account = testing.getAccountState(executor.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("SignedCrossDexExecutor", CODE_FIXTURE_PATH).hash());
            return SignedCrossDexExecutorStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Signed cross-DEX executor is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Signed cross-DEX executor is frozen at the pinned block");
        }
    }
}

get fun `test signed cross dex exact code and data fixtures`() {
    val codeBytes = fs.readBytes(CODE_FIXTURE_PATH);
    val dataBytes = fs.readBytes(DATA_FIXTURE_PATH);
    expect(codeBytes).toBeNotNull();
    expect(dataBytes).toBeNotNull();
    expect(codeBytes!.preloadUint(32)).toEqual(0xb5ee9c72);
    expect(dataBytes!.preloadUint(32)).toEqual(0xb5ee9c72);

    val code = build("SignedCrossDexExecutor", CODE_FIXTURE_PATH);
    val data = build("SignedCrossDexExecutorData", DATA_FIXTURE_PATH);
    val storage = SignedCrossDexExecutorStorage.fromCell(data);
    val continuation = storage.continuation;

    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.lastCleanedQueryId).toEqual(7669400232966163715);
    expect(storage.publicKey).toEqual(EXPECTED_PUBLIC_KEY);
    expect(continuation).toBeNotNull();
    expect(continuation!.load().remainingSteps).toEqual(2);
}

get fun `test signed cross dex pinned storage and getters`() {
    val executor = mainnetSignedCrossDexExecutor();
    val storage = loadStorageFromFork(executor);
    val continuation = storage.continuation;
    val expectedRemainingSteps = continuation == null
        ? 0
        : continuation.load().remainingSteps as int;

    expect(scripts.isContractDeployed(executor.address)).toBeTrue();
    expect(storage.publicKey).toEqual(EXPECTED_PUBLIC_KEY);
    expect(executor.seqno()).toEqual(0);
    expect(executor.getMethod995190ybc()).toEqual(expectedRemainingSteps);
    expect(executor.processed(0)).toEqual(1);
    expect(executor.processed(18446744073709551615)).toEqual(0);

    println("SIGNED_CROSS_DEX_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("SIGNED_CROSS_DEX_EXECUTOR_ADDRESS={}", executor.address);
    println("SIGNED_CROSS_DEX_STORAGE={}", storage);
}
