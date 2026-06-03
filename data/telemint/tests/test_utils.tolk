import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/telemint_nft_item.types"
import "../wrappers/TelemintNftItem.gen"

const MAINNET_TELEMINT_NFT_ITEM_ADDRESS = "EQBqs8pl1dJOZeXC3lspnYneBHag7VbQ9zKkv4IpQT3nnn5g"

fun mainnetTelemintNftItem(): TelemintNftItem {
    return TelemintNftItem.fromAddress(address(MAINNET_TELEMINT_NFT_ITEM_ADDRESS));
}

fun telemintInlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun loadTelemintNftItemStorageFromFork(item: TelemintNftItem): TelemintNftItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return TelemintNftItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TeleMint NFT item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TeleMint NFT item mainnet fixture account is frozen");
        }
    }
}
