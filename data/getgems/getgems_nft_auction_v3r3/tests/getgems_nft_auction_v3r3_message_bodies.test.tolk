import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_auction_v3r3.types"

get fun `test getgems nft auction v3r3 decodes toncenter cancel text command body`() {
    val txHash = "nTlKlXao31kpK6M5pk8O2zkaUVq397s5GJhHkO9qjNk=";
    val txLt = "45947608000003";
    val bodyBoc = "te6cckEBAQEADAAAFAAAAABjYW5jZWx5IUuu";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV3R3TextComment.fromCell(body);
    var text = decoded.text;

    expect(decoded.toCell().hash()).toEqual(body.hash());
    expect(text.remainingBitsCount()).toEqual(48);
    expect(text.remainingRefsCount()).toEqual(0);
    expect(text.loadUint(48)).toEqual(0x63616e63656c);
    expect(text.remainingBitsCount()).toEqual(0);
    expect(text.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V3R3_TONCENTER_CANCEL_TEXT_TX={} LT={}", txHash, txLt);
}

get fun `test getgems nft auction v3r3 decodes toncenter cancellation nft transfer body`() {
    val txHash = "nTlKlXao31kpK6M5pk8O2zkaUVq397s5GJhHkO9qjNk=";
    val txLt = "45947608000003";
    val bodyBoc = "te6cckEBAQEAUgAAn1/MPRQAACnKAtpmA4Afwdxqys8PM0mSewvgBiykNpugTR7x0B7zLKzO5lZpAFAD+DuNWVnh5mkyT2F8AMWUhtN0CaPeOgPeZZWZ3MrNIAgIWXQ4sw==";
    val expectedOwner = address("0:FE0EE3565678799A4C93D85F00316521B4DD0268F78E80F79965667732B34802");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV3R3NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.toCell().hash()).toEqual(body.hash());
    expect(decoded.queryId).toEqual(45947608000003);
    expect(decoded.newOwnerAddress).toEqual(expectedOwner);
    expect(decoded.responseAddress).toEqual(expectedOwner);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V3R3_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}
