import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/telegram_gift_nft_item.types"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(payload);
}

get fun `test telegram gift v1 decodes real deployment body`() {
    val txHash = "tOXgid5tDcoZSesnDosnbogTKTAMNZHbqY8ojI6OMq4=";
    val txLt = "52086548000001";
    val bodyBoc = "te6cckEBBwEA1wAEUymaPhWAHUqtG0V0METtODQASj1hNtcnu9HoMaTRZV/yZU1UbO/o7msoAQECAwQAGgpwZXBwZXJtaW50AQABAwDABQBngAM+7239QCym6yJRy0jQdhASjW6/L98mTY90a6gSgEATiO5rKACO5rKAAKAAAH0AACowEABLAAUAZIADPu9t/UAspusiUctI0HYQEo1uvy/fJk2PdGuoEoBAE5ABQ6AQVGpv/ht5z92GutPbh0MT3N4vsF5qdKp/NVLZYXx50TAGABwAcGVwcGVybWludCAjMRkEyuI=";
    val expectedSender = address("0:EA5568DA2BA1822769C1A00251EB09B6B93DDE8F418D268B2AFF932A6AA3677F");
    val expectedBeneficiary = address("0:19F77B6FEA01653759128E5A4683B080946B75F97EF9326C7BA35D409402009C");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TelegramGiftNftItemDeploy.fromCell(body);
    val auction = decoded.auctionConfig.load();
    val royalty = decoded.royaltyParams.load();

    expect(decoded.senderAddress).toEqual(expectedSender);
    expect(decoded.bid).toEqual(2000000000);
    expect(auction.beneficiaryAddress).toEqual(expectedBeneficiary);
    expect(auction.initialMinBid).toEqual(2000000000);
    expect(auction.maxBid).toEqual(2000000000);
    expect(auction.minBidStep).toEqual(5);
    expect(auction.minExtendTime).toEqual(1000);
    expect(auction.duration).toEqual(86400);
    expect(royalty.numerator).toEqual(5);
    expect(royalty.denominator).toEqual(100);
    expect(royalty.destination).toEqual(expectedBeneficiary);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TELEGRAM_GIFT_V1_DEPLOY_TX={} LT={}", txHash, txLt);
}

get fun `test telegram gift v1 decodes real settlement outputs`() {
    val txHash = "tOXgid5tDcoZSesnDosnbogTKTAMNZHbqY8ojI6OMq4=";
    val txLt = "52086548000001";
    val ownershipBodyBoc = "te6cckEBAQEAGwAAMQUTjZEAAC9fWDDtAQcCT7wo7msoAM7NdMf76MKB";
    val fillUpBodyBoc = "te6cckEBAQEADgAAGDcP7FEAAC9fWDDtAX91K6E=";
    val ownershipBody = parseCellFromBase64(ownershipBodyBoc);
    val ownership = TelegramGiftNftItemOwnershipAssigned.fromCell(ownershipBody);
    var payload = ownership.forwardPayload;

    expect(ownership.queryId).toEqual(52086548000001);
    expect(ownership.previousOwnerAddress).toBeNull();
    expect(payload.loadBool()).toBeFalse();
    expect(payload.loadUint(32)).toEqual(0x38127de1);
    expect(payload.loadCoins()).toEqual(2000000000);
    expect(payload.loadUint(32)).toEqual(1734785635);
    expectNoTail(payload);
    expect(ownership.toCell().hash()).toEqual(ownershipBody.hash());

    val fillUpBody = parseCellFromBase64(fillUpBodyBoc);
    val fillUp = TelegramGiftNftItemFillUp.fromCell(fillUpBody);
    expect(fillUp.queryId).toEqual(52086548000001);
    expect(fillUp.toCell().hash()).toEqual(fillUpBody.hash());

    println("TELEGRAM_GIFT_V1_SETTLEMENT_TX={} LT={}", txHash, txLt);
}

get fun `test telegram gift v2 decodes real transfer body`() {
    val txHash = "d90Rcj7dRtbfy8LruxvpFeCFEiXZx9ZlapqRfCJGDAw=";
    val txLt = "60054989000003";
    val bodyBoc = "te6cckEBAQEAUwAAoV/MPRSYX1c+Wua16YAJxsyfXdAp97bYOWba5XWKWivDDYI9msyfw2fjT5+wA7ACdqXGvONLwOr3zCNX5FjapflorB6ZsOdcdfLrjsDLt3AgKEEHvN4=";
    val expectedNewOwner = address("0:4E3664FAEE814FBDB6C1CB36D72BAC52D15E186C11ECD664FE1B3F1A7CFD801D");
    val expectedResponse = address("0:9DA971AF38D2F03ABDF308D5F91636A97E5A2B07A66C39D71D7CBAE3B032EDDC");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TelegramGiftNftItemTransfer.fromCell(body);
    var payload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(10979590341877216745);
    expect(decoded.newOwnerAddress).toEqual(expectedNewOwner);
    expect(decoded.responseDestination).toEqual(expectedResponse);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(1);
    expectInlineEmptyForwardPayload(mutate payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TELEGRAM_GIFT_V2_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test telegram gift v2 decodes real transfer outputs`() {
    val txHash = "d90Rcj7dRtbfy8LruxvpFeCFEiXZx9ZlapqRfCJGDAw=";
    val txLt = "60054989000003";
    val ownershipBodyBoc = "te6cckEBAQEAMAAAWwUTjZGYX1c+Wua16YATtS415xpeB1e+YRq/IsbVL8tFYPTNhzrjr5dcdgZdu4ixi8Nn";
    val excessBodyBoc = "te6cckEBAQEADgAAGNUydtuYX1c+Wua16V31Shg=";
    val expectedPreviousOwner = address("0:9DA971AF38D2F03ABDF308D5F91636A97E5A2B07A66C39D71D7CBAE3B032EDDC");
    val ownershipBody = parseCellFromBase64(ownershipBodyBoc);
    val ownership = TelegramGiftNftItemOwnershipAssigned.fromCell(ownershipBody);
    var payload = ownership.forwardPayload;

    expect(ownership.queryId).toEqual(10979590341877216745);
    expect(ownership.previousOwnerAddress).toEqual(expectedPreviousOwner);
    expectInlineEmptyForwardPayload(mutate payload);
    expect(ownership.toCell().hash()).toEqual(ownershipBody.hash());

    val excessBody = parseCellFromBase64(excessBodyBoc);
    val excess = TelegramGiftNftItemExcesses.fromCell(excessBody);
    expect(excess.queryId).toEqual(10979590341877216745);
    expect(excess.toCell().hash()).toEqual(excessBody.hash());

    println("TELEGRAM_GIFT_V2_TRANSFER_TX={} LT={}", txHash, txLt);
}
