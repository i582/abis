import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "./master_test_utils"
import "../types/jetton_notcoin_wallet.types"
import "../wrappers/JettonNotcoinWallet.gen"

fun mainnetJettonNotcoinWallet(): JettonNotcoinWallet {
    return JettonNotcoinWallet.fromAddress(mainnetJettonNotcoinWalletAddress());
}

fun emptyJettonNotcoinForwardPayload(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadJettonNotcoinWalletStorageFromFork(
    wallet: JettonNotcoinWallet,
): JettonNotcoinWalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return JettonNotcoinWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Jetton 1.2 Notcoin wallet mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Jetton 1.2 Notcoin wallet mainnet fixture account is frozen");
        }
    }
}
