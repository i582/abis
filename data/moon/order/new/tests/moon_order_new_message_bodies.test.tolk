import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/moon_order_new.types"

get fun `test moon order new decodes real wallet resolution flow`() {
    val callbackTxHash = "4ubP5DigjJ8BvIAuAdxaWExgo/45b1YWNQl49l58soA=";
    val callbackTxLt = "58435731000001";
    val callbackBodyBoc = "te6cckEBAQEAMAAAW5ikKi8AAAAAAA1K9IAbyOR182420C9Zmxs9LPigmwQ7TbA8XZwVzs5oFJ4yCvD4aT5n";
    val callbackBody = parseCellFromBase64(callbackBodyBoc);
    val callback = MoonOrderNewPipeWalletResolved.fromCell(callbackBody);

    val requestTxHash = "xfCxkYDV1c/ta9N7G7uA4D741uEPHmMZjDFooUUYTrY=";
    val requestTxLt = "58435724000005";
    val requestBodyBoc = "te6cckEBAQEAMAAAW6XueCIAAAAAAA1K9IAbALwEpwCkA3QeCw3ojp6RLR8dfIOomtpqRR0KON/Z3RAYYUr7";
    val requestBody = parseCellFromBase64(requestBodyBoc);
    val request = MoonOrderNewPipeWalletRequest.fromCell(requestBody);

    expect(callback.queryId).toEqual(871156);
    expect(request.queryId).toEqual(callback.queryId);
    expect(callback.wallet).toEqual(
        address("0:DE4723AF9B71B6817ACCD8D9E967C504D821DA6D81E2ECE0AE767340A4F19057"),
    );
    expect(request.order).toEqual(
        address("0:D805E0253805201BA0F0586F4474F48968F8EBE41D44D6D35228E851C6FECEE8"),
    );
    expect(callback.toCell().hash()).toEqual(callbackBody.hash());
    expect(request.toCell().hash()).toEqual(requestBody.hash());
    println("MOON_ORDER_NEW_WALLET_CALLBACK_TX={} LT={}", callbackTxHash, callbackTxLt);
    println("MOON_ORDER_NEW_WALLET_REQUEST_TX={} LT={}", requestTxHash, requestTxLt);
}

get fun `test moon order new constructs bodies absent from its complete history`() {
    val queryId: uint64 = 871157;
    val creator = address(
        "0:5555555555555555555555555555555555555555555555555555555555555555",
    );
    val sourceWallet = address(
        "0:6666666666666666666666666666666666666666666666666666666666666666",
    );
    val assets = MoonOrderNewAssets {
        asset1: null,
        asset2: address(
            "0:7777777777777777777777777777777777777777777777777777777777777777",
        ),
    }.toCell();
    val feeCell = MoonOrderNewFeeNotification { queryId }.toCell();
    val registrationCell = MoonOrderNewFactoryRegistration {
        queryId,
        creator,
        orderId: 42,
        assets,
        sourceWallet,
        amount: 600000000,
    }.toCell();
    val response510Cell = MoonOrderNewResponse510 { queryId }.toCell();
    val response702Cell = MoonOrderNewResponse702 { queryId }.toCell();

    val fee = MoonOrderNewFeeNotification.fromCell(feeCell);
    val registration = MoonOrderNewFactoryRegistration.fromCell(registrationCell);
    val response510 = MoonOrderNewResponse510.fromCell(response510Cell);
    val response702 = MoonOrderNewResponse702.fromCell(response702Cell);

    expect(fee.queryId).toEqual(queryId);
    expect(registration.queryId).toEqual(queryId);
    expect(registration.creator).toEqual(creator);
    expect(registration.orderId).toEqual(42);
    expect(registration.sourceWallet).toEqual(sourceWallet);
    expect(registration.amount).toEqual(600000000);
    expect(response510.queryId).toEqual(queryId);
    expect(response702.queryId).toEqual(queryId);
    expect(fee.toCell().hash()).toEqual(feeCell.hash());
    expect(registration.toCell().hash()).toEqual(registrationCell.hash());
    expect(response510.toCell().hash()).toEqual(response510Cell.hash());
    expect(response702.toCell().hash()).toEqual(response702Cell.hash());
}
