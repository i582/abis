import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/invoices.types"

const INVOICE_NONE_ID = 0x02dfef3f7664437bbedc2cadd5f80181
const INVOICE_TONSITE_ID = 0x0198d27722cd75bea0bd597f596bdd5a
const INVOICE_TONSITE_ADDRESS = 0x4e63fe557473ad2a0f9303724b02f738e9c77e395f618c3921d779c268442de5

fun bits128FromUint(value: uint128): bits128 {
    var bits = beginCell().storeUint(value, 128).endCell().beginParse();
    return bits.loadBits(128) as bits128;
}

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectNoneUrl(url: PaymentProviderUrl): void {
    match (url) {
        None => {}
        Tonsite => {
            expect(false).toBeTrue();
        }
    }
}

fun expectTonsiteUrl(url: PaymentProviderUrl, expectedAddress: uint256): void {
    match (url) {
        None => {
            expect(false).toBeTrue();
        }
        Tonsite => {
            expect(url.address).toEqual(bits256FromUint(expectedAddress));
        }
    }
}

get fun `test invoices decodes real none invoice payload body`() {
    val txHash = "nP2xO6Kz1ZK2fkD9XrvgjBxozk2P7ujCGQqtazvKbRI=";
    val txLt = "66341510000003";
    val bodyBoc = "te6cckEBAQEAFwAAKnqiPrUC3+8/dmRDe77cLK3V+AGBAJpfNaI=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = InvoicePayload.fromCell(body);

    expect(decoded.id).toEqual(bits128FromUint(INVOICE_NONE_ID));
    expectNoneUrl(decoded.url);

    println("INVOICES_NONE_TX={} LT={}", txHash, txLt);
}

get fun `test invoices decodes real tonsite invoice payload body`() {
    val txHash = "3OTRjT9WM3tfCZ3w1pAAPC6oY8sLC9Ue0v2iNj5ATMY=";
    val txLt = "60736794000003";
    val bodyBoc = "te6cckEBAQEANwAAanqiPrUBmNJ3Is11vqC9WX9Za91aAU5j/lV0c60qD5MDcksC9zjpx345X2GMOSHXecJoRC3lK7Nv6w==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = InvoicePayload.fromCell(body);

    expect(decoded.id).toEqual(bits128FromUint(INVOICE_TONSITE_ID));
    expectTonsiteUrl(decoded.url, INVOICE_TONSITE_ADDRESS);

    println("INVOICES_TONSITE_TX={} LT={}", txHash, txLt);
}
