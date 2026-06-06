import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/evaa_master_pyth.types"

const EVAA_PYTH_PARSE_INITIAL_SENDER = "kQCw6aDI1eCU1Xg_r9x1qwoXN_zgHC_xStzFkL7dFnM3mX6R"
const EXPECTED_PYTH_PARSE_PRICE_FEEDS_HASH = 0x58e40c615cd8354afcba4241df585e92d6b94fd06e724f929e21f9ff24aa6c91
const EXPECTED_PYTH_PARSE_NESTED_CELL_HASH = 0x17217ffcf5e32f00b760e6b7f38e22287acc8cc57361da7d50d3add66ed70574
const EXPECTED_PYTH_PARSE_OPERATION_PAYLOAD_HASH = 0x35a5a6d1fba708afa999dea83774f93fa5ccb43cbba440f7fb8a064447f927f3

fun expectOpcode(body: cell, expectedOpcode: uint32): void {
    val raw = body.beginParse();
    expect(raw.remainingBitsCount()).toBeGreater(31);
    expect(raw.preloadUint(32)).toEqual(expectedOpcode);
}

get fun `test evaa master pyth decodes toncenter pyth_parse body`() {
    val txHash = "opRNDqE3OwPKMkaoxne+6LmWD9e3RNjZ/BfgoUFg40U=";
    val txLt = "81992376000005";
    val bodyBoc = "te6cckECEwEAAdAAAk0AAAAFA4AWHTQZGrwSmq8H9fuOtWFC5v+cA4X+KVuYshfbos5m8zABAgJAPReEEo7qtZYexgZI/kl9OQHuvSEbf1Hkuw258CSXfSUDBAEYAAAABAAAAAAAAAAADgIABQYCQIljIXg4q0z1ytwXIgPB8Ldj+6pF80bY7lC6mUu8rDAmBwgAOAAAAAAGq4rrAAAAAAAAAAH////4AAAAAGoke6YAOAAAAAAGq3fJAAAAAAAAAAH////4AAAAAGoke6YCAAkKAUAribncj9+fNHCaWxBrRy8PObtsqc4EsP1/LpcWiOLlOwsAOAAAAAAJk9fxAAAAAAADatn////4AAAAAGoke6YAOAAAAAAJjzxPAAAAAAAD2hL////4AAAAAGoke6YCAAwNADgAAAAABfUxOwAAAAAAAPmA////+AAAAABqJHumADgAAAAABfUuzQAAAAAAAOrg////+AAAAABqJHumAwAPEBEAEAAAAAAAAAAAAJMAAAAAAmJaAMqQBr0/sD01Xa7v+TskvpCvqm48oAc/9XIPioUskzJ4gBYdNBkavBKarwf1+461YULm/5wDhf4pW5iyF9uizmbzMAEVwAAAAAAAAAAAAAESAACef47B";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = EvaaMasterPythParsePriceFeedUpdates.fromCell(body);
    val nested = decoded.operationPayload.load();
    val operationPayload = nested.operationPayload;
    val operationPayloadHash = operationPayload.hash();
    var operationTail = operationPayload.beginParse();

    expectOpcode(body, 0x00000005);
    expect(decoded.numPriceFeeds).toEqual(3);
    expect(decoded.initialSender).toEqual(address(EVAA_PYTH_PARSE_INITIAL_SENDER));
    expect(decoded.priceFeedsCell.hash()).toEqual(EXPECTED_PYTH_PARSE_PRICE_FEEDS_HASH);
    expect(decoded.operationPayload.hash()).toEqual(EXPECTED_PYTH_PARSE_NESTED_CELL_HASH);
    expect(nested.operationCode).toEqual(0x00000004);
    expect(nested.queryId).toEqual(0);
    expect(operationPayloadHash).toEqual(EXPECTED_PYTH_PARSE_OPERATION_PAYLOAD_HASH);
    expect(operationTail.remainingBitsCount()).toEqual(0);
    expect(operationTail.remainingRefsCount()).toEqual(3);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("EVAA_MASTER_PYTH_PYTH_PARSE_TX={} LT={}", txHash, txLt);
    println("EVAA_MASTER_PYTH_PYTH_PARSE_PRICE_FEEDS_HASH={}", decoded.priceFeedsCell.hash());
    println("EVAA_MASTER_PYTH_PYTH_PARSE_PAYLOAD_HASH={}", operationPayloadHash);
}
