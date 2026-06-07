import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_wallet.types"

const HIPO_OWNER = "0:7F2BEB264EBBD6A81F8BB96737394F380A3B75F0C20EB550DC4C1312DD60E0CC"
const HIPO_PARENT = "0:CF76AF318C0872B58A9F1925FC29C156211782B9FB01F56760D292E56123BF87"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

fun loadForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(mutate payload);
    return payloadCell;
}

get fun `test hipo wallet decodes toncenter owner send_tokens and outgoing receive_tokens`() {
    val txHash = "ZddMFyuDaTUkrrHZTNrCqDr9afLuuBKJpVc/PEh3R1o=";
    val txLt = "45927205000003";
    val sendBodyBoc = "te6cckEBAgEAiAABbQ+KfqUABJ4bU6N8FkO5rKAIAO87mQKicbKgHIk4pSPP4k5xhHqutqYgAB7USnesDnCcEDk4cAMBAJclk4VhgAIqFqMWTE1aoxM/MRD/EEluAMqKyKvv/FAn4CTTNIDD6HcT3r0AH8r6yZOu9aoH4u5Zzc5TzgKO3Xwwg61UNxMExLdYODMQK8wWcA==";
    val receiveBodyBoc = "te6cckEBAgEAqQABrxeNRRkABJ4bU6N8FkO5rKAIAP5X1kydd61QPxdyzm5ynnAUduvhhB1qobiYJiW6wcGZAB/K+smTrvWqB+LuWc3OU84Cjt18MIOtVDcTBMS3WDgzEDk4cAMBAJclk4VhgAIqFqMWTE1aoxM/MRD/EEluAMqKyKvv/FAn4CTTNIDD6HcT3r0AH8r6yZOu9aoH4u5Zzc5TzgKO3Xwwg61UNxMExLdYODMQ3xXjMQ==";
    val sendBody = parseCellFromBase64(sendBodyBoc);
    val receiveBody = parseCellFromBase64(receiveBodyBoc);
    val send = HipoWalletSendTokens.fromCell(sendBody);
    val receive = HipoWalletReceiveTokens.fromCell(receiveBody);
    var sendPayload = send.forwardPayload;
    var receivePayload = receive.forwardPayload;
    val sendPayloadCell = loadForwardPayloadRef(mutate sendPayload);
    val receivePayloadCell = loadForwardPayloadRef(mutate receivePayload);

    expect(send.queryId).toEqual(1299740111371286);
    expect(send.tokens).toEqual(1000000000);
    expect(send.recipient).toEqual(
        address("0:779DCC815138D9500E449C5291E7F12738C23D575B5310000F6A253BD607384E"),
    );
    expect(send.returnExcess).toBeNull();
    expect(send.customPayload).toBeNull();
    expect(send.forwardTonAmount).toEqual(240000000);

    expect(receive.queryId).toEqual(send.queryId);
    expect(receive.tokens).toEqual(send.tokens);
    expect(receive.sender).toEqual(address(HIPO_OWNER));
    expect(receive.returnExcess).toBeNotNull();
    expect(receive.returnExcess!).toEqual(address(HIPO_OWNER));
    expect(receive.forwardTonAmount).toEqual(send.forwardTonAmount);
    expect(receivePayloadCell.hash()).toEqual(sendPayloadCell.hash());
    expect(send.toCell().hash()).toEqual(sendBody.hash());
    expect(receive.toCell().hash()).toEqual(receiveBody.hash());

    println("HIPO_WALLET_SEND_TOKENS_TX={} LT={}", txHash, txLt);
}

