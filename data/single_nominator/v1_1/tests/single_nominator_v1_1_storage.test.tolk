import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/single_nominator_v1_1.types"
import "../wrappers/SingleNominatorV11.gen"

const FIXTURE_BOC_PATH = "data/single_nominator/v1_1/testdata/SingleNominatorV11.boc"
const DATA_FIXTURE_BOC_PATH = "data/single_nominator/v1_1/testdata/SingleNominatorV11.data.boc"
const DATA_FIXTURE_BOC = "te6ccgEBAQEARQAAhYARhy+Ifz/haSyza6FGBWNSde+ZjHy+uBieS1O4PxaPVnP8Dqn4VGKEh2fE8nnJMX7yTvNzoJgaUN4BrrMlylrF7L4="
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xcc0d39589eb2c0cfe0fde28456657a3bdd3d953955ae3f98f25664ab3c904fbd
const EXPECTED_DATA_HASH = 0x9f2bb399f70ea7540ff4421ec4f10b8e8bc4e64e1a06214f8db4af769ae14869
const PINNED_MAINNET_BLOCK = 71810979

const MAINNET_SINGLE_NOMINATOR_V11_ADDRESS = "Ef_blSQgiTZmBp9nTBTFFiluQ7tICOB_ZybvEv-YrXi_R7tG"
const MAINNET_OWNER_ADDRESS = "EQCMOXxD-f8LSWWbXQowKxqTr3zMY-X1wMTyWp3B-LR6s3Va"
const MAINNET_VALIDATOR_ADDRESS = "Ef8Dqn4VGKEh2fE8nnJMX7yTvNzoJgaUN4BrrMlylrF7L7sc"

fun mainnetSingleNominatorV11(): SingleNominatorV11 {
    return SingleNominatorV11.fromAddress(address(MAINNET_SINGLE_NOMINATOR_V11_ADDRESS));
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

fun loadStorageFromFork(pool: SingleNominatorV11): SingleNominatorV11Storage {
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
            expect(code!.hash()).toEqual(build("SingleNominatorV11", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return SingleNominatorV11Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Single Nominator v1.1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Single Nominator v1.1 mainnet fixture account is frozen");
        }
    }
}

fun getRoles(pool: SingleNominatorV11): SingleNominatorV11Roles {
    return pool.getRoles();
}

fun getPoolData(pool: SingleNominatorV11): SingleNominatorV11PoolDataReply {
    return pool.getPoolData();
}

fun expectStorageRoles(storage: SingleNominatorV11Storage): void {
    expect(storage.ownerAddress).toEqual(address(MAINNET_OWNER_ADDRESS));
    expect(storage.validatorAddress).toEqual(address(MAINNET_VALIDATOR_ADDRESS));
}

fun expectPoolDataDefaults(data: SingleNominatorV11PoolDataReply): void {
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
    pool: SingleNominatorV11,
    storage: SingleNominatorV11Storage,
): void {
    val roles = getRoles(pool);
    val poolData = getPoolData(pool);

    expect(roles.ownerAddress).toEqual(storage.ownerAddress);
    expect(roles.validatorAddress).toEqual(storage.validatorAddress);
    expectPoolDataDefaults(poolData);
}

get fun `test single nominator v1_1 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("SingleNominatorV11", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test single nominator v1_1 saved data fixture parses storage`() {
    val data = dataFixtureCell();
    val storage = SingleNominatorV11Storage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expectStorageRoles(storage);

    println("SINGLE_NOMINATOR_V11_DATA_FIXTURE_STORAGE={}", storage);
}

get fun `test single nominator v1_1 mainnet storage and getters`() {
    val pool = mainnetSingleNominatorV11();
    val storage = loadStorageFromFork(pool);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expectStorageRoles(storage);
    expectGettersMatchStorage(pool, storage);

    println("SINGLE_NOMINATOR_V11_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("SINGLE_NOMINATOR_V11_MAINNET_ADDRESS={}", pool.address);
    println("SINGLE_NOMINATOR_V11_MAINNET_STORAGE={}", storage);
}
