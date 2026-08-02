import "@acton/fmt"
import "@acton/testing/expect"
import "../types/moon_clmm_range.types"

const DIRECT_SWAP_BODY_BOC = "te6cckEBAQEAVgAAp9FRIQ8AAAAAAAAAAFBvwjrACACKOydTblFAjhaZvettMp7xEGpwDnD+/eZLrK7omZVKMgAAAAAAAAAAAAAAAAAAAAATHswkDnAuPIMfonhsI7jgQA6d9D8="
const JETTON_NOTIFICATION_BODY_BOC = "te6cckEBAgEAfQABZHNi0JwAAAAAAAAAAEAhcr54ARjTvr5QXZQv0LBXgsvxjpQwRPq4iGRbMbsmW/OP5rEhAQCL0VEhD4ARjTvr5QXZQv0LBXgsvxjpQwRPq4iGRbMbsmW/OP5rEgAAAAAAAAAAAAAAAAAAAAABMfJMh7zTr+K5DBU/g5N4JOmPQ/A="
const JETTON_TRANSFER_BODY_BOC = "te6cckEBAgEAYgABsA+KfqUAAAAAAAAAAEEuW5DoASGZhheeL8vR6YU7BkaSE6OjLGVIJqmen6EjOSnFsAfBACQzMMLzxfl6PTCnYMjSQnR0ZYypBNUz0/QkZyU4tgD4CDVPjfUBAAmdFCZDQBKVpNc="
const NATIVE_RESULT_BODY_BOC = "te6cckEBAQEAFAAAI50UJkMAAAAAAAAAAFBdn/cp5DqMHrE="
const NATIVE_REFUND_BODY_BOC = "te6cckEBAQEAFAAAI/8y2pkAAAAAAAAAAFBvwjrABHBKHJw="

get fun `test moon clmm range direct native swap body round trips`() {
    val body = parseCellFromBase64(DIRECT_SWAP_BODY_BOC);
    val swap = MoonClmmRangeSwap.fromCell(body);

    expect(swap.toCell().hash()).toEqual(body.hash());
    expect(swap.queryId).toEqual(0);
    expect(swap.swapAmount).toEqual(30000000000);
    expect(swap.excessAddress).toEqual(
        address("0:451D93A9B728A0470B4CDEF5B6994F7888353807387F7EF325D657744CCAA519"),
    );
    expect(swap.sqrtPriceLimitX128).toEqual(12707620646955425021358931339677654128);
    expect(swap.nextFulfill).toBeNull();
    expect(swap.nextReject).toBeNull();
}

get fun `test moon clmm range jetton funded swap body round trips`() {
    val body = parseCellFromBase64(JETTON_NOTIFICATION_BODY_BOC);
    val notification = MoonClmmRangeJettonTransferNotification.fromCell(body);
    var forwardPayload = notification.forwardPayload;

    expect(notification.queryId).toEqual(0);
    expect(notification.amount).toEqual(35072999);
    expect(notification.sender).toEqual(
        address("0:8C69DF5F282ECA17E8582BC165F8C74A18227D5C44322D98DD932DF9C7F35890"),
    );
    expect(forwardPayload.loadBool()).toBeTrue();
    val payloadCell = forwardPayload.loadRef();
    val payload = MoonClmmRangeSwapForwardPayload.fromCell(payloadCell);
    expect(payload.excessAddress).toEqual(notification.sender);
    expect(payload.sqrtPriceLimitX128).toBeGreater(0);
    expect(payload.nextFulfill).toBeNull();
    expect(payload.nextReject).toBeNull();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
}

get fun `test moon clmm range jetton result body round trips`() {
    val body = parseCellFromBase64(JETTON_TRANSFER_BODY_BOC);
    val transfer = MoonClmmRangeJettonTransfer.fromCell(body);

    expect(transfer.toCell().hash()).toEqual(body.hash());
    expect(transfer.queryId).toEqual(0);
    expect(transfer.amount).toEqual(317045006);
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(447203066);
    expect(transfer.forwardPayload).toBeNotNull();

    val result = MoonClmmRangeJettonSwapResultPayload.fromCell(transfer.forwardPayload!);
    expect(result.payload).toBeNull();
}

get fun `test moon clmm range native result and refund bodies round trip`() {
    val resultBody = parseCellFromBase64(NATIVE_RESULT_BODY_BOC);
    val refundBody = parseCellFromBase64(NATIVE_REFUND_BODY_BOC);
    val result = MoonClmmRangeNativeSwapResult.fromCell(resultBody);
    val refund = MoonClmmRangeNativeSwapRefund.fromCell(refundBody);

    expect(result.toCell().hash()).toEqual(resultBody.hash());
    expect(result.queryId).toEqual(0);
    expect(result.amount).toBeGreater(0);
    expect(result.payload).toBeNull();

    expect(refund.toCell().hash()).toEqual(refundBody.hash());
    expect(refund.queryId).toEqual(0);
    expect(refund.amount).toEqual(30000000000);
    expect(refund.payload).toBeNull();
}
