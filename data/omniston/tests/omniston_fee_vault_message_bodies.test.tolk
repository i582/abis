import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/omniston_fee_vault.types"

const ZERO_ADDRESS = "0:0000000000000000000000000000000000000000000000000000000000000000"
const FEE_RECIPIENT = "0:224073DC87D1100361226D9A1CCEAA89D1B8249BD9B9B22C6013B35D2170FB4B"
const JETTON_SENDER = "0:CAEC65D0A002F9B28FE45217BEA6397B1AA5CCD92FFEAC972710E3D722F8D1BB"
const JETTON_ROUTE_ADDRESS = "0:EEF80EBB1632D78F853296BA761AED383C6BF2CCE2481A96B211650C821B2BFD"
const NATIVE_ROUTE_ADDRESS = "0:C2E0641BED5DDD1A4B170F6AC446CE87E077ADD2B05626E4EE539F800B9B032C"
const WRAPPED_NATIVE_ROUTE_ADDRESS = "0:29B6EEA77F3660F1AEFA2B0918CC80FD1CB4C5D1A57C6655A0AA2B5F0426AE03"
const PTON_REFUND_ADDRESS = "0:9C25FD8A1651FDC48C77773B72B71C51164DCA419284601AFE7F49C520ED61DD"
const PTON_ROUTE_ADDRESS = "0:BF939175D0B8D858D0AEDFE056D06566802A37EEF745B058B938A5BA226982D7"
const PTON_FEE_RECIPIENT = "0:19F7A368E4B047CDC583ADA6D62BCC2B5D24F49FE6B34D43F25BF0822A00DB73"
const ROUTE_TAG = 0x1a3c2fc3
const SUCCESS_EXIT_CODE = 56647

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

fun expectInlineResultCode(mutate payload: RemainingBitsAndRefs, expectedExitCode: uint32): void {
    expect(payload.remainingBitsCount()).toEqual(33);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.loadUint(32)).toEqual(expectedExitCode);
    expectNoTail(payload);
}

fun expectFeeShares(
    shares: OmnistonFeeShareConfig,
    expectedRecipient: address,
    expectedShareBps: uint16,
): void {
    expect(shares.recipient0).toEqual(expectedRecipient);
    expect(shares.shareBps0).toEqual(expectedShareBps);
    expect(shares.recipient1).toEqual(address(ZERO_ADDRESS));
    expect(shares.shareBps1).toEqual(0);
    expect(shares.recipient2).toEqual(address(ZERO_ADDRESS));
    expect(shares.shareBps2).toEqual(0);
}

fun expectJettonRoutePayload(payload: OmnistonJettonFeePayload): void {
    expect(payload.successDestination).toEqual(address(JETTON_ROUTE_ADDRESS));
    expect(payload.errorDestination).toEqual(address(JETTON_ROUTE_ADDRESS));
    expect(payload.responseDestination).toEqual(address(JETTON_ROUTE_ADDRESS));
    expectFeeShares(payload.feeShares.load(), address(FEE_RECIPIENT), 50);
}

fun expectNativeRoutePayload(
    payload: OmnistonNativeFeePayload,
    expectedRouteAddress: address,
    expectedFeeRecipient: address,
    expectedShareBps: uint16,
): void {
    expect(payload.routeTag).toEqual(ROUTE_TAG);
    expect(payload.successDestination).toEqual(expectedRouteAddress);
    expect(payload.errorDestination).toEqual(expectedRouteAddress);
    expect(payload.contextAddress).toEqual(expectedRouteAddress);
    expectFeeShares(payload.feeShares.load(), expectedFeeRecipient, expectedShareBps);
}

