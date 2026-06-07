import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_treasury.types"
import "../wrappers/HipoTreasury.gen"

const FIXTURE_BOC_PATH = "data/hipo/treasury/testdata/HipoTreasury.boc"
const FIXTURE_DATA_BOC_PATH = "data/hipo/treasury/testdata/HipoTreasury.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x234682616b70138cb6d55be146ac0456ba79c2fad788f224b63058ddb5057bf2
const EXPECTED_DATA_HASH = 0x65308cacc3b71a597d3b2c3c6d263ab13ef45533b37d36ecc85a68b00282a873
const EXPECTED_TOTAL_COINS = 0x2d81b55a4c51d
const EXPECTED_TOTAL_TOKENS = 0x28a7f1897c1ad
const EXPECTED_TOTAL_UNSTAKING = 0x493872800
const EXPECTED_ROUNDS_IMBALANCE = 0xff
const EXPECTED_PREVIOUS_RATE = 0x42ad4d41
const EXPECTED_CURRENT_RATE = 0x42b74e1f
const EXPECTED_CURRENT_ROUND_SINCE = 1780764424
const EXPECTED_MAX_BURNABLE_TOKENS = -8934080690
const PINNED_MAINNET_BLOCK = 71622046

const MAINNET_HIPO_TREASURY_ADDRESS = "EQCLyZHP4Xe8fpchQz76O-_RmUhaVc_9BAoGyJrwJrcbz2eZ"
const MAINNET_HIPO_PARENT_ADDRESS = "0:CF76AF318C0872B58A9F1925FC29C156211782B9FB01F56760D292E56123BF87"

struct LoadedHipoTreasuryStorage {
    data: cell
    storage: HipoTreasuryStorage
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun mainnetHipoTreasury(): HipoTreasury {
    return HipoTreasury.fromAddress(address(MAINNET_HIPO_TREASURY_ADDRESS));
}

fun loadHipoTreasuryStorageFromFork(treasury: HipoTreasury): LoadedHipoTreasuryStorage {
    val account = testing.getAccountState(treasury.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("HipoTreasury", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedHipoTreasuryStorage {
                data: data!,
                storage: HipoTreasuryStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Expected active Hipo Treasury account, got uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Expected active Hipo Treasury account, got frozen");
        }
    }
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun expectTreasuryStateMatchesStorage(
    treasury: HipoTreasury,
    loaded: LoadedHipoTreasuryStorage,
): void {
    val storage = loaded.storage;
    val extension = storage.extension.load();
    val state = treasury.getTreasuryState();
    val times = treasury.getTimes();
    val fees = treasury.getTreasuryFees(1);
    val maxBurnableTokens = treasury.getMaxBurnableTokens();
    val surplus = treasury.getSurplus();
    val maxPunishment = treasury.getMaxPunishment(ton("1"));

    expect(scripts.isContractDeployed(treasury.address)).toBeTrue();
    expect(storage.totalCoins).toEqual(EXPECTED_TOTAL_COINS);
    expect(storage.totalTokens).toEqual(EXPECTED_TOTAL_TOKENS);
    expect(storage.totalStaking).toEqual(0);
    expect(storage.totalUnstaking).toEqual(EXPECTED_TOTAL_UNSTAKING);
    expect(storage.totalBorrowersStake).toEqual(0);
    expect(storage.roundsImbalance).toEqual(EXPECTED_ROUNDS_IMBALANCE);
    expect(storage.stopped).toBeFalse();
    expect(storage.instantMint).toBeTrue();
    expect(storage.parent).toBeNotNull();
    expect(storage.parent!).toEqual(address(MAINNET_HIPO_PARENT_ADDRESS));

    expect(extension.previousRate).toEqual(EXPECTED_PREVIOUS_RATE);
    expect(extension.currentRate).toEqual(EXPECTED_CURRENT_RATE);
    expectInternalAddress(extension.halter);
    expectInternalAddress(extension.governor);
    expect(storage.loanCodes.hash()).toBeGreater(0);
    expect(extension.collectionCodes.hash()).toBeGreater(0);
    expect(extension.billCodes.hash()).toBeGreater(0);

    expect(state.totalCoins).toEqual(storage.totalCoins);
    expect(state.totalTokens).toEqual(storage.totalTokens);
    expect(state.totalStaking).toEqual(storage.totalStaking);
    expect(state.totalUnstaking).toEqual(storage.totalUnstaking);
    expect(state.totalBorrowersStake).toEqual(storage.totalBorrowersStake);
    expect(state.parent.castToInternal()).toEqual(storage.parent!);
    expect(state.roundsImbalance).toEqual(storage.roundsImbalance);
    expect(state.stopped).toEqual(storage.stopped);
    expect(state.instantMint).toEqual(storage.instantMint);
    expect(state.loanCodes.hash()).toEqual(storage.loanCodes.hash());
    expect(state.previousRate).toEqual(extension.previousRate);
    expect(state.currentRate).toEqual(extension.currentRate);
    expect(state.halter).toEqual(extension.halter);
    expect(state.governor).toEqual(extension.governor);
    expect(state.governanceFee).toEqual(extension.governanceFee);
    expect(state.collectionCodes.hash()).toEqual(extension.collectionCodes.hash());
    expect(state.billCodes.hash()).toEqual(extension.billCodes.hash());

    expect(times.currentRoundSince).toBeGreater(0);
    expect(times.participateSince).toBeGreater(0);
    expect(times.participateUntil).toBeGreater(times.participateSince);
    expect(times.nextRoundSince).toBeGreater(times.currentRoundSince);
    expect(times.nextRoundUntil).toBeGreater(times.nextRoundSince);
    expect(times.stakeHeldFor).toBeGreater(0);

    expect(fees.requestLoanFee).toBeGreater(0);
    expect(fees.depositCoinsFee).toBeGreater(0);
    expect(fees.unstakeAllTokensFee).toBeGreater(0);
    expect(maxBurnableTokens).toEqual(EXPECTED_MAX_BURNABLE_TOKENS);
    expect(maxPunishment).toBeGreater(0);

    println("HIPO_TREASURY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("HIPO_TREASURY_STORAGE={}", storage);
    println("HIPO_TREASURY_EXTENSION={}", extension);
    println("HIPO_TREASURY_STATE={}", state);
    println("HIPO_TREASURY_TIMES={}", times);
    println("HIPO_TREASURY_FEES={}", fees);
    println("HIPO_TREASURY_MAX_BURNABLE_TOKENS={}", maxBurnableTokens);
    println("HIPO_TREASURY_SURPLUS={}", surplus);
    println("HIPO_TREASURY_MAX_PUNISHMENT_1_TON={}", maxPunishment);
}

get fun `test hipo treasury code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(FIXTURE_DATA_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("HipoTreasury", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test hipo treasury parses live fork storage and getters`() {
    val treasury = mainnetHipoTreasury();
    val loaded = loadHipoTreasuryStorageFromFork(treasury);
    expectTreasuryStateMatchesStorage(treasury, loaded);
}
