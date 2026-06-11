import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/fragment_marketapp_proxy_simple.types"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test marketapp proxy simple decodes real buy body with root secondary ref`() {
    val txHash = "uWa++bMAMJJm/SInpIlLGo3sTsoxy5h4ZVXnwprnboI=";
    val txLt = "82456943000002";
    val bodyBoc = "te6cckEBBQEA2AACiD8rktJKeUZVVGRexOvUgvWc80wifh/KQZwTkAxGz1w5U06MSa9JS8RYgj3L0kFjrWvJ4I/wl7FKo6XL6nWXi3QWGhkFAQIBS4AQpIh/CzP81LtGn8hgk1icF9Zg43ZX9qzGvVKEJQ+FB0ntoj1BAwFDgAEom5vOuqTBUz+cMt7n63L5CZkv5Kt636IBl14W06cS8AQATAAAAAA0NzUgVGVsZWdyYW0gU3RhcnMgCgpSZWYjRVBYOGduR2RtADAAAAAAUmV3YXJkIGZyb20gc3BlbmQudGfKYSd4";
    val body = parseCellFromBase64(bodyBoc);
    expect(body.hash()).toEqual(0x5068448d9ba983d8f6bc40850d83377fa6b1ee03205f88c2c36e969c54dbe008);

    val decoded = FragmentMarketappProxySimpleBuy.fromCell(body);
    var request = decoded.request.load();
    expect(request.destination).toEqual(address("EQCFJEP4WZ_mpdo0_kMEmsTgvrMHG7K_tWY16pQhKHwoOoy2"));
    expect(request.amount).toEqual(4140900000);
    expect(request.forwardPayload.hash()).toEqual(0xfdfe6852426fc40af33246ab608089f99254f6e8dba8fd77d92c55d0a3c1cfc2);
    expectNoTail(mutate request.extra);

    var extra = decoded.extra;
    expect(extra.remainingBitsCount()).toEqual(0);
    expect(extra.remainingRefsCount()).toEqual(1);
    var secondary = FragmentMarketappProxySimpleSecondarySend.fromCell(extra.loadRef());
    expectNoTail(mutate extra);
    expect(secondary.destination).toEqual(address("EQAJRNzeddUmCpn84Zb3P1uXyEzJfyVb1v0QDLrwtp04l6Bc"));
    expect(secondary.forwardPayload.hash()).toEqual(0x68cc4ffbf3e7a6f31b825f2efe595f0e4f8f4c49bac6cf32c2b46806decd8e3a);
    expectNoTail(mutate secondary.extra);

    println("FRAGMENT_MARKETAPP_PROXY_SIMPLE_BUY_TX={} LT={}", txHash, txLt);
}
