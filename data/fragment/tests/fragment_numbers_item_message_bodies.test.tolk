import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/fragment_numbers_item.types"

const NUMBERS_COLLECTION = "0:0E41DC1DC3C9067ED24248580E12B3359818D83DEE0304FABCF80845EAFAFDB2"
const NUMBERS_INITIAL_BIDDER = "0:1A84310D165735881DACF505E69D77313C27AD4AC81A1B82246A43473EED9760"
const NUMBERS_OWNER = "0:3A9CFE127594AC05E7BCE307845691488B2260E238E65005AC1A26F9FE094532"

get fun `test fragment numbers item decodes real collection deploy body`() {
    val txHash = "whrz17mYtLyhZS0We3OjeZjtGyafqiSLlEASe5mS8go=";
    val txLt = "33926188000005";
    val bodyBoc = "te6cckEBBQEA1AAEVSmaPhWAA1CGIaLK5rEDtZ6gvNOu5ieE9alZA0NwRI1IaOfdsuwKLhm4PAEBAgMEABwLODg4MDI0MzE5NTQBAABiAWh0dHBzOi8vbmZ0LmZyYWdtZW50LmNvbS9udW1iZXIvODg4MDI0MzE5NTQuanNvbgBrgAgRtHZRbYDLSyfCByJNN1VTi/GV14GNOz4VV3VlUyStai4ZuDwAouGbg8AAoAABwgABJ1AQAEsABQBkgAgRtHZRbYDLSyfCByJNN1VTi/GV14GNOz4VV3VlUyStcKq2AAM=";
    val decoded = FragmentNumbersItemDeploy.fromCell(parseCellFromBase64(bodyBoc));
    val auctionConfig = decoded.auctionConfig.load();
    val royalty = decoded.royaltyParams.load();

    expect(decoded.senderAddress).toEqual(address(NUMBERS_INITIAL_BIDDER));
    expect(decoded.bid).toEqual(99000000000);
    expect(decoded.tokenInfo.hash()).toBeGreater(0);
    expect(decoded.nftContent.hash()).toBeGreater(0);
    expect(auctionConfig.beneficiaryAddress).toEqual(address("0:408DA3B28B6C065A593E10391269BAAA9C5F8CAEBC0C69D9F0AABBAB2A99256B"));
    expect(auctionConfig.initialMinBid).toEqual(99000000000);
    expect(auctionConfig.maxBid).toEqual(99000000000);
    expect(auctionConfig.minBidStep).toEqual(5);
    expect(auctionConfig.minExtendTime).toEqual(3600);
    expect(auctionConfig.duration).toEqual(604800);
    expect(royalty.numerator).toEqual(5);
    expect(royalty.denominator).toEqual(100);
    expect(royalty.destination!).toEqual(address("0:408DA3B28B6C065A593E10391269BAAA9C5F8CAEBC0C69D9F0AABBAB2A99256B"));

    println("FRAGMENT_NUMBERS_ITEM_DEPLOY_TX={} LT={} BODY={}", txHash, txLt, decoded);
}

get fun `test fragment numbers item decodes real transfer responses`() {
    val txHash = "nnwT4ADErzzpCjNcP0jC+Vm4x9bi00q+eZ0Gn5SLzAE=";
    val txLt = "51916254000001";
    val transferBoc = "te6cckEBAgEAWgABoV/MPRQAAAAAZ1/5fYAHU5/CTrKVgLz3nGDwitIpEWRMHEccygC1g0TfP8EoplAAahDENFlc1iB2s9QXmnXcxPCetSsgaG4IkakNHPu2XYAgPAEACAAAAAAvzGpo";
    val assignedBoc = "te6cckEBAgEANwABWwUTjZEAAAAAZ1/5fYADUIYhosrmsQO1nqC8067mJ4T1qVkDQ3BEjUho592y7BwBAAgAAAAAe71KXw==";
    val excessBoc = "te6cckEBAQEADgAAGNUydtsAAAAAZ1/5fcH44UY=";
    val transfer = FragmentNumbersItemTransfer.fromCell(parseCellFromBase64(transferBoc));
    val assigned = FragmentNumbersItemOwnershipAssigned.fromCell(parseCellFromBase64(assignedBoc));
    val excess = FragmentNumbersItemExcesses.fromCell(parseCellFromBase64(excessBoc));

    expect(transfer.queryId).toEqual(assigned.queryId);
    expect(transfer.queryId).toEqual(excess.queryId);
    expect(transfer.queryId).toEqual(1734343037);
    expect(transfer.newOwnerAddress).toEqual(address(NUMBERS_OWNER));
    expect(transfer.responseDestination).toEqual(address(NUMBERS_INITIAL_BIDDER));
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(1);
    expect(assigned.previousOwnerAddress!).toEqual(address(NUMBERS_INITIAL_BIDDER));
    expect(transfer.forwardPayload.remainingBitsCount()).toEqual(2);
    expect(transfer.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(assigned.forwardPayload.remainingBitsCount()).toEqual(2);
    expect(assigned.forwardPayload.remainingRefsCount()).toEqual(1);

    println("FRAGMENT_NUMBERS_ITEM_TRANSFER_TX={} LT={} TRANSFER={} ASSIGNED={} EXCESS={}", txHash, txLt, transfer, assigned, excess);
}

get fun `test fragment numbers item decodes real auction settlement notifications`() {
    val txHash = "whrz17mYtLyhZS0We3OjeZjtGyafqiSLlEASe5mS8go=";
    val txLt = "33926188000005";
    val assignedBoc = "te6cckEBAQEAHAAAMwUTjZEAAB7bDmJjBQcCT7wqLhm4PADHTyNv7howQA==";
    val fillUpBoc = "te6cckEBAQEADgAAGDcP7FEAAB7bDmJjBaP/qTM=";
    val assigned = FragmentNumbersItemOwnershipAssigned.fromCell(parseCellFromBase64(assignedBoc));
    val fillUp = FragmentNumbersItemFillUp.fromCell(parseCellFromBase64(fillUpBoc));

    expect(assigned.previousOwnerAddress).toBeNull();
    expect(fillUp.queryId).toEqual(33926188000005);
    expect(assigned.queryId).toEqual(33926188000005);

    println("FRAGMENT_NUMBERS_ITEM_SETTLEMENT_TX={} LT={} ASSIGNED={} FILL_UP={}", txHash, txLt, assigned, fillUp);
}
