import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonstakers_validator_controller.types"

const CODE_FIXTURE_BOC_PATH = "data/tonstakers/controller/testdata/TonstakersValidatorController.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonstakers/controller/testdata/TonstakersValidatorController.data.boc"
const DATA_FIXTURE_BOC = "te6ccgEBAwEA+QABiQBAAAAAAAAAsMyAz5qjJhcm+LZYEcv8JKIwY3kZfZm/7SHWuo2+5aAIAAGc2T7EAAAAAgAAAAAAAAAAAAAAAAAAAAAACAEB0QAAAACf75L7tBm0MNWKmJTGQbVxyL4CNs5Mq0jmbjdfMPrXahIwApFsX8oQJIpt4Ng4ykEIPE+T+IPkNfiv4xKxnAyWeIvqAESTIwI4uSoCWZpCPZrybnD/CL9oJF8eYxPiv8V+lGImQAIAhYAYKMg5K4k30jynjQhoygtAEIV5RIsrtWFtNhmwmCUrPRACzouwkiwi7vsdtXfya1p/xnRwCWVa+J1rO7bBHseF194="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xdd3ce98db487c7585803933bffba7a57eb4e663099059d08b83db0b4ce060793
const EXPECTED_DATA_HASH = 0x0c78bcb09b8f07415b64e6583f9e579ba76880f3a015df2ecdef80a0c780b476
const EXPECTED_REQUEST_WINDOW_SINCE = 1778241288
const EXPECTED_REQUEST_WINDOW_UNTIL = 1778265864
const EXPECTED_MAX_LOAN = 901000000000000
const EXPECTED_MAX_INTEREST = 5033
const PINNED_MAINNET_BLOCK = 71635640

const MAINNET_CONTROLLER_ADDRESS = "Ef9bdRWdEwl7HRbeoUgbze1ZBw-SLXkl74f8roPiwZtX6NB1"
const EXPECTED_VALIDATOR_ADDRESS = "-1:7C97DDA0CDA186AC54C4A6320DAB8E45F011B672655A473371BAF987D6BB5091"
const EXPECTED_POOL_ADDRESS = "0:A45B17F28409229B78360E3290420F13E4FE20F90D7E2BF8C4AC6703259E22FA"
const EXPECTED_GOVERNOR_ADDRESS = "0:8926460471725404B334847B35E4DCE1FE117ED048BE3CC627C57F8AFD28C44C"
const EXPECTED_APPROVER_ADDRESS = "0:C14641C95C49BE91E53C684346505A00842BCA24595DAB0B69B0CD84C12959E8"
const EXPECTED_HALTER_ADDRESS = "0:B3A2EC248B08BBBEC76D5DFC9AD69FF19D1C025956BE275ACEEDB047B1E175F7"

struct TonstakersValidatorControllerFork {
    address: address
}

struct LoadedTonstakersValidatorControllerStorage {
    data: cell
    storage: TonstakersValidatorControllerStorage
    staticData: TonstakersValidatorControllerStaticData
    roles: TonstakersValidatorControllerRoles
}

