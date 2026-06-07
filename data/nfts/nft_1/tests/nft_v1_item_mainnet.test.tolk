import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/nft_v1_item.types"
import "../wrappers/NftV1Item.gen"

fun assertNftV1ItemGetters(item: NftV1Item, label: string) {
    val storage = loadNftV1ItemStorageFromFork(item);
    val data = item.getNftData();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(data.ownerAddress).toBeNotNull();
    expect(data.ownerAddress!).toEqual(storage.ownerAddress);
    expect(data.content).toBeNotNull();
    expect(data.content!.hash()).toEqual(storage.content.hash());

    println("NFT_V1_ITEM_LABEL={}", label);
    println("NFT_V1_ITEM_ADDRESS={}", item.address);
    println("NFT_V1_ITEM_STORAGE={}", storage);
    println("NFT_V1_ITEM_DATA={}", data);
}

get fun `test nft v1 item mainnet getters and storage`() {
    assertNftV1ItemGetters(mainnetNftV1Item(), "standard");
}

get fun `test nft v1 simple item mainnet getters and storage`() {
    assertNftV1ItemGetters(mainnetNftV1SimpleItem(), "simple_schema");
}

get fun `test nft v1 item mainnet get static data succeeds`() {
    val item = mainnetNftV1Item();
    val sender = testing.treasury("nft-v1-item-get-static-data");

    val txs = item.sendNftV1GetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<NftV1GetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test nft v1 item rejects unauthorized transfer`() {
    val item = mainnetNftV1Item();
    val sender = testing.treasury("nft-v1-item-unauthorized-transfer");
    val before = item.getNftData();

    val txs = item.sendNftV1Transfer(
        sender.address,
        2,
        sender.address,
        sender.address,
        null,
        0,
        nftV1InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<NftV1Transfer>({
        from: sender.address,
        to: item.address,
        exitCode: NftV1ItemErrors.UnauthorizedOwner,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}
