import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_prelaunch.types"

const STORM_PRELAUNCH_ADDRESS = "0:7E6B279D3E8C14B6210021F74D05DA7FD49FD595B76F79D7D1CA9F3EDF2AC086"
const STORM_PRELAUNCH_ADMIN_ADDRESS = "0:8FD0F51FB92617DEE43F22D4CBDB82FDFE2728AF670BE1C6E02938C87EB5CB4B"
const STORM_PRELAUNCH_REWARD_NOTIFIER = "0:748C1E39BE05C5D84DDFCB6427F1B9D072076A9FE2BCD01FB3C084FBD0700F98"
const STORM_PRELAUNCH_FIRST_USER = "0:D373935DA0E574264EF456A3865F279771E2C41ED71D6C850A71F6D2649DD6AF"
const STORM_PRELAUNCH_REFUND_USER = "0:5B21D1B1E8F169F06B4A3D9A06F2717C7878B41E3B9A79DFE1F5A51E777D52F4"
const STORM_PRELAUNCH_JETTON_WALLET = "0:B8D2D2F4C80C8FAE6B3E0AB940634F5E826A2C574E9736DD8D152D47F0240833"

const STORM_PRELAUNCH_JETTON_WALLET_HASH = 0xb8d2d2f4c80c8fae6b3e0ab940634f5e826a2c574e9736dd8d152d47f0240833
const STORM_PRELAUNCH_FIRST_USER_HASH = 0xd373935da0e574264ef456a3865f279771e2c41ed71d6c850a71f6d2649dd6af
const STORM_PRELAUNCH_CHANGE_CODE_HASH = 0xe3bb855bb5fa6756650c619ba551762817f8ff39b46437582514dfb3ab2f6aa3

fun expectEmptySlice(mutate stream: slice): void {
    expect(stream.remainingBitsCount()).toEqual(0);
    expect(stream.remainingRefsCount()).toEqual(0);
}

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
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

fun expectRefEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    var payloadBody = loadForwardPayloadRef(mutate payload).beginParse();
    expectEmptySlice(mutate payloadBody);
}

fun expectExtraRefundText(mutate payload: RemainingBitsAndRefs): void {
    var text = loadForwardPayloadRef(mutate payload).beginParse();

    expect(text.remainingBitsCount()).toEqual(288);
    expect(text.remainingRefsCount()).toEqual(0);
    expect(text.loadUint(32)).toEqual(0);
    expect(text.loadUint(64)).toEqual(0x4578747261205553);
    expect(text.loadUint(64)).toEqual(0x4454206f7220544f);
    expect(text.loadUint(64)).toEqual(0x4e20617265207365);
    expect(text.loadUint(64)).toEqual(0x6e74206261636b2e);
    expectEmptySlice(mutate text);
}

get fun `test storm prelaunch decodes toncenter provide wallet address body`() {
    val txHash = "bh2QOOz3aa4uiFdjpl9y0j35t6Xh92FQdgJBX8/zwYc=";
    val txLt = "48554227000001";
    val bodyBoc = "te6cckEBAQEAMAAAWyx2uXMAAAAAZsM9roAPzWTzp9GClsQgBD7poLtP+pP6srbt7zr6OVPn2+VYEMien2kS";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchProvideWalletAddress.fromCell(body);

    expect(decoded.queryId).toEqual(1724071342);
    expect(decoded.ownerAddress).toEqual(address(STORM_PRELAUNCH_ADDRESS));
    expect(decoded.includeAddress).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_PROVIDE_WALLET_ADDRESS_TX={} LT={} QUERY_ID={}", txHash, txLt, decoded.queryId);
}

get fun `test storm prelaunch decodes toncenter take wallet address body`() {
    val txHash = "LZEqwp3G2Nq/uD97buouS8UZaA6dHJlA/VPC8drnMrE=";
    val txLt = "48554233000001";
    val bodyBoc = "te6cckEBAQEAMAAAW9FzVAAAAAAAZsM9roAXGlpemQGR9c1nwVcoDGnr0E1FiunS5tuxoqWo/gSBBmiXpfS3";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchTakeWalletAddress.fromCell(body);

    expect(decoded.queryId).toEqual(1724071342);
    expect(decoded.walletAddress).toEqual(address(STORM_PRELAUNCH_JETTON_WALLET));
    expect(decoded.includeAddress).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_TAKE_WALLET_ADDRESS_TX={} LT={}", txHash, txLt);
}

