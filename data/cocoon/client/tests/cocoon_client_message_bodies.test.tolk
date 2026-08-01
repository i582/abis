import "@acton/fmt"
import "@acton/testing/expect"
import "../types/cocoon_client.types"

get fun `test cocoon client decodes real signed charge`() {
    val body = parseCellFromBase64("te6cckEBAgEAqQAB27tj/5PHdqlaBxbT64AHgFpfXFZMYJG0WAdV4YV9ZBHtBRhqj6lQ3DNTHjf1V183gxUneTegK6tiRDGFy+nLwjHHaeiA9r9AZIyoeN6hf5lvQMUfXqh9KrZR+dDwEcBQzyi+kd26bdxi7y/ltcEQAQBru2P/k8d2qVoHFtPrAAAATzhw9vSADHnK/Itu2aC8B9n6Lhy1/EhXM/gHskNaSd+DZVG55wVw8Jj3Iw==");
    val message = CocoonClientChargeSigned.fromCell(body);
    val payload = CocoonClientChargePayload.fromCell(message.signedDataCell);

    expect(message.queryId).toEqual(14372861464930604011);
    expect(payload.queryId).toEqual(14372861464930604011);
    expect(payload.newTokensUsed).toEqual(340249343732);
}

get fun `test cocoon client decodes real top up`() {
    val body = parseCellFromBase64("te6cckEBAQEANQAAZfFy5sLEpSZ7zJiPLVA34R1gCAEDtjMctypYXPOdFQv+KuHCBcLiUHaELyNqCQS9GW2AAwfIbnw=");
    val message = CocoonClientTopUp.fromCell(body);

    expect(message.topUpAmount).toEqual(15000000000);
    expect(message.queryId).toEqual(14169774115746516781);
}

get fun `test cocoon client decodes real owner withdraw`() {
    val body = parseCellFromBase64("te6cckEBAQEAMAAAW9oGjniLPshQ+1rQDoAQO2Mxy3Klhc850VC/4q4cIFwuJQdoQvI2oJBL0ZbYADDOKa/s");
    val message = CocoonClientWithdraw.fromCell(body);

    expect(message.queryId).toEqual(10033677269968015374);
}

get fun `test cocoon client decodes real secret hash change`() {
    val body = parseCellFromBase64("te6cckEBAQEAUAAAm6k1cDSJwbPgK55ksuOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVgBA7YzHLcqWFzznRUL/irhwgXC4lB2hC8jagkEvRltgAMP7TyZo=");
    val message = CocoonClientChangeSecretHash.fromCell(body);

    expect(message.queryId).toEqual(9926412829087130802);
    expect(
        message.newSecretHash,
    ).toEqual(102987336249554097029535212322581322789799900648198034993379397001115665086549);
}

get fun `test cocoon client decodes real registration`() {
    val body = parseCellFromBase64("te6cckEBAQEAOAAAa8RfnzvYDgRVmOvnew8SKSemOpb7gBA7YzHLcqWFzznRUL/irhwgXC4lB2hC8jagkEvRltgAMMRX5/Q=");
    val message = CocoonClientRegister.fromCell(body);

    expect(message.queryId).toEqual(15568385727550711675);
    expect(message.nonce).toEqual(1085975710419031803);
}

get fun `test cocoon client decodes real usage report to proxy`() {
    val body = parseCellFromBase64("te6cckEBAgEAZwABW2VEj/THdqlaBxbT64AQO2Mxy3Klhc850VC/4q4cIFwuJQdoQvI2oJBL0ZbYACgBAGcUB5Vp60FA34R1gAAAABPOHD29OOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVgIJhYNQ==");
    val message = CocoonClientProxyRequest.fromCell(body);
    val state = message.stateData.load();

    expect(message.queryId).toEqual(14372861464930604011);
    expect(state.state).toEqual(0);
    expect(state.balance).toEqual(8142879440);
    expect(state.stake).toEqual(15000000000);
    expect(state.tokensUsed).toEqual(340249343732);
    expect(message.payload).toBeNull();
}

get fun `test cocoon client decodes real top up forwarded to proxy`() {
    val body = parseCellFromBase64("te6cckEBAwEAlQACW2VEj/TEpSZ7zJiPLYAQO2Mxy3Klhc850VC/4q4cIFwuJQdoQvI2oJBL0ZbYADgBAgBnFBQqIL8BQN+EdYAAAAATxAurejjsMRCmPwcFJr79MiZb7kkJ65B5GSbk0yklZkbeFK4VYABVXPxrh1A34R1gCAEDtjMctypYXPOdFQv+KuHCBcLiUHaELyNqCQS9GW2AA9xDInI=");
    val message = CocoonClientProxyRequest.fromCell(body);

    expect(message.payload).toBeNotNull();
    val topUp = CocoonClientProxyTopUp.fromCell(message.payload!);
    expect(message.queryId).toEqual(14169774115746516781);
    expect(topUp.topUpAmount).toEqual(15000000000);
}

get fun `test cocoon client decodes real refund forwarded to proxy`() {
    val body = parseCellFromBase64("te6cckEBAwEAlQACW2VEj/SLPshQ+1rQDoAQO2Mxy3Klhc850VC/4q4cIFwuJQdoQvI2oJBL0ZbYADgBAgBnFA34R1gBQN+EdYAAAAANf60LZjjsMRCmPwcFJr79MiZb7kkJ65B5GSbk0yklZkbeFK4VYABVxo68e1Bf8R7wSAEDtjMctypYXPOdFQv+KuHCBcLiUHaELyNqCQS9GW2AA5pZAcw=");
    val message = CocoonClientProxyRequest.fromCell(body);

    expect(message.payload).toBeNotNull();
    val refund = CocoonClientProxyRefundGranted.fromCell(message.payload!);
    expect(message.queryId).toEqual(10033677269968015374);
    expect(refund.amount).toEqual(25754201860);
}

get fun `test cocoon client decodes real excess acknowledgement`() {
    val body = parseCellFromBase64("te6cckEBAQEADgAAGCVlk0zHdqlaBxbT6wXbUpc=");
    val message = CocoonClientReturnExcesses.fromCell(body);

    expect(message.queryId).toEqual(14372861464930604011);
}
