import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/scaled_ui_jetton_master.types"

get fun `test scaled ui decodes latest display multiplier changed body`() {
    val txHash = "Roilf48HTDw/o/pRYTtx26I8vSpUI/FygG7yQeyB4tU=";
    val txLt = "81604877000003";
    val bodyBoc = "te6cckEBAQEAFAAAI6w5JZgwOah1mb4Jgca/UmNAEO1ziLI=";
    val decoded = ScaledUiDisplayMultiplierChanged.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.numerator).toEqual(7924461287361);
    expect(decoded.denominator).toEqual(7812500000000);
    expect(decoded.comment).toBeNull();

    println("SCALED_UI_LATEST_EVENT_TX={} LT={}", txHash, txLt);
}

get fun `test scaled ui decodes initialization display multiplier changed body`() {
    val txHash = "t0JIkGiAyXdmHTULjktnZOiCaoocpnyq9Va2HBsZ3Y0=";
    val txLt = "63532751000003";
    val bodyBoc = "te6cckEBAgEAGwABD6w5JZgICEBwAQAcaW5pdGlhbGl6YXRpb25RxsPj";
    val decoded = ScaledUiDisplayMultiplierChanged.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.numerator).toEqual(1);
    expect(decoded.denominator).toEqual(1);
    expect(decoded.comment).toEqual("initialization");

    println("SCALED_UI_INITIALIZATION_EVENT_TX={} LT={}", txHash, txLt);
}
