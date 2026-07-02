import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_router_v1.types"

const USER_ADDRESS = "0:D4DE482AAF2DD97D97DBC537FE2A7E82C28E629408652E17BCC8EFF8C5843796"
const TOKEN0_WALLET = "0:4EEC921B9D4D56A0D94676016D49C26B39B1D7901A7E153E66033F146A0886F4"
const TOKEN1_WALLET = "0:306CF19A0860B02ECB4079142F34C59A602DABFBCDEE122EA31917152314BCB1"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectCellOpcode(body: cell, expectedOpcode: uint32): void {
    var parsed = body.beginParse();
    expect(parsed.loadUint(32)).toEqual(expectedOpcode);
}

fun loadForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(payload);
    return payloadCell;
}

get fun `test stonfi router v1 decodes toncenter jetton notify with swap payload`() {
    val txHash = "3AaovnjzmtEQeff8y0NaDTOTRf4Er5SlXlcMOTuJEJU=";
    val txLt = "83006575000011";
    val bodyBoc = "te6cckEBAgEAhgABanNi0Jw67C2UhR0eo3BGhA1GidAIAam8kFVeW7L7L7eKb/xU/QWFHMUoEMpcL3mR3/GLCG8tAQCXJZOFYYAJ3ZJDc6mq1BsozsAtqThNZzY68gNPwqfMwGfijUEQ3ogGIIcVADU3kgqry3ZfZfbxTf+Kn6Cwo5ilAhlLhe8yO/4xYQ3lkGpbqXc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiRouterV1JettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val swapPayloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val swapPayload = StonfiRouterV1SwapForwardPayload.fromCell(swapPayloadCell);

    expectCellOpcode(body, 0x7362d09c);
    expectCellOpcode(swapPayloadCell, 0x25938561);
    expect(decoded.queryId).toEqual(4245818664615222947);
    expect(decoded.jettonAmount).toEqual(1240527557664000);
    expect(decoded.fromAddress).toEqual(address(USER_ADDRESS));
    expect(swapPayload.tokenWallet).toEqual(address(TOKEN0_WALLET));
    expect(swapPayload.minOut).toEqual(51397514);
    expect(swapPayload.toAddress).toEqual(address(USER_ADDRESS));
    expect(swapPayload.referralAddress).toBeNull();
    expect(swapPayload.toCell().hash()).toEqual(swapPayloadCell.hash());

    println("STONFI_ROUTER_V1_JETTON_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi router v1 decodes jetton transfer swap forward payload ref`() {
    val bodyHex = "b5ee9c720101020100a90001ac0f8a7ea50000000000000001213a1800ef3b9902a271b2a01c8938a523cfe24e71847aaeb6a620001ed44a77ac0e709d00231a77d7ca0bb285fa160af0597e31d286089f57110c8b663764cb7e71fcd6240814dc938101009b25938561801d1971bdf55bcfad5b19c0c4a539d8e674d0827d847d4f765a0365803b92de938c03e4d59b4b5d00231a77d7ca0bb285fa160af0597e31d286089f57110c8b663764cb7e71fcd62410";
    val body = parseCellFromHex(bodyHex);
    val decoded = StonfiRouterV1JettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val swapPayloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val swapPayload = StonfiRouterV1SwapForwardPayload.fromCell(swapPayloadCell);

    expectCellOpcode(body, 0x0f8a7ea5);
    expectCellOpcode(swapPayloadCell, 0x25938561);
    expect(decoded.queryId).toEqual(1);
    expect(decoded.amount).toEqual(5025);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(175000000);
    expect(swapPayload.minOut).toEqual(2140685575598);
    expect(swapPayload.toAddress).toEqual(decoded.responseDestination);
    expect(swapPayload.referralAddress).toBeNull();
    expect(swapPayload.toCell().hash()).toEqual(swapPayloadCell.hash());
}

get fun `test stonfi router v1 decodes toncenter swap body sent to pool`() {
    val txHash = "3AaovnjzmtEQeff8y0NaDTOTRf4Er5SlXlcMOTuJEJU=";
    val txLt = "83006575000011";
    val bodyBoc = "te6cckEBAgEAggABtSWThWE67C2UhR0eo4Aam8kFVeW7L7L7eKb/xU/QWFHMUoEMpcL3mR3/GLCG8tAAwbPGaCGCwLstAeRQvNMWaYC2r+83uEi6jGRcVIxS8sXBGhA1GidAEAxBDikBAEOAGpvJBVXluy+y+3im/8VP0FhRzFKBDKXC95kd/xiwhvLQ1iWyZg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiRouterV1PoolSwap.fromCell(body);
    val addrs = decoded.addrs.load();

    expectCellOpcode(body, 0x25938561);
    expect(decoded.queryId).toEqual(4245818664615222947);
    expect(decoded.toAddress).toEqual(address(USER_ADDRESS));
    expect(decoded.senderAddress).toEqual(address(TOKEN1_WALLET));
    expect(decoded.jettonAmount).toEqual(1240527557664000);
    expect(decoded.minOut).toEqual(51397514);
    expect(decoded.hasRefAddress).toEqual(0);
    expect(addrs.fromUser).toEqual(address(USER_ADDRESS));
    expectNoTail(addrs.referralAddressTail);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_ROUTER_V1_SWAP_TO_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi router v1 decodes toncenter pay to body from pool`() {
    val txHash = "bEYbY7qygXywYJEnGrikWh9KTsLnfBsbEr+bm3itTeU=";
    val txLt = "83006575000015";
    val bodyBoc = "te6cckEBAgEAfwABY/k7tD867C2UhR0eo4Aam8kFVeW7L7L7eKb/xU/QWFHMUoEMpcL3mR3/GLCG8tjIbhy4AQCPQDM8TkgAndkkNzqarUGyjOwC2pOE1nNjryA0/Cp8zAZ+KNQRDegQAMGzxmghgsC7LQHkULzTFmmAtq/vN7hIuoxkXFSMUvLG43q5YQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiRouterV1PayTo.fromCell(body);
    val params = decoded.params.load();

    expectCellOpcode(body, 0xf93bb43f);
    expect(decoded.queryId).toEqual(4245818664615222947);
    expect(decoded.owner).toEqual(address(USER_ADDRESS));
    expect(decoded.exitCode).toEqual(3326308581);
    expect(decoded.paramsAsRef).toEqual(1);
    expect(params.amount0Out).toEqual(53724388);
    expect(params.token0Address).toEqual(address(TOKEN0_WALLET));
    expect(params.amount1Out).toEqual(0);
    expect(params.token1Address).toEqual(address(TOKEN1_WALLET));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_ROUTER_V1_PAY_TO_FROM_POOL_TX={} LT={}", txHash, txLt);
}
