import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_notcoin_master.types"
import "../wrappers/JettonNotcoinMaster.gen"

const MAINNET_JETTON_NOTCOIN_MASTER_ADDRESS = "EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT"
const MAINNET_JETTON_NOTCOIN_OWNER_ADDRESS = "EQA9ZJf1M-Z3HvprCdlnL0puFwiJP6x2z7JSXhqPMdHOKnHR"
const MAINNET_JETTON_NOTCOIN_WALLET_ADDRESS = "EQAtRMiPzUFf6--gle-_Z2WGl0XH8To-r5hHk_B8JPCqTjcD"

fun mainnetJettonNotcoinMaster(): JettonNotcoinMaster {
    return JettonNotcoinMaster.fromAddress(address(MAINNET_JETTON_NOTCOIN_MASTER_ADDRESS));
}

fun mainnetJettonNotcoinOwner(): address {
    return address(MAINNET_JETTON_NOTCOIN_OWNER_ADDRESS);
}

fun mainnetJettonNotcoinWalletAddress(): address {
    return address(MAINNET_JETTON_NOTCOIN_WALLET_ADDRESS);
}

fun emptyJettonNotcoinMetadataTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadJettonNotcoinMasterStorageFromFork(
    master: JettonNotcoinMaster,
): JettonNotcoinMasterStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return JettonNotcoinMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Jetton 1.2 Notcoin master mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Jetton 1.2 Notcoin master mainnet fixture account is frozen");
        }
    }
}
