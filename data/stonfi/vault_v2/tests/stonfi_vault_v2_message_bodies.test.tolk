import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_vault_v2.types"

get fun `test stonfi vault v2 decodes toncenter deposit ref fee body`() {
    val txHash = "TJ9+LE93Bh/LJ6WTuN5KeC4NqduiUAJwRU0Cxf7Xvcc=";
    val txLt = "81508858000013";
    val bodyBoc = "te6cckEBAQEAMwAAYQSQ8JtcgaDaWnTNsTFy+BgBSHt5yl1LjHJ5IuYBl1yx3Km78Ftotg9VM6JHJdgqT8EBBhxE";
    val expectedExcessesAddress = address("0:A43DBCE52EA5C6393C917300CBAE58EE54DDF82DB45B07AA99D12392EC1527E0");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiDepositRefFeeV2.fromCell(body);

    expect(decoded.queryId).toEqual(6665785783165963697);
    expect(decoded.jettonAmount).toEqual(1519489);
    expect(decoded.excessesAddress).toEqual(expectedExcessesAddress);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_VAULT_V2_DEPOSIT_REF_FEE_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi vault v2 decodes toncenter withdraw fee body`() {
    val txHash = "Alw4b/cjKAGuyolQdPsZK2L+1tXqlxxIOxup1SvMuDg=";
    val txLt = "81355457000017";
    val bodyBoc = "te6cckEBAQEADgAAGDVLzfQAAAAAAAAACgxCdeQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiWithdrawFeeV2.fromCell(body);

    expect(decoded.queryId).toEqual(10);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_VAULT_V2_WITHDRAW_FEE_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi vault v2 decodes toncenter vault pay to body`() {
    val txHash = "Alw4b/cjKAGuyolQdPsZK2L+1tXqlxxIOxup1SvMuDg=";
    val txLt = "81355457000017";
    val bodyBoc = "te6cckEBAQEAVwAAqSEAySIAAAAAAAAAClAamJvK6AEkWsT6+x23oBycR3thipTt3Lw+jK50NeiC8K/0fEfSPwAIkBz3IfREANhIm2aHM6qidG4JJvZubIsYBOzXSFw+0uCe1MD/";
    val expectedTokenAddress = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedToAddress = address("0:224073DC87D1100361226D9A1CCEAA89D1B8249BD9B9B22C6013B35D2170FB4B");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiVaultPayToV2.fromCell(body);

    expect(decoded.queryId).toEqual(10);
    expect(decoded.amountOut).toEqual(7139343534);
    expect(decoded.tokenAddress).toEqual(expectedTokenAddress);
    expect(decoded.toAddress).toEqual(expectedToAddress);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_VAULT_V2_VAULT_PAY_TO_TX={} LT={}", txHash, txLt);
}
