import "@acton/fmt"
import "@acton/testing/expect"
import "../types/stakeed_minter.types"

const EXPECTED_OWNER = "0:24871B76A2A5529A79DBD5553482F31F94510FF08A050DB2F7DE0D237D897F49"
const EXPECTED_BURNER = "0:046BD5C4306FCAD98DBE66E0D6EF04D627CBE423CA78048AE10E796BBB5D6EF5"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(1);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test stakeed minter decodes real mint and internal transfer bodies`() {
    val mint = StakeedMinterMint.fromCell(parseCellFromBase64("te6cckEBAQEAOgAAbxZ0sKAAAAAAAAAnEYAEkONu1FSqU087eqqmkF5j8ooh/hFAobZe+8Gkb7Ev6SoEXLYqlIC+vCAB/gpPRA=="));
    val transfer = StakeedMinterJettonInternalTransfer.fromCell(parseCellFromBase64("te6cckEBAQEAOgAAbxeNRRkAAAAAAAAnEVAi5bFUogASQ427UVKpTTzt6qqaQXmPyiiH+EUChtl77waRvsS/pKAvrwgCfNJmHw=="));

    expect(mint.queryId).toEqual(10001);
    expect(mint.toAddress).toEqual(address(EXPECTED_OWNER));
    expect(mint.jettonAmount).toEqual(9367655754);
    expect(mint.forwardTonAmount).toEqual(100000000);
    expect(mint.totalTonAmount).toEqual(0);
    expect(transfer.queryId).toEqual(10001);
    expect(transfer.amount).toEqual(9367655754);
    expect(transfer.fromAddress).toBeNull();
    expect(transfer.responseAddress).toEqual(address(EXPECTED_OWNER));
    expect(transfer.forwardTonAmount).toEqual(100000000);
    expectInlineEmptyForwardPayload(transfer.forwardPayload);
}

get fun `test stakeed minter decodes real burn notification and burned body`() {
    val burn = StakeedMinterBurnNotification.fromCell(parseCellFromBase64("te6cckEBAgEAWgABp3vdl94AAAAAAAAAAEu4uu+YAAjXq4hg35WzG3zNwa3eCaxPl8hHlPAJFcIc8td2ut3rAAEa9XEMG/K2Y2+ZuDW7wTWJ8vkI8p4BIrhDnlru11u9cAEAASDcfH/C"));
    val burned = StakeedMinterJettonsBurned.fromCell(parseCellFromBase64("te6cckEBAQEAVgAApzGbDNwAAAAAAAAAAEu4uu+YAAjXq4hg35WzG3zNwa3eCaxPl8hHlPAJFcIc8td2ut3rAAEa9XEMG/K2Y2+ZuDW7wTWJ8vkI8p4BIrhDnlru11u9SMd5vW0="));

    expect(burn.queryId).toEqual(0);
    expect(burn.jettonAmount).toEqual(3146493689);
    expect(burn.fromAddress).toEqual(address(EXPECTED_BURNER));
    expect(burn.responseAddress).toEqual(address(EXPECTED_BURNER));
    expect(burn.customPayload).toBeNotNull();
    expect(burned.queryId).toEqual(0);
    expect(burned.jettonAmount).toEqual(3146493689);
    expect(burned.fromAddress).toEqual(address(EXPECTED_BURNER));
    expect(burned.responseAddress).toEqual(address(EXPECTED_BURNER));
    expect(burned.customPayloadTail.remainingBitsCount()).toEqual(2);
    expect(burned.customPayloadTail.remainingRefsCount()).toEqual(0);
}
