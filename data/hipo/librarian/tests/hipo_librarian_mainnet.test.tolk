import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_librarian.types"
import "../wrappers/HipoLibrarian.gen"

const CODE_FIXTURE_BOC_PATH = "data/hipo/librarian/testdata/HipoLibrarian.boc"
const DATA_FIXTURE_BOC_PATH = "data/hipo/librarian/testdata/HipoLibrarian.data.boc"
const DATA_FIXTURE_BOC = "te6ccgEBAQEAJAAAQ4AReTI5/C73j9LkKGffR336MykLSrn/oIFA2RNeBNbjefA="
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xcb1cdae5c512e6b1ca17d1b14514d20ec9dc91e6ba0591cd28a3eb071627f628
const EXPECTED_DATA_HASH = 0xf1b6384bc2e93619a98f80795ba15a9247d5957435e300d22d6b7ac20380206d
const PINNED_MAINNET_BLOCK = 71631031

const HIPO_LIBRARIAN_ADDRESS = "Ef-KhrzdZChlJiLZj2e1noxqrZ1rL6kGA4FWfW0SNhIfWKVV"
const HIPO_TREASURY_ADDRESS = "EQCLyZHP4Xe8fpchQz76O-_RmUhaVc_9BAoGyJrwJrcbz2eZ"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDataCell(): cell {
    return parseCellFromBase64(DATA_FIXTURE_BOC);
}

fun expectLibrarianStorage(storage: HipoLibrarianStorage): void {
    expect(storage.treasury).toEqual(address(HIPO_TREASURY_ADDRESS));
    expect((storage.treasury as any_address).castToInternal()).toEqual(storage.treasury);
}

fun mainnetHipoLibrarian(): HipoLibrarian {
    return HipoLibrarian.fromAddress(address(HIPO_LIBRARIAN_ADDRESS));
}

get fun `test hipo librarian code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("HipoLibrarian", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test hipo librarian parses saved toncenter account data`() {
    val data = savedDataCell();
    val storage = HipoLibrarianStorage.fromCell(data);
    var raw = data.beginParse();

    expectLibrarianStorage(storage);
    expect(raw.loadAddress()).toEqual(address(HIPO_TREASURY_ADDRESS));
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);

    println("HIPO_LIBRARIAN_SAVED_STORAGE={}", storage);
}

get fun `test hipo librarian mainnet storage from pinned fork`() {
    val librarian = mainnetHipoLibrarian();
    expect(librarian.address).toEqual(address(HIPO_LIBRARIAN_ADDRESS));

    val account = testing.getAccountState(librarian.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("HipoLibrarian", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);

            val storage = HipoLibrarianStorage.fromCell(data!);
            expectLibrarianStorage(storage);

            println("HIPO_LIBRARIAN_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
            println("HIPO_LIBRARIAN_MAINNET_STORAGE={}", storage);
        }
        TlbAccountStateUninit => {
            Assert.fail("Hipo Librarian mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Hipo Librarian mainnet fixture account is frozen");
        }
    }
}
