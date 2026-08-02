import "@acton/fmt"
import "@acton/testing/expect"
import "../types/frt_gram_coordinator.types"

// Message bodies from mainnet trace 342e6948e4bdf520e18cf54991545b4d58d88872ed58f5128198c52e90199b37,
// pinned to blocks 83536149-83536151.

const ROUTE_DESTINATION = "EQCcSVxmNtWGfJ3lcNXU93YgDIHuAMcTlJBMBbx-NTjFq3rp"

get fun `test frt gram coordinator decodes real route request`() {
    val bodyBoc = "te6cckEBAQEADQAAFpofDAkAAwAAAVoGH27VwQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramCoordinatorRouteRequest.fromCell(body);

    expect(decoded.routeIndex).toEqual(3);
    expect(decoded.sequence).toEqual(346);
    expect(decoded.action).toEqual(6);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram coordinator decodes real dispatch`() {
    val bodyBoc = "te6cckEBAQEAVQAApZofDAoAAwAAAVoGgBOJK4zG2rDPk7yuGrqe7sQBkD3AGOJykgmAt4/Gpxi1aSoF8gEAJxJXGY21YZ8neVw1dT3diAMge4AxxOUkEwFvH41OMWrwWLA9LA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramCoordinatorDispatch.fromCell(body);

    expect(decoded.routeIndex).toEqual(3);
    expect(decoded.sequence).toEqual(346);
    expect(decoded.action).toEqual(6);
    expect(decoded.destination).toEqual(address(ROUTE_DESTINATION));
    expect(decoded.amount).toEqual(2500000000);
    expect(decoded.responseAddress).toEqual(address(ROUTE_DESTINATION));
    expect(decoded.callbackEnabled).toBeTrue();
    expect(decoded.payload.remainingBitsCount()).toEqual(0);
    expect(decoded.payload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram coordinator decodes real completion callback`() {
    val bodyBoc = "te6cckEBAQEACwAAEZofDA2gwv+1VEFSkEA=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramCoordinatorCallback.fromCell(body);

    expect(decoded.success).toBeTrue();
    expect(decoded.amount).toEqual(408942250);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
