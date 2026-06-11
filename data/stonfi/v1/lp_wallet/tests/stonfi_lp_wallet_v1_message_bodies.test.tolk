import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_lp_wallet_v1.types"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate forwardPayload: RemainingBitsAndRefs): void {
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expectNoTail(forwardPayload);
}

get fun `test stonfi lp wallet v1 decodes toncenter internal transfer body`() {
    val txHash = "0Q5ejN+woBrWwdIzjRPV+bNoU17Twg+RD+dKjyP2bl8=";
    val txLt = "29588032000015";
    val bodyBoc = "te6cckEBAQEAVAAAoxeNRRkAAAAAAAAAACA+iAD2KIZWsnOiWODdFXIydF6Pdc+KsauLn6EO81sHJmtKoQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGgxhab";
    val expectedFrom = address("0:7B14432B5939D12C706E8AB9193A2F47BAE7C558D5C5CFD08779AD839335A550");
    val expectedResponse = address("0:0000000000000000000000000000000000000000000000000000000000000000");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiLpWalletV1InternalTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(1000);
    expect(decoded.fromAddress).toEqual(expectedFrom);
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(expectedResponse);
    expect(decoded.forwardTonAmount).toEqual(0);
    var forwardPayload = decoded.forwardPayload;
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_LP_WALLET_V1_TONCENTER_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}
