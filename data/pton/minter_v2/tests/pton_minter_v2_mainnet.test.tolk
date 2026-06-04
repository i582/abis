import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/pton_minter_v2.types"
import "../wrappers/PtonMinterV2.gen"

const FIXTURE_BOC_PATH = "data/pton/minter_v2/testdata/PtonMinterV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfaf8bb63fe7c20f8468c1cda6981998eb1fdfb86571bf6e592e141f30f8e4461
const EXPECTED_WALLET_CODE_HASH = 0xed91066ad36ee3aaaff29e78db287acb51376292ea0e01bca1b92c97cdf0421b
const PINNED_MAINNET_BLOCK = 71235434

const MAINNET_PTON_MINTER_V2_ADDRESS = "EQBnGWMCf3-FZZq1W4IWcWiGAc3PHuZ0_H-7sad2oY00o83S"
const MAINNET_STONFI_ROUTER_V2_ADDRESS = "EQCS4UEa5UaJLzOyyKieqQOQ2P9M-7kXpkO5HnP3Bv250cN3"
const MAINNET_STONFI_ROUTER_PTON_WALLET = "EQCSIMGBps_qzRG3uPYhON8bucyCtu0mYdL1-u4gSz77IBa3"
const MAINNET_EXTRA_ROUTER_ADDRESS = "EQBQ_UBQvR9ryUjKDwijtoiyyga2Wl-yJm6Y8gl0k-HDh_5x"
const MAINNET_EXTRA_ROUTER_PTON_WALLET = "EQBTYCx7TGgVgaIr3tuJ3r_91E6FUBBWLtT73lTYYmrIc5gb"

fun mainnetPtonMinterV2(): PtonMinterV2 {
    return PtonMinterV2.fromAddress(address(MAINNET_PTON_MINTER_V2_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadPtonMinterV2StorageFromFork(minter: PtonMinterV2): PtonMinterV2Storage {
    val account = testing.getAccountState(minter.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("PtonMinterV2", FIXTURE_BOC_PATH).hash());
            return PtonMinterV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("pTON minter v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("pTON minter v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test pton minter v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("PtonMinterV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test pton minter v2 mainnet getters storage and derived wallets`() {
    val minter = mainnetPtonMinterV2();
    val storage = loadPtonMinterV2StorageFromFork(minter);
    val jettonData = minter.getJettonData();
    val version = minter.getVersion();
    val stonfiRouterWallet = minter.getWalletAddress(address(MAINNET_STONFI_ROUTER_V2_ADDRESS));
    val extraRouterWallet = minter.getWalletAddress(address(MAINNET_EXTRA_ROUTER_ADDRESS));

    expect(scripts.isContractDeployed(minter.address)).toBeTrue();

    expect(storage.id).toEqual(0);
    expect(storage.walletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
    expect(jettonData.totalSupply).toEqual(0);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toBeNoneAddress();
    expect(jettonData.jettonContent.hash()).toEqual(storage.content.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.walletCode.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);

    expect(version.major).toEqual(2);
    expect(version.minor).toEqual(1);
    expect(version.development).toEqual("release");

    expect(stonfiRouterWallet).toEqual(address(MAINNET_STONFI_ROUTER_PTON_WALLET));
    expect(extraRouterWallet).toEqual(address(MAINNET_EXTRA_ROUTER_PTON_WALLET));

    println("PTON_MINTER_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("PTON_MINTER_V2_ADDRESS={}", minter.address);
    println("PTON_MINTER_V2_STORAGE={}", storage);
    println("PTON_MINTER_V2_GET_JETTON_DATA={}", jettonData);
    println("PTON_MINTER_V2_GET_VERSION={}", version);
    println("PTON_MINTER_V2_STONFI_ROUTER_WALLET={}", stonfiRouterWallet);
    println("PTON_MINTER_V2_EXTRA_ROUTER_WALLET={}", extraRouterWallet);
}
