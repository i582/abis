import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_loan.types"

const EXPECTED_QUERY_ID = 1780755345
const EXPECTED_STAKE_AT = 1780764424
const EXPECTED_MAX_FACTOR = 294912
const EXPECTED_VALIDATOR_PUBKEY = 0xa41414a54e2d0bc722e7a2254a94fc18fa65483d4875e8ae7a804bf76a8fba8d
const EXPECTED_ADNL_ADDR = 0x20791d63c50ed91d13e2b1f5d68589d5cc9a10b81ab775c3543bdfb9ac74f00c
const EXPECTED_SIGNATURE_HASH = 0x4cfd3580406373dfd5b502d847b26dc0787a557e5d35cb5e97adaaf6358c7dd5
const EXPECTED_PROXY_BODY_HASH = 0x907efc2473d6151cc2261cd998b0c194da0e9ead8078802f2c2397a2ea2e3db9
const EXPECTED_PROXY_PAYLOAD_HASH = 0x9e88fafaf053de30f1a4bff56614d6109c10ed56e9c0231973cff6279af8094d
const EXPECTED_NEW_STAKE_BODY_HASH = 0x2cf2cc086be529abe5b0bf621e6392ae5c2f528900d4a85cf92def9b97f83377
const EXPECTED_NEW_STAKE_OK_BODY_HASH = 0x91dad9e70932ca09bc25e29704d641252bc5e2ede40110baf504cda58e1c2f30

fun expectedValidatorPubkey(): bits256 {
    var bits = beginCell().storeUint(EXPECTED_VALIDATOR_PUBKEY, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectedAdnlAddr(): bits256 {
    var bits = beginCell().storeUint(EXPECTED_ADNL_ADDR, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectNewStakePayload(payload: HipoLoanNewStakeMsg): void {
    expect(payload.validatorPubkey).toEqual(expectedValidatorPubkey());
    expect(payload.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(payload.maxFactor).toEqual(EXPECTED_MAX_FACTOR);
    expect(payload.adnlAddr).toEqual(expectedAdnlAddr());
    expect(payload.signature.hash()).toEqual(EXPECTED_SIGNATURE_HASH);
}

get fun `test hipo loan decodes real incoming proxy_new_stake body`() {
    val txHash = "Qa1am0GUs/zsMgvoy6CEuAy+96kxZZnNNTJZXYcuEIQ=";
    val txLt = "81941546000001";
    val bodyBoc = "te6cckEBAwEAnAABGAic1NAAAAAAaiQrkQEBkKQUFKVOLQvHIueiJUqU/Bj6ZUg9SHXornqAS/dqj7qNaiRPCAAEgAAgeR1jxQ7ZHRPisfXWhYnVzJoQuBq3dcNUO9+5rHTwDAIAgAF5IFYQHLjTYt94Y+32Wv5uVJRLWOQ2Wo5T3k8KIzXh4+pckjbsgVfsy3tmlv9fRiM4uGV8gOIUt6eZUUpH5wNrfYZa";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoLoanProxyNewStake.fromCell(body);
    val payload = decoded.newStakeMsg.load();

    expect(body.hash()).toEqual(EXPECTED_PROXY_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.newStakeMsg.hash()).toEqual(EXPECTED_PROXY_PAYLOAD_HASH);
    expectNewStakePayload(payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("HIPO_LOAN_PROXY_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test hipo loan decodes real outgoing new_stake body`() {
    val txHash = "Qa1am0GUs/zsMgvoy6CEuAy+96kxZZnNNTJZXYcuEIQ=";
    val txLt = "81941546000001";
    val bodyBoc = "te6cckEBAgEAmQABqE5zdEsAAAAAaiQrkaQUFKVOLQvHIueiJUqU/Bj6ZUg9SHXornqAS/dqj7qNaiRPCAAEgAAgeR1jxQ7ZHRPisfXWhYnVzJoQuBq3dcNUO9+5rHTwDAEAgAF5IFYQHLjTYt94Y+32Wv5uVJRLWOQ2Wo5T3k8KIzXh4+pckjbsgVfsy3tmlv9fRiM4uGV8gOIUt6eZUUpH5wMvbzlx";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoLoanNewStake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_NEW_STAKE_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.validatorPubkey).toEqual(expectedValidatorPubkey());
    expect(decoded.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(decoded.maxFactor).toEqual(EXPECTED_MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(expectedAdnlAddr());
    expect(decoded.signature.hash()).toEqual(EXPECTED_SIGNATURE_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("HIPO_LOAN_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test hipo loan decodes real incoming new_stake_ok body`() {
    val txHash = "vUxanZKYMQngD9+zuigcRRoPSFdqRHqgCxryC2Lw/6A=";
    val txLt = "81941546000005";
    val bodyBoc = "te6cckEBAQEAEgAAIPN0SEwAAAAAaiQrkQAAAADg4yfT";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoLoanNewStakeOk.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_NEW_STAKE_OK_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.comment).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("HIPO_LOAN_NEW_STAKE_OK_TX={} LT={}", txHash, txLt);
}
