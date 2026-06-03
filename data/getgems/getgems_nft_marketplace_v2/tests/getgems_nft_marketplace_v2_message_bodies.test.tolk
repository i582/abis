import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "@acton/types/message"
import "../types/getgems_nft_marketplace_v2.types"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadSingleSignedExternalActionMessage(
    mutate stream: RemainingBitsAndRefs,
    expectedMode: int,
): TlbMessageRelaxed<RemainingBitsAndRefs> {
    expect(stream.remainingBitsCount()).toEqual(8);
    expect(stream.remainingRefsCount()).toEqual(1);
    expect(stream.loadUint(8)).toEqual(expectedMode);

    val messageCell = stream.loadRef();
    expectNoTail(mutate stream);

    return (messageCell as Cell<TlbMessageRelaxed<RemainingBitsAndRefs>>).load({
        assertEndAfterReading: false,
    });
}

fun loadAndCheckInternalMessageBody(
    message: TlbMessageRelaxed<RemainingBitsAndRefs>,
    expectedDestination: address,
    expectedValue: int,
    expectedOpcode: int,
    expectedBodyBits: int,
    expectedBodyRefs: int,
): RemainingBitsAndRefs {
    expect(message.info.bounce).toBeTrue();
    expect(message.info.bounced).toBeFalse();
    expect(message.info.dest).toEqual(expectedDestination);
    expect(message.info.value.grams).toEqual(expectedValue);

    var body = message.loadBody();
    expect(body.remainingBitsCount()).toEqual(expectedBodyBits);
    expect(body.remainingRefsCount()).toEqual(expectedBodyRefs);
    expect(body.preloadUint(32)).toEqual(expectedOpcode);
    return body;
}

fun expectCancelOfferBody(mutate body: RemainingBitsAndRefs): void {
    expect(body.remainingBitsCount()).toEqual(68);
    expect(body.remainingRefsCount()).toEqual(1);
    expect(body.loadUint(32)).toEqual(0x00000003);
    expect(body.loadCoins()).toEqual(34000000);

    val ownerPayloadCell = body.loadRef();
    expectNoTail(mutate body);

    var ownerPayload = ownerPayloadCell.beginParse();
    expect(ownerPayload.remainingBitsCount()).toEqual(816);
    expect(ownerPayload.remainingRefsCount()).toEqual(0);
    expect(ownerPayload.loadUint(32)).toEqual(0);
    expect(ownerPayload.loadUint(64)).toEqual(0x43616e63656c206f);
    expect(ownerPayload.loadUint(64)).toEqual(0x6666657220536361);
    expect(ownerPayload.loadUint(16)).toEqual(0x7265);
    expect(ownerPayload.remainingBitsCount()).toEqual(640);
    expect(ownerPayload.remainingRefsCount()).toEqual(0);
}

fun expectEmergencyProxyBody(mutate body: RemainingBitsAndRefs): void {
    expect(body.remainingBitsCount()).toEqual(96);
    expect(body.remainingRefsCount()).toEqual(1);
    expect(body.loadUint(32)).toEqual(0x0000022b);
    expect(body.loadUint(64)).toEqual(8549106353021481429);

    val actionCell = body.loadRef();
    expectNoTail(mutate body);

    var action = actionCell.beginParse();
    expect(action.remainingBitsCount()).toEqual(8);
    expect(action.remainingRefsCount()).toEqual(1);
    expect(action.loadUint(8)).toEqual(3);

    val rawMessageCell = action.loadRef();
    expectNoTail(mutate action);

    val rawMessage = (rawMessageCell as Cell<TlbMessageRelaxed<RemainingBitsAndRefs>>).load({
        assertEndAfterReading: false,
    });
    val expectedDestination = address("0:69B3B41322CC1A9983D2B9DA15D5403EDD891EC292FB6010488F7938B990E684");
    var nftTransfer = loadAndCheckInternalMessageBody(
        rawMessage,
        expectedDestination,
        90000000,
        0x5fcc3d14,
        644,
        0,
    );

    expect(nftTransfer.loadUint(32)).toEqual(0x5fcc3d14);
    expect(nftTransfer.loadUint(64)).toEqual(8549106350062479961);
    expect(nftTransfer.loadAddress()).toEqual(
        address("0:2F36BFB18DB18731595C64B23D19DD6582CCA0F36C6DE39306E3483407C7C169"),
    );
    expect(nftTransfer.loadAddress()).toEqual(
        address("0:584EE61B2DFF0837116D0FCB5078D93964BCBE9C05FD6A141B1BFCA5D6A43E18"),
    );
    expect(nftTransfer.loadBool()).toBeFalse();
    expect(nftTransfer.loadCoins()).toEqual(1);
    expect(nftTransfer.loadBool()).toBeFalse();
    expectNoTail(mutate nftTransfer);
}

