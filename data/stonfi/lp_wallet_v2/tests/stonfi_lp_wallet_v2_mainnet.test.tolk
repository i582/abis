import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_lp_wallet_v2.types"
import "../wrappers/StonfiLpWalletV2.gen"

const FIXTURE_BOC_PATH = "data/stonfi/lp_wallet_v2/testdata/StonfiLpWalletV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xbf13041750f2beeb688859c75689e2c18b9c90bd78e97b197aad7ad6bc520c84
const PINNED_MAINNET_BLOCK = 71167154

const MAINNET_STONFI_LP_WALLET_V2_ADDRESS = "EQBtRf9VN6DK5IDOejdA53RhahjLCpAL5lwE_riSiCVymAEU"

fun mainnetStonfiLpWalletV2(): StonfiLpWalletV2 {
    return StonfiLpWalletV2.fromAddress(address(MAINNET_STONFI_LP_WALLET_V2_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiLpWalletV2StorageFromFork(wallet: StonfiLpWalletV2): StonfiLpWalletV2Storage {
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
            expect(code!.hash()).toEqual(build("StonfiLpWalletV2", FIXTURE_BOC_PATH).hash());
            return StonfiLpWalletV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi LP wallet v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi LP wallet v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi lp wallet v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StonfiLpWalletV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi lp wallet v2 mainnet get wallet data matches storage`() {
    val wallet = mainnetStonfiLpWalletV2();
    val storage = loadStonfiLpWalletV2StorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    println("STONFI_LP_WALLET_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_LP_WALLET_V2_ADDRESS={}", wallet.address);
    println("STONFI_LP_WALLET_V2_STORAGE={}", storage);
    println("STONFI_LP_WALLET_V2_GET_WALLET_DATA={}", data);
    println("STONFI_LP_WALLET_V2_WALLET_CODE_HASH={}", data.jettonWalletCode.hash());
}
