import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_pool_v1.types"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadPayToParamsRef(mutate params: RemainingBitsAndRefs): StonfiPoolV1PayToParams {
    expect(params.remainingBitsCount()).toEqual(1);
    expect(params.remainingRefsCount()).toEqual(1);
    expect(params.loadBool()).toBeTrue();

    val paramsCell = params.loadRef();
    expectNoTail(mutate params);
    return StonfiPoolV1PayToParams.fromCell(paramsCell);
}

get fun `test stonfi pool v1 decodes real outgoing pay_to body`() {
    val txHash = "wW3FkGZHnv7kGT9fK3SSEZvOUmomu6u3tSv0E+JqUhI=";
    val txLt = "83006559000018";
    val bodyBoc = "te6cckEBAgEAfwABY/k7tD867C2UAsX50YAbp7c0kSzAj9iSLm9+Yk2g60o2wIIKKJThE76PG19hLxjIbhy4AQCPQMMNu7gAndkkNzqarUGyjOwC2pOE1nNjryA0/Cp8zAZ+KNQRDegQAEVC1GLJiatUYmfmIh/iCS3AGVFZFX3/igT8BJpmkBh+JW3j0w==";
    val expectedOwner = address("0:DD3DB9A48966047EC491737BF3126D075A51B604105144A7089DF478DAFB0978");
    val expectedToken0 = address("0:4EEC921B9D4D56A0D94676016D49C26B39B1D7901A7E153E66033F146A0886F4");
    val expectedToken1 = address("0:1150B518B2626AD51899F98887F8824B70065456455F7FE2813F012699A4061F");
    val body = parseCellFromBase64(bodyBoc);
    var raw = body.beginParse();
    val decoded = StonfiPoolV1PayTo.fromCell(body);
    var paramsTail = decoded.params;
    val params = loadPayToParamsRef(mutate paramsTail);

    expect(raw.loadUint(32)).toEqual(0xf93bb43f);
    expect(decoded.queryId).toEqual(4245818662428473809);
    expect(decoded.owner).toEqual(expectedOwner);
    expect(decoded.exitCode).toEqual(3326308581);
    expect(params.amount0Out).toEqual(204528571);
    expect(params.token0Address).toEqual(expectedToken0);
    expect(params.amount1Out).toEqual(0);
    expect(params.token1Address).toEqual(expectedToken1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_POOL_V1_PAY_TO_TX={} LT={}", txHash, txLt);
}
