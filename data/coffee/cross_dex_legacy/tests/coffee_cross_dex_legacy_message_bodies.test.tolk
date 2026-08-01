import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/coffee_cross_dex_legacy.types"

get fun `test coffee cross dex legacy decodes real dedust payout route`() {
    val txHash = "YRkEgXyG7vNf2YZ7NThLEbiOYFrR0ffcnRNUzENqz+Q=";
    val txLt = "55093269000001";
    val bodyBoc = "te6cckECBQEAASMAARlHT4bPABYH8AOqZUHAAQFtIA+QhgAWB/ADqmVBgAQL25IS1Ki7K7i8TFSt3sZqRRyjRqTEtnrSLXRCmu05qEGQqwCC+vCAEAIBZgHzg10AFgfwA6plQVEX3k+XWABp9yAAsFZDwucQPuLUo8wGoCT8ut1qE4HdjBt3QLBIewMB4WZk3iqACIWhYUA+wT02PGa2X/7CpYyhFbGOutFyc6UQzoyaVWXQANPuQAFgrIeFziB9xalHmA1ASfl1utQnA7sYNu6BYJD2ABp9yAAsFZDwucQPuLUo8wGoCT8ut1qE4HdjBt3QLBIegAAAADPsrhNABABZcJDY/NvamvgAafcgALBWQ8LnED7i1KPMBqAk/LrdahOB3Ywbd0CwSHoAAAAQU8K3fA==";
    val decoded = CoffeeCrossDexLegacyDedustPayout.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(6201176922678593);
    expect(decoded.payload).toBeNotNull();
    val resend = CoffeeCrossDexLegacyResend.fromCell(decoded.payload!);
    expect(resend.queryId).toEqual(decoded.queryId);
    expect(resend.nextRecipient).toEqual(
        address("0:205EDC9096A545D95DC5E262A56EF6335228E51A352625B3D6916BA214D769CD"),
    );
    expect(resend.next.beginParse().preloadUint(32)).toEqual(0x01f3835d);
    expect(resend.totalGas).toEqual(550000000);
    expect(resend.nextGas).toEqual(400000000);

    println("COFFEE_CROSS_DEX_LEGACY_DEDUST_TX={} LT={}", txHash, txLt);
}

get fun `test coffee cross dex legacy decodes real pton route`() {
    val txHash = "XODRl22Ytjnmn4V4ev/U5jDUp3/+uSlSLOXrOG9ieHc=";
    val txLt = "54103077000009";
    val bodyBoc = "te6cckECBQEAAQQAAWYB84NdABYH8ANC3aFceQlC8HgAL8E4JCc2PocpCOCVd8sK8zoDGnlhCtMCOgnXbunL2hkBAW0gD5CGABYH8ANC3aGAG1wqdOmxKXeGTpAzGaxNyeu+lNNaX0rZ0B+EyJauEaQIR4aMAII8NGAQAgFv6gYYXQAWB/ADQt2hXHkJQvCIAHy/+VG7+ebYbZP+jeYqxVVqNzIpCLWthNl7zJOrFKsQSxowj7QDAUtntF8rgAL8E4JCc2PocpCOCVd8sK8zoDGnlhCtMCOgnXbunL2hgwQAW7kC5hoAFgfwA0LdoYAC/BOCQnNj6HKQjglXfLCvM6Axp5YQrTAjoJ127py9oZDdVtK8";
    val decoded = CoffeeCrossDexLegacyPtonTonTransfer.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(6201176915893665);
    expect(decoded.tonAmount).toEqual(857124122375);
    expect(decoded.refundAddress).toEqual(
        address("0:17E09C12139B1F439484704ABBE585799D018D3CB08569811D04EBB774E5ED0C"),
    );
    expect(decoded.forwardPayload).toBeNotNull();
    val resend = CoffeeCrossDexLegacyResend.fromCell(decoded.forwardPayload!);
    expect(resend.queryId).toEqual(decoded.queryId);
    expect(resend.nextRecipient).toEqual(
        address("0:DAE153A74D894BBC32748198CD626E4F5DF4A69AD2FA56CE80FC2644B5708D20"),
    );
    expect(resend.next.beginParse().preloadUint(32)).toEqual(0xea06185d);
    expect(resend.totalGas).toEqual(600000000);
    expect(resend.nextGas).toEqual(300000000);

    println("COFFEE_CROSS_DEX_LEGACY_PTON_TX={} LT={}", txHash, txLt);
}
