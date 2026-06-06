import "@acton/build"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_lp_wallet.types"
import "../wrappers/StormLpWallet.gen"

const FIXTURE_BOC_PATH = "data/storm/lp_wallet/testdata/storm_lp_wallet_code.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x02ae100484cfd15161d16dd4fec955b6b550678567ceea62b1db84eee35d0ccd
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_STORM_LP_WALLET_ADDRESS = "EQAlGBmBJdmQTy9ny3-jvfcGPdg1vcX3TEFgN2tdb14skfhI"

fun mainnetStormLpWallet(): StormLpWalletCode {
    return StormLpWalletCode.fromAddress(address(MAINNET_STORM_LP_WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStormLpWalletStorageFromFork(wallet: StormLpWalletCode): StormLpWalletStorage {
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
            expect(code!.hash()).toEqual(build("StormLpWallet", FIXTURE_BOC_PATH).hash());
            return StormLpWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm LP wallet representative account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm LP wallet representative account is frozen");
        }
    }
}

get fun `test storm lp wallet code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StormLpWallet", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storm lp wallet mainnet storage and get wallet data`() {
    val wallet = mainnetStormLpWallet();
    val storage = loadStormLpWalletStorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(data.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(storage.ownerAddress.getWorkchain()).toEqual(0);
    expect(storage.jettonMasterAddress.getWorkchain()).toEqual(0);

    println("STORM_LP_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_LP_WALLET_ADDRESS={}", wallet.address);
    println("STORM_LP_WALLET_STORAGE={}", storage);
    println("STORM_LP_WALLET_GET_WALLET_DATA={}", data);
    println("STORM_LP_WALLET_CODE_HASH={}", data.jettonWalletCode.hash());
}
