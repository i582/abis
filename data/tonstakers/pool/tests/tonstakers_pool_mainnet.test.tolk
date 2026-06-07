import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonstakers_pool.types"
import "../wrappers/TonstakersPool.gen"

const FIXTURE_BOC_PATH = "data/tonstakers/pool/testdata/TonstakersPool.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonstakers/pool/testdata/TonstakersPool.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x192535677eed65c20ac387efe4dd7415ad9ebb9349103e87c60e592538c9dcf3
const EXPECTED_DATA_HASH = 0xe65fd297607edec4e09545f07fdf6b7cbebd33228fb8ceae86d2fb79469952d4
const PINNED_MAINNET_BLOCK = 71635640

const MAINNET_TONSTAKERS_POOL_ADDRESS = "EQCkWxfyhAkim3g2DjKQQg8T5P4g-Q1-K_jErGcDJZ4i-vqR"
const MAINNET_SAMPLE_VALIDATOR_ADDRESS = "0:0A2A9F5AFCF4A7F70758CDB62EA64302A8991A6E974C489570133746ADB6135B"
const MAINNET_SAMPLE_VALIDATOR_HASH = 0x0A2A9F5AFCF4A7F70758CDB62EA64302A8991A6E974C489570133746ADB6135B

struct LoadedTonstakersPoolStorage {
    data: cell
    storage: TonstakersPoolStorage
    mintersData: TonstakersPoolMintersData
    roundsData: TonstakersPoolRoundsData
    currentRound: TonstakersPoolRoundData
    prevRound: TonstakersPoolRoundData
    roles: TonstakersPoolRoles
    roleTail: TonstakersPoolRoleTail
    codes: TonstakersPoolCodes
}

