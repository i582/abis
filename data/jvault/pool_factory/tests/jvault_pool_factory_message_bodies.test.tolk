import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/jvault_pool_factory.types"

const FACTORY_ADMIN = "0:ED67DD472FD7D1189946C9C793D8E1152D77C7DEA080695520440EA7CF966E65"

get fun `test decodes live factory fee withdrawal and jetton transfer`() {
    val txHash = "/pko5vxJ6TCgczfVSUOW9g15Dp0zGcoqlc8Hagekt/o=";
    val txLt = "92940153000024";
    val withdrawalBody = parseCellFromBase64(
        "te6cckEBAQEARwAAiRHAloIAAAAAAAAAAIAKY6t2l1S/4cB0FkkV9WRrItnYRGPBtsAHWc6Fm68xWUw/DFKI7SAAAAAArtLo0Mjkwu5AzMrK5xo4Ggg=",
    );
    val withdrawal = JVaultPoolFactoryWithdrawJetton.fromCell(withdrawalBody);
    expect(withdrawal.queryId).toEqual(0);
    expect(withdrawal.amount).toBeGreater(0);
    expect(withdrawal.forwardPayload.remainingBitsCount()).toBeGreater(32);
    expect(withdrawal.toCell().hash()).toEqual(withdrawalBody.hash());

    val transferBody = parseCellFromBase64(
        "te6cckEBAgEAcAABtA+KfqUAAAAAAAAAAGH4YpRHaQgB2s+6jl+vojEyjZOPJ7HCKlrvj71BANKqQIgdT58s3MsAO1n3Ucv19EYmUbJx5PY4RUtd8feoIBpVSBEDqfPlm5lIBV1KgQEAIgAAAABXaXRoZHJhdyBmZWVzTPMjaw==",
    );
    val transfer = JVaultPoolFactoryJettonTransfer.fromCell(transferBody);
    expect(transfer.queryId).toEqual(0);
    expect(transfer.amount).toEqual(34661078431376);
    expect(transfer.destination).toEqual(address(FACTORY_ADMIN));
    expect(transfer.responseDestination).toBeNotNull();
    expect(transfer.responseDestination!).toEqual(address(FACTORY_ADMIN));
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(45000000);
    expect(transfer.forwardPayload).toBeNotNull();
    expect(transfer.toCell().hash()).toEqual(transferBody.hash());

    println("JVAULT_POOL_FACTORY_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live factory TON withdrawal forwarding and responses`() {
    val txHash = "pJHwwexzfu3/S/aP2ihs7R9xbxP7OHKsNs8hJGu24eg=";
    val txLt = "92778363000024";
    val requestBody = parseCellFromBase64(
        "te6cckEBAQEAMAAAW+W4Jo8AAAAAAAAAAIAMYiKtBrp0uW0Oe4ryjgDWCCLqQHl4uddMQXyuxnYiabDx9+Q/",
    );
    val request = JVaultPoolFactorySendWithdrawTon.fromCell(requestBody);
    expect(request.queryId).toEqual(0);
    expect(request.toCell().hash()).toEqual(requestBody.hash());

    val forwardedBody = parseCellFromBase64(
        "te6cckEBAQEADgAAGDdya9sAAAAAAAAAAADJO3E=",
    );
    val forwarded = JVaultPoolFactoryForwardWithdrawTon.fromCell(forwardedBody);
    expect(forwarded.queryId).toEqual(request.queryId);
    expect(forwarded.toCell().hash()).toEqual(forwardedBody.hash());

    val excessBody = parseCellFromBase64(
        "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=",
    );
    val excess = JVaultPoolFactoryExcesses.fromCell(excessBody);
    expect(excess.queryId).toEqual(0);
    expect(excess.toCell().hash()).toEqual(excessBody.hash());

    val commentBody = parseCellFromBase64(
        "te6cckEBAQEAEwAAIgAAAABUT04gd2l0aHJhd2FsKefMXw==",
    );
    val comment = JVaultPoolFactoryTextComment.fromCell(commentBody);
    expect(comment.text.remainingBitsCount()).toBeGreater(0);
    expect(comment.toCell().hash()).toEqual(commentBody.hash());

    println("JVAULT_POOL_FACTORY_FORWARD_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live factory transfer notification and arbitrary forwarding request`() {
    val notificationTxHash = "C2+gn9Jnmke9aZvNB+6iKQGgRpFRW7fEPcB1Tko3giI=";
    val notificationBody = parseCellFromBase64(
        "te6cckEBAgEAVwABZnNi0JwAAAAAAAAAAFSi/jnXiAG0F9cHwhoNInON7KvUe3yOVBkpDLm4gqScOSHOHkqaowEAPgAAAABKVmF1bHQncyByZXdhcmRzIGNvbW1pc3Npb244T2yB",
    );
    val notification = JVaultPoolFactoryTransferNotification.fromCell(notificationBody);
    expect(notification.queryId).toEqual(0);
    expect(notification.amount).toEqual(318631026040);
    expect(notification.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(notification.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(notification.toCell().hash()).toEqual(notificationBody.hash());

    val forwardingTxHash = "j/UJedwStskNvEbEjSqvluw0ZATJ0yCY16xlOzWsZe8=";
    val forwardingBody = parseCellFromBase64(
        "te6cckEBAwEAjgABW6R9mJwAAAAAAAAAAIAN1DBq3lFmZ6FEWvQ46KsjD3pxcw83bPnOLKitRFIPkJABAVukfZicAAAAAAAAAACACCuUM1dbN2RE9fne4so5RTKxG87DBEQyuiHeSiwLH1IwAgBT1opKweafXvshkGJsV0alKIAGLXmIPSAAAMhBHhowArtAWXkgKBNY7jIEGJon3g==",
    );
    val forwarding = JVaultPoolFactorySendAnyMessage.fromCell(forwardingBody);
    expect(forwarding.queryId).toEqual(0);
    expect(forwarding.payload.beginParse().remainingRefsCount()).toBeGreater(0);
    expect(forwarding.toCell().hash()).toEqual(forwardingBody.hash());

    println(
        "JVAULT_POOL_FACTORY_NOTIFY_TX={} FORWARD_TX={}",
        notificationTxHash,
        forwardingTxHash,
    );
}
