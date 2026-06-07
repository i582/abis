import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_v2_collection.types"
import "../types/getgems_nft_v2_editable_item.types"
import "../types/getgems_nft_v2_item.types"
import "../wrappers/GetgemsNftCollectionV2.gen"
import "../wrappers/GetgemsNftEditableItemV2.gen"
import "../wrappers/GetgemsNftItemV2.gen"

const MAINNET_GETGEMS_NFT_COLLECTION_V2_ADDRESS = "EQCoXMPfScPFpyeBJWAwJDTGt0IedtnvUCglIQphe1KAf62u"
const MAINNET_GETGEMS_NFT_ITEM_V2_ADDRESS = "EQDciKcA85857MsCuXuD_kXL2My8V1Log5ZvbAw_J4VC5keQ"
const MAINNET_GETGEMS_NFT_EDITABLE_ITEM_V2_ADDRESS = "EQCQxUrLeVpeXtVQA1KDCMoPHLTsiXmHkeg4mBbePGmhudGY"

fun mainnetGetgemsNftCollectionV2(): GetgemsNftCollectionV2 {
    return GetgemsNftCollectionV2.fromAddress(address(MAINNET_GETGEMS_NFT_COLLECTION_V2_ADDRESS));
}

fun mainnetGetgemsNftItemV2(): GetgemsNftItemV2 {
    return GetgemsNftItemV2.fromAddress(address(MAINNET_GETGEMS_NFT_ITEM_V2_ADDRESS));
}

fun mainnetGetgemsNftEditableItemV2(): GetgemsNftEditableItemV2 {
    return GetgemsNftEditableItemV2.fromAddress(
        address(MAINNET_GETGEMS_NFT_EDITABLE_ITEM_V2_ADDRESS),
    );
}

fun getgemsNftV2InlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun loadGetgemsNftCollectionV2StorageFromFork(
    collection: GetgemsNftCollectionV2,
): GetgemsNftCollectionV2Storage {
    val account = testing.getAccountState(collection.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftCollectionV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT collection v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT collection v2 mainnet fixture account is frozen");
        }
    }
}

fun loadGetgemsNftItemV2StorageFromFork(item: GetgemsNftItemV2): GetgemsNftItemV2Storage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftItemV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT item v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT item v2 mainnet fixture account is frozen");
        }
    }
}

fun loadGetgemsNftEditableItemV2StorageFromFork(
    item: GetgemsNftEditableItemV2,
): GetgemsNftEditableItemV2Storage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftEditableItemV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT editable item v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT editable item v2 mainnet fixture account is frozen");
        }
    }
}
