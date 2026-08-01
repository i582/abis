import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_escrow_position.types"

const POSITION_ADDRESS = "0:1A29644BA5E9A9B8FAE8FE25902F154C04E9B2EF113EC01FD31E4A45D09F7ED1"
const MINTER_ADDRESS = "0:3349DDD903D5FF139DF8F3F471855A86858DE47CDE9F992D108BE5C58216E926"
const RESOLVER_ADDRESS = "0:F5EEF26012FA502B67623301C1F0F26C2C3ECF96F7CCDAF9F06D9BAD392FD5AC"
const RESOLVER_JETTON_WALLET = "0:7263BF71DA4163834415F19F0F93D0864EA3F1F39E4B883D5CC91DD10CFD6F88"

get fun `test decodes real stonfi escrow position unlock body`() {
    val txHash = "g7vqGwtt11Y6RnkIoNm73elnCQAYCAJsHmDvEPhQvXg=";
    val txLt = "76121956000009";
    val bodyBoc = "te6cckEBAwEAxQACpWlvotgAAAAAagDQkSAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWQAcmO/cdpBY4NEFfGfD5PQhk6j8fOeS4g9XMkd0Qz9b4g/HJdUAQIACTUmXBBAAMmAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWQA9e7yYBL6UCtnYjMBwfDybCw+z5b3zNr58G2brTkv1ayAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWQBHBx9Q=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowPositionInternalUnlock.fromCell(body);
    val unlockArgs = StonfiEscrowPositionBilateralUnlockArgs.fromCell(decoded.unlockArgs);
    val extra = StonfiEscrowPositionUnlockExtraFields.fromCell(decoded.extraFields);

    expect(decoded.queryId).toEqual(1778438289);
    expect(decoded.fillToVault).toBeFalse();
    expect(decoded.refundToVault).toBeFalse();
    expect(decoded.resolver).toEqual(address(RESOLVER_ADDRESS));
    expect(decoded.resolverSentJettonWallet).toEqual(address(RESOLVER_JETTON_WALLET));
    expect(decoded.resolverSentAmount).toEqual(15845749);
    expect(decoded.forwardParams).toBeNull();
    expect(unlockArgs.minOut).toEqual(5400001);
    expect(unlockArgs.ignoreRefundAmount).toEqual(0);
    expect(unlockArgs.signed).toBeNull();
    expect(extra.recipient).toEqual(address(RESOLVER_ADDRESS));
    expect(extra.refundTo).toEqual(address(RESOLVER_ADDRESS));
    expect(extra.excesses).toEqual(address(RESOLVER_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_POSITION={} MINTER={}", POSITION_ADDRESS, MINTER_ADDRESS);
    println("STONFI_ESCROW_POSITION_UNLOCK_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real cron trigger body accepted by escrow positions`() {
    val txHash = "UgqiuESvrmL8OjCmmzQX+mv/4OQ1f2quGMjh5qjEuIE=";
    val txLt = "82015997000001";
    val bodyBoc = "te6cckEBAQEALAAAUyEUcC2ADEx6Hv7vk6JFFw3qswL4BGXkP6MPJLY9teXY3XBKh8/fQHr/8GETgH8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowPositionCronTrigger.fromCell(body);

    expect(decoded.rewardAddress).toEqual(
        address("0:6263D0F7F77C9D1228B86F559817C0232F21FD187925B1EDAF2EC6EB82543E7E"),
    );
    expect(decoded.salt).toEqual(4194555903);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_POSITION_CRON_TRIGGER_TX={} LT={}", txHash, txLt);
}
