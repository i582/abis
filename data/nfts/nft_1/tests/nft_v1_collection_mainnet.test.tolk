import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/nft_v1_collection.types"
import "../wrappers/NftV1Collection.gen"

fun assertNftV1CollectionGetters(collection: NftV1Collection, label: string) {
    val storage = loadNftV1CollectionStorageFromFork(collection);
    val storedContent = storage.content.load();
    val storedRoyalty = storage.royaltyParams.load();
    val data = collection.getCollectionData();
    val royalty = collection.royaltyParams();
    val nftAddress = collection.getNftAddressByIndex(storage.nextItemIndex as int);
    val fullContent = collection.getNftContent(storage.nextItemIndex as int, createEmptyCell());

    expect(scripts.isContractDeployed(collection.address)).toBeTrue();
    expect(data.nextItemIndex).toEqual(storage.nextItemIndex as int);
    expect(data.collectionMetadata.hash()).toEqual(storedContent.collectionMetadata.hash());
    expect(data.adminAddress).toEqual(storage.adminAddress);
    expect(royalty.numerator).toEqual(storedRoyalty.numerator);
    expect(royalty.denominator).toEqual(storedRoyalty.denominator);
    expect(royalty.royaltyAddress).toEqual(storedRoyalty.royaltyAddress);

    println("NFT_V1_COLLECTION_LABEL={}", label);
    println("NFT_V1_COLLECTION_ADDRESS={}", collection.address);
    println("NFT_V1_COLLECTION_STORAGE={}", storage);
    println("NFT_V1_COLLECTION_DATA={}", data);
    println("NFT_V1_COLLECTION_ROYALTY={}", royalty);
    println("NFT_V1_COLLECTION_NEXT_ITEM_ADDRESS={}", nftAddress);
    println("NFT_V1_COLLECTION_FULL_CONTENT_HASH={}", fullContent.hash());
}

get fun `test nft v1 collection mainnet getters and storage`() {
    assertNftV1CollectionGetters(mainnetNftV1Collection(), "standard");
}

get fun `test nft v1 editable collection mainnet getters and storage`() {
    assertNftV1CollectionGetters(mainnetNftV1EditableCollection(), "editable");
}

get fun `test nft v1 collection mainnet royalty request succeeds`() {
    val collection = mainnetNftV1Collection();
    val sender = testing.treasury("nft-v1-collection-royalty-request");

    val txs = collection.sendNftV1GetRoyaltyParams(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<NftV1GetRoyaltyParams>({
        from: sender.address,
        to: collection.address,
        exitCode: 0,
    });
}

get fun `test nft v1 collection rejects unauthorized admin change`() {
    val collection = mainnetNftV1Collection();
    val sender = testing.treasury("nft-v1-collection-unauthorized-admin-change");
    val before = collection.getCollectionData();

    val txs = collection.sendNftV1ChangeAdmin(
        sender.address,
        2,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<NftV1ChangeAdmin>({
        from: sender.address,
        to: collection.address,
        exitCode: NftV1CollectionErrors.UnauthorizedAdmin,
    });
    expect(collection.getCollectionData().adminAddress).toEqual(before.adminAddress);
}

get fun `test nft v1 editable collection rejects unauthorized content change`() {
    val collection = mainnetNftV1EditableCollection();
    val sender = testing.treasury("nft-v1-editable-collection-unauthorized-content-change");
    val before = collection.getCollectionData();
    val royalty = collection.royaltyParams();

    val txs = collection.sendNftV1ChangeContent(
        sender.address,
        3,
        { collectionMetadata: before.collectionMetadata, commonContent: createEmptyCell() },
        royalty,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<NftV1ChangeContent>({
        from: sender.address,
        to: collection.address,
        exitCode: NftV1CollectionErrors.UnauthorizedAdmin,
    });
    expect(collection.getCollectionData().collectionMetadata.hash()).toEqual(
        before.collectionMetadata.hash(),
    );
}
