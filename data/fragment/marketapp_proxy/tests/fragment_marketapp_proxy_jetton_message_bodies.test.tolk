import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/fragment_marketapp_proxy_jetton.types"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectFalseMaybeTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(1);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(tail.loadBool()).toBeFalse();
    expectNoTail(mutate tail);
}

get fun `test marketapp proxy jetton decodes real buy body with signed false secondary tail`() {
    val txHash = "GLLP2ouqx7FakGkn2Yy/oPRXCnDRvDLKd66ei3zUv5c=";
    val txLt = "82457718000002";
    val bodyBoc = "te6cckEBAwEAmAABiD8rktKUow8K3I5ydNDXQSjPdDhiEN5Dux+AIt+nNkePu9pZHFHi3Py0NnuSsEmb8WE7yE8nI9j1E3KLiBXWQCCs87ANAQFMgBCkiH8LM/zUu0afyGCTWJwX1mDjdlf2rMa9UoQlD4UHSM+yxsACAEwAAAAAMjAwIFRlbGVncmFtIFN0YXJzIAoKUmVmIzBwY1JpdFNpZPgjxkU=";
    val body = parseCellFromBase64(bodyBoc);
    expect(body.hash()).toEqual(0x8d02a86039e5df541ff8aae2f39e038fe09e895966cebe31b49c01c16e3ee631);

    val decoded = FragmentMarketappProxyJettonBuy.fromCell(body);
    var request = decoded.request.load();
    expect(request.destination).toEqual(address("EQCFJEP4WZ_mpdo0_kMEmsTgvrMHG7K_tWY16pQhKHwoOoy2"));
    expect(request.amount).toEqual(1742300000);
    expect(request.forwardPayload.hash()).toEqual(0xc77d3e69328eedb15c7e41a1af077728ef1664002c0cce4dbc0c5d354844bee8);
    expectFalseMaybeTail(mutate request.extra);

    var extra = decoded.extra;
    expectNoTail(mutate extra);

    println("FRAGMENT_MARKETAPP_PROXY_JETTON_BUY_TX={} LT={}", txHash, txLt);
}
