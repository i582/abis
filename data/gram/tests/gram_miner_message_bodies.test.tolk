import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/gram_miner.types"

const PROOF_BODY_HASH = 0x6ca5fdccaa58576199e6a68ccd16b4f29f4cc97391660d1b0a3cad04eb754802
const PROOF_FIELDS_HASH = 0x0001e15ae2b9ad1f84f499514234c1b589de8d61a1f2f3cc185b78a50bb940be

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

get fun `test gram miner decodes a real proof attempt prefix`() {
    val messageHash = "6k8KnMzROk6bFf2DGKas6UcJodkkmgXb9vUxV+3CKbA=";
    val source = "0:B8106735171F480F968E5480A98027D52783C88DD14190573A69499BD33E8E78";
    val destination = "0:006E8AFE090EE5BAD323428D17507E1FE480A99CDADFA6A9B78D229842B80633";
    val bodyBoc = "te6cckEBAgEAoAAB8k1pbmUAajY0ZrgQZzUXH0gPlo5UgKmAJ9Ung8iN0UGQVzppSZvTPo54AAAAAAAAAAAAAAAAAAAAAMsRgoJPY/dPpYAPVbG602rli3YX3QS/r6RTl77O6Bj7AAAAAAAAAAAAAAAAAAAAAMsRgoJPY/dPpYAPVbG602oBAEOAFwIM5qLj6QHy0cqQFTAE+qTweRG6KDIK500pM3pn0c8Qpb0mBw==";
    val body = parseCellFromBase64(bodyBoc);
    val proof = (body as Cell<GramSubmitProofOfWork>).load({
        assertEndAfterReading: false,
    });
    val repeatedData = bits256FromUint(
        0x00000000000000000000000000000000cb1182824f63f74fa5800f55b1bad36a,
    );

    expect(body.hash()).toEqual(PROOF_BODY_HASH);
    expect(body.beginParse().remainingBitsCount()).toEqual(968);
    expect(body.beginParse().remainingRefsCount()).toEqual(1);
    expect(proof.flags).toEqual(0);
    expect(proof.expire).toEqual(1781937254);
    expect(proof.whom).toEqual(
        bits256FromUint(0xb8106735171f480f968e5480a98027d52783c88dd14190573a69499bd33e8e78),
    );
    expect(proof.rdata1).toEqual(repeatedData);
    expect(proof.rseed).toEqual(305117335513064972746342480618463959291);
    expect(proof.rdata2).toEqual(repeatedData);
    // Toncenter's observed attempt has one unconsumed reference. The typed
    // 968-bit proof prefix is exact; the deployed miner's end-parse check would
    // reject this particular attempt because of that reference.
    expect(proof.toCell().hash()).toEqual(PROOF_FIELDS_HASH);

    println(
        "GRAM_PROOF_MESSAGE={} SOURCE={} DESTINATION={}",
        messageHash,
        source,
        destination,
    );
}
