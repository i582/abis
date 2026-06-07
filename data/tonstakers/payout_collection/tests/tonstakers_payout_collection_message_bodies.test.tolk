import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonstakers_payout_collection.types"

const EXPECTED_QUERY_ID = 6083770388084608433
const EXPECTED_OWNER = "0:3B6CE64FB8FA5E405E5F67C93DE74A9933D59F483AA7D9658FB3A124591EBC66"
const EXPECTED_AMOUNT = 1789290689
const EXPECTED_NOTIFICATION_TON = 100000000
const EXPECTED_FORWARD_TON = 0
const EXPECTED_PREV = "0:947C68BA8B89634AB3651BAADFDC18DEAA9D4866EDE3C280FBA543A6ECED5FC2"
const EXPECTED_NEXT = "0:0C22DA75619A246898749E0A0C145924222601EA6AC6A471D5095D78BB758CAA"

fun expectNoTail(tail: slice): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test tonstakers payout collection decodes real incoming mint body`() {
    val txHash = "iwyn09dOLULAlQ6cOeIRGou1Jsv4nS7p/Lnnl3a9aYA=";
    val txLt = "81981719000022";
    val bodyBoc = "te6cckEBAQEAOQAAbRZ0sKBUbeTvTNLNsYAHbZzJ9x9LyAvL7PknvOlTJnqz6QdU+yyx9nQkiyPXjMjVTNGCgL68IAH80Ojq";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPayoutCollectionMintNft.fromCell(body);
    var tail = body.beginParse();

    expect(tail.loadUint(32)).toEqual(0x1674b0a0);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.owner).toEqual(address(EXPECTED_OWNER));
    expect(decoded.amount).toEqual(EXPECTED_AMOUNT);
    expect(decoded.notificationTon).toEqual(EXPECTED_NOTIFICATION_TON);
    expect(decoded.forwardTon).toEqual(EXPECTED_FORWARD_TON);

    tail.loadUint(64);
    tail.loadAddress();
    tail.loadCoins();
    tail.loadCoins();
    tail.loadCoins();
    expectNoTail(mutate tail);

    println("TONSTAKERS_PAYOUT_COLLECTION_MINT_BODY_TX={} LT={}", txHash, txLt);
}

get fun `test tonstakers payout collection decodes real outgoing init nft body`() {
    val txHash = "iwyn09dOLULAlQ6cOeIRGou1Jsv4nS7p/Lnnl3a9aYA=";
    val txLt = "81981719000022";
    val bodyBoc = "te6cckEBAQEAdwAA6RMvmkVUbeTvTNLNsYAHbZzJ9x9LyAvL7PknvOlTJnqz6QdU+yyx9nQkiyPXjMjVTNGDACUfGi6i4ljSrNlG6rf3Bjeqp1IZu3jwoD7pUOm7O1fwoABhFtOrDNEjRMOk8FBgoskhETAPU1Y1I46oSuvF26xlVMxqJxw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPayoutCollectionInitNft.fromCell(body);
    var tail = body.beginParse();

    expect(tail.loadUint(32)).toEqual(0x132f9a45);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.owner).toEqual(address(EXPECTED_OWNER));
    expect(decoded.amount).toEqual(EXPECTED_AMOUNT);
    expect(decoded.prev).toBeNotNull();
    expect(decoded.prev!).toEqual(address(EXPECTED_PREV));
    expect(decoded.next).toBeNotNull();
    expect(decoded.next!).toEqual(address(EXPECTED_NEXT));

    tail.loadUint(64);
    tail.loadAddress();
    tail.loadCoins();
    tail.loadAddress();
    tail.loadAddress();
    expectNoTail(mutate tail);

    println("TONSTAKERS_PAYOUT_COLLECTION_INIT_NFT_BODY_TX={} LT={}", txHash, txLt);
}
