import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_lp_account_v2.types"

get fun `test stonfi lp account v2 decodes early liquidity cb_add_liquidity body`() {
    val txHash = "NaGz1S+REZOwLvVyMKdPf8JsVdjUuipCZoiRFaUxEi4=";
    val txLt = "49987441000001";
    val bodyBoc = "te6cckEBAgEApwABeQbs1ScAAABGewMMykD39JAFC6Q7dACACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KJqYRdpAgBAMmACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KQASyzX6Pz6fgGDwJoBIVAwYBJ7xLzX+6ZhnXFw8urPP5SACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KQJpqCGM=";
    val expectedUser = address("0:4B2CD7E8FCFA7E0183C09A0121503060127BC4BCD7FBA6619D7170F2EACF3F94");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiLpAccountV2CbAddLiquidity.fromCell(body);
    val additionalFields = decoded.additionalFields.load();

    expect(decoded.queryId).toEqual(302711508170);
    expect(decoded.totAm0).toEqual(260000000);
    expect(decoded.totAm1).toEqual(50000000000);
    expect(decoded.userAddress).toEqual(expectedUser);
    expect(decoded.minLpOut).toEqual(3569495762);
    expect(decoded.fwdAmount).toEqual(0);
    expect(decoded.customPayloadCs).toBeNull();
    expect(additionalFields.toUserAddress).toEqual(expectedUser);
    expect(additionalFields.refundAddress).toEqual(expectedUser);
    expect(additionalFields.excessAddress).toEqual(expectedUser);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_LP_ACCOUNT_V2_CB_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}
