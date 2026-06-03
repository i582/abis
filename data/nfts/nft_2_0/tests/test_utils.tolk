import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/nft_v2_collection.types"
import "../types/nft_v2_editable_item.types"
import "../types/nft_v2_item.types"
import "../wrappers/NftV2Collection.gen"
import "../wrappers/NftV2EditableItem.gen"
import "../wrappers/NftV2Item.gen"

const MAINNET_NFT_V2_COLLECTION_ADDRESS = "EQCSISwAJT2YNGzMZfjyRysKIXm1ahz2A1c3ulzZZ-p6lrxw"
const MAINNET_NFT_V2_EDITABLE_COLLECTION_ADDRESS = "EQAgqGsCmnweWeNEpSZASL2rakJiwcwi6o_V11yabB9uouGF"
const MAINNET_NFT_V2_ITEM_ADDRESS = "EQCZ_295fsyHHOdpZyUDQdX_tRTQsli5hTGmpipcx6kn8_zq"
const MAINNET_NFT_V2_SIMPLE_ITEM_ADDRESS = "EQDhZBNuiJoWgq-0xEc0A46-nIcEKAQbS-0MkWU_I2LEp3Ty"
const MAINNET_NFT_V2_EDITABLE_ITEM_ADDRESS = "EQDqG87vJ-dvN3_NLW2AXBheN4td6ee_CL3kfueoBfFLtTt0"

fun mainnetNftV2Collection(): NftV2Collection {
    return NftV2Collection.fromAddress(address(MAINNET_NFT_V2_COLLECTION_ADDRESS));
}

fun mainnetNftV2EditableCollection(): NftV2Collection {
    return NftV2Collection.fromAddress(address(MAINNET_NFT_V2_EDITABLE_COLLECTION_ADDRESS));
}

fun mainnetNftV2Item(): NftV2Item {
    return NftV2Item.fromAddress(address(MAINNET_NFT_V2_ITEM_ADDRESS));
}

fun mainnetNftV2SimpleItem(): NftV2Item {
    return NftV2Item.fromAddress(address(MAINNET_NFT_V2_SIMPLE_ITEM_ADDRESS));
}

fun mainnetNftV2EditableItem(): NftV2EditableItem {
    return NftV2EditableItem.fromAddress(address(MAINNET_NFT_V2_EDITABLE_ITEM_ADDRESS));
}

fun nftV2InlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun loadNftV2CollectionStorageFromFork(collection: NftV2Collection): NftV2CollectionStorage {
    val account = testing.getAccountState(collection.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return NftV2CollectionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("NFT 2.0 collection mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("NFT 2.0 collection mainnet fixture account is frozen");
        }
    }
}

fun loadNftV2ItemStorageFromFork(item: NftV2Item): NftV2ItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return NftV2ItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("NFT 2.0 item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("NFT 2.0 item mainnet fixture account is frozen");
        }
    }
}

fun loadNftV2EditableItemStorageFromFork(item: NftV2EditableItem): NftV2EditableItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return NftV2EditableItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("NFT 2.0 editable item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("NFT 2.0 editable item mainnet fixture account is frozen");
        }
    }
}
