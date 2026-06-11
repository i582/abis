import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stakee_pool.types"
import "../wrappers/StakeePool.gen"

const CODE_FIXTURE_BOC_PATH = "data/stakee/pool/testdata/StakeePool.boc"
const DATA_FIXTURE_BOC_PATH = "data/stakee/pool/testdata/StakeePool.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x192535677eed65c20ac387efe4dd7415ad9ebb9349103e87c60e592538c9dcf3
const EXPECTED_DATA_HASH = 0xf4b28094a751816024a368acc3f1e079238326cc36c67d2d22945ac7598ed522

const EXPECTED_MINTER = "0:AA0BA121449FEDA569E02B12FA755D24E834A7454AECF4649590B6DF742AAC8F"
const EXPECTED_WITHDRAWAL_PAYOUT = "0:28BF64ED4FE71C32CBCBCFFCA1524A74315E4C1B62747CAC76AB1FF1BBDAD771"
const EXPECTED_SUDOER = "0:DBB056B1C99111A8C55F792E012351255329E88145CCEB6F80AAE4DB87BD4230"
const EXPECTED_INTEREST_MANAGER = "0:FD7BF2264EA4B58B2F5C18A1D15215025A36CF7F815DD615B01333AA401FCA3D"
const EXPECTED_HALTER = "kQBB44emfOH7kH1vZGqcqsvwHpU8kV4i1YqAy1Gk7Y6Wrt07"

