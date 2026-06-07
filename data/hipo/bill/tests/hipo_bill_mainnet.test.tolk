import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_bill.types"
import "../wrappers/HipoBill.gen"

const MAINNET_HIPO_BILL_ADDRESS = "EQDBJw5nOR8APrGY-qRcO2_9NOJvI0PXoXIphoKrYZIc9oHg"
const MAINNET_HIPO_COLLECTION_ADDRESS = "EQCLCScwON95erSRKhHuBDf9O8hT8ERGwCNjbS1w0JzqHDFA"
const MAINNET_HIPO_PARENT_ADDRESS = "EQDPdq8xjAhytYqfGSX8KcFWIReCufsB9Wdg0pLlYSO_h76w"
const MAINNET_HIPO_OWNER_ADDRESS = "EQBF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBL1o"
const EXPECTED_CODE_HASH = 0x9e2923274fd83860d5b9ad4bb34f2a6da3c93f0b25f0ae973abf27c6df359f8f
const EXPECTED_DATA_HASH = 0x7b28c0d87271a7ae17fee89ac63cdd37206c28a3749aaf844c0ace52bc42f5e2
const EXPECTED_INDEX = 0
const EXPECTED_REVOKED_AT = 0
const EXPECTED_AMOUNT = 19654977536
const PINNED_MAINNET_BLOCK = 71630478

struct LoadedHipoBillStorage {
    data: cell
    storage: HipoBillStorage
}

fun mainnetHipoBillAddress(): address {
    return address(MAINNET_HIPO_BILL_ADDRESS);
}

fun loadHipoBillStorageFromFork(): LoadedHipoBillStorage {
    val billAddress = mainnetHipoBillAddress();
    val account = testing.getAccountState(billAddress);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            val storage = HipoBillStorage.fromCell(data!);
            return LoadedHipoBillStorage {
                data: data!,
                storage,
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Hipo Bill mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Hipo Bill mainnet fixture account is frozen");
        }
    }
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

get fun `test hipo bill mainnet storage and getters`() {
    val bill = HipoBill.fromAddress(mainnetHipoBillAddress());
    val loaded = loadHipoBillStorageFromFork();
    val storage = loaded.storage;
    val nftData = bill.getNftData();
    val authority = bill.getAuthorityAddress();
    val revokedTime = bill.getRevokedTime();

    expect(scripts.isContractDeployed(bill.address)).toBeTrue();
    expect(storage.index).toEqual(EXPECTED_INDEX);
    expect(storage.collection).toEqual(address(MAINNET_HIPO_COLLECTION_ADDRESS));
    expect(storage.revokedAt).toEqual(EXPECTED_REVOKED_AT);
    expect(storage.parent).toBeNotNull();
    expect(storage.parent!).toEqual(address(MAINNET_HIPO_PARENT_ADDRESS));
    expect(storage.owner).toBeNotNull();
    expect(storage.owner!).toEqual(address(MAINNET_HIPO_OWNER_ADDRESS));
    expect(storage.unstake).toBeTrue();
    expect(storage.amount).toEqual(EXPECTED_AMOUNT);

    expect(nftData.isInitialized).toBeTrue();
    expect(nftData.index).toEqual(storage.index as int);
    expect(nftData.collection).toEqual(storage.collection);
    expectAnyAddressEqualsNullable(nftData.owner, storage.owner);
    expect(nftData.content.hash()).toBeGreater(0);
    expect(authority).toEqual(storage.collection);
    expect(revokedTime).toEqual(storage.revokedAt);

    println("HIPO_BILL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("HIPO_BILL_ADDRESS={}", bill.address);
    println("HIPO_BILL_DATA_HASH={}", loaded.data.hash());
    println("HIPO_BILL_STORAGE={}", storage);
    println("HIPO_BILL_GET_NFT_DATA={}", nftData);
}
