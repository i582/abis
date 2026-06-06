import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_lp_minter.types"
import "../wrappers/StormLpMinter.gen"

const FIXTURE_BOC_PATH = "data/storm/lp_minter/testdata/StormLpMinter.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5d01684bdf1d5c9be2682c4e36074202432628bd3477d77518d66b0976b78cca
const EXPECTED_WALLET_CODE_HASH = 0x02ae100484cfd15161d16dd4fec955b6b550678567ceea62b1db84eee35d0ccd
const PINNED_MAINNET_BLOCK = 71589284

const TON_LP_MINTER_ADDRESS = "EQCNY2AQ3ZDYwJAqx_nzl9i9Xhd_Ex7izKJM6JTxXRnO6n1F"
const USDT_LP_MINTER_ADDRESS = "EQCup4xxCulCcNwmOocM9HtDYPU8xe0449tQLp6a-5BLEegW"

struct LoadedStormLpMinterStorage {
    data: cell
    storage: StormLpMinterStorage
}

fun tonLpMinter(): StormLpMinter {
    return StormLpMinter.fromAddress(address(TON_LP_MINTER_ADDRESS));
}

fun usdtLpMinter(): StormLpMinter {
    return StormLpMinter.fromAddress(address(USDT_LP_MINTER_ADDRESS));
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

fun loadStormLpMinterStorageFromFork(minter: StormLpMinter): LoadedStormLpMinterStorage {
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
            expect(code!.hash()).toEqual(build("StormLpMinter", FIXTURE_BOC_PATH).hash());
            return LoadedStormLpMinterStorage {
                data: data!,
                storage: StormLpMinterStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm LP minter mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm LP minter mainnet fixture account is frozen");
        }
    }
}

fun expectStormLpMinterGettersMatchStorage(minter: StormLpMinter, loaded: LoadedStormLpMinterStorage): void {
    val storage = loaded.storage;
    val jettonData = minter.getJettonData();
    val walletAddress = minter.getWalletAddress(storage.vaultAddress);

    expect(scripts.isContractDeployed(minter.address)).toBeTrue();
    expectInternalAddress(storage.vaultAddress);
    expectInternalAddress(walletAddress);

    expect(minter.getVaultAddress()).toEqual(storage.vaultAddress);
    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(storage.vaultAddress);
    expect(jettonData.walletCode.hash()).toEqual(storage.lpWalletCode.hash());
    expect(jettonData.walletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
    expect(jettonData.content.hash()).toBeGreater(0);
    expect(storage.lpWalletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
}

get fun `test storm lp minter code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StormLpMinter", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storm ton lp minter mainnet storage and getters`() {
    val minter = tonLpMinter();
    val loaded = loadStormLpMinterStorageFromFork(minter);

    expectStormLpMinterGettersMatchStorage(minter, loaded);

    println("STORM_LP_MINTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_TON_LP_MINTER_ADDRESS={}", minter.address);
    println("STORM_TON_LP_MINTER_STORAGE={}", loaded.storage);
}

get fun `test storm usdt lp minter mainnet storage and getters`() {
    val minter = usdtLpMinter();
    val loaded = loadStormLpMinterStorageFromFork(minter);

    expectStormLpMinterGettersMatchStorage(minter, loaded);

    println("STORM_LP_MINTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_USDT_LP_MINTER_ADDRESS={}", minter.address);
    println("STORM_USDT_LP_MINTER_STORAGE={}", loaded.storage);
}
