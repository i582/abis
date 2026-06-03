import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/nft_v1_editable_item.types"
import "../wrappers/NftV1EditableItem.gen"
import "./test_utils"

get fun `test nft v1 editable item mainnet getters and storage`() {
    val item = mainnetNftV1EditableItem();
    val storage = loadNftV1EditableItemStorageFromFork(item);
    val data = item.getNftData();
    val editor = item.getEditor();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(data.ownerAddress).toBeNotNull();
    expect(data.ownerAddress!).toEqual(storage.ownerAddress);
    expect(data.content).toBeNotNull();
    expect(data.content!.hash()).toEqual(storage.content.hash());
    expect(editor).toEqual(storage.editorAddress);

    println("NFT_V1_EDITABLE_ITEM_ADDRESS={}", item.address);
    println("NFT_V1_EDITABLE_ITEM_STORAGE={}", storage);
    println("NFT_V1_EDITABLE_ITEM_DATA={}", data);
    println("NFT_V1_EDITABLE_ITEM_EDITOR={}", editor);
}

get fun `test nft v1 editable item mainnet get static data succeeds`() {
    val item = mainnetNftV1EditableItem();
    val sender = testing.treasury("nft-v1-editable-item-get-static-data");

    val txs = item.sendNftV1EditableGetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<NftV1EditableGetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test nft v1 editable item rejects unauthorized edit content`() {
    val item = mainnetNftV1EditableItem();
    val sender = testing.treasury("nft-v1-editable-item-unauthorized-edit-content");
    val before = item.getNftData();

    val txs = item.sendNftV1EditableEditContent(
        sender.address,
        2,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<NftV1EditableEditContent>({
        from: sender.address,
        to: item.address,
        exitCode: NftV1EditableItemErrors.UnauthorizedEditContent,
    });
    expect(item.getNftData().content!.hash()).toEqual(before.content!.hash());
}

get fun `test nft v1 editable item rejects unauthorized editorship transfer`() {
    val item = mainnetNftV1EditableItem();
    val sender = testing.treasury("nft-v1-editable-item-unauthorized-editorship-transfer");
    val beforeEditor = item.getEditor();

    val txs = item.sendNftV1EditableTransferEditorship(
        sender.address,
        3,
        sender.address,
        sender.address,
        null,
        0,
        nftV1InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<NftV1EditableTransferEditorship>({
        from: sender.address,
        to: item.address,
        exitCode: NftV1EditableItemErrors.UnauthorizedOwnerOrEditor,
    });
    expect(item.getEditor()).toEqual(beforeEditor);
}
