import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_position_manager_legacy.types"

fun expectEmptyOpcodeBody(body: cell, expectedOpcode: uint32): void {
    var raw = body.beginParse();
    expect(raw.loadUint(32)).toEqual(expectedOpcode);
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);
}

get fun `test legacy storm position manager decodes real order-created notification`() {
    // Local 50M mainnet fixture:
    // tx 0qGUYCSuq2Ek3NwDqVHhAK10NiCM/jjDz/rUaxINGzI=
    // message LT 82380159000006
    // 0:EDBFA6…B09B -> 0:2F0927…0F65
    val bodyBoc = "te6cckEBAQEABgAACDqUPOb0tNdL";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLegacyOrderCreated.fromCell(body);

    expectEmptyOpcodeBody(body, 0x3a943ce6);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LEGACY_ORDER_CREATED_TX={} LT={}", "0qGUYCSuq2Ek3NwDqVHhAK10NiCM/jjDz/rUaxINGzI=", "82380159000006");
}

get fun `test legacy storm position manager decodes real order-canceled notification`() {
    // Local 50M mainnet fixture:
    // tx NwN34HlhoozH1IqAkHgVdHduM25MKqeLMHbRc9Xm4CQ=
    // message LT 81882307000004
    // 0:B60ED2…21AF -> 0:9E7E69…5F48
    val bodyBoc = "te6cckEBAQEABgAACGnQhnnLLOv/";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLegacyOrderCanceled.fromCell(body);

    expectEmptyOpcodeBody(body, 0x69d08679);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LEGACY_ORDER_CANCELED_TX={} LT={}", "NwN34HlhoozH1IqAkHgVdHduM25MKqeLMHbRc9Xm4CQ=", "81882307000004");
}
