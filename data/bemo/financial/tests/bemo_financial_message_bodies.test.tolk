import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bemo_financial.types"

const ACTIVE_OWNER = "0:1DB686BD9086A0A565FCB51144AD0C85C9B1B92B01E3EE907C828EA89B9C99BE"
const HISTORICAL_OWNER = "0:87822C5EF0E61E65C75C7E22DA0904BD4141F018160A88160DFFE06157669112"

fun expectEmptyBody(body: cell): void {
    val parsed = body.beginParse();
    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);
}

get fun `test bemo financial decodes toncenter empty simple stake body`() {
    val txHash = "ggpJOdUx008CKqArYOx+mSNEUbZ3xyoB+v0FbwtCaM8=";
    val txLt = "81345284000010";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoFinancialEmptyStake.fromCell(body);

    expectEmptyBody(body);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_FINANCIAL_EMPTY_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test bemo financial decodes toncenter burn notification body`() {
    val txHash = "prRey84p5AO1XUERChKxMYAg8ynGwLuOknYsuYpSWuo=";
    val txLt = "81720342000005";
    val bodyBoc = "te6cckEBAQEAVwAAqXvdl94AAAAAAAAAAFF0VY+E2AA7bQ17IQ1BSsv5aiKJWhkLk2NyVgPH3SD5BR1RNzkzfQAHbaGvZCGoKVl/LURRK0MhcmxuSsB4+6QfIKOqJucmb5CiaLZw";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoFinancialBurnNotification.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(99947706445);
    expect(decoded.ownerAddress).toEqual(address(ACTIVE_OWNER));
    expect(decoded.receiverAddress).toEqual(address(ACTIVE_OWNER));
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_FINANCIAL_BURN_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test bemo financial decodes toncenter unstake body`() {
    val txHash = "OPvy8b8FxRpiYWM+2APeRGPe8NG0TxlUxgpHuYjiRIw=";
    val txLt = "81491899000005";
    val bodyBoc = "te6cckEBAQEAOQAAbUkqsbMAAAAAAAABi4AQ8EWL3hzDzLjrj8RbQSCXqCg+AwLBUQLBv/wMKuzSIkhxD36qhxBALSh/JIcv";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoFinancialUnstake.fromCell(body);

    expect(decoded.index).toEqual(395);
    expect(decoded.owner).toEqual(address(HISTORICAL_OWNER));
    expect(decoded.tonAmount).toEqual(948420437);
    expect(decoded.jettonAmount).toEqual(948044137);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_FINANCIAL_UNSTAKE_TX={} LT={}", txHash, txLt);
}

get fun `test bemo financial decodes toncenter deploy unstake request body`() {
    val txHash = "prRey84p5AO1XUERChKxMYAg8ynGwLuOknYsuYpSWuo=";
    val txLt = "81720342000005";
    val bodyBoc = "te6cckEBAQEANwAAaRChznWAA7bQ17IQ1BSsv5aiKJWhkLk2NyVgPH3SD5BR1RNzkzfKLo9snlKi6KsfCaaiVdQIUnAe0Q==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoFinancialDeployUnstakeRequest.fromCell(body);

    expect(decoded.ownerAddress).toEqual(address(ACTIVE_OWNER));
    expect(decoded.withdrawTonAmount).toEqual(99987377961);
    expect(decoded.withdrawJettonAmount).toEqual(99947706445);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.lockupTimestamp).toEqual(1780833600);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_FINANCIAL_DEPLOY_UNSTAKE_REQUEST_TX={} LT={}", txHash, txLt);
}

get fun `test bemo financial decodes toncenter unstake notification body`() {
    val txHash = "OPvy8b8FxRpiYWM+2APeRGPe8NG0TxlUxgpHuYjiRIw=";
    val txLt = "81491899000005";
    val bodyBoc = "te6cckEBAQEADwAAGZDICgcAAAAAAAAAAEBBymVq";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BemoFinancialUnstakeNotification.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BEMO_FINANCIAL_UNSTAKE_NOTIFICATION_TX={} LT={}", txHash, txLt);
}
