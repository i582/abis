import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/dns_collection.types"

fun expectNoCollectionTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test dns collection decodes toncenter deploy domain body`() {
    val txHash = "aLFDFe8Job6RBabna8KoUsIgdYxdhA7nsFPxQjLbARk=";
    val txLt = "83244554000003";
    val bodyBoc = "te6cckEBAQEAFAAAJAAAAABrYW5lY2thLXV6YmVrYXdsIPQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsCollectionDeployDomain.fromCell(body);

    var domain = decoded.domain;
    expect(domain.remainingBitsCount()).toEqual(112);
    expect(domain.remainingRefsCount()).toEqual(0);
    expect(domain.loadUint(32)).toEqual(0x6b616e65);
    expect(domain.loadUint(32)).toEqual(0x636b612d);
    expect(domain.loadUint(32)).toEqual(0x757a6265);
    expect(domain.loadUint(16)).toEqual(0x6b61);
    expectNoCollectionTail(domain);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DNS_COLLECTION_TONCENTER_DEPLOY_TX={} LT={}", txHash, txLt);
}

get fun `test dns collection decodes toncenter fill up body`() {
    val txHash = "cicZCbNF0Jn4l/ZdLUDIxdWLDrNcuAerAPAZzLUiw40=";
    val txLt = "83243221000027";
    val bodyBoc = "te6cckEBAQEADgAAGDcP7FHv5G1U3JC4wkQsMHs=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsCollectionFillUp.fromCell(body);

    expect(decoded.queryId).toEqual(0xefe46d54dc90b8c2 as uint64);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DNS_COLLECTION_TONCENTER_FILL_UP_TX={} LT={}", txHash, txLt);
}
