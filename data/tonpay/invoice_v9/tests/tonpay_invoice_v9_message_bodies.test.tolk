import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonpay_invoice_v9.types"

get fun `test tonpay invoice v9 decodes real store payment body`() {
    val txHash = "pRg1iXZ38fyD2/eYUOdSc6oeS7IUJfWEnswLsF++rh4=";
    val txLt = "52312976000003";
    val bodyBoc = "te6cckEBAQEAMAAAW/U6AtMAAAAAAAAAAIAcKzCJUA6nR8C9Z4wNXSAOxRbZy4CD3ZLZFc09XsWcMjDhsuua";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonpayInvoiceV9Pay.fromCell(body);
    var payer = decoded.payerTail;

    expect(decoded.queryId).toEqual(0);
    expect(payer.loadAddress()).toEqual(
        address("0:E159844A80753A3E05EB3C606AE9007628B6CE5C041EEC96C8AE69EAF62CE191"),
    );
    expect(payer.remainingBitsCount()).toEqual(0);
    expect(payer.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("TONPAY_INVOICE_PAY_TX={} LT={}", txHash, txLt);
}

get fun `test tonpay invoice v9 decodes real outgoing payment memo`() {
    val txHash = "pRg1iXZ38fyD2/eYUOdSc6oeS7IUJfWEnswLsF++rh4=";
    val txLt = "52312976000003";
    val bodyBoc = "te6cckEBAQEAJgAASAAAAAAxNDc2LjEuMS5iSXJrWm5UY2psbGduSVlLWUJkaUFEeeiiOjE=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonpayInvoiceV9Text.fromCell(body);

    expect(decoded.value.remainingBitsCount()).toEqual(256);
    expect(decoded.value.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("TONPAY_INVOICE_MEMO_TX={} LT={}", txHash, txLt);
}
