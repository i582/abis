import "@acton/fmt"
import "@acton/testing/expect"
import "../types/stakee_payout_item.types"

const EXPECTED_OWNER = "0:E8B913C2CE2504CCB0B5B29B62D4B19D750A3984FD9CC6624626E01094785EA7"
const EXPECTED_PREV = "0:2A3EFB321DCDA0CA0C6FAAEDCE764B350279FF6ABCAF8E9346952E3BEAB512AA"
const EXPECTED_NEXT = "0:855B2C18758F8A058EF85419196B2A9B306C8653BBCE1A164EEC31A75FA87551"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(1);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test stakee payout item decodes real init body`() {
    val init = StakeePayoutItemInit.fromCell(parseCellFromBase64("te6cckEBAQEAdwAA6RMvmkUAAAAAAAAAAIAdFyJ4WcSgmZYWtlNsWpYzrqFHMJ+zmMxIxNwCEo8L1OjWVoNTAAqPvsyHc2gygxvqu3Odks1Ann/aryvjpNGlS476rUSqoAQq2WDDrHxQLHfCoMjLWVTZg2Qynd5w0LJ3YY06/UOqjJ97wxs="));

    expect(init.queryId).toEqual(0);
    expect(init.ownerAddress).toEqual(address(EXPECTED_OWNER));
    expect(init.amount).toEqual(1797996969);
    expect(init.previousItemAddress).toEqual(address(EXPECTED_PREV));
    expect(init.nextItemAddress).toEqual(address(EXPECTED_NEXT));
}

get fun `test stakee payout item decodes real ownership assigned body`() {
    val assigned = StakeePayoutItemOwnershipAssigned.fromCell(parseCellFromBase64("te6cckEBAQEADwAAGQUTjZEAAAAAAAAAABAk/v7w"));

    expect(assigned.queryId).toEqual(0);
    expect(assigned.previousOwnerAddress).toBeNull();
    expectInlineEmptyForwardPayload(assigned.forwardPayload);
}
