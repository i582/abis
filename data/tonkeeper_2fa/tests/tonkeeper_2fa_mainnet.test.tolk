import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonkeeper_2fa.types"
import "../wrappers/Tonkeeper2fa.gen"

const CODE_FIXTURE_BOC_PATH = "data/tonkeeper_2fa/testdata/Tonkeeper2fa.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xc5ef19df22aee8b707bd7a181174e400a4225223c5ae40d8320f5ddd707d34a1
const MAINNET_TONKEEPER_2FA_ADDRESS = "EQAhPLqGHIVPVYg5-lbvo3B6tSFG3qtOz1MHIew3YdF1oP_w"

struct LoadedTonkeeper2faStorage {
    data: cell
    storage: Tonkeeper2faStorage
}

fun mainnetTonkeeper2fa(): Tonkeeper2fa {
    return Tonkeeper2fa.fromAddress(address(MAINNET_TONKEEPER_2FA_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadTonkeeper2faStorageFromFork(extension: Tonkeeper2fa): LoadedTonkeeper2faStorage {
    val account = testing.getAccountState(extension.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("Tonkeeper2fa", CODE_FIXTURE_BOC_PATH).hash());
            return LoadedTonkeeper2faStorage {
                data: data!,
                storage: Tonkeeper2faStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Tonkeeper 2FA mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Tonkeeper 2FA mainnet fixture account is frozen");
        }
    }
}

get fun `test tonkeeper 2fa code boc fixture is real and hash verified`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("Tonkeeper2fa", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonkeeper 2fa mainnet getters and storage`() {
    val extension = mainnetTonkeeper2fa();
    val loaded = loadTonkeeper2faStorageFromFork(extension);
    val storage = loaded.storage;
    val delegation = extension.getDelegationState();
    var storageDelegation = storage.delegationState;

    expect(scripts.isContractDeployed(extension.address)).toBeTrue();
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.seqno).toEqual(extension.getSeqno());
    expect(storage.wallet).toEqual(extension.getWalletAddr());
    expect(storage.rootCaPubkey).toEqual(extension.getRootPubkey());
    expect(storage.seedPubkey).toEqual(extension.getSeedPubkey());
    expect(storage.rootCaPubkey).toBeGreater(0);
    expect(storage.seedPubkey).toBeGreater(0);
    expect(storage.delegationStarted).toEqual(delegation.delegationStarted);
    expect(storage.delegationStarted).toBeFalse();
    expect(storageDelegation.loadUint(64)).toEqual(delegation.recoveryBlockedUntil);
    expect(storageDelegation.remainingBitsCount()).toEqual(0);
    expect(storageDelegation.remainingRefsCount()).toEqual(0);

    println("TONKEEPER_2FA_ADDRESS={}", extension.address);
    println("TONKEEPER_2FA_DATA_HASH={}", loaded.data.hash());
    println("TONKEEPER_2FA_STORAGE={}", storage);
}
