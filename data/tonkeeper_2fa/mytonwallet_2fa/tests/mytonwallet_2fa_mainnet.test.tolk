import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/mytonwallet_2fa.types"
import "../wrappers/MyTonWallet2fa.gen"

const CODE_FIXTURE_BOC_PATH = "data/tonkeeper_2fa/mytonwallet_2fa/testdata/MyTonWallet2fa.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonkeeper_2fa/mytonwallet_2fa/testdata/MyTonWallet2fa.data.boc"
const LIBRARY_FIXTURE_BOC_PATH = "data/tonkeeper_2fa/mytonwallet_2fa/testdata/MyTonWallet2faLibrary.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x14dbe27de307b26faf75361dc5429d1a14b5288f9a82ce08727513c02835e4f7
const EXPECTED_DATA_HASH = 0x568ea85caa48a12c53e576fc06b35543a8ce7f415d37c4b249a248d7d8473fcd
const EXPECTED_LIBRARY_HASH = 0x701eede652337f699550cc51cb15263259aae6fc6eba976237945f142dda982d
const PINNED_MAINNET_BLOCK = 83370093
const MAINNET_EXTENSION_ADDRESS = "EQCrhkjs2CbHTj5tJ7Ux1J7JiiLDAD9uC6qc9p3AvXBP0-8h"
const WALLET_ADDRESS = "EQDqAuCsDYjpqFPNkPKKI2I5vTMyRIvQxhw_ZippTfBzuh_d"

struct LoadedMyTonWallet2faStorage {
    data: cell
    storage: MyTonWallet2faStorage
}

fun extension(): MyTonWallet2fa {
    return MyTonWallet2fa.fromAddress(address(MAINNET_EXTENSION_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadFixture(name: string, path: string): cell {
    val bytes = fs.readBytes(path);
    expect(bytes).toBeNotNull();
    expect(hasBocMagic(bytes!)).toBeTrue();
    return build(name, path);
}

fun loadStorageFromFork(contract: MyTonWallet2fa): LoadedMyTonWallet2faStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                loadFixture("MyTonWallet2fa", CODE_FIXTURE_BOC_PATH).hash(),
            );
            return LoadedMyTonWallet2faStorage {
                data: data!,
                storage: MyTonWallet2faStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("MyTonWallet 2FA extension is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("MyTonWallet 2FA extension is frozen at the pinned block");
        }
    }
}

get fun `test mytonwallet 2fa exact code data and library fixtures`() {
    val code = loadFixture("MyTonWallet2fa", CODE_FIXTURE_BOC_PATH);
    val data = loadFixture("MyTonWallet2faData", DATA_FIXTURE_BOC_PATH);
    val library = loadFixture("MyTonWallet2faLibrary", LIBRARY_FIXTURE_BOC_PATH);

    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(library.hash()).toEqual(EXPECTED_LIBRARY_HASH);

    val storage = MyTonWallet2faStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.seqno).toEqual(16);
    expect(storage.wallet).toEqual(address(WALLET_ADDRESS));
    expect(storage.telegramId.hash()).toEqual(
        0x2c40619cf1e72af52eead37a2ae6c9fed2036e891979cd753be93c77226b6999,
    );
    expect(storage.seedPubkey).toEqual(
        0xe876517d96c5738f48fd5431501c1ba803ed2f435d05daad23644d67e390007e,
    );
    expect(storage.recoveryStarted).toBeFalse();
    expect(storage.blockedUntil).toEqual(0);
}

get fun `test mytonwallet 2fa pinned mainnet storage and getters`() {
    val contract = extension();
    val loaded = loadStorageFromFork(contract);
    val storage = loaded.storage;
    val recovery = contract.getRecoveryState();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(loaded.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.seqno).toEqual(contract.getSeqno());
    expect(storage.seqno).toEqual(16);
    expect(storage.wallet).toEqual(address(WALLET_ADDRESS));
    expect(storage.recoveryStarted).toEqual(recovery.recoveryStarted);
    expect(storage.blockedUntil).toEqual(recovery.blockedUntil);
    expect(contract.getTelegramId()).toEqual(6230557472);
    expect(recovery.recoveryStarted).toBeFalse();
    expect(recovery.blockedUntil).toEqual(0);

    println("MYTONWALLET_2FA_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("MYTONWALLET_2FA_ADDRESS={}", contract.address);
    println("MYTONWALLET_2FA_STORAGE={}", storage);
}
