import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tsusde_vault.types"

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test decodes live tsusde vault asset notification`() {
    val txHash = "KWMsuUIuZF/yLvINfGTAPH67Gt9F/iaXi9DGGrUPb8g=";
    val txLt = "94159460000007";
    val bodyBoc = "te6cckEBAQEAMwAAYnNi0Jx7eS3jDInPgTGhw9gAbcD64bjEOd4PcqKKmykwdNFCImWKzpEa+qkDu4oh/1pHkZEu";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeVaultTransferNotification.fromCell(body);
    var payload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(8897192992038309761);
    expect(decoded.amount).toEqual(1711165);
    expectInlineEmptyForwardPayload(mutate payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_VAULT_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde vault share mint`() {
    val txHash = "KWMsuUIuZF/yLvINfGTAPH67Gt9F/iaXi9DGGrUPb8g=";
    val txLt = "94159460000007";
    val bodyBoc = "te6cckEBAgEAUAABY2QrfQd7eS3jDInPgYAG3A+uG4xDneD3KiipspMHTRQiJlis6RGvqpA7uKIf9agELB2BAQAxF41FGXt5LeMMic+BMUGVYAAAAAAAAAAABFTg2Lc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeVaultMintShares.fromCell(body);
    val internalTransfer = decoded.internalTransfer.load();

    expect(decoded.queryId).toEqual(8897192992038309761);
    expect(decoded.forwardTonAmount).toEqual(35000000);
    expect(internalTransfer.queryId).toEqual(decoded.queryId);
    expect(internalTransfer.amount).toBeGreater(0);
    expect(internalTransfer.timelockLimit).toEqual(0);
    expect(internalTransfer.from).toBeNull();
    expect(internalTransfer.responseAddress).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_VAULT_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde vault asset transfer`() {
    val txHash = "nI0hEK/YF3Hwr0MkJL0Y2RYhU/xSk0MACKQhfI3XAWg=";
    val txLt = "93987071000007";
    val bodyBoc = "te6cckEBAQEAVwAAqg+KfqUAAAAAAAAAAFBP/WcXqAG+fdiPZc483UDl2mHJO827O1UVD5yy6ruEspvspz15uwA3z7sR7LnHm6gcu0w5J3m3Z2qiofOWXVdwllN9lOevN0DgHqUn";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeVaultJettonTransfer.fromCell(body);
    var payload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(21472113018);
    expect(decoded.destination).toEqual(decoded.responseDestination);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_VAULT_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde vault rewards event`() {
    val txHash = "x/Iq6alQT9SQJUQSc0wlK6QH9GMqb6kdySFcdXOZeO8=";
    val txLt = "93626766000007";
    val bodyBoc = "te6cckEBBAEAwQABW+M7mHMAAAAAAAAARQgBdYXAVvby42sYhtk6C3g+aL7Off/dvb1TXjB9ps6PWU0BApcAAAAAAGV2ZW50gV7k/8k/9////////////////////////////////////AAAAAAAAAAAARVZFTlQ6OlJld2FyZHNEZXBvc2l0ZWSAgMAdwAAAAAAY29pbnNxXv/////////////////////////////////////////8AAAAAAAAAAAAAAACSCAiAgAAAb+cxA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeVaultEventMessage.fromCell(body);
    val event = decoded.event.load();
    val rewards = TsusdeVaultCoinsPayload.fromCell(event.payload);
    val initialStorage = event.initialStorage.beginParse();

    expect(decoded.queryId).toEqual(69);
    expect(decoded.donationNanos).toEqual(0);
    expect(decoded.origin).toEqual(
        address("0:BAC2E02B7B7971B58C436C9D05BC1F345F673EFFEEDEDEA9AF183ED36747ACA6"),
    );
    expect(event.topic).toBeGreater(0);
    expect(rewards.amount).toEqual(2450000000);
    expect(initialStorage.remainingBitsCount()).toEqual(0);
    expect(initialStorage.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_VAULT_EVENT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live tsusde vault empty refund body`() {
    val txHash = "x/Iq6alQT9SQJUQSc0wlK6QH9GMqb6kdySFcdXOZeO8=";
    val txLt = "93626766000007";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TsusdeVaultEmptyBody.fromCell(body);
    val raw = body.beginParse();

    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TSUSDE_VAULT_EMPTY_REFUND_TX={} LT={}", txHash, txLt);
}
