import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_lp_wallet.types"

const LP_WALLET_OWNER_A = "0:2457FFDA7E6C000FBC3FF1B87D04C42512C4A00E4550D1B9C98550A42464F73F"
const LP_WALLET_OWNER_B = "0:9C062B8FA0ED5B341048F23AB3AEA3402DE69E52F217C539B3A6E411A89E64E3"
const LP_WALLET_BURN_OWNER = "0:0EB482E6AB9E6C5F2055CD97086D3F24FE5951317E1C078FC2A87A0E5C62393E"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectAbsentMaybeRefTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(1);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(tail.loadBool()).toBeFalse();
    expectNoTail(mutate tail);
}

fun expectRefBackedForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(1);
}

get fun `test storm lp wallet decodes real transfer request body`() {
    val txHash = "P82VSQJZ95OgAW1v2f1kMhN64efVsvtOqTPfEWRyvRs=";
    val txLt = "80911838000012";
    val bodyBoc = "te6cckEBBAEAlwABrg+KfqU67C2Ufc3xzDW42AgBOAxXH0HatmggkeR1Z11GgFvNPKXkL4pzZ03II1E8yccACRX/9p+bAAPvD/xuH0ExCUSxKAORVDRucmFUKQkZPc/IHc1lAQEBVeOg1IKAG4XtEnLnY/sK5fQHFK9ckLW2fkYpEaChL+z4iTPrwrfkA0d/a0ACAglqHfFHDgMDAAguHPqC3sdylQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(4245818664492593612);
    expect(decoded.amount).toEqual(6000000);
    expect(decoded.destination).toEqual(address(LP_WALLET_OWNER_B));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(LP_WALLET_OWNER_A));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(250000000);
    expectRefBackedForwardPayload(mutate forwardPayload);

    println("STORM_LP_WALLET_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp wallet decodes real peer internal transfer body`() {
    val txHash = "P82VSQJZ95OgAW1v2f1kMhN64efVsvtOqTPfEWRyvRs=";
    val txLt = "80911838000012";
    val bodyBoc = "te6cckEBBAEAlwABrReNRRk67C2Ufc3xzDW42AgASK//tPzYAB94f+Nw+gmISiWJQByKoaNzkwqhSEjJ7n8ACRX/9p+bAAPvD/xuH0ExCUSxKAORVDRucmFUKQkZPc/QO5rKAwEBVeOg1IKAG4XtEnLnY/sK5fQHFK9ckLW2fkYpEaChL+z4iTPrwrfkA0d/a0ACAglqHfFHDgMDAAguHPqCvbvIUw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletInternalTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(4245818664492593612);
    expect(decoded.amount).toEqual(6000000);
    expect(decoded.fromAddress).toEqual(address(LP_WALLET_OWNER_A));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(LP_WALLET_OWNER_A));
    expect(decoded.forwardTonAmount).toEqual(250000000);
    expectRefBackedForwardPayload(mutate forwardPayload);

    println("STORM_LP_WALLET_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp wallet decodes real burn request body`() {
    val txHash = "0oLeynZwuNjo/7jd388+xa1PEdBe0szhBPHICXqIdcA=";
    val txLt = "48167315000003";
    val bodyBoc = "te6cckEBAQEANQAAZllfB7wAAAAAAAAAAFAbai/HGAAdaQXNVzzYvkCrmy4Q2n5J/LKiYvw4Dx+FUPQcuMRyfALrFeU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletBurn.fromCell(body);
    var tail = decoded.tail;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(7359102065);
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(LP_WALLET_BURN_OWNER));
    expectAbsentMaybeRefTail(mutate tail);

    println("STORM_LP_WALLET_BURN_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp wallet decodes real burn notification body`() {
    val txHash = "0oLeynZwuNjo/7jd388+xa1PEdBe0szhBPHICXqIdcA=";
    val txLt = "48167315000003";
    val bodyBoc = "te6cckEBAQEAVwAAqXvdl94AAAAAAAAAAFAbai/HGAAdaQXNVzzYvkCrmy4Q2n5J/LKiYvw4Dx+FUPQcuMRyfQADrSC5quebF8gVc2XCG0/JP5ZUTF+HAePwqh6DlxiOT6D0m5BZ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletBurnNotification.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(7359102065);
    expect(decoded.senderAddress).toEqual(address(LP_WALLET_BURN_OWNER));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(LP_WALLET_BURN_OWNER));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LP_WALLET_BURN_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp wallet decodes real transfer notification body`() {
    val txHash = "a+pp7aM/mHRKgG5SxUW0TJzp/sC80vwLE1H29rttFP4=";
    val txLt = "80911838000014";
    val bodyBoc = "te6cckEBBAEAcQABYnNi0Jw67C2Ufc3xzDW42AgASK//tPzYAB94f+Nw+gmISiWJQByKoaNzkwqhSEjJ7n8BAVXjoNSCgBuF7RJy52P7CuX0BxSvXJC1tn5GKRGgoS/s+Ikz68K35ANHf2tAAgIJah3xRw4DAwAILhz6glh+lfg=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(4245818664492593612);
    expect(decoded.amount).toEqual(6000000);
    expect(decoded.fromAddress).toEqual(address(LP_WALLET_OWNER_A));
    expectRefBackedForwardPayload(mutate forwardPayload);

    println("STORM_LP_WALLET_TRANSFER_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp wallet decodes real excesses body`() {
    val txHash = "4OBPV2V8PMRbGG0XiT5CcEY03cFFjjvFmPIRyzu+lYs=";
    val txLt = "48167293000002";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAACvO0mOZQeagj5s=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(48167293000001);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LP_WALLET_EXCESSES_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp wallet decodes real bounced known body prefix`() {
    val txHash = "wWjB4Wt4m5be3Yt/nO0sP2tyPmUaJbRKSTuyaf9VLLE=";
    val txLt = "80911844000002";
    val bodyBoc = "te6cckEBAQEAJgAASP////9zYtCcAAAAAAAAAABDOZ+RiAAnqSKRg6Go8uQo2lUFKnRmwOU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpWalletBouncedKnownBody.fromCell(body);
    val tail = decoded.tail;

    expect(decoded.originalOpcode).toEqual(0x7362d09c);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(865728792);
    expect(tail.remainingBitsCount()).toEqual(124);
    expect(tail.remainingRefsCount()).toEqual(0);

    println("STORM_LP_WALLET_BOUNCED_KNOWN_BODY_TX={} LT={}", txHash, txLt);
}