get fun `test storm prelaunch decodes toncenter accepted jetton notify body`() {
    val txHash = "j+moCL/7Ln7Cp20gXkhS3V2eX+qq+xlBUGzNF6H/MA0=";
    val txLt = "48558210000001";
    val bodyBoc = "te6cckEBAgEANgABYnNi0JwAAAAAAAAAADtxsAgBpucmu0HK6Eyd6K1HDL5PLuPFiD2uOtkKFOPtpMk7rV8BAABq03r4";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchJettonNotify.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(12000000);
    expect(decoded.senderAddress).toEqual(address(STORM_PRELAUNCH_FIRST_USER));
    var forwardPayload = decoded.forwardPayload;
    expectRefEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_JETTON_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test storm prelaunch decodes toncenter set participants body`() {
    val txHash = "mpWc/irQNs5avnXomvaNL6autfVqUSeUejsB/8B3TpI=";
    val txLt = "48558138000001";
    val bodyBoc = "te6cckEBAgEAQQABGZ8qaJoAAAAAAAAAAMABAF2gGm5ya7QcroTJ3orUcMvk8u48WIPa462QoU4+2kyTutXggcnDgAAAAAAAAAAAEMMhpGY=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchSetParticipants.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.participants).toHaveLength(1);
    val participant = decoded.participants.mustGet(STORM_PRELAUNCH_FIRST_USER_HASH);
    expect(participant.targetAmount).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_SET_PARTICIPANTS_TX={} LT={} PARTICIPANT={}", txHash, txLt, participant);
}

get fun `test storm prelaunch decodes toncenter set reward notifier body`() {
    val txHash = "094/yY3w1kgO8mhntVys+jhmqR9FY3KAJ7nBAwId7IY=";
    val txLt = "48554411000001";
    val bodyBoc = "te6cckEBAQEAMAAAW8jnmW0AAAAAAAAAAIAOkYPHN8C4uwm7+WyE/jc6DkDtU/xXmgP2eBCfeg4B8xBmasLM";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchSetRewardNotifier.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.rewardNotifierAddress).toEqual(address(STORM_PRELAUNCH_REWARD_NOTIFIER));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_SET_REWARD_NOTIFIER_TX={} LT={}", txHash, txLt);
}

get fun `test storm prelaunch decodes toncenter change code body`() {
    val txHash = "SObmytWI054zN9RXsiZ73t3l7vxk77qqKBpQULf//SM=";
    val txLt = "48554580000001";
    val bodyBoc = "te6cckECFwEABNwAARicDzIgAAAAAAAAAAABART/APSkE/S88sgLAgIBYgMEAgLPBQYCAWoVFgTFDPQ0wMBcbCSXwPg+kAwIPAB7UTQ9AT6QNMf0x/TAPpA+kAwBvhhBPhiAvhj+GT4Zfhm+Gf4ReMDIscAkl8D4ALTH9M/IoIQ0XNUALrjAiKCEHNi0Jy64wIxMiCCEJ8qaJq6gBwgJCgARPpEMHC68uFNgALRfA/hGcPgjghAsdrlzIsiCCTEtAPoCy2rLH8s/+CjPFssAgBjIywVYzxYBzxfJcfsAcfhl+EH4QvhD+ET4RfhG+EcGyPQAUAXPFhPLH8sfywABzxYBzxbJ7VQAaGwx+kAwAfhGxwXytPhm+EH4QvhD+ET4RfhG+EcGyPQAUAXPFhPLH8sfywABzxYBzxbJ7VQC7GwS+gD6QDAk+EbHBY7MM3CAQCGIJhBoEFcGVTCCEA+KfqXIyx8Zyz9QB/oCUAXPFlADzxZwAcsAUAT6AhT0AMlxcIAQyMsFUAXPFlAF+gITy2kTywDMyQH7AOEg+kQxIfAB+EFSEIMH9A5voXAlggi3GwC+ErALDAL8jjMwAfhCxwXysvQEMPhh+EH4QvhD+ET4RfhG+EcGyPQAUAXPFhPLH8sfywABzxYBzxbJ7VTgIIIQyOeZbbqOMzAB+ELHBfKy+kAw+Gf4QfhC+EP4RPhF+Eb4RwbI9ABQBc8WE8sfyx/LAAHPFgHPFsntVOAgghCcDzIguuMCExQAMAAAAABDaGVjayBzZW5kZXIgZmFpbGVkLgNc+CP4Q1IQvPhEErmwsAeCEDWk6QC+F7CSWxPjDYIImJaAcPsCIcIAkTHjDSLCAA0ODwH8NSKCCLcbAKkIUTOhAwX6APoA0x/THzBdupRQhqAijhhTNqAju5RSOQegmlI3oCKhGKBRURjiGBbiUgShIIIItxsAqQQgpvp6qQRwtgkgpwoSoVGBoFGooMhQBvoCUAT6AhTLHxjLH/hBQUCDB/RD+GGCEC+vCAD4R1RENFAGEACu+EKCCvrwgHFwyMknUWAQaBBYUUsEEDlBCYIQD4p+pcjLHxnLP1AH+gJQBc8WUAPPFnABywBQBPoCFPQAyXFwgBDIywVQBc8WUAX6AhPLaRPLAMzJAfsAAvaOyHCDBiGIJAYIVTCCEA+KfqXIyx8Zyz9QB/oCUAXPFlADzxZwAcsAUAT6AhT0AMlxcIAQyMsFUAXPFlAF+gITy2kTywDMyQH7AI6IbCFwMoMG2zzi+EH4QvhD+ET4RfhG+EcGyPQAUAXPFhPLH8sfywABzxYBzxbJ7VQREgBMcHLIyx/LP1ADzxbLH8sfyXGAGMjLBVADzxZQA/oCy2rMyYAQ+wAASAAAAABFeHRyYSBVU0RUIG9yIFRPTiBhcmUgc2VudCBiYWNrLgAocIAQyMsFUAPPFlAD+gLLaskB+wAAGDAB+ELHBfKy1NH7BAAyghBG6fHbupsB+ELHBfKy1NHtVOBbhA/y8ACHt0DdqJoegJ9IGmP6Y/pgH0gfSAYA3wwgnwxAXwx/DJ8MvwzfDP9Ihj8IMGD+gc30LgpAU4t/QAY/QAY6Y/pj5hImXFAAZ7YQPaiaHoCfSBpj+mP6YB9IH0gGAN8MIJ8MQF8MfwyfDL8M3wz/CD8IXwh/CJ8IvwjfCPB+DjN3";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchChangeCode.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.code.hash()).toEqual(STORM_PRELAUNCH_CHANGE_CODE_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_CHANGE_CODE_TX={} LT={} CODE_HASH={}", txHash, txLt, decoded.code.hash());
}

get fun `test storm prelaunch decodes toncenter set end time body`() {
    val txHash = "n9MYQVjO0NthEb2pIkBa+QZeudNYDJWcGlUnawDbuGo=";
    val txLt = "48574818000001";
    val bodyBoc = "te6cckEBAQEAEgAAIB3hZzEAAAAAAAAAAGbFrJDQCICI";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchSetEndTime.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.endTime).toEqual(1724230800);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_SET_END_TIME_TX={} LT={} END_TIME={}", txHash, txLt, decoded.endTime);
}

get fun `test storm prelaunch decodes toncenter notify rewards complete body`() {
    val txHash = "3wKQgwdFE8xdoH5Ym/UJaknr4XUmW7o+Bl4ZEQVZEIg=";
    val txLt = "48637115000001";
    val bodyBoc = "te6cckEBAQEADgAAGHB5wUUAAAAAAAAAAAspxXo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchNotifyRewardsComplete.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_NOTIFY_REWARDS_COMPLETE_TX={} LT={}", txHash, txLt);
}

get fun `test storm prelaunch decodes toncenter accepted jetton transfer body`() {
    val txHash = "j+moCL/7Ln7Cp20gXkhS3V2eX+qq+xlBUGzNF6H/MA0=";
    val txLt = "48558210000001";
    val bodyBoc = "te6cckEBAgEAWAABpg+KfqUAAAAAAAAAADtxsAgBH6HqP3JML73IfkWpl7cF+/xOUV7OF8ONwFJxkP1rlpcANNzk12g5XQmTvRWo4ZfJ5dx4sQe1x1shQpx9tJkndavBAQAAoCgTqA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchJettonTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(12000000);
    expect(decoded.destination).toEqual(address(STORM_PRELAUNCH_ADMIN_ADDRESS));
    expect(decoded.responseDestination).toEqual(address(STORM_PRELAUNCH_FIRST_USER));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    var forwardPayload = decoded.forwardPayload;
    expectRefEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_ACCEPTED_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test storm prelaunch decodes toncenter refund jetton transfer body`() {
    val txHash = "aHjtKsi2zPVwTYoh/Hhap51tmVj7nFwjk4UVwQzUiy4=";
    val txLt = "48604624000001";
    val bodyBoc = "te6cckEBAgEAfQABqA+KfqUAAAAAAAAAAEAhYOwIALZDo2PR4tPg1pR7NA3k4vjw8Wg8dzTzv8PrSjzu+qXpABbIdGx6PFp8GtKPZoG8nF8eHi0Hjuaed/h9aUed31S9AQEASAAAAABFeHRyYSBVU0RUIG9yIFRPTiBhcmUgc2VudCBiYWNrLiKALX8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchJettonTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(35000000);
    expect(decoded.destination).toEqual(address(STORM_PRELAUNCH_REFUND_USER));
    expect(decoded.responseDestination).toEqual(address(STORM_PRELAUNCH_REFUND_USER));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    var forwardPayload = decoded.forwardPayload;
    expectExtraRefundText(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PRELAUNCH_REFUND_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test storm prelaunch decodes toncenter reward counts notify body`() {
    val txHash = "j+moCL/7Ln7Cp20gXkhS3V2eX+qq+xlBUGzNF6H/MA0=";
    val txLt = "48558210000001";
    val bodyBoc = "te6cckEBAQEAOAAAawAAAAIAAAAAAAAAAIAabnJrtByuhMneitRwy+Ty7jxYg9rjrZChTj7aTJO61eAAAAAAAAAAMP8giLc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchRewardCountsNotify.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.participantAddress).toEqual(address(STORM_PRELAUNCH_FIRST_USER));
    expect(decoded.rewardCountBDelta).toEqual(0);
    expect(decoded.rewardCountADelta).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "STORM_PRELAUNCH_REWARD_COUNTS_NOTIFY_TX={} LT={} COUNT_B_DELTA={} COUNT_A_DELTA={}",
        txHash,
        txLt,
        decoded.rewardCountBDelta,
        decoded.rewardCountADelta,
    );
}

get fun `test storm prelaunch decodes toncenter rewards complete notify body`() {
    val txHash = "3wKQgwdFE8xdoH5Ym/UJaknr4XUmW7o+Bl4ZEQVZEIg=";
    val txLt = "48637115000001";
    val bodyBoc = "te6cckEBAQEAMAAAWwAAAAMAAAAAAAAAAIAR+h6j9yTC+9yH5FqZe3Bfv8TlFezhfDjcBScZD9a5aXDA71Y5";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormPrelaunchRewardsCompleteNotify.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    var payload = decoded.payload;
    expect(payload.remainingBitsCount()).toEqual(267);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadAddress()).toEqual(address(STORM_PRELAUNCH_ADMIN_ADDRESS));
    expectNoTail(mutate payload);

    println("STORM_PRELAUNCH_REWARDS_COMPLETE_NOTIFY_TX={} LT={}", txHash, txLt);
}
