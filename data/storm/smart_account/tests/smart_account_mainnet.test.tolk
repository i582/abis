import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/smart_account.types"
import "../wrappers/SmartAccount.gen"

const FIXTURE_BOC_PATH = "data/storm/smart_account/testdata/SmartAccount.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const PINNED_MAINNET_BLOCK = 71591177
const MAINNET_SMART_ACCOUNT_ADDRESS = "EQAlEeKROSs9N0UbTw2lWgns8EKjaNs7HmAwVpHc-L_MMjBd"
const MAINNET_FACTORY_ADDRESS = "EQA34l2ywiFdu_kb-HZMqLngFVDjw0DJZHo1aBokOap8xVMU"
const MAINNET_OWNER_ADDRESS = "EQDrkP0Gm0ZIiTC744Xhd4fFLt560Q6NjwqtqESUuw_KQqnh"
const MAINNET_NATIVE_VAULT_ADDRESS = "EQDpJnZP89Jyxz3euDaXXFUhwCWtaOeRmiUJTi3jGYgF8fnj"
const EXPECTED_CODE_HASH =
    0x91beb72642b69dd1217ddf6f488a9391b4d4b83d0131856b1157106091886f56
const EXPECTED_NATIVE_VAULT_BALANCE = 106127368
const EXPECTED_HOT_PUBLIC_KEY =
    87239587847142616048295798838787664456457434067972149231226244021718341634210
const EXPECTED_COLD_PUBLIC_KEY =
    77954538618246219238076980304107513279290426602386175610114018503125127500440

fun mainnetSmartAccount(): SmartAccount {
    return SmartAccount.fromAddress(address(MAINNET_SMART_ACCOUNT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun zeroPositionKey(): bits268 {
    var key = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 12)
        .endCell()
        .beginParse();
    return key.loadBits(268) as bits268;
}

fun loadSmartAccountStorageFromFork(account: SmartAccount): SmartAccountStorage {
    val accountState = testing.getAccountState(account.address);
    expect(accountState).toBeNotNull();

    val storageState = accountState!.storage.state;
    match (storageState) {
        TlbAccountStateActive => {
            val code = storageState.stateInit.code;
            val data = storageState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("SmartAccount", FIXTURE_BOC_PATH).hash());
            return SmartAccountStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("SmartAccount representative account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("SmartAccount representative account is frozen");
        }
    }
}

get fun `test smart account code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("SmartAccount", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test smart account mainnet storage and getters`() {
    val account = mainnetSmartAccount();
    val storage = loadSmartAccountStorageFromFork(account);
    val storageData = account.getStorageData();
    val userPublicKeys = account.getUserPublicKeys();
    val highloadData = account.getHighloadData();
    val keysData = account.getKeysData();
    val nativeVaultAddress = address(MAINNET_NATIVE_VAULT_ADDRESS);
    val vaultBalance = account.getVaultBalance(nativeVaultAddress);
    val zeroPosition = account.getPosition(zeroPositionKey());
    val processed = account.processed(0, 0, 0);
    val keysStorage = storage.keys.load();
    val highloadStorage = storage.highloadData.load();

    expect(scripts.isContractDeployed(account.address)).toBeTrue();
    expect(storage.saType).toEqual(0);
    expect(storage.factoryAddress).toEqual(address(MAINNET_FACTORY_ADDRESS));
    expect(storage.ownerAddress).toEqual(address(MAINNET_OWNER_ADDRESS));
    expect(storage.version).toEqual(0);
    expect(storage.balances).toBeNonEmpty();
    expect(storage.positions).toBeEmpty();

    expect(storageData.saType).toEqual(storage.saType);
    expect(storageData.factoryAddress).toEqual(storage.factoryAddress);
    expect(storageData.ownerAddress).toEqual(storage.ownerAddress);
    expect(storageData.balances).toEqual(storage.balances);
    expect(storageData.version).toEqual(storage.version);
    expect(storageData.keys.hash()).toEqual(storage.keys.hash());
    expect(storageData.positions).toEqual(storage.positions);
    expect(storageData.highloadData.hash()).toEqual(storage.highloadData.hash());

    expect(keysData.hotPublicKey).toEqual(EXPECTED_HOT_PUBLIC_KEY);
    expect(keysData.coldPublicKey).toEqual(EXPECTED_COLD_PUBLIC_KEY);
    expect(keysData.keysCount).toEqual(2);
    expect(keysData.userPublicKeys).toEqual(userPublicKeys);
    expect(keysData.userPublicKeys).toEqual(keysStorage.userPublicKeys);
    expect(userPublicKeys).toHaveLength(2);
    expect(keysStorage.keysCount).toEqual(2);
    expect(keysStorage.hotPublicKey).toEqual(EXPECTED_HOT_PUBLIC_KEY);
    expect(keysStorage.coldPublicKey).toEqual(EXPECTED_COLD_PUBLIC_KEY);

    expect(highloadData.oldQueries).toEqual(highloadStorage.oldQueries);
    expect(highloadData.queries).toEqual(highloadStorage.queries);
    expect(highloadData.lastCleanTime).toEqual(1780004166);
    expect(highloadData.timeout).toEqual(15552000);
    expect(highloadStorage.lastCleanTime).toEqual(1780004166);
    expect(highloadStorage.timeout).toEqual(15552000);
    expect(vaultBalance).toEqual(EXPECTED_NATIVE_VAULT_BALANCE);
    expect(storage.balances.mustGet(nativeVaultAddress)).toEqual(vaultBalance);
    expect(zeroPosition.locked).toBeFalse();
    expect(zeroPosition.position).toBeNull();
    expect(processed).toBeTrue();

    println("STORM_SMART_ACCOUNT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_SMART_ACCOUNT_ADDRESS={}", account.address);
    println("STORM_SMART_ACCOUNT_STORAGE={}", storage);
    println("STORM_SMART_ACCOUNT_KEYS_DATA={}", keysData);
    println("STORM_SMART_ACCOUNT_HIGHLOAD_DATA={}", highloadData);
}
