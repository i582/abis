import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/airdrop_interlocker_v1.types"
import "../wrappers/AirdropInterlockerV1.gen"

const FIXTURE_BOC_PATH = "data/airdrop/interlocker_v1/testdata/AirdropInterlockerV1.boc"
const DATA_FIXTURE_BOC_PATH = "data/airdrop/interlocker_v1/testdata/AirdropInterlockerV1.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xacd2b8ec4db7414396fa53698653ecc04a416ee3649d8f5b20b41f176ad833f0
const EXPECTED_DATA_HASH = 0x636ae8fdd990cfe6eed0ab3f2f9dec98a48e89a8dff06a0488d1344b0e0c02b7
const EXPECTED_MERKLE_ROOT = 0x0c929b45b93f63cf394dac4b0e1993ff30c98c16a8bd2710358ca391e2e6f033
const EXPECTED_RECEIVER = "0:15dad65f227da08fdba7c5b640e503d6a5774f50d305b5c37889e28d8e1070ef"
const EXPECTED_DISTRIBUTOR = "0:349e60be368c6ea09adaa773c99f701fd4c9ac50e05c4f27bc57243fe6b93512"
const EXPECTED_MIN_COMMISSION = 150000000
const MAINNET_AIRDROP_INTERLOCKER_V1_ADDRESS = "EQAEJuROARXd5NePsr6NJujD67mQslW5KI004drUaBt2ILCT"
const DATA_FIXTURE_BOC =
    "te6ccgEBAQEAagAAz4ZJTaLcn7HnnKbWJYcMyf+YZMYLVF6TiBrGUcjxc3gZwAFdrWXyJ9oI/bp8W2QOUD1qV3T1DTBbXDeInijY4QcO+ABpPMF8bRjdQTW1TueTPuA/qZNYocC4nk94rkh/zXJqJIEeGjAQ"

struct LoadedAirdropInterlockerV1Storage {
    data: cell
    storage: AirdropInterlockerV1Storage
}

fun mainnetAirdropInterlockerV1(): AirdropInterlockerV1 {
    return AirdropInterlockerV1.fromAddress(address(MAINNET_AIRDROP_INTERLOCKER_V1_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun dataFixtureCell(): cell {
    return parseCellFromBase64(DATA_FIXTURE_BOC);
}

fun loadStorageFixture(): AirdropInterlockerV1Storage {
    val data = dataFixtureCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = AirdropInterlockerV1Storage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun loadStorageFromFork(interlocker: AirdropInterlockerV1): LoadedAirdropInterlockerV1Storage {
    val account = testing.getAccountState(interlocker.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("AirdropInterlockerV1", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedAirdropInterlockerV1Storage {
                data: data!,
                storage: AirdropInterlockerV1Storage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Airdrop Interlocker v1 mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Airdrop Interlocker v1 mainnet account is frozen");
        }
    }
}

fun expectStorageValues(storage: AirdropInterlockerV1Storage): void {
    expect(storage.claimed).toBeTrue();
    expect(storage.merkleRoot).toEqual(EXPECTED_MERKLE_ROOT);
    expect(storage.receiver).toEqual(address(EXPECTED_RECEIVER));
    expect(storage.distributor).toEqual(address(EXPECTED_DISTRIBUTOR));
    expect(storage.minCommission).toEqual(EXPECTED_MIN_COMMISSION);
}

get fun `test airdrop interlocker v1 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("AirdropInterlockerV1", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test airdrop interlocker v1 saved data fixture parses storage`() {
    val storage = loadStorageFixture();

    expectStorageValues(storage);

    println("AIRDROP_INTERLOCKER_V1_STORAGE_FIXTURE={}", storage);
}

get fun `test airdrop interlocker v1 mainnet storage and getter`() {
    val interlocker = mainnetAirdropInterlockerV1();
    val loaded = loadStorageFromFork(interlocker);
    val data = interlocker.getContractData();

    expect(scripts.isContractDeployed(interlocker.address)).toBeTrue();
    expectStorageValues(loaded.storage);
    expect(data.isClaimed).toEqual(loaded.storage.claimed);
    expect(data.merkleRoot).toEqual(loaded.storage.merkleRoot);
    expect(data.receiver).toEqual(loaded.storage.receiver);
    expect(data.distributor).toEqual(loaded.storage.distributor);

    println("AIRDROP_INTERLOCKER_V1_ADDRESS={}", interlocker.address);
    println("AIRDROP_INTERLOCKER_V1_STORAGE={}", loaded.storage);
    println("AIRDROP_INTERLOCKER_V1_GET_CONTRACT_DATA={}", data);
}
