import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "./test_utils"
import "../types/fragment_username_item.types"

const USERNAME_COLLECTION = "0:80D78A35F955A14B679FAA887FF4CD5BFC0F43B4A4EEA2A7E6927F3701B273C2"
const USERNAME_INITIAL_BIDDER = "0:15E29566B7180E5F3F808F6E3531478F806023927EF39EB1D94576FA7021A244"
const USERNAME_OWNER = "0:8E33E79D3F6169E7F677FAD7BBD71AA73570C357C27B2974AA63B0EF16FF56FB"

get fun `test fragment username item decodes real collection deploy body`() {
    val txHash = "9M90/0wq4ybW9alZGyaLxUTLVy3PtVoJCK9k4MPDLhE=";
    val txLt = "34336226000005";
    val bodyBoc = "te6cckEBBQEAyQAEVymaPhWAArxSrNbjAcvn8BHtxqYo8fAMBHJP3nPWOyiu304ENEiMCS+W6YgBAQIDBAAWBGRhZ2UFbWUAdAAAWAFodHRwczovL25mdC5mcmFnbWVudC5jb20vdXNlcm5hbWUvZGFnZS5qc29uAGOACBG0dlFtgMtLJ8IHIk03VVOL8ZXXgY07PhVXdWVTJK1sCS+W6YgAAKAAAcIAASdQEABLAAUAZIAIEbR2UW2Ay0snwgciTTdVU4vxldeBjTs+FVd1ZVMkrXBzppyb";
    val decoded = FragmentUsernameItemDeploy.fromCell(parseCellFromBase64(bodyBoc));
    val auctionConfig = decoded.auctionConfig.load();
    val royalty = decoded.royaltyParams.load();

    expect(decoded.senderAddress).toEqual(address(USERNAME_INITIAL_BIDDER));
    expect(decoded.bid).toEqual(5050000000000);
    expect(decoded.tokenInfo.hash()).toBeGreater(0);
    expect(decoded.nftContent.hash()).toBeGreater(0);
    expect(auctionConfig.beneficiaryAddress).toEqual(address("0:408DA3B28B6C065A593E10391269BAAA9C5F8CAEBC0C69D9F0AABBAB2A99256B"));
    expect(auctionConfig.initialMinBid).toEqual(5050000000000);
    expect(auctionConfig.maxBid).toEqual(0);
    expect(auctionConfig.minBidStep).toEqual(5);
    expect(auctionConfig.minExtendTime).toEqual(3600);
    expect(auctionConfig.duration).toEqual(604800);
    expect(royalty.numerator).toEqual(5);
    expect(royalty.denominator).toEqual(100);
    expect(royalty.destination!).toEqual(address("0:408DA3B28B6C065A593E10391269BAAA9C5F8CAEBC0C69D9F0AABBAB2A99256B"));

    println("FRAGMENT_USERNAME_ITEM_DEPLOY_TX={} LT={} BODY={}", txHash, txLt, decoded);
}

get fun `test fragment username item decodes real start auction and ok bodies`() {
    val txHash = "UR5VatSvJub9WIC4IouRnLQzrwipVsTbxYaJE9joGCE=";
    val txLt = "46202951000001";
    val requestBoc = "te6cckEBAgEAQwABGEh6joEdh+0ehBzHMgEAY4ARxnzzp+wtPP7O/1r3euNU5q4YavhPZS6VTHYd4t/q32x5Q8Z/SAAAoAABwgABJ1AQ+DsnGg==";
    val okBoc = "te6cckEBAQEADgAAGKN6CYMdh+0ehBzHMvd45wI=";
    val request = FragmentUsernameItemStartAuction.fromCell(parseCellFromBase64(requestBoc));
    val ok = FragmentUsernameItemOk.fromCell(parseCellFromBase64(okBoc));
    val auctionConfig = request.auctionConfig.load();

    expect(request.queryId).toEqual(ok.queryId);
    expect(request.queryId).toEqual(2127930064277129010);
    expect(auctionConfig.beneficiaryAddress).toEqual(address(USERNAME_OWNER));
    expect(auctionConfig.initialMinBid).toEqual(66666000000000);
    expect(auctionConfig.maxBid).toEqual(0);
    expect(auctionConfig.minBidStep).toEqual(5);
    expect(auctionConfig.minExtendTime).toEqual(3600);
    expect(auctionConfig.duration).toEqual(604800);

    println("FRAGMENT_USERNAME_ITEM_START_AUCTION_TX={} LT={} REQUEST={} OK={}", txHash, txLt, request, ok);
}

