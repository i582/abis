import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/dns_domain_item.types"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate forwardPayload: RemainingBitsAndRefs): void {
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expectNoTail(mutate forwardPayload);
}

get fun `test dns domain item decodes toncenter transfer body`() {
    val txHash = "npE1LhSeCkPNP3rh/1RVFsrdXbSuNqyfaf4Bw3M+cNw=";
    val txLt = "31576270000003";
    val bodyBoc = "te6cckEBAQEAVgAAp1/MPRQAAAAAAAAAAIATtS415xpeB1e+YRq/IsbVL8tFYPTNhzrjr5dcdgZdu5ACpAyLtPPm9pWmX6hy9we8PuXhIqghBi2XbZjadqCAnISAJiWgCNB6ESs=";
    val expectedNewOwner = address("0:9DA971AF38D2F03ABDF308D5F91636A97E5A2B07A66C39D71D7CBAE3B032EDDC");
    val expectedResponseDestination = address("0:A90322ED3CF9BDA56997EA1CBDC1EF0FB97848AA08418B65DB66369DA8202721");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(expectedNewOwner);
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(expectedResponseDestination);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(20000000);
    var forwardPayload = decoded.forwardPayload;
    expectInlineEmptyForwardPayload(mutate forwardPayload);

    println("DNS_DOMAIN_ITEM_TONCENTER_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter change dns delete body`() {
    val txHash = "yOp2wQW32buIMjAfh68Pc08dJxWemiRCf5oPVWbmzZU=";
    val txLt = "64165205000003";
    val bodyBoc = "te6cckEBAQEALgAAWE6x8PkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMPrTzw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemChangeDnsRecord.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.key).toEqual(0 as uint256);
    var value = decoded.value;
    expectNoTail(mutate value);

    println("DNS_DOMAIN_ITEM_TONCENTER_CHANGE_DNS_DELETE_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter get static data body`() {
    val txHash = "AMkR0iCPnx9dPNOULr0DGBKMrbzJE+t1uC50u6xz+MY=";
    val txLt = "39594664000003";
    val bodyBoc = "te6cckEBAQEADgAAGC/LJqIAAAAAAAAClRa0ss0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemGetStaticData.fromCell(body);

    expect(decoded.queryId).toEqual(661);

    println("DNS_DOMAIN_ITEM_TONCENTER_GET_STATIC_DATA_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter ownership assigned body`() {
    val txHash = "npE1LhSeCkPNP3rh/1RVFsrdXbSuNqyfaf4Bw3M+cNw=";
    val txLt = "31576270000003";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZEAAAAAAAAAAIAVIGRdp583tK0y/UOXuD3h9y8JFUEIMWy7bMbTtQQE5Cjgq8h9";
    val expectedPreviousOwner = address("0:A90322ED3CF9BDA56997EA1CBDC1EF0FB97848AA08418B65DB66369DA8202721");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemOwnershipAssigned.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(expectedPreviousOwner);
    var forwardPayload = decoded.forwardPayload;
    expectInlineEmptyForwardPayload(mutate forwardPayload);

    println("DNS_DOMAIN_ITEM_TONCENTER_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter report static data body`() {
    val txHash = "AMkR0iCPnx9dPNOULr0DGBKMrbzJE+t1uC50u6xz+MY=";
    val txLt = "39594664000003";
    val bodyBoc = "te6cckEBAQEAUAAAm4t3FzUAAAAAAAAClZx9VswRXnz2wl4Sa+p3y8PLFdVRBvLjl1YlkQWZY/qjgBbumyvWQKh+MNgNZuNXEVrgnvxKwmGV8sMSbRT6GW2Z8HDwqSU=";
    val expectedCollection = address("0:B774D95EB20543F186C06B371AB88AD704F7E256130CAF96189368A7D0CB6CCF");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemReportStaticData.fromCell(body);

    expect(decoded.queryId).toEqual(661);
    expect(decoded.itemIndex).toEqual(
        0x9c7d56cc115e7cf6c25e126bea77cbc3cb15d55106f2e397562591059963faa3 as uint256,
    );
    expect(decoded.collectionAddress).toEqual(expectedCollection);

    println("DNS_DOMAIN_ITEM_TONCENTER_REPORT_STATIC_DATA_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter excess body`() {
    val txHash = "npE1LhSeCkPNP3rh/1RVFsrdXbSuNqyfaf4Bw3M+cNw=";
    val txLt = "31576270000003";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);

    println("DNS_DOMAIN_ITEM_TONCENTER_EXCESS_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter fill up body`() {
    val txHash = "f3usIipxmuHwUvH3vF5B21IEYvckUSnKBUMsoUPRva0=";
    val txLt = "31360895000003";
    val bodyBoc = "te6cckEBAQEADgAAGDcP7FEAAAAAYymbaahZ7m0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemFillUp.fromCell(body);

    expect(decoded.queryId).toEqual(1663671145);

    println("DNS_DOMAIN_ITEM_TONCENTER_FILL_UP_TX={} LT={}", txHash, txLt);
}

get fun `test dns domain item decodes toncenter outbid notification body`() {
    val txHash = "pXF+Pb/h0KRkBE4pLeMij+evtrNUYj2d9C8HjKPDID0=";
    val txLt = "30176973000003";
    val bodyBoc = "te6cckEBAQEADgAAGFV86iAAABtyH8GNQ7W6ma0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DnsDomainItemOutbidNotification.fromCell(body);

    expect(decoded.queryId).toEqual(30176973000003);

    println("DNS_DOMAIN_ITEM_TONCENTER_OUTBID_NOTIFICATION_TX={} LT={}", txHash, txLt);
}
