import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_executor.types"

const INITIAL_OWNER_ADDRESS = "0:4de480ab6acefd53c158126ef5c2cdf89fe64d210d0b44da5c90e52c215dce79"
const REDIRECT_ADDRESS = "0:afbd6698187ff01747c1d6df0a0443768d182174f5f8323d5748aafce68b1184"
const CLAIM_OWNER_ADDRESS = "0:0eb482e6ab9e6c5f2055cd97086d3f24fe5951317e1c078fc2a87a0e5c62393e"
const CLAIM_VAULT_ADDRESS = "0:f29d17a209e2bcc652916d802ba69e23cb366e17afad61f8453343b9ba53ace4"
const ADD_AMOUNT_ORIGIN_ADDRESS = "0:9dc3b1a65b0b2e0c2a682eec48c8ac82f6bfaf0eabafa6578777e3bfa41845a4"
const PROVIDE_VAULT_ADDRESS = "0:fa87bdeb3c237eb2b6daf71b35095011b31fbc7115de332c148af3887d5c73d9"
const PROVIDE_ORIGIN_ADDRESS = "0:763a947d82a6fa9668a29c004b8edd590c68c757a5cef52f83ab312fd8e28832"
const INITIAL_BALANCE_VAULT_HASH =
    0xf29d17a209e2bcc652916d802ba69e23cb366e17afad61f8453343b9ba53ace4
const PROVIDE_VAULT_HASH =
    0xfa87bdeb3c237eb2b6daf71b35095011b31fbc7115de332c148af3887d5c73d9
const TRANSFER_QUERY_ID = 0xf95b6c08e7439103

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadUint(1)).toEqual(0);
    expectNoTail(mutate payload);
}

fun expectProvideVaultRequestTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.loadCoins()).toEqual(11976048);
    expect(tail.loadAddress()).toEqual(address(PROVIDE_ORIGIN_ADDRESS));
    expectNoTail(mutate tail);
}

fun expectVaultsReplyTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.loadAddress()).toEqual(address(PROVIDE_VAULT_ADDRESS));
    expect(tail.loadCoins()).toEqual(11976048);
    expect(tail.loadAddress()).toEqual(address(PROVIDE_ORIGIN_ADDRESS));
    expectNoTail(mutate tail);
}

fun expectInitialBalances(balances: map<uint256, coins>): void {
    expect(balances).toHaveLength(1);
    expect(balances.mustGet(INITIAL_BALANCE_VAULT_HASH)).toEqual(0);
}

fun expectVaultWhitelist(whitelist: map<uint256, coins>): void {
    expect(whitelist.isEmpty()).toBeFalse();
    expect(whitelist.mustGet(PROVIDE_VAULT_HASH)).toEqual(0);
}

