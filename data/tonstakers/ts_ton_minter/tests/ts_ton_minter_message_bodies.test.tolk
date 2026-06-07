import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/ts_ton_minter.types"

const USER_A = "0:A3173AE6AFCA52A1F15C88EAAD1A60616533FDB936F25019BBCD3EF172239D7F"
const USER_B = "0:1E6CC569EDEAA844772A709BB5292D8981672C328CAE4DEBE32E1612B853E2D1"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

fun expectTwoBitCustomPayloadTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(2);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(tail.loadUint(2)).toEqual(2);
    expectNoTail(mutate tail);
}

get fun `test tsTON minter decodes real incoming mint body`() {
    val txHash = "NVPPY0HYXMJH0fbbbBaRLBlXbvnOmhWIH3sD47QOjWw=";
    val txLt = "81984759000005";
    val bodyBoc = "te6cckEBAQEAOgAAbxZ0sKAAAAAAAAAAAYAUYudc1flKVD4rkR1Vo0wMLKZ/tybeSgM3eafeLkRzr+oKZmXhToC+vCABdzyZmQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsTonMinterMint.fromCell(body);

    expect(decoded.queryId).toEqual(1);
    expect(decoded.toAddress).toEqual(address(USER_A));
    expect(decoded.jettonAmount).toEqual(22333812903);
    expect(decoded.forwardTonAmount).toEqual(100000000);
    expect(decoded.totalTonAmount).toEqual(0);

    println("TSTON_MINTER_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test tsTON minter decodes real outgoing mint internal transfer body`() {
    val txHash = "NVPPY0HYXMJH0fbbbBaRLBlXbvnOmhWIH3sD47QOjWw=";
    val txLt = "81984759000005";
    val bodyBoc = "te6cckEBAQEAOgAAbxeNRRkAAAAAAAAAAVBTMy8KcgBRi51zV+UpUPiuRHVWjTAwspn+3Jt5KAzd5p94uRHOv6AvrwgCrXY7kg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsTonMinterJettonInternalTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(1);
    expect(decoded.amount).toEqual(22333812903);
    expect(decoded.fromAddress).toBeNull();
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(USER_A));
    expect(decoded.forwardTonAmount).toEqual(100000000);
    expectInlineEmptyForwardPayload(mutate forwardPayload);

    println("TSTON_MINTER_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test tsTON minter decodes real incoming burn notification body`() {
    val txHash = "Wh5MFk6/3gBs/2Wj6NfsYVk0SXXEf9+Ixr5JDTE4BM0=";
    val txLt = "81984815000012";
    val bodyBoc = "te6cckEBAgEAWwABqXvdl97v5G1UZ/OhzFGhhej4CAA82YrT29VQiO5U4TdqUlsTAs5YZRlcm9fGXCwlcKfFowAHmzFae3qqER3KnCbtSktiYFnLDKMrk3r4y4WErhT4tHABAAGgBTUwuA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsTonMinterBurnNotification.fromCell(body);

    expect(decoded.queryId).toEqual(17286061479043506636);
    expect(decoded.jettonAmount).toEqual(112078000000);
    expect(decoded.fromAddress).toEqual(address(USER_B));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(USER_B));
    expect(decoded.customPayload).toBeNotNull();
    var customPayload = decoded.customPayload!.beginParse();
    expectTwoBitCustomPayloadTail(mutate customPayload);

    println("TSTON_MINTER_BURN_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test tsTON minter decodes real outgoing jettons burned body`() {
    val txHash = "Wh5MFk6/3gBs/2Wj6NfsYVk0SXXEf9+Ixr5JDTE4BM0=";
    val txLt = "81984815000012";
    val bodyBoc = "te6cckEBAQEAVwAAqTGbDNzv5G1UZ/OhzFGhhej4CAA82YrT29VQiO5U4TdqUlsTAs5YZRlcm9fGXCwlcKfFowAHmzFae3qqER3KnCbtSktiYFnLDKMrk3r4y4WErhT4tGje4fg8";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsTonMinterJettonsBurned.fromCell(body);
    var customPayloadTail = decoded.customPayloadTail;

    expect(decoded.queryId).toEqual(17286061479043506636);
    expect(decoded.jettonAmount).toEqual(112078000000);
    expect(decoded.fromAddress).toEqual(address(USER_B));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(USER_B));
    expectTwoBitCustomPayloadTail(mutate customPayloadTail);

    println("TSTON_MINTER_JETTONS_BURNED_TX={} LT={}", txHash, txLt);
}
