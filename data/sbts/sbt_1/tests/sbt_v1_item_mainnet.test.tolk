import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/sbt_v1_item.types"
import "../wrappers/SbtV1Item.gen"

get fun `test sbt v1 item mainnet getters and storage`() {
    val item = mainnetSbtV1Item();
    val storage = loadSbtV1ItemStorageFromFork(item);
    val data = item.getNftData();
    val authorityAddress = item.getAuthorityAddress();
    val revokedTime = item.getRevokedTime();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(storage.itemIndex as int);
    expect(data.collectionAddress).toEqual(storage.collectionAddress);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.content).toBeNotNull();
    expect(data.content!.hash()).toEqual(storage.content.hash());
    if (storage.authorityAddress == null) {
        expect(authorityAddress).toBeNoneAddress();
    } else {
        expect(authorityAddress.castToInternal()).toEqual(storage.authorityAddress!);
    }
    expect(revokedTime).toEqual(storage.revokedAt);

    println("SBT_V1_ITEM_ADDRESS={}", item.address);
    println("SBT_V1_ITEM_STORAGE={}", storage);
    println("SBT_V1_ITEM_DATA={}", data);
    println("SBT_V1_ITEM_AUTHORITY={}", authorityAddress);
    println("SBT_V1_ITEM_REVOKED_AT={}", revokedTime);
}

get fun `test sbt v1 item mainnet get static data succeeds`() {
    val item = mainnetSbtV1Item();
    val sender = testing.treasury("sbt-v1-item-get-static-data");

    val txs = item.sendSbtV1ItemGetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<SbtV1ItemGetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test sbt v1 item mainnet request owner succeeds`() {
    val item = mainnetSbtV1Item();
    val sender = testing.treasury("sbt-v1-item-request-owner");

    val txs = item.sendSbtV1ItemRequestOwner(
        sender.address,
        2,
        sender.address,
        createEmptyCell(),
        false,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<SbtV1ItemRequestOwner>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });
}

get fun `test sbt v1 item rejects transfer`() {
    val item = mainnetSbtV1Item();
    val sender = testing.treasury("sbt-v1-item-rejected-transfer");
    val before = item.getNftData();

    val txs = item.sendSbtV1ItemTransfer(
        sender.address,
        3,
        sender.address,
        null,
        null,
        0,
        sbtV1InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<SbtV1ItemTransfer>({
        from: sender.address,
        to: item.address,
        exitCode: SbtV1ItemErrors.TransferRejected,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}

get fun `test sbt v1 item rejects unauthorized prove ownership`() {
    val item = mainnetSbtV1Item();
    val sender = testing.treasury("sbt-v1-item-unauthorized-prove");

    val txs = item.sendSbtV1ItemProveOwnership(
        sender.address,
        4,
        sender.address,
        createEmptyCell(),
        false,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<SbtV1ItemProveOwnership>({
        from: sender.address,
        to: item.address,
        exitCode: SbtV1ItemErrors.UnauthorizedOwnerOrAuthority,
    });
}
