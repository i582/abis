import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_vault.types"
import "../wrappers/StormVault.gen"

const FIXTURE_BOC_PATH = "data/storm/vault/testdata/StormVault.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfbe19f9572b8acf2420c12fe186a781928f07a5406817f5e76dce11330de433b
const EXPECTED_DECIMALS = 6
const EXPECTED_VAULT_TYPE = 0
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_STORM_VAULT_ADDRESS = "EQAz6ehNfL7_8NI7OVh1Qg46HsuC4kFpK-icfqK9J3Frd6CJ"

struct LoadedStormVaultStorage {
    data: cell
    storage: StormVaultStorage
}

fun mainnetStormVault(): StormVault {
    return StormVault.fromAddress(address(MAINNET_STORM_VAULT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun decodeV3Paused(mutate tail: RemainingBitsAndRefs): bool {
    if (tail.remainingBitsCount() == 0) {
        expect(tail.remainingRefsCount()).toEqual(0);
        return false;
    }

    expect(tail.remainingBitsCount()).toEqual(1);
    val paused = tail.loadUint(1) == 1;
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
    return paused;
}

fun loadStormVaultStorageFromFork(vault: StormVault): LoadedStormVaultStorage {
    val account = testing.getAccountState(vault.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StormVault", FIXTURE_BOC_PATH).hash());
            return LoadedStormVaultStorage {
                data: data!,
                storage: StormVaultStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm Vault mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm Vault mainnet fixture account is frozen");
        }
    }
}

fun expectStormVaultGettersMatchStorage(vault: StormVault, loaded: LoadedStormVaultStorage): void {
    val storage = loaded.storage;
    val vaultData = vault.getVaultData();
    val bufferData = vault.getBufferData();
    val bufferRates = storage.bufferRates.load();
    var tail = storage.tail;
    val v3Paused = decodeV3Paused(mutate tail);

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(vault.getVaultType()).toEqual(EXPECTED_VAULT_TYPE);
    expect(vault.getVaultContractData().hash()).toEqual(loaded.data.hash());

    expect(storage.decimals).toEqual(EXPECTED_DECIMALS);
    val whitelistedAddresses = vault.getVaultWhitelistedAddresses();
    expect(whitelistedAddresses.mustGet(0)).toEqual(storage.protocolAddresses.mustGet(0));
    expect(whitelistedAddresses.mustGet(1)).toEqual(storage.protocolAddresses.mustGet(1));
    expect(whitelistedAddresses.mustGet(2)).toEqual(storage.protocolAddresses.mustGet(2));
    expect(whitelistedAddresses.mustGet(4)).toEqual(storage.protocolAddresses.mustGet(4));

    expect(vaultData.jettonWallet).toEqual(storage.jettonWallet);
    expect(vaultData.rate).toEqual(storage.rate);
    expect(vaultData.totalSupply).toEqual(storage.totalSupply);
    expect(vaultData.freeBalance).toEqual(storage.freeBalance);
    expect(vaultData.lockedBalance).toEqual(storage.lockedBalance);
    expect(vaultData.bufferBalance).toEqual(storage.bufferBalance);
    expect(vaultData.stakersBalance).toEqual(storage.stakersBalance);
    expect(vaultData.executorsBalance).toEqual(storage.executorsBalance);
    expect(vaultData.v3Paused).toEqual(v3Paused);

    expect(bufferData.bufferBalance).toEqual(storage.bufferBalance);
    expect(bufferData.bufferRate).toEqual(bufferRates.bufferRate);
    expect(bufferData.bufferUnderRate).toEqual(bufferRates.bufferUnderRate);
    expect(bufferData.bufferOverRate).toEqual(bufferRates.bufferOverRate);

    expect(storage.totalSupply).toBeGreater(0);
    expect(storage.rate).toBeGreater(0);
    expect(vault.getClaimerAddress()).toEqual(storage.protocolAddresses.mustGet(4));
    expectInternalAddress(vault.getLpMinterAddress());
    expectInternalAddress(vault.getReferralCollectionAddress());
    expectInternalAddress(vault.getExecutorCollectionAddress());
    expectInternalAddress(vault.getClaimerAddress());
}

get fun `test storm vault code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StormVault", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storm vault mainnet storage and getters`() {
    val vault = mainnetStormVault();
    val loaded = loadStormVaultStorageFromFork(vault);

    expectStormVaultGettersMatchStorage(vault, loaded);

    println("STORM_VAULT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_VAULT_ADDRESS={}", vault.address);
    println("STORM_VAULT_STORAGE={}", loaded.storage);
}