fun mainnetTonstakersPool(): TonstakersPool {
    return TonstakersPool.fromAddress(address(MAINNET_TONSTAKERS_POOL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun signedCoinsToInt(value: TonstakersPoolSignedCoins): int {
    if (value.negative) {
        return 0 - value.amount;
    }
    return value.amount;
}

fun expectRoundReplyMatchesStorage(reply: tuple, storage: TonstakersPoolRoundData): void {
    expect(reply.get(1) as int).toEqual(storage.roundId);
    expect(reply.get(2) as int).toEqual(storage.activeBorrowers);
    expect(reply.get(3) as int).toEqual(storage.borrowed);
    expect(reply.get(4) as int).toEqual(storage.expected);
    expect(reply.get(5) as int).toEqual(storage.returned);
    expect(reply.get(6) as int).toEqual(signedCoinsToInt(storage.profit));
    if (storage.activeBorrowers == 0) {
        expect(storage.borrowersDict.isEmpty()).toBeTrue();
    } else {
        expect((reply.get(0) as cell).hash()).toBeGreater(0);
        expect(storage.borrowersDict.isEmpty()).toBeFalse();
    }
    expect(storage.borrowersDict).toHaveLength(storage.activeBorrowers);
}

fun expectGetterPayoutMatchesStorage(
    payout: TonstakersPoolMaybePayout,
    getterAddress: address?,
    getterAmount: int,
): void {
    match (payout) {
        TonstakersPoolPayoutAbsent => {
            expect(getterAddress).toBeNull();
            expect(getterAmount).toEqual(0);
        }
        TonstakersPoolPayoutInline => {
            expect(getterAddress).toEqual(payout.payoutAddress);
            expect(getterAmount).toEqual(payout.requestedAmount);
        }
        TonstakersPoolPayoutRef => {
            val loaded = payout.payout.load();
            expect(getterAddress).toEqual(loaded.payoutAddress);
            expect(getterAmount).toEqual(loaded.requestedAmount);
        }
    }
}

fun loadTonstakersPoolStorageFromDataFixture(): LoadedTonstakersPoolStorage {
    val rawBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val data = build("TonstakersPoolData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    val storage = TonstakersPoolStorage.fromCell(data);
    val mintersData = storage.mintersData.load();
    val roundsData = storage.rounds.load();
    val roles = storage.roles.load();
    return LoadedTonstakersPoolStorage {
        data,
        storage,
        mintersData,
        roundsData,
        currentRound: roundsData.currentRoundBorrowers.load(),
        prevRound: roundsData.prevRoundBorrowers.load(),
        roles,
        roleTail: roles.tail.load(),
        codes: storage.codes.load(),
    };
}

fun loadTonstakersPoolStorageFromFork(pool: TonstakersPool): LoadedTonstakersPoolStorage {
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
            expect(code!.hash()).toEqual(build("TonstakersPool", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            val storage = TonstakersPoolStorage.fromCell(data!);
            val mintersData = storage.mintersData.load();
            val roundsData = storage.rounds.load();
            val roles = storage.roles.load();
            return LoadedTonstakersPoolStorage {
                data: data!,
                storage,
                mintersData,
                roundsData,
                currentRound: roundsData.currentRoundBorrowers.load(),
                prevRound: roundsData.prevRoundBorrowers.load(),
                roles,
                roleTail: roles.tail.load(),
                codes: storage.codes.load(),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Tonstakers Pool mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Tonstakers Pool mainnet fixture account is frozen");
        }
    }
}

fun expectTonstakersPoolGettersMatchStorage(
    pool: TonstakersPool,
    loaded: LoadedTonstakersPoolStorage,
): void {
    val storage = loaded.storage;
    val minters = loaded.mintersData;
    val roles = loaded.roles;
    val roleTail = loaded.roleTail;
    val codes = loaded.codes;
    val rawFullData = pool.getPoolFullDataRaw();
    val fullData = pool.getPoolFullData();
    val loan = pool.getLoan(0, address(MAINNET_SAMPLE_VALIDATOR_ADDRESS), false, false);
    val controllerAddress = pool.getControllerAddress(0, address(MAINNET_SAMPLE_VALIDATOR_ADDRESS));
    val legacyControllerAddress = pool.getControllerAddressLegacy(
        0,
        0,
        MAINNET_SAMPLE_VALIDATOR_HASH,
    );
    val calculatedLoan = pool.calculateLoanAmount(0, 1000000000, rawFullData.interestRate);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expect(rawFullData.state).toEqual(storage.state);
    expect(rawFullData.halted).toEqual(storage.halted);
    expect(rawFullData.totalBalance).toEqual(storage.totalBalance);
    expect(rawFullData.interestRate).toEqual(storage.interestRate);
    expect(rawFullData.optimisticDepositWithdrawals).toEqual(storage.optimisticDepositWithdrawals);
    expect(rawFullData.depositsOpen).toEqual(storage.depositsOpen);
    expect(rawFullData.savedValidatorSetHash).toEqual(storage.savedValidatorSetHash);
    expectRoundReplyMatchesStorage(rawFullData.prevRoundBorrowers, loaded.prevRound);
    expectRoundReplyMatchesStorage(rawFullData.currentRoundBorrowers, loaded.currentRound);
    expect(rawFullData.minLoanPerValidator).toEqual(storage.minLoanPerValidator);
    expect(rawFullData.maxLoanPerValidator).toEqual(storage.maxLoanPerValidator);
    expect(rawFullData.governanceFee).toEqual(storage.governanceFee);
    expect(rawFullData.jettonMinter).toEqual(minters.jettonMinter);
    expect(rawFullData.supply).toEqual(minters.supply);
    expectGetterPayoutMatchesStorage(
        minters.depositPayout,
        rawFullData.depositPayout,
        rawFullData.requestedForDeposit,
    );
    expectGetterPayoutMatchesStorage(
        minters.withdrawalPayout,
        rawFullData.withdrawalPayout,
        rawFullData.requestedForWithdrawal,
    );
    expect(rawFullData.sudoer).toEqual(roles.sudoer);
    expect(rawFullData.sudoerSetAt).toEqual(roles.sudoerSetAt);
    expect(rawFullData.governor).toEqual(roles.governor);
    expect(rawFullData.governorUpdateAfter).toEqual(roles.governorUpdateAfter);
    expect(rawFullData.interestManager).toEqual(roles.interestManager);
    expect(rawFullData.halter).toEqual(roleTail.halter);
    expect(rawFullData.approver).toEqual(roleTail.approver);
    expect(rawFullData.controllerCode.hash()).toEqual(codes.controllerCode.hash());
    expect(rawFullData.poolJettonWalletCode.hash()).toEqual(codes.poolJettonWalletCode.hash());
    expect(rawFullData.payoutMinterCode.hash()).toEqual(codes.payoutMinterCode.hash());

    expect(fullData.supply).toEqual(rawFullData.supply);
    expect(fullData.jettonMinter).toEqual(rawFullData.jettonMinter);
    expect(loan.borrowedAmount).toBeGreaterOrEqual(0);
    expect(loan.accountedInterest).toBeGreaterOrEqual(0);
    expect((controllerAddress as any_address).castToInternal()).toEqual(controllerAddress);
    expect(legacyControllerAddress.workchain).toEqual(-1);
    expect(legacyControllerAddress.addressHash).toBeGreater(0);
    expect(calculatedLoan).toBeGreaterOrEqual(-1);
}

get fun `test tonstakers pool local code and data bocs are real and hash verified`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val code = build("TonstakersPool", FIXTURE_BOC_PATH);
    val loaded = loadTonstakersPoolStorageFromDataFixture();
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(loaded.data.hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test tonstakers pool mainnet storage and getters`() {
    val pool = mainnetTonstakersPool();
    val loaded = loadTonstakersPoolStorageFromFork(pool);

    expectTonstakersPoolGettersMatchStorage(pool, loaded);

    println("TONSTAKERS_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONSTAKERS_POOL_ADDRESS={}", pool.address);
    println("TONSTAKERS_POOL_STORAGE={}", loaded.storage);
    println("TONSTAKERS_POOL_MINTERS_DATA={}", loaded.mintersData);
    println("TONSTAKERS_POOL_CURRENT_ROUND={}", loaded.currentRound);
    println("TONSTAKERS_POOL_PREV_ROUND={}", loaded.prevRound);
    println("TONSTAKERS_POOL_RAW_FULL_DATA={}", pool.getPoolFullDataRaw());
}
