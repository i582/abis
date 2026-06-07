import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/nominator_pool.types"

const VALIDATOR_PUBKEY = 0x7dfd70b822d590249ee678282d927e21279fa473bb67bc5d5ba7413606c7050e
const ADNL_ADDR = 0x95343c09f5d4f1830c8ae4c8577c66ee779fa723d0c8d10acaffac9f346b1eca
const SIGNATURE_HASH = 0x1973aab0f8172e02518793db0491d5f775608432843e790e9658c81d94b8418e

const DEPOSIT_BODY_HASH = 0xe94b342a5af00f2b4003cd179560966759b8eca704f566fae242418b53771fc8
const WITHDRAW_BODY_HASH = 0xc3736fc1c941bf240f8c95a613f7395550cc0814ef7ac7a7eaa0141f13426eea
const PROCESS_WITHDRAW_BODY_HASH = 0xbd717fb0ec057c932f95fec235eab79792d06cadb814f1f6ea4d76c06e8bdbad
const VALIDATOR_WITHDRAW_BODY_HASH = 0x1ce98f8c4bb94e1768b6e5fc838fe2d8826f10046fec2a4a49d0c52bf0fc5017
const UPDATE_VALIDATOR_SET_BODY_HASH = 0x4ef8a4533a36cd999b57c106a756bd8fbd064ab8b3d2805f476451f5552f7519
const RECOVER_STAKE_BODY_HASH = 0x276d4a9c571407baf781920510c217a531a82ff24f1086b78010eaa0e4b9308e
const NEW_STAKE_IN_BODY_HASH = 0x53a007e96f2c7334287753f0c16a3f1f18f63e38f4e28d08505bb67cc654cd32
const NEW_STAKE_OUT_BODY_HASH = 0x65832382a689b9e677eb193a21c6257f2b2fca64a0fd58063cecc2253763c4a7
const NEW_STAKE_OK_BODY_HASH = 0x6c0240c03605c8a6d82aaa1895c1e075b04b4c867df3df417918088066f4dc36
const RECOVER_STAKE_OK_BODY_HASH = 0xf4258273b7019713fcde9fdbb768dbb8d78983bdb1281cd8d8b3efe097db51cc
const EMPTY_BODY_HASH = 0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectEmptyBody(body: cell): void {
    val raw = body.beginParse();
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);
}

fun expectNewStakePayload(
    validatorPubkey: bits256,
    stakeAt: uint32,
    maxFactor: uint32,
    adnlAddr: bits256,
    signature: Cell<bits512>,
): void {
    expect(validatorPubkey).toEqual(bits256FromUint(VALIDATOR_PUBKEY));
    expect(stakeAt).toEqual(1780829960);
    expect(maxFactor).toEqual(294912);
    expect(adnlAddr).toEqual(bits256FromUint(ADNL_ADDR));
    expect(signature.hash()).toEqual(SIGNATURE_HASH);
}

