import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/airdrop_interlocker_v2.types"
import "../wrappers/AirdropInterlockerV2.gen"

const FIXTURE_BOC_PATH = "data/airdrop/interlocker_v2/testdata/AirdropInterlockerV2.boc"
const DATA_FIXTURE_BOC_PATH = "data/airdrop/interlocker_v2/testdata/AirdropInterlockerV2.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x0ff44a96fc2481111236d8d9920fd6e29b6108215e3ec5ba761ead9602adada4
const EXPECTED_DATA_HASH = 0xfa53f4a68d90741cb7fe26df94f99e20de5abcbc41622774fc8e6c4e1b8f51e0
const EXPECTED_MERKLE_ROOT = 0x9cd53cd47cc6fe6c87bebe030c711aff5178f614317f4c222818497b631603ee
const EXPECTED_RECEIVER = "0:5fe623d175df28b2ee3a720fbcb3add5745a8c110629258a3533a481ab040bcd"
const EXPECTED_DISTRIBUTOR = "0:33b5b0b3f63582e28e0d9b8ae42a6fd58a54f28326434dfc00ef394d82fec664"
const EXPECTED_MIN_COMMISSION = 250000000
const EXPECTED_TOTAL_AMOUNT = 20000000000
const EXPECTED_CLAIMED_AMOUNT = 7260000000
const EXPECTED_TOTALS_HASH = 0x57e7de17d2d43afe08d8200903a8148ccf350033882b21873bc44776690f611f
const EXPECTED_UNLOCKS_HASH = 0x654aeb18b423fe2e41fba7c976d76eda7ecc57fcd53b757f4c977094cc9917f4
const MAINNET_AIRDROP_INTERLOCKER_V2_ADDRESS = "EQAAbnoy7xE86q9Hw6X5NhKIdFFNGhKLWhzt63f2Dw-KjISf"
const DATA_FIXTURE_BOC = "te6ccgECCAEAAzwAAs9Oap5qPmN/NkPfXwGGOI1/qLx7Chi/phEUDCS9sYsB90AF/mI9F13yiy7jpyD7yzrdV0WowRBiklijUzpIGrBAvNgAZ2thZ+xrBcUcGzcVyFTfqxSp5QZMhpv4Ad5ymwX9jMiB3NZQGAECABZQSoF8gAUBsLrPAAGcaiS0gAA3aiYGAAA3aidXgAA3aiipAAA3ain6gAA3aitMAAA3aiydgAA3ai3vAAA3ai9AgAA3ajCSAAA3ajHjgAA3ajM1AAA3ajSGgAA3AwH8ajXYAAA3ajcpgAA3ajh7AAA3ajnMgAA3ajseAAA3ajxvgAA3aj3BAAA3aj8SgAA3akBkAAA3akG1gAA3akMHAAA3akRYgAA3akWqAAA3akb7gAA3akhNAAA3akmegAA3akrwAAA3akxBgAA3ak2TAAA3ak7kgAA3alA2AAA3BAH8alGHgAA3alLZAAA3alQqgAA3alV8AAA3albNgAA3algfAAA3allwgAA3alrCAAA3alwTgAA3al1lAAA3al62gAA3amAIAAA3amFZgAA3amKrAAA3amP8gAA3amVOAAA3amafgAA3amfxAAA3amlCgAA3amqUAAA3amvlgAA3BQH8am03AAA3am6IgAA3am/aAAA3anErgAA3anJ9AAA3anPOgAA3anUgAAA3anZxgAA3anfDAAA3ankUgAA3anpmAAA3anu3gAA3an0JAAA3an5agAA3an+sAAA3aoD9gAA3aoJPAAA3aoOggAA3aoTyAAA3aoZDgAA3aoeVAAA3BgH8aojmgAA3aoo4AAA3aouJgAA3aozbAAA3ao4sgAA3ao9+AAA3apDPgAA3apIhAAA3apNygAA3apTEAAA3apYVgAA3apdnAAA3api4gAA3apoKAAA3aptbgAA3apytAAA3ap3+gAA3ap9QAAA3aqChgAA3aqHzAAA3aqNEgAA3BwDYaqSWAAA3aqXngAA3aqc5AAA3aqiKgAA3aqncAAA3aqstgAA3aqx/AAA3aq3QgAA3aq8iAAA3arBzgAA3arHFAAA3arMWgAA3arRoAAA3arW5gAA3arcLAAA3arhcgAA3armuAAA3arr/gABk"

