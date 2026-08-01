import "@acton/fmt"
import "@acton/testing/expect"
import "../types/wallet_v5r1.types"

const ACTION_SEND_MSG = 0x0ec3c86d
const MULTI_ACTION_SIGNED_BODY_HASH = 0xd6cf1f06b4804bcec2cfb3476a073a83d5e978351ec4675154277a73a84826bc
const UNSIGNED_BODY_HASH = 0x22f90b3e76af2849fadec1c72a9eca3dea95198c53af267c44436b8cd5762976
const FIRST_MESSAGE_BOC = "te6ccgEBAQEANQAAZkIAa5yKA/gbStnXmg2U1Zib1GE01YSPACHaGA0K0BpBRw4cxLQAAAAAAAAAAAAAAAAAAA=="
const SECOND_MESSAGE_BOC = "te6ccgEBAQEANQAAZkIAa5yKA/gbStnXmg2U1Zib1GE01YSPACHaGA0K0BpBRw4aYloAAAAAAAAAAAAAAAAAAA=="
const UNSIGNED_BODY_BOC = "te6ccgEBBgEAkgABIXNpZ25///8RZQECAwECAwSgAQIKDsPIbQMCAwIKDsPIbQMEBQBmQgBrnIoD+BtK2deaDZTVmJvUYTTVhI8AIdoYDQrQGkFHDhpiWgAAAAAAAAAAAAAAAAAAAAAAZkIAa5yKA/gbStnXmg2U1Zib1GE01YSPACHaGA0K0BpBRw4cxLQAAAAAAAAAAAAAAAAAAA=="
const SIGNED_BODY_BOC = "te6ccgEBBgEA0gABoXNpZ25///8RZQECAwECAwSlWkRi5/zRwsZ28tPUQCHU7CCo6AcjNFpReeXP0ixGZ2q6Vx7XT7IJNsSy2cvza+cvPGjdEFZELIa26XMGx/CD4AECCg7DyG0DAgMCCg7DyG0DBAUAZkIAa5yKA/gbStnXmg2U1Zib1GE01YSPACHaGA0K0BpBRw4aYloAAAAAAAAAAAAAAAAAAAAAAGZCAGucigP4G0rZ15oNlNWYm9RhNNWEjwAh2hgNCtAaQUcOHMS0AAAAAAAAAAAAAAAAAAA="
const SIGNATURE_HEX = "9569118b9ff3470b19dbcb4f51008753b082a3a01c8cd16945e7973f48b1199daae95c7b5d3ec824db12cb672fcdaf9cbcf1a374415910b21adba5cc1b1fc20f"

fun assertSendMessageAction(mutate action: slice): (cell, cell) {
    expect(action.loadUint(32)).toEqual(ACTION_SEND_MSG);
    expect(action.loadUint(8)).toEqual(3);
    val previous = action.loadRef();
    val message = action.loadRef();
    expect(action.remainingBitsCount()).toEqual(0);
    expect(action.remainingRefsCount()).toEqual(0);
    return (previous, message);
}

get fun `test wallet v5r1 preserves public order of a fixed multi action body`() {
    val body = parseCellFromBase64(SIGNED_BODY_BOC);
    val decoded = WalletSignedExternalV5r1.fromCell(body);

    expect(body.hash()).toEqual(MULTI_ACTION_SIGNED_BODY_HASH);
    expect(decoded.walletId).toEqual(0x7fffff11);
    expect(decoded.validUntil).toEqual(0x65010203);
    expect(decoded.seqno).toEqual(0x01020304);
    expect(decoded.outActions).toBeNotNull();
    expect(decoded.extendedActions).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    // C5 is stored newest-first: the root is the second public action and its
    // first reference points to the first public action.
    var newest = decoded.outActions!.beginParse();
    val (previousCell, secondMessage) = assertSendMessageAction(mutate newest);
    var previous = previousCell.beginParse();
    val (emptyList, firstMessage) = assertSendMessageAction(mutate previous);

    expect(emptyList.beginParse().remainingBitsCount()).toEqual(0);
    expect(emptyList.beginParse().remainingRefsCount()).toEqual(0);
    expect(firstMessage.hash()).toEqual(parseCellFromBase64(FIRST_MESSAGE_BOC).hash());
    expect(secondMessage.hash()).toEqual(parseCellFromBase64(SECOND_MESSAGE_BOC).hash());
}

get fun `test wallet v5r1 unsigned body omits placeholder and signature is final 512 bits`() {
    val unsigned = parseCellFromBase64(UNSIGNED_BODY_BOC);
    val signed = parseCellFromBase64(SIGNED_BODY_BOC);

    expect(unsigned.hash()).toEqual(UNSIGNED_BODY_HASH);
    expect(unsigned.beginParse().remainingBitsCount()).toEqual(130);
    expect(unsigned.beginParse().remainingRefsCount()).toEqual(1);
    expect(signed.hash()).toEqual(MULTI_ACTION_SIGNED_BODY_HASH);
    expect(signed.beginParse().remainingBitsCount()).toEqual(642);
    expect(signed.beginParse().remainingRefsCount()).toEqual(1);

    var unsignedFields = unsigned.beginParse();
    expect(unsignedFields.loadUint(32)).toEqual(0x7369676e);
    expect(unsignedFields.loadUint(32)).toEqual(0x7fffff11);
    expect(unsignedFields.loadUint(32)).toEqual(0x65010203);
    expect(unsignedFields.loadUint(32)).toEqual(0x01020304);
    expect(unsignedFields.loadBool()).toBeTrue();
    val unsignedActions = unsignedFields.loadRef();
    expect(unsignedFields.loadBool()).toBeFalse();
    expect(unsignedFields.remainingBitsCount()).toEqual(0);
    expect(unsignedFields.remainingRefsCount()).toEqual(0);

    var signedFields = signed.beginParse();
    val actualSignature = signedFields.getLastBits(512);
    signedFields.removeLastBits(512);
    val signedPrefix = beginCell().storeSlice(signedFields).endCell();
    val actualSignatureCell = beginCell().storeSlice(actualSignature).endCell();
    val expectedSignatureCell = beginCell().storeSlice(SIGNATURE_HEX.hexToSlice()).endCell();

    expect(signedPrefix.hash()).toEqual(unsigned.hash());
    expect(actualSignatureCell.hash()).toEqual(expectedSignatureCell.hash());

    val decoded = WalletSignedExternalV5r1.fromCell(signed);
    expect(decoded.outActions).toBeNotNull();
    expect(decoded.outActions!.hash()).toEqual(unsignedActions.hash());
    expect(decoded.extendedActions).toBeNull();
}
