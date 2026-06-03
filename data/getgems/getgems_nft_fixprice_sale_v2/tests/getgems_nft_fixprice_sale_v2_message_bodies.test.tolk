import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_fixprice_sale_v2.types"

get fun `test getgems sale v2 decodes toncenter empty buy body`() {
    val txHash = "4MEryALBZv8si8Vu5bID/b780nOCKV82THgJ+W2DUGc=";
    val txLt = "27395901000005";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val emptyBuy = GetgemsNftFixpriceSaleV2EmptyBuy.fromCell(body);
    expect(emptyBuy.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V2_TONCENTER_EMPTY_BUY_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v2 decodes toncenter ownership assigned body`() {
    val txHash = "rkO6sswFXwVNSE9e1cWOI+Jl6LWqeVdL7iIXCi4beLQ=";
    val txLt = "27395908000005";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZEAAAAAAAAAAIAPI6D8b1+ftl3DKAzgaf/BAOhCg0PJ5m14C56mz3B3X6hXddC4";
    val expectedPreviousOwner = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV2OwnershipAssigned.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(expectedPreviousOwner);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_FIXPRICE_SALE_V2_TONCENTER_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v2 decodes toncenter cancel sale body`() {
    val txHash = "9s3ic9Q3O5jNfOTv72Vg8fk1CEpO55LQFRkJHg25Rfw=";
    val txLt = "28918372000003";
    val bodyBoc = "te6cckEBAQEADgAAGAAAAAMAAAAAAAAAAF1zkvU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV2CancelSale.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V2_TONCENTER_CANCEL_SALE_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v2 decodes toncenter nft transfer out body`() {
    val txHash = "9s3ic9Q3O5jNfOTv72Vg8fk1CEpO55LQFRkJHg25Rfw=";
    val txLt = "28918372000003";
    val bodyBoc = "te6cckEBAQEAUgAAn1/MPRQAAAAAAAAAAIAPI6D8b1+ftl3DKAzgaf/BAOhCg0PJ5m14C56mz3B3X7AB5HQfjevz9su4ZQGcDT/4IB0IUGh5PM2vAXPU2e4O6/QIvLNqoQ==";
    val expectedOwner = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV2NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(expectedOwner);
    expect(decoded.responseAddress).toEqual(expectedOwner);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_FIXPRICE_SALE_V2_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}
