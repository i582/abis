import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/verifier_source_item.types"

get fun `test decodes real verifier source item content body`() {
    val txHash = "HrVOP/pjfEmioyDzmCt81DN7ZT88KUy8KvnrIudGNNg=";
    val txLt = "85354652000024";
    val bodyBoc = "te6cckEBAQEARQAAhgFpcGZzOi8vYmFma3JlaWVpanJlc3pubHRkMmd5ZWpuYzZwZmg3N3JzbGZzM2FraHl3ZzR5N3Y0eTR5cXluaHMzZXGpz5MZ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = VerifierSourceItemContent.fromCell(body);

    expect(decoded.version).toEqual(1);
    expect(decoded.url.remainingBitsCount()).toEqual(528);
    expect(decoded.url.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("VERIFIER_SOURCE_ITEM_CONTENT_TX={} LT={}", txHash, txLt);
}
