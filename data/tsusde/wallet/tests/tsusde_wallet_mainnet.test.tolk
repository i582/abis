import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tsusde_wallet.types"
import "../wrappers/TsusdeWallet.gen"

const CODE_FIXTURE_BOC_PATH = "data/tsusde/wallet/testdata/TsusdeWallet.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xd3624ca5def8b5d8fb3b929f6554a37f989e06b873fd49442cea94a3bd671940
const EXPECTED_DATA_HASH = 0xf27242fa57c4f7785243007b7080a7fcc6185ac72dc8eec9a21eb04dd8e7b860
const EXPECTED_BALANCE = 24564290305
const PINNED_MAINNET_BLOCK = 48269304
const WALLET_ADDRESS = "EQDjJT1i9vgNpsbctFwYCMEgtADsTfoeEnaD4QSWCUY1X8zf"
const OWNER_ADDRESS = "UQApXKTeI56uu34eRxXZT5edGMgjNsW-iMYUhCsEdOlVKVs0"
const MASTER_ADDRESS = "EQDQ5UUyPHrLcQJlPAczd_fjxn8SLrlNQwolBznxCdSlfQwr"

struct LoadedTsusdeWalletStorage {
    /// Original pinned data cell used to verify lossless storage decoding.
    data: cell
    /// Typed wallet storage decoded from the original data cell.
    storage: TsusdeWalletStorage
}

fun wallet(): TsusdeWallet {
    return TsusdeWallet.fromAddress(address(WALLET_ADDRESS));
}

fun emptyTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadWalletStorageFromFork(contract: TsusdeWallet): LoadedTsusdeWalletStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TsusdeWallet", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedTsusdeWalletStorage {
                data: data!,
                storage: TsusdeWalletStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("tsUSDe wallet is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("tsUSDe wallet is frozen at the pinned block");
        }
    }
}

get fun `test tsusde wallet code fixture matches live code hash`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("TsusdeWallet", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tsusde wallet parses pinned storage and all getters`() {
    val contract = wallet();
    val loaded = loadWalletStorageFromFork(contract);
    val storage = loaded.storage;
    val walletData = contract.getWalletData();
    val timelockData = contract.getTimelockData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.status).toEqual(0);
    expect(storage.balance).toEqual(EXPECTED_BALANCE);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(address(MASTER_ADDRESS));
    expect(storage.timelockedBalance).toEqual(0);
    expect(storage.timelockLimit).toEqual(0);

    expect(walletData.balance).toEqual(storage.balance);
    expect(walletData.ownerAddress).toEqual(storage.ownerAddress);
    expect(walletData.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(walletData.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(contract.getStatus()).toEqual(storage.status);
    expect(timelockData.timelockedBalance).toEqual(storage.timelockedBalance);
    expect(timelockData.timelockLimit).toEqual(storage.timelockLimit);

    println("TSUSDE_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TSUSDE_WALLET_STORAGE={}", storage);
}

get fun `test tsusde wallet accepts funding-only top up`() {
    val contract = wallet();
    val sender = testing.treasury("tsusde-wallet-top-up");
    val before = contract.getWalletData();
    val txs = contract.sendTsusdeWalletTopUp(
        sender.address,
        emptyTail(),
        { value: ton("0.01"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<TsusdeWalletTopUp>({
        from: sender.address,
        to: contract.address,
        exitCode: 0,
    });
    expect(contract.getWalletData().balance).toEqual(before.balance);
}
