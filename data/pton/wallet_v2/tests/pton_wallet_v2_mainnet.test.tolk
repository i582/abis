import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/pton_wallet_v2.types"
import "../wrappers/PtonWalletV2.gen"

const FIXTURE_BOC_PATH = "data/pton/wallet_v2/testdata/PtonWalletV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xed91066ad36ee3aaaff29e78db287acb51376292ea0e01bca1b92c97cdf0421b
const PINNED_MAINNET_BLOCK = 71235434

const MAINNET_PTON_MINTER_V2_ADDRESS = "EQBnGWMCf3-FZZq1W4IWcWiGAc3PHuZ0_H-7sad2oY00o83S"
const MAINNET_STONFI_ROUTER_V2_ADDRESS = "EQCS4UEa5UaJLzOyyKieqQOQ2P9M-7kXpkO5HnP3Bv250cN3"
const MAINNET_STONFI_ROUTER_PTON_WALLET = "EQCSIMGBps_qzRG3uPYhON8bucyCtu0mYdL1-u4gSz77IBa3"
const MAINNET_EXTRA_ROUTER_ADDRESS = "EQBQ_UBQvR9ryUjKDwijtoiyyga2Wl-yJm6Y8gl0k-HDh_5x"
const MAINNET_EXTRA_ROUTER_PTON_WALLET = "EQBTYCx7TGgVgaIr3tuJ3r_91E6FUBBWLtT73lTYYmrIc5gb"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadPtonWalletV2StorageFromFork(wallet: PtonWalletV2): PtonWalletV2Storage {
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
            expect(code!.hash()).toEqual(build("PtonWalletV2", FIXTURE_BOC_PATH).hash());
            return PtonWalletV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("pTON wallet v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("pTON wallet v2 mainnet fixture account is frozen");
        }
    }
}

fun assertPtonWalletV2GetterMatchesStorage(walletAddress: address, expectedOwner: address): void {
    val wallet = PtonWalletV2.fromAddress(walletAddress);
    val storage = loadPtonWalletV2StorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    expect(storage.ownerAddress).toEqual(expectedOwner);
    expect(storage.minterAddress).toEqual(address(MAINNET_PTON_MINTER_V2_ADDRESS));
    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.minterAddress);
    expect(data.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.jettonWalletCode.hash()).toEqual(build("PtonWalletV2", FIXTURE_BOC_PATH).hash());

    println("PTON_WALLET_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("PTON_WALLET_V2_ADDRESS={}", wallet.address);
    println("PTON_WALLET_V2_STORAGE={}", storage);
    println("PTON_WALLET_V2_GET_WALLET_DATA={}", data);
}

get fun `test pton wallet v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("PtonWalletV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test pton wallet v2 stonfi router mainnet getter matches storage`() {
    assertPtonWalletV2GetterMatchesStorage(
        address(MAINNET_STONFI_ROUTER_PTON_WALLET),
        address(MAINNET_STONFI_ROUTER_V2_ADDRESS),
    );
}

get fun `test pton wallet v2 extra router mainnet getter matches storage`() {
    assertPtonWalletV2GetterMatchesStorage(
        address(MAINNET_EXTRA_ROUTER_PTON_WALLET),
        address(MAINNET_EXTRA_ROUTER_ADDRESS),
    );
}