get fun `test hipo wallet decodes toncenter receive_tokens with ref payload, notification, and excess`() {
    val txHash = "B+pwLS8dtGWzOmO97QISRJAtC+8bkuy2WNyKFNU7Urg=";
    val txLt = "60623378000057";
    val receiveBodyBoc = "te6cckEBAgEAYAABrReNRRkAAAAAAAAAADaJRdgBxiqt2h18qdwcmwYUiS/G1reEoPVpsHTMicfKFLajrY8AH8r6yZOu9aoH4u5Zzc5TzgKO3Xwwg61UNxMExLdYODMQCYloAwEACH8M4E+rAH8k";
    val notificationBodyBoc = "te6cckEBAgEAOgABYnNi0JwAAAAAAAAAADaJRdgBxiqt2h18qdwcmwYUiS/G1reEoPVpsHTMicfKFLajrY8BAAh/DOBPq72bGg==";
    val excessBodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val receiveBody = parseCellFromBase64(receiveBodyBoc);
    val notificationBody = parseCellFromBase64(notificationBodyBoc);
    val excessBody = parseCellFromBase64(excessBodyBoc);
    val receive = HipoWalletReceiveTokens.fromCell(receiveBody);
    val notification = HipoWalletTransferNotification.fromCell(notificationBody);
    val excess = HipoWalletGasExcess.fromCell(excessBody);
    var receivePayload = receive.forwardPayload;
    var notificationPayload = notification.forwardPayload;
    val receivePayloadCell = loadForwardPayloadRef(mutate receivePayload);
    val notificationPayloadCell = loadForwardPayloadRef(mutate notificationPayload);

    expect(receive.queryId).toEqual(0);
    expect(receive.tokens).toEqual(6853725);
    expect(receive.sender).toEqual(
        address("0:E31556ED0EBE54EE0E4D830A4497E36B5BC2507AB4D83A6644E3E50A5B51D6C7"),
    );
    expect(receive.returnExcess).toBeNotNull();
    expect(receive.returnExcess!).toEqual(address(HIPO_OWNER));
    expect(receive.forwardTonAmount).toEqual(40000000);

    expect(notification.queryId).toEqual(receive.queryId);
    expect(notification.tokens).toEqual(receive.tokens);
    expect(notification.sender).toEqual(receive.sender);
    expect(notificationPayloadCell.hash()).toEqual(receivePayloadCell.hash());
    expect(excess.queryId).toEqual(receive.queryId);
    expect(receive.toCell().hash()).toEqual(receiveBody.hash());
    expect(notification.toCell().hash()).toEqual(notificationBody.hash());
    expect(excess.toCell().hash()).toEqual(excessBody.hash());

    println("HIPO_WALLET_RECEIVE_TOKENS_REF_PAYLOAD_TX={} LT={}", txHash, txLt);
}

