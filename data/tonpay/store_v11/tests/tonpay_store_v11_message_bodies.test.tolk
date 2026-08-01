import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonpay_store_v11.types"

get fun `test tonpay store v11 decodes real request purchase body`() {
    val txHash = "2f8nzca2FmhKG09Fq9GYECwBm2gB4YDa2MG4b/PJyfY=";
    val txLt = "52312974000001";
    val bodyBoc = "te6cckEBAwEARAACKDa3lbUAAAAAAAAAAAAAAAAGRTmAAQIASAAAAAAxNDc2LjEuMS5iSXJrWm5UY2psbGduSVlLWUJkaUFEeQAIAAAAALKuLqo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonpayStoreV11RequestPurchase.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(105200000);
    expect(TonpayStoreV11Text.fromCell(decoded.invoiceId).value.remainingBitsCount()).toEqual(256);
    expect(TonpayStoreV11Text.fromCell(decoded.metadata).value.remainingBitsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("TONPAY_STORE_REQUEST_PURCHASE_TX={} LT={}", txHash, txLt);
}

get fun `test tonpay store v11 decodes real outgoing invoice payment body`() {
    val txHash = "2f8nzca2FmhKG09Fq9GYECwBm2gB4YDa2MG4b/PJyfY=";
    val txLt = "52312974000001";
    val bodyBoc = "te6cckEBAQEAMAAAW/U6AtMAAAAAAAAAAIAcKzCJUA6nR8C9Z4wNXSAOxRbZy4CD3ZLZFc09XsWcMjDhsuua";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonpayStoreV11PayInvoice.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.payer).toEqual(
        address("0:E159844A80753A3E05EB3C606AE9007628B6CE5C041EEC96C8AE69EAF62CE191"),
    );
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("TONPAY_STORE_PAY_INVOICE_TX={} LT={}", txHash, txLt);
}
