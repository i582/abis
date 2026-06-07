import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/subscription_v1.types"

get fun `test subscription v1 decodes real payment confirmed body`() {
    val txHash = "eZwacRiPClNM5PUqZzGBhE6FL8kOJwqM3tYhbdzhkEU=";
    val txLt = "23914742000005";
    val bodyBoc = "te6cckEBAQEADgAAGPBsdWcAABXAFbOpgUFMBuM=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SubscriptionV1PaymentConfirmed.fromCell(body);

    expect(decoded.queryId).toEqual(23914742000001);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SUBSCRIPTION_V1_PAYMENT_CONFIRMED_TX={} LT={}", txHash, txLt);
}

get fun `test subscription v1 decodes real subscription payment body`() {
    val txHash = "eZwacRiPClNM5PUqZzGBhE6FL8kOJwqM3tYhbdzhkEU=";
    val txLt = "23914742000005";
    val bodyBoc = "te6cckEBAQEABgAACHN1YnO58WdQ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SubscriptionV1SubscriptionPayment.fromCell(body);

    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SUBSCRIPTION_V1_SUBSCRIPTION_PAYMENT_TX={} LT={}", txHash, txLt);
}
