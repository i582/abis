import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/cocoon_root.types"

get fun `test decodes real cocoon root add worker hash`() {
    val txHash = "ivRJNF7QwUpIK1Sy3+kspHT3KnCIGEby05/iD0DvL4Y=";
    val body = parseCellFromBase64("te6cckEBAQEALgAAWONLHGAAAAAAAAAAAEUV/EXxdXCx6bxDNC/Np5NgGbdmYVmLiMtYbOHgJR/SNKDOFg==");
    val message = CocoonRootAddWorkerType.fromCell(body);

    expect(message.queryId).toEqual(0);
    expect(
        message.workerHash,
    ).toEqual(0x4515fc45f17570b1e9bc43342fcda7936019b76661598b88cb586ce1e0251fd2);
    expect(message.toCell().hash()).toEqual(body.hash());
    println("COCOON_ROOT_ADD_WORKER_TX={}", txHash);
}

get fun `test decodes real cocoon root add proxy hash`() {
    val txHash = "OsdcwZ/n4A+ZEuZEPCeKDXIADnjoF4SGokIHzJcFpqo=";
    val body = parseCellFromBase64("te6cckEBAQEALgAAWHGGDoAAAAAAAAAAACvdghTkUUHSB6rY1z0iuR1rybWAmugjHk6ZqUSl3TZ2huRtXg==");
    val message = CocoonRootAddProxyType.fromCell(body);

    expect(message.queryId).toEqual(0);
    expect(
        message.proxyHash,
    ).toEqual(0x2bdd8214e45141d207aad8d73d22b91d6bc9b5809ae8231e4e99a944a5dd3676);
    expect(message.toCell().hash()).toEqual(body.hash());
    println("COCOON_ROOT_ADD_PROXY_TX={}", txHash);
}

get fun `test decodes real cocoon root parameter change`() {
    val txHash = "zUNEGYObO8SJTkRBSfojCRrPLuBfgne2+gdurYB35Sg=";
    val body = parseCellFromBase64("te6cckEBAQEAIgAAQAIvoYkAAAAAAAAAABCBBwABUYAAAKjAQ7msoAQ7msoAvUldjw==");
    val message = CocoonRootChangeParams.fromCell(body);

    expect(message.queryId).toEqual(0);
    expect(message.pricePerToken).toEqual(8);
    expect(message.workerFeePerToken).toEqual(7);
    expect(message.proxyDelayBeforeClose).toEqual(86400);
    expect(message.clientDelayBeforeClose).toEqual(43200);
    expect(message.minProxyStake).toEqual(1000000000);
    expect(message.minClientStake).toEqual(1000000000);
    expect(message.toCell().hash()).toEqual(body.hash());
    println("COCOON_ROOT_CHANGE_PARAMS_TX={}", txHash);
}

get fun `test decodes real cocoon root excess acknowledgement`() {
    val txHash = "ivRJNF7QwUpIK1Sy3+kspHT3KnCIGEby05/iD0DvL4Y=";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGCVlk0wAAAAAAAAAAA05+zs=");
    val message = CocoonRootReturnExcesses.fromCell(body);

    expect(message.queryId).toEqual(0);
    expect(message.toCell().hash()).toEqual(body.hash());
    println("COCOON_ROOT_EXCESSES_TX={}", txHash);
}
