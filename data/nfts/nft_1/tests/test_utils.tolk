import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/nft_v1_collection.types"
import "../types/nft_v1_editable_item.types"
import "../types/nft_v1_item.types"
import "../wrappers/NftV1Collection.gen"
import "../wrappers/NftV1EditableItem.gen"
import "../wrappers/NftV1Item.gen"

const MAINNET_NFT_V1_COLLECTION_ADDRESS = "EQCSISwAJT2YNGzMZfjyRysKIXm1ahz2A1c3ulzZZ-p6lrxw"
const MAINNET_NFT_V1_EDITABLE_COLLECTION_ADDRESS = "EQAgqGsCmnweWeNEpSZASL2rakJiwcwi6o_V11yabB9uouGF"
const MAINNET_NFT_V1_ITEM_ADDRESS = "EQCZ_295fsyHHOdpZyUDQdX_tRTQsli5hTGmpipcx6kn8_zq"
const MAINNET_NFT_V1_SIMPLE_ITEM_ADDRESS = "EQDhZBNuiJoWgq-0xEc0A46-nIcEKAQbS-0MkWU_I2LEp3Ty"
const MAINNET_NFT_V1_EDITABLE_ITEM_ADDRESS = "EQDqG87vJ-dvN3_NLW2AXBheN4td6ee_CL3kfueoBfFLtTt0"

fun mainnetNftV1Collection(): NftV1Collection {
    return NftV1Collection.fromAddress(address(MAINNET_NFT_V1_COLLECTION_ADDRESS));
}

fun mainnetNftV1EditableCollection(): NftV1Collection {
    return NftV1Collection.fromAddress(address(MAINNET_NFT_V1_EDITABLE_COLLECTION_ADDRESS));
}

fun mainnetNftV1Item(): NftV1Item {
    return NftV1Item.fromAddress(address(MAINNET_NFT_V1_ITEM_ADDRESS));
}

fun mainnetNftV1SimpleItem(): NftV1Item {
    return NftV1Item.fromAddress(address(MAINNET_NFT_V1_SIMPLE_ITEM_ADDRESS));
}

fun mainnetNftV1EditableItem(): NftV1EditableItem {
    return NftV1EditableItem.fromAddress(address(MAINNET_NFT_V1_EDITABLE_ITEM_ADDRESS));
}

fun nftV1InlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun loadNftV1CollectionStorageFromFork(collection: NftV1Collection): NftV1CollectionStorage {
    val account = testing.getAccountState(collection.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return NftV1CollectionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("NFT v1 collection mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("NFT v1 collection mainnet fixture account is frozen");
        }
    }
}

fun loadNftV1ItemStorageFromFork(item: NftV1Item): NftV1ItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return NftV1ItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("NFT v1 item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("NFT v1 item mainnet fixture account is frozen");
        }
    }
}

fun loadNftV1EditableItemStorageFromFork(item: NftV1EditableItem): NftV1EditableItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return NftV1EditableItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("NFT v1 editable item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("NFT v1 editable item mainnet fixture account is frozen");
        }
    }
}
