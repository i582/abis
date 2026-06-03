import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_auction_v2.types"

get fun `test getgems auction v2 decodes toncenter empty bid body`() {
    val txHash = "f8R9sm2FleVjeBarDgPuGKRjO6bmNZnKU21EcSUwPtU=";
    val txLt = "30578080000003";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V2_TONCENTER_EMPTY_BID_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v2 decodes toncenter external activate raw body`() {
    val txHash = "8qQaNqDYlKSmphMHOBvAk6oboCAixqdE4hEHkICD0ik=";
    val txLt = "30578047000001";
    val bodyBoc = "te6cckEBAQEAJgAASAAAAABnZXRnZW1zLmlvIGRlcGxveSBhdWN0aW9uIHYyAAAAAB7f0jE=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV2ActivateExternal.fromCell(body);
    var rawBody = decoded.rawBody;

    expect(rawBody.remainingBitsCount()).toEqual(288);
    expect(rawBody.remainingRefsCount()).toEqual(0);
    expect(rawBody.loadUint(32)).toEqual(0);
    expect(rawBody.loadUint(64)).toEqual(0x67657467656d732e);
    expect(rawBody.loadUint(64)).toEqual(0x696f206465706c6f);
    expect(rawBody.loadUint(64)).toEqual(0x792061756374696f);
    expect(rawBody.loadUint(64)).toEqual(0x6e20763200000000);
    expect(rawBody.remainingBitsCount()).toEqual(0);
    expect(rawBody.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V2_TONCENTER_EXTERNAL_ACTIVATE_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v2 decodes toncenter zero opcode text command body`() {
    val txHash = "8qQaNqDYlKSmphMHOBvAk6oboCAixqdE4hEHkICD0ik=";
    val txLt = "30578047000001";
    val bodyBoc = "te6cckEBAQEAJgAASAAAAABnZXRnZW1zLmlvIGRlcGxveSBhdWN0aW9uIHYyAAAAAB7f0jE=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV2TextCommand.fromCell(body);
    var comment = decoded.comment;

    expect(comment.remainingBitsCount()).toEqual(256);
    expect(comment.remainingRefsCount()).toEqual(0);
    expect(comment.loadUint(64)).toEqual(0x67657467656d732e);
    expect(comment.loadUint(64)).toEqual(0x696f206465706c6f);
    expect(comment.loadUint(64)).toEqual(0x792061756374696f);
    expect(comment.loadUint(64)).toEqual(0x6e20763200000000);
    expect(comment.remainingBitsCount()).toEqual(0);
    expect(comment.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V2_TONCENTER_ZERO_OPCODE_TEXT_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v2 decodes toncenter ownership assigned body`() {
    val txHash = "N0692aEJ99auzncDYRPfuSq7gUiLox9P/xvjrpHCErc=";
    val txLt = "30578044000005";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZEAAAAAAAAAAIAPI6D8b1+ftl3DKAzgaf/BAOhCg0PJ5m14C56mz3B3X6hXddC4";
    val expectedPreviousOwner = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV2OwnershipAssigned.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(expectedPreviousOwner);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V2_TONCENTER_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v2 decodes toncenter outbid text comment body`() {
    val txHash = "8ybCcoOPDkCO+2FE6eWTlKeIG33vKu/BHQRqYCWDH3w=";
    val txLt = "30578099000003";
    val bodyBoc = "te6cckEBAQEALwAAWgAAAABZb3VyIGJpZCBoYXMgYmVlbiBvdXRiaWQgYnkgYW5vdGhlciB1c2VyLksbQPQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV2TextComment.fromCell(body);
    var comment = decoded.comment;

    expect(comment.remainingBitsCount()).toEqual(328);
    expect(comment.remainingRefsCount()).toEqual(0);
    expect(comment.loadUint(64)).toEqual(0x596f757220626964);
    expect(comment.loadUint(64)).toEqual(0x2068617320626565);
    expect(comment.loadUint(64)).toEqual(0x6e206f7574626964);
    expect(comment.loadUint(64)).toEqual(0x20627920616e6f74);
    expect(comment.loadUint(64)).toEqual(0x6865722075736572);
    expect(comment.loadUint(8)).toEqual(0x2e);
    expect(comment.remainingBitsCount()).toEqual(0);
    expect(comment.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V2_TONCENTER_OUTBID_TEXT_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v2 decodes toncenter nft transfer out body`() {
    val txHash = "nrDakjjuUFWw1FFB1YOrShU9of1EtBLeIJgQYwjz3fo=";
    val txLt = "30578226000003";
    val bodyBoc = "te6cckEBAQEAVQAApV/MPRQAABvPjExwg4AbsLOMErehSOuMpqm7Jsdp6cbTnw2EAsJM4MVOcbG7ybAB5HQfjevz9su4ZQGcDT/4IB0IUGh5PM2vAXPU2e4O6/RzEtAIDh+Ebw==";
    val expectedNewOwner = address("0:DD859C6095BD0A475C65354DD9363B4F4E369CF86C20161267062A738D8DDE4D");
    val expectedResponseDestination = address("0:791D07E37AFCFDB2EE194067034FFE080742141A1E4F336BC05CF5367B83BAFD");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV2NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(30578226000003);
    expect(decoded.newOwnerAddress).toEqual(expectedNewOwner);
    expect(decoded.responseDestination).toEqual(expectedResponseDestination);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(10000000);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_AUCTION_V2_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}
