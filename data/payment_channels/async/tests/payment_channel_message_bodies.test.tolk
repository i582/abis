import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/payment_channel.types"

const MAINNET_CHANNEL = "0:3836D93A0764AAF8B6C7A19FB5D45160AF8DE8DDD939852DF0E46DCE90ECC785"
const MAINNET_CHANNEL_ID = 92038272110415228469469388800325311629
const SOURCE_FIXTURE_CHANNEL_ID = 123

get fun `test payment channel decodes real top up body`() {
    val txHash = "e1qkelhV44z6FYDYa86swrw9Au14ZTl1IcnZAg3OSNs=";
    val txLt = "68092143000002";
    val body = parseCellFromBase64("te6cckEBAQEACwAAEmfH0oFAvrwgAFzBTBQ=");
    val decoded = AsyncPaymentChannelTopUpBalance.fromCell(body);

    expect(decoded.addA).toEqual(200000000);
    expect(decoded.addB).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("PAYMENT_CHANNEL={} TOP_UP_TX={} LT={}", MAINNET_CHANNEL, txHash, txLt);
}

get fun `test payment channel decodes real initialization body`() {
    val txHash = "WEDel1ZVh0B2cF86eCqBA/a4UMJ7JiAZDrP1XF/q66o=";
    val txLt = "68092149000002";
    val bodyBoc = "te6cckEBAQEAYAAAuw4GIMKCzxzoRLhM0aHVkblqtTA2IhW04GkA5+Di0ZwRPQOr4MSnH5/XiQYNxX0fqYz5jekIJuHgoLPNFG/o7Du7Km2BtLc0uiKe9pU3S8GFaWHtwBBR7kagX14QAEDeXW2q";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = AsyncPaymentChannelInit.fromCell(body);

    expect(decoded.isA).toBeTrue();
    expect(decoded.tag).toEqual(0x696e6974);
    expect(decoded.channelId).toEqual(MAINNET_CHANNEL_ID);
    expect(decoded.balanceA).toEqual(200000000);
    expect(decoded.balanceB).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("PAYMENT_CHANNEL={} INIT_TX={} LT={}", MAINNET_CHANNEL, txHash, txLt);
}

get fun `test payment channel decodes real cooperative close body`() {
    val txHash = "+CiHm3Ub0ei5hjEb3rm5dTsRNb8ev6PSoBMoNfc4VtM=";
    val txLt = "68092161000002";
    val bodyBoc = "te6cckEBAwEAtQACWlV3WH5DbG9zRT3tKm6XgwrSw9uAIKPcjUBfXhAAAAAAAAAAAGQAAAAAAAAAAAECAIA+hBhQBOIdG7i3B0o/FwJpLeF/heG1hDgh1jE6VjfE6e9BRH0t6f+SiXvmbNRo5Ixic9ojw73/1sR7W8rvtzAAAIDYv7NDC3j0KIlo17MgQ7s1BLCcd5112tzIPYCVgrj3kWAB86KcLHAuVlJAJJMBuF4Q5m0Ih3Md8WuiJVKDW7sJ0D1h2w==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = AsyncPaymentChannelCooperativeClose.fromCell(body);

    expect(decoded.signatureA.beginParse().remainingBitsCount()).toEqual(512);
    expect(decoded.signatureB.beginParse().remainingBitsCount()).toEqual(512);
    expect(decoded.tag).toEqual(0x436c6f73);
    expect(decoded.channelId).toEqual(MAINNET_CHANNEL_ID);
    expect(decoded.balanceA).toEqual(100000000);
    expect(decoded.balanceB).toEqual(0);
    expect(decoded.seqnoA).toEqual(100);
    expect(decoded.seqnoB).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("PAYMENT_CHANNEL={} COOPERATIVE_CLOSE_TX={} LT={}", MAINNET_CHANNEL, txHash, txLt);
}

