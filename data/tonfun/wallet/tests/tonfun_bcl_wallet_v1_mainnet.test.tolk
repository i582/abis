import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonfun_bcl_wallet_common.types"
import "../wrappers/TonFunBclWalletV1.gen"

const FIXTURE_BOC_PATH = "data/tonfun/wallet/testdata/TonFunBclWalletV1.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonfun/wallet/testdata/TonFunBclWalletV1.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9db2219b2f2aaf9a29122a1163fa342c74dda4c87927a9b23efb789c288db857
const EXPECTED_DATA_HASH = 0x44761bc7a00da2c05db191422733134ed00b52f9e091d6a81c45a20a6bfddd66
const EXPECTED_BALANCE = 588005449713604
const PINNED_MAINNET_BLOCK = 41153367
const WALLET_ADDRESS = "EQD6YuwVisup4eCrh41COcRx0va2_ZXc-bGQ0JG0Ca9WCwIx"
const OWNER_ADDRESS = "EQDv9OXOdUlsgU2hpZRPDmPCzY66tk4GqhTQ9Snk8LnEnQxb"
const MASTER_ADDRESS = "EQCp7EwWd8_EJCF3YBvLXtB_KxBsUxopfLmPs_F3i_HGK25a"

struct LoadedTonFunBclWalletV1Storage {
    data: cell
    storage: TonFunBclWalletStorage
}

fun wallet(): TonFunBclWalletV1 {
    return TonFunBclWalletV1.fromAddress(address(WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStorageFromFork(contract: TonFunBclWalletV1): LoadedTonFunBclWalletV1Storage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TonFunBclWalletV1", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(
                build("TonFunBclWalletV1Data", DATA_FIXTURE_BOC_PATH).hash(),
            );
            return LoadedTonFunBclWalletV1Storage {
                data: data!,
                storage: TonFunBclWalletStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => Assert.fail("TonFun BCL Wallet V1 is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("TonFun BCL Wallet V1 is frozen at the pinned block"),
    }
}

get fun `test tonfun bcl wallet v1 exact code and data fixtures`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("TonFunBclWalletV1", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);

    val data = build("TonFunBclWalletV1Data", DATA_FIXTURE_BOC_PATH);
    val storage = TonFunBclWalletStorage.fromCell(data);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.status).toEqual(0);
    expect(storage.balance).toEqual(EXPECTED_BALANCE);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(address(MASTER_ADDRESS));
}

get fun `test tonfun bcl wallet v1 pinned storage and getters`() {
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

    println("TONFUN_BCL_WALLET_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