struct LoadedAirdropInterlockerV2Storage {
    data: cell
    storage: AirdropInterlockerV2Storage
}

fun mainnetAirdropInterlockerV2(): AirdropInterlockerV2 {
    return AirdropInterlockerV2.fromAddress(address(MAINNET_AIRDROP_INTERLOCKER_V2_ADDRESS));
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

fun loadStorageFixture(): AirdropInterlockerV2Storage {
    val data = dataFixtureCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = AirdropInterlockerV2Storage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun loadStorageFromFork(interlocker: AirdropInterlockerV2): LoadedAirdropInterlockerV2Storage {
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
            expect(code!.hash()).toEqual(build("AirdropInterlockerV2", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedAirdropInterlockerV2Storage {
                data: data!,
                storage: AirdropInterlockerV2Storage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Airdrop Interlocker v2 mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Airdrop Interlocker v2 mainnet account is frozen");
        }
    }
}

fun expectStorageValues(storage: AirdropInterlockerV2Storage): void {
    val totals = storage.totals.load();

    expect(storage.claimed).toBeFalse();
    expect(storage.merkleRoot).toEqual(EXPECTED_MERKLE_ROOT);
    expect(storage.receiver).toEqual(address(EXPECTED_RECEIVER));
    expect(storage.distributor).toEqual(address(EXPECTED_DISTRIBUTOR));
    expect(storage.minCommission).toEqual(EXPECTED_MIN_COMMISSION);
    expect(storage.amountKnown).toBeTrue();
    expect(storage.totals.hash()).toEqual(EXPECTED_TOTALS_HASH);
    expect(totals.totalAmount).toEqual(EXPECTED_TOTAL_AMOUNT);
    expect(totals.claimedAmount).toEqual(EXPECTED_CLAIMED_AMOUNT);
    expect(storage.unlocks.hash()).toEqual(EXPECTED_UNLOCKS_HASH);
}

get fun `test airdrop interlocker v2 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("AirdropInterlockerV2", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test airdrop interlocker v2 saved data fixture parses storage`() {
    val storage = loadStorageFixture();

    expectStorageValues(storage);

    println("AIRDROP_INTERLOCKER_V2_STORAGE_FIXTURE={}", storage);
    println("AIRDROP_INTERLOCKER_V2_TOTALS_FIXTURE={}", storage.totals.load());
}

get fun `test airdrop interlocker v2 mainnet storage and getters`() {
    val interlocker = mainnetAirdropInterlockerV2();
    val loaded = loadStorageFromFork(interlocker);
    val storage = loaded.storage;
    val totals = storage.totals.load();
    val distribution = interlocker.getDistributionInfo();
    val unlocksInfo = interlocker.getUnlocksInfo();
    val available = interlocker.getAvailableClaimAmount();

    expect(scripts.isContractDeployed(interlocker.address)).toBeTrue();
    expectStorageValues(storage);

    expect(distribution.merkleRoot).toEqual(storage.merkleRoot);
    expect(distribution.receiver).toEqual(storage.receiver);
    expect(distribution.distributor).toEqual(storage.distributor);
    expect(distribution.minCommission).toEqual(storage.minCommission);

    expect(unlocksInfo.claimed).toEqual(storage.claimed);
    expect(unlocksInfo.totalAmount).toEqual(totals.totalAmount);
    expect(unlocksInfo.claimedAmount).toEqual(totals.claimedAmount);
    expect(unlocksInfo.unlocks.hash()).toEqual(storage.unlocks.hash());
    expect(available).toBeGreaterOrEqual(0);
    expect(available).toBeLessOrEqual(totals.totalAmount - totals.claimedAmount);

    println("AIRDROP_INTERLOCKER_V2_ADDRESS={}", interlocker.address);
    println("AIRDROP_INTERLOCKER_V2_STORAGE={}", storage);
    println("AIRDROP_INTERLOCKER_V2_TOTALS={}", totals);
    println("AIRDROP_INTERLOCKER_V2_DISTRIBUTION={}", distribution);
    println("AIRDROP_INTERLOCKER_V2_UNLOCKS_INFO={}", unlocksInfo);
    println("AIRDROP_INTERLOCKER_V2_AVAILABLE={}", available);
}
