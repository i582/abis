import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stablecoin_wallet.types"
import "../wrappers/StablecoinWallet.gen"
import "./master_test_utils"

fun mainnetStablecoinWallet(): StablecoinWallet {
    return StablecoinWallet.fromAddress(mainnetStablecoinWalletAddress());
}

fun emptyStablecoinForwardPayload(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadStablecoinWalletStorageFromFork(
    wallet: StablecoinWallet,
): StablecoinWalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return StablecoinWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Stablecoin v1.04 wallet mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Stablecoin v1.04 wallet mainnet fixture account is frozen");
        }
    }
}
