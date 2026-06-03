import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/getgems_nft_v2_collection.types"
import "../wrappers/GetgemsNftCollectionV2.gen"
import "./test_utils"

get fun `test getgems nft collection v2 mainnet getters and storage`() {
    val collection = mainnetGetgemsNftCollectionV2();
    val storage = loadGetgemsNftCollectionV2StorageFromFork(collection);
    val storedContent = storage.content.load();
    val storedRoyalty = storage.royaltyParams.load();
    val data = collection.getCollectionData();
    val royalty = collection.royaltyParams();
    val secondOwner = collection.getSecondOwnerAddress();
    val nftAddress = collection.getNftAddressByIndex(storage.nextItemIndex as int);
    val fullContent = collection.getNftContent(storage.nextItemIndex as int, createEmptyCell());

    expect(scripts.isContractDeployed(collection.address)).toBeTrue();
    expect(data.nextItemIndex).toEqual(storage.nextItemIndex as int);
    expect(data.collectionMetadata.hash()).toEqual(storedContent.collectionMetadata.hash());
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(royalty.numerator).toEqual(storedRoyalty.numerator);
    expect(royalty.denominator).toEqual(storedRoyalty.denominator);
    expect(royalty.royaltyAddress).toEqual(storedRoyalty.royaltyAddress);
    expect(secondOwner).toEqual(storage.secondOwnerAddress);

    println("GETGEMS_NFT_COLLECTION_V2_ADDRESS={}", collection.address);
    println("GETGEMS_NFT_COLLECTION_V2_STORAGE={}", storage);
    println("GETGEMS_NFT_COLLECTION_V2_DATA={}", data);
    println("GETGEMS_NFT_COLLECTION_V2_ROYALTY={}", royalty);
    println("GETGEMS_NFT_COLLECTION_V2_SECOND_OWNER={}", secondOwner);
    println("GETGEMS_NFT_COLLECTION_V2_NEXT_ITEM_ADDRESS={}", nftAddress);
    println("GETGEMS_NFT_COLLECTION_V2_FULL_CONTENT_HASH={}", fullContent.hash());
}

get fun `test getgems nft collection v2 mainnet royalty request succeeds`() {
    val collection = mainnetGetgemsNftCollectionV2();
    val sender = testing.treasury("getgems-nft-v2-collection-royalty-request");

    val txs = collection.sendGetgemsNftCollectionV2GetRoyaltyParams(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<GetgemsNftCollectionV2GetRoyaltyParams>({
        from: sender.address,
        to: collection.address,
        exitCode: 0,
    });
}

get fun `test getgems nft collection v2 rejects unauthorized second owner change`() {
    val collection = mainnetGetgemsNftCollectionV2();
    val sender = testing.treasury("getgems-nft-v2-collection-unauthorized-second-owner");
    val before = collection.getSecondOwnerAddress();

    val txs = collection.sendGetgemsNftCollectionV2ChangeSecondOwner(
        sender.address,
        2,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<GetgemsNftCollectionV2ChangeSecondOwner>({
        from: sender.address,
        to: collection.address,
        exitCode: GetgemsNftCollectionV2Errors.UnauthorizedOwnerOrSecondOwner,
    });
    expect(collection.getSecondOwnerAddress()).toEqual(before);
}