get fun `test hipo wallet decodes toncenter tokens_minted and owner notification`() {
    val txHash = "mRdO6dOQvWypiv+O5/A8UsvTSgVne7wnPOkOAAewvso=";
    val txLt = "63198808000007";
    val mintedBodyBoc = "te6cckEBAQEAPQAAdVRF7+5s4/IuHhIa7ENz5p+EO5rKAIAP5X1kydd61QPxdyzm5ynnAUduvhhB1qobiYJiW6wcGYAAAAAQUcFwaA==";
    val notificationBodyBoc = "te6cckEBAQEANAAAZHNi0Jxs4/IuHhIa7ENz5p+IAP5X1kydd61QPxdyzm5ynnAUduvhhB1qobiYJiW6wcGYrSq/5w==";
    val mintedBody = parseCellFromBase64(mintedBodyBoc);
    val notificationBody = parseCellFromBase64(notificationBodyBoc);
    val minted = HipoWalletTokensMinted.fromCell(mintedBody);
    val notification = HipoWalletTransferNotification.fromCell(notificationBody);
    var forwardPayload = notification.forwardPayload;

    expect(minted.queryId).toEqual(7846381255696456428);
    expect(minted.tokens).toEqual(926837240);
    expect(minted.coins).toEqual(1000000000);
    expect(minted.owner).toEqual(address(HIPO_OWNER));
    expect(minted.roundSince).toEqual(0);
    expect(notification.queryId).toEqual(minted.queryId);
    expect(notification.tokens).toEqual(minted.tokens);
    expect(notification.sender).toEqual(address(HIPO_OWNER));
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(minted.toCell().hash()).toEqual(mintedBody.hash());
    expect(notification.toCell().hash()).toEqual(notificationBody.hash());

    println("HIPO_WALLET_TOKENS_MINTED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo wallet decodes toncenter unstake_tokens and proxy_reserve_tokens`() {
    val txHash = "PWeqLADTE7760AWsf5+1co8QviZ2F1lsDEqfK7l5R6k=";
    val txLt = "77799920000005";
    val unstakeBodyBoc = "te6cckEBAgEAGQABI1lfB7z8YV2Zz6fhelASoF8gAwEABAEB+J3RRA==";
    val reserveBodyBoc = "te6cckEBAQEANwAAaWiLAhP8YV2Zz6fhelASoF8gCAD+V9ZMnXetUD8Xcs5ucp5wFHbr4YQdaqG4mCYlusHBmAIDt9kL5w==";
    val unstakeBody = parseCellFromBase64(unstakeBodyBoc);
    val reserveBody = parseCellFromBase64(reserveBodyBoc);
    val unstake = HipoWalletUnstakeTokens.fromCell(unstakeBody);
    val reserve = HipoWalletProxyReserveTokens.fromCell(reserveBody);
    val customPayload = unstake.customPayload!.load();

    expect(unstake.queryId).toEqual(18185919685494038906);
    expect(unstake.tokens).toEqual(5000000000);
    expect(unstake.returnExcess).toBeNull();
    expect(customPayload.mode).toEqual(0);
    expect(customPayload.ownershipAssignedAmount).toEqual(1);

    expect(reserve.queryId).toEqual(unstake.queryId);
    expect(reserve.tokens).toEqual(unstake.tokens);
    expect(reserve.owner).toEqual(address(HIPO_OWNER));
    expect(reserve.mode).toEqual(customPayload.mode);
    expect(reserve.ownershipAssignedAmount).toEqual(customPayload.ownershipAssignedAmount);
    expect(unstake.toCell().hash()).toEqual(unstakeBody.hash());
    expect(reserve.toCell().hash()).toEqual(reserveBody.hash());

    println("HIPO_WALLET_UNSTAKE_TOKENS_TX={} LT={}", txHash, txLt);
}

get fun `test hipo wallet decodes toncenter tokens_burned and withdrawal_notification`() {
    val txHash = "5qGqyUEHIQEd3EvLxsTeZ1uhQQVHG3tJvzdQpJg+q7E=";
    val txLt = "77799920000013";
    val burnedBodyBoc = "te6cckEBAQEAGQAALltRLiX8YV2Zz6fhelASoF8gBQFMAXMwVfp7wg==";
    val withdrawalBodyBoc = "te6cckEBAQEAGQAALvD6Ijv8YV2Zz6fhelASoF8gBQFMAXMwudcAWQ==";
    val burnedBody = parseCellFromBase64(burnedBodyBoc);
    val withdrawalBody = parseCellFromBase64(withdrawalBodyBoc);
    val burned = HipoWalletTokensBurned.fromCell(burnedBody);
    val withdrawal = HipoWalletWithdrawalNotification.fromCell(withdrawalBody);

    expect(burned.queryId).toEqual(18185919685494038906);
    expect(burned.tokens).toEqual(5000000000);
    expect(burned.coins).toEqual(5570130736);
    expect(withdrawal.queryId).toEqual(burned.queryId);
    expect(withdrawal.tokens).toEqual(burned.tokens);
    expect(withdrawal.coins).toEqual(burned.coins);
    expect(burned.toCell().hash()).toEqual(burnedBody.hash());
    expect(withdrawal.toCell().hash()).toEqual(withdrawalBody.hash());

    println("HIPO_WALLET_TOKENS_BURNED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo wallet decodes toncenter merge_wallet body`() {
    val txHash = "c0cf1B9vX4CE1HXwh3WVAFwdebtVJWhbKl6LDgmSW9o=";
    val txLt = "45468543000015";
    val bodyBoc = "te6cckEBAQEAFAAAI2PTp2wAAAAAAAAAAF6oX/8D6Haphg0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoWalletMergeWallet.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newTokens).toEqual(1007270490174);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("HIPO_WALLET_MERGE_WALLET_TX={} LT={}", txHash, txLt);
}