get fun `test fragment username item decodes real transfer responses`() {
    val txHash = "Ic0eGMiD2a9H9Kj0X1RWTwnoZmh4A7qWxh/XaRUh59M=";
    val txLt = "44255504000003";
    val transferBoc = "te6cckEBAQEAUwAAoV/MPRQAAAGNUBNeFoARxnzzp+wtPP7O/1r3euNU5q4YavhPZS6VTHYd4t/q33AAV4pVmtxgOXz+Aj241MUePgGAjkn7znrHZRXb6cCGiRAgKAv/E5s=";
    val assignedBoc = "te6cckEBAQEAMAAAWwUTjZEAAAGNUBNeFoACvFKs1uMBy+fwEe3Gpijx8AwEck/ec9Y7KK7fTgQ0SIiEmhTf";
    val excessBoc = "te6cckEBAQEADgAAGNUydtsAAAGNUBNeFpRzgZo=";
    val transfer = FragmentUsernameItemTransfer.fromCell(parseCellFromBase64(transferBoc));
    val assigned = FragmentUsernameItemOwnershipAssigned.fromCell(parseCellFromBase64(assignedBoc));
    val excess = FragmentUsernameItemExcesses.fromCell(parseCellFromBase64(excessBoc));

    expect(transfer.queryId).toEqual(assigned.queryId);
    expect(transfer.queryId).toEqual(excess.queryId);
    expect(transfer.queryId).toEqual(1706445463062);
    expect(transfer.newOwnerAddress).toEqual(address(USERNAME_OWNER));
    expect(transfer.responseDestination).toEqual(address(USERNAME_INITIAL_BIDDER));
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(1);
    expect(assigned.previousOwnerAddress!).toEqual(address(USERNAME_INITIAL_BIDDER));
    expect(transfer.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(transfer.forwardPayload.remainingRefsCount()).toEqual(0);
    expect(assigned.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(assigned.forwardPayload.remainingRefsCount()).toEqual(0);

    println("FRAGMENT_USERNAME_ITEM_TRANSFER_TX={} LT={} TRANSFER={} ASSIGNED={} EXCESS={}", txHash, txLt, transfer, assigned, excess);
}

get fun `test fragment username item decodes real auction settlement notifications`() {
    val txHash = "30gxLOLOAqlAwaBfxMF4ZwrcTxRsCKUFxdYxJ6I7n6E=";
    val txLt = "34521791000001";
    val assignedBoc = "te6cckEBAQEAHQAANQUTjZEAAB9luxbtwQcCT7wsCS+W6YgAx3hNDeB71lo=";
    val fillUpBoc = "te6cckEBAQEADgAAGDcP7FEAAB9luxbtwSxzZXo=";
    val assigned = FragmentUsernameItemOwnershipAssigned.fromCell(parseCellFromBase64(assignedBoc));
    val fillUp = FragmentUsernameItemFillUp.fromCell(parseCellFromBase64(fillUpBoc));

    expect(assigned.previousOwnerAddress).toBeNull();
    expect(fillUp.queryId).toEqual(34521791000001);
    expect(assigned.queryId).toEqual(34521791000001);

    println("FRAGMENT_USERNAME_ITEM_SETTLEMENT_TX={} LT={} ASSIGNED={} FILL_UP={}", txHash, txLt, assigned, fillUp);
}