struct LoadedStakeePoolStorage {
    data: cell
    storage: StakeePoolStorage
    minters: StakeePoolMintersData
    currentRound: StakeePoolRoundData
    prevRound: StakeePoolRoundData
    roles: StakeePoolRoles
    roleTail: StakeePoolRoleTail
    codes: StakeePoolCodes
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStakeePoolStorage(): LoadedStakeePoolStorage {
    val data = build("StakeePoolData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = StakeePoolStorage.fromCell(data);
    val minters = storage.mintersData.load();
    val rounds = storage.rounds.load();
    val roles = storage.roles.load();
    return LoadedStakeePoolStorage {
        data,
        storage,
        minters,
        currentRound: rounds.currentRoundBorrowers.load(),
        prevRound: rounds.prevRoundBorrowers.load(),
        roles,
        roleTail: roles.tail.load(),
        codes: storage.codes.load(),
    };
}

fun expectDepositPayoutAbsent(payout: StakeePoolMaybePayout): void {
    match (payout) {
        StakeePoolPayoutAbsent => {}
        StakeePoolPayoutInline => {
            expect(false).toBeTrue();
        }
        StakeePoolPayoutRef => {
            expect(false).toBeTrue();
        }
    }
}

fun expectWithdrawalPayoutInline(payout: StakeePoolMaybePayout): void {
    match (payout) {
        StakeePoolPayoutInline => {
            expect(payout.payoutAddress).toEqual(address(EXPECTED_WITHDRAWAL_PAYOUT));
            expect(payout.requestedAmount).toEqual(1351194863093);
        }
        StakeePoolPayoutAbsent => {
            expect(false).toBeTrue();
        }
        StakeePoolPayoutRef => {
            expect(false).toBeTrue();
        }
    }
}

get fun `test stakee pool code and data fixtures are real BoCs`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("StakeePool", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("StakeePoolData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test stakee pool parses saved mainnet storage fixture`() {
    val loaded = loadStakeePoolStorage();
    val storage = loaded.storage;
    val minters = loaded.minters;

    expect(storage.state).toEqual(0);
    expect(storage.halted).toBeFalse();
    expect(storage.totalBalance).toEqual(16228036533964673);
    expect(storage.interestRate).toEqual(11875);
    expect(storage.optimisticDepositWithdrawals).toBeTrue();
    expect(storage.depositsOpen).toBeTrue();
    expect(storage.minLoanPerValidator).toEqual(10000000000000);
    expect(storage.maxLoanPerValidator).toEqual(1000000000000000);
    expect(storage.governanceFee).toEqual(3187671);

    expect(minters.jettonMinter).toEqual(address(EXPECTED_MINTER));
    expect(minters.supply).toEqual(14588975584039280);
    expectDepositPayoutAbsent(minters.depositPayout);
    expectWithdrawalPayoutInline(minters.withdrawalPayout);

    expect(loaded.currentRound.roundId).toEqual(1225);
    expect(loaded.currentRound.activeBorrowers).toEqual(7);
    expect(loaded.currentRound.borrowed).toEqual(7000000000000000);
    expect(loaded.currentRound.expected).toEqual(7004893720149990);
    expect(loaded.currentRound.returned).toEqual(0);
    expect(loaded.currentRound.profit.amount).toEqual(0);
    expect(loaded.currentRound.profit.negative).toBeFalse();
    expect(loaded.currentRound.borrowersDict).toHaveLength(7);

    expect(loaded.prevRound.roundId).toEqual(1224);
    expect(loaded.prevRound.activeBorrowers).toEqual(7);
    expect(loaded.prevRound.borrowed).toEqual(7000000000000000);
    expect(loaded.prevRound.expected).toEqual(7004883706569665);
    expect(loaded.prevRound.returned).toEqual(0);
    expect(loaded.prevRound.profit.amount).toEqual(0);
    expect(loaded.prevRound.profit.negative).toBeFalse();
    expect(loaded.prevRound.borrowersDict).toHaveLength(7);

    expect(loaded.roles.sudoer).toEqual(address(EXPECTED_SUDOER));
    expect(loaded.roles.sudoerSetAt).toEqual(0);
    expect(loaded.roles.governor).toEqual(address(EXPECTED_SUDOER));
    expect(loaded.roles.governorUpdateAfter).toEqual(281474976710655);
    expect(loaded.roles.interestManager).toEqual(address(EXPECTED_INTEREST_MANAGER));
    expect(loaded.roleTail.halter).toEqual(address(EXPECTED_HALTER));
    expect(loaded.roleTail.approver).toEqual(address(EXPECTED_HALTER));

    expect(loaded.codes.controllerCode.hash()).toEqual(
        0xdd3ce98db487c7585803933bffba7a57eb4e663099059d08b83db0b4ce060793,
    );
    expect(loaded.codes.poolJettonWalletCode.hash()).toEqual(
        0x89621dd77e0a9a4ae44279e592f13d6ab5c55decd60cc9ec36b7c2ae40d1595,
    );
    expect(loaded.codes.payoutMinterCode.hash()).toEqual(
        0x06174e58f067ca46c87fa65efe574ea0becb217cda36e351f4a979370d720ee2,
    );

    println("STAKEE_POOL_STORAGE={}", storage);
    println("STAKEE_POOL_MINTERS={}", minters);
    println("STAKEE_POOL_CURRENT_ROUND={}", loaded.currentRound);
}

get fun `test stakee pool local wrapper full-data decodes borrower maps`() {
    val loaded = loadStakeePoolStorage();
    val pool = StakeePool.fromStorage(loaded.storage);
    val deployer = testing.treasury("stakee-pool-storage-deployer");

    pool.deploy(deployer.address, { value: ton("1"), bounce: false });
    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    val fullData = pool.getPoolFullDataRaw();
    val [currentBorrowers, currentRoundId, _, _, _, _, _] = fullData.currentRoundBorrowers;
    val [prevBorrowers, prevRoundId, _, _, _, _, _] = fullData.prevRoundBorrowers;
    expect(currentRoundId).toEqual(loaded.currentRound.roundId as int);
    expect(currentBorrowers).toHaveLength(
        loaded.currentRound.activeBorrowers as int,
    );
    expect(prevRoundId).toEqual(loaded.prevRound.roundId as int);
    expect(prevBorrowers).toHaveLength(
        loaded.prevRound.activeBorrowers as int,
    );

    println("STAKEE_POOL_FULL_DATA={}", fullData);
}
