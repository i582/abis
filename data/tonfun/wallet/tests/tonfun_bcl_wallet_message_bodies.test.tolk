import "@acton/fmt"
import "@acton/testing/expect"
import "../types/tonfun_bcl_wallet_common.types"

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test decodes observed tonfun v1 deployment transfer and excess`() {
    val incomingBodyBoc = "te6cckEBAQEAOAAAaxeNRRkAAAAAAAAAAHAhbJr/THxCAHf6cuc6pLZAptDSyieHMeFmx11bJwNVCmh6lPJ4XOJOgm3AUdM=";
    val outgoingBodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val incomingBody = parseCellFromBase64(incomingBodyBoc);
    val outgoingBody = parseCellFromBase64(outgoingBodyBoc);
    val incoming = TonFunBclWalletInternalTransfer.fromCell(incomingBody);
    val outgoing = TonFunBclWalletExcesses.fromCell(outgoingBody);
    var forwardPayload = incoming.forwardPayload;

    expect(incoming.queryId).toEqual(0);
    expect(incoming.amount).toEqual(588005449713604);
    expect(incoming.fromAddress).toBeNull();
    expect(incoming.responseAddress).toEqual(
        address("EQDv9OXOdUlsgU2hpZRPDmPCzY66tk4GqhTQ9Snk8LnEnQxb"),
    );
    expect(incoming.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(incoming.toCell().hash()).toEqual(incomingBody.hash());
    expect(outgoing.queryId).toEqual(0);
    expect(outgoing.toCell().hash()).toEqual(outgoingBody.hash());
}

get fun `test decodes observed tonfun v2 deployment transfer and excess`() {
    val incomingBodyBoc = "te6cckEBAQEANwAAaReNRRkAAAAAAAAAAGJmAmTCGVIAQqGmgx5cVcVdSE6LMo/aPEV878IyDQtMKkXgp6IW09yC/88iyw==";
    val outgoingBodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val incomingBody = parseCellFromBase64(incomingBodyBoc);
    val outgoingBody = parseCellFromBase64(outgoingBodyBoc);
    val incoming = TonFunBclWalletInternalTransfer.fromCell(incomingBody);
    val outgoing = TonFunBclWalletExcesses.fromCell(outgoingBody);
    var forwardPayload = incoming.forwardPayload;

    expect(incoming.queryId).toEqual(0);
    expect(incoming.amount).toEqual(42194401239445);
    expect(incoming.fromAddress).toBeNull();
    expect(incoming.responseAddress).toEqual(
        address("EQCFQ00GPLirirqQnRZlH7R4ivnfhGQaFphUi8FPRC2nuVux"),
    );
    expect(incoming.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(incoming.toCell().hash()).toEqual(incomingBody.hash());
    expect(outgoing.queryId).toEqual(0);
    expect(outgoing.toCell().hash()).toEqual(outgoingBody.hash());
}
