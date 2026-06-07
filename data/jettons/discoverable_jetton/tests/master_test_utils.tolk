import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/discoverable_jetton_master.types"
import "../wrappers/DiscoverableJettonMaster.gen"

const MAINNET_DISCOVERABLE_JETTON_MASTER_ADDRESS = "EQDOxsDBUkJYfX2musuy4yG-7o6VSMIMdqEsktTjI3HX3vUb"
const MAINNET_DISCOVERABLE_JETTON_OWNER_ADDRESS = "EQDerEPTIh0O8lBdjWc6aLaJs5HYqlfBN2Ruj1lJQH_6vcaZ"
const MAINNET_DISCOVERABLE_JETTON_WALLET_ADDRESS = "EQDt0qeoHwip8CtuUeNsaKjK-g0rwL7zUunKAnv0NCTZDSs3"

fun mainnetDiscoverableJettonMaster(): DiscoverableJettonMaster {
    return DiscoverableJettonMaster.fromAddress(
        address(MAINNET_DISCOVERABLE_JETTON_MASTER_ADDRESS),
    );
}

fun mainnetDiscoverableJettonOwner(): address {
    return address(MAINNET_DISCOVERABLE_JETTON_OWNER_ADDRESS);
}

fun mainnetDiscoverableJettonWalletAddress(): address {
    return address(MAINNET_DISCOVERABLE_JETTON_WALLET_ADDRESS);
}

fun loadDiscoverableJettonMasterStorageFromFork(
    master: DiscoverableJettonMaster,
): DiscoverableJettonMasterStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return DiscoverableJettonMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Discoverable Jetton master mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Discoverable Jetton master mainnet fixture account is frozen");
        }
    }
}
