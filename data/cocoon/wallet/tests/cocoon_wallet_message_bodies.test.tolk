import "@acton/fmt"
import "@acton/testing/expect"
import "../types/cocoon_wallet.types"

get fun `test cocoon wallet decodes real signed external batch`() {
    val body = parseCellFromBase64("te6cckEBAwEAtwABmpRTTgqLrbXTTlhXDbAaEu/oq0q+yosRb6en4rWjVWihpLoREglDd4Rli0dw/JARneGuD1QICBA0tQ2DNmiZgwEAAAAAaedD/gAAAAUAAQFoYgAOguWOSeDD2IQPsj2NFvBPPfktEQre5MBHO8KVEyQf5KFNyTgAAAAAAAAAAAAAAAAAAQIAW/r6bMF+cggk8A7kOoAI1irXliW+yZ0y5kae1zxbmQl7ucrXqI+APj3rvMwc+LBxz9cI");
    val message = CocoonWalletSignedExternal.fromCell(body);

    expect(message.subwalletId).toEqual(0);
    expect(message.validUntil).toEqual(1776763902);
    expect(message.seqno).toEqual(5);
    expect(message.messages.remainingBitsCount()).toEqual(8);
    expect(message.messages.remainingRefsCount()).toEqual(1);
}

get fun `test cocoon wallet decodes another real signed external batch`() {
    val body = parseCellFromBase64("te6cckEBAwEAvQABmmotQSyNle4z3eFS22UQrNBNLfsm/vJo9/cV0p0OOCp3jLhccNi2Fepc2IiDQ70JiaCoF2AfDo+gPfSM41a4sAQAAAAAaeB8uwAAAAMAAQFqYgAOguWOSeDD2IQPsj2NFvBPPfktEQre5MBHO8KVEyQf5KgdPlfoAAAAAAAAAAAAAAAAAAECAGXxcubCgQgiuHWHMO9QN+EdYAgAjWKteWJb7JnTLmRp7XPFuZCXu5yteoj4A+Peu8zBz4vNhVUF");
    val message = CocoonWalletSignedExternal.fromCell(body);

    expect(message.subwalletId).toEqual(0);
    expect(message.validUntil).toEqual(1776319675);
    expect(message.seqno).toEqual(3);
    expect(message.messages.remainingBitsCount()).toEqual(8);
    expect(message.messages.remainingRefsCount()).toEqual(1);
}

get fun `test cocoon wallet decodes real owner relay`() {
    val body = parseCellFromBase64("te6cckEBAwEAdwABGpxp83YAAAAAAAAAAAABAWhiACJKEvb1yOZuYrb1LQpKUmW7fZVuGEsNn80AUOC5qQR5oEeGjAAAAAAAAAAAAAAAAAABAgBb+vpswQAAAAAAAAAAgBmZbel9Tvzw+msWlhgGwPog0jj6W/CGCts+wPTCmtBsULEQSAk=");
    val message = CocoonWalletSendMessage.fromCell(body);

    expect(message.queryId).toEqual(0);
    expect(message.mode).toEqual(0);
    expect(message.message.beginParse().remainingBitsCount()).toEqual(416);
    expect(message.message.beginParse().remainingRefsCount()).toEqual(1);
}

get fun `test cocoon wallet decodes real ignored excess acknowledgement`() {
    val body = parseCellFromBase64("te6cckEBAQEADgAAGCVlk0x+cggk8A7kOvTy+ok=");
    val message = CocoonWalletReturnExcesses.fromCell(body);

    expect(message.queryId).toEqual(9111353950863287354);
}

get fun `test cocoon wallet decodes real ignored payout`() {
    val body = parseCellFromBase64("te6cckEBAQEADgAAGMWafNN+cggk8A7kOotTG+o=");
    val message = CocoonWalletPayout.fromCell(body);

    expect(message.queryId).toEqual(9111353950863287354);
}
