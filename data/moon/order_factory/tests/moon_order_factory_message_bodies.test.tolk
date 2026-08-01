import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/moon_order_factory.types"

get fun `test moon order factory decodes real fee notification`() {
    val txHash = "+KmsrtUOzsyrhchUl3cBCg4sQJ8DrSzVQ9Ce2tExUsg=";
    val txLt = "61984382000005";
    val bodyBoc = "te6cckEBAQEADgAAGDZ61AYAAAAAAADzW8DFChA=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonOrderFactoryFeeNotification.fromCell(body);

    expect(decoded.queryId).toEqual(62299);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("MOON_ORDER_FACTORY_FEE_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test moon order factory decodes real order registration`() {
    val txHash = "JTC6pvdJstNu/1LSGXyHZkr43H/T/XSMgNdUpwz4R1w=";
    val txLt = "59837928000015";
    val bodyBoc = "te6cckEBAgEApAABt1ufhEkAAAAAAAv8goAP8Bvw8UIuXrtBCznfG2Mfcg97y7fjZ7ItAlxK+5DeXcAAAAAAAAAFEAFBlm/SMy3shDSNlwcD6QX3ENqbZFxnypr+Kp0vzr8/yQdzWUAgAQCFgBYidTKWoElCzjPtInJlHW6ysthxRL6yBRYo39m4bEO/0AKXRLjG+h4Z4UaKNPOJxIDyPoaKK6CYlbnPFBtlNSe2tnFm2NU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonOrderFactoryRegisterOrder.fromCell(body);
    val assets = decoded.assets.load();

    expect(decoded.queryId).toEqual(785538);
    expect(decoded.creator).toEqual(
        address("0:7F80DF878A1172F5DA0859CEF8DB18FB907BDE5DBF1B3D916812E257DC86F2EE"),
    );
    expect(decoded.orderId).toEqual(40);
    expect(assets.asset1).toEqual(
        address("0:B113A994B5024A16719F69139328EB759596C38A25F59028B146FECDC3621DFE"),
    );
    expect(assets.asset2).toEqual(
        address("0:A5D12E31BE87867851A28D3CE271203C8FA1A28AE826256E73C506D94D49EDAD"),
    );
    expect(decoded.sourceWallet).toEqual(
        address("0:50659BF48CCB7B210D2365C1C0FA417DC436A6D91719F2A6BF8AA74BF3AFCFF2"),
    );
    expect(decoded.amount).toEqual(500000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("MOON_ORDER_FACTORY_REGISTER_ORDER_TX={} LT={}", txHash, txLt);
}

get fun `test moon order factory constructs historically absent forward bodies`() {
    val queryId: uint64 = 700001;
    val destination = address(
        "0:1111111111111111111111111111111111111111111111111111111111111111",
    );
    val payload0 = createEmptyCell() as Cell<RemainingBitsAndRefs>;
    val payload1 = beginCell()
        .storeUint(123456789, 64)
        .storeUint(1, 1)
        .storeUint(3600, 64)
        .endCell() as Cell<RemainingBitsAndRefs>;
    val requestCell = MoonOrderFactoryForwardRequest {
        queryId,
        destination,
        payload0,
        payload1,
    }.toCell();
    val forwardedCell = MoonOrderFactoryForwardedMessage { queryId, payload0, payload1 }.toCell();
    val request = MoonOrderFactoryForwardRequest.fromCell(requestCell);
    val forwarded = MoonOrderFactoryForwardedMessage.fromCell(forwardedCell);

    expect(request.queryId).toEqual(queryId);
    expect(request.destination).toEqual(destination);
    expect(request.payload0.hash()).toEqual(payload0.hash());
    expect(request.payload1.hash()).toEqual(payload1.hash());
    expect(forwarded.queryId).toEqual(queryId);
    expect(forwarded.payload0.hash()).toEqual(payload0.hash());
    expect(forwarded.payload1.hash()).toEqual(payload1.hash());
    expect(request.toCell().hash()).toEqual(requestCell.hash());
    expect(forwarded.toCell().hash()).toEqual(forwardedCell.hash());
}