get fun `test omniston fee vault decodes toncenter jetton fee notification`() {
    val txHash = "nQpMUU9rFepByTGohTae/Me3LLyxWMTMgO2WmTVbEMs=";
    val txLt = "85448712000001";
    val bodyBoc = "te6cckECAwEAARAAAWhzYtCcCqs3O1vPzbJgO73r60V4AZXYy6FABfNlH8ikL31McvY1S5myX/1ZLk4hx65F8aN3AQHRGjwvw4Ad3wHXYsZa8fCmUtdOw12nB41+WZxJA1LWQiyhkENlf7ADu+A67FjLXj4Uylrp2Gu04PGvyzOJIGpayEWUMghsr/YAd3wHXYsZa8fCmUtdOw12nB41+WZxJA1LWQiyhkENlf7AAgDVgARIDnuQ+iIAbCRNs0OZ1VE6NwSTezc2RYwCdmukLh9pYAZQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEDZLgeh";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonJettonFeeNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val payload = OmnistonJettonFeePayload.fromCell(payloadCell);

    expectCellOpcode(body, 0x7362d09c);
    expect(decoded.queryId).toEqual(768768889479744946);
    expect(decoded.amount).toEqual(4105430807639);
    expect(decoded.sender).toEqual(address(JETTON_SENDER));
    expectJettonRoutePayload(payload);
    expect(payload.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_JETTON_FEE_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter native fee distribution`() {
    val txHash = "PjYkkrrQhtc3mpGe7vmcvguumDaWYcRX+7zx55x+Iv8=";
    val txLt = "85448523000019";
    val bodyBoc = "te6cckEBAwEA6QABGUdPhs+Sq6XFrz2zj8ABAdEaPC/DgBhcDIN9q7ujSWLh7ViI2dD8DvW6VgrE3J3Kc/ABc2BlkAMLgZBvtXd0aSxcPasRGzofgd63SsFYm5O5Tn4ALmwMsgBhcDIN9q7ujSWLh7ViI2dD8DvW6VgrE3J3Kc/ABc2BlkACANWABEgOe5D6IgBsJE2zQ5nVUTo3BJN7NzZFjAJ2a6QuH2lgBlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQJj8zQk=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonNativeFeeDistribution.fromCell(body);

    expectCellOpcode(body, 0x474f86cf);
    expect(decoded.queryId).toEqual(10568723219022197647);
    expect(decoded.route).toBeNotNull();
    expectNativeRoutePayload(decoded.route!.load(), address(NATIVE_ROUTE_ADDRESS), address(FEE_RECIPIENT), 50);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_NATIVE_FEE_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter wrapped native distribution`() {
    val txHash = "PD/9SdjoUTg+wNbAqsbIqULBvVMqJ6R8AazpQOvM74c=";
    val txLt = "85448075000027";
    val bodyBoc = "te6cckEBAwEA6AABGMD/7jYNZhSIif5PSAEB0Ro8L8OABTbd1O/mzB4130VhIxmQH6OWmLo0r4zKtBVFa+CE1cBwAKbbup382YPGu+isJGMyA/Ry0xdGlfGZVoKorXwQmrgOABTbd1O/mzB4130VhIxmQH6OWmLo0r4zKtBVFa+CE1cBwAIA1YAESA57kPoiAGwkTbNDmdVROjcEk3s3NkWMAnZrpC4faWAGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA4D0yVw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonWrappedNativeFeeDistribution.fromCell(body);

    expectCellOpcode(body, 0xc0ffee36);
    expect(decoded.queryId).toEqual(965481746780802888);
    expectNativeRoutePayload(decoded.payload.load(), address(WRAPPED_NATIVE_ROUTE_ADDRESS), address(FEE_RECIPIENT), 50);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_WRAPPED_NATIVE_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter pton transfer`() {
    val txHash = "4E9F/+qhszxmTLFctrYjM5crjoVMteWTBxN6VS7oYA4=";
    val txLt = "85442071000034";
    val bodyBoc = "te6cckECAwEAAQ8AAWYB84NdrPwVbtj5OBhQ19l0fogBOEv7FCyj+4kY7u525W44oiyblIMlCMA1/P6TikHaw7sBAdEaPC/DgBfyci66FxsLGhXb/AraDKzQBUb93ui2CxcnFLdETTBa8AL+TkXXQuNhY0K7f4FbQZWaAKjfu90WwWLk4pboiaYLXgBfyci66FxsLGhXb/AraDKzQBUb93ui2CxcnFLdETTBa8ACANWAAz70bRyWCPm4sHW02sV5hWuknpP81mmofkt+EEVAG25gAVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQKkk4Ws=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonPtonTonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val routeCell = loadForwardPayloadRef(mutate forwardPayload);
    val route = OmnistonNativeFeePayload.fromCell(routeCell);

    expectCellOpcode(body, 0x01f3835d);
    expect(decoded.queryId).toEqual(12464861434485487640);
    expect(decoded.tonAmount).toEqual(57941641192);
    expect(decoded.refundAddress).toEqual(address(PTON_REFUND_ADDRESS));
    expectNativeRoutePayload(route, address(PTON_ROUTE_ADDRESS), address(PTON_FEE_RECIPIENT), 10);
    expect(route.toCell().hash()).toEqual(routeCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_PTON_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter vault deposit`() {
    val txHash = "nQpMUU9rFepByTGohTae/Me3LLyxWMTMgO2WmTVbEMs=";
    val txLt = "85448712000001";
    val bodyBoc = "te6cckEBAQEANQAAZW2C0qQKqzc7W8/NslBMeDg3aAHd8B12LGWvHwplLXTsNdpweNflmcSQNS1kIsoZBDZX+8xrMAo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonVaultDeposit.fromCell(body);

    expectCellOpcode(body, 0x6d82d2a4);
    expect(decoded.queryId).toEqual(768768889479744946);
    expect(decoded.amount).toEqual(20527154038);
    expect(decoded.responseDestination).toEqual(address(JETTON_ROUTE_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_VAULT_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter jetton transfer`() {
    val txHash = "nQpMUU9rFepByTGohTae/Me3LLyxWMTMgO2WmTVbEMs=";
    val txLt = "85448712000001";
    val bodyBoc = "te6cckEBAQEAXAAAtA+KfqUKqzc7W8/NsmA7cXOzDhgB3fAddixlrx8KZS107DXacHjX5ZnEkDUtZCLKGQQ2V/sAO74DrsWMtePhTKWunYa7Tg8a/LM4kgalrIRZQyCGyv9AAADdR8hTaE8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonJettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expectCellOpcode(body, 0x0f8a7ea5);
    expect(decoded.queryId).toEqual(768768889479744946);
    expect(decoded.amount).toEqual(4084903653601);
    expect(decoded.destination).toEqual(address(JETTON_ROUTE_ADDRESS));
    expect(decoded.responseDestination).toEqual(address(JETTON_ROUTE_ADDRESS));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expectInlineResultCode(mutate forwardPayload, SUCCESS_EXIT_CODE);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter native result bodies`() {
    val txHash = "PjYkkrrQhtc3mpGe7vmcvguumDaWYcRX+7zx55x+Iv8=";
    val txLt = "85448523000019";
    val excessesBodyBoc = "te6cckEBAQEADgAAGDfTr56Sq6XFrz2zj2H4ktc=";
    val resultBodyBoc = "te6cckEBAQEAEgAAIEw+EteSq6XFrz2zjwAA3UcuFUpg";
    val excessesBody = parseCellFromBase64(excessesBodyBoc);
    val resultBody = parseCellFromBase64(resultBodyBoc);
    val excesses = OmnistonNativeTonExcesses.fromCell(excessesBody);
    val result = OmnistonNativeTonPayResult.fromCell(resultBody);

    expectCellOpcode(excessesBody, 0x37d3af9e);
    expect(excesses.queryId).toEqual(10568723219022197647);
    expect(excesses.toCell().hash()).toEqual(excessesBody.hash());

    expectCellOpcode(resultBody, 0x4c3e12d7);
    expect(result.queryId).toEqual(10568723219022197647);
    expect(result.exitCode).toEqual(SUCCESS_EXIT_CODE);
    expect(result.toCell().hash()).toEqual(resultBody.hash());

    println("OMNISTON_FEE_VAULT_NATIVE_RESULT_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter wrapped native result bodies`() {
    val txHash = "PD/9SdjoUTg+wNbAqsbIqULBvVMqJ6R8AazpQOvM74c=";
    val txLt = "85448075000027";
    val excessesBodyBoc = "te6cckEBAQEADgAAGHBQKTMNZhSIif5PSLSxY8c=";
    val resultBodyBoc = "te6cckEBAQEAEgAAIGSnhH4NZhSIif5PSAAA3UfXkynr";
    val excessesBody = parseCellFromBase64(excessesBodyBoc);
    val resultBody = parseCellFromBase64(resultBodyBoc);
    val excesses = OmnistonWrappedNativeExcesses.fromCell(excessesBody);
    val result = OmnistonWrappedNativeResult.fromCell(resultBody);

    expectCellOpcode(excessesBody, 0x70502933);
    expect(excesses.queryId).toEqual(965481746780802888);
    expect(excesses.toCell().hash()).toEqual(excessesBody.hash());

    expectCellOpcode(resultBody, 0x64a7847e);
    expect(result.queryId).toEqual(965481746780802888);
    expect(result.exitCode).toEqual(SUCCESS_EXIT_CODE);
    expect(result.toCell().hash()).toEqual(resultBody.hash());

    println("OMNISTON_FEE_VAULT_WRAPPED_RESULT_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter pton result bodies`() {
    val txHash = "4E9F/+qhszxmTLFctrYjM5crjoVMteWTBxN6VS7oYA4=";
    val txLt = "85442071000034";
    val excessesBodyBoc = "te6cckEBAQEADgAAGAE0O1Ws/BVu2Pk4GF/OaPQ=";
    val resultBodyBoc = "te6cckEBAQEAEgAAIAzTQ0+s/BVu2Pk4GAAA3UflYDzR";
    val excessesBody = parseCellFromBase64(excessesBodyBoc);
    val resultBody = parseCellFromBase64(resultBodyBoc);
    val excesses = OmnistonPtonFeeExcesses.fromCell(excessesBody);
    val result = OmnistonPtonFeeResult.fromCell(resultBody);

    expectCellOpcode(excessesBody, 0x01343b55);
    expect(excesses.queryId).toEqual(12464861434485487640);
    expect(excesses.toCell().hash()).toEqual(excessesBody.hash());

    expectCellOpcode(resultBody, 0x0cd3434f);
    expect(result.queryId).toEqual(12464861434485487640);
    expect(result.exitCode).toEqual(SUCCESS_EXIT_CODE);
    expect(result.toCell().hash()).toEqual(resultBody.hash());

    println("OMNISTON_FEE_VAULT_PTON_RESULT_TX={} LT={}", txHash, txLt);
}

get fun `test omniston fee vault decodes toncenter excesses body`() {
    val txHash = "BkMvuDCyOJCzbq9zkBY9t0fkDOus8l1wH5Y5AwSQo5o=";
    val txLt = "85450279000024";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtu4s8h8mOm5B3WuK6c=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = OmnistonExcesses.fromCell(body);

    expectCellOpcode(body, 0xd53276db);
    expect(decoded.queryId).toEqual(13309201761276901639);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("OMNISTON_FEE_VAULT_EXCESSES_TX={} LT={}", txHash, txLt);
}
