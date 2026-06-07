import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/single_nominator_v1_1.types"

const EXPECTED_NEW_STAKE_QUERY_ID = 1780797200
const EXPECTED_RECOVER_STAKE_QUERY_ID = 1780797194
const EXPECTED_STAKE_AMOUNT = 2476204000000000
const EXPECTED_STAKE_AT = 1780829960
const EXPECTED_MAX_FACTOR = 294912
const EXPECTED_VALIDATOR_PUBKEY = 0x0f633aea2d39410bea2c3f59bf6b07e9c796072a9f776c18139ee132f91daf73
const EXPECTED_ADNL_ADDR = 0xd21793467939beca344121269456610a46d5061ba351e7a2576367ff75873821
const EXPECTED_SIGNATURE_HASH = 0x75a90824b4c6500152340fe69ce8f82a206cbb29993794bf6407033a28ea6fcc
const EXPECTED_IN_NEW_STAKE_BODY_HASH = 0x8e8861c2e4bb83765aa79628ef8936c566e2f0dd3be40b360c763111cdded263
const EXPECTED_OUT_NEW_STAKE_BODY_HASH = 0xeee0827515edbfc722dd845d81d40b27d8c2957e96e9f64c94768746cb354639
const EXPECTED_RECOVER_STAKE_BODY_HASH = 0x0a90b3dad65db08ceadbaafad69572735edfbed6ed6295d7232b729fc7c30036
const EXPECTED_NEW_STAKE_CONFIRMATION_BODY_HASH = 0x75303ba5a8d5e2a6fb9a40cc5ef687055a9f995f38f1e17ceeef33fbd7d13859
const EXPECTED_TEXT_WITHDRAW_BODY_HASH = 0xc3736fc1c941bf240f8c95a613f7395550cc0814ef7ac7a7eaa0141f13426eea

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectElectorStakePayload(decoded: SingleNominatorV11ElectorNewStake): void {
    expect(decoded.queryId).toEqual(EXPECTED_NEW_STAKE_QUERY_ID);
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(EXPECTED_VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(decoded.maxFactor).toEqual(EXPECTED_MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(EXPECTED_ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(EXPECTED_SIGNATURE_HASH);
}

get fun `test single nominator v1_1 decodes real incoming validator new_stake body`() {
    val txHash = "01GnsxvMFJIladALWfce+bw7K6cOSQNT4ui22FfjUk0=";
    val txLt = "82045416000003";
    val bodyBoc = "te6cckEBAgEAoQABt05zdEsAAAAAaiTPEHCMwYK8+4AA9jOuotOUEL6iw/Wb9rB+nHlgcqn3dsGBOe4TL5Ha9zaiVPCAAEgADSF5NGeTm+yjRBISaUVmEKRtUGG6NR56JXY2f/dYc4IYAQCAaVZ+3lnIzOCWhPNlvtlKCsCH6PyCLcjo+6rR9RZwovJkNrmP/8PDpMKThsV/jyVl54pYAeZJfSLTyZldjOmMC0RRwxg=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SingleNominatorV11NewStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_IN_NEW_STAKE_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_NEW_STAKE_QUERY_ID);
    expect(decoded.stake).toEqual(EXPECTED_STAKE_AMOUNT);
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(EXPECTED_VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(decoded.maxFactor).toEqual(EXPECTED_MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(EXPECTED_ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(EXPECTED_SIGNATURE_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V11_IN_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test single nominator v1_1 decodes real outgoing elector new_stake body`() {
    val txHash = "01GnsxvMFJIladALWfce+bw7K6cOSQNT4ui22FfjUk0=";
    val txLt = "82045416000003";
    val bodyBoc = "te6cckEBAgEAmQABqE5zdEsAAAAAaiTPEA9jOuotOUEL6iw/Wb9rB+nHlgcqn3dsGBOe4TL5Ha9zaiVPCAAEgADSF5NGeTm+yjRBISaUVmEKRtUGG6NR56JXY2f/dYc4IQEAgGlWft5ZyMzgloTzZb7ZSgrAh+j8gi3I6Puq0fUWcKLyZDa5j//Dw6TCk4bFf48lZeeKWAHmSX0i08mZXYzpjAuJvuh/";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SingleNominatorV11ElectorNewStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_OUT_NEW_STAKE_BODY_HASH);
    expectElectorStakePayload(decoded);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V11_OUT_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test single nominator v1_1 decodes real recover_stake request bodies`() {
    val txHash = "i80NHtZVLR+4+wu7fmaR1bKlXNkQYeIUbG8NGhX603w=";
    val txLt = "82045402000003";
    val bodyBoc = "te6cckEBAQEADgAAGEdldCQAAAAAaiTPCnhs02w=";
    val body = parseCellFromBase64(bodyBoc);
    val incoming = SingleNominatorV11RecoverStake.fromCell(body);
    val outgoing = SingleNominatorV11ElectorRecoverStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_RECOVER_STAKE_BODY_HASH);
    expect(incoming.queryId).toEqual(EXPECTED_RECOVER_STAKE_QUERY_ID);
    expect(outgoing.queryId).toEqual(EXPECTED_RECOVER_STAKE_QUERY_ID);
    expect(incoming.toCell().hash()).toEqual(body.hash());
    expect(outgoing.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V11_RECOVER_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test single nominator v1_1 decodes real elector response bodies`() {
    val newStakeTxHash = "gt6ln8IEiqbiw0jPBgHEpX0xhPPPcRca7HWB6/BvGtk=";
    val newStakeTxLt = "82045416000007";
    val newStakeOkBoc = "te6cckEBAQEAEgAAIPN0SEwAAAAAaiTPEAAAAADXlJmg";
    val recoverTxHash = "r5w1uO/VHwVkx1Ymin/Oj4VSZai/igzkv2PF/2U2Ius=";
    val recoverTxLt = "82045402000007";
    val recoverBoc = "te6cckEBAQEADgAAGPlvcyQAAAAAaiTPCiKY61s=";
    val newStakeOk = SingleNominatorV11NewStakeConfirmation.fromCell(
        parseCellFromBase64(newStakeOkBoc),
    );
    val recover = SingleNominatorV11RecoverStakeResponse.fromCell(parseCellFromBase64(recoverBoc));

    expect(parseCellFromBase64(newStakeOkBoc).hash()).toEqual(
        EXPECTED_NEW_STAKE_CONFIRMATION_BODY_HASH,
    );
    expect(newStakeOk.queryId).toEqual(EXPECTED_NEW_STAKE_QUERY_ID);
    expect(newStakeOk.comment).toEqual(0);
    expect(newStakeOk.toCell().hash()).toEqual(parseCellFromBase64(newStakeOkBoc).hash());

    expect(recover.queryId).toEqual(EXPECTED_RECOVER_STAKE_QUERY_ID);
    expect(recover.toCell().hash()).toEqual(parseCellFromBase64(recoverBoc).hash());

    println("SINGLE_NOMINATOR_V11_NEW_STAKE_OK_TX={} LT={}", newStakeTxHash, newStakeTxLt);
    println("SINGLE_NOMINATOR_V11_RECOVER_STAKE_RESPONSE_TX={} LT={}", recoverTxHash, recoverTxLt);
}

get fun `test single nominator v1_1 decodes real text withdraw body`() {
    val txHash = "MaydFSjPVIxZwsV1tWAWLu5WcV0qARP9Uxm+nJ2rT5U=";
    val txLt = "74135282000001";
    val bodyBoc = "te6cckEBAQEABwAACgAAAAB30uHyKA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SingleNominatorV11TextWithdraw.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_TEXT_WITHDRAW_BODY_HASH);
    expect(decoded.action).toEqual(0x77);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V11_TEXT_WITHDRAW_TX={} LT={}", txHash, txLt);
}
