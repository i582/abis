import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/evaa_master_classic.types"

const TRANSFER_NOTIFY_BODY_BOC = "te6cckEBAwEAgwABYnNi0JwAAAAAAAAAADSAVtgAfuWGBloDnHtLd92S8+Ujztn2UlU+EWe8ZJYYx4AWItMBAZMAAAAB4AH7lhgZaA5x7S3fdkvPlI87Z9lJVPhFnvGSWGMeAFiLSAABAA/csMDLQHOPaW77sl58pHnbPspKp8Is94ySwxjwAsRaSAIAAP5m3nk="
const TRANSFER_NOTIFY_TX_HASH = "ipcC2c0MAKZiaO8i5fv1myp5vcBzIKAXS5Bk6I/oZxU="
const TRANSFER_NOTIFY_LT = "81973888000007"
const EXPECTED_BODY_HASH = 0x68b03ba69f8c5cfd89fc6d8a2111798a9831a243f47795830c7cf7fe10e78c5c
const EXPECTED_FORWARD_PAYLOAD_HASH = 0x63c4f04284a13139588be6cc1b60d940e0e60c9ac8e9e3980a243c0705d5ad8c
const EXPECTED_EMPTY_PAYLOAD_HASH = 0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7
const EXPECTED_SENDER_ADDRESS = "0:3f72c3032d01ce3da5bbeec979f291e76cfb292a9f08b3de324b0c63c00b1169"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(payload);
    return payloadCell;
}

get fun `test evaa master classic decodes real jetton transfer notification body`() {
    val body = parseCellFromBase64(TRANSFER_NOTIFY_BODY_BOC);
    val decoded = EvaaMasterClassicJettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val forwardPayloadCell = loadForwardPayloadRef(mutate forwardPayload);
    var jettonSupply = forwardPayloadCell.beginParse();

    expect(body.hash()).toEqual(EXPECTED_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(4719981);
    expect(decoded.sender.castToInternal()).toEqual(address(EXPECTED_SENDER_ADDRESS));

    expect(forwardPayloadCell.hash()).toEqual(EXPECTED_FORWARD_PAYLOAD_HASH);
    expect(jettonSupply.loadUint(32)).toEqual(0x00000001);
    expect(jettonSupply.loadInt(2)).toEqual(-1);
    expect(jettonSupply.loadAddress()).toEqual(address(EXPECTED_SENDER_ADDRESS));

    val customResponsePayload = jettonSupply.loadRef();
    expect(customResponsePayload.hash()).toEqual(EXPECTED_EMPTY_PAYLOAD_HASH);

    expect(jettonSupply.remainingBitsCount()).toEqual(287);
    expect(jettonSupply.remainingRefsCount()).toEqual(0);
    expect(jettonSupply.loadInt(16)).toEqual(0);
    expect(jettonSupply.loadInt(2)).toEqual(0);
    expect(jettonSupply.loadAddress()).toEqual(address(EXPECTED_SENDER_ADDRESS));
    expect(jettonSupply.loadInt(2)).toEqual(0);
    expect(jettonSupply.remainingBitsCount()).toEqual(0);
    expect(jettonSupply.remainingRefsCount()).toEqual(0);

    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "EVAA_MASTER_CLASSIC_TRANSFER_NOTIFY_TX={} LT={}",
        TRANSFER_NOTIFY_TX_HASH,
        TRANSFER_NOTIFY_LT,
    );
}