fun mainnetController(): TonstakersValidatorControllerFork {
    return TonstakersValidatorControllerFork { address: address(MAINNET_CONTROLLER_ADDRESS) };
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

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun expectStableStorageFields(loaded: LoadedTonstakersValidatorControllerStorage): void {
    val storage = loaded.storage;
    val staticData = loaded.staticData;
    val roles = loaded.roles;

    expect(storage.state).toEqual(0);
    expect(storage.halted).toBeFalse();
    expect(storage.approved).toBeTrue();
    expect(storage.stakeAmountSent).toEqual(0);
    expect(storage.stakeAt).toEqual(0);
    expect(storage.sudoer).toBeNull();
    expect(storage.savedValidatorSetHash).toBeGreater(0);
    expect(storage.validatorSetChangesCount).toBeGreaterOrEqual(0);

    expect(staticData.controllerId).toEqual(0);
    expect(staticData.validator).toEqual(address(EXPECTED_VALIDATOR_ADDRESS));
    expect(staticData.pool).toEqual(address(EXPECTED_POOL_ADDRESS));
    expect(staticData.governor).toEqual(address(EXPECTED_GOVERNOR_ADDRESS));
    expect(roles.approver).toEqual(address(EXPECTED_APPROVER_ADDRESS));
    expect(roles.halter).toEqual(address(EXPECTED_HALTER_ADDRESS));
}

fun loadFromDataCell(data: cell): LoadedTonstakersValidatorControllerStorage {
    val storage = TonstakersValidatorControllerStorage.fromCell(data);
    val staticData = storage.staticData.load();
    val roles = staticData.roles.load();
    return LoadedTonstakersValidatorControllerStorage { data, storage, staticData, roles };
}

fun loadTonstakersValidatorControllerStorageFromFork(
    controller: TonstakersValidatorControllerFork,
): LoadedTonstakersValidatorControllerStorage {
    val account = testing.getAccountState(controller.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("TonstakersValidatorController", CODE_FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return loadFromDataCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Tonstakers Validator Controller mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Tonstakers Validator Controller mainnet fixture account is frozen");
        }
    }
}

fun controllerData(
    controller: TonstakersValidatorControllerFork,
): TonstakersValidatorControllerDataReply {
    return net.runGetMethod(controller.address, "get_validator_controller_data");
}

fun maxPunishment(controller: TonstakersValidatorControllerFork, stake: int): coins {
    return net.runGetMethod(controller.address, "get_max_punishment", [stake]);
}

fun maxStakeValue(controller: TonstakersValidatorControllerFork): int {
    return net.runGetMethod(controller.address, "get_max_stake_value");
}

fun requiredBalanceForLoan(
    controller: TonstakersValidatorControllerFork,
    credit: coins,
    interest: uint24,
): TonstakersValidatorControllerRequiredBalanceForLoanReply {
    return net.runGetMethod(controller.address, "required_balance_for_loan", [credit, interest]);
}

fun requestWindowTime(
    controller: TonstakersValidatorControllerFork,
): TonstakersValidatorControllerRequestWindowTimeReply {
    return net.runGetMethod(controller.address, "request_window_time");
}

fun expectControllerGetDataMatchesStorage(
    data: TonstakersValidatorControllerDataReply,
    loaded: LoadedTonstakersValidatorControllerStorage,
): void {
    val storage = loaded.storage;

    expect(data.state).toEqual(storage.state);
    expect(data.halted).toEqual(storage.halted);
    expect(data.approved).toEqual(storage.approved);
    expect(data.stakeAmountSent).toEqual(storage.stakeAmountSent);
    expect(data.stakeAt).toEqual(storage.stakeAt);
    expect(data.savedValidatorSetHash).toEqual(storage.savedValidatorSetHash);
    expect(data.validatorSetChangesCount).toEqual(storage.validatorSetChangesCount);
    expect(data.validatorSetChangeTime).toEqual(storage.validatorSetChangeTime);
    expect(data.stakeHeldFor).toEqual(storage.stakeHeldFor);
    expect(data.borrowedAmount).toEqual(storage.borrowedAmount);
    expect(data.borrowingTime).toEqual(storage.borrowingTime);
    expect(data.validator.castToInternal()).toEqual(loaded.staticData.validator);
    expect(data.pool.castToInternal()).toEqual(loaded.staticData.pool);
    expectAnyAddressEqualsNullable(data.sudoer, storage.sudoer);
}

get fun `test tonstakers validator controller code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("TonstakersValidatorController", CODE_FIXTURE_BOC_PATH).hash()).toEqual(
        EXPECTED_CODE_HASH,
    );
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test tonstakers validator controller saved data fixture parses storage`() {
    val loaded = loadFromDataCell(dataFixtureCell());

    expect(loaded.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expectStableStorageFields(loaded);

    println("TONSTAKERS_CONTROLLER_DATA_FIXTURE_STORAGE={}", loaded.storage);
    println("TONSTAKERS_CONTROLLER_DATA_FIXTURE_STATIC={}", loaded.staticData);
}

get fun `test tonstakers validator controller mainnet storage and getters`() {
    val controller = mainnetController();
    val loaded = loadTonstakersValidatorControllerStorageFromFork(controller);
    val data = controllerData(controller);
    val punishment = maxPunishment(controller, 50000 * 1000000000);
    val stakeValue = maxStakeValue(controller);
    val loanBalance = requiredBalanceForLoan(controller, EXPECTED_MAX_LOAN, EXPECTED_MAX_INTEREST);
    val window = requestWindowTime(controller);

    expect(scripts.isContractDeployed(controller.address)).toBeTrue();
    expectStableStorageFields(loaded);
    expectControllerGetDataMatchesStorage(data, loaded);

    expect(data.state).toEqual(0);
    expect(data.halted).toBeFalse();
    expect(data.approved).toBeTrue();
    expect(data.stakeAmountSent).toEqual(0);
    expect(data.stakeAt).toEqual(0);
    expect(data.validator.castToInternal()).toEqual(address(EXPECTED_VALIDATOR_ADDRESS));
    expect(data.pool.castToInternal()).toEqual(address(EXPECTED_POOL_ADDRESS));
    expect(data.sudoer).toBeNoneAddress();

    expect(punishment).toBeGreater(0);
    expect(stakeValue).toBeGreaterOrEqual(-1);
    expect(loanBalance.requiredBalance).toBeGreater(0);
    expect(loanBalance.validatorAmount).toBeGreater(0);
    expect(window.since).toEqual(EXPECTED_REQUEST_WINDOW_SINCE);
    expect(window.until).toEqual(EXPECTED_REQUEST_WINDOW_UNTIL);

    println("TONSTAKERS_CONTROLLER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONSTAKERS_CONTROLLER_ADDRESS={}", controller.address);
    println("TONSTAKERS_CONTROLLER_DATA_HASH={}", loaded.data.hash());
    println("TONSTAKERS_CONTROLLER_STORAGE={}", loaded.storage);
    println("TONSTAKERS_CONTROLLER_GET_DATA={}", data);
    println("TONSTAKERS_CONTROLLER_REQUEST_WINDOW={}", window);
}
