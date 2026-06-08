import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/pyth_oracle.types"

const EXPECTED_PARSE_REQUEST_BODY_HASH = 0x794a486207b7c8ef01aad93aff82ec4b792233e4937948405a26ff0873798d97
const EXPECTED_PARSE_RESPONSE_BODY_HASH = 0xca8befeb1c563507c7a846da1ae4db70b57043cb149cb9647e41c594a543b806
const EXPECTED_PARSE_RESPONSE_SENDER = "0:173F40F269F3B57C90EC4BB58AEC1CC1329925E673203127C1F459F85039719D"

fun expectOpcode(body: cell, expectedOpcode: uint32): void {
    val raw = body.beginParse();
    expect(raw.remainingBitsCount()).toBeGreater(31);
    expect(raw.preloadUint(32)).toEqual(expectedOpcode);
}

get fun `test pyth oracle decodes real parse price feed update request body`() {
    val txHash = "AUDTqAOG9MFchzr3+mcOgiEL7dXXWvKsLmfIMss11jU=";
    val txLt = "82354935000017";
    val bodyBoc = "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";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = PythParsePriceFeedUpdates.fromCell(body);

    expectOpcode(body, 0x00000005);
    expect(body.hash()).toEqual(EXPECTED_PARSE_REQUEST_BODY_HASH);
    expect(decoded.updateData.hash()).toBeGreater(0);
    expect(decoded.priceIds.hash()).toBeGreater(0);
    expect(decoded.minPublishTime).toBeGreater(0);
    expect(decoded.maxPublishTime).toBeGreater(decoded.minPublishTime);
    expect(decoded.targetAddress).toBeNotNull();
    expect(decoded.customPayload.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("PYTH_ORACLE_PARSE_REQUEST_TX={} LT={}", txHash, txLt);
}

get fun `test pyth oracle decodes real parse price feed update response body`() {
    val txHash = "AUDTqAOG9MFchzr3+mcOgiEL7dXXWvKsLmfIMss11jU=";
    val txLt = "82354935000017";
    val bodyBoc = "te6cckECEwEAAdAAAk0AAAAFA4AC5+geTT52r5IdiXaxXYOYJlMkvM5kBiT4Pos/CgcuM7ABAgJAPReEEo7qtZYexgZI/kl9OQHuvSEbf1Hkuw258CSXfSUDBAEYAAAABAAAAAAAAAAADgIABQYCQIljIXg4q0z1ytwXIgPB8Ldj+6pF80bY7lC6mUu8rDAmBwgAOAAAAAAGrHJAAAAAAAAAAAH////4AAAAAGomtZUAOAAAAAAGrGIsAAAAAAAAAAH////4AAAAAGomtZUCAAkKAUAribncj9+fNHCaWxBrRy8PObtsqc4EsP1/LpcWiOLlOwsAOAAAAAAKWMOdAAAAAAAEBMj////4AAAAAGomtZUAOAAAAAAKUno5AAAAAAAENzb////4AAAAAGomtZUCAAwNADgAAAAABfTNnQAAAAAAAM1l////+AAAAABqJrWVADgAAAAABfS6bAAAAAAAANmF////+AAAAABqJrWVAwAPEBEAEAAAAAAAAAAAAJMAAAAQTFM8AMqQBr0/sD01Xa7v+TskvpCvqm48oAc/9XIPioUskzJ4gALn6B5NPnavkh2JdrFdg5gmUyS8zmQGJPg+iz8KBy4zsAEVwAAAAAAAAAAAAAESAACVVDR1";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = PythParsePriceFeedUpdatesResponse.fromCell(body);

    expectOpcode(body, 0x00000005);
    expect(body.hash()).toEqual(EXPECTED_PARSE_RESPONSE_BODY_HASH);
    expect(decoded.numberOfPriceFeeds).toEqual(3);
    expect(decoded.priceFeeds.hash()).toBeGreater(0);
    expect(decoded.senderAddress).toEqual(address(EXPECTED_PARSE_RESPONSE_SENDER));
    expect(decoded.customPayload.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("PYTH_ORACLE_PARSE_RESPONSE_TX={} LT={}", txHash, txLt);
}
