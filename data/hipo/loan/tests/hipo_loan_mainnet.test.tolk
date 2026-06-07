import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_loan.types"
import "../wrappers/HipoLoan.gen"

const FIXTURE_BOC_PATH = "data/hipo/loan/testdata/HipoLoan.boc"
const DATA_FIXTURE_BOC_PATH = "data/hipo/loan/testdata/HipoLoan.data.boc"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x56fb96fc4b9051deecfce8b04ce3c888990ba80fe6bd07154e351506ee9907a0
const EXPECTED_DATA_HASH = 0x3b9d34ef6aa39bd7be3f6d9ebcaace0c36e72deb9e0992f4fc7fedfccb6522c2
const EXPECTED_ROUND_SINCE = 1780764424
const PINNED_MAINNET_BLOCK = 71622046

const MAINNET_HIPO_LOAN_ADDRESS = "Ef_gcmy3Zh_YLOToiutmYF4nqZqohmr4OIowk-QjKQdG6bV9"
const MAINNET_HIPO_ELECTOR_ADDRESS = "-1:3333333333333333333333333333333333333333333333333333333333333333"
const MAINNET_HIPO_TREASURY_ADDRESS = "EQCLyZHP4Xe8fpchQz76O-_RmUhaVc_9BAoGyJrwJrcbz2eZ"
const MAINNET_HIPO_BORROWER_ADDRESS = "0:9c9b4ce7de3773c2a5f905f6f72c90392f0d79e149e8886df0aaa95bbe2b0fff"

struct LoadedHipoLoanStorage {
    data: cell
    storage: HipoLoanStorage
}

fun mainnetHipoLoan(): HipoLoan {
    return HipoLoan.fromAddress(address(MAINNET_HIPO_LOAN_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun expectStorageFields(storage: HipoLoanStorage): void {
    expect(storage.elector).toEqual(address(MAINNET_HIPO_ELECTOR_ADDRESS));
    expect(storage.treasury).toEqual(address(MAINNET_HIPO_TREASURY_ADDRESS));
    expect(storage.borrower).toEqual(address(MAINNET_HIPO_BORROWER_ADDRESS));
    expect(storage.roundSince).toEqual(EXPECTED_ROUND_SINCE);
}

fun loadHipoLoanStorageFromFork(loan: HipoLoan): LoadedHipoLoanStorage {
    val account = testing.getAccountState(loan.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("HipoLoan", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedHipoLoanStorage {
                data: data!,
                storage: HipoLoanStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Hipo Loan mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Hipo Loan mainnet fixture account is frozen");
        }
    }
}

get fun `test hipo loan code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("HipoLoan", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test hipo loan mainnet storage and getter`() {
    val loan = mainnetHipoLoan();
    val loaded = loadHipoLoanStorageFromFork(loan);
    val state = loan.getLoanState();

    expect(scripts.isContractDeployed(loan.address)).toBeTrue();
    expectStorageFields(loaded.storage);

    expectAnyAddressEqualsNullable(state.elector, loaded.storage.elector);
    expect(state.treasury).toEqual(loaded.storage.treasury);
    expect(state.borrower).toEqual(loaded.storage.borrower);
    expect(state.roundSince).toEqual(loaded.storage.roundSince);

    println("HIPO_LOAN_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("HIPO_LOAN_ADDRESS={}", loan.address);
    println("HIPO_LOAN_DATA_HASH={}", loaded.data.hash());
    println("HIPO_LOAN_STORAGE={}", loaded.storage);
    println("HIPO_LOAN_GET_STATE={}", state);
}
