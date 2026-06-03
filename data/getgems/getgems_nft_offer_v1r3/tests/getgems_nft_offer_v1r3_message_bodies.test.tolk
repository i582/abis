import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_offer_v1r3.types"

get fun `test getgems offer v1r3 decodes toncenter zero opcode cancel text body`() {
    val txHash = "tsspLJTjJqFGL8RkkMmTdrLSwbcJqsav7hVVScJvzUk=";
    val txLt = "45632572000003";
    val bodyBoc = "te6cckEBAQEADAAAFAAAAABjYW5jZWx5IUuu";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftOfferV1R3TextCommand.fromCell(body);
    var payload = decoded.payload;

    expect(decoded.toCell().hash()).toEqual(body.hash());
    expect(payload.remainingBitsCount()).toEqual(48);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadUint(48)).toEqual(0x63616e63656c);
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_OFFER_V1R3_TONCENTER_ZERO_OPCODE_CANCEL_TX={} LT={}", txHash, txLt);
}

get fun `test getgems offer v1r3 decodes toncenter empty owner refund body`() {
    val txHash = "tsspLJTjJqFGL8RkkMmTdrLSwbcJqsav7hVVScJvzUk=";
    val txLt = "45632572000003";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_OFFER_V1R3_TONCENTER_EMPTY_OWNER_REFUND_TX={} LT={}", txHash, txLt);
}
