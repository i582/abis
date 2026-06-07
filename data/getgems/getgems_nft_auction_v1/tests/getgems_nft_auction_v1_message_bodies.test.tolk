import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_auction_v1.types"

get fun `test getgems auction v1 decodes toncenter empty bid body`() {
    val txHash = "zOuXAlAMpPpi7QnbMToHVOQymVYZQCnGZ9m21Y+wwBc=";
    val txLt = "29720601000003";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val emptyBid = GetgemsNftAuctionV1EmptyBid.fromCell(body);
    expect(emptyBid.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_AUCTION_V1_TONCENTER_EMPTY_BID_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v1 decodes toncenter external activate raw body`() {
    val txHash = "/3bS2Bz9kkFTYz1JNRhXmrUg7SrhtmzrMkofdGoDXLk=";
    val txLt = "29720570000001";
    val bodyBoc = "te6cckEBAQEAHwAAOgAAAABnZXRnZW1zLmlvIGRlcGxveSBhdWN0aW9uCksGUQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV1ExternalActivate.fromCell(body);
    var rawBody = decoded.rawBody;

    expect(rawBody.remainingBitsCount()).toEqual(232);
    expect(rawBody.remainingRefsCount()).toEqual(0);
    expect(rawBody.loadUint(32)).toEqual(0);
    expect(rawBody.loadUint(64)).toEqual(0x67657467656d732e);
    expect(rawBody.loadUint(64)).toEqual(0x696f206465706c6f);
    expect(rawBody.loadUint(64)).toEqual(0x792061756374696f);
    expect(rawBody.loadUint(8)).toEqual(0x6e);
    expect(rawBody.remainingBitsCount()).toEqual(0);
    expect(rawBody.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V1_TONCENTER_EXTERNAL_ACTIVATE_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v1 decodes toncenter stop text command body`() {
    val txHash = "k/oU6SXIg0lpBtq6ql3q+Apr7eKEQT49z0Y9eMeBHWo=";
    val txLt = "29739654000003";
    val bodyBoc = "te6cckEBAQEACgAAEAAAAABzdG9wtSN8lg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV1TextCommand.fromCell(body);
    var command = decoded.command;

    expect(command.remainingBitsCount()).toEqual(32);
    expect(command.remainingRefsCount()).toEqual(0);
    expect(command.loadUint(32)).toEqual(0x73746f70);
    expect(command.remainingBitsCount()).toEqual(0);
    expect(command.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V1_TONCENTER_STOP_TEXT_COMMAND_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v1 decodes toncenter nft transfer out body`() {
    val txHash = "k/oU6SXIg0lpBtq6ql3q+Apr7eKEQT49z0Y9eMeBHWo=";
    val txLt = "29739654000003";
    val bodyBoc = "te6cckEBAQEAVgAAp1/MPRQAABsMTYMtg4ABfo1/tw8s2+RN+p8deUk8zbAk+qrKMtEbgmTa6b9cX3AB5HQfjevz9su4ZQGcDT/4IB0IUGh5PM2vAXPU2e4O6/SAOThwCG3Uo3o=";
    val expectedNewOwner = address("0:0BF46BFDB87966DF226FD4F8EBCA49E66D8127D556519688DC1326D74DFAE2FB");
    val expectedResponseDestination = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV1NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(29739654000003);
    expect(decoded.newOwnerAddress).toBeNotNull();
    expect(decoded.newOwnerAddress!).toEqual(expectedNewOwner);
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(expectedResponseDestination);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(30000000);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();

    println("GETGEMS_NFT_AUCTION_V1_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v1 decodes toncenter rejected bid text notification body`() {
    val txHash = "k/oU6SXIg0lpBtq6ql3q+Apr7eKEQT49z0Y9eMeBHWo=";
    val txLt = "29739654000003";
    val bodyBoc = "te6cckEBAQEALQAAVgAAAABZb3VyIHRyYW5zYWN0aW9uIGhhcyBub3QgYmVlbiBhY2NlcHRlZC637R96";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV1TextCommand.fromCell(body);
    var text = decoded.command;

    expect(text.remainingBitsCount()).toEqual(312);
    expect(text.remainingRefsCount()).toEqual(0);
    expect(text.loadUint(64)).toEqual(0x596f757220747261);
    expect(text.loadUint(64)).toEqual(0x6e73616374696f6e);
    expect(text.loadUint(64)).toEqual(0x20686173206e6f74);
    expect(text.loadUint(64)).toEqual(0x206265656e206163);
    expect(text.loadUint(56)).toEqual(0x6365707465642e);
    expect(text.remainingBitsCount()).toEqual(0);
    expect(text.remainingRefsCount()).toEqual(0);

    println(
        "GETGEMS_NFT_AUCTION_V1_TONCENTER_REJECTED_TEXT_NOTIFICATION_TX={} LT={}",
        txHash,
        txLt,
    );
}

get fun `test getgems auction v1 decodes toncenter previous owner text notification body`() {
    val txHash = "k/oU6SXIg0lpBtq6ql3q+Apr7eKEQT49z0Y9eMeBHWo=";
    val txLt = "29739654000003";
    val bodyBoc = "te6cckEBAQEAHQAANgAAAABQcmV2aW91cyBvd25lciB3aXRoZHJhd6meMrk=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV1TextCommand.fromCell(body);
    var text = decoded.command;

    expect(text.remainingBitsCount()).toEqual(184);
    expect(text.remainingRefsCount()).toEqual(0);
    expect(text.loadUint(64)).toEqual(0x50726576696f7573);
    expect(text.loadUint(64)).toEqual(0x206f776e65722077);
    expect(text.loadUint(56)).toEqual(0x69746864726177);
    expect(text.remainingBitsCount()).toEqual(0);
    expect(text.remainingRefsCount()).toEqual(0);

    println(
        "GETGEMS_NFT_AUCTION_V1_TONCENTER_PREVIOUS_OWNER_TEXT_NOTIFICATION_TX={} LT={}",
        txHash,
        txLt,
    );
}
