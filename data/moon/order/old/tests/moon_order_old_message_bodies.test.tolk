import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/moon_order_old.types"

get fun `test moon order old decodes real wallet resolution flow`() {
    val callbackTxHash = "vXWFBA96DHofEnQazK0+Nau8dcaCGbW6YXwPxZLFYJg=";
    val callbackTxLt = "58086768000001";
    val callbackBodyBoc = "te6cckEBAQEAMAAAW5ikKi8AAAAAAAhYuYAS3L+8w0kpvwBTlGVh8IJivQmgBXQU2cpyv7dw4Gry9ZBa0jaY";
    val callbackBody = parseCellFromBase64(callbackBodyBoc);
    val callback = MoonOrderOldPipeWalletResolved.fromCell(callbackBody);

    val requestTxHash = "pzHBSokPLKSO1hqF5HW3rs+MiOYhvT8UuD3DuLXytbg=";
    val requestTxLt = "58086762000001";
    val requestBodyBoc = "te6cckEBAQEAMAAAW6XueCIAAAAAAAhYuYAF/6GuwJGRHpCdBxRhw2iENRjSo24ZH2Vs0htkwjzjSBCZZ+xO";
    val requestBody = parseCellFromBase64(requestBodyBoc);
    val request = MoonOrderOldPipeWalletRequest.fromCell(requestBody);

    expect(callback.queryId).toEqual(547001);
    expect(request.queryId).toEqual(callback.queryId);
    expect(callback.wallet).toEqual(
        address("0:96E5FDE61A494DF8029CA32B0F841315E84D002BA0A6CE5395FDBB87035797AC"),
    );
    expect(request.order).toEqual(
        address("0:2FFD0D76048C88F484E838A30E1B4421A8C6951B70C8FB2B6690DB2611E71A40"),
    );
    expect(callback.toCell().hash()).toEqual(callbackBody.hash());
    expect(request.toCell().hash()).toEqual(requestBody.hash());
    println("MOON_ORDER_OLD_WALLET_CALLBACK_TX={} LT={}", callbackTxHash, callbackTxLt);
    println("MOON_ORDER_OLD_WALLET_REQUEST_TX={} LT={}", requestTxHash, requestTxLt);
}

get fun `test moon order old constructs bodies absent from its complete history`() {
    val queryId: uint64 = 547002;
    val creator = address(
        "0:2222222222222222222222222222222222222222222222222222222222222222",
    );
    val sourceWallet = address(
        "0:3333333333333333333333333333333333333333333333333333333333333333",
    );
    val assets = MoonOrderOldAssets {
        asset1: null,
        asset2: address(
            "0:4444444444444444444444444444444444444444444444444444444444444444",
        ),
    }.toCell();
    val feeCell = MoonOrderOldFeeNotification { queryId }.toCell();
    val registrationCell = MoonOrderOldFactoryRegistration {
        queryId,
        creator,
        orderId: 41,
        assets,
        sourceWallet,
        amount: 500000000,
    }.toCell();
    val response510Cell = MoonOrderOldResponse510 { queryId }.toCell();
    val response702Cell = MoonOrderOldResponse702 { queryId }.toCell();

    val fee = MoonOrderOldFeeNotification.fromCell(feeCell);
    val registration = MoonOrderOldFactoryRegistration.fromCell(registrationCell);
    val response510 = MoonOrderOldResponse510.fromCell(response510Cell);
    val response702 = MoonOrderOldResponse702.fromCell(response702Cell);

    expect(fee.queryId).toEqual(queryId);
    expect(registration.queryId).toEqual(queryId);
    expect(registration.creator).toEqual(creator);
    expect(registration.orderId).toEqual(41);
    expect(registration.sourceWallet).toEqual(sourceWallet);
    expect(registration.amount).toEqual(500000000);
    expect(response510.queryId).toEqual(queryId);
    expect(response702.queryId).toEqual(queryId);
    expect(fee.toCell().hash()).toEqual(feeCell.hash());
    expect(registration.toCell().hash()).toEqual(registrationCell.hash());
    expect(response510.toCell().hash()).toEqual(response510Cell.hash());
    expect(response702.toCell().hash()).toEqual(response702Cell.hash());
}
