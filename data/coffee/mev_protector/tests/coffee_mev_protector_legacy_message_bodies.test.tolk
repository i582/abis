import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/coffee_mev_protector_legacy.types"

get fun `test legacy coffee mev protector decodes real hold funds message`() {
    val txHash = "FVqMMpFOUL5WMpZEbDcgjWhIQCbxNOcZohUMLGAgdds=";
    val txLt = "55143836000003";
    val messageHash = "QO5r8FwIoCwgrpqked5p0DyoYesRPzVbVoD8bhMP+Dw=";
    val bodyBoc = "te6cckEBAQEADgAAGGvHnn4AAAAAAAAD6fjDYHI=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = CoffeeMevProtectorLegacyHoldFunds.fromCell(body);

    expect(decoded.queryId).toEqual(1001);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "COFFEE_MEV_PROTECTOR_LEGACY_HOLD_TX={} LT={} MESSAGE={}",
        txHash,
        txLt,
        messageHash,
    );
}

get fun `test legacy coffee mev protector decodes real signed external batch`() {
    val txHash = "vMYaHnDJj9w2AiHBosP4kMRlwEX8zoZJ8emrM86RkjY=";
    val txLt = "55143840000001";
    val messageHash = "oOpNYrvnb0cp/oAhMfyouldKpQTnJfgLp1kcPjw/iXE=";
    val bodyBoc = "te6cckECBwEAAgUAAZnQ+zzlD8FqhBdW0sQhoeT2JtaOTHHbx0eC6x6l5jPnPOXOipknWAPsTt4CUBoNeDJsRuBNi+fTzJRjHHmU0EkGAAAAG2fbPAAAAAPpwAEBB6AAAgcCAcxiAFGJR2gaoPyltarGxAKK6JDrTC9Xk6P6V9PWPjo0k5ZVoTEtAAAAAAAAAAAAAAAAAAAAAfODXQAWB/AAAH0hQCYloAgBPy10U0m0WeN56oui2f2jIKSe1UKM9SJbtzOdzK0JOzkDAeFmZN4qgADq/Pgbzi6a24D50qaMRmy//tNLnCIrR70C6l9uo9xkcAJ+Wuimk2izxvPVF0Wz+0ZBST2qhRnqRLduZzuZWhJ2cgBPy10U0m0WeN56oui2f2jIKSe1UKM9SJbtzOdzK0JOzgAAAAAz7Z3uQAQBXVMh5jxcKAFjoOGT+HiXiGkhk/YJUOR4jZ1zPlBe7M8H6i13WxrycoI8NGAQAAAQBQHhZmTeKoAZ5UipIAE53kC1iJ1CFHM3WW93gLkimmBv7R07w+sTS7ACflroppNos8bz1RdFs/tGQUk9qoUZ6kS3bmc7mVoSdnIAT8tdFNJtFnjeeqLotn9oyCkntVCjPUiW7czncytCTs4AAAAAM+2d7kAGAFExnU1YAT8tdFNJtFnjeeqLotn9oyCkntVCjPUiW7czncytCTs4AAAAEMNOJ50=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = CoffeeMevProtectorLegacySignedBatch.fromCell(body);
    val actionLookup = decoded.payload.get(1);

    expect(decoded.subwalletId).toEqual(27);
    expect(decoded.queryId).toEqual(7483641176503878633);
    expect(actionLookup.isFound).toBeTrue();
    val action = actionLookup.loadValue();
    expect(action.mode).toEqual(3);
    expect(action.message.beginParse().remainingBitsCount()).toBeGreater(0);

    println(
        "COFFEE_MEV_PROTECTOR_LEGACY_EXTERNAL_TX={} LT={} MESSAGE={}",
        txHash,
        txLt,
        messageHash,
    );
}

get fun `test legacy coffee mev protector accepts a real empty internal body`() {
    val txHash = "kpkV4Gi4WWm1QgQL5q1jspB9KCnukYy9Ac+eaEjSdCA=";
    val txLt = "55567467000001";
    val messageHash = "58923GqA2LHhre0oQW1aEOX2pa4CAI1yeuarxr5A87o=";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc).beginParse();

    expect(body.remainingBitsCount()).toEqual(0);
    expect(body.remainingRefsCount()).toEqual(0);

    println(
        "COFFEE_MEV_PROTECTOR_LEGACY_EMPTY_TX={} LT={} MESSAGE={}",
        txHash,
        txLt,
        messageHash,
    );
}
