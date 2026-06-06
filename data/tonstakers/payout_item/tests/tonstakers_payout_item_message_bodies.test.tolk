import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonstakers_payout_item.types"

const EXPECTED_INIT_BODY_HASH = 0xc577ce44861cf88052786db50f910f8eee67b591fbe9b777028eafde371465b8
const EXPECTED_OWNERSHIP_ASSIGNED_BODY_HASH = 0x209c25655b48a2d4e9a69a0d03d5cbba14cbe36d1238d80cd78ac1ad560b814f
const EXPECTED_QUERY_ID = 6083770388084608433
const EXPECTED_OWNER_ADDRESS = "0:3b6ce64fb8fa5e405e5f67c93de74a9933d59f483aa7d9658fb3a124591ebc66"
const EXPECTED_PREVIOUS_ITEM_ADDRESS = "0:947c68ba8b89634ab3651baadfdc18deaa9d4866ede3c280fba543a6eced5fc2"
const EXPECTED_NEXT_ITEM_ADDRESS = "0:0c22da75619a246898749e0a0c145924222601ea6ac6a471d5095d78bb758caa"
const EXPECTED_AMOUNT = 1789290689

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test tonstakers payout item decodes real incoming init body`() {
    val txHash = "dIk6mE9L2sbKbqrKOn6o7yWHW0nNxkj1jEYwpRHWnj4=";
    val txLt = "81981719000024";
    val bodyBoc = "te6cckEBAQEAdwAA6RMvmkVUbeTvTNLNsYAHbZzJ9x9LyAvL7PknvOlTJnqz6QdU+yyx9nQkiyPXjMjVTNGDACUfGi6i4ljSrNlG6rf3Bjeqp1IZu3jwoD7pUOm7O1fwoABhFtOrDNEjRMOk8FBgoskhETAPU1Y1I46oSuvF26xlVMxqJxw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPayoutItemInit.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_INIT_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.ownerAddress).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(decoded.amount).toEqual(EXPECTED_AMOUNT);
    expect(decoded.previousItemAddress).toEqual(address(EXPECTED_PREVIOUS_ITEM_ADDRESS));
    expect(decoded.nextItemAddress).toEqual(address(EXPECTED_NEXT_ITEM_ADDRESS));

    println("TONSTAKERS_PAYOUT_ITEM_INIT_TX={} LT={}", txHash, txLt);
}

get fun `test tonstakers payout item decodes real outgoing ownership assigned body`() {
    val txHash = "dIk6mE9L2sbKbqrKOn6o7yWHW0nNxkj1jEYwpRHWnj4=";
    val txLt = "81981719000024";
    val bodyBoc = "te6cckEBAQEADwAAGQUTjZFUbeTvTNLNsRBDxuKL";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPayoutItemOwnershipAssigned.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_OWNERSHIP_ASSIGNED_BODY_HASH);
    expect(decoded.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(decoded.previousOwnerAddress).toBeNull();

    var forwardPayload = decoded.forwardPayload;
    expectInlineEmptyForwardPayload(mutate forwardPayload);

    println("TONSTAKERS_PAYOUT_ITEM_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}