get fun `test nominator pool decodes real deposit text comment body`() {
    val txHash = "Eq/p+uSk7H1PE+Bpay6Tf/Miz4KtKkP1MaCQchyFpOA=";
    val txLt = "65761862000001";
    val body = parseCellFromBase64("te6cckEBAQEABwAACgAAAABkSdX8Kw==");
    val decoded = NominatorPoolTextCommand.fromCell(body);
    var tail = decoded.tail;

    expect(body.hash()).toEqual(DEPOSIT_BODY_HASH);
    expect(decoded.action).toEqual(100);
    expectNoTail(mutate tail);

    println("NOMINATOR_POOL_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real withdraw text comment body`() {
    val txHash = "+UipF2Wb4scHBza7BAkZpjUxJNssClxnNLNJNMK0BiI=";
    val txLt = "64768504000001";
    val body = parseCellFromBase64("te6cckEBAQEABwAACgAAAAB30uHyKA==");
    val decoded = NominatorPoolTextCommand.fromCell(body);
    var tail = decoded.tail;

    expect(body.hash()).toEqual(WITHDRAW_BODY_HASH);
    expect(decoded.action).toEqual(119);
    expectNoTail(mutate tail);

    println("NOMINATOR_POOL_WITHDRAW_TEXT_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real process withdraw requests body`() {
    val txHash = "PLmfyptRMejHKIlKCQ+v0Sng0UrwV2wQ8Cq02cMaUbo=";
    val txLt = "64782751000003";
    val body = parseCellFromBase64("te6cckEBAQEAEgAAIAAAAAIAAAAAaUPQWgAAAGQqdC+J");
    val decoded = NominatorPoolProcessWithdrawRequests.fromCell(body);
    var tail = decoded.tail;

    expect(body.hash()).toEqual(PROCESS_WITHDRAW_BODY_HASH);
    expect(decoded.queryId).toEqual(1766051930);
    expect(decoded.limit).toEqual(0);
    expect(tail.remainingBitsCount()).toEqual(24);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(tail.loadUint(24)).toEqual(100);
    expectNoTail(mutate tail);

    println("NOMINATOR_POOL_PROCESS_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real validator withdraw body`() {
    val txHash = "rrv2XY42GL+6cNhiJGRdb48SNpWFP8F4UrCoybl/AhY=";
    val txLt = "77110316000003";
    val body = parseCellFromBase64("te6cckEBAQEAFAAAIwAAAAUAAAAAagbQD1F0h26ACKxmxBU=");
    val decoded = NominatorPoolValidatorWithdraw.fromCell(body);

    expect(body.hash()).toEqual(VALIDATOR_WITHDRAW_BODY_HASH);
    expect(decoded.queryId).toEqual(1778831375);
    expect(decoded.amount).toEqual(100000000000);

    println("NOMINATOR_POOL_VALIDATOR_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real update validator set body`() {
    val txHash = "2bbHyPZSsqi3MMeDPCQjrylor/OoUkt3JwQZCmIgVQw=";
    val txLt = "82127309000003";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGAAAAAYAAAAAaiVPtoX4wrw=");
    val decoded = NominatorPoolUpdateValidatorSetHash.fromCell(body);

    expect(body.hash()).toEqual(UPDATE_VALIDATOR_SET_BODY_HASH);
    expect(decoded.queryId).toEqual(1780830134);

    println("NOMINATOR_POOL_UPDATE_VALIDATOR_SET_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real recover stake command body`() {
    val txHash = "s00+NJzcro5O+suyqJ1iEb2fr3UF7IMAcEDyd1WEiGo=";
    val txLt = "82046689000003";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGEdldCQAAAAAaiTREtOQSj0=");
    val decoded = NominatorPoolRecoverStake.fromCell(body);

    expect(body.hash()).toEqual(RECOVER_STAKE_BODY_HASH);
    expect(decoded.queryId).toEqual(1780797714);

    println("NOMINATOR_POOL_RECOVER_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real incoming new stake validator command body`() {
    val txHash = "nIYm5EyhTkU+v3+CWHYBJxSxAeSfMUjd9qAJaF9g2qU=";
    val txLt = "82046700000003";
    val body = parseCellFromBase64("te6cckEBAgEAoQABt05zdEsAAAAAaiTRFnCEWf272tD339cLgi1ZAknuZ4KC2SfiEnn6Rzu2e8XVunQTYGxwUOaiVPCAAEgACVNDwJ9dTxgwyK5MhXfGbud5+nI9DI0QrK/6yfNGseyoAQCAlMrzD4gQm1mmiKQ052vv8b0TkAtq/BUCIzILFYqtjUlK+6/3HuMnmTR4BxCEOtTbIBORxVdJB7QKN1kFszUrD8Q2Ly0=");
    val decoded = NominatorPoolNewStake.fromCell(body);

    expect(body.hash()).toEqual(NEW_STAKE_IN_BODY_HASH);
    expect(decoded.queryId).toEqual(1780797718);
    expect(decoded.stakeValue).toEqual(2328352702442767);
    expectNewStakePayload(decoded.validatorPubkey, decoded.stakeAt, decoded.maxFactor, decoded.adnlAddr, decoded.signature);

    println("NOMINATOR_POOL_NEW_STAKE_IN_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real outgoing elector new stake body`() {
    val txHash = "nIYm5EyhTkU+v3+CWHYBJxSxAeSfMUjd9qAJaF9g2qU=";
    val txLt = "82046700000003";
    val body = parseCellFromBase64("te6cckEBAgEAmQABqE5zdEsAAAAAaiTRFn39cLgi1ZAknuZ4KC2SfiEnn6Rzu2e8XVunQTYGxwUOaiVPCAAEgACVNDwJ9dTxgwyK5MhXfGbud5+nI9DI0QrK/6yfNGseygEAgJTK8w+IEJtZpoikNOdr7/G9E5ALavwVAiMyCxWKrY1JSvuv9x7jJ5k0eAcQhDrU2yATkcVXSQe0CjdZBbM1Kw+oBkso");
    val decoded = NominatorPoolElectorNewStake.fromCell(body);

    expect(body.hash()).toEqual(NEW_STAKE_OUT_BODY_HASH);
    expect(decoded.queryId).toEqual(1780797718);
    expectNewStakePayload(decoded.validatorPubkey, decoded.stakeAt, decoded.maxFactor, decoded.adnlAddr, decoded.signature);

    println("NOMINATOR_POOL_NEW_STAKE_OUT_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real elector new stake ok body`() {
    val txHash = "idqbEZ1enDohNc0r8zHFFsRDkCl1mzvI0Aga0MWPVgg=";
    val txLt = "82046700000007";
    val body = parseCellFromBase64("te6cckEBAQEAEgAAIPN0SEwAAAAAaiTRFgAAAACqSo35");
    val decoded = NominatorPoolNewStakeOk.fromCell(body);
    var tail = decoded.tail;

    expect(body.hash()).toEqual(NEW_STAKE_OK_BODY_HASH);
    expect(decoded.queryId).toEqual(1780797718);
    expect(tail.remainingBitsCount()).toEqual(32);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(tail.loadUint(32)).toEqual(0);
    expectNoTail(mutate tail);

    println("NOMINATOR_POOL_NEW_STAKE_OK_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real elector recover stake ok body`() {
    val txHash = "BtRz0mFetaZG6me0kfwe8UYSDjaSFbviRn5q0fYNRpk=";
    val txLt = "82046689000007";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGPlvcyQAAAAAaiTREolkcgo=");
    val decoded = NominatorPoolRecoverStakeOk.fromCell(body);

    expect(body.hash()).toEqual(RECOVER_STAKE_OK_BODY_HASH);
    expect(decoded.queryId).toEqual(1780797714);

    println("NOMINATOR_POOL_RECOVER_STAKE_OK_TX={} LT={}", txHash, txLt);
}

get fun `test nominator pool decodes real empty outgoing body`() {
    val txHash = "+UipF2Wb4scHBza7BAkZpjUxJNssClxnNLNJNMK0BiI=";
    val txLt = "64768504000001";
    val body = parseCellFromBase64("te6cckEBAQEAAgAAAEysuc0=");
    val decoded = NominatorPoolEmptyBody.fromCell(body);

    expect(body.hash()).toEqual(EMPTY_BODY_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectEmptyBody(body);

    println("NOMINATOR_POOL_EMPTY_OUT_TX={} LT={}", txHash, txLt);
}
