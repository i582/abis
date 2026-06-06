import "@acton/emulation/testing"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_wallet.types"
import "../wrappers/HipoWallet.gen"

const FIXTURE_BOC_PATH = "data/hipo/wallet/testdata/HipoWallet.boc"
const DATA_FIXTURE_BOC_PATH = "data/hipo/wallet/testdata/HipoWallet.data.boc"
const LIVE_DATA_BOC = "te6ccgEBAQEASwAAkYAP5X1kydd61QPxdyzm5ynnAUduvhhB1qobiYJiW6wcGZADPdq8xjAhytYqfGSX8KcFWIReCufsB9Wdg0pLlYSO/h1KvRCUIsE="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x50b917d9fd5b95760993287677d04812a15aa55e6b71d0f9226ecd7c20c3d82a
const EXPECTED_DATA_HASH = 0xd88ed9704a38e70cf399f74f0d0072c2534ce8d9739fac14a8b6f073424fc8f7
const EXPECTED_TOKENS = 0x2af442508b
const EXPECTED_SEND_TOKENS_FEE = 0x240530
const EXPECTED_UNSTAKE_TOKENS_FEE = 0xb4db43
const EXPECTED_UPGRADE_WALLET_FEE = 0x366b86
const EXPECTED_WALLET_STORAGE_FEE = 0x9e996
const PINNED_MAINNET_BLOCK = 71622046

const MAINNET_HIPO_WALLET_ADDRESS = "EQBwh1XGDsEongigw0iz-s-3pkkeMrpIKioELjbmGB9BDMbo"
const EXPECTED_OWNER_ADDRESS = "0:7F2BEB264EBBD6A81F8BB96737394F380A3B75F0C20EB550DC4C1312DD60E0CC"
const EXPECTED_PARENT_ADDRESS = "0:CF76AF318C0872B58A9F1925FC29C156211782B9FB01F56760D292E56123BF87"

struct LoadedHipoWalletStorage {
    data: cell
    storage: HipoWalletStorage
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun mainnetHipoWallet(): HipoWallet {
    return HipoWallet.fromAddress(address(MAINNET_HIPO_WALLET_ADDRESS));
}

fun expectStorageFields(storage: HipoWalletStorage): void {
    expect(storage.owner).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(storage.parent).toEqual(address(EXPECTED_PARENT_ADDRESS));
    expect(storage.tokens).toEqual(EXPECTED_TOKENS);
    expect(storage.staking.isEmpty()).toBeTrue();
    expect(storage.unstaking).toEqual(0);
}

fun loadStorageFromFork(wallet: HipoWallet): LoadedHipoWalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedHipoWalletStorage {
                data: data!,
                storage: HipoWalletStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Expected active Hipo wallet account, got uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Expected active Hipo wallet account, got frozen");
        }
    }
}

get fun `test hipo wallet local boc fixtures exist and live data boc parses storage`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val liveData = parseCellFromBase64(LIVE_DATA_BOC);
    expect(liveData.hash()).toEqual(EXPECTED_DATA_HASH);
    val storage = HipoWalletStorage.fromCell(liveData);
    expectStorageFields(storage);

    println("HIPO_WALLET_LIVE_DATA_HASH={}", liveData.hash());
    println("HIPO_WALLET_STORAGE={}", storage);
}

get fun `test hipo wallet mainnet fork storage and getters match live account data`() {
    val wallet = mainnetHipoWallet();
    val loaded = loadStorageFromFork(wallet);
    val walletData = wallet.getWalletData();
    val walletState = wallet.getWalletState();
    val walletFees = wallet.getWalletFees();

    expectStorageFields(loaded.storage);

    expect(walletData.tokens).toEqual(loaded.storage.tokens);
    expect(walletData.owner).toEqual(loaded.storage.owner);
    expect(walletData.parent).toEqual(loaded.storage.parent);
    expect(walletData.code.hash()).toEqual(EXPECTED_CODE_HASH);

    expect(walletState.tokens).toEqual(loaded.storage.tokens);
    expect(walletState.staking.isEmpty()).toEqual(loaded.storage.staking.isEmpty());
    expect(walletState.unstaking).toEqual(loaded.storage.unstaking);

    expect(walletFees.sendTokensFee).toEqual(EXPECTED_SEND_TOKENS_FEE);
    expect(walletFees.unstakeTokensFee).toEqual(EXPECTED_UNSTAKE_TOKENS_FEE);
    expect(walletFees.upgradeWalletFee).toEqual(EXPECTED_UPGRADE_WALLET_FEE);
    expect(walletFees.walletStorageFee).toEqual(EXPECTED_WALLET_STORAGE_FEE);

    println("HIPO_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("HIPO_WALLET_GET_DATA={}", walletData);
    println("HIPO_WALLET_GET_STATE={}", walletState);
    println("HIPO_WALLET_GET_FEES={}", walletFees);
}
