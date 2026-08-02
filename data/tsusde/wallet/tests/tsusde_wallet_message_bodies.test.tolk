import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tsusde_wallet.types"

const TSUSDE_WALLET_OWNER = "0:295CA4DE239EAEBB7E1E4715D94F979D18C82336C5BE88C614842B0474E95529"
const TSUSDE_MASTER = "0:D0E545323C7ACB7102653C073377F7E3C67F122EB94D430A250739F109D4A57D"
const TSUSDE_NOTIFICATION_SENDER = "0:DF9AC0ED5903F90FF6245D7F979542EFB381E2BD168A637F1FB53DA14B9C8000"

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test decodes live tsusde timelocked internal transfer`() {
    val txHash = "TJoCvlC0guow82Lec3eYtnQka0lKSHOM8XvVEx8AeXg=";
    val txLt = "67586192000011";
    val bodyBoc = "te6cckEBAQEAGwAAMbJYPtUAAAAAAAAAADD0JBAAAAAGmxjtYAQO1f3B";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletInternalTransferTimelocked.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(1000001);
    expect(decoded.timelockLimit).toEqual(1773244118);
    expect(decoded.from).toBeNull();
    expect(decoded.responseAddress).toBeNull();
    expect(decoded.remainder.remainingBitsCount()).toEqual(5);
    expect(decoded.remainder.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_TIMELOCKED_IN_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde timelocked redemption request`() {
    val txHash = "eZQr2puDKkbLwPohsJEmVAbuS2Ndw+Ir9z8gt8iImnU=";
    val txLt = "61840368000003";
    val bodyBoc = "te6cckEBAQEAWQAArtdQzskAAAAAAAAAADAYbmgBocqKZHj1luIEyngOZu/vx4z+JF1ymoYUSg5z4hOpSvsAClcpN4jnq67fh5HFdlPl50YyCM2xb6IxhSEKwR06VUpIC+vCAIWMK/Q=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletTransferTimelocked.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(100070);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(100000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_TIMELOCKED_REDEEM_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde ordinary transfer request`() {
    val txHash = "oh7y7KIvJLGD52XySdeUrrd7dKSQYHCtthNURa5wRe8=";
    val txLt = "67586192000003";
    val bodyBoc = "te6cckEBAQEAWQAArg+KfqUAAAAAAAAAADC+2+gBocqKZHj1luIEyngOZu/vx4z+JF1ymoYUSg5z4hOpSvsAClcpN4jnq67fh5HFdlPl50YyCM2xb6IxhSEKwR06VUpIC+vCAFctI2I=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletTransfer.fromCell(body);
    var payload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(781758);
    expect(decoded.destination).toEqual(address(TSUSDE_MASTER));
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(address(TSUSDE_WALLET_OWNER));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(100000000);
    expectInlineEmptyForwardPayload(mutate payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_TRANSFER_IN_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde ordinary internal transfer`() {
    val txHash = "oh7y7KIvJLGD52XySdeUrrd7dKSQYHCtthNURa5wRe8=";
    val txLt = "67586192000003";
    val bodyBoc = "te6cckEBAgEAZQABvReNRRkAAAAAAAAAADC+2+AAAAAAAAAACABSuUm8Rz1ddvw8jiuyny86MZBGbYt9EYwpCFYI6dKqUwAKVyk3iOerrt+HkcV2U+XnRjIIzbFvojGFIQrBHTpVSlAX14QDAQABIGES1Sg=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletInternalTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(781758);
    expect(decoded.timelockLimit).toEqual(0);
    expect(decoded.from).toBeNotNull();
    expect(decoded.from!).toEqual(address(TSUSDE_WALLET_OWNER));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(TSUSDE_WALLET_OWNER));
    expect(decoded.forwardTonAmount).toEqual(100000000);
    expect(decoded.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(decoded.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_INTERNAL_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde timelocked internal redemption`() {
    val txHash = "eZQr2puDKkbLwPohsJEmVAbuS2Ndw+Ir9z8gt8iImnU=";
    val txLt = "61840368000003";
    val bodyBoc = "te6cckEBAgEAZQABvbJYPtUAAAAAAAAAADAYbmAAAAAAAAAACABSuUm8Rz1ddvw8jiuyny86MZBGbYt9EYwpCFYI6dKqUwAKVyk3iOerrt+HkcV2U+XnRjIIzbFvojGFIQrBHTpVSlAX14QDAQABoBjeGN0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletInternalTransferTimelocked.fromCell(body);
    var remainder = decoded.remainder;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(100070);
    expect(decoded.timelockLimit).toEqual(0);
    expect(decoded.from).toBeNotNull();
    expect(decoded.from!).toEqual(address(TSUSDE_WALLET_OWNER));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(TSUSDE_WALLET_OWNER));
    expect(remainder.loadCoins()).toEqual(100000000);
    expect(remainder.loadBool()).toBeTrue();
    expect(remainder.remainingBitsCount()).toEqual(0);
    expect(remainder.remainingRefsCount()).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_TIMELOCKED_INTERNAL_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde transfer notification`() {
    val txHash = "4+Xp9SDsB/8M3FR/eaIkpw3HUdOzloJ7g5o2uTjJGs0=";
    val txLt = "64747532000005";
    val bodyBoc = "te6cckEBAQEANQAAZnNi0JwAAAAAaUKGGFBbf3jEGAG/NYHasgfyH+xIuv8vKoXfZwPFei0Uxv4/antClzkAAEuUYRw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletTransferNotification.fromCell(body);
    var payload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(1765967384);
    expect(decoded.amount).toEqual(24561290305);
    expect(decoded.sender).toBeNotNull();
    expect(decoded.sender!).toEqual(address(TSUSDE_NOTIFICATION_SENDER));
    expectInlineEmptyForwardPayload(mutate payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_NOTIFICATION_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde excess response`() {
    val txHash = "4+Xp9SDsB/8M3FR/eaIkpw3HUdOzloJ7g5o2uTjJGs0=";
    val txLt = "64747532000005";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAaUKGGHqlmws=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeWalletExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(1765967384);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_WALLET_EXCESSES_OUT_TX={} LT={}", txHash, txLt);
}
