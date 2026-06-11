import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_lp_account_v1.types"

get fun `test stonfi lp account v1 decodes real add_liquidity body`() {
    val txHash = "9V2rr0seGbTb4edR85LmoLKDSx45l3vGql5oDf1XsVw=";
    val txLt = "37959705000011";
    val bodyBoc = "te6cckEBAQEAGQAALT6+VDEAE8zJp22cpgVLbvZBnkIRgR/Ypr26aA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiLpAccountV1AddLiquidity.fromCell(body);

    expect(decoded.queryId).toEqual(5573191026973862);
    expect(decoded.newAmount0).toEqual(0);
    expect(decoded.newAmount1).toEqual(323984179614);
    expect(decoded.minLpOut).toEqual(555225597);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_LP_ACCOUNT_V1_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi lp account v1 decodes real cb_add_liquidity body`() {
    val txHash = "9V2rr0seGbTb4edR85LmoLKDSx45l3vGql5oDf1XsVw=";
    val txLt = "37959705000011";
    val bodyBoc = "te6cckEBAQEAPwAAeVbf64oAE8zJp22cpl6NSlDGxUtu9kGegBU05qWzDJGQbikIyil5wp0VNtBaYxzR5nT6Udj8GeAXKEIwI/uoy3oL";
    val expectedUser = address("EQCppzUtmGSMg3FIRlFLzhToqbaC0xjmjzOn0o7H4M8Aua1t");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiLpAccountV1CbAddLiquidity.fromCell(body);

    expect(decoded.queryId).toEqual(5573191026973862);
    expect(decoded.totalAmount0).toEqual(999999999084);
    expect(decoded.totalAmount1).toEqual(323984179614);
    expect(decoded.userAddress).toEqual(expectedUser);
    expect(decoded.minLpOut).toEqual(555225597);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_LP_ACCOUNT_V1_CB_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}
