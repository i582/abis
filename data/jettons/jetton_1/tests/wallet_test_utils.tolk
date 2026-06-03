import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_v1_wallet.types"
import "../wrappers/JettonV1Wallet.gen"

const MAINNET_JETTON_V1_WALLET_ADDRESS = "EQA_wAw2-rhLg-kCypeJW8dcrPKWcHZ9VccrZd_6RPjqYpfR"

fun mainnetJettonV1Wallet(): JettonV1Wallet {
    return JettonV1Wallet.fromAddress(address(MAINNET_JETTON_V1_WALLET_ADDRESS));
}

fun emptyForwardPayload(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadJettonV1WalletStorageFromFork(wallet: JettonV1Wallet): JettonV1WalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return JettonV1WalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Jetton v1 wallet mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Jetton v1 wallet mainnet fixture account is frozen");
        }
    }
}
