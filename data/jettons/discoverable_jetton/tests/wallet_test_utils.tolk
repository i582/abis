import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/discoverable_jetton_wallet.types"
import "../wrappers/DiscoverableJettonWallet.gen"

const MAINNET_DISCOVERABLE_JETTON_WALLET_ADDRESS = "EQDt0qeoHwip8CtuUeNsaKjK-g0rwL7zUunKAnv0NCTZDSs3"

fun mainnetDiscoverableJettonWallet(): DiscoverableJettonWallet {
    return DiscoverableJettonWallet.fromAddress(
        address(MAINNET_DISCOVERABLE_JETTON_WALLET_ADDRESS),
    );
}

fun emptyForwardPayload(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadDiscoverableJettonWalletStorageFromFork(
    wallet: DiscoverableJettonWallet,
): DiscoverableJettonWalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return DiscoverableJettonWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Discoverable Jetton wallet mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Discoverable Jetton wallet mainnet fixture account is frozen");
        }
    }
}
