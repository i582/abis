import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_prelaunch.types"
import "../wrappers/StormPrelaunch.gen"

const EXPECTED_CODE_HASH = 0x6599be05b28905753aced8acf1dd21d40371702a3af5d6e8275a2ad3021a0478
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_PRELAUNCH_ADDRESS = "EQB-ayedPowUtiEAIfdNBdp_1J_VlbdvedfRyp8-3yrAhtMC"
const ABSENT_USER_ADDRESS = "0:0000000000000000000000000000000000000000000000000000000000000001"

fun mainnetStormPrelaunch(): StormPrelaunch {
    return StormPrelaunch.fromAddress(address(MAINNET_PRELAUNCH_ADDRESS));
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadStormPrelaunchStorageFromFork(prelaunch: StormPrelaunch): StormPrelaunchStorage {
    val account = testing.getAccountState(prelaunch.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return StormPrelaunchStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm Prelaunch account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm Prelaunch account is frozen");
        }
    }
}

get fun `test storm prelaunch mainnet storage and getters`() {
    val prelaunch = mainnetStormPrelaunch();
    val storage = loadStormPrelaunchStorageFromFork(prelaunch);
    val getterData = prelaunch.getStorageData();
    val absentCounts = prelaunch.getMethod104966Jsxb(address(ABSENT_USER_ADDRESS));

    expect(scripts.isContractDeployed(prelaunch.address)).toBeTrue();
    expect(storage.participants.isEmpty()).toBeFalse();
    expect(storage.startTime).toBeGreater(0);
    expect(storage.endTime).toBeGreater(storage.startTime);
    expect(storage.walletDiscovered).toBeTrue();
    expectInternalAddress(storage.adminAddress);
    expectInternalAddress(storage.jettonWalletAddress);
    expectInternalAddress(storage.rewardNotifierAddress);

    expect(getterData.participants).toEqual(storage.participants);
    expect(getterData.adminAddress).toEqual(storage.adminAddress);
    expect(getterData.startTime).toEqual(storage.startTime);
    expect(getterData.endTime).toEqual(storage.endTime);
    expect(getterData.walletDiscovered).toEqual(storage.walletDiscovered);
    expect(getterData.jettonWalletAddress).toEqual(storage.jettonWalletAddress);
    expect(getterData.rewardNotifierAddress).toEqual(storage.rewardNotifierAddress);

    expect(absentCounts.rewardCountA).toEqual(0);
    expect(absentCounts.rewardCountB).toEqual(0);

    println("STORM_PRELAUNCH_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_PRELAUNCH_ADDRESS={}", prelaunch.address);
    println("STORM_PRELAUNCH_STORAGE={}", storage);
    println("STORM_PRELAUNCH_GETTER_DATA={}", getterData);
}