get fun `test payment channel decodes source-derived cooperative commit body`() {
    val bodyBoc = "te6cckEBAgEAbgACUHmhJu9DQ210AAAAAAAAAAAAAAAAAAAAewAAAAAAAAABAAAAAAAAAAIBAQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMn91JE=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = AsyncPaymentChannelCooperativeCommit.fromCell(body);

    expect(body.hash()).toEqual(0xb586777ae330bac0248e407de38b33de5f1fc262d19c36c4fbd4986b60442de5);
    expect(decoded.signatureA.beginParse().remainingBitsCount()).toEqual(512);
    expect(decoded.signatureB.beginParse().remainingBitsCount()).toEqual(512);
    expect(decoded.tag).toEqual(0x43436d74);
    expect(decoded.channelId).toEqual(SOURCE_FIXTURE_CHANNEL_ID);
    expect(decoded.seqnoA).toEqual(1);
    expect(decoded.seqnoB).toEqual(2);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test payment channel decodes source-derived uncooperative start body`() {
    val bodyBoc = "te6cckECAwEAARsAArEfFRrPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACq3IbYAAAAAAAAAAAAAAAAAAAA9wAECALkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ2hTdAAAAAAAAAAAAAAAAAAAAHsAAAAAAAAAAQIAuQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABDaFN0AAAAAAAAAAAAAAAAAAAAewAAAAAAAAACAhRJhUc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = AsyncPaymentChannelStartUncooperativeClose.fromCell(body);
    val semiA = AsyncPaymentChannelSignedSemiChannel.fromCell(decoded.semiChannelA);
    val semiB = AsyncPaymentChannelSignedSemiChannel.fromCell(decoded.semiChannelB);

    expect(body.hash()).toEqual(0xae84566b9bab844ceef5a65a560518020abcc718b81164fff3f8f98c8f1fe42b);
    expect(decoded.signedByA).toBeTrue();
    expect(decoded.tag).toEqual(0x556e436c);
    expect(decoded.channelId).toEqual(SOURCE_FIXTURE_CHANNEL_ID);
    expect(semiA.state.channelId).toEqual(SOURCE_FIXTURE_CHANNEL_ID);
    expect(semiA.state.data.seqno).toEqual(1);
    expect(semiA.state.data.sent).toEqual(0);
    expect(semiA.state.counterpartyData).toBeNull();
    expect(semiB.state.channelId).toEqual(SOURCE_FIXTURE_CHANNEL_ID);
    expect(semiB.state.data.seqno).toEqual(2);
    expect(semiB.state.data.sent).toEqual(0);
    expect(semiB.state.counterpartyData).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test payment channel decodes source-derived quarantine challenge body`() {
    val bodyBoc = "te6cckECAwEAARsAArEIjqoyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACG0M6iAAAAAAAAAAAAAAAAAAAA9wAECALkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ2hTdAAAAAAAAAAAAAAAAAAAAHsAAAAAAAAAAQIAuQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABDaFN0AAAAAAAAAAAAAAAAAAAAewAAAAAAAAACAoK5d5E=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = AsyncPaymentChannelChallengeQuarantinedState.fromCell(body);
    val semiA = AsyncPaymentChannelSignedSemiChannel.fromCell(decoded.semiChannelA);
    val semiB = AsyncPaymentChannelSignedSemiChannel.fromCell(decoded.semiChannelB);

    expect(body.hash()).toEqual(0x653103951eeb6d5dc5745ed39faafe6396fadf523ca23695c986b79bd4519684);
    expect(decoded.challengedByA).toBeFalse();
    expect(decoded.tag).toEqual(0x43686751);
    expect(decoded.channelId).toEqual(SOURCE_FIXTURE_CHANNEL_ID);
    expect(semiA.state.data.seqno).toEqual(1);
    expect(semiB.state.data.seqno).toEqual(2);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test payment channel decodes source-derived settle conditionals body`() {
    val bodyBoc = "te6cckEBAQEAWwAAsWb28GmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIbYhtwAAAAAAAAAAAAAAAAAAAD2gt7O7AQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = AsyncPaymentChannelSettleConditionals.fromCell(body);

    expect(body.hash()).toEqual(0x7e248958d7b14afda3c2cb6bf242d834ed5e9864a9a62569a790f21f5ec25a87);
    expect(decoded.fromA).toBeTrue();
    expect(decoded.tag).toEqual(0x436c436e);
    expect(decoded.channelId).toEqual(SOURCE_FIXTURE_CHANNEL_ID);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test payment channel decodes real finish uncooperative close body`() {
    val txHash = "opW43babcZHx570Cwh0CUOyS1A+2SP4CnA+tzNW3ZI8=";
    val txLt = "57614243000002";
    val body = parseCellFromBase64("te6cckEBAQEABgAACCVDKpHJoL/2");
    val decoded = AsyncPaymentChannelFinishUncooperativeClose.fromCell(body);

    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("FINISH_UNCOOPERATIVE_CLOSE_TX={} LT={}", txHash, txLt);
}

get fun `test payment channel decodes real channel closed body`() {
    val txHash = "aKx3JVQF0hELG086YPj8cHmFU2pj+FQagVj7NVJDqKc=";
    val txLt = "56967655000002";
    val body = parseCellFromBase64("te6cckEBAQEAFgAAKN3ciLppRUwfOIypfw5zlVG3lBxom0mcsw==");
    val decoded = AsyncPaymentChannelClosed.fromCell(body);

    expect(decoded.channelId).toEqual(139928751977359195818869845348370881640);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("CHANNEL_CLOSED_TX={} LT={}", txHash, txLt);
}
