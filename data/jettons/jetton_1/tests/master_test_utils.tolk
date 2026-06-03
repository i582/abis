import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_v1_master.types"
import "../wrappers/JettonV1Master.gen"

const MAINNET_JETTON_V1_MASTER_ADDRESS = "EQALtan2kEPuvdpa0ulG65UyQr2PYD_nldkGmM7sa_xgoCwr"

fun mainnetJettonV1Master(): JettonV1Master {
    return JettonV1Master.fromAddress(address(MAINNET_JETTON_V1_MASTER_ADDRESS));
}

fun loadJettonV1MasterStorageFromFork(master: JettonV1Master): JettonV1MasterStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return JettonV1MasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Jetton v1 master mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Jetton v1 master mainnet fixture account is frozen");
        }
    }
}
