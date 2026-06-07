import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/getgems_nft_v2_editable_item.types"
import "../wrappers/GetgemsNftEditableItemV2.gen"

get fun `test getgems nft editable item v2 mainnet getters and storage`() {
    val item = mainnetGetgemsNftEditableItemV2();
    val storage = loadGetgemsNftEditableItemV2StorageFromFork(item);
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

    println("GETGEMS_NFT_EDITABLE_ITEM_V2_ADDRESS={}", item.address);
    println("GETGEMS_NFT_EDITABLE_ITEM_V2_STORAGE={}", storage);
    println("GETGEMS_NFT_EDITABLE_ITEM_V2_DATA={}", data);
    println("GETGEMS_NFT_EDITABLE_ITEM_V2_EDITOR={}", editor);
}

get fun `test getgems nft editable item v2 mainnet get static data succeeds`() {
    val item = mainnetGetgemsNftEditableItemV2();
    val sender = testing.treasury("getgems-nft-v2-editable-item-get-static-data");

    val txs = item.sendGetgemsNftEditableItemV2GetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<GetgemsNftEditableItemV2GetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test getgems nft editable item v2 rejects unauthorized edit content`() {
    val item = mainnetGetgemsNftEditableItemV2();
    val sender = testing.treasury("getgems-nft-v2-editable-item-unauthorized-edit");
    val before = item.getNftData();

    val txs = item.sendGetgemsNftEditableItemV2EditContent(
        sender.address,
        2,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<GetgemsNftEditableItemV2EditContent>({
        from: sender.address,
        to: item.address,
        exitCode: GetgemsNftEditableItemV2Errors.UnauthorizedEditContent,
    });
    expect(item.getNftData().content!.hash()).toEqual(before.content!.hash());
}

get fun `test getgems nft editable item v2 rejects unauthorized transfer editorship`() {
    val item = mainnetGetgemsNftEditableItemV2();
    val sender = testing.treasury("getgems-nft-v2-editable-item-unauthorized-editorship");
    val before = item.getEditor();

    val txs = item.sendGetgemsNftEditableItemV2TransferEditorship(
        sender.address,
        3,
        sender.address,
        sender.address,
        null,
        0,
        getgemsNftV2InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<GetgemsNftEditableItemV2TransferEditorship>({
        from: sender.address,
        to: item.address,
        exitCode: GetgemsNftEditableItemV2Errors.UnauthorizedOwnerOrEditor,
    });
    expect(item.getEditor()).toEqual(before);
}
