import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "@acton/types/message"
import "../types/tonkeeper_2fa.types"

const DELEGATION_BODY_HASH = 0x43a1ceceebece5da86f59e9b15478782589fccc79d203e2406145ad8a3ce4de7
const DELEGATION_STATE_INIT_HASH = 0x213cba861c854f558839fa56efa3707ab52146deab4ecf530721ec3761d175a0
const CANCEL_DELEGATION_BODY_HASH = 0x5a008dbfb0f41831f131714b9651c2185323f653cb7991ac824fcd0809e6003e
const SEND_ACTIONS_BODY_HASH = 0x4048cbd3c9c63d81a814ffe2af89b03e6d851a90df126ccdcf6c1a047fd29216
const SEND_ACTIONS_MSG_HASH = 0xedfcc6a58c8d08c340c2f9974df24f05305b33f4116e5c60e0a75d42e0b8ec0a
const WALLET_REQUEST_BODY_HASH = 0x4cf1ce624e0b75fc02b96fc88b20ce847e1ae97269befe177a7d899aadcc2fa6
const WALLET_REQUEST_OUT_ACTION_HASH = 0xb2e6bd50d37b0dbc61df698a543671b75bf68ad04f6ab3d1d423402111d1556f
const WALLET_REQUEST_NESTED_MSG_HASH = 0x5e6ec94321e708f34b5fa668b799d7f5df10c31cc045519c13e3ca8287241cd2
const SEND_ACTIONS_NESTED_DESTINATION = "0:1016DA0F532FB85CD568656850C6D371C48A9F2080A144007F43B836FD36C5F7"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectDelegationPayload(payload: Tonkeeper2faSeedPayload): void {
    match (payload) {
        Tonkeeper2faDelegation => {
            expect(payload.seqno).toEqual(15);
            expect(payload.validUntil).toEqual(1778447516);
            expect(payload.newStateInit.hash()).toEqual(DELEGATION_STATE_INIT_HASH);
            expect(payload.forwardAmount).toEqual(1);
        }
        Tonkeeper2faCancelDelegation => {
            expect(false).toBeTrue();
        }
    }
}

fun expectCancelDelegationPayload(payload: Tonkeeper2faSeedPayload): void {
    match (payload) {
        Tonkeeper2faDelegation => {
            expect(false).toBeTrue();
        }
        Tonkeeper2faCancelDelegation => {
            expect(payload.seqno).toEqual(16);
            expect(payload.validUntil).toEqual(1778447986);
        }
    }
}

fun expectSendActionsPayload(payload: Tonkeeper2faSigned2faPayload): void {
    match (payload) {
        Tonkeeper2faSendActions => {
            expect(payload.seqno).toEqual(25);
            expect(payload.validUntil).toEqual(1780790250);
            expect(payload.mode).toEqual(3);
            expect(payload.msg.hash()).toEqual(SEND_ACTIONS_MSG_HASH);
        }
        Tonkeeper2faRemoveExtension => {
            expect(false).toBeTrue();
        }
    }
}

