import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/single_nominator_v1_0.types"
import "../wrappers/SingleNominatorV10.gen"

const FIXTURE_BOC_PATH = "data/single_nominator/v1_0/testdata/SingleNominatorV10.boc"
const DATA_FIXTURE_BOC_PATH = "data/single_nominator/v1_0/testdata/SingleNominatorV10.data.boc"
const DATA_FIXTURE_BOC = "te6ccgEBAQEARQAAhYARdQqdi5PjEqW8fC3pHpqYZ8XnvGg6BuKJK/NRgDw2IrP8LlstBeLIAf4XbBzkpjiDxP8eE90fwzMUKIDT1ooDXjo="
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa42ae69eac76ffe0e452d3d4f13d387a14e46c01a5aadba5fc1d893e6c71f5ba
const EXPECTED_DATA_HASH = 0x2b0e14111ecf5372c9f7d9e6b6d6eb9462e769652e72902cff3533939de970e4
const PINNED_MAINNET_BLOCK = 71810979

const MAINNET_SINGLE_NOMINATOR_V10_ADDRESS = "Ef8eWpCZ7U0WWxCFEnXsae_3GTPnAWyolMp6KkWAWetQcjZj"
const MAINNET_OWNER_ADDRESS = "EQCLqFTsXJ8YlS3j4W9I9NTDPi8940HQNxRJX5qMAeGxFcrL"
const MAINNET_VALIDATOR_ADDRESS = "Ef8LlstBeLIAf4XbBzkpjiDxP8eE90fwzMUKIDT1ooDXjibB"

fun mainnetSingleNominatorV10(): SingleNominatorV10 {
    return SingleNominatorV10.fromAddress(address(MAINNET_SINGLE_NOMINATOR_V10_ADDRESS));
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

fun loadStorageFromFork(pool: SingleNominatorV10): SingleNominatorV10Storage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("SingleNominatorV10", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return SingleNominatorV10Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Single Nominator v1.0 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Single Nominator v1.0 mainnet fixture account is frozen");
        }
    }
}

fun getRoles(pool: SingleNominatorV10): SingleNominatorV10Roles {
    return pool.getRoles();
}

fun getPoolData(pool: SingleNominatorV10): SingleNominatorV10PoolDataReply {
    return pool.getPoolData();
}

fun expectStorageRoles(storage: SingleNominatorV10Storage): void {
    expect(storage.ownerAddress).toEqual(address(MAINNET_OWNER_ADDRESS));
    expect(storage.validatorAddress).toEqual(address(MAINNET_VALIDATOR_ADDRESS));
}

fun expectPoolDataDefaults(data: SingleNominatorV10PoolDataReply): void {
    expect(data.state).toEqual(2);
    expect(data.nominatorsCount).toEqual(1);
    expect(data.stakeAmountSent).toEqual(0);
    expect(data.validatorAmount).toEqual(0);
    expect(data.validatorAddress).toEqual(0);
    expect(data.validatorRewardShare).toEqual(0);
    expect(data.maxNominatorsCount).toEqual(0);
    expect(data.minValidatorStake).toEqual(0);
    expect(data.minNominatorStake).toEqual(0);
    expect(data.nominators).toBeNull();
    expect(data.withdrawRequests).toBeNull();
    expect(data.stakeAt).toEqual(0);
    expect(data.savedValidatorSetHash).toEqual(0);
    expect(data.validatorSetChangesCount).toEqual(2);
    expect(data.validatorSetChangeTime).toEqual(0);
    expect(data.stakeHeldFor).toEqual(0);
}

fun expectGettersMatchStorage(
    pool: SingleNominatorV10,
    storage: SingleNominatorV10Storage,
): void {
    val roles = getRoles(pool);
    val poolData = getPoolData(pool);

    expect(roles.ownerAddress).toEqual(storage.ownerAddress);
    expect(roles.validatorAddress).toEqual(storage.validatorAddress);
    expectPoolDataDefaults(poolData);
}

get fun `test single nominator v1_0 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("SingleNominatorV10", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test single nominator v1_0 saved data fixture parses storage`() {
    val data = dataFixtureCell();
    val storage = SingleNominatorV10Storage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expectStorageRoles(storage);

    println("SINGLE_NOMINATOR_V10_DATA_FIXTURE_STORAGE={}", storage);
}

get fun `test single nominator v1_0 mainnet storage and getters`() {
    val pool = mainnetSingleNominatorV10();
    val storage = loadStorageFromFork(pool);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expectStorageRoles(storage);
    expectGettersMatchStorage(pool, storage);

    println("SINGLE_NOMINATOR_V10_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("SINGLE_NOMINATOR_V10_MAINNET_ADDRESS={}", pool.address);
    println("SINGLE_NOMINATOR_V10_MAINNET_STORAGE={}", storage);
}
