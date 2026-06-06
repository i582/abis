import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_vault_native.types"

const STORM_ORIGIN = "0:9E7E69CD0D8CA689A61F3EBBA57E5DC855484A4C435D878C58B6ED8522A75F48"
const STORM_NATIVE_TRADE_SA = "0:021D96782F8CE9C9A44917F48ACF87EA613D5B0CB06A61E244D9542826CD738E"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test storm native vault decodes toncenter native stake body`() {
    val txHash = "z5gsT5mcPQIZZDqs7rwXsymcM/AMp2UFDqKIQRO4ums=";
    val txLt = "81928332000003";
    val bodyBoc = "te6cckEBAQEACwAAEciaPuRDuaygCLdoqxQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormVaultStake.fromCell(body);

    expect(decoded.amount).toEqual(1000000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAULT_NATIVE_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test storm native vault decodes toncenter unstake body`() {
    val txHash = "X6OncC/kImVFOAa2UxMpQ3Wx/tb+HegCMEyVe8gbgLc=";
    val txLt = "81928041000003";
    val bodyBoc = "te6cckEBAQEALgAAV9W16a1gFzHGRdZoAJA9hI/KlupfzCUunTUsI7ZcwKKoQFfqAeqApNJagmabgUASVQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormVaultUnstake.fromCell(body);

    expect(decoded.jettonAmount).toEqual(1593909206374);
    expect(decoded.userAddress).toEqual(
        address("0:481EC247E54B752FE612974E9A9611DB2E605154202BF500F54052692D41334D"),
    );
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAULT_NATIVE_UNSTAKE_TX={} LT={}", txHash, txLt);
}

get fun `test storm native vault decodes toncenter trade notification v2 body`() {
    val txHash = "wdIkyiCG+yl1GXSHHKXnIO3y703j8qUDtBbFfxMz1Is=";
    val txLt = "81927712000004";
    val bodyBoc = "te6cckEBAwEAuwAC0CjTZJEAAAAAaiQVsQAKAAAAAAAAY/8AAAAAAAAAAP////7H8f8bAAAAAIWz6AcAAAAAhbL1LQAAAAAAAI7bAAAAAAAAAAAcAAIdlngvjOnJpEkX9IrPh+phPVsMsGph4kTZVCgmzXOOAQIAR9IAdctUsF3RmTy0jETjQ3sIk1nuk6dWFcRGPVzLNj5D6R6yQABNEBVpCI4AEg8kB01thm+gcXH2HdhnqSfakGZQFZcUlzmkC94Uj/2QqdHlxw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormTradeNotificationV2.fromCell(body);

    expect(decoded.queryId).toEqual(1780749745);
    expect(decoded.assetId).toEqual(10);
    expect(decoded.freeAmount).toEqual(25599);
    expect(decoded.lockedAmount).toEqual(0);
    expect(decoded.exchangeAmount).toEqual(-5235409125);
    expect(decoded.withdrawLockedAmount).toEqual(2243160071);
    expect(decoded.feeToStakers).toEqual(2243097901);
    expect(decoded.executorAmount).toEqual(36571);
    expect(decoded.totalReferrerAmount).toEqual(0);
    expect(decoded.refCount).toEqual(1);
    expect(decoded.saAddress).toEqual(address(STORM_NATIVE_TRADE_SA));

    println("STORM_VAULT_NATIVE_TRADE_NOTIFICATION_V2_TX={} LT={}", txHash, txLt);
}

get fun `test storm native vault decodes toncenter lp mint request outgoing body`() {
    val txHash = "z5gsT5mcPQIZZDqs7rwXsymcM/AMp2UFDqKIQRO4ums=";
    val txLt = "81928332000003";
    val bodyBoc = "te6cckEBAQEANAAAYxZ0sKAAAEqDbSA7A0LygY2YAA0xAk4gWxjht2QyaIpJe3mMAzH9U/7VvZR1eS4pm0yjesNJkA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormMintJettons.fromCell(body);

    expect(decoded.queryId).toEqual(81928332000003);
    expect(decoded.amount).toEqual(791156953);
    expect(decoded.ownerAddress).toEqual(
        address("0:06988127102D8C70DBB219344524BDBCC60198FEA9FF6ADECA3ABC9714CDA651"),
    );
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAULT_NATIVE_LP_MINT_REQUEST_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test storm native vault decodes toncenter legacy trade body`() {
    val txHash = "Ep7IT1yC5IqavPq5ocKVA05sDldtnJ1nrzx/q8vAwuk=";
    val txLt = "81941596000007";
    val bodyBoc = "te6cckEBAgEAhwAB8jR1/dIAhAAAAADhTjkAAAAAFeLWLAAAAAAAAAAAAAAAAAAAAAAAAAAAAGCPPQAAAAAAAAAAAIARkjwkzAKi20pPD2PBPGE6oQS+1p35VzJc1gRrx7aqzvACefmnNDYymiaYfPrulfl3IVUhKTENdh4xYtu2FIqdfSEBABGhHhowAAAAABSauC5H";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormVaultTradeNotification.fromCell(body);

    expect(decoded.ammIndex).toEqual(132);
    expect(decoded.freeAmount).toEqual(3780000000);
    expect(decoded.lockedAmount).toEqual(94000000000);
    expect(decoded.exchangeAmount).toEqual(0);
    expect(decoded.withdrawLockedAmount).toEqual(0);
    expect(decoded.feeToStakers).toEqual(1620000000);
    expect(decoded.withdrawAmount).toEqual(0);
    expect(decoded.traderAddr).toEqual(
        address("0:8C91E126601516DA52787B1E09E309D50825F6B4EFCAB992E6B0235E3DB55677"),
    );
    expect(decoded.withdrawDestination).toEqual(address(STORM_ORIGIN));
    expect(decoded.referralParams).toBeNull();
    expect(decoded.executorParams).toBeNotNull();

    println("STORM_VAULT_NATIVE_LEGACY_TRADE_TX={} LT={}", txHash, txLt);
}

get fun `test storm native vault decodes toncenter add amount outgoing bodies`() {
    val addExecutorTxHash = "Ep7IT1yC5IqavPq5ocKVA05sDldtnJ1nrzx/q8vAwuk=";
    val addReferralTxHash = "soXx8BTpLuqxg2ByezM0AskWQ3LDFRxtCI77BBVHGW0=";
    val addExecutorBoc = "te6cckEBAQEALAAAU13WZXlBV1KgCAE8/NOaGxlNE0w+fXdK/LuQqpCUmIa7DxixbdsKRU6+kUxKy2I=";
    val addReferralBoc = "te6cckEBAQEAKwAAUYTc7Xo5AIE4ATz805obGU0TTD59d0r8u5CqkJSYhrsPGLFt2wpFTr6RXT+1Lw==";
    val addExecutor = StormAddExecutorAmount.fromCell(parseCellFromBase64(addExecutorBoc));
    val addReferral = StormAddReferralAmount.fromCell(parseCellFromBase64(addReferralBoc));

    expect(addExecutor.referralAmount).toEqual(360000000);
    expect(addExecutor.originAddr).toEqual(address(STORM_ORIGIN));
    expect(addReferral.referralAmount).toEqual(9439251);
    expect(addReferral.originAddr).toEqual(address(STORM_ORIGIN));

    println("STORM_VAULT_NATIVE_ADD_EXECUTOR_OUT_TX={}", addExecutorTxHash);
    println("STORM_VAULT_NATIVE_ADD_REFERRAL_OUT_TX={}", addReferralTxHash);
}
