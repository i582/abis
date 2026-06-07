import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/whales_proxy.types"

const MESSAGE_FIXTURE_JSON = "data/whales/research/toncenter_proxy_message_bodies.json"

const QUERY_ID = 1780804460099
const STAKE_AT = 1780829960
const MAX_FACTOR = 196608
const VALIDATOR_PUBKEY = 0x9b20fd9f5da69b580a90f253b9e345850acfcdaba40d0b5dd20fe8880e7db622
const ADNL_ADDR = 0xd1dac99d5fe0880e223f77bda1f4ea4a0beaa315d3aa686e5de234fc0bc1fec2
const SIGNATURE_HASH = 0x26c3a88d77c313f920b624e026525c7dcda74b011ac9b1a93716265105a841fd

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectNewStakePayload(decoded: WhalesProxyElectorNewStake): void {
    expect(decoded.queryId).toEqual(QUERY_ID);
    expect(decoded.validatorPubkey).toEqual(bits256FromUint(VALIDATOR_PUBKEY));
    expect(decoded.stakeAt).toEqual(STAKE_AT);
    expect(decoded.maxFactor).toEqual(MAX_FACTOR);
    expect(decoded.adnlAddr).toEqual(bits256FromUint(ADNL_ADDR));
    expect(decoded.signature.hash()).toEqual(SIGNATURE_HASH);
}

get fun `test whales proxy decodes real forwarded elector new stake body`() {
    val txHash = "yb43a3FZdtxCj3vJ93mTJsMuIhv0em+OeernsbpGIFg=";
    val txLt = "82063491000003";
    val body = parseCellFromBase64("te6cckEBAgEAmQABqE5zdEsAAAGeoDeeQ5sg/Z9dpptYCpDyU7njRYUKz82rpA0LXdIP6IgOfbYiaiVPCAADAADR2smdX+CIDiI/d72h9OpKC+qjFdOqaG5d4jT8C8H+wgEAgObDibnpWYP6iLDNqs07Ey7hLoajETKnV4Cm1szDOKh43SZtpsuv4XfwRVVSs6Hr2ixjbmEVAuYKlgyIUktlPwBZGjbr");
    val decoded = WhalesProxyElectorNewStake.fromCell(body);

    expectNewStakePayload(decoded);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("WHALES_PROXY_NEW_STAKE_FIXTURE={} TX={} LT={}", MESSAGE_FIXTURE_JSON, txHash, txLt);
}

get fun `test whales proxy decodes real forwarded elector recover request body`() {
    val txHash = "JQtsG535jm5f2SqMFBBRzKLee35LDJfVI4/ad0G060s=";
    val txLt = "82046210000003";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGEdldCQAAAAAAAAAAEUmpq4=");
    val decoded = WhalesProxyElectorRecoverStakeRequest.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "WHALES_PROXY_RECOVER_REQUEST_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test whales proxy decodes real forwarded elector new stake confirmation body`() {
    val txHash = "VEVbqwaTlMBqFujyFQZcoJqZt9KfnzvBP0NOtaH7sqI=";
    val txLt = "82063493000001";
    val body = parseCellFromBase64("te6cckEBAQEAEgAAIPN0SEwAAAGeoDeeQwAAAAD6BOU4");
    val decoded = WhalesProxyElectorNewStakeConfirmation.fromCell(body);

    expect(decoded.queryId).toEqual(QUERY_ID);
    expect(decoded.comment).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "WHALES_PROXY_NEW_STAKE_CONFIRMATION_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test whales proxy decodes real forwarded elector recover response body`() {
    val txHash = "z2gOu7Zrpf9rUhM3779bJcZtiE93NYO0mW19IiHcjcI=";
    val txLt = "82046214000001";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGPlvcyQAAAAAAAAAAB/Snpk=");
    val decoded = WhalesProxyElectorRecoverStakeResponse.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "WHALES_PROXY_RECOVER_RESPONSE_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}
