import "@acton/build"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_collection.types"
import "../wrappers/HipoCollection.gen"

const FIXTURE_BOC_PATH = "data/hipo/collection/testdata/HipoCollection.boc"
const DATA_FIXTURE_BOC_PATH = "data/hipo/collection/testdata/HipoCollection.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9f1b492a4f05be6526d01cc3498b94961e1415e4c8ca196273fe389001da4ed6
const EXPECTED_DATA_HASH = 0xeff5c1b3890c8699d2ebdffb4433f1d6a1c7b6f38a30ffec96bf1aadbbaa4d32
const EXPECTED_BILL_CODE_HASH = 0x9e2923274fd83860d5b9ad4bb34f2a6da3c93f0b25f0ae973abf27c6df359f8f
const EXPECTED_ROUND_SINCE = 1780764424
const EXPECTED_NEXT_ITEM_INDEX = 1
const PINNED_MAINNET_BLOCK = 71599021

const MAINNET_HIPO_COLLECTION_ADDRESS = "EQCLCScwON95erSRKhHuBDf9O8hT8ERGwCNjbS1w0JzqHDFA"
const MAINNET_HIPO_TREASURY_ADDRESS = "EQCLyZHP4Xe8fpchQz76O-_RmUhaVc_9BAoGyJrwJrcbz2eZ"
const MAINNET_HIPO_BILL_ITEM_0_ADDRESS = "EQDBJw5nOR8APrGY-qRcO2_9NOJvI0PXoXIphoKrYZIc9oHg"

fun mainnetHipoCollection(): HipoCollection {
    return HipoCollection.fromAddress(address(MAINNET_HIPO_COLLECTION_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadHipoCollectionStorageFromFork(collection: HipoCollection): HipoCollectionStorage {
    val account = testing.getAccountState(collection.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("HipoCollection", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return HipoCollectionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Hipo Collection mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Hipo Collection mainnet fixture account is frozen");
        }
    }
}

get fun `test hipo collection code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("HipoCollection", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test hipo collection mainnet storage and getters`() {
    val collection = mainnetHipoCollection();
    val storage = loadHipoCollectionStorageFromFork(collection);
    val collectionData = collection.getCollectionData();
    val bill0 = collection.getNftAddressByIndex(0);
    val individualContent = beginCell().storeUint(0x1234, 16).endCell();
    val returnedContent = collection.getNftContent(0, individualContent);

    expect(scripts.isContractDeployed(collection.address)).toBeTrue();
    expect(storage.treasury).toEqual(address(MAINNET_HIPO_TREASURY_ADDRESS));
    expect(storage.roundSince).toEqual(EXPECTED_ROUND_SINCE);
    expect(storage.nextItemIndex).toEqual(EXPECTED_NEXT_ITEM_INDEX);
    expect(storage.billCode.hash()).toEqual(EXPECTED_BILL_CODE_HASH);

    expect(collectionData.nextItemIndex).toEqual(storage.nextItemIndex as int);
    expect(collectionData.treasury).toEqual(storage.treasury);
    expect(collectionData.collectionMetadata.hash()).toBeGreater(0);
    expect(bill0).toEqual(address(MAINNET_HIPO_BILL_ITEM_0_ADDRESS));
    expect(returnedContent.hash()).toEqual(individualContent.hash());

    println("HIPO_COLLECTION_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("HIPO_COLLECTION_ADDRESS={}", collection.address);
    println("HIPO_COLLECTION_STORAGE={}", storage);
    println("HIPO_COLLECTION_DATA={}", collectionData);
    println("HIPO_COLLECTION_BILL_0_ADDRESS={}", bill0);
}
