import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_fixprice_sale_v3.types"

get fun `test getgems sale v3 decodes toncenter empty buy body`() {
    val txHash = "R1hwHE9MOB4PPt4ZUg/9VCt+mI0yjJ0xGcGAxNLGLC0=";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val emptyBuy = GetgemsNftFixpriceSaleV3EmptyBuy.fromCell(body);
    expect(emptyBuy.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V3_TONCENTER_EMPTY_BUY_TX={}", txHash);
}
