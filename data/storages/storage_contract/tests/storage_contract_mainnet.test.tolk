import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storage_contract.types"
import "../wrappers/StorageContract.gen"

const FIXTURE_BOC_PATH = "data/storages/storage_contract/testdata/StorageContract.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb4f9d928599d2f9be748f8a04af86a3cb2ff2053634df62b275545f6152b1d1a
const EXPECTED_FILE_SIZE = 179688
const EXPECTED_RATE_PER_MB_DAY = 1
const EXPECTED_MAX_SPAN = 86400
const EXPECTED_LAST_PROOF_TIME = 1753103874
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_STORAGE_CONTRACT_ADDRESS = "EQCdNyptyckH9K9numWAaQIlwBq3rl1GLelUeQUYJucpC2XE"

struct LoadedStorageContractStorage {
    data: cell
    storage: StorageContractStorage
    clientData: StorageContractClientData
}

fun mainnetStorageContract(): StorageContract {
    return StorageContract.fromAddress(address(MAINNET_STORAGE_CONTRACT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStorageContractStorageFromFork(contract: StorageContract): LoadedStorageContractStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StorageContract", FIXTURE_BOC_PATH).hash());
            val storage = StorageContractStorage.fromCell(data!);
            return LoadedStorageContractStorage {
                data: data!,
                storage,
                clientData: storage.clientData.load(),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("TON Storage Contract mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TON Storage Contract mainnet fixture account is frozen");
        }
    }
}

fun expectStorageContractGettersMatchStorage(contract: StorageContract, loaded: LoadedStorageContractStorage): void {
    val storage = loaded.storage;
    val clientData = loaded.clientData;
    val contractData = contract.getStorageContractData();
    val nextProofInfo = contract.getNextProofInfo();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(contract.getTorrentHash()).toEqual(clientData.torrentHash);
    expect(contract.isActive()).toEqual(storage.active);

    expect(contractData.active).toEqual(storage.active);
    expect(contractData.balance).toEqual(storage.balance);
    expect(contractData.provider).toEqual(storage.provider);
    expect(contractData.merkleHash).toEqual(storage.merkleHash);
    expect(contractData.fileSize).toEqual(storage.fileSize);
    expect(contractData.nextProof).toEqual(storage.nextProof);
    expect(contractData.ratePerMbDay).toEqual(storage.ratePerMbDay);
    expect(contractData.maxSpan).toEqual(storage.maxSpan);
    expect(contractData.lastProofTime).toEqual(storage.lastProofTime);
    expect(contractData.client).toEqual(clientData.client);
    expect(contractData.torrentHash).toEqual(clientData.torrentHash);

    expect(nextProofInfo.nextProof).toEqual(storage.nextProof);
    expect(nextProofInfo.lastProofTime).toEqual(storage.lastProofTime);
    expect(nextProofInfo.maxSpan).toEqual(storage.maxSpan);

    expect(storage.active).toBeFalse();
    expect(storage.fileSize).toEqual(EXPECTED_FILE_SIZE);
    expect(storage.ratePerMbDay).toEqual(EXPECTED_RATE_PER_MB_DAY);
    expect(storage.maxSpan).toEqual(EXPECTED_MAX_SPAN);
    expect(storage.lastProofTime).toEqual(EXPECTED_LAST_PROOF_TIME);
    expect(storage.balance).toBeGreater(0);
}

get fun `test storage contract code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StorageContract", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storage contract mainnet storage and getters`() {
    val contract = mainnetStorageContract();
    val loaded = loadStorageContractStorageFromFork(contract);

    expectStorageContractGettersMatchStorage(contract, loaded);

    println("STORAGE_CONTRACT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORAGE_CONTRACT_ADDRESS={}", contract.address);
    println("STORAGE_CONTRACT_STORAGE={}", loaded.storage);
    println("STORAGE_CONTRACT_CLIENT_DATA={}", loaded.clientData);
}
