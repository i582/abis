import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "@acton/types/message"
import "../types/mytonwallet_2fa.types"

const INSTALL_BODY_HASH = 0x034e2561ca62da080291d8807e4713d9a57f35d8a5c21afd8ce865506ee7bb1d
const INSTALL_WALLET_REQUEST_HASH = 0x6ad9b059a1fe5eb0acf543ef777fb8bc35459c24ac8fc0d04fd5304dff5c7bb0
const SEND_ACTIONS_BODY_HASH = 0x470bdbf2f597b06620d4dfdb9dcb58795167cbbd61a873b00c43cf0d93018b08
const SEND_ACTIONS_MESSAGE_HASH = 0xd51a5c920e2fc75fa6f8389376335af9e7ac89f930ab0c872fd3dc01dc06ff10
const WALLET_REQUEST_BODY_HASH = 0x850197ae5330ad12f2c58d6745b82dcecdbd15d505465174a4d0f33cbad8730e
const WALLET_REQUEST_OUT_ACTION_HASH = 0x9e5251a315f14875b2ea92e0b24478e375dbc4f158b115740fd467d41b32162a
const WALLET_REQUEST_NESTED_MESSAGE_HASH = 0xcb62722b70c4e5bcc5764d9c1e4f2b3fc06dff1f4398df187ee1c79b3204a112
const NESTED_DESTINATION = "EQDqAuCsDYjpqFPNkPKKI2I5vTMyRIvQxhw_ZippTfBzuh_d"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectSendActions(payload: MyTonWallet2faSignedPayload): void {
    match (payload) {
        MyTonWallet2faSendActions => {
            expect(payload.seqno).toEqual(15);
            val action = payload.payload.load();
            expect(action.mode).toEqual(3);
            expect(action.message.hash()).toEqual(SEND_ACTIONS_MESSAGE_HASH);
        }
        MyTonWallet2faRemoveExtension => {
            expect(false).toBeTrue();
        }
    }
}

get fun `test mytonwallet 2fa decodes real install and install wallet request`() {
    val txHash = "FyTxEs8+s2aXb29cbpai5XWjhBDzI0kEOOcHYDOVilU=";
    val txLt = "93393612000003";
    val installBody = parseCellFromBase64("te6cckEBAQEABgAACENWMXSflLNF");
    val install = MyTonWallet2faInstall.fromCell(installBody);
    expect(installBody.hash()).toEqual(INSTALL_BODY_HASH);
    expect(install.toCell().hash()).toEqual(installBody.hash());

    val walletBody = parseCellFromBase64("te6cckEBAQEAEAAAG2V4dG4AAAAAAAAAAEEI5+cjvg==");
    val request = MyTonWallet2faWalletRequestByExtension.fromCell(walletBody);
    var extended = request.extendedActions;
    expect(walletBody.hash()).toEqual(INSTALL_WALLET_REQUEST_HASH);
    expect(request.toCell().hash()).toEqual(walletBody.hash());
    expect(request.queryId).toEqual(0);
    expect(request.outActions).toBeNull();
    expect(extended.loadBool()).toBeTrue();
    expect(extended.loadUint(8)).toEqual(4);
    expect(extended.loadBool()).toBeFalse();
    expect(extended.loadBool()).toBeFalse();
    expectNoTail(extended);

    println("MYTONWALLET_2FA_INSTALL_TX={} LT={}", txHash, txLt);
}

get fun `test mytonwallet 2fa decodes real signed send actions body`() {
    val txHash = "ig7zn8ZDmSHO+5pooCcSHdwvkTkJ4GJNKOF2NASbzcQ=";
    val txLt = "93976124000001";
    val bodyBoc = "te6cckECCAEAAR8AA5CxXyyMAAAAD3CEFWduEi+VXPGz/Ns+Un/7/kl0zOpbLmnfHy44Xw43poVFVQNT7Btym4RYnCJOwFtB/HXgIQii/6Hq+iHEawkBAgMAgP/4HC9eeZb9FixaMS/C9KF8dte9A4KSDdBiOFSFPon78A/9O36Z4qZQorndmdgabqOhZGfqUvxG5tWN7GQiwwUAFDE3ODU2MDg1OTYBAgMEAX9iAHUBcFYGxHTUKebIeUURsRzemZkiRehjDh+zFTSm+DndGG8mOAAAAAAAAAAAAAAAAABleHRuAAAAAAAAAACgBQIKDsPIbQMGBwAAAGBCAHUBcFYGxHTUKebIeUURsRzemZkiRehjDh+zFTSm+DndAAAAAAAAAAAAAAAAAACQVMK4";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MyTonWallet2faSignedExternal.fromCell(body);

    expect(body.hash()).toEqual(SEND_ACTIONS_BODY_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expect(decoded.authDate.hash()).toEqual(
        0x7b20521cf2edf6eb44005172e66fcf2f2458c45ded584ed650c0e0c5fd2d1aa9,
    );
    expectSendActions(decoded.payload);

    println("MYTONWALLET_2FA_SEND_ACTIONS_TX={} LT={}", txHash, txLt);
}

get fun `test mytonwallet 2fa decodes real forwarded wallet request`() {
    val txHash = "ig7zn8ZDmSHO+5pooCcSHdwvkTkJ4GJNKOF2NASbzcQ=";
    val txLt = "93976124000001";
    val bodyBoc = "te6cckEBBAEATQABGWV4dG4AAAAAAAAAAKABAgoOw8htAwIDAAAAYEIAdQFwVgbEdNQp5sh5RRGxHN6ZmSJF6GMOH7MVNKb4Od0AAAAAAAAAAAAAAAAAADzUNmU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MyTonWallet2faWalletRequestByExtension.fromCell(body);
    var extended = decoded.extendedActions;

    expect(body.hash()).toEqual(WALLET_REQUEST_BODY_HASH);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expect(decoded.queryId).toEqual(0);
    expect(decoded.outActions).toBeNotNull();
    expect(decoded.outActions!.hash()).toEqual(WALLET_REQUEST_OUT_ACTION_HASH);
    expect(extended.loadBool()).toBeFalse();
    expectNoTail(extended);

    var action = decoded.outActions!.beginParse();
    action.loadRef();
    expect(action.loadUint(32)).toEqual(0x0ec3c86d);
    expect(action.loadUint(8)).toEqual(3);
    val nestedCell = action.loadRef();
    expectNoTail(action);
    expect(nestedCell.hash()).toEqual(WALLET_REQUEST_NESTED_MESSAGE_HASH);

    val nested = (nestedCell as Cell<TlbMessageRelaxed<RemainingBitsAndRefs>>).load({
        assertEndAfterReading: false,
    });
    expect(nested.info.bounce).toBeFalse();
    expect(nested.info.bounced).toBeFalse();
    expect(nested.info.dest).toEqual(address(NESTED_DESTINATION));
    expect(nested.info.value.grams).toEqual(0);

    println("MYTONWALLET_2FA_WALLET_REQUEST_TX={} LT={}", txHash, txLt);
}
