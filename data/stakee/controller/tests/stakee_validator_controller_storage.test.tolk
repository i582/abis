import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/stakee_validator_controller.types"

const CODE_FIXTURE_BOC_PATH = "data/stakee/controller/testdata/StakeeValidatorController.boc"
const DATA_FIXTURE_BOC_PATH = "data/stakee/controller/testdata/StakeeValidatorController.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x073d70653ae8ea8e4d30679a52a227a72ff06c36edbfd74c4d9cb228ff0b0f1b
const EXPECTED_VALIDATOR = "kf-jsqsCp82dEbxMnZCGuXmM5FinQCk5JgRK69LpGnhQMekw"
const EXPECTED_POOL = "0:F6FF877DD4CE1355B101572045F09D54C29309737EB52CA542CFA6C195F7CC5B"
const EXPECTED_GOVERNOR = "0:DBB056B1C99111A8C55F792E012351255329E88145CCEB6F80AAE4DB87BD4230"
const EXPECTED_ROLE = "kQBB44emfOH7kH1vZGqcqsvwHpU8kV4i1YqAy1Gk7Y6Wrt07"

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test stakee validator controller code and data fixtures are real BoCs`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("StakeeValidatorControllerData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test stakee validator controller parses saved mainnet storage fixture`() {
    val data = build("StakeeValidatorControllerData", DATA_FIXTURE_BOC_PATH);
    val storage = StakeeValidatorControllerStorage.fromCell(data);
    val staticData = storage.staticData.load();
    val roles = staticData.roles.load();

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.state).toEqual(3);
    expect(storage.halted).toBeFalse();
    expect(storage.approved).toBeTrue();
    expect(storage.stakeAmountSent).toEqual(1001640153117506);
    expect(storage.stakeAt).toEqual(1780895496);
    expect(storage.validatorSetChangesCount).toEqual(1);
    expect(storage.validatorSetChangeTime).toEqual(1780895803);
    expect(storage.stakeHeldFor).toEqual(32768);
    expect(storage.borrowedAmount).toEqual(1000699102878570);
    expect(storage.borrowingTime).toEqual(1780863984);
    expect(storage.sudoer).toBeNull();
    expect(storage.sudoerSetAt).toEqual(0);
    expect(storage.maxExpectedInterest).toEqual(0);
    expect(staticData.controllerId).toEqual(0);
    expect(staticData.validator).toEqual(address(EXPECTED_VALIDATOR));
    expect(staticData.pool).toEqual(address(EXPECTED_POOL));
    expect(staticData.governor).toEqual(address(EXPECTED_GOVERNOR));
    expect(roles.approver).toEqual(address(EXPECTED_ROLE));
    expect(roles.halter).toEqual(address(EXPECTED_ROLE));
}
