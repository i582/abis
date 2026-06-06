import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_bill.types"

const LIVE_ASSIGN_BODY_HASH = 0xd3357f23c71178a08149607b6c92aa5f0bcd72ad9ce86cd45badd3bea430515a
const LIVE_OWNERSHIP_ASSIGNED_BODY_HASH = 0xb9282f45667322699aa0e0fb7cc89d084e4fbe97ecaf73b7c83e69ce96a795b5
const CANDIDATE_BURN_BODY_HASH = 0xcc7dc16355c2d2a1bda353d70ebec896c4f5c9cd9535bf77f9007544adb0bd09
const CANDIDATE_BILL_BURNED_BODY_HASH = 0x8f95ce50bb6424d325ce03391ba3b6dd987fce0f4879b37441c8c2ab14a74d59

const LIVE_QUERY_ID = 2326822259136878274
const LIVE_AMOUNT = 19654977536
const CANDIDATE_BURN_QUERY_ID = 1712181271
const CANDIDATE_AMOUNT = 4915967133
const HIPO_PARENT_ADDRESS = "EQDPdq8xjAhytYqfGSX8KcFWIReCufsB9Wdg0pLlYSO_h76w"
const LIVE_OWNER_ADDRESS = "EQBF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBL1o"
const CANDIDATE_OWNER_ADDRESS = "EQABg0Ju_Vscg0tK7s4UsDNg267PHNa5s7lGUmnH4aifrD7j"

fun expectInlineEmptyForwardPayload(payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test hipo bill decodes real assign body from live bill item zero`() {
    val txHash = "5lKXppXciws4rjP3i3oFpACGrfk/Vqa5XwfxNX+5B+w=";
    val txLt = "81945672000001";
    val bodyBoc = "te6cckEBAQEAWAAAqzJ138IgSoiEQ1NWwlBJOHKADABF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBIAZ7tXmMYEOVrFT4yS/hTgqxCLwVz9gPqzsGlJcrCR38OIDsBKAyw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoBillAssign.fromCell(body);

    expect(body.hash()).toEqual(LIVE_ASSIGN_BODY_HASH);
    expect(decoded.queryId).toEqual(LIVE_QUERY_ID);
    expect(decoded.amount).toEqual(LIVE_AMOUNT);
    expect(decoded.unstake).toBeTrue();
    expect(decoded.owner).toBeNotNull();
    expect(decoded.owner!).toEqual(address(LIVE_OWNER_ADDRESS));
    expect(decoded.parent).toBeNotNull();
    expect(decoded.parent!).toEqual(address(HIPO_PARENT_ADDRESS));
    expect(decoded.notify).toEqual(1);

    println("HIPO_BILL_ASSIGN_TX={} LT={}", txHash, txLt);
}

get fun `test hipo bill decodes real ownership assigned body from live bill item zero`() {
    val txHash = "5lKXppXciws4rjP3i3oFpACGrfk/Vqa5XwfxNX+5B+w=";
    val txLt = "81945672000001";
    val bodyBoc = "te6cckEBAQEADwAAGQUTjZEgSoiEQ1NWwhDUJXHf";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoBillOwnershipAssigned.fromCell(body);

    expect(body.hash()).toEqual(LIVE_OWNERSHIP_ASSIGNED_BODY_HASH);
    expect(decoded.queryId).toEqual(LIVE_QUERY_ID);
    expect(decoded.previousOwner).toBeNull();
    expectInlineEmptyForwardPayload(decoded.forwardPayload);

    println("HIPO_BILL_OWNERSHIP_ASSIGNED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo bill decodes real burn body from verified same-hash bill`() {
    val txHash = "/Qi038M1LjphNgqpPl7SoF64ANqhJIQyQqyf/Vn/gu0=";
    val txLt = "45656029000006";
    val bodyBoc = "te6cckEBAQEADgAAGG+J9eMAAAAAZg3QF680aoI=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoBillBurn.fromCell(body);

    expect(body.hash()).toEqual(CANDIDATE_BURN_BODY_HASH);
    expect(decoded.queryId).toEqual(CANDIDATE_BURN_QUERY_ID);

    println("HIPO_BILL_BURN_TX={} LT={}", txHash, txLt);
}

get fun `test hipo bill decodes real bill burned body from verified same-hash bill`() {
    val txHash = "/Qi038M1LjphNgqpPl7SoF64ANqhJIQyQqyf/Vn/gu0=";
    val txLt = "45656029000006";
    val bodyBoc = "te6cckEBAQEAXwAAuYQPY2kAAAAAZg3QF1ASUDtJ3AABg0Ju/Vscg0tK7s4UsDNg267PHNa5s7lGUmnH4aifrIAZ7tXmMYEOVrFT4yS/hTgqxCLwVz9gPqzsGlJcrCR38OAAAAAAAAAAEFU2TLQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoBillBurned.fromCell(body);

    expect(body.hash()).toEqual(CANDIDATE_BILL_BURNED_BODY_HASH);
    expect(decoded.queryId).toEqual(CANDIDATE_BURN_QUERY_ID);
    expect(decoded.amount).toEqual(CANDIDATE_AMOUNT);
    expect(decoded.unstake).toBeTrue();
    expect(decoded.owner).toBeNotNull();
    expect(decoded.owner!).toEqual(address(CANDIDATE_OWNER_ADDRESS));
    expect(decoded.parent).toBeNotNull();
    expect(decoded.parent!).toEqual(address(HIPO_PARENT_ADDRESS));
    expect(decoded.index).toEqual(0);

    println("HIPO_BILL_BILL_BURNED_TX={} LT={}", txHash, txLt);
}
