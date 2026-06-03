import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_sale_legacy.types"

get fun `test getgems nft sale legacy decodes toncenter empty buy body`() {
    val txHash = "EgkXjCdUg7kGUYt02ODSr5nAWpS+Xtei2kTidk7My3w=";
    val txLt = "26819119000005";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val emptyBuy = GetgemsNftSaleLegacyEmptyBuy.fromCell(body);
    expect(emptyBuy.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_SALE_LEGACY_TONCENTER_EMPTY_BUY_TX={} LT={}", txHash, txLt);
}
