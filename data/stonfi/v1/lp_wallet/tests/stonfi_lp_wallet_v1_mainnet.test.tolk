import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_lp_wallet_v1.types"
import "../wrappers/StonfiLpWalletV1.gen"

const FIXTURE_BOC_PATH = "data/stonfi/v1/lp_wallet/testdata/StonfiLpWalletV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x0857cdd89c74844150cacd35cd020bef9167cbe12cd330dfb8c779c14d6b1552
const PINNED_MAINNET_BLOCK = 71167154

const MAINNET_STONFI_LP_WALLET_V1_ADDRESS = "EQC47gPA2YMcmg2l_SscPm9pXILg-D98DjpQVZckEdeLaVH7"
const MAINNET_STONFI_LP_WALLET_V1_MASTER = "0:7B14432B5939D12C706E8AB9193A2F47BAE7C558D5C5CFD08779AD839335A550"
const MAINNET_STONFI_LP_WALLET_V1_OWNER = "0:0000000000000000000000000000000000000000000000000000000000000000"

fun mainnetStonfiLpWalletV1(): StonfiLpWalletV1 {
    return StonfiLpWalletV1.fromAddress(address(MAINNET_STONFI_LP_WALLET_V1_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiLpWalletV1StorageFromFork(wallet: StonfiLpWalletV1): StonfiLpWalletV1Storage {
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
            expect(code!.hash()).toEqual(build("StonfiLpWalletV1", FIXTURE_BOC_PATH).hash());
            return StonfiLpWalletV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi LP wallet v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi LP wallet v1 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi lp wallet v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StonfiLpWalletV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi lp wallet v1 mainnet get wallet data matches storage`() {
    val wallet = mainnetStonfiLpWalletV1();
    val storage = loadStonfiLpWalletV1StorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    expect(storage.balance).toEqual(1000);
    expect(storage.ownerAddress).toEqual(address(MAINNET_STONFI_LP_WALLET_V1_OWNER));
    expect(storage.jettonMasterAddress).toEqual(address(MAINNET_STONFI_LP_WALLET_V1_MASTER));

    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    println("STONFI_LP_WALLET_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_LP_WALLET_V1_ADDRESS={}", wallet.address);
    println("STONFI_LP_WALLET_V1_STORAGE={}", storage);
    println("STONFI_LP_WALLET_V1_GET_WALLET_DATA={}", data);
    println("STONFI_LP_WALLET_V1_WALLET_CODE_HASH={}", data.jettonWalletCode.hash());
}
