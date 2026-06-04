import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonco_account.types"
import "../wrappers/ToncoAccount.gen"

const FIXTURE_BOC_PATH = "data/tonco/account/testdata/ToncoAccount.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa820f670f18a3afa05c5acb0f85e248c97b01b4d846aeeac4730622b832a8c20
const PINNED_MAINNET_BLOCK = 71245765

const MAINNET_TONCO_ACCOUNT_ADDRESS = "EQAZ8g6UM2EXWMFxpFcXtrAFHCY9PFbnbHKoQt7pHH9ps5w4"
const MAINNET_TONCO_POOL_ADDRESS = "EQBk33mIwYXYAytv4beERPqjfdNHaQuSfpaRY7KmNmHqpVLY"
const MAINNET_TONCO_POSITION_OWNER_ADDRESS = "EQAkAnmElEeFWeACUBfmi2q-qQseA00sBInrihCAFmQbkTeH"

fun mainnetToncoAccount(): ToncoAccount {
    return ToncoAccount.fromAddress(address(MAINNET_TONCO_ACCOUNT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadToncoAccountStorageFromFork(accountContract: ToncoAccount): ToncoAccountStorage {
    val account = testing.getAccountState(accountContract.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("ToncoAccount", FIXTURE_BOC_PATH).hash());
            return ToncoAccountStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TONCO AccountV3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TONCO AccountV3 mainnet fixture account is frozen");
        }
    }
}

get fun `test tonco account code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("ToncoAccount", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonco account mainnet getter matches storage`() {
    val account = mainnetToncoAccount();
    val storage = loadToncoAccountStorageFromFork(account);
    val balances = storage.balances.load();
    val data = account.getAccountData();

    expect(scripts.isContractDeployed(account.address)).toBeTrue();

    expect(storage.userAddress).toEqual(address(MAINNET_TONCO_POSITION_OWNER_ADDRESS));
    expect(storage.poolAddress).toEqual(address(MAINNET_TONCO_POOL_ADDRESS));
    expect(data.userAddress).toEqual(storage.userAddress);
    expect(data.poolAddress).toEqual(storage.poolAddress);
    expect(data.amount0).toEqual(balances.amount0 as int);
    expect(data.amount1).toEqual(balances.amount1 as int);
    expect(data.enough0).toEqual(balances.enough0 as int);
    expect(data.enough1).toEqual(balances.enough1 as int);

    println("TONCO_ACCOUNT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONCO_ACCOUNT_ADDRESS={}", account.address);
    println("TONCO_ACCOUNT_STORAGE={}", storage);
    println("TONCO_ACCOUNT_DATA={}", data);
}