get fun `test tonkeeper 2fa decodes real delegation seed external body`() {
    val txHash = "MTjgZWyWvqq94eOzNYVg7jyrlpEqLjs3e4Tw72JwstA=";
    val txLt = "76143732000001";
    val bodyBoc = "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";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Tonkeeper2faSignedSeedExternal.fromCell(body);

    expect(body.hash()).toEqual(DELEGATION_BODY_HASH);
    expectDelegationPayload(decoded.payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONKEEPER_2FA_DELEGATION_TX={} LT={}", txHash, txLt);
}

get fun `test tonkeeper 2fa decodes real cancel delegation seed external body`() {
    val txHash = "5D0INMDx359Ru1Wd87VzRca1V+NoLqZmeZi+Vr9kJYU=";
    val txLt = "76145626000003";
    val bodyBoc = "te6cckEBAQEAUgAAoN6CtQEAAAAQAAAAAGoA9nJ5Jac1RArUqpUVLSKMAYPXOW4aq31s6OMHaHLTmgdP0wDPW30proNf8ba1Xh+dkaEnB8D+WUKZP8L8K7s21HQPIFzFkg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Tonkeeper2faSignedSeedExternal.fromCell(body);

    expect(body.hash()).toEqual(CANCEL_DELEGATION_BODY_HASH);
    expectCancelDelegationPayload(decoded.payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONKEEPER_2FA_CANCEL_DELEGATION_TX={} LT={}", txHash, txLt);
}

get fun `test tonkeeper 2fa decodes real send actions 2fa external body`() {
    val txHash = "k14WFjVKRBdzPItigeFr2lTKts8HtMxs+9CX3hslB8g=";
    val txLt = "82027409000003";
    val bodyBoc = "te6cckECCAEAAcsAA6KxXyyMAAAAGQAAAABqJLPqA9q+l2Iq6XCizp4piHt46L32IqFB7fzOm3c6+cH5c/Z5pgj5lXvgGITsZQR7yqrhqPFKsCM592grTj8GamgS/QEBAgMA0AAAAABqRnFlFp/eqWfKRuUnTPbBjKZrcApiaWQKqv35uaiobmZO9ommm47aQxm8zZ3cgbqOap5/lktEbV7th5c3OswqV3MYiVTjebrEA11bJeJNl5pwSNITWEyMxoFxv5OPhsSuXbcCAIBTFYqkOd20D8aunyywVWWQ8RcT7mig7E1Bgu1SaOiUWvfeA8AO5hU71B6sgLtzMCkQBfgX4RPuAEguB5VLhBgJAX9CAEco0MVzStyRAJEpYCnzjoSuzGuEeaRUuktFS/HdS9wzGHS9eAAAAAAAAAAAAAAAAABleHRuAAAAAAAAAACgBAIKDsPIbQMFBgAAAYBiAAgLbQepl9wuarQytChjabjiRU+QQFCiAD+h3Bt+m2L7oC+vCAAAAAAAAAAAAAAAAAAASHqOgXeNPNLx7j5rBwBrgBHKNDFc0rckQCRKWAp846ErsxrhHmkVLpLRUvx3UvcMywAdG/gAsAHRv4AAoAABwhABJ1AQiNPTKw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Tonkeeper2faSigned2faExternal.fromCell(body);

    expect(body.hash()).toEqual(SEND_ACTIONS_BODY_HASH);
    expectSendActionsPayload(decoded.payload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONKEEPER_2FA_SEND_ACTIONS_TX={} LT={}", txHash, txLt);
}

get fun `test tonkeeper 2fa decodes real outgoing wallet request body`() {
    val txHash = "k14WFjVKRBdzPItigeFr2lTKts8HtMxs+9CX3hslB8g=";
    val txLt = "82027409000003";
    val bodyBoc = "te6cckEBBQEAlgABGWV4dG4AAAAAAAAAAKABAgoOw8htAwIDAAABgGIACAttB6mX3C5qtDK0KGNpuOJFT5BAUKIAP6HcG36bYvugL68IAAAAAAAAAAAAAAAAAABIeo6Bd4080vHuPmsEAGuAEco0MVzStyRAJEpYCnzjoSuzGuEeaRUuktFS/HdS9wzLAB0b+ACwAdG/gACgAAHCEAEnUBAhzCXf";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Tonkeeper2faWalletRequestByExtension.fromCell(body);
    var extended = decoded.extendedActions;

    expect(body.hash()).toEqual(WALLET_REQUEST_BODY_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expect(decoded.queryId).toEqual(0);
    expect(decoded.outActions).toBeNotNull();
    expect(decoded.outActions!.hash()).toEqual(WALLET_REQUEST_OUT_ACTION_HASH);
    expect(extended.remainingBitsCount()).toEqual(1);
    expect(extended.loadBool()).toBeFalse();
    expectNoTail(mutate extended);

    var outAction = decoded.outActions!.beginParse();
    outAction.loadRef();
    expect(outAction.loadUint(32)).toEqual(0x0ec3c86d);
    expect(outAction.loadUint(8)).toEqual(3);
    val nestedMessageCell = outAction.loadRef();
    expectNoTail(mutate outAction);
    expect(nestedMessageCell.hash()).toEqual(WALLET_REQUEST_NESTED_MSG_HASH);

    val nestedMessage = (nestedMessageCell as Cell<TlbMessageRelaxed<RemainingBitsAndRefs>>).load({
        assertEndAfterReading: false,
    });
    expect(nestedMessage.info.bounce).toBeTrue();
    expect(nestedMessage.info.bounced).toBeFalse();
    expect(nestedMessage.info.dest).toEqual(address(SEND_ACTIONS_NESTED_DESTINATION));
    expect(nestedMessage.info.value.grams).toEqual(100000000);

    println("TONKEEPER_2FA_WALLET_REQUEST_TX={} LT={}", txHash, txLt);
}
