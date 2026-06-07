import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_offer_v1.types"

get fun `test getgems offer v1 decodes toncenter zero text command body`() {
    val txHash = "HLcHWBKUvkgTKNOH32M4ZqBCmnUBejYzG+GQG7oAamM=";
    val txLt = "31423352000003";
    val bodyBoc = "te6cckEBAQEAFgAAKAAAAABPZmZlciBmb3IgRG9nICM0EyKoww==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftOfferV1TextCommand.fromCell(body);
    var payload = decoded.payload;

    expect(payload.remainingBitsCount()).toEqual(128);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadUint(64)).toEqual(0x4f6666657220666f);
    expect(payload.loadUint(64)).toEqual(0x7220446f67202334);
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_OFFER_V1_TONCENTER_ZERO_TEXT_COMMAND_TX={} LT={}", txHash, txLt);
}

get fun `test getgems offer v1 decodes toncenter marketplace cancel offer body`() {
    val txHash = "V+MLJyGJ0XlofTIDKH7OcVkFwMck4DqVJAKSTmQ9ioE=";
    val txLt = "31560206000003";
    val bodyBoc = "te6cckEBAgEAJQABEQAAAANAHJw4CAEALgAAAABDYW5jZWwgb2ZmZXIgRG9nICM01wwH3A==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftOfferV1CancelOffer.fromCell(body);
    val marketplacePayload = GetgemsNftOfferV1MarketplaceCancelPayload.fromCell(
        decoded.payload.toCell(),
    );
    var ownerPayload = marketplacePayload.ownerPayload.beginParse();

    expect(marketplacePayload.cancelFee).toEqual(30000000);
    expect(ownerPayload.remainingBitsCount()).toEqual(184);
    expect(ownerPayload.remainingRefsCount()).toEqual(0);
    expect(ownerPayload.loadUint(32)).toEqual(0);
    expect(ownerPayload.loadUint(64)).toEqual(0x43616e63656c206f);
    expect(ownerPayload.loadUint(64)).toEqual(0x6666657220446f67);
    expect(ownerPayload.loadUint(24)).toEqual(0x202334);
    expect(ownerPayload.remainingBitsCount()).toEqual(0);
    expect(ownerPayload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_OFFER_V1_TONCENTER_CANCEL_OFFER_TX={} LT={}", txHash, txLt);
}

get fun `test getgems offer v1 decodes toncenter cancel fee text comment body`() {
    val txHash = "V+MLJyGJ0XlofTIDKH7OcVkFwMck4DqVJAKSTmQ9ioE=";
    val txLt = "31560206000003";
    val bodyBoc = "te6cckEBAQEAFgAAKAAAAABPZmZlciBjYW5jZWwgZmVlsKlPNg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftOfferV1TextComment.fromCell(body);
    var text = decoded.text;

    expect(text.remainingBitsCount()).toEqual(128);
    expect(text.remainingRefsCount()).toEqual(0);
    expect(text.loadUint(64)).toEqual(0x4f66666572206361);
    expect(text.loadUint(64)).toEqual(0x6e63656c20666565);
    expect(text.remainingBitsCount()).toEqual(0);
    expect(text.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_OFFER_V1_TONCENTER_CANCEL_FEE_TEXT_TX={} LT={}", txHash, txLt);
}
