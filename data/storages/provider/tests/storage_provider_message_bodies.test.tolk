import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storage_provider.types"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test storage provider decodes toncenter update storage params body`() {
    val txHash = "D2b/AmdNOCaP3VVQnQ2+1PbAXn92RDPXWEcHCfTix+0=";
    val txLt = "38390813000003";
    val bodyBoc = "te6cckEBAQEAJwAASVTL8ZsAAAAAAAAAAKHc1lAAAAqMAAAAAAAAACAAAAAAAdzWUASnpC8g";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StorageProviderUpdateStorageParams.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.acceptNewContracts).toBeTrue();
    expect(decoded.ratePerMbDay).toEqual(1000000000);
    expect(decoded.maxSpan).toEqual(86400);
    expect(decoded.minimalFileSize).toEqual(1024);
    expect(decoded.maximalFileSize).toEqual(1000000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORAGE_PROVIDER_UPDATE_PARAMS_TX={} LT={}", txHash, txLt);
}

get fun `test storage provider decodes toncenter signed external body`() {
    val txHash = "wYILmwY7neyxmoMioP/L3JlFX/RAsjXcBdU0BVDbocg=";
    val txLt = "38390813000001";
    val bodyBoc = "te6cckEBAgEAqwABmjpvkquqyGyorPsuURpyjBCaj+5ovAlVY5WG5ro9rx+zzEBvD5LCGA7Z/TFZL4+XW3+L8wNgxTLXTvxQEwvWFgEAAAAAZIWrDgAAAAEDAQCxMgBiMSM19j1sPYSX6tTE4SPmZV1muM1KpACH3HQbz19O+CAvrwgAAAAAAAAAAAAAAAAAAFTL8ZsAAAAAAAAAAKHc1lAAAAqMAAAAAAAAACAAAAAAAdzWUAQeJ4xN";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StorageProviderSignedExternal.fromCell(body);
    var messages = decoded.messages;

    expect(decoded.subwallet).toEqual(0);
    expect(decoded.validUntil).toEqual(1686481678);
    expect(decoded.msgSeqno).toEqual(1);
    expect(messages.remainingBitsCount()).toEqual(8);
    expect(messages.remainingRefsCount()).toEqual(1);
    expect(messages.loadUint(8)).toEqual(3);
    val outbound = messages.loadRef();
    expect(
        outbound.hash(),
    ).toEqual(68775244706494241510735699739358728299814528923069484497345553015400313282628);
    expectNoTail(mutate messages);

    println("STORAGE_PROVIDER_SIGNED_EXTERNAL_TX={} LT={}", txHash, txLt);
}
