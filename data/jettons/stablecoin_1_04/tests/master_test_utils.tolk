import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stablecoin_master.types"
import "../wrappers/StablecoinMaster.gen"

const MAINNET_STABLECOIN_MASTER_ADDRESS = "EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs"
const MAINNET_STABLECOIN_OWNER_ADDRESS = "EQAj-peZGPH-cC25EAv4Q-h8cBXszTmkch6ba6wXC8BM4xdo"
const MAINNET_STABLECOIN_WALLET_ADDRESS = "EQAmJs8wtwK93thF78iD76RQKf9Z3v2sxM57iwpZZtdQAiVM"

fun mainnetStablecoinMaster(): StablecoinMaster {
    return StablecoinMaster.fromAddress(address(MAINNET_STABLECOIN_MASTER_ADDRESS));
}

fun mainnetStablecoinOwner(): address {
    return address(MAINNET_STABLECOIN_OWNER_ADDRESS);
}

fun mainnetStablecoinWalletAddress(): address {
    return address(MAINNET_STABLECOIN_WALLET_ADDRESS);
}

fun emptyStablecoinMetadataTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadStablecoinMasterStorageFromFork(
    master: StablecoinMaster,
): StablecoinMasterStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return StablecoinMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Stablecoin v1.04 master mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Stablecoin v1.04 master mainnet fixture account is frozen");
        }
    }
}
