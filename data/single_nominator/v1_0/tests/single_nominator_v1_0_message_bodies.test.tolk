import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/single_nominator_v1_0.types"

const EXPECTED_NEW_STAKE_QUERY_ID = 1780797293
const EXPECTED_RECOVER_STAKE_QUERY_ID = 1780797288
const EXPECTED_STAKE_AMOUNT = 983037000000000
const EXPECTED_STAKE_AT = 1780829960
const EXPECTED_MAX_FACTOR = 294912
const EXPECTED_VALIDATOR_PUBKEY = 0x20c027cc6e8a464614d54ce489f692a4c232b67636ab0b19628806284182fb31
const EXPECTED_ADNL_ADDR = 0x45791ef3e6e0b403b4cd3cb9313a71ed55bf9408d0d32ddd60e794274c2e3f32
const EXPECTED_SIGNATURE_HASH = 0xd7d97a6d3b1a8d3aa0a7993510f81ef334fe686e9e70ef8b6f44d9218c5e2bed
const EXPECTED_IN_NEW_STAKE_BODY_HASH = 0x82c6af5a033e7d102fab19638a437a1f96ce56f75414e94239e5e3a8bd3e4b5c
const EXPECTED_OUT_NEW_STAKE_BODY_HASH = 0xe971b31ddf07445fa615f60bd0c69a4df7104166e9494962dacf7373ebe23d22
const EXPECTED_RECOVER_STAKE_BODY_HASH = 0x38cd40921c33e8f1cb8cfcb49d271b9bb6def9eea385b7e0f90e311231058ac5
const EXPECTED_NEW_STAKE_CONFIRMATION_BODY_HASH = 0x9ccf2a6ba83734dfb60e3d5ead689739371d15e2fa9f506234910e786eb7a522

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectElectorStakePayload(decoded: SingleNominatorV10ElectorNewStake): void {
    expect(decoded.queryId).toEqual(EXPECTED_NEW_STAKE_QUERY_ID);
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(EXPECTED_VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(decoded.maxFactor).toEqual(EXPECTED_MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(EXPECTED_ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(EXPECTED_SIGNATURE_HASH);
}

get fun `test single nominator v1_0 decodes real incoming validator new_stake body`() {
    val txHash = "9t8SxmOofCNfLJzAISBSEkDqRJcdLvX4zsBgnunDcQc=";
    val txLt = "82045640000003";
    val bodyBoc = "te6cckEBAgEAoQABt05zdEsAAAAAaiTPbXA34RIy+iACDAJ8xuikZGFNVM5In2kqTCMrZ2NqsLGWKIBihBgvsxaiVPCAAEgABFeR7z5uC0A7TNPLkxOnHtVb+UCNDTLd1g55QnTC4/MoAQCAoUSOZnALFS0F3v2zf8xsqWdnS3LZo01DeBxE5FKH5o5hTHggKDCGloygDuBldi7U+j7PfGfhtDVYvoWkxUCnBhSxhQ8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SingleNominatorV10NewStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_IN_NEW_STAKE_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_NEW_STAKE_QUERY_ID);
    expect(decoded.stake).toEqual(EXPECTED_STAKE_AMOUNT);
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(EXPECTED_VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(decoded.maxFactor).toEqual(EXPECTED_MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(EXPECTED_ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(EXPECTED_SIGNATURE_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V10_IN_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test single nominator v1_0 decodes real outgoing elector new_stake body`() {
    val txHash = "9t8SxmOofCNfLJzAISBSEkDqRJcdLvX4zsBgnunDcQc=";
    val txLt = "82045640000003";
    val bodyBoc = "te6cckEBAgEAmQABqE5zdEsAAAAAaiTPbSDAJ8xuikZGFNVM5In2kqTCMrZ2NqsLGWKIBihBgvsxaiVPCAAEgABFeR7z5uC0A7TNPLkxOnHtVb+UCNDTLd1g55QnTC4/MgEAgKFEjmZwCxUtBd79s3/MbKlnZ0ty2aNNQ3gcRORSh+aOYUx4ICgwhpaMoA7gZXYu1Po+z3xn4bQ1WL6FpMVApwZvi/iA";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SingleNominatorV10ElectorNewStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_OUT_NEW_STAKE_BODY_HASH);
    expectElectorStakePayload(decoded);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V10_OUT_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test single nominator v1_0 decodes real recover_stake request bodies`() {
    val txHash = "ZXjePrxFVcCZ4AHBuOjBiT4WwHH5mJ0niFqhKVJ405U=";
    val txLt = "82045629000003";
    val bodyBoc = "te6cckEBAQEADgAAGEdldCQAAAAAaiTPaO2PLuw=";
    val body = parseCellFromBase64(bodyBoc);
    val incoming = SingleNominatorV10RecoverStake.fromCell(body);
    val outgoing = SingleNominatorV10ElectorRecoverStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_RECOVER_STAKE_BODY_HASH);
    expect(incoming.queryId).toEqual(EXPECTED_RECOVER_STAKE_QUERY_ID);
    expect(outgoing.queryId).toEqual(EXPECTED_RECOVER_STAKE_QUERY_ID);
    expect(incoming.toCell().hash()).toEqual(body.hash());
    expect(outgoing.toCell().hash()).toEqual(body.hash());

    println("SINGLE_NOMINATOR_V10_RECOVER_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test single nominator v1_0 decodes real elector response bodies`() {
    val newStakeTxHash = "G/mEXHogCF48sJNuFgWzpwYlZCDuM1fRV//mvDc3/sI=";
    val newStakeTxLt = "82045640000007";
    val newStakeOkBoc = "te6cckEBAQEAEgAAIPN0SEwAAAAAaiTPbQAAAABw8HEe";
    val recoverTxHash = "Zvcs3kiBsaLHRIG1gqzBQ3ehsu0ANFYP3kQfxdjgAnE=";
    val recoverTxLt = "82045629000007";
    val recoverBoc = "te6cckEBAQEADgAAGPlvcyQAAAAAaiTPaLd7Fts=";
    val newStakeOk = SingleNominatorV10NewStakeConfirmation.fromCell(
        parseCellFromBase64(newStakeOkBoc),
    );
    val recover = SingleNominatorV10RecoverStakeResponse.fromCell(parseCellFromBase64(recoverBoc));

    expect(parseCellFromBase64(newStakeOkBoc).hash()).toEqual(
        EXPECTED_NEW_STAKE_CONFIRMATION_BODY_HASH,
    );
    expect(newStakeOk.queryId).toEqual(EXPECTED_NEW_STAKE_QUERY_ID);
    expect(newStakeOk.comment).toEqual(0);
    expect(newStakeOk.toCell().hash()).toEqual(parseCellFromBase64(newStakeOkBoc).hash());

    expect(recover.queryId).toEqual(EXPECTED_RECOVER_STAKE_QUERY_ID);
    expect(recover.toCell().hash()).toEqual(parseCellFromBase64(recoverBoc).hash());

    println("SINGLE_NOMINATOR_V10_NEW_STAKE_OK_TX={} LT={}", newStakeTxHash, newStakeTxLt);
    println("SINGLE_NOMINATOR_V10_RECOVER_STAKE_RESPONSE_TX={} LT={}", recoverTxHash, recoverTxLt);
}
