import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_router_v2.types"

get fun `test stonfi router v2 decodes toncenter swap body sent to pool`() {
    val txHash = "x1vUisjbkkYsidXgIuNkWhHv87B2D1uptWOAvW9uXVs=";
    val txLt = "81508026000007";
    val bodyBoc = "te6cckEBAwEA9wABZ2Zk3ipUuhIc3Ezz9IAPTqaL2cS/TF55wRrV08oPB6y652iwk7ZiHOvWrnTTOYCgPf0kABABAeFmZN4qgBJFrE+vsdt6AcnEd7YYqU7dy8PoyudDXogvCv9HxH0j8AHp1NF7OJfpi884I1q6eUHg9Zdc7RYSdsxDnXrVzppnMgA9OpovZxL9MXnnBGtXTyg8HrLrnaLCTtmIc69audNM5gAAAAB/////wAIAkz3bNBgA9OpovZxL9MXnnBGtXTyg8HrLrnaLCTtmIc69audNM5gAABlAAiQHPch9EQA2EibZoczqqJ0bgkm9m5sixgE7NdIXD7S4Dcnd7Q==";
    val expectedUser = address("0:7A75345ECE25FA62F3CE08D6AE9E50783D65D73B45849DB310E75EB573A699CC");
    val expectedOtherWallet = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedRefAddress = address("0:224073DC87D1100361226D9A1CCEAA89D1B8249BD9B9B22C6013B35D2170FB4B");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiSwapV2.fromCell(body);
    val dexPayload = decoded.dexPayload.load();
    val swapBody = dexPayload.swapBody.load();

    expect(decoded.queryId).toEqual(6105212160018543604);
    expect(decoded.fromUser).toEqual(expectedUser);
    expect(decoded.leftAmount).toEqual(0);
    expect(decoded.rightAmount).toEqual(8320000000);
    expect(dexPayload.transferredOp).toEqual(0x6664de2a);
    expect(dexPayload.tokenWallet1).toEqual(expectedOtherWallet);
    expect(dexPayload.refundAddress).toEqual(expectedUser);
    expect(dexPayload.excessesAddress).toEqual(expectedUser);
    expect(dexPayload.txDeadline).toEqual(4294967295);
    expect(swapBody.minOut).toEqual(14529345);
    expect(swapBody.receiver).toBeNotNull();
    expect(swapBody.receiver!).toEqual(expectedUser);
    expect(swapBody.fwdGas).toEqual(0);
    expect(swapBody.customPayload).toBeNull();
    expect(swapBody.refundFwdGas).toEqual(0);
    expect(swapBody.refundPayload).toBeNull();
    expect(swapBody.refFee).toEqual(50);
    expect(swapBody.refAddress).toBeNotNull();
    expect(swapBody.refAddress!).toEqual(expectedRefAddress);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_ROUTER_V2_SWAP_TO_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi router v2 decodes toncenter pay to body from pool`() {
    val txHash = "x1vUisjbkkYsidXgIuNkWhHv87B2D1uptWOAvW9uXVs=";
    val txLt = "81508026000007";
    val bodyBoc = "te6cckEBAgEAwgAB6WV7VPVUuhIc3Ezz9IAPTqaL2cS/TF55wRrV08oPB6y652iwk7ZiHOvWrnTTOZAB6dTReziX6YvPOCNaunlB4PWXXO0WEnbMQ5161c6aZzIAPTqaL2cS/TF55wRrV08oPB6y652iwk7ZiHOvWrnTTOZjIbhyoAEAjwPf7z6AEkWsT6+x23oBycR3thipTt3Lw+jK50NeiC8K/0fEfSPhACSIMGBps/qzRG3uPYhON8bucyCtu0mYdL1+u4gSz77IIC81EVg=";
    val expectedUser = address("0:7A75345ECE25FA62F3CE08D6AE9E50783D65D73B45849DB310E75EB573A699CC");
    val expectedToken0 = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedToken1 = address("0:9220C181A6CFEACD11B7B8F62138DF1BB9CC82B6ED2661D2F5FAEE204B3EFB20");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPayToV2.fromCell(body);
    val additionalInfo = decoded.additionalInfo.load();

    expect(decoded.queryId).toEqual(6105212160018543604);
    expect(decoded.toAddress).toEqual(expectedUser);
    expect(decoded.excessesAddress).toEqual(expectedUser);
    expect(decoded.originalCaller).toEqual(expectedUser);
    expect(decoded.exitCode).toEqual(3326308581);
    expect(decoded.customPayload).toBeNull();
    expect(additionalInfo.fwdTonAmount).toEqual(0);
    expect(additionalInfo.amount0Out).toEqual(14675774);
    expect(additionalInfo.token0Address).toEqual(expectedToken0);
    expect(additionalInfo.amount1Out).toEqual(0);
    expect(additionalInfo.token1Address).toEqual(expectedToken1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_ROUTER_V2_PAY_TO_FROM_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi router v2 decodes toncenter pay vault body from pool`() {
    val txHash = "x1vUisjbkkYsidXgIuNkWhHv87B2D1uptWOAvW9uXVs=";
    val txLt = "81508026000007";
    val bodyBoc = "te6cckEBAgEAmwABnWM4FjJUuhIc3Ezz9IAESA57kPoiAGwkTbNDmdVROjcEk3s3NkWMAnZrpC4faXAB6dTReziX6YvPOCNaunlB4PWXXO0WEnbMQ5161c6aZzIBAI0wEgKoASRaxPr7HbegHJxHe2GKlO3cvD6MrnQ16ILwr/R8R9I+EAJIgwYGmz+rNEbe49iE43xu5zIK27SZh0vX67iBLPvsgitZldw=";
    val expectedOwner = address("0:224073DC87D1100361226D9A1CCEAA89D1B8249BD9B9B22C6013B35D2170FB4B");
    val expectedExcesses = address("0:7A75345ECE25FA62F3CE08D6AE9E50783D65D73B45849DB310E75EB573A699CC");
    val expectedToken0 = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedToken1 = address("0:9220C181A6CFEACD11B7B8F62138DF1BB9CC82B6ED2661D2F5FAEE204B3EFB20");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPayVaultV2.fromCell(body);
    val additionalInfo = decoded.additionalInfo.load();

    expect(decoded.queryId).toEqual(6105212160018543604);
    expect(decoded.owner).toEqual(expectedOwner);
    expect(decoded.excessesAddress).toEqual(expectedExcesses);
    expect(additionalInfo.amount0Out).toEqual(73770);
    expect(additionalInfo.token0Address).toEqual(expectedToken0);
    expect(additionalInfo.amount1Out).toEqual(0);
    expect(additionalInfo.token1Address).toEqual(expectedToken1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_ROUTER_V2_PAY_VAULT_FROM_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi router v2 decodes toncenter deposit ref fee body sent to vault`() {
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

    println("STONFI_ROUTER_V2_DEPOSIT_REF_FEE_TO_VAULT_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi router v2 decodes toncenter vault pay to body from vault`() {
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

    println("STONFI_ROUTER_V2_VAULT_PAY_TO_FROM_VAULT_TX={} LT={}", txHash, txLt);
}
