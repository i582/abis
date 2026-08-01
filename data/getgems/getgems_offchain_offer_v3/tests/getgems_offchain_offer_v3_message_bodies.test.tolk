import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_offchain_offer_v3.types"

get fun `test offchain offer v3 decodes real cancel request body`() {
    val txHash = "F05oqjQykBUQrjSVVzaGc+rlIohV8Z6AHs3BETYhbL0=";
    val txLt = "94008584000001";
    val source = "0:178D565685F095557FD695B93F522BEF75AE396F8FC4D3B6053FA312454C1523";
    val destination = "0:F0190EEA96E3A8ADCEC4A9A36B8A1E6277889F3EE51D5CFBC2360C2146394D82";
    val bodyBoc = "te6cckEBAQEADgAAGJ5Ujwp2pIbu/u4o7X72ql8=";
    val body = parseCellFromBase64(bodyBoc);
    val cancel = GetgemsOffchainOfferV3Cancel.fromCell(body);

    expect(cancel.queryId).toEqual(8549106353693403373);
    expect(cancel.toCell().hash()).toEqual(body.hash());
    println(
        "GETGEMS_OFFCHAIN_OFFER_V3_CANCEL_TX={} LT={} SOURCE={} DESTINATION={}",
        txHash,
        txLt,
        source,
        destination,
    );
}

get fun `test offchain offer v3 decodes real cancellation acknowledgement body`() {
    val txHash = "K+m9RdwRf6gS83ZEcEOxPWxA9crzqi+Lx5QYMbEUpTo=";
    val txLt = "94008585000040";
    val source = "0:7771A51840B8355E1DDC7E14DFF250DD6B7562DF5B945229CBFE249778F8DACE";
    val destination = "0:178D565685F095557FD695B93F522BEF75AE396F8FC4D3B6053FA312454C1523";
    val bodyBoc = "te6cckEBAQEADgAAGKipraV2pIbuyzQk3uoBmFE=";
    val body = parseCellFromBase64(bodyBoc);
    val cancelled = GetgemsOffchainOfferV3OfferWasCancelled.fromCell(body);

    expect(cancelled.queryId).toEqual(8549106352825574622);
    expect(cancelled.toCell().hash()).toEqual(body.hash());
    println(
        "GETGEMS_OFFCHAIN_OFFER_V3_CANCELLED_TX={} LT={} SOURCE={} DESTINATION={}",
        txHash,
        txLt,
        source,
        destination,
    );
}

get fun `test offchain offer v3 decodes real empty close refund body`() {
    val txHash = "O8kT3fWgGQyNPETEZEVQpofiCZ8YD0PBMetEzU1s0Ug=";
    val txLt = "65816293000001";
    val source = "0:067590126EDF36A1EF2249BEFA4E1BFCF44787D7625AF2DB020BABE2702C6B25";
    val destination = "0:59AE94BD33FBDBFCFF127B37AC46ACC99483BAE1857FBA510DEFD111C7E7ED9B";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val emptyBody = GetgemsOffchainOfferV3EmptyBody.fromCell(body);

    val bodySlice = body.beginParse();
    expect(emptyBody.toCell().hash()).toEqual(body.hash());
    expect(bodySlice.remainingBitsCount()).toEqual(0);
    expect(bodySlice.remainingRefsCount()).toEqual(0);
    println(
        "GETGEMS_OFFCHAIN_OFFER_V3_EMPTY_REFUND_TX={} LT={} SOURCE={} DESTINATION={}",
        txHash,
        txLt,
        source,
        destination,
    );
}