get fun `test getgems marketplace v2 decodes toncenter signed external cancel action body`() {
    val txHash = "lKLWf1IctqxAXezRYVjd/YGLdBNlMEH4a+2BLEKPeKo=";
    val txLt = "81351902000030";
    val bodyBoc = "te6cckEBAwEA+AABmid5cQfC04V1dNddMFOV8TLeoB6cj3etzm9o+HjnLCF9hakogYPNUN019ESuYSG1szekENjNvcMOHP7k8wZaMQIAAAAAaiCP6wABYmwCAQF5YgBUKTjb9TLbbTxoTJ/Vvd5nHHlUHGMCUMO7OXZvPiBErSAOThwAAAAAAAAAAAAAAAAAAAAAAANAIGzICAIAzAAAAABDYW5jZWwgb2ZmZXIgU2NhcmVkIENhdCAjOTU5Njog0J3QtSDRgdC/0LDRgdC40LHQviAsINC80L3QtSDRjdGC0LggMTcwINGC0L7QvSDQvdC4INCyINC/0LjQt9C00YMgKcnpQdg=";
    val expectedDestination = address("0:A85271B7EA65B6DA78D0993FAB7BBCCE38F2A838C604A1877672ECDE7C40895A");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftMarketplaceV2SignedExternal.fromCell(body);
    var stream = decoded.messages;

    expect(decoded.subwalletId).toEqual(0);
    expect(decoded.validUntil).toEqual(1780518891);
    expect(decoded.seqno).toEqual(90732);

    val message = loadSingleSignedExternalActionMessage(mutate stream, 2);
    var forwardedBody = loadAndCheckInternalMessageBody(
        message,
        expectedDestination,
        30000000,
        0x00000003,
        68,
        1,
    );
    expectCancelOfferBody(mutate forwardedBody);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_SIGNED_CANCEL_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter signed external emergency proxy body`() {
    val txHash = "1rQw8odTi/E8MzLvVjfNsCUdRuwGM6N71cBPD5mNmHY=";
    val txLt = "81281238000001";
    val bodyBoc = "te6cckECBQEAASEAAZoyL6ASQN51/SdsMmgKasZKvZ7vo3jF7yNyffc/7ZEILz/d2vImP4rAWHHxb3/TAjIjlyFSFcp5FVA8PIbh8iMJAAAAAGogIgAAAWJnAwEBgGIACIoRY1HhPLG7DJKBK9uowzurBHJu7wN7NfrXjreOHNUgNHO8AAAAAAAAAAAAAAAAAAAAAAIrdqSG7tbhcdUCAQIDAwFoYgA02doJkWYNTMHpXO0K6qAfbsSPYUl9sAgkR7ycXMhzQiAq6lQAAAAAAAAAAAAAAAAAAQQAoV/MPRR2pIbuJoKqWYAF5tf2MbYw5isrjJZHozussFmUHm2NvHJg3GkGgPj4LTABYTuYbLf8INxFtD8tQeNk5ZLy+nAX9ahQbG/yl1qQ+GAgKHPxrUI=";
    val expectedDestination = address("0:111422C6A3C279637619250257B75186775608E4DDDE06F66BF5AF1D6F1C39AA");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftMarketplaceV2SignedExternal.fromCell(body);
    var stream = decoded.messages;

    expect(decoded.subwalletId).toEqual(0);
    expect(decoded.validUntil).toEqual(1780490752);
    expect(decoded.seqno).toEqual(90727);

    val message = loadSingleSignedExternalActionMessage(mutate stream, 3);
    var forwardedBody = loadAndCheckInternalMessageBody(
        message,
        expectedDestination,
        110000000,
        0x0000022b,
        96,
        1,
    );
    expectEmergencyProxyBody(mutate forwardedBody);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_SIGNED_EMERGENCY_PROXY_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter signed external stop text body`() {
    val txHash = "1ou9McQlFB6/awt0V4njsqB0Gu4+j5FWumBco+fnI8I=";
    val txLt = "81277949000008";
    val bodyBoc = "te6cckEBAgEAjgABmgNFe+Ll2nEDvq2Q+zFFcw1b8o34iPjhrhKAZxJiG0TMOQy0yKhB2QWcXeslbRHz7mSOBjUu3U+sHxW/vOqw8w4AAAAAaiAc4gABYmYDAQB4YgARwyfGwLCmZBy5Oo35/+h7sr+9UZEiisfyqekQ7xKN2qAvrwgAAAAAAAAAAAAAAAAAAAAAAABzdG9wNYbATQ==";
    val expectedDestination = address("0:23864F8D81614CC83972751BF3FFD0F7657F7AA32245158FE553D221DE251BB5");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsNftMarketplaceV2SignedExternal.fromCell(body);
    var stream = decoded.messages;

    expect(decoded.subwalletId).toEqual(0);
    expect(decoded.validUntil).toEqual(1780489442);
    expect(decoded.seqno).toEqual(90726);

    val message = loadSingleSignedExternalActionMessage(mutate stream, 3);
    var forwardedBody = loadAndCheckInternalMessageBody(
        message,
        expectedDestination,
        100000000,
        0x00000000,
        64,
        0,
    );

    expect(forwardedBody.loadUint(32)).toEqual(0);
    expect(forwardedBody.loadUint(32)).toEqual(0x73746f70);
    expectNoTail(mutate forwardedBody);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_SIGNED_STOP_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter incoming cancel fee text body`() {
    val txHash = "4uc46GM1PC9rzFbRhSNYgQPeRj7FmV4rbxkwiTdbMUk=";
    val txLt = "81351902000034";
    val bodyBoc = "te6cckEBAQEAFgAAKAAAAABPZmZlciBjYW5jZWwgZmVlsKlPNg==";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(160);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(parsed.loadUint(32)).toEqual(0);
    expect(parsed.loadUint(64)).toEqual(0x4f66666572206361);
    expect(parsed.loadUint(64)).toEqual(0x6e63656c20666565);
    expectNoTail(mutate parsed);

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_IN_CANCEL_FEE_TEXT_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter incoming excess body`() {
    val txHash = "cJ2DIzOMvhid1XgOwmghbochdfxdkzSuSewSJ/y2xxU=";
    val txLt = "81281238000008";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtt2pIbuJoKqWeje0jM=";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(96);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(parsed.loadUint(32)).toEqual(0xd53276db);
    expect(parsed.loadUint(64)).toEqual(8549106350062479961);
    expectNoTail(mutate parsed);

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_IN_EXCESS_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter incoming bounce text body`() {
    val txHash = "dV4TJVoZdy5MjgVK3lqDFcy52frz/TXixXLMl+Es0Qs=";
    val txLt = "81277949000012";
    val bodyBoc = "te6cckEBAQEADgAAGP////8AAAAAc3RvcBWfRxE=";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(96);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(parsed.loadUint(32)).toEqual(0xffffffff);
    expect(parsed.loadUint(32)).toEqual(0);
    expect(parsed.loadUint(32)).toEqual(0x73746f70);
    expectNoTail(mutate parsed);

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_IN_BOUNCE_TEXT_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter outgoing cancel offer raw body`() {
    val txHash = "lKLWf1IctqxAXezRYVjd/YGLdBNlMEH4a+2BLEKPeKo=";
    val txLt = "81351902000030";
    val bodyBoc = "te6cckEBAgEAdAABEQAAAANAIGzICAEAzAAAAABDYW5jZWwgb2ZmZXIgU2NhcmVkIENhdCAjOTU5Njog0J3QtSDRgdC/0LDRgdC40LHQviAsINC80L3QtSDRjdGC0LggMTcwINGC0L7QvSDQvdC4INCyINC/0LjQt9C00YMgKSPCWq4=";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expectCancelOfferBody(mutate parsed);

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_OUT_CANCEL_OFFER_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter outgoing emergency proxy raw body`() {
    val txHash = "1rQw8odTi/E8MzLvVjfNsCUdRuwGM6N71cBPD5mNmHY=";
    val txLt = "81281238000001";
    val bodyBoc = "te6cckEBBAEAnQABGAAAAit2pIbu1uFx1QEBAgMCAWhiADTZ2gmRZg1Mwelc7QrqoB9uxI9hSX2wCCRHvJxcyHNCICrqVAAAAAAAAAAAAAAAAAABAwChX8w9FHakhu4mgqpZgAXm1/YxtjDmKyuMlkejO6ywWZQebY28cmDcaQaA+PgtMAFhO5hst/wg3EW0Py1B42TlkvL6cBf1qFBsb/KXWpD4YCAooWkQcw==";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expectEmergencyProxyBody(mutate parsed);

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_OUT_EMERGENCY_PROXY_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v2 decodes toncenter outgoing stop text body`() {
    val txHash = "1ou9McQlFB6/awt0V4njsqB0Gu4+j5FWumBco+fnI8I=";
    val txLt = "81277949000008";
    val bodyBoc = "te6cckEBAQEACgAAEAAAAABzdG9wtSN8lg==";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(64);
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(parsed.loadUint(32)).toEqual(0);
    expect(parsed.loadUint(32)).toEqual(0x73746f70);
    expectNoTail(mutate parsed);

    println("GETGEMS_NFT_MARKETPLACE_V2_TONCENTER_OUT_STOP_TEXT_TX={} LT={}", txHash, txLt);
}
