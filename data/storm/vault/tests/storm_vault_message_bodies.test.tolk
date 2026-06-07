import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_vault.types"

const STORM_USDT_MINTER = "0:B113A994B5024A16719F69139328EB759596C38A25F59028B146FECDC3621DFE"
const STORM_ORIGIN = "0:9E7E69CD0D8CA689A61F3EBBA57E5DC855484A4C435D878C58B6ED8522A75F48"
const STORM_VAULT_TRADE_SA = "0:0FDC7DADDC7009BAD5E313CAC3FDE98D3502E3415B5DCCA314BD8390F951B451"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(mutate payload);
    return payloadCell;
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

get fun `test storm vault decodes toncenter jetton notify body`() {
    val txHash = "cYR4m7iEv/ZkxUnvTn65xrwu1Bp8SVr4VzwLKLsUUMY=";
    val txLt = "81941550000010";
    val bodyBoc = "te6cckEBAwEAXAABZHNi0JwAAAAAAAAAAEAS7jEIAVn874sOs4xDeXGVZApA/V/wgFG1OMrVvlNYfYYPEyrRAQEe4Nt3UwCaMwAAAAAAAC5kAgAlAAAAdGpSiABqJCwDAgP5ZYmAQKmpiiY=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormJettonNotify.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    var payload = payloadCell.beginParse();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(19850000);
    expect(decoded.senderAddress).toEqual(
        address("0:ACFE77C58759C621BCB8CAB205207EAFF84028DA9C656ADF29AC3EC307899568"),
    );
    expect(payload.loadUint(32)).toEqual(0xe0db7753);
    expect(payload.remainingBitsCount()).toEqual(88);
    expect(payload.remainingRefsCount()).toEqual(1);

    println("STORM_VAULT_JETTON_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test storm vault decodes toncenter unstake body`() {
    val txHash = "5O6z4dNBmciPqs38rUpAIf+NEtPQ2yzAxOkvzpS7I9I=";
    val txLt = "81893279000001";
    val bodyBoc = "te6cckEBAQEALAAAU9W16a1Du/hUuABIr/+0/NgAH3h/43D6CYhKJYlAHIqho3OTCqFISMnuf8edg6E=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormVaultUnstake.fromCell(body);

    expect(decoded.jettonAmount).toEqual(1002407243);
    expect(decoded.userAddress).toEqual(
        address("0:2457FFDA7E6C000FBC3FF1B87D04C42512C4A00E4550D1B9C98550A42464F73F"),
    );
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAULT_UNSTAKE_TX={} LT={}", txHash, txLt);
}

get fun `test storm vault decodes toncenter trade notification v2 body`() {
    val txHash = "/LM9wrRg9W4+y6TWtxAmu94iId5rEjBFZuoNvT5buls=";
    val txLt = "81734442000006";
    val bodyBoc = "te6cckEBAwEAvAAC0CjTZJEAAAAAaiLkiQAvAAAAABWSjjUAAAAAAAAAAP////wcP6ydAAAAACoCHEkAAAAACc1+TgAAAAAHNXcrAAAAAANsmJscAA/cfa3ccAm61eMTysP96Y01AuNBW13MoxS9g5D5UbRRAQIAR9IAEZv65mlFK1duxLpiRxIN6d7yfdElqcRdJt1zgAieetayQABPFGFKaNx+AGUW/STa6IjSN99FQ4SowUDrydrdyO9lHfASoG365sMWEN3q6YM=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormTradeNotificationV2.fromCell(body);

    expect(decoded.queryId).toEqual(1780671625);
    expect(decoded.assetId).toEqual(47);
    expect(decoded.freeAmount).toEqual(361926197);
    expect(decoded.lockedAmount).toEqual(0);
    expect(decoded.exchangeAmount).toEqual(-16705934179);
    expect(decoded.withdrawLockedAmount).toEqual(704781385);
    expect(decoded.feeToStakers).toEqual(164462158);
    expect(decoded.executorAmount).toEqual(120944427);
    expect(decoded.totalReferrerAmount).toEqual(57448603);
    expect(decoded.refCount).toEqual(1);
    expect(decoded.saAddress).toEqual(address(STORM_VAULT_TRADE_SA));

    println("STORM_VAULT_TRADE_NOTIFICATION_V2_TX={} LT={}", txHash, txLt);
}

get fun `test storm vault decodes toncenter referral fees outgoing body`() {
    val txHash = "/LM9wrRg9W4+y6TWtxAmu94iId5rEjBFZuoNvT5buls=";
    val txLt = "81734442000006";
    val bodyBoc = "te6cckEBAgEAgQABp0/tyCsAAAAAaiLkiYAB+4+1u44BN1q8YnlYf70xpqBcaCtruZRil7ByHyo2iigG2TE3ACxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/oAEATxRhSmjcfgBlFv0k2uiI0jffRUOEqMFA68na3cjvZR3wEqBt+ubDFhC2ppYB";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralFees.fromCell(body);

    expect(decoded.queryId).toEqual(1780671625);
    expect(decoded.referralSaAddress).toEqual(address(STORM_VAULT_TRADE_SA));
    expect(decoded.amount).toEqual(57448603);
    expect(decoded.jettonMinterAddress).toEqual(address(STORM_USDT_MINTER));

    println("STORM_VAULT_REFERRAL_FEES_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test storm vault decodes toncenter jetton transfer outgoing body`() {
    val txHash = "2d6q3lGtnobjScA5wbVflxsCa++gRn3C5e0wJSKAOU4=";
    val txLt = "81940809000001";
    val bodyBoc = "te6cckEBAQEAVwAAqg+KfqUAAAAAAAAAAEAQ1PmIAP8ZiTFGMMAeTqtPdUipvxFo0zOeuy+ZLGc7ZxzChL8rACefmnNDYymiaYfPrulfl3IVUhKTENdh4xYtu2FIqdfSAgLYyyak";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = JettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(17649560);
    expect(decoded.destination).toEqual(
        address("0:7F8CC498A318600F2755A7BAA454DF88B46999CF5D97CC96339DB38E61425F95"),
    );
    expect(decoded.responseDestination).toEqual(address(STORM_ORIGIN));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(1);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAULT_JETTON_TRANSFER_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test storm vault decodes toncenter legacy trade body`() {
    val txHash = "Qh57lXGkoKyVvwlmvBF6ZejQuAVQvcHxH6uFc0ZpS0o=";
    val txLt = "81940970000007";
    val bodyBoc = "te6cckEBAwEAsAAC8jR1/dIAnAAAAABMJ7P6AAAABf1IAKEAAAAAAAAAAAAAAAAAAAAAAAAAACCjTSIAAAAAAAAAAIAWvwXFU5cXKTJfM7clTycy74fLMFdqgx7nAkusqTlZAtACefmnNDYymiaYfPrulfl3IVUhKTENdh4xYtu2FIqdfSMBAgBLQMFo5YgB5ssFVnhL/laej+D50I41UYXeKbyU5SQmKt3o+sL5AScAEaFTULsYAAAAFItSsDc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormVaultTradeNotification.fromCell(body);

    expect(decoded.ammIndex).toEqual(156);
    expect(decoded.freeAmount).toEqual(1277670394);
    expect(decoded.lockedAmount).toEqual(25724190881);
    expect(decoded.exchangeAmount).toEqual(0);
    expect(decoded.withdrawLockedAmount).toEqual(0);
    expect(decoded.feeToStakers).toEqual(547573026);
    expect(decoded.withdrawAmount).toEqual(0);
    expect(decoded.traderAddr).toEqual(
        address("0:B5F82E2A9CB8B94992F99DB92A7939977C3E5982BB5418F738125D6549CAC816"),
    );
    expect(decoded.withdrawDestination).toEqual(address(STORM_ORIGIN));
    expect(decoded.referralParams).toBeNotNull();
    expect(decoded.executorParams).toBeNotNull();

    println("STORM_VAULT_LEGACY_TRADE_TX={} LT={}", txHash, txLt);
}

get fun `test storm vault decodes toncenter add amount outgoing bodies`() {
    val txHash = "Qh57lXGkoKyVvwlmvBF6ZejQuAVQvcHxH6uFc0ZpS0o=";
    val txLt = "81940970000007";
    val addExecutorBoc = "te6cckEBAQEALAAAU13WZXlBly2tWAE8/NOaGxlNE0w+fXdK/LuQqpCUmIa7DxixbdsKRU6+ke/KB2U=";
    val addReferralBoc = "te6cckEBAQEALAAAU4Tc7XpAwWjliAE8/NOaGxlNE0w+fXdK/LuQqpCUmIa7DxixbdsKRU6+kQw0sik=";
    val addExecutor = StormAddExecutorAmount.fromCell(parseCellFromBase64(addExecutorBoc));
    val addReferral = StormAddReferralAmount.fromCell(parseCellFromBase64(addReferralBoc));

    expect(addExecutor.referralAmount).toEqual(426957525);
    expect(addExecutor.originAddr).toEqual(address(STORM_ORIGIN));
    expect(addReferral.referralAmount).toEqual(202804824);
    expect(addReferral.originAddr).toEqual(address(STORM_ORIGIN));

    println("STORM_VAULT_ADD_AMOUNT_OUT_TX={} LT={}", txHash, txLt);
}
