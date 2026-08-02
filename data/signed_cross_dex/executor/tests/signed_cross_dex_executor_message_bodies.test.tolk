import "@acton/fmt"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "../types/signed_cross_dex_executor.types"

get fun `test signed cross dex decodes real signed route request`() {
    // External-in body from transaction wuXYnbtWp9Neq0sSnF0A2jO9KHPTuvFYEXgsOMKW6bY=.
    val bodyBoc = "te6cckECCAEAAegAAqNLcam6XpbRbKQtffB+VIhU7aoyB8qr/BqSanaxSnK7Fi4hi7+JkFbsUJ/OH00cuXi6fvMr857xUXRq4HS882EDam6K7GpuiuyuPwlxA4AAAAHAAQIBrWgBQw1lERfgN/OYLvr4aUimMamYCDKvt7WdQYBlG3DMu0UALOwDZxQu2CyhNIaLjsmxH5HsoaORJVB1BjlwmpHYYknULsyImgAAAAAAAAAAAAAAAAAAwAMBAgEEAKfRUSEPAAAAAAAAAABQukO3QAgBQw1lERfgN/OYLvr4aUimMamYCDKvt7WdQYBlG3DMu0QAAAAAAAAAAAAAAAAAAAAAEyDBJSKXIzDfB/vaMwZcmEABk4AY+2KWxAkcMtB/PPVUpAdD91rO6JT0YeFRYuQNxJis+OBAEAMfbFLYgSOGWg/nnqqUgOh+61ndEp6MPCosXIG4kxWfHQdzWUAQBQGwD4p+pQAAAAAAAAABQEKHVHgAMVUcXdqi6PtcBngPNycQeyg5Wx7Kiz5d05ro6W1x2rsAKGGsoiL8Bv5zBd9fDSkUxjUzAQZV9vazqDAMo24Zl2iIHc1lAQYBV+Og1IKAB8v/lRu/nm2G2T/o3mKsVVajcyKQi1rYTZe8yTqxSrEFC6ZZBsdABwAJAAAAAAJKJ6Fw";
    val body = parseCellFromBase64(bodyBoc);
    val request = SignedCrossDexExecutorSignedRequest.fromCell(body);
    var payload = request.payload;

    expect(request.validUntil).toEqual(1785629420);
    expect(request.queryId).toEqual(7669219964598815089);
    expect(request.sendMode).toEqual(3);
    expect(request.replaceContinuation).toBeTrue();
    expect(payload.remainingBitsCount()).toEqual(32);
    expect(payload.remainingRefsCount()).toEqual(2);
    expect(payload.loadUint(32)).toEqual(3);

    val initialMessage = payload.loadRef();
    val continuation = SignedCrossDexContinuation.fromCell(payload.loadRef());
    val step = continuation.firstStep.load();

    expect(initialMessage.hash()).toEqual(
        0x30c5514989a1b51af7e23e2d2a476e78bf3b439ab01a4d857f849a354a34f214,
    );
    expect(continuation.remainingSteps).toEqual(1);
    expect(step.expectedSender).toEqual(
        address("0:C7DB14B62048E19683F9E7AAA5203A1FBAD67744A7A30F0A8B17206E24C567C7"),
    );
    expect(step.callbackKind).toEqual(2);
    expect(step.reserved).toEqual(0);
    expect(step.destination).toEqual(step.expectedSender);
    expect(step.value).toEqual(500000000);
    expect(step.body.hash()).toEqual(
        0x9735129b39c585795cb26dbe6f5668a11f1b6cb62a0855a5917c5b5cea91e974,
    );

    match (step.next) {
        SignedCrossDexContinuationEnd => {}
        SignedCrossDexContinuationNext => {
            Assert.fail("Expected the captured route to contain exactly one continuation step");
        }
    }
}

get fun `test signed cross dex decodes real jetton notification callback`() {
    // Incoming body from transaction TRRqKwh47Rm62zEHu645+VyZQoX5M9mF3atLbV44chs=.
    val bodyBoc = "te6cckEBAQEAOAAAbHNi0JwAAAAAAAAAAUpz5P+YAO87mQKicbKgHIk4pSPP4k5xhHqutqYgAB7USnesDnCcX/4SlftotOE=";
    val body = parseCellFromBase64(bodyBoc);
    val notification = SignedCrossDexJettonTransferNotification.fromCell(body);
    var forwardPayload = notification.forwardPayload;

    expect(notification.queryId).toEqual(1);
    expect(notification.amount).toEqual(2805878777);
    expect(notification.sender).toEqual(
        address("0:779DCC815138D9500E449C5291E7F12738C23D575B5310000F6A253BD607384E"),
    );
    expect(forwardPayload.remainingBitsCount()).toEqual(33);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.loadUint(32)).toEqual(0x5ffe1295);
}

get fun `test signed cross dex decodes real excesses callback`() {
    // Incoming body from transaction rRP4CmBmv/pDjBibd5U95hVcP3VV2nprJHzuDKewoWo=.
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAfRC8y4=";
    val body = parseCellFromBase64(bodyBoc);
    val excesses = SignedCrossDexExcesses.fromCell(body);

    expect(excesses.queryId).toEqual(1);
    expect(excesses.toCell().hash()).toEqual(body.hash());
}