get fun `test storm executor decodes toncenter mint body`() {
    val txHash = "KDq1U+sB1H3l5R4YuF6k/ugx4VYppLCG8YIUa61FlGc=";
    val txLt = "41881176000005";
    val bodyBoc = "te6cckEBAgEAbgABjU84yuiACbyQFW1Z36p4KwJN3rhZvxP8yaQhoWibS5IcpYQruc8wAr71mmBh/8BdHwdbfCgRDdo0YIXT1+DI9V0iq/OaLEYTAQBDoB5TovRBPFeYylItsAV008R5Zs3C9fWsPwimaHc3SnWcgQD/ZVo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormMintExecutor.fromCell(body);

    expect(decoded.nftOwner).toEqual(address(INITIAL_OWNER_ADDRESS));
    expect(decoded.redirectAddress).toEqual(address(REDIRECT_ADDRESS));
    expectInitialBalances(decoded.balancesDict);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter add amount body`() {
    val txHash = "yd2hEG8NhhZxQ7Q/1zKM6OQ2dvpsmKNv0yv/kqXBLLU=";
    val txLt = "57943106000009";
    val bodyBoc = "te6cckEBAQEAKwAAUV3WZXkwHT0YATuHY0y2FlwYVNBd2JGRWQXtf14dV19Mrw7vx39IMItJsRnkJQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormAddExecutorAmount.fromCell(body);

    expect(decoded.referralAmount).toEqual(119761);
    expect(decoded.originAddr).toEqual(address(ADD_AMOUNT_ORIGIN_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_ADD_AMOUNT_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter vaults reply body`() {
    val txHash = "Tu3c8ogJMSwfl6U/WH2kquqqoJ2eaQaWCmMOtbPrN1Q=";
    val txLt = "58521282000001";
    val bodyBoc = "te6cckECDgEAAWgAAZVplhWNwA+oe96zwjfrK22vcbNQlQEbMfvHEV3jMsFIrziH1cc9k7a9cIAOx1KPsFTfUs0UU4AJcdurIY0Y6vS53qXwdWYl+xxRBlABAgEgAgMCASAEBQIBIAgJAgEgBgcAQ7+wfRtqEf3ZzhkeGsmXiC7hzTh1C5zZZzLgDH5VL8gENQgAQ79N5+DnhKtJNU37mRNX6iTHHAyyEWYcguf6ejoDqewPehAAQ79n09Ca+X3/4aR2crDqhBx0PZcFxILSV9E4/UV6TuLW7hAAQ7+f4e6j3p3N5i/uAris16/HRfuQvRFj242swf7JhC0dxwgCAVgKCwBDvySZ2T/PScsc93rg2l1xVIcAlrWjnkZolCU4t4xmIBfEIAIBIAwNAEO+1Oi9EE8V5jKUi2wBXTTxHlmzcL19aw/CKZodzdKdZyBAAEO+1D3vWeEb9ZW217jZqEqAjZj944iu8ZlgpFecQ+rjnshAfPfKKQ==";
    val body = parseCellFromBase64(bodyBoc);
    var decoded = StormExecutorVaultsReply.fromCell(body);

    expectVaultWhitelist(decoded.vaultsWhitelist);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectVaultsReplyTail(mutate decoded.requestTail);

    println("STORM_EXECUTOR_VAULTS_REPLY_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter claim body`() {
    val txHash = "4VioOBQHLWpN8aUqf1sJYqvoNBgdr5dWx3nWX4JBlhU=";
    val txLt = "54001251000001";
    val bodyBoc = "te6cckEBAQEAKAAAS4xnniOAHlOi9EE8V5jKUi2wBXTTxHlmzcL19aw/CKZodzdKdZyQ8xao1Q==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormClaimExecutorAmount.fromCell(body);

    expect(decoded.vaultAddress).toEqual(address(CLAIM_VAULT_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_CLAIM_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter transfer body`() {
    val txHash = "ialy/bfA9AN7Y2V5HrdsMrJGqxpMldMjwjO/aUUaUDs=";
    val txLt = "53961395000001";
    val bodyBoc = "te6cckEBAQEAVgAAp1/MPRT5W2wI50ORA4AB1pBc1XPNi+QKubLhDafkn8sqJi/DgPH4VQ9By4xHJ9AAOtILmq55sXyBVzZcIbT8k/llRMX4cB4/CqHoOXGI5PiAvrwgCAIq41I=";
    val body = parseCellFromBase64(bodyBoc);
    var decoded = StormExecutorTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(TRANSFER_QUERY_ID);
    expect(decoded.newOwnerAddress).toEqual(address(CLAIM_OWNER_ADDRESS));
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(address(CLAIM_OWNER_ADDRESS));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(100000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectInlineEmptyForwardPayload(mutate decoded.forwardPayload);

    println("STORM_EXECUTOR_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter withdraw body`() {
    val txHash = "4VioOBQHLWpN8aUqf1sJYqvoNBgdr5dWx3nWX4JBlhU=";
    val txLt = "54001251000001";
    val bodyBoc = "te6cckEBAQEAMgAAXyzeY1EAAAAAYRl0V63m2AAdaQXNVzzYvkCrmy4Q2n5J/LKiYvw4Dx+FUPQcuMRyfT0aTF0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormWithdrawExecutorAmount.fromCell(body);

    expect(decoded.index).toEqual(0);
    expect(decoded.executorAmount).toEqual(19341403414125);
    expect(decoded.ownerAddr).toEqual(address(CLAIM_OWNER_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter provide vaults request body`() {
    val txHash = "Tu3c8ogJMSwfl6U/WH2kquqqoJ2eaQaWCmMOtbPrN1Q=";
    val txLt = "58521282000001";
    val bodyBoc = "te6cckEBAQEATQAAld1aq3OAH1D3vWeEb9ZW217jZqEqAjZj944iu8ZlgpFecQ+rjnsnbXrhAB2OpR9gqb6lmiinABLjt1ZDGjHV6XO9S+DqzEv2OKIMoNn4+mE=";
    val body = parseCellFromBase64(bodyBoc);
    var decoded = StormExecutorProvideVaultsRequest.fromCell(body);

    expect(decoded.vaultAddress).toEqual(address(PROVIDE_VAULT_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectProvideVaultRequestTail(mutate decoded.requestTail);

    println("STORM_EXECUTOR_PROVIDE_VAULTS_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter ownership assigned body`() {
    val txHash = "ialy/bfA9AN7Y2V5HrdsMrJGqxpMldMjwjO/aUUaUDs=";
    val txLt = "53961395000001";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZH5W2wI50ORA4AJvJAVbVnfqngrAk3euFm/E/zJpCGhaJtLkhylhCu5zyhXIoxW";
    val body = parseCellFromBase64(bodyBoc);
    var decoded = StormExecutorOwnershipAssigned.fromCell(body);

    expect(decoded.queryId).toEqual(TRANSFER_QUERY_ID);
    expect(decoded.previousOwnerAddress).toEqual(address(INITIAL_OWNER_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectInlineEmptyForwardPayload(mutate decoded.forwardPayload);

    println("STORM_EXECUTOR_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor decodes toncenter excess body`() {
    val txHash = "ialy/bfA9AN7Y2V5HrdsMrJGqxpMldMjwjO/aUUaUDs=";
    val txLt = "53961395000001";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtv5W2wI50ORA/GP1CI=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormExecutorExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(TRANSFER_QUERY_ID);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_EXCESSES_TX={} LT={}", txHash, txLt);
}
