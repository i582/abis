import "@acton/fmt"
import "@acton/testing/expect"
import "../types/cocoon_worker.types"

get fun `test cocoon worker decodes real signed payout request`() {
    val body = parseCellFromBase64("te6cckEBAgEAqQAB26BArSiARHyzg3JUpoAHgFpfXFZMYJG0WAdV4YV9ZBHtBRhqj6lQ3DNTHjf1V0/PaOv72+zuP6eCvXRGD5Q2lBXL4d4y7W0afUTa9ZKHDFzbEAGRQ6yuTPGFREYWHMm5AN9D3mEmG0iVcr2/KyCwAQBroECtKIBEfLODclSmAAAABTh8kB6ABTefjVCqJpMjHB8zjLRAVk/X+CoTtTSJm5T3F4BDdTRwpmXJZw==");
    val message = CocoonWorkerPayoutRequestSigned.fromCell(body);
    val payload = CocoonWorkerPayoutPayload.fromCell(message.signedDataCell);

    expect(message.queryId).toEqual(9242649445717398694);
    expect(payload.queryId).toEqual(9242649445717398694);
    expect(payload.newTokens).toEqual(22422523934);
}

get fun `test cocoon worker decodes real signed final payout request`() {
    val body = parseCellFromBase64("te6cckEBAgEAqQAB2/XyajaK0yCIXgnNPIAHgFpfXFZMYJG0WAdV4YV9ZBHtBRhqj6lQ3DNTHjf1V1vAbW8lzvhI2P1VAoRrWOyWDAgacIhhjvr/0ssN+1tyH2oeOtAkH8BHhK4LZ0Grm3hHM+fDjvDjYI8xErYeAoGQAQBr9fJqNorTIIheCc08AAAABNtfi0uACnpicbTmApMHx3wiJ07eqkksXeQMVLMIfuYWX5M+dTTQc50W2Q==");
    val message = CocoonWorkerLastPayoutRequestSigned.fromCell(body);
    val payload = CocoonWorkerLastPayoutPayload.fromCell(message.signedDataCell);

    expect(message.queryId).toEqual(10003374967385345340);
    expect(payload.queryId).toEqual(10003374967385345340);
    expect(payload.newTokens).toEqual(20860341067);
}

get fun `test cocoon worker decodes real payout report to proxy`() {
    val body = parseCellFromBase64("te6cckEBAgEAawABa01yXSyARHyzg3JUpoAc8tkq5GyNpGq0Jc1r0sjfASqA2Nfgn+KREcug8HfsZsAAAAApw+SA9gEAXwjn0DZQJUEuvYQfX0/IgAeAWl9cVkxgkbRYB1XhhX1kEe0FGGqPqVDcM1MeN/VXUBcdImM=");
    val message = CocoonWorkerProxyRequest.fromCell(body);

    expect(message.payload).toBeNotNull();
    val payout = CocoonWorkerProxyPayoutRequest.fromCell(message.payload!);
    expect(message.queryId).toEqual(9242649445717398694);
    expect(message.state).toEqual(0);
    expect(message.tokens).toEqual(22422523934);
    expect(payout.workerPart).toEqual(10000460760);
    expect(payout.proxyPart).toEqual(526340040);
}

get fun `test cocoon worker decodes real excess acknowledgement body`() {
    val body = parseCellFromBase64("te6cckEBAQEADgAAGCVlk0yARHyzg3JUpoWeZdg=");
    val message = CocoonWorkerReturnExcesses.fromCell(body);

    expect(message.queryId).toEqual(9242649445717398694);
}
