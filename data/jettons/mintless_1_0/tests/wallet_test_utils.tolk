import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/mintless_wallet.types"
import "../wrappers/MintlessJettonWallet.gen"
import "./master_test_utils"

fun mainnetMintlessWallet(): MintlessJettonWallet {
    return MintlessJettonWallet.fromAddress(mainnetMintlessWalletAddress());
}

fun emptyMintlessForwardPayload(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun unknownMintlessWalletBody(): cell {
    return beginCell()
        .storeUint(0x12345678, 32)
        .storeUint(0, 64)
        .endCell();
}

fun loadMintlessWalletStorageFromFork(
    wallet: MintlessJettonWallet,
): MintlessJettonWalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return MintlessJettonWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Mintless v1.0 wallet mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Mintless v1.0 wallet mainnet fixture account is frozen");
        }
    }
}
