import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_farm_collection.types"

fun loadReferencedForwardPayload(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();
    val body = payload.loadRef();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
    return body;
}

get fun `test decodes real stonfi farm collection stake notification`() {
    val txHash = "BvswshfSqGWh+gSo3HztJD2jQ7PzYYWMkI3ULuYiQ8E=";
    val txLt = "59380399000007";
    val body = parseCellFromBase64(
        "te6cckEBAgEAPQABZnNi0JwAAAAclxcTW1W2bMGDaAEIHTdNvlCrO1Bt8XEVh7zGnvi4CmpLd2wDk+HGU1tzFwEACW7J3GUgJ7MNyg==",
    );
    val decoded = StonfiFarmCollectionJettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val stake = StonfiFarmStakeForwardPayload.fromCell(
        loadReferencedForwardPayload(mutate forwardPayload),
    );

    expect(decoded.queryId).toEqual(122793956187);
    expect(decoded.amount).toEqual(392566675510);
    expect(decoded.senderAddress).toEqual(
        address("kQCEDpum3yhVnag2-LiKw95jT3xcBTUlu7YByfDjKa25i1mX"),
    );
    expect(stake.ownerAddress).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_FARM_COLLECTION_STAKE_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real stonfi farm collection unstake request`() {
    val txHash = "j1RrtLRbTfkGRVjLAR7Q1wLs8L9CFELziiyc3aZU6SQ=";
    val txLt = "52161292000003";
    val body = parseCellFromBase64(
        "te6cckEBCAEAqgABiKExJJYAAAC+WpOXngAAAAAAAAANAAAAAGcRCLZgHm5C16Z4AZiFboA9aiiwhQ/sPSVnUj/S2sUSRyqhjRp3B7D3O8pdAQIBzQIDAgEgBAUCASAGBwAmAAAAAAAAAAAAAAAAAAAABMF4ZgAmAAAAAAAAAAAAAAAAAAAAAylm/QAmAAAAAAAAAAAAAAAAAAAAJIPMSgAmAAAAAAAAAAAAAAAAAAAAAEjW+pajHns=",
    );
    val decoded = StonfiFarmCollectionUnstakeRequest.fromCell(body);

    expect(decoded.queryId).toEqual(817563408286);
    expect(decoded.itemIndex).toEqual(13);
    expect(decoded.stakeDate).toEqual(1729169590);
    expect(decoded.stakedTokens).toEqual(2091182291559);
    expect(decoded.ownerAddress).toEqual(
        address("0:CC42B7401EB514584287F61E92B3A91FE96D6289239550C68D3B83D87B9DE52E"),
    );
    expect(decoded.claimedPerUnitRoot).toBeNotNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_FARM_COLLECTION_UNSTAKE_REQUEST_TX={} LT={}", txHash, txLt);
}
