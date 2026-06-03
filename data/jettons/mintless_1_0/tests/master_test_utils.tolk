import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/mintless_master.types"
import "../wrappers/MintlessJettonMaster.gen"

const MAINNET_MINTLESS_MASTER_ADDRESS = "EQAJ8uWd7EBqsmpSWaRdf_I-8R8-XHwh3gsNKhy-UrdrPcUo"
const MAINNET_MINTLESS_OWNER_ADDRESS = "EQD4uGNdB4a3f52mYOZf0x1nCmdd1DAvrLppL0a1cetTYHn0"
const MAINNET_MINTLESS_WALLET_ADDRESS = "EQD1MISQQCRISJVAyLVdwEo8WiFAxSX173eUHTFPz2FdfJ42"

fun mainnetMintlessMaster(): MintlessJettonMaster {
    return MintlessJettonMaster.fromAddress(address(MAINNET_MINTLESS_MASTER_ADDRESS));
}

fun mainnetMintlessOwner(): address {
    return address(MAINNET_MINTLESS_OWNER_ADDRESS);
}

fun mainnetMintlessWalletAddress(): address {
    return address(MAINNET_MINTLESS_WALLET_ADDRESS);
}

fun emptyMintlessMetadataTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadMintlessMasterStorageFromFork(
    master: MintlessJettonMaster,
): MintlessJettonMasterStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return MintlessJettonMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Mintless v1.0 master mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Mintless v1.0 master mainnet fixture account is frozen");
        }
    }
}
