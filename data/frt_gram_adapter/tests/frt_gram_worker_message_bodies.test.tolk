import "@acton/fmt"
import "@acton/testing/expect"
import "../types/frt_gram_worker.types"

// Message bodies from mainnet trace 342e6948e4bdf520e18cf54991545b4d58d88872ed58f5128198c52e90199b37,
// pinned to blocks 83536149-83536151.

const ROUTE_DESTINATION = "EQCcSVxmNtWGfJ3lcNXU93YgDIHuAMcTlJBMBbx-NTjFq3rp"
const COORDINATOR = "EQAOYIpqiuS0blDySfqSPKHhYoJRRV8RxUHGQUw_hw8WUQth"

get fun `test frt gram worker decodes real step request`() {
    val bodyBoc = "te6cckEBAQEAMQAAXpofDw4AAAFaUBYqXLgIATiSuMxtqwz5O8rhq6nu7EAZA9wBjicpIJgLePxqcYtX/QqK+A==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramWorkerStepRequest.fromCell(body);

    expect(decoded.sequence).toEqual(346);
    expect(decoded.amount).toEqual(5950000000);
    expect(decoded.destination).toEqual(address(ROUTE_DESTINATION));
    expect(decoded.enabled).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test frt gram worker decodes real step result`() {
    val bodyBoc = "te6cckEBAQEAVQAApZofDw8ABwAAAVpQFipcuAgBOJK4zG2rDPk7yuGrqe7sQBkD3AGOJykgmAt4/Gpxi1cAA5gimqK5LRuUPJJ+pI8oeFiglFFXxHFQcZBTD+HDxZRwI2ynig==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FrtGramWorkerStepResult.fromCell(body);

    expect(decoded.routeIndex).toEqual(7);
    expect(decoded.sequence).toEqual(346);
    expect(decoded.amount).toEqual(5950000000);
    expect(decoded.workerAddress).toEqual(address(ROUTE_DESTINATION));
    expect(decoded.destination).toEqual(address(COORDINATOR));
    expect(decoded.enabled).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
