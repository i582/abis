import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonfun_bcl_wallet_common.types"
import "../wrappers/TonFunBclWalletV2.gen"

const FIXTURE_BOC_PATH = "data/tonfun/wallet/testdata/TonFunBclWalletV2.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonfun/wallet/testdata/TonFunBclWalletV2.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x226830546dc9ab1687dc72bc8a5edcc60210391a7c60698c4fe226618d778d68
const EXPECTED_DATA_HASH = 0xa9a91f60a325ee7350ea588e658a6e7a018b7548b3c4f355c6a1e15e003f29b8
const EXPECTED_BALANCE = 42194401239445
const PINNED_MAINNET_BLOCK = 42790177
const WALLET_ADDRESS = "EQBuUZeNbRdzvKKN8nZFd2Auu_6f03AXl4rvzFo2vTPmx60Q"
const OWNER_ADDRESS = "EQCFQ00GPLirirqQnRZlH7R4ivnfhGQaFphUi8FPRC2nuVux"
const MASTER_ADDRESS = "EQDHwuXHUgH3KTfkMjl-d7-l5FC0T4BS0tZGW9QMkwkol7m1"

struct LoadedTonFunBclWalletV2Storage {
    data: cell
    storage: TonFunBclWalletStorage
}

fun wallet(): TonFunBclWalletV2 {
    return TonFunBclWalletV2.fromAddress(address(WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStorageFromFork(contract: TonFunBclWalletV2): LoadedTonFunBclWalletV2Storage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TonFunBclWalletV2", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(
                build("TonFunBclWalletV2Data", DATA_FIXTURE_BOC_PATH).hash(),
            );
            return LoadedTonFunBclWalletV2Storage {
                data: data!,
                storage: TonFunBclWalletStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => Assert.fail("TonFun BCL Wallet V2 is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("TonFun BCL Wallet V2 is frozen at the pinned block"),
    }
}

get fun `test tonfun bcl wallet v2 exact code and data fixtures`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("TonFunBclWalletV2", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);

    val data = build("TonFunBclWalletV2Data", DATA_FIXTURE_BOC_PATH);
    val storage = TonFunBclWalletStorage.fromCell(data);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.status).toEqual(0);
    expect(storage.balance).toEqual(EXPECTED_BALANCE);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(address(MASTER_ADDRESS));
}

get fun `test tonfun bcl wallet v2 pinned storage and getters`() {
    val contract = wallet();
    val loaded = loadStorageFromFork(contract);
    val storage = loaded.storage;
    val walletData = contract.getWalletData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.status).toEqual(0);
    expect(storage.balance).toEqual(EXPECTED_BALANCE);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(address(MASTER_ADDRESS));
    expect(walletData.balance).toEqual(storage.balance);
    expect(walletData.ownerAddress).toEqual(storage.ownerAddress);
    expect(walletData.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(walletData.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(contract.getStatus()).toEqual(storage.status);
    expect(contract.getTransfersEnabled()).toBeFalse();

    println("TONFUN_BCL_WALLET_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
