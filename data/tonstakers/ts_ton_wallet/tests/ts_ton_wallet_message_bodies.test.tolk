import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/ts_ton_wallet.types"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

fun expectInlineEmptyTextCommentPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.loadUint(32)).toEqual(0);
    expectNoTail(mutate payload);
}

fun loadForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(mutate payload);
    return payloadCell;
}

fun expectTextCommentCell(payloadCell: cell, expectedTextWord: uint32): void {
    var payload = payloadCell.beginParse();
    expect(payload.loadUint(32)).toEqual(0);
    expect(payload.loadUint(32)).toEqual(expectedTextWord);
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test ts ton wallet decodes internal transfer, notification, and excess with ref text payload`() {
    val txHash = "mn5TR9GnOxZgL0OTj27zfT0ELHFbi6Fv345vtfucSiM=";
    val txLt = "75290515000022";
    val internalTransferBodyBoc = "te6cckEBAgEAYwABqxeNRRlUbeTvoemF8VATVLiHqABgD3exTR1a+l4RchM95fz8kVszNxiPHUQPJ/avg+hY6QAeuUFbD/ZQG+bu+fHCJzUxAgB2QdUhsvtt84S3xGerPEQHAQAQAAAAAFNlbmTuR5A5";
    val notificationBodyBoc = "te6cckEBAgEAQAABZnNi0JxUbeTvoemF8VATVLiHqABgD3exTR1a+l4RchM95fz8kVszNxiPHUQPJ/avg+hY6QEAEAAAAABTZW5kXRmCFA==";
    val excessBodyBoc = "te6cckEBAQEADgAAGNUydttUbeTvoemF8TvrrmI=";
    val internalTransfer = TsTonWalletInternalTransfer.fromCell(parseCellFromBase64(internalTransferBodyBoc));
    val notification = TsTonWalletTransferNotification.fromCell(parseCellFromBase64(notificationBodyBoc));
    val excess = TsTonWalletExcesses.fromCell(parseCellFromBase64(excessBodyBoc));
    var internalPayload = internalTransfer.forwardPayload;
    var notificationPayload = notification.forwardPayload;
    val internalPayloadCell = loadForwardPayloadRef(mutate internalPayload);
    val notificationPayloadCell = loadForwardPayloadRef(mutate notificationPayload);

    expect(internalTransfer.queryId).toEqual(6083770389512160753);
    expect(internalTransfer.amount).toEqual(5189109882);
    expect(internalTransfer.fromAddress).toEqual(address("0:3007BBD8A68EAD7D2F08B9099EF2FE7E48AD999B8C478EA20793FB57C1F42C74"));
    expect(internalTransfer.responseAddress).toBeNotNull();
    expect(internalTransfer.responseAddress!).toEqual(address("0:7AE5056C3FD9406F9BBBE7C7089CD4C40801D9075486CBEDB7CE12DF119EACF1"));
    expect(internalTransfer.forwardTonAmount).toEqual(1);

    expect(notification.queryId).toEqual(internalTransfer.queryId);
    expect(notification.amount).toEqual(internalTransfer.amount);
    expect(notification.senderAddress).toEqual(internalTransfer.fromAddress);
    expect(notificationPayloadCell.hash()).toEqual(internalPayloadCell.hash());
    expectTextCommentCell(internalPayloadCell, 0x53656e64);
    expect(excess.queryId).toEqual(internalTransfer.queryId);

    println("TSTON_WALLET_REF_PAYLOAD_TX={} LT={}", txHash, txLt);
}

get fun `test ts ton wallet decodes internal transfer, notification, and excess with inline empty payload`() {
    val txHash = "v04oatAG/1ja4Bma4VHG822hpGGiXtbhdQOOQROOCXY=";
    val txLt = "74996530000003";
    val internalTransferBodyBoc = "te6cckEBAQEAWgAArxeNRRkAAAAAAAAAAE1yEIPIAJzKomluy9Xm1z2SRNB2/rQ3owYP7yYiwCQzGfXl0qyVABOZVE0t2Xq82ueySJoO39aG9GDB/eTEWASGYz68ulWSkAvrwgGxlBRh";
    val notificationBodyBoc = "te6cckEBAQEANAAAZHNi0JwAAAAAAAAAAE1yEIPIAJzKomluy9Xm1z2SRNB2/rQ3owYP7yYiwCQzGfXl0qyURParWw==";
    val excessBodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val internalTransfer = TsTonWalletInternalTransfer.fromCell(parseCellFromBase64(internalTransferBodyBoc));
    val notification = TsTonWalletTransferNotification.fromCell(parseCellFromBase64(notificationBodyBoc));
    val excess = TsTonWalletExcesses.fromCell(parseCellFromBase64(excessBodyBoc));
    var internalPayload = internalTransfer.forwardPayload;
    var notificationPayload = notification.forwardPayload;

    expect(internalTransfer.queryId).toEqual(0);
    expect(internalTransfer.amount).toEqual(3609266236);
    expect(internalTransfer.fromAddress).toEqual(address("0:4E655134B765EAF36B9EC922683B7F5A1BD18307F793116012198CFAF2E9564A"));
    expect(internalTransfer.responseAddress).toBeNotNull();
    expect(internalTransfer.responseAddress!).toEqual(address("0:4E655134B765EAF36B9EC922683B7F5A1BD18307F793116012198CFAF2E9564A"));
    expect(internalTransfer.forwardTonAmount).toEqual(50000000);
    expectInlineEmptyForwardPayload(mutate internalPayload);

    expect(notification.queryId).toEqual(internalTransfer.queryId);
    expect(notification.amount).toEqual(internalTransfer.amount);
    expect(notification.senderAddress).toEqual(internalTransfer.fromAddress);
    expectInlineEmptyForwardPayload(mutate notificationPayload);
    expect(excess.queryId).toEqual(internalTransfer.queryId);

    println("TSTON_WALLET_INLINE_EMPTY_PAYLOAD_TX={} LT={}", txHash, txLt);
}

get fun `test ts ton wallet decodes inline text comment payload and zero-forward excess case`() {
    val textTxHash = "SE3VT8iDz8ZUNyKHjCaqA//yB3dPTlPvJqELq5Oz9hY=";
    val textTxLt = "44038616000005";
    val textInternalTransferBodyBoc = "te6cckEBAQEAXAAAsxeNRRkAAAAAAAAAAFCl15EK6ACWRPBBOXbJA51iMNKL8PdzukRtYKz31ix1raa9bqyacQASyJ4IJy7ZIHOsRhpRfh7ud0iNrBWe+sWOtbTXrdWTTgQEAAAAAe23/w8=";
    val textNotificationBodyBoc = "te6cckEBAQEAOQAAbnNi0JwAAAAAAAAAAFCl15EK6ACWRPBBOXbJA51iMNKL8PdzukRtYKz31ix1raa9bqyacAAAAAD7zsAa";
    val zeroForwardTxHash = "0bgWvJucie21piaKUoV98fC+7XOZtg3jEl+1+c9V6ls=";
    val zeroForwardTxLt = "42594451000005";
    val zeroForwardBodyBoc = "te6cckEBAQEAVwAAqReNRRkAAAAAAAAAAFAg9g7C2AARjmA2+pOfJKpo5/eodgDUZx16Kp2qQ+Eh7FlESfq9wQACMcwG31Jz5JVNHP71DsAajOOvRVO1SHwkPYsoiT9XuAG8ULW3";
    val zeroForwardExcessBodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val textInternalTransfer = TsTonWalletInternalTransfer.fromCell(parseCellFromBase64(textInternalTransferBodyBoc));
    val textNotification = TsTonWalletTransferNotification.fromCell(parseCellFromBase64(textNotificationBodyBoc));
    val zeroForwardTransfer = TsTonWalletInternalTransfer.fromCell(parseCellFromBase64(zeroForwardBodyBoc));
    val zeroForwardExcess = TsTonWalletExcesses.fromCell(parseCellFromBase64(zeroForwardExcessBodyBoc));
    var internalTextPayload = textInternalTransfer.forwardPayload;
    var notificationTextPayload = textNotification.forwardPayload;
    var zeroForwardPayload = zeroForwardTransfer.forwardPayload;

    expect(textInternalTransfer.queryId).toEqual(0);
    expect(textInternalTransfer.amount).toEqual(44517888174);
    expect(textInternalTransfer.fromAddress).toEqual(address("0:4B2278209CBB6481CEB1186945F87BB9DD2236B0567BEB163AD6D35EB7564D38"));
    expect(textInternalTransfer.forwardTonAmount).toEqual(1);
    expectInlineEmptyTextCommentPayload(mutate internalTextPayload);
    expect(textNotification.queryId).toEqual(textInternalTransfer.queryId);
    expect(textNotification.amount).toEqual(textInternalTransfer.amount);
    expect(textNotification.senderAddress).toEqual(textInternalTransfer.fromAddress);
    expectInlineEmptyTextCommentPayload(mutate notificationTextPayload);

    expect(zeroForwardTransfer.queryId).toEqual(0);
    expect(zeroForwardTransfer.amount).toEqual(8847944749);
    expect(zeroForwardTransfer.fromAddress).toEqual(address("0:08C7301B7D49CF92553473FBD43B006A338EBD154ED521F090F62CA224FD5EE0"));
    expect(zeroForwardTransfer.responseAddress).toBeNotNull();
    expect(zeroForwardTransfer.responseAddress!).toEqual(address("0:08C7301B7D49CF92553473FBD43B006A338EBD154ED521F090F62CA224FD5EE0"));
    expect(zeroForwardTransfer.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate zeroForwardPayload);
    expect(zeroForwardExcess.queryId).toEqual(zeroForwardTransfer.queryId);

    println("TSTON_WALLET_INLINE_TEXT_TX={} LT={}", textTxHash, textTxLt);
    println("TSTON_WALLET_ZERO_FORWARD_TX={} LT={}", zeroForwardTxHash, zeroForwardTxLt);
}
