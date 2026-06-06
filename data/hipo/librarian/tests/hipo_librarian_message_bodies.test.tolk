import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_librarian.types"

const EXPECTED_ADD_LIBRARY_CODE_HASH = 0xb79bd205f18c356092a907ca31fe0e379bde1b86a4caf36d8797849038ab2a7a
const EXPECTED_REMOVE_LIBRARY_CODE_HASH = 0x5f87521f495c0af9a270f8849818077c340728d2f4ea78dba2543a2477250e9d

get fun `test hipo librarian decodes toncenter add library body`() {
    val txHash = "ma96KYUEQLV9teGa3XpyDL+fVPN4aKFsBw7zqTTtjOI=";
    val txLt = "45623615000001";
    val bodyBoc = "te6cckECGgEABLkAARhT0Ec+AAAAAAAAAAABART/APSkE/S88sgLAgIBYgMEAgLKBQYCASAVFgSZ1AdDTA/pAMNs8WAJxsI67ATHTHzHTH9M/MCGCEAUkx666jpqCEMGOhtLIyx/LP3D4RcgBzxYSbVhwgEDbPJEw4oIQDdYH47ow8gDjDoZDgcIAr+uW1wyMsHi7SGlwbyBCaWxsICOM8W+EFtnAF6qQymMFhvAiHAAOYxyJgBbyICywchbuYxzxfJgvCCo1N/8NvOfuw11p7cOhie5vF9gvNTpVP5qpbLC+POiViDB/QX2zyAQEQTcAdMfIYIQMnXfwrqOxDHTP/oAAfhn0gAB+Gb6QAH4ZfpAAfhk+gDR+EITxwXy4GchjpxwghAFE42RyMsfEss/ywJw+EXIAc8WE21ac9s8kVvi4CGCEG+J9eO64wIhghAfBFN6uuMCIYIQBN7RSLoOCQoLAQTbPA8BijHTP9H4QhLHBfLgZ/hD8tBq+CP4Y/hB+EaCEIQPY2nIyx8Tyz/4R/oCEsoA+EXPFvhEzxbLP3D4QsgBzxYSbVhwgwbbPA4BXDHTP9H4RVIgxwXy4Gf4Q/LgZ4sC+GWCENUydtvIyx/LP3ACyAHPFm1YcIBC2zwOA8KOxjHTP/pA1NIA0fhFFccF8uBnA5LwOZFt4vhD+EGCEAUkx67Iyx8Vyz8Uy//4Rc8WFMwSyz8S9AB/AsgBzxZtWHCAQNs88gDgIYIQ0MO/6rrjAgGCEC/LJqK64wJb8sBrDgwNAYAx0z/6QNTSANGS8DmRbeL4Q/hBghAN1gfjyMsfFss/Fcv/UAXPFvhFzxbMEss/EvQAfwLIAc8WbVhwgEDbPPIADgFM0z/R+EGCEIt3FzXIyx8Syz/L//hCzxZwAsgBzxZtWHCAQNs88gAOAIRwBpKAGJKAEOLIywVQBc8XAfoCFMtoASBulTBwAcsAl3JYywEBzxfiWCDPMYECAbuXcFjLAAHPF5TJAfQA4skB+wAAQPhG+EP4QcjLP/hCzxbLH/hEzxb4Rc8WygD4R/oCye1UAfRwyMsH+Eabi5V2l0aGRyYXcgiai4RGVwb3NpdCCOLPFvhHbXCOHQJ6qQymMFhvAgKkIMAJmIAuUANvAgKk3iHAABAj5jKTIcEJmIAwAW8CAaQB6CHACZiALgFvAgGkAd4BwAqVgDABbwLeyJgBbyICywchbuYxzxf4RhIC/oLwyQRvejetDqfO5zNVmE+lQomC+LN8j3vOyR96xxp80QRYgwf0F3DIyweNCFodHRwczovL2FwcC5oaXBvLmZpbmFuY2UvYmlsbC5wbmeDPFsmC8GEF1sx2r0ADJelNWIzlEb5b/btztDfcUeykORfXpD49WIMH9Bf4Q+MAcMgTFAAml4tSBoVE9OiWi0IFRPTo4s8WyQBscMjLB4tmhpZGRlbozxbJgvDTOuBgQwNtDRw74nIBrBXuTHPajNt8jzRizjCAJglawFiDB/QXAArLB/QAyQIBWBcYASe8fn7Z58IkWBY4LZ/CD8IXwi+BzBkBDbVjG2efCFAZAQ23sHtnnwhwGQBO7UTQ0z8B+GH6QAH4YtMfAfhj+kAB+GT6QAH4ZdIAAfhm+gAB+GfRhnW0GQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoLibrarianAddLibrary.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.code.hash()).toEqual(EXPECTED_ADD_LIBRARY_CODE_HASH);

    println("HIPO_LIBRARIAN_ADD_LIBRARY_TX={} LT={}", txHash, txLt);
}

get fun `test hipo librarian decodes toncenter remove library body`() {
    val txHash = "cVAdKWwcXfoGF0y9/fI7PGjcLEzYqNT5HR8f0EF/ALs=";
    val txLt = "45644143000001";
    val bodyBoc = "te6cckEBAQEALgAAWGvQzlIAAAAAAAAAAF+HUh9JXAr5onD4hJgYB3w0ByjS9Op426JUOiR3JQ6drBw5YA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoLibrarianRemoveLibrary.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.codeHash).toEqual(EXPECTED_REMOVE_LIBRARY_CODE_HASH);

    println("HIPO_LIBRARIAN_REMOVE_LIBRARY_TX={} LT={}", txHash, txLt);
}

get fun `test hipo librarian decodes toncenter top up body`() {
    val txHash = "Kyvr43dCHYTwiFnlrsZwP3zpD+/1S0mXRdfg7zgdi3Q=";
    val txLt = "54248106000001";
    val bodyBoc = "te6cckEBAQEADgAAGFNyFYwAAAAAAAAAAJeLa9k=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoLibrarianTopUp.fromCell(body);

    expect(decoded.queryId).toEqual(0);

    println("HIPO_LIBRARIAN_TOP_UP_TX={} LT={}", txHash, txLt);
}
