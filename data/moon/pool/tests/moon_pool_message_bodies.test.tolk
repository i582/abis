import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/moon_pool.types"

const SWAP_SENDER = "0:4DE08C4D061688A38A4056EA1261176307D3EC8263CBE4251D8E54844DF0A1A1"
const SWAP_RECIPIENT = "0:7F80DF878A1172F5DA0859CEF8DB18FB907BDE5DBF1B3D916812E257DC86F2EE"

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

fun expectEmptySwapParams(params: MoonPoolSwapParams): void {
    expect(params.minOut).toEqual(0);
    expect(params.deadline).toEqual(0);
    expect(params.excessAddress).toBeNull();
    expect(params.referralAddress).toBeNull();
    expect(params.nextFulfill).toBeNull();
    expect(params.nextReject).toBeNull();
}

get fun `test moon pool decodes real direct native swap body`() {
    val txHash = "bGoOB8Nl7S65Qb3h+HSFljdD+YCUa3aVONejANldeRo=";
    val bodyBoc = "te6cckEBAQEAHAAAM7N6kAsAAAAAAAAAe0O5rKAAAAAAAAAAAAACFjwBkQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolSwap.fromCell(body);

    expect(decoded.queryId).toEqual(123);
    expect(decoded.amount).toEqual(1000000000);
    expectEmptySwapParams(decoded.swapParams);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_DIRECT_SWAP_TX={}", txHash);
}

get fun `test moon pool decodes real native boost body`() {
    val txHash = "5W//DWEA/e+s9NcbfLEOctP7NPcKtQnOdfoyFA0fFsI=";
    val bodyBoc = "te6cckEBAQEADgAAGJaqFYYAAAAAAAAAAB/ai7A=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolBoost.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_BOOST_TX={}", txHash);
}

get fun `test moon pool decodes real jetton notification with nested swap`() {
    val txHash = "XQpGPFQB4cCM/UCQWiavkasQt763BQZxm/uYzKuwqOI=";
    val bodyBoc = "te6cckEBAgEARAABYnNi0JwAAAAAAAAAezD0JAgAm8EYmgwtEUcUgK3UJMIuxg+n2QTHl8hKOxypCJvhQ0MBABuzepALAAAAAAAAAAAAIN9o+8Q=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolJettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val swap = MoonPoolSwapForwardPayload.fromCell(payloadCell);

    expect(decoded.queryId).toEqual(123);
    expect(decoded.amount).toEqual(1000000);
    expect(decoded.senderAddress).toEqual(address(SWAP_SENDER));
    expectEmptySwapParams(swap.swapParams);
    expect(swap.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_JETTON_SWAP_TX={}", txHash);
}

get fun `test moon pool decodes real direct swap-success callback`() {
    val txHash = "XQpGPFQB4cCM/UCQWiavkasQt763BQZxm/uYzKuwqOI=";
    val bodyBoc = "te6cckEBAQEABgAACMt/ONZ398VQ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolSwapSucceed.fromCell(body);
    val tail = decoded.tail;

    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_SWAP_SUCCESS_TX={}", txHash);
}

get fun `test moon pool decodes real jetton transfer with success callback`() {
    val txHash = "bGoOB8Nl7S65Qb3h+HSFljdD+YCUa3aVONejANldeRo=";
    val bodyBoc = "te6cckEBAgEAYAABrg+KfqUAAAAAAAAAezHnjIgA/wG/DxQi5eu0ELOd8bYx9yD3vLt+Nnsi0CXEr7kN5d0AH+A34eKEXL12ghZzvjbGPuQe95dvxs9kWgS4lfchvLuICiH+gQEACMt/ONbEMEGJ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolJettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val callback = MoonPoolSwapSucceed.fromCell(payloadCell);

    expect(decoded.queryId).toEqual(123);
    expect(decoded.amount).toEqual(1997000);
    expect(decoded.destination).toEqual(address(SWAP_RECIPIENT));
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(address(SWAP_RECIPIENT));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(85000000);
    expect(callback.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_JETTON_SWAP_SUCCESS_TX={}", txHash);
}

get fun `test moon pool decodes real jetton transfer with failure callback`() {
    val txHash = "eWG/UtDeHacXGP2WregrVIfN6OzG99zsnTUUpsPw0Vo=";
    val txLt = "55754079000001";
    val bodyBoc = "te6cckEBAgEAYAABrg+KfqUAAAAAAAABQTD0JAgAm8EYmgwtEUcUgK3UJMIuxg+n2QTHl8hKOxypCJvhQ0MAE3gjE0GFoijikBW6hJhF2MH0+yCY8vkJR2OVIRN8KGhIHAOhgQEACMR8H1f4eiDE";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolJettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val callback = MoonPoolSwapFailed.fromCell(payloadCell);

    expect(decoded.queryId).toEqual(321);
    expect(decoded.amount).toEqual(1000000);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(235000000);
    expect(callback.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_JETTON_SWAP_FAILURE_TX={} LT={}", txHash, txLt);
}

get fun `test moon pool decodes real initial lp internal transfer`() {
    val txHash = "leckWPa1jezjmgfqOz/bGXgg5zrgpB8iK5N57yw1ymc=";
    val bodyBoc = "te6cckEBAQEAMwAAYReNRRkAAAAAAAAAey9w2AEZSsFOGOrCZOpZSA0Vi1BIvctoaNCZV0x8OEt+Cdto9gINGrpT";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolJettonInternalTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(123);
    expect(decoded.amount).toEqual(63245);
    expect(decoded.responseAddress).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expectNoTail(forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_INITIAL_LP_TRANSFER_TX={}", txHash);
}

get fun `test moon pool decodes real excess body`() {
    val txHash = "gmW1FMQ2XbldbzS6UKjgd0ZyGWyduRxhV1hezA/IjDs=";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAe8E+iTQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MoonPoolExcess.fromCell(body);

    expect(decoded.queryId).toEqual(123);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("MOON_POOL_EXCESS_TX={}", txHash);
}
