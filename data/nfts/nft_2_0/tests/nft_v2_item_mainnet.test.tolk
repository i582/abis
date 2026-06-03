import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/nft_v2_item.types"
import "../wrappers/NftV2Item.gen"
import "./test_utils"

fun assertNftV2ItemGetters(item: NftV2Item, label: string) {
    val storage = loadNftV2ItemStorageFromFork(item);
    val data = item.getNftData();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(data.ownerAddress).toBeNotNull();
    expect(data.ownerAddress!).toEqual(storage.ownerAddress);
    expect(data.content).toBeNotNull();
    expect(data.content!.hash()).toEqual(storage.content.hash());

    println("NFT_V2_ITEM_LABEL={}", label);
    println("NFT_V2_ITEM_ADDRESS={}", item.address);
    println("NFT_V2_ITEM_STORAGE={}", storage);
    println("NFT_V2_ITEM_DATA={}", data);
}

get fun `test nft v2 item mainnet getters and storage`() {
    assertNftV2ItemGetters(mainnetNftV2Item(), "standard");
}

get fun `test nft v2 simple item mainnet getters and storage`() {
    assertNftV2ItemGetters(mainnetNftV2SimpleItem(), "simple_schema");
}

get fun `test nft v2 item mainnet get static data succeeds`() {
    val item = mainnetNftV2Item();
    val sender = testing.treasury("nft-v2-item-get-static-data");

    val txs = item.sendNftV2GetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<NftV2GetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test nft v2 item rejects unauthorized transfer`() {
    val item = mainnetNftV2Item();
    val sender = testing.treasury("nft-v2-item-unauthorized-transfer");
    val before = item.getNftData();

    val txs = item.sendNftV2Transfer(
        sender.address,
        2,
        sender.address,
        sender.address,
        null,
        0,
        nftV2InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<NftV2Transfer>({
        from: sender.address,
        to: item.address,
        exitCode: NftV2ItemErrors.UnauthorizedOwner,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}
