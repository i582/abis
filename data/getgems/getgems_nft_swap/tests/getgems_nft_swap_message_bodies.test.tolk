import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_swap.types"

fun expectEmptyInlineForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test getgems nft swap decodes toncenter ownership assigned body`() {
    val txHash = "8xCxDCJPiSf4xE0o4CEsbC4fyEzpCh8FcMZ4nFZT0hU=";
    val txLt = "38039740000006";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZEAAAAAAAAAAIAEjZAG+2c7XvDC+p0UW/euYvwQ5x44PgZZBLWqALjppog+zHmb";
    val expectedPreviousOwner = address("0:246C8037DB39DAF78617D4E8A2DFBD7317E08738F1C1F032C825AD5005C74D34");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftSwapOwnershipAssigned.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(expectedPreviousOwner);
    expectEmptyInlineForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_SWAP_TONCENTER_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test getgems nft swap decodes toncenter topup body`() {
    val txHash = "mX94mtlNUT32kL8bJAnsMDvtwP5DxnEglBQM7dnEVLM=";
    val txLt = "38039732000003";
    val bodyBoc = "te6cckEBAQEADgAAGAAAAAQAAAAAAAAAAEe98jI=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();
    val decoded = GetgemsNftSwapTopup.fromCell(body);

    expect(parsed.remainingBitsCount()).toEqual(96);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_SWAP_TONCENTER_TOPUP_TX={} LT={}", txHash, txLt);
}

get fun `test getgems nft swap decodes toncenter nft transfer out body`() {
    val txHash = "8xCxDCJPiSf4xE0o4CEsbC4fyEzpCh8FcMZ4nFZT0hU=";
    val txLt = "38039740000006";
    val bodyBoc = "te6cckEBAQEAUgAAn1/MPRQAAAAAAAAAAIAEjZAG+2c7XvDC+p0UW/euYvwQ5x44PgZZBLWqALjpppAAkbIA32zna94YX1Oii371zF+CHOPHB8DLIJa1QBcdNNAINEoiZA==";
    val expectedNewOwner = address("0:246C8037DB39DAF78617D4E8A2DFBD7317E08738F1C1F032C825AD5005C74D34");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftSwapNftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(expectedNewOwner);
    expect(decoded.responseAddress).toEqual(expectedNewOwner);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expectEmptyInlineForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_SWAP_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test getgems nft swap decodes toncenter trade completed body`() {
    val txHash = "8xCxDCJPiSf4xE0o4CEsbC4fyEzpCh8FcMZ4nFZT0hU=";
    val txLt = "38039740000006";
    val bodyBoc = "te6cckEBAQEADgAAGO8D0AkAAAAAAAAAAKDWJlE=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();
    val decoded = GetgemsNftSwapTradeCompleted.fromCell(body);

    expect(parsed.remainingBitsCount()).toEqual(96);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_SWAP_TONCENTER_TRADE_COMPLETED_TX={} LT={}", txHash, txLt);
}

get fun `test getgems nft swap decodes toncenter trade commission body`() {
    val txHash = "8xCxDCJPiSf4xE0o4CEsbC4fyEzpCh8FcMZ4nFZT0hU=";
    val txLt = "38039740000006";
    val bodyBoc = "te6cckEBAQEADgAAGIK9jyoAAAAAAAAAAI12Z9M=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();
    val decoded = GetgemsNftSwapTradeCommission.fromCell(body);

    expect(parsed.remainingBitsCount()).toEqual(96);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_SWAP_TONCENTER_TRADE_COMMISSION_TX={} LT={}", txHash, txLt);
}
