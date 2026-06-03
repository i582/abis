import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_fixprice_sale_v3r2.types"

get fun `test getgems sale v3r2 decodes toncenter empty buy body`() {
    val txHash = "+jtrQBOqIC2swZC9EriRmwmkIunUfTnupJ/d89HqoRw=";
    val txLt = "37314780000003";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val emptyBuy = GetgemsNftFixpriceSaleV3R2EmptyBuy.fromCell(body);
    expect(emptyBuy.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R2_TONCENTER_EMPTY_BUY_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v3r2 decodes toncenter accept coins body`() {
    val txHash = "xxaDfvBtqbKEc78UfMvoOT3qGbpLMqBvunQeZizQ14o=";
    val txLt = "37314757000007";
    val bodyBoc = "te6cckEBAQEADgAAGAAAAAEAAAGH3GVWw+OSncg=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();
    val decoded = GetgemsNftFixpriceSaleV3R2AcceptCoins.fromCell(body);

    expect(parsed.remainingBitsCount()).toEqual(96);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(decoded.queryId).toEqual(1683029841603);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R2_TONCENTER_ACCEPT_COINS_TX={} LT={}", txHash, txLt);
}

get fun `test getgems sale v3r2 decodes toncenter nft transfer out body`() {
    val txHash = "+jtrQBOqIC2swZC9EriRmwmkIunUfTnupJ/d89HqoRw=";
    val txLt = "37314780000003";
    val bodyBoc = "te6cckEBAQEAVgAAp1/MPRQAAAAAAAAAAIAPI6D8b1+ftl3DKAzgaf/BAOhCg0PJ5m14C56mz3B3X7AB5HQfjevz9su4ZQGcDT/4IB0IUGh5PM2vAXPU2e4O6/SAOThwCDc+C8Q=";
    val expectedBuyer = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV3R2NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(expectedBuyer);
    expect(decoded.responseAddress).toEqual(expectedBuyer);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(30000000);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R2_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}
