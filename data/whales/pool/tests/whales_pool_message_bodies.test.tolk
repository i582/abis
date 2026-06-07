import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/whales_pool.types"

const MESSAGE_FIXTURE_JSON = "data/whales/research/toncenter_pool_message_bodies.json"

const STAKE_SEND_QUERY_ID = 1780804460099
const STAKE_AT = 1780829960
const MAX_FACTOR = 196608
const STAKE_AMOUNT = 975465112634631
const VALIDATOR_PUBKEY = 0x9b20fd9f5da69b580a90f253b9e345850acfcdaba40d0b5dd20fe8880e7db622
const ADNL_ADDR = 0xd1dac99d5fe0880e223f77bda1f4ea4a0beaa315d3aa686e5de234fc0bc1fec2
const SIGNATURE_HASH = 0x26c3a88d77c313f920b624e026525c7dcda74b011ac9b1a93716265105a841fd
const ACCEPT_STAKES_MEMBERS_HASH = 0xbbddc896da072377525abb0c3a8a8ef91a58137e33e1b1dc3ff62031db443129
const ACCEPT_WITHDRAWS_MEMBERS_HASH = 0x3ac728fb741d56901caafe48a0c44c2ac5b019484ccc4586be5ee6deaa3c1428

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectStakeSendPayload(decoded: WhalesPoolStakeSend): void {
    expect(decoded.stake).toEqual(STAKE_AMOUNT);
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(STAKE_AT);
    expect(decoded.maxFactor).toEqual(MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(SIGNATURE_HASH);
}

fun expectElectorNewStakePayload(decoded: WhalesPoolElectorNewStake): void {
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(STAKE_AT);
    expect(decoded.maxFactor).toEqual(MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(SIGNATURE_HASH);
}

get fun `test whales pool decodes real user deposit withdraw and text bodies`() {
    val withdrawTx = "Jvh1pf+LCdi41qlaPL0j2RkfS6y8vKVBKFlz5yiKUK8=";
    val withdrawLt = "82145557000003";
    val withdrawBody = parseCellFromBase64("te6cckEBAQEAFwAAKtqAPv1UbeTvfLj6DjAYagUGSVNOALEAkck=");
    val withdraw = WhalesPoolStakeWithdraw.fromCell(withdrawBody);
    expect(withdraw.queryId).toEqual(6083770388888222222);
    expect(withdraw.gasLimit).toEqual(100000);
    expect(withdraw.amount).toEqual(27000000000);
    expect(withdraw.toCell().hash()).toEqual(withdrawBody.hash());

    val depositTx = "gWKs8hKc3yxb2XLcSe9C3ZRYgMxRBLS2HcOlLm631DQ=";
    val depositLt = "81983748000003";
    val depositBody = parseCellFromBase64("te6cckEBAQEAEgAAH3vNH+8AAH4yxKUU5jAYagiydXCO");
    val deposit = WhalesPoolStakeDeposit.fromCell(depositBody);
    expect(deposit.queryId).toEqual(138756512617702);
    expect(deposit.gasLimit).toEqual(100000);
    expect(deposit.toCell().hash()).toEqual(depositBody.hash());

    val textTx = "nTer3q/hLOsm3n8V1RurxVpA85jpg1i2uBplkN8KM9E=";
    val textLt = "81115786000013";
    val textBody = parseCellFromBase64("te6cckEBAQEADgAAGAAAAABXaXRoZHJhd6/QZtE=");
    val text = WhalesPoolTextComment.fromCell(textBody);
    var textTail = text.text;
    expect(textTail.remainingBitsCount()).toEqual(64);
    expect(textTail.remainingRefsCount()).toEqual(0);
    expect(textTail.loadUint(64)).toEqual(0x5769746864726177);
    expectNoTail(mutate textTail);
    expect(text.toCell().hash()).toEqual(textBody.hash());

    println("WHALES_POOL_WITHDRAW_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, withdrawTx, withdrawLt);
    println("WHALES_POOL_DEPOSIT_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, depositTx, depositLt);
    println("WHALES_POOL_TEXT_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, textTx, textLt);
}

get fun `test whales pool decodes real controller stake and pending-operation bodies`() {
    val stakeSendTx = "yb43a3FZdtxCj3vJ93mTJsMuIhv0em+OeernsbpGIFg=";
    val stakeSendLt = "82063491000003";
    val stakeSendBody = parseCellFromBase64("te6cckEBAgEAowABvKIGXywAAAGeoDeeQyw1BwN3LiuHhQebIP2fXaabWAqQ8lO540WFCs/Nq6QNC13SD+iIDn22ImolTwgAAwAA0drJnV/giA4iP3e9ofTqSgvqoxXTqmhuXeI0/AvB/sIBAIDmw4m56VmD+oiwzarNOxMu4S6GoxEyp1eAptbMwzioeN0mbabLr+F38EVVUrOh69osY25hFQLmCpYMiFJLZT8A5ESkEw==");
    val stakeSend = WhalesPoolStakeSend.fromCell(stakeSendBody);
    expect(stakeSend.queryId).toEqual(STAKE_SEND_QUERY_ID);
    expect(stakeSend.gasLimit).toEqual(50000);
    expectStakeSendPayload(stakeSend);
    expect(stakeSend.toCell().hash()).toEqual(stakeSendBody.hash());

    val acceptStakesTx = "0a5VjcTmGc5qrJ/BsssnLQghjQzQoWqn6wX5bHpGbAQ=";
    val acceptStakesLt = "82046325000007";
    val acceptStakesBody = parseCellFromBase64("te6cckEBAgEANwABH5moEfsAAAGen85yZzD0JAwBAEOgFfZHPkksN9VOgLx1zSmmX2sRt/3xy5O0GxloLZ4FqAN4T+a/bA==");
    val acceptStakes = WhalesPoolAcceptStakes.fromCell(acceptStakesBody);
    expect(acceptStakes.queryId).toEqual(1780797567591);
    expect(acceptStakes.gasLimit).toEqual(1000000);
    expect(acceptStakes.members).toBeNotNull();
    expect(acceptStakes.members!.hash()).toEqual(ACCEPT_STAKES_MEMBERS_HASH);
    expect(acceptStakes.toCell().hash()).toEqual(acceptStakesBody.hash());

    val acceptWithdrawsTx = "Ye08DsD7O4liBlzX2L575jZ9JViK1nEFx4FmtbOYQP8=";
    val acceptWithdrawsLt = "82046426000010";
    val acceptWithdrawsBody = parseCellFromBase64("te6cckEBAgEANwABH6Gf2TQAAAGen88TYDD0JAwBAEOgHoV1DRLUBspqnWFv0VAri/ZAN3G9Yh83A3VX8NIPplJYHQdXGA==");
    val acceptWithdraws = WhalesPoolAcceptWithdraws.fromCell(acceptWithdrawsBody);
    expect(acceptWithdraws.queryId).toEqual(1780797608800);
    expect(acceptWithdraws.gasLimit).toEqual(1000000);
    expect(acceptWithdraws.members).toBeNotNull();
    expect(acceptWithdraws.members!.hash()).toEqual(ACCEPT_WITHDRAWS_MEMBERS_HASH);
    expect(acceptWithdraws.toCell().hash()).toEqual(acceptWithdrawsBody.hash());

    println("WHALES_POOL_STAKE_SEND_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, stakeSendTx, stakeSendLt);
    println("WHALES_POOL_ACCEPT_STAKES_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, acceptStakesTx, acceptStakesLt);
    println("WHALES_POOL_ACCEPT_WITHDRAWS_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, acceptWithdrawsTx, acceptWithdrawsLt);
}

get fun `test whales pool decodes real controller recover finalize and unowned bodies`() {
    val recoverTx = "JQtsG535jm5f2SqMFBBRzKLee35LDJfVI4/ad0G060s=";
    val recoverLt = "82046210000003";
    val recoverBody = parseCellFromBase64("te6cckEBAQEAEgAAH2VNUY4AAAGen825qTAYaghDTlp0");
    val recover = WhalesPoolStakeRecover.fromCell(recoverBody);
    expect(recover.queryId).toEqual(1780797520297);
    expect(recover.gasLimit).toEqual(100000);
    expect(recover.toCell().hash()).toEqual(recoverBody.hash());

    val finalizeTx = "CMOJKmHdhlcz2Dvtgk3ujYJBNcWVIVVnkxVcVCyk8/c=";
    val finalizeLt = "81963997000007";
    val finalizeBody = parseCellFromBase64("te6cckEBAQEAEgAAHxWWkgwAAAGendUK5DAYaggKhe8A");
    val finalize = WhalesPoolStakeLockFinalize.fromCell(finalizeBody);
    expect(finalize.queryId).toEqual(1780764445412);
    expect(finalize.gasLimit).toEqual(100000);
    expect(finalize.toCell().hash()).toEqual(finalizeBody.hash());

    val unownedTx = "qbg4zoZGa7BV0xAUifcWwH7j1nKXdNnWogkwD3A4iqs=";
    val unownedLt = "82046478000005";
    val unownedBody = parseCellFromBase64("te6cckEBAQEAEgAAHyUdapgAAAGen89lEDAYaghEFHEI");
    val unowned = WhalesPoolWithdrawUnowned.fromCell(unownedBody);
    expect(unowned.queryId).toEqual(1780797629712);
    expect(unowned.gasLimit).toEqual(100000);
    expect(unowned.toCell().hash()).toEqual(unownedBody.hash());

    println("WHALES_POOL_RECOVER_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, recoverTx, recoverLt);
    println("WHALES_POOL_FINALIZE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, finalizeTx, finalizeLt);
    println("WHALES_POOL_WITHDRAW_UNOWNED_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, unownedTx, unownedLt);
}

get fun `test whales pool decodes real receipt and response bodies`() {
    val depositResponseTx = "gWKs8hKc3yxb2XLcSe9C3ZRYgMxRBLS2HcOlLm631DQ=";
    val depositResponseLt = "81983748000003";
    val depositResponseBody = parseCellFromBase64("te6cckEBAQEADgAAGMZB6TIAAH4yxKUU5tiSlGU=");
    val depositResponse = WhalesPoolStakeDepositResponse.fromCell(depositResponseBody);
    expect(depositResponse.queryId).toEqual(138756512617702);
    expect(depositResponse.toCell().hash()).toEqual(depositResponseBody.hash());

    val withdrawResponseTx = "Jvh1pf+LCdi41qlaPL0j2RkfS6y8vKVBKFlz5yiKUK8=";
    val withdrawResponseLt = "82145557000003";
    val withdrawResponseBody = parseCellFromBase64("te6cckEBAQEADgAAGCPUIeFUbeTvfLj6DgzCfrc=");
    val withdrawResponse = WhalesPoolStakeWithdrawResponse.fromCell(withdrawResponseBody);
    expect(withdrawResponse.queryId).toEqual(6083770388888222222);
    expect(withdrawResponse.toCell().hash()).toEqual(withdrawResponseBody.hash());

    val withdrawDelayedTx = "zPfMoUcgbcmJ4SYRq0eFr4DSzVHgj48d2HNlETLaB9Q=";
    val withdrawDelayedLt = "81758648000008";
    val withdrawDelayedBody = parseCellFromBase64("te6cckEBAQEADgAAGHS7NCdUbeTveNZEBwZJCHA=");
    val withdrawDelayed = WhalesPoolStakeWithdrawDelayed.fromCell(withdrawDelayedBody);
    expect(withdrawDelayed.queryId).toEqual(6083770388823032839);
    expect(withdrawDelayed.toCell().hash()).toEqual(withdrawDelayedBody.hash());

    val unownedResponseTx = "qbg4zoZGa7BV0xAUifcWwH7j1nKXdNnWogkwD3A4iqs=";
    val unownedResponseLt = "82046478000005";
    val unownedResponseBody = parseCellFromBase64("te6cckEBAQEADgAAGB0XFb8AAAGen89lENfg4dk=");
    val unownedResponse = WhalesPoolWithdrawUnownedResponse.fromCell(unownedResponseBody);
    expect(unownedResponse.queryId).toEqual(1780797629712);
    expect(unownedResponse.toCell().hash()).toEqual(unownedResponseBody.hash());

    val textReceiptTx = "nTer3q/hLOsm3n8V1RurxVpA85jpg1i2uBplkN8KM9E=";
    val textReceiptLt = "81115786000013";
    val textReceiptBody = parseCellFromBase64("te6cckEBAQEATwAAmgAAAABXaXRoZHJhdyByZXF1ZXN0ZWQuIFBsZWFzZSwgcmV0cnkgdGhlIGNvbW1hbmQgd2hlbiB5b3VyIGJhbGFuY2UgaXMgcmVhZHkuFrUgxw==");
    val textReceipt = WhalesPoolTextComment.fromCell(textReceiptBody);
    var receiptTail = textReceipt.text;
    expect(receiptTail.remainingBitsCount()).toBeGreater(64);
    expect(receiptTail.remainingRefsCount()).toEqual(0);
    expect(receiptTail.loadUint(64)).toEqual(0x5769746864726177);
    expect(textReceipt.toCell().hash()).toEqual(textReceiptBody.hash());

    println("WHALES_POOL_DEPOSIT_RESPONSE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, depositResponseTx, depositResponseLt);
    println("WHALES_POOL_WITHDRAW_RESPONSE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, withdrawResponseTx, withdrawResponseLt);
    println("WHALES_POOL_WITHDRAW_DELAYED_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, withdrawDelayedTx, withdrawDelayedLt);
    println("WHALES_POOL_WITHDRAW_UNOWNED_RESPONSE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, unownedResponseTx, unownedResponseLt);
    println("WHALES_POOL_TEXT_RECEIPT_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, textReceiptTx, textReceiptLt);
}

get fun `test whales pool decodes real elector request and response bodies`() {
    val newStakeOutTx = "yb43a3FZdtxCj3vJ93mTJsMuIhv0em+OeernsbpGIFg=";
    val newStakeOutLt = "82063491000003";
    val newStakeOutBody = parseCellFromBase64("te6cckEBAgEAmQABqE5zdEsAAAGeoDeeQ5sg/Z9dpptYCpDyU7njRYUKz82rpA0LXdIP6IgOfbYiaiVPCAADAADR2smdX+CIDiI/d72h9OpKC+qjFdOqaG5d4jT8C8H+wgEAgObDibnpWYP6iLDNqs07Ey7hLoajETKnV4Cm1szDOKh43SZtpsuv4XfwRVVSs6Hr2ixjbmEVAuYKlgyIUktlPwBZGjbr");
    val newStakeOut = WhalesPoolElectorNewStake.fromCell(newStakeOutBody);
    expect(newStakeOut.queryId).toEqual(STAKE_SEND_QUERY_ID);
    expectElectorNewStakePayload(newStakeOut);
    expect(newStakeOut.toCell().hash()).toEqual(newStakeOutBody.hash());

    val recoverRequestTx = "JQtsG535jm5f2SqMFBBRzKLee35LDJfVI4/ad0G060s=";
    val recoverRequestLt = "82046210000003";
    val recoverRequestBody = parseCellFromBase64("te6cckEBAQEADgAAGEdldCQAAAAAAAAAAEUmpq4=");
    val recoverRequest = WhalesPoolElectorRecoverStakeRequest.fromCell(recoverRequestBody);
    expect(recoverRequest.queryId).toEqual(0);
    expect(recoverRequest.toCell().hash()).toEqual(recoverRequestBody.hash());

    val newStakeOkTx = "VEVbqwaTlMBqFujyFQZcoJqZt9KfnzvBP0NOtaH7sqI=";
    val newStakeOkLt = "82063493000001";
    val newStakeOkBody = parseCellFromBase64("te6cckEBAQEAEgAAIPN0SEwAAAGeoDeeQwAAAAD6BOU4");
    val newStakeOk = WhalesPoolElectorNewStakeConfirmation.fromCell(newStakeOkBody);
    expect(newStakeOk.queryId).toEqual(STAKE_SEND_QUERY_ID);
    expect(newStakeOk.comment).toEqual(0);
    expect(newStakeOk.toCell().hash()).toEqual(newStakeOkBody.hash());

    val recoverResponseTx = "z2gOu7Zrpf9rUhM3779bJcZtiE93NYO0mW19IiHcjcI=";
    val recoverResponseLt = "82046214000001";
    val recoverResponseBody = parseCellFromBase64("te6cckEBAQEADgAAGPlvcyQAAAAAAAAAAB/Snpk=");
    val recoverResponse = WhalesPoolElectorRecoverStakeResponse.fromCell(recoverResponseBody);
    expect(recoverResponse.queryId).toEqual(0);
    expect(recoverResponse.toCell().hash()).toEqual(recoverResponseBody.hash());

    println("WHALES_POOL_ELECTOR_NEW_STAKE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, newStakeOutTx, newStakeOutLt);
    println("WHALES_POOL_ELECTOR_RECOVER_REQUEST_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, recoverRequestTx, recoverRequestLt);
    println("WHALES_POOL_ELECTOR_NEW_STAKE_OK_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, newStakeOkTx, newStakeOkLt);
    println("WHALES_POOL_ELECTOR_RECOVER_RESPONSE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, recoverResponseTx, recoverResponseLt);
}
