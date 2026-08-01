import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/coffee_cross_dex_bidask.types"

get fun `test coffee cross dex bidask decodes real native transfer route`() {
    val txHash = "zsejvylVchCYH7WUzH1XKrds77eWBdpBshGJ5Ks3U3w=";
    val txLt = "58903276000001";
    val bodyBoc = "te6cckEBBAEA0AABIW7dZfAAPA/oAvd+YUC+eHYMAQFtIA+QhgA8D+gC935hgBtl1J/5w40iIx6CTrjbRVV6wd6nBt/r0Od8I+I5qJCSiEGQqwCB3NZQEAIBa8D/7gAAPA/oAvd+YUC+L1H3kJMbxofrhr/ZKFjDKWSDnf4WNUNuoF4DF2aYasdwRXQKlStrQAMAjWhi1bqAE/LXRTSbRZ43nqi6LZ/aMgpJ7VQoz1Ilu3M53MrQk7OQAmf6VehCTUq+l6bz2mviFZE+iJqpIj37UTDiAiT9Qf+9BD0Bxg==";
    val decoded = CoffeeCrossDexBidaskBidaskNativeTransferNotification.fromCell(
        parseCellFromBase64(bodyBoc),
    );

    expect(decoded.queryId).toEqual(16905987759242849);
    expect(decoded.nativeAmount).toEqual(199722848);
    expect(decoded.forwardPayload).toBeNotNull();
    val resend = CoffeeCrossDexBidaskResend.fromCell(decoded.forwardPayload!);
    expect(resend.queryId).toEqual(decoded.queryId);
    expect(resend.nextRecipient).toEqual(
        address("0:DB2EA4FFCE1C691118F41275C6DA2AABD60EF53836FF5E873BE11F11CD448494"),
    );
    expect(resend.next.beginParse().preloadUint(32)).toEqual(0xc0ffee00);
    expect(resend.totalGas).toEqual(550000000);
    expect(resend.nextGas).toEqual(250000000);

    println("COFFEE_CROSS_DEX_BIDASK_NATIVE_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test coffee cross dex bidask decodes real jetton route wrapper`() {
    val txHash = "lcRn/T4OFyvg54/Rk9BtzTFLwpYvwCqyFCK/ORo2als=";
    val txLt = "60470579000014";
    val bodyBoc = "te6cckECBQEAATwAAWhzYtCcADwP4AAAfQFgJa7+iBDoAZXYy6FABfNlH8ikL31McvY1S5myX/1ZLk4hx65F8aN3AQEITumxBgIBtA+KfqUAPA/gAAB9AWAlrv6IEPgB4/fRqKenqWjy2nsMr94O5kRaJHsblM+T3nWaRM3oEu8AJ+Wuimk2izxvPVF0Wz+0ZBST2qhRnqRLduZzuZWhJ2cIKgVyQQMB4WZk3iqAGqgUz0CNHfTDgPKCRKapez94rCTJmVs0giMrPfKZzb8wAn5a6KaTaLPG89UXRbP7RkFJPaqFGepEt25nO5laEnZyAE/LXRTSbRZ43nqi6LZ/aMgpJ7VQoz1Ilu3M53MrQk7OAAAAADRPKn1ABABVUB+F+FHYAT8tdFNJtFnjeeqLotn9oyCkntVCjPUiW7czncytCTs4AAAAEP7Y5fk=";
    val decoded = CoffeeCrossDexBidaskJettonTransferNotification.fromCell(
        parseCellFromBase64(bodyBoc),
    );

    expect(decoded.queryId).toEqual(16905953349762305);
    expect(decoded.amount).toEqual(2589595304206);
    expect(decoded.sender).toEqual(
        address("0:CAEC65D0A002F9B28FE45217BEA6397B1AA5CCD92FFEAC972710E3D722F8D1BB"),
    );
    var forwardPayload = decoded.forwardPayload;
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(1);
    expect(forwardPayload.loadBool()).toBeTrue();
    val wrapper = CoffeeCrossDexBidaskResendJettonPayload.fromCell(forwardPayload.loadRef());
    expect(wrapper.next.beginParse().preloadUint(32)).toEqual(0x0f8a7ea5);
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("COFFEE_CROSS_DEX_BIDASK_JETTON_NOTIFY_TX={} LT={}", txHash, txLt);
}
