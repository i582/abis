import "@acton/fmt"
import "@acton/testing/expect"
import "../types/frt_gram_executor.types"

// Message bodies from mainnet trace 342e6948e4bdf520e18cf54991545b4d58d88872ed58f5128198c52e90199b37,
// pinned to blocks 83536149-83536151.

const ROUTE_DESTINATION = "EQCcSVxmNtWGfJ3lcNXU93YgDIHuAMcTlJBMBbx-NTjFq3rp"
const COORDINATOR = "EQAOYIpqiuS0blDySfqSPKHhYoJRRV8RxUHGQUw_hw8WUQth"

get fun `test frt gram executor decodes real execution request`() {
    val bodyBoc = "te6cckEBAgEAXAABCJofEAkBAKZQFipcuASVAvkAwADmCKaorktG5Q8kn6kjyh4WKCUUVfEcVBxkFMP4cPFlGAE4krjMbasM+TvK4aup7uxAGQPcAY4nKSCYC3j8anGLVgAGAAACtZdTSnQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramExecutorExecute.fromCell(body);
    var raw = body.beginParse();
    raw.loadUint(32);
    val payloadCell = raw.loadRef();

    expect(decoded.payload.hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram executor decodes real pool request`() {
    val bodyBoc = "te6cckEBAQEADgAAGCbfOfwAAAAAAAAAACESwmY=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramExecutorPoolDataRequest.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram executor decodes real pool response`() {
    val bodyBoc = "te6cckEBAgEAuwABtybfOfwAAAAAAAAAADAqYD6as1Mj1mUDXr7ADCJdwhkzN/h9/IARaZnqbFaK8P43aaA22+x+AmDv42vIAWakWfaYqXdPYOTC9vzm8pIc2Q18w6aBE2l8OCUUUTRdAQCzABQACoAWOg4ZP4eJeIaSGT9glQ5HiNnXM+UF7szwfqLXdbGvJzADWPLSi+AddDBo7zpifWI+H5DXm8sDw9sr0NWI0OK7+b2EA0EULP1UXMuPqs2Al3z5PBxg4bQlLQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramExecutorPoolDataResponse.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.payload.remainingBitsCount()).toEqual(639);
    expect(decoded.payload.remainingRefsCount()).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram executor decodes real jetton transfer`() {
    val bodyBoc = "te6cckEBAQEAWgAAsA+KfqUAAAAAAAAAAEGF/2qoATiSuMxtqwz5O8rhq6nu7EAZA9wBjicpIJgLePxqcYtXACcSVxmNtWGfJ3lcNXU93YgDIHuAMcTlJBMBbx+NTjFqyAJiWgBykYaL";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramExecutorJettonTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(408942250);
    expect(decoded.destination).toEqual(address(ROUTE_DESTINATION));
    expect(decoded.responseDestination).toEqual(address(ROUTE_DESTINATION));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(20000000);
    expect(decoded.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(decoded.forwardPayload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram executor decodes real dispatcher result`() {
    val bodyBoc = "te6cckEBAQEAMQAAXZofDQhJUC+QCAAcwRTVFclo3KHkk/UkeUPCxQSiir4jioOMgph/Dh4so0GF/2qoqIDPLw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramExecutorDispatcherResult.fromCell(body);

    expect(decoded.amount).toEqual(2500000000);
    expect(decoded.responseDestination).toEqual(address(COORDINATOR));
    expect(decoded.success).toBeTrue();
    expect(decoded.secondaryAmount).toEqual(408942250);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram executor preserves real execution event tail`() {
    val bodyBoc = "te6cckEBAQEAWgAAr0GF/2qlAWKly4BJUC+QAAAwAAAVqAAcwRTVFclo3KHkk/UkeUPCxQSiir4jioOMgph/Dh4sowAnElcZjbVhnyd5XDV1Pd2IAyB7gDHE5SQTAW8fjU4xavAYeUeF";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramExecutorExecutionEvent.fromCell(body);

    expect(decoded.payload.remainingBitsCount()).toEqual(667);
    expect(decoded.payload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
