import "@acton/fmt"
import "@acton/testing/expect"
import "../types/dedust_uranus_meme_v3.types"

const BUY_EXCESSES_ADDRESS = "0:0B21844BB597AD901305B72B6CD63957ECE1B1CF62F036E71E5DB9CB184E77D5"
const SELL_OWNER_ADDRESS = "0:48F3A7666BCCB7FFC07A863845CF61A36EA10AC1DD08455AE19CEFDA624CEB4C"

get fun `test dedust uranus meme v3 decodes live init meme body`() {
    val txLt = "82453926000024";
    val bodyBoc = "te6cckEBAQEAFAAAI3lvWgwAAAAAaidXI1ASoF8gApdF25U=";
    val decoded = DedustUranusInitMeme.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(1780963107);
    expect(decoded.initialBuy).toEqual(5000000000);
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}

get fun `test dedust uranus meme v3 decodes live buy body`() {
    val txHash = "eul6CTrihrTHp5fu18CT0AceI5zWBomj+jAFWWgPOz8=";
    val txLt = "82438803000002";
    val bodyBoc = "te6cckEBAQEAPAAAc5SCZVeN2V4LAHrGqEO5rKAHA2PIbMkXsoABZDCJdrL1sgJgtuVtmscq/Zw2OexeBtzjy7c5YwnO+qQAV3oC";
    val decoded = DedustUranusBuyMessage.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(10221304230639748776);
    expect(decoded.amount).toEqual(1000000000);
    expect(decoded.minimalAmountOut).toEqual(954137399859122);
    expect(decoded.excessesTo).toEqual(address(BUY_EXCESSES_ADDRESS));
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}

get fun `test dedust uranus meme v3 decodes live buy event body`() {
    val txHash = "eul6CTrihrTHp5fu18CT0AceI5zWBomj+jAFWWgPOz8=";
    val txLt = "82438803000004";
    val bodyBoc = "te6cckEBAQEASgAAj6Cqa8KAAWQwiXay9bICYLblbZrHKv2cNjnsXgbc48u3OWMJzvqodul5dOB3wjfsn42mFtTEYPOIIBAEPKVwVhXCkqOmRWCKSOXztkU=";
    val decoded = DedustUranusBuyEvent.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.traderAddress).toEqual(address(BUY_EXCESSES_ADDRESS));
    expect(decoded.amountIn).toEqual(997506234);
    expect(decoded.amountOut).toEqual(1053408364919917);
    expect(decoded.fees.creatorFee).toEqual(748130);
    expect(decoded.fees.protocolFee).toEqual(498753);
    expect(decoded.fees.partnerFee).toEqual(0);
    expect(decoded.fees.referrerFee).toEqual(0);
    expect(decoded.currentSupply).toEqual(152650388326768969);
    expect(decoded.raisedFunds).toEqual(125395731538);
    expect(decoded.isGraduated).toBeFalse();
}

get fun `test dedust uranus meme v3 decodes live compact buy callback body`() {
    val txLt = "82457690000004";
    val bodyBoc = "te6cckEBAQEADgAAGGbIrXKN2V4LAHrmkcs/bH4=";
    val decoded = DedustUranusOpcode66c8ad72.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(10221304230639756945);
}

get fun `test dedust uranus meme v3 decodes live sell body`() {
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

get fun `test dedust uranus meme v3 decodes live sell event body`() {
    val txHash = "8ZPNsCaxzdt2r/+RbYSiRxcary17mvhp2Y2YynzVFwA=";
    val txLt = "82438859000022";
    val bodyBoc = "te6cckEBAQEASwAAkTqw/MyACR507M15lv/4D1DHCLnsNG3UIVg7oQirXDOd+0xJnWmOX8eqqA9hQKBV/7dqxwgwSGsCAwAQAqZtMbyBaIiiKIJMtRB643Og";
    val decoded = DedustUranusSellEvent.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.traderAddress).toEqual(address(SELL_OWNER_ADDRESS));
    expect(decoded.amountIn).toEqual(13479829282730144);
    expect(decoded.amountOut).toEqual(11542575958);
    expect(decoded.fees.creatorFee).toEqual(8656932);
    expect(decoded.fees.protocolFee).toEqual(5771288);
    expect(decoded.fees.partnerFee).toEqual(0);
    expect(decoded.fees.referrerFee).toEqual(0);
    expect(decoded.currentSupply).toEqual(95480047296623684);
    expect(decoded.raisedFunds).toEqual(74156500392);
}
