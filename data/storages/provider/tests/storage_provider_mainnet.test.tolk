import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storage_provider.types"
import "../wrappers/StorageProvider.gen"

const FIXTURE_BOC_PATH = "data/storages/provider/testdata/StorageProvider.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x91befe944b1d974aea0fb6a215ac3404633e3230ad963fe9ae9d249111b52aea
const EXPECTED_RATE_PER_MB_DAY = 1000000000
const EXPECTED_MAX_SPAN = 86400
const EXPECTED_MINIMAL_FILE_SIZE = 1024
const EXPECTED_MAXIMAL_FILE_SIZE = 1000000000
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_STORAGE_PROVIDER_ADDRESS = "EQDEYkZr7HrYewkv1amJwkfMyrrNcZqVSAEPuOg3nr6d8FT7"
const SAMPLE_STORAGE_CLIENT = "EQBY5Ce_dSZeOtu-u09JRMB6dMMflc4iptMKSGCMVh_h7-Xa"

struct LoadedStorageProviderStorage {
    data: cell
    storage: StorageProviderStorage
}

fun mainnetStorageProvider(): StorageProvider {
    return StorageProvider.fromAddress(address(MAINNET_STORAGE_PROVIDER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadStorageProviderStorageFromFork(provider: StorageProvider): LoadedStorageProviderStorage {
    val account = testing.getAccountState(provider.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StorageProvider", FIXTURE_BOC_PATH).hash());
            return LoadedStorageProviderStorage {
                data: data!,
                storage: StorageProviderStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("TON Storage Provider mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TON Storage Provider mainnet fixture account is frozen");
        }
    }
}

fun expectStorageProviderGettersMatchStorage(provider: StorageProvider, loaded: LoadedStorageProviderStorage): void {
    val storage = loaded.storage;
    val walletParams = provider.getWalletParams();
    val storageParams = provider.getStorageParams();
    val sampleContractAddress = provider.getStorageContractAddress(
        0x7f01e90a1548b5ecbc26b27fb8007194a22edafc4ace348c7b703f92fd5b4143,
        179688,
        address(SAMPLE_STORAGE_CLIENT),
        0xfb7ada4a75311fd6f170ca180ebf9374839afa95b429bcb259562e2edda256de,
    );

    expect(scripts.isContractDeployed(provider.address)).toBeTrue();
    expect(provider.seqno()).toEqual(storage.seqno);
    expect(provider.getPublicKey()).toEqual(storage.publicKey);

    expect(walletParams.seqno).toEqual(storage.seqno);
    expect(walletParams.subwallet).toEqual(storage.subwallet);
    expect(walletParams.publicKey).toEqual(storage.publicKey);

    expect(storageParams.acceptNewContracts).toEqual(storage.acceptNewContracts);
    expect(storageParams.ratePerMbDay).toEqual(storage.ratePerMbDay);
    expect(storageParams.maxSpan).toEqual(storage.maxSpan);
    expect(storageParams.minimalFileSize).toEqual(storage.minimalFileSize);
    expect(storageParams.maximalFileSize).toEqual(storage.maximalFileSize);

    expect(storage.acceptNewContracts).toBeTrue();
    expect(storage.ratePerMbDay).toEqual(EXPECTED_RATE_PER_MB_DAY);
    expect(storage.maxSpan).toEqual(EXPECTED_MAX_SPAN);
    expect(storage.minimalFileSize).toEqual(EXPECTED_MINIMAL_FILE_SIZE);
    expect(storage.maximalFileSize).toEqual(EXPECTED_MAXIMAL_FILE_SIZE);
    expectInternalAddress(sampleContractAddress);
}

get fun `test storage provider code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StorageProvider", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storage provider mainnet storage and getters`() {
    val provider = mainnetStorageProvider();
    val loaded = loadStorageProviderStorageFromFork(provider);

    expectStorageProviderGettersMatchStorage(provider, loaded);

    println("STORAGE_PROVIDER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORAGE_PROVIDER_ADDRESS={}", provider.address);
    println("STORAGE_PROVIDER_STORAGE={}", loaded.storage);
}
