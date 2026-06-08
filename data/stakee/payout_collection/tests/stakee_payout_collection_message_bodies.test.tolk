import "@acton/fmt"
import "@acton/testing/expect"
import "../types/stakee_payout_collection.types"

const EXPECTED_OWNER = "0:E8B913C2CE2504CCB0B5B29B62D4B19D750A3984FD9CC6624626E01094785EA7"
const EXPECTED_PREV = "0:2A3EFB321DCDA0CA0C6FAAEDCE764B350279FF6ABCAF8E9346952E3BEAB512AA"
const EXPECTED_NEXT = "0:855B2C18758F8A058EF85419196B2A9B306C8653BBCE1A164EEC31A75FA87551"

get fun `test stakee payout collection decodes real mint body`() {
    val mint = StakeePayoutCollectionMintNft.fromCell(parseCellFromBase64("te6cckEBAQEAOQAAbRZ0sKAAAAAAAAAAAIAdFyJ4WcSgmZYWtlNsWpYzrqFHMJ+zmMxIxNwCEo8L1OjWVoNSgL68IAF/pFEU"));

    expect(mint.queryId).toEqual(0);
    expect(mint.owner).toEqual(address(EXPECTED_OWNER));
    expect(mint.amount).toEqual(1797996969);
    expect(mint.notificationTon).toEqual(100000000);
    expect(mint.forwardTon).toEqual(0);
}

get fun `test stakee payout collection decodes real outgoing init nft body`() {
    val init = StakeePayoutCollectionInitNft.fromCell(parseCellFromBase64("te6cckEBAQEAdwAA6RMvmkUAAAAAAAAAAIAdFyJ4WcSgmZYWtlNsWpYzrqFHMJ+zmMxIxNwCEo8L1OjWVoNTAAqPvsyHc2gygxvqu3Odks1Ann/aryvjpNGlS476rUSqoAQq2WDDrHxQLHfCoMjLWVTZg2Qynd5w0LJ3YY06/UOqjJ97wxs="));

    expect(init.queryId).toEqual(0);
    expect(init.owner).toEqual(address(EXPECTED_OWNER));
    expect(init.amount).toEqual(1797996969);
    expect(init.prev).toEqual(address(EXPECTED_PREV));
    expect(init.next).toEqual(address(EXPECTED_NEXT));
}
