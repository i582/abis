import "@acton/fmt"
import "@acton/testing/expect"
import "../types/cocoon_proxy.types"

get fun `test cocoon proxy decodes real no-op heartbeat`() {
    val body = parseCellFromBase64("te6cckEBAQEANgAAaJoSR8AK5ZoNlVspZ1MQnA8APYw18sncYCzUZ+4reGRJ9CykNQX2t34IS7jd2g1XNBD/rhqaM2VB");
    val message = CocoonProxyDoNotProcess.fromCell(body);

    expect(message.payload.remainingBitsCount()).toEqual(384);
    expect(message.payload.remainingRefsCount()).toEqual(0);
}

get fun `test cocoon proxy decodes real client request`() {
    val body = parseCellFromBase64("te6cckEBAgEAZwABW2VEj/Ta9LET0cfSVoAKSkWIXwLLlw41+jYYlCP/PJkQDhoCoKnrCwdC6TdUkYgBAGcUGDY0T2FA34R1gAAAAAAC+3uAuOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVgFVHFoQ==");
    val message = CocoonProxyClientRequest.fromCell(body);
    val state = message.stateData.load();

    expect(message.queryId).toEqual(15777430093267718742);
    expect(state.state).toEqual(0);
    expect(state.balance).toEqual(25997153240);
    expect(state.stake).toEqual(15000000000);
    expect(state.tokensUsed).toEqual(200142338);
    expect(
        state.secretHash,
    ).toEqual(102987336249554097029535212322581322789799900648198034993379397001115665086549);
    expect(message.payload).toBeNull();
}

get fun `test cocoon proxy decodes real worker payout request`() {
    val body = parseCellFromBase64("te6cckEBAgEAawABa01yXSyARHyzg3JUpoAc8tkq5GyNpGq0Jc1r0sjfASqA2Nfgn+KREcug8HfsZsAAAAApw+SA9gEAXwjn0DZQJUEuvYQfX0/IgAeAWl9cVkxgkbRYB1XhhX1kEe0FGGqPqVDcM1MeN/VXUBcdImM=");
    val message = CocoonProxyWorkerRequest.fromCell(body);

    expect(message.queryId).toEqual(9242649445717398694);
    expect(message.state).toEqual(0);
    expect(message.tokens).toEqual(22422523934);
    expect(message.payload).toBeNotNull();
    val payout = CocoonProxyWorkerPayoutRequest.fromCell(message.payload!);
    expect(payout.workerPart).toEqual(10000460760);
    expect(payout.proxyPart).toEqual(526340040);
}

get fun `test cocoon proxy decodes real owner payout request`() {
    val body = parseCellFromBase64("te6cckEBAQEAMAAAW3YQ5usGoczFII6Ox4AHgFpfXFZMYJG0WAdV4YV9ZBHtBRhqj6lQ3DNTHjf1V1DvNcNi");
    val message = CocoonProxyPayoutRequest.fromCell(body);

    expect(message.queryId).toEqual(477888182504820423);
}

get fun `test cocoon proxy decodes real excess acknowledgement`() {
    val body = parseCellFromBase64("te6cckEBAQEADgAAGCVlk0yARHyzg3JUpoWeZdg=");
    val message = CocoonProxyReturnExcesses.fromCell(body);

    expect(message.queryId).toEqual(9242649445717398694);
}

get fun `test cocoon proxy decodes real payout`() {
    val body = parseCellFromBase64("te6cckEBAQEADgAAGMWafNOARHyzg3JUpvo/hLs=");
    val message = CocoonProxyPayout.fromCell(body);

    expect(message.queryId).toEqual(9242649445717398694);
}
