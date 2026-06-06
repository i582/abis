import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_collection.types"

const EXPECTED_QUERY_ID = 2326822259136878274
const EXPECTED_AMOUNT = 19654977536
const EXPECTED_OWNER = "EQBF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBL1o"
const EXPECTED_PARENT = "EQDPdq8xjAhytYqfGSX8KcFWIReCufsB9Wdg0pLlYSO_h76w"
const EXPECTED_OWNERSHIP_ASSIGNED_AMOUNT = 1

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectMintOrAssignFields(
    queryId: uint64,
    amount: coins,
    unstake: bool,
    owner: address,
    parent: address,
    ownershipAssignedAmount: coins,
): void {
    expect(queryId).toEqual(EXPECTED_QUERY_ID);
    expect(amount).toEqual(EXPECTED_AMOUNT);
    expect(unstake).toBeTrue();
    expect(owner).toEqual(address(EXPECTED_OWNER));
    expect(parent).toEqual(address(EXPECTED_PARENT));
    expect(ownershipAssignedAmount).toEqual(EXPECTED_OWNERSHIP_ASSIGNED_AMOUNT);
}

get fun `test hipo collection decodes toncenter mint bill body`() {
    val txHash = "e7CfHDWGDRz/leoYQO5HIwwZUyhJXbFcr6Zg50zczw0=";
    val txLt = "81945671000003";
    val bodyBoc = "te6cckEBAQEAWAAAq0steHEgSoiEQ1NWwlBJOHKADABF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBIAZ7tXmMYEOVrFT4yS/hTgqxCLwVz9gPqzsGlJcrCR38OIDPXkg6A==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoCollectionMintBill.fromCell(body);
    var tail = body.beginParse();

    expect(tail.loadUint(32)).toEqual(0x4b2d7871);
    expectMintOrAssignFields(
        decoded.queryId,
        decoded.amount,
        decoded.unstake,
        decoded.owner,
        decoded.parent,
        decoded.ownershipAssignedAmount,
    );
    expect(decoded.toCell().hash()).toEqual(body.hash());

    tail.loadUint(64);
    tail.loadCoins();
    tail.loadInt(1);
    tail.loadAddress();
    tail.loadAddress();
    tail.loadCoins();
    expectNoTail(mutate tail);

    println("HIPO_COLLECTION_MINT_BILL_TX={} LT={}", txHash, txLt);
}

get fun `test hipo collection decodes toncenter assign bill body`() {
    val txHash = "e7CfHDWGDRz/leoYQO5HIwwZUyhJXbFcr6Zg50zczw0=";
    val txLt = "81945671000003";
    val bodyBoc = "te6cckEBAQEAWAAAqzJ138IgSoiEQ1NWwlBJOHKADABF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBIAZ7tXmMYEOVrFT4yS/hTgqxCLwVz9gPqzsGlJcrCR38OIDsBKAyw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoCollectionAssignBill.fromCell(body);
    var tail = body.beginParse();

    expect(tail.loadUint(32)).toEqual(0x3275dfc2);
    expectMintOrAssignFields(
        decoded.queryId,
        decoded.amount,
        decoded.unstake,
        decoded.owner,
        decoded.parent,
        decoded.ownershipAssignedAmount,
    );
    expect(decoded.toCell().hash()).toEqual(body.hash());

    tail.loadUint(64);
    tail.loadCoins();
    tail.loadInt(1);
    tail.loadAddress();
    tail.loadAddress();
    tail.loadCoins();
    expectNoTail(mutate tail);

    println("HIPO_COLLECTION_ASSIGN_BILL_TX={} LT={}", txHash, txLt);
}
