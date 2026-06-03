import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_fixprice_sale_v3r3.types"

get fun `test getgems sale v3r3 decodes toncenter empty buy body`() {
    val txHash = "wLqDjW72VC5GlxTxfLp3Qa03tL5LyPuxXzuUL/5+xsU=";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val emptyBuy = GetgemsNftFixpriceSaleV3R3EmptyBuy.fromCell(body);
    expect(emptyBuy.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R3_TONCENTER_EMPTY_BUY_TX={}", txHash);
}

get fun `test getgems sale v3r3 decodes toncenter nft transfer out body`() {
    val txHash = "wLqDjW72VC5GlxTxfLp3Qa03tL5LyPuxXzuUL/5+xsU=";
    val bodyBoc = "te6cckEBAQEAVgAAp1/MPRQAAAAAAAAAAIAfwdxqys8PM0mSewvgBiykNpugTR7x0B7zLKzO5lZpAFAD+DuNWVnh5mkyT2F8AMWUhtN0CaPeOgPeZZWZ3MrNIAiAOThwCGJaOlQ=";
    val expectedBuyer = address("0:FE0EE3565678799A4C93D85F00316521B4DD0268F78E80F79965667732B34802");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftFixpriceSaleV3R3NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(expectedBuyer);
    expect(decoded.responseAddress).toEqual(expectedBuyer);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(30000000);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();

    println("GETGEMS_NFT_FIXPRICE_SALE_V3R3_TONCENTER_NFT_TRANSFER_TX={}", txHash);
}
