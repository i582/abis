import "@acton/fmt"
import "@acton/testing/expect"
import "../types/dedust_uranus_meme_wallet_v3.types"

const SELL_OWNER_ADDRESS = "0:48F3A7666BCCB7FFC07A863845CF61A36EA10AC1DD08455AE19CEFDA624CEB4C"

get fun `test dedust uranus meme wallet v3 decodes live sell tokens body`() {
    val txHash = "7BdhPFoCtXkfM3adLbDkjnBigvJfK5icuEkwhL2Bmws=";
    val txLt = "82438859000018";
    val bodyBoc = "te6cckEBAQEAOQAAbbdFniyN2V4LAHrGv3L+PVVAewoBAYAJHnTszXmW//gPUMcIuew0bdQhWDuhCKtcM537TEmdaYS2jFHP";
    val decoded = DedustUranusSellTokensMessage.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(10221304230639748799);
    expect(decoded.amount).toEqual(13479829282730144);
    expect(decoded.minimalAmountOut).toEqual(1);
    expect(decoded.excessesTo).toBeNotNull();
    expect(decoded.excessesTo!).toEqual(address(SELL_OWNER_ADDRESS));
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}

get fun `test dedust uranus meme wallet v3 decodes live outgoing sell body`() {
    val txHash = "7BdhPFoCtXkfM3adLbDkjnBigvJfK5icuEkwhL2Bmws=";
    val txLt = "82438859000020";
    val bodyBoc = "te6cckEBAQEAWgAAsGRq1CSN2V4LAHrGv3L+PVVAewoBAYAJHnTszXmW//gPUMcIuew0bdQhWDuhCKtcM537TEmdaZABI86dma8y3/8B6hjhFz2GjbqEKwd0IRVrhnO/aYkzrTC4J6Os";
    val decoded = DedustUranusSellMessage.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(10221304230639748799);
    expect(decoded.amount).toEqual(13479829282730144);
    expect(decoded.minimalAmountOut).toEqual(1);
    expect(decoded.from).toEqual(address(SELL_OWNER_ADDRESS));
    expect(decoded.excessesTo).toBeNotNull();
    expect(decoded.excessesTo!).toEqual(address(SELL_OWNER_ADDRESS));
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}
