import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/telemint_nft_item.types"
import "../wrappers/TelemintNftItem.gen"
import "./test_utils"

get fun `test telemint nft item mainnet getters and storage`() {
    val item = mainnetTelemintNftItem();
    val storage = loadTelemintNftItemStorageFromFork(item);
    val config = storage.config.load();
    val state = storage.state!.load();
    val data = item.getNftData();
    val auctionConfig = item.getTelemintAuctionConfig();
    val royalty = item.royaltyParams();
    val storedRoyalty = state.royaltyParams.load();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(config.itemIndex as int);
    expect(data.collectionAddress).toEqual(config.collectionAddress);
    expect(data.ownerAddress.castToInternal()).toEqual(state.ownerAddress!);
    expect(data.content).toBeNotNull();
    expect(data.content!.hash()).toEqual(state.content.load().nftContent.hash());
    expect(item.getTelemintTokenName()).toEqual("dage");
    expect(royalty.numerator).toEqual(storedRoyalty.numerator);
    expect(royalty.denominator).toEqual(storedRoyalty.denominator);
    expect(royalty.destination.castToInternal()).toEqual(storedRoyalty.destination!);

    println("TELEMINT_NFT_ITEM_ADDRESS={}", item.address);
    println("TELEMINT_NFT_ITEM_STORAGE={}", storage);
    println("TELEMINT_NFT_ITEM_DATA={}", data);
    println("TELEMINT_NFT_ITEM_AUCTION_CONFIG={}", auctionConfig);
    println("TELEMINT_NFT_ITEM_ROYALTY={}", royalty);
}

get fun `test telemint nft item mainnet get static data succeeds`() {
    val item = mainnetTelemintNftItem();
    val sender = testing.treasury("telemint-nft-item-get-static-data");

    val txs = item.sendTelemintNftItemGetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<TelemintNftItemGetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test telemint nft item rejects unauthorized transfer`() {
    val item = mainnetTelemintNftItem();
    val sender = testing.treasury("telemint-nft-item-unauthorized-transfer");
    val before = item.getNftData();

    val txs = item.sendTelemintNftItemTransfer(
        sender.address,
        2,
        sender.address,
        sender.address,
        null,
        0,
        telemintInlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<TelemintNftItemTransfer>({
        from: sender.address,
        to: item.address,
        exitCode: TelemintNftItemErrors.ForbiddenTransfer,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}
