import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/bemo_financial.types"
import "../wrappers/BemoFinancial.gen"

const FIXTURE_BOC_PATH = "data/bemo/financial/testdata/BemoFinancial.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x56e134340de7ad043631ffa618095badb0da8472159e9cf6421d69efdb61c2d3
const EXPECTED_UNSTAKE_REQUEST_CODE_HASH = 0x5b7a8516a9df1e8c9ffbeda43405223e3ba1696ee104465c5aa36b4a630a7e8c
const EXPECTED_COMMISSION_FACTOR = 112
const EXPECTED_LOCKUP_PERIOD = 129600
const EXPECTED_NEXT_UNSTAKE_REQUEST_INDEX = 397
const PINNED_MAINNET_BLOCK = 71622046

const MAINNET_BEMO_FINANCIAL_ADDRESS = "EQCSxGZPHqa3TtnODgMan8CEM0jf6HpY-uon_NMeFgjKqkEY"
const MAINNET_BEMO_UNSTAKE_REQUEST_ADDRESS = "EQB8if4poFsD7UKWnYIESQs2tN83Oe1CKqPAxnOeA-5O_CqF"
const MAINNET_BEMO_SAMPLE_OWNER_ADDRESS = "0:1DB686BD9086A0A565FCB51144AD0C85C9B1B92B01E3EE907C828EA89B9C99BE"
const MAINNET_BEMO_SAMPLE_WALLET_ADDRESS = "0:645BF93B9C628AD25555EE77E780D6B850CC9E73172736F2A42474A88A0F42C7"

struct LoadedBemoFinancialStorage {
    data: cell
    storage: BemoFinancialStorage
    lockupData: BemoFinancialLockupData
}

fun mainnetBemoFinancial(): BemoFinancial {
    return BemoFinancial.fromAddress(address(MAINNET_BEMO_FINANCIAL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadBemoFinancialStorageFromFork(financial: BemoFinancial): LoadedBemoFinancialStorage {
    val account = testing.getAccountState(financial.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("BemoFinancial", FIXTURE_BOC_PATH).hash());
            val storage = BemoFinancialStorage.fromCell(data!);
            return LoadedBemoFinancialStorage {
                data: data!,
                storage,
                lockupData: storage.lockupData.load(),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Bemo Financial mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Bemo Financial mainnet fixture account is frozen");
        }
    }
}

fun expectBemoFinancialGettersMatchStorage(
    financial: BemoFinancial,
    loaded: LoadedBemoFinancialStorage,
): void {
    val storage = loaded.storage;
    val lockup = loaded.lockupData;
    val fullData = financial.getFullData();
    val jettonData = financial.getJettonData();
    val walletAddress = financial.getWalletAddress(address(MAINNET_BEMO_SAMPLE_OWNER_ADDRESS));
    val unstakeRequestAddress = financial.getUnstakeRequestAddress(396);
    val lockupPeriod = financial.getLockupPeriod();

    expect(scripts.isContractDeployed(financial.address)).toBeTrue();
    expect(fullData.jettonTotalSupply).toEqual(storage.jettonTotalSupply);
    expect(fullData.tonTotalSupply).toEqual(storage.tonTotalSupply);
    expect(fullData.commissionTotalSupply).toEqual(storage.commissionTotalSupply);
    expect(fullData.commissionFactor).toEqual(storage.commissionFactor);
    expect(fullData.commissionAddress).toEqual(storage.commissionAddress);
    expect(fullData.adminAddress).toEqual(storage.adminAddress);
    expect(fullData.transactionAddress).toEqual(storage.transactionAddress);
    expect(fullData.content.hash()).toEqual(storage.content.hash());
    expect(fullData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(fullData.unstakeRequestCode.hash()).toEqual(lockup.unstakeRequestCode.hash());
    expect(fullData.lastLockupEpoch).toEqual(lockup.lastLockupEpoch);
    expect(fullData.lockupSupply).toEqual(lockup.lockupSupply);
    expect(fullData.nextLockupSupply).toEqual(lockup.nextLockupSupply);
    expect(fullData.laterLockupSupply).toEqual(lockup.laterLockupSupply);
    expect(fullData.nextUnstakeRequestIndex).toEqual(lockup.nextUnstakeRequestIndex);

    expect(jettonData.totalSupply).toEqual(storage.jettonTotalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(storage.adminAddress);
    expect(jettonData.jettonContent.hash()).toEqual(storage.content.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    expect(walletAddress).toEqual(address(MAINNET_BEMO_SAMPLE_WALLET_ADDRESS));
    expect(unstakeRequestAddress).toEqual(address(MAINNET_BEMO_UNSTAKE_REQUEST_ADDRESS));
    expect(lockupPeriod).toEqual(EXPECTED_LOCKUP_PERIOD);
    expect(storage.commissionFactor).toEqual(EXPECTED_COMMISSION_FACTOR);
    expect(lockup.nextUnstakeRequestIndex).toEqual(EXPECTED_NEXT_UNSTAKE_REQUEST_INDEX);
    expect(lockup.unstakeRequestCode.hash()).toEqual(EXPECTED_UNSTAKE_REQUEST_CODE_HASH);
}

get fun `test bemo financial code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("BemoFinancial", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test bemo financial mainnet storage and getters`() {
    val financial = mainnetBemoFinancial();
    val loaded = loadBemoFinancialStorageFromFork(financial);

    expectBemoFinancialGettersMatchStorage(financial, loaded);

    println("BEMO_FINANCIAL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("BEMO_FINANCIAL_ADDRESS={}", financial.address);
    println("BEMO_FINANCIAL_STORAGE={}", loaded.storage);
    println("BEMO_FINANCIAL_LOCKUP_DATA={}", loaded.lockupData);
    println("BEMO_FINANCIAL_FULL_DATA={}", financial.getFullData());
    println("BEMO_FINANCIAL_JETTON_DATA={}", financial.getJettonData());
}
