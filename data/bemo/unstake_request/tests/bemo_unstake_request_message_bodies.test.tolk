import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bemo_unstake_request.types"

const HISTORICAL_OWNER = "0:87822C5EF0E61E65C75C7E22DA0904BD4141F018160A88160DFFE06157669112"
const EXPECTED_DEPLOY_BODY_HASH = 0x548e32cdf3ed12ed9b1acb0d9513854032e11e2c7e36d06dddeb5a2ea7f7acd5
const EXPECTED_UNSTAKE_BODY_HASH = 0x2b4d76e3c99fbc20e5c893b87d01a0dda331e7afea55c9690393c59c6b7543d5

get fun `test bemo unstake request decodes real deploy body`() {
    val txHash = "zblrsqxAQSzbOFDHEVWGCpEUuk1DWsbFOJPTfaUBWyY=";
    val txLt = "81113529000042";
    val bodyBoc = "te6cckEBAQEANQAAZRChznWAEPBFi94cw8y464/EW0Egl6goPgMCwVECwb/8DCrs0iJIcQ9+qocQQC0mohaMCHyXa20=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoUnstakeRequestDeploy.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_DEPLOY_BODY_HASH);
    expect(decoded.ownerAddress).toEqual(address(HISTORICAL_OWNER));
    expect(decoded.withdrawTonAmount).toEqual(948420437);
    expect(decoded.withdrawJettonAmount).toEqual(948044137);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.lockupTimestamp).toEqual(1780574400);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_UNSTAKE_REQUEST_DEPLOY_TX={} LT={}", txHash, txLt);
}

get fun `test bemo unstake request decodes real outgoing unstake body`() {
    val txHash = "lr8hY4xgErpO4mLcCu6nggSnlvZOpzRLwWW6nw0dZPc=";
    val txLt = "81491899000003";
    val bodyBoc = "te6cckEBAQEAOQAAbUkqsbMAAAAAAAABi4AQ8EWL3hzDzLjrj8RbQSCXqCg+AwLBUQLBv/wMKuzSIkhxD36qhxBALSh/JIcv";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoUnstakeRequestUnstake.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_UNSTAKE_BODY_HASH);
    expect(decoded.index).toEqual(395);
    expect(decoded.owner).toEqual(address(HISTORICAL_OWNER));
    expect(decoded.tonAmount).toEqual(948420437);
    expect(decoded.jettonAmount).toEqual(948044137);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_UNSTAKE_REQUEST_UNSTAKE_TX={} LT={}", txHash, txLt);
}
