import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_fixprice_sale_v4r1.types"

fun expectEmptyInlineForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test getgems sale v4r1 decodes toncenter jetton transfer notification body`() {
    val txHash = "KHgVMhKZ8hSjmXWemG32OmKwrC2/xD1mtEGilBVBs3o=";
    val txLt = "49497158000003";
    val bodyBoc = "te6cckEBAQEAMwAAYnNi0Jx2pIbuA6zP4THoSAgA8joPxvX5+2XcMoDOBp/8EA6EKDQ8nmbXgLnqbPcHdfo5oWuU";
    val expectedBuyer = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV4R1JettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(8549106349478039521);
    expect(decoded.amount).toEqual(2000000);
    expect(decoded.buyerAddress).toEqual(expectedBuyer);
    expectEmptyInlineForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "GETGEMS_NFT_FIXPRICE_SALE_V4R1_TONCENTER_JETTON_NOTIFICATION_TX={} LT={}",
        txHash,
        txLt,
    );
}

get fun `test getgems sale v4r1 decodes toncenter deploy jetton body`() {
    val txHash = "VEEikaaD8kd6gAMH4Mfl5dxm+G8u2XLDY5cftBwaBBk=";
    val txLt = "49476563000001";
    val bodyBoc = "te6cckEBAgEAuwAB2/tdv0d2pIbu/RJLXM/sOVzyPrmYW7QDyq6hLwTaOKyLvVxiY21NCbEwIWlAIkj8WiYK0M0qvWrMdHdlzSrXk438zFrNQMimrGiRAAyACwncw2W/4QbiLaH5ag8bJyyXl9OAv61Cg2N/lLrUh8MYAQCPoAdLvl+Zq2JFxq99AMvH2sLGCJcJqWmYJXgm8omcEy8miHc1lAEALETqZS1AkoWcZ9pE5Mo63WVlsOKJfWQKLFG/s3DYh3+g+ckvyw==";
    val expectedMarketplace = address("0:584EE61B2DFF0837116D0FCB5078D93964BCBE9C05FD6A141B1BFCA5D6A43E18");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV4R1DeployJetton.fromCell(body);

    expect(decoded.queryId).toEqual(8549106353662217052);
    expect(decoded.marketplaceAddress).toEqual(expectedMarketplace);
    expect(decoded.jettonPrices.isEmpty()).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_TONCENTER_DEPLOY_JETTON_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v4r1 decodes toncenter change price body`() {
    val txHash = "5cy3nYjoOhK2wTLhJAd2n+l8IXXA7N/ejMeZLmXmuz4=";
    val txLt = "49496763000001";
    val bodyBoc = "te6cckEBAgEAWQABGf0TX3t2pIbu0lEppQwBAI2gB0u+X5mrYkXGr30Ay8fawsYIlwmpaZgleCbyiZwTLyaGPQkBACxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/oAf8PqE=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV4R1ChangePrice.fromCell(body);

    expect(decoded.queryId).toEqual(8549106352944916901);
    expect(decoded.newTonPrice).toEqual(0);
    expect(decoded.newJettonPrices.isEmpty()).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_TONCENTER_CHANGE_PRICE_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v4r1 decodes toncenter nft transfer out body`() {
    val txHash = "KHgVMhKZ8hSjmXWemG32OmKwrC2/xD1mtEGilBVBs3o=";
    val txLt = "49497158000003";
    val bodyBoc = "te6cckEBAQEAUwAAoV/MPRR2pIbuA6zP4YAPI6D8b1+ftl3DKAzgaf/BAOhCg0PJ5m14C56mz3B3X7AB5HQfjevz9su4ZQGcDT/4IB0IUGh5PM2vAXPU2e4O6/QgKC0uWlA=";
    val expectedBuyer = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV4R1NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(8549106349478039521);
    expect(decoded.newOwnerAddress).toEqual(expectedBuyer);
    expect(decoded.responseAddress).toEqual(expectedBuyer);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(1);
    expectEmptyInlineForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v4r1 decodes toncenter jetton transfer out body`() {
    val txHash = "KHgVMhKZ8hSjmXWemG32OmKwrC2/xD1mtEGilBVBs3o=";
    val txLt = "49497158000003";
    val bodyBoc = "te6cckEBAQEAVgAAqA+KfqV2pIbuA6zP4THBOAgAwRBn6EK+6C7e6/7UBIDZx0/BKzlVacqGyoXNP5oicHUAHkdB+N6/P2y7hlAZwNP/ggHQhQaHk8za8Bc9TZ7g7r9CAnDpOYs=";
    val expectedDestination = address("0:608833F4215F74176F75FF6A02406CE3A7E0959CAAB4E5436542E69FCD11383A");
    val expectedResponseDestination = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV4R1JettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(8549106349478039521);
    expect(decoded.amount).toEqual(1840000);
    expect(decoded.destination).toEqual(expectedDestination);
    expect(decoded.responseDestination).toEqual(expectedResponseDestination);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(1);
    expectEmptyInlineForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V4R1_TONCENTER_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}
