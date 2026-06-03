import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/getgems_nft_v2_item.types"
import "../wrappers/GetgemsNftItemV2.gen"
import "./test_utils"

get fun `test getgems nft item v2 mainnet getters and storage`() {
    val item = mainnetGetgemsNftItemV2();
    val storage = loadGetgemsNftItemV2StorageFromFork(item);
    val data = item.getNftData();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(data.ownerAddress).toBeNotNull();
    expect(data.ownerAddress!).toEqual(storage.ownerAddress);
    expect(data.content).toBeNotNull();
    expect(data.content!.hash()).toEqual(storage.content.hash());

    println("GETGEMS_NFT_ITEM_V2_ADDRESS={}", item.address);
    println("GETGEMS_NFT_ITEM_V2_STORAGE={}", storage);
    println("GETGEMS_NFT_ITEM_V2_DATA={}", data);
}

get fun `test getgems nft item v2 mainnet get static data succeeds`() {
    val item = mainnetGetgemsNftItemV2();
    val sender = testing.treasury("getgems-nft-v2-item-get-static-data");

    val txs = item.sendGetgemsNftItemV2GetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<GetgemsNftItemV2GetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test getgems nft item v2 rejects unauthorized transfer`() {
    val item = mainnetGetgemsNftItemV2();
    val sender = testing.treasury("getgems-nft-v2-item-unauthorized-transfer");
    val before = item.getNftData();

    val txs = item.sendGetgemsNftItemV2Transfer(
        sender.address,
        2,
        sender.address,
        sender.address,
        null,
        0,
        getgemsNftV2InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<GetgemsNftItemV2Transfer>({
        from: sender.address,
        to: item.address,
        exitCode: GetgemsNftItemV2Errors.UnauthorizedOwner,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}
