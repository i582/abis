import "@acton/fmt"
import "@acton/testing/expect"
import "../types/stakee_validator_controller.types"

const EXPECTED_VALIDATOR = "kf-jsqsCp82dEbxMnZCGuXmM5FinQCk5JgRK69LpGnhQMekw"
const EXPECTED_POOL = "0:F6FF877DD4CE1355B101572045F09D54C29309737EB52CA542CFA6C195F7CC5B"
const EXPECTED_GOVERNOR = "0:DBB056B1C99111A8C55F792E012351255329E88145CCEB6F80AAE4DB87BD4230"

get fun `test stakee validator controller decodes real loan request bodies`() {
    val incoming = StakeeValidatorControllerSendRequestLoan.fromCell(parseCellFromBase64("te6cckEBAQEAIAAAPGM1sRoAAAAAaiXT7HAiGyYt2AAHA41+pMaAAAA+QlSOxOY="));
    val outgoing = StakeeValidatorControllerPoolRequestLoan.fromCell(parseCellFromBase64("te6cckEBAwEA0gABPOZCyWUAAAAAaiXT7HAiGyYt2AAHA41+pMaAAAA+QgEB0QAAAACf9HZVYFT5s6I3iZOyENcvMZyLFOgFJyTAiV16XSNPCgYwA9v+HfdTOE1WxAVcgRfCdVMKTCXN+tSylQs+mwZX3zFuAG3YK1jkyIjUYq+8lwCRqJKplPRAouZ1t8BVcm3D3qEYQAIAhYAIPHD0z5w/cg+t7I1TlVl+A9KnkivEWrFQGWo0nbHS1dABB44emfOH7kH1vZGqcqsvwHpU8kV4i1YqAy1Gk7Y6Wro9Uf/I"));
    val staticData = outgoing.controllerData.load();

    expect(incoming.queryId).toEqual(1780863980);
    expect(incoming.minLoan).toEqual(600000000000000);
    expect(incoming.maxLoan).toEqual(1000000000000000);
    expect(incoming.maxInterest).toEqual(15938);
    expect(outgoing.queryId).toEqual(incoming.queryId);
    expect(outgoing.minLoan).toEqual(incoming.minLoan);
    expect(outgoing.maxLoan).toEqual(incoming.maxLoan);
    expect(outgoing.maxInterest).toEqual(incoming.maxInterest);
    expect(staticData.controllerId).toEqual(0);
    expect(staticData.validator).toEqual(address(EXPECTED_VALIDATOR));
    expect(staticData.pool).toEqual(address(EXPECTED_POOL));
    expect(staticData.governor).toEqual(address(EXPECTED_GOVERNOR));
}

get fun `test stakee validator controller decodes real credit and repayment bodies`() {
    val credit = StakeeValidatorControllerCredit.fromCell(parseCellFromBase64("te6cckEBAQEAFgAAJxaQxgQAAAAAaiXT7HA44hao3bao8lEQPQ=="));
    val repayment = StakeeValidatorControllerPoolLoanRepayment.fromCell(parseCellFromBase64("te6cckEBAQEADgAAGN/consAAAAAAAAAAOrQUms="));

    expect(credit.queryId).toEqual(1780863980);
    expect(credit.creditAmount).toEqual(1000699102878570);
    expect(repayment.queryId).toEqual(0);
}
