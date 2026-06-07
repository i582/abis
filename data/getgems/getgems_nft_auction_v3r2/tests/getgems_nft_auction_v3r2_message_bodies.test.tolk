import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_nft_auction_v3r2.types"

get fun `test getgems auction v3r2 decodes toncenter empty bid body`() {
    val txHash = "W7jLUnCa9VwGhhsiiOWzFQ7KudYjlwbVI1p7+qvsTso=";
    val txLt = "36406123000001";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    val bid = GetgemsNftAuctionV3R2Bid.fromCell(body);
    val payload = bid.payload;
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(bid.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_AUCTION_V3R2_TONCENTER_EMPTY_BID_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v3r2 decodes toncenter ownership assigned body`() {
    val txHash = "ttrFIQHmW6Ac0kdNnemuMEl/X31e+eEBQYeM/X1LcV0=";
    val txLt = "36406118000005";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZEAAAAAAAAAAIAKeDGeAmCJZmwGuOdbqBPxGNY4+0aruWiqnpwPcnr/hKjRBOLZ";
    val expectedPreviousOwner = address("0:53C18CF013044B336035C73ADD409F88C6B1C7DA355DCB4554F4E07B93D7FC25");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV3R2OwnershipAssigned.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(expectedPreviousOwner);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_AUCTION_V3R2_TONCENTER_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v3r2 decodes toncenter finish text command body`() {
    val txHash = "JwgTSwXyjvNHpqIlmiCqJLAXL+nGFI7juEYsnZHPJ2Y=";
    val txLt = "36406380000001";
    val bodyBoc = "te6cckEBAQEADAAAFAAAAABmaW5pc2jiLUfQ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV3R2TextCommand.fromCell(body);
    var command = decoded.command;

    expect(command.remainingBitsCount()).toEqual(48);
    expect(command.remainingRefsCount()).toEqual(0);
    expect(command.loadUint(48)).toEqual(0x66696e697368);
    expect(command.remainingBitsCount()).toEqual(0);
    expect(command.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_AUCTION_V3R2_TONCENTER_FINISH_TEXT_COMMAND_TX={} LT={}", txHash, txLt);
}

get fun `test getgems auction v3r2 decodes toncenter nft transfer out body`() {
    val txHash = "JwgTSwXyjvNHpqIlmiCqJLAXL+nGFI7juEYsnZHPJ2Y=";
    val txLt = "36406380000001";
    val bodyBoc = "te6cckEBAQEAUgAAn1/MPRQAACEchVjzAYAKeDGeAmCJZmwGuOdbqBPxGNY4+0aruWiqnpwPcnr/hLABTwYzwEwRLM2A1xzrdQJ+IxrHH2jVdy0VU9OB7k9f8JQIswz5cg==";
    val expectedNewOwner = address("0:53C18CF013044B336035C73ADD409F88C6B1C7DA355DCB4554F4E07B93D7FC25");
    val expectedResponseDestination = address("0:53C18CF013044B336035C73ADD409F88C6B1C7DA355DCB4554F4E07B93D7FC25");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftAuctionV3R2NftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(36406380000001);
    expect(decoded.newOwnerAddress).toEqual(expectedNewOwner);
    expect(decoded.responseDestination).toEqual(expectedResponseDestination);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_AUCTION_V3R2_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}
