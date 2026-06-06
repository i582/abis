import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_executor_collection.types"
import "../wrappers/StormExecutorCollection.gen"

const PINNED_MAINNET_BLOCK = 71588122
const MAINNET_EXECUTOR_COLLECTION_ADDRESS = "EQAR1cNVy6K6PV2f_kdrjVziJpWZUW7_HWQV9l4pE7YBSvrZ"
const MAINNET_EXECUTOR_ITEM_0_ADDRESS = "EQDeA8aTt-gxy5nNbbqsoXRQtBYj5ND7LLOrODdUsuZm_bWD"
const EXPECTED_EXECUTOR_COLLECTION_CODE_HASH =
    0xbed395e1e32650955d3323dc8769e461f39b6f5215fa7c57084ce9b254a7c213

fun mainnetStormExecutorCollection(): StormExecutorCollection {
    return StormExecutorCollection.fromAddress(address(MAINNET_EXECUTOR_COLLECTION_ADDRESS));
}

fun loadStormExecutorCollectionStorageFromFork(collection: StormExecutorCollection): StormExecutorCollectionStorage {
    val account = testing.getAccountState(collection.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_EXECUTOR_COLLECTION_CODE_HASH);
            return StormExecutorCollectionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm executor collection account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm executor collection account is frozen");
        }
    }
}

fun stormWrappedCollectionMetadata(content: cell): cell {
    return beginCell()
        .storeUint(1, 8)
        .storeSlice(content.beginParse())
        .endCell();
}

get fun `test storm executor collection mainnet storage and getters`() {
    val collection = mainnetStormExecutorCollection();
    val storage = loadStormExecutorCollectionStorageFromFork(collection);
    val content = storage.content.load();
    val royaltyParams = storage.royaltyParams.load();
    val collectionData = collection.getCollectionData();
    val getterRoyalty = collection.royaltyParams();
    val getterWhitelist = collection.getExecutorVaultsWhitelist();
    val item0 = collection.getNftAddressByIndex(0);

    expect(scripts.isContractDeployed(collection.address)).toBeTrue();
    expect(collectionData.nextItemIndex).toEqual(storage.nextExecutorIndex as int);
    expect(collectionData.collectionMetadata.hash()).toEqual(
        stormWrappedCollectionMetadata(content.collectionMetadata).hash(),
    );
    expect(collectionData.adminAddress).toEqual(storage.adminAddress);
    expect(getterRoyalty.numerator).toEqual(royaltyParams.numerator);
    expect(getterRoyalty.denominator).toEqual(royaltyParams.denominator);
    expect(getterRoyalty.royaltyAddress).toEqual(royaltyParams.royaltyAddress);
    expect(getterWhitelist).toEqual(storage.vaultsWhitelist);
    expect(item0).toEqual(address(MAINNET_EXECUTOR_ITEM_0_ADDRESS));

    println("STORM_EXECUTOR_COLLECTION_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_EXECUTOR_COLLECTION_ADDRESS={}", collection.address);
    println("STORM_EXECUTOR_COLLECTION_STORAGE={}", storage);
    println("STORM_EXECUTOR_COLLECTION_DATA={}", collectionData);
    println("STORM_EXECUTOR_COLLECTION_ITEM_0={}", item0);
}
