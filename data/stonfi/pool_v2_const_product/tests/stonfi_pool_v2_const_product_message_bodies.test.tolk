import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_pool_v2_const_product.types"

get fun `test stonfi pool v2 constant product decodes toncenter swap body`() {
    val txHash = "x1vUisjbkkYsidXgIuNkWhHv87B2D1uptWOAvW9uXVs=";
    val txLt = "81508026000007";
    val bodyBoc = "te6cckEBAwEA9wABZ2Zk3ipUuhIc3Ezz9IAPTqaL2cS/TF55wRrV08oPB6y652iwk7ZiHOvWrnTTOYCgPf0kABABAeFmZN4qgBJFrE+vsdt6AcnEd7YYqU7dy8PoyudDXogvCv9HxH0j8AHp1NF7OJfpi884I1q6eUHg9Zdc7RYSdsxDnXrVzppnMgA9OpovZxL9MXnnBGtXTyg8HrLrnaLCTtmIc69audNM5gAAAAB/////wAIAkz3bNBgA9OpovZxL9MXnnBGtXTyg8HrLrnaLCTtmIc69audNM5gAABlAAiQHPch9EQA2EibZoczqqJ0bgkm9m5sixgE7NdIXD7S4Dcnd7Q==";
    val expectedUser = address("0:7A75345ECE25FA62F3CE08D6AE9E50783D65D73B45849DB310E75EB573A699CC");
    val expectedTokenWallet1 = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedRefAddress = address("0:224073DC87D1100361226D9A1CCEAA89D1B8249BD9B9B22C6013B35D2170FB4B");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPoolV2ConstProductSwap.fromCell(body);
    val dexPayload = decoded.dexPayload.load();
    val swapBody = dexPayload.swapBody.load();

    expect(decoded.queryId).toEqual(6105212160018543604);
    expect(decoded.fromUser).toEqual(expectedUser);
    expect(decoded.leftAmount).toEqual(0);
    expect(decoded.rightAmount).toEqual(8320000000);
    expect(dexPayload.transferredOp).toEqual(0x6664de2a);
    expect(dexPayload.tokenWallet1).toEqual(expectedTokenWallet1);
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

    println("STONFI_POOL_V2_CP_SWAP_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi pool v2 constant product decodes early provide lp body`() {
    val txHash = "KiapxZFxnxVI+MKBcAVnMyIhbasoNJDhLW03mE98VXg=";
    val txLt = "49987429000005";
    val bodyBoc = "te6cckEBAwEA1AABZzfAlt8AAAb/URIej4AJZZr9H59PwDB4E0AkKgYMAk94l5r/dMwzri4eXVnn8oChdIdugBABAeE3wJbfgBJFrE+vsdt6AcnEd7YYqU7dy8PoyudDXogvCv9HxH0j8AEss1+j8+n4Bg8CaASFQMGASe8S81/umYZ1xcPLqzz+UgAllmv0fn0/AMHgTQCQqBgwCT3iXmv90zDOuLh5dWefygAAAAAzh4f2QAIATU1MIu0oAJZZr9H59PwDB4E0AkKgYMAk94l5r/dMwzri4eXVnn8pBMAAIm4=";
    val expectedUser = address("0:4B2CD7E8FCFA7E0183C09A0121503060127BC4BCD7FBA6619D7170F2EACF3F94");
    val expectedTokenWallet1 = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPoolV2ConstProductProvideLp.fromCell(body);
    val dexPayload = decoded.dexPayload.load();
    val provideBody = dexPayload.provideLpBody.load();

    expect(decoded.queryId).toEqual(7693646569103);
    expect(decoded.fromUser).toEqual(expectedUser);
    expect(decoded.leftAmount).toEqual(0);
    expect(decoded.rightAmount).toEqual(50000000000);
    expect(dexPayload.transferredOp).toEqual(0x37c096df);
    expect(dexPayload.tokenWallet1).toEqual(expectedTokenWallet1);
    expect(dexPayload.refundAddress).toEqual(expectedUser);
    expect(dexPayload.excessesAddress).toEqual(expectedUser);
    expect(dexPayload.txDeadline).toEqual(1729040364);
    expect(provideBody.minLpOut).toEqual(3569495762);
    expect(provideBody.toAddress).toEqual(expectedUser);
    expect(provideBody.bothPositive).toEqual(1);
    expect(provideBody.fwdAmount).toEqual(0);
    expect(provideBody.customPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_POOL_V2_CP_PROVIDE_LP_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi pool v2 constant product decodes early cb add liquidity body`() {
    val txHash = "NaGz1S+REZOwLvVyMKdPf8JsVdjUuipCZoiRFaUxEi4=";
    val txLt = "49987441000001";
    val bodyBoc = "te6cckEBAgEApwABeQbs1ScAAABGewMMykD39JAFC6Q7dACACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KJqYRdpAgBAMmACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KQASyzX6Pz6fgGDwJoBIVAwYBJ7xLzX+6ZhnXFw8urPP5SACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KQJpqCGM=";
    val expectedUser = address("0:4B2CD7E8FCFA7E0183C09A0121503060127BC4BCD7FBA6619D7170F2EACF3F94");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPoolV2ConstProductCbAddLiquidity.fromCell(body);
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

    println("STONFI_POOL_V2_CP_CB_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi pool v2 constant product decodes toncenter burn notification body`() {
    val txHash = "dZ5VbVraQukF+uma7qXpz7UNvvwIHH249OFljum+PB4=";
    val txLt = "53658015000003";
    val bodyBoc = "te6cckEBAQEANgAAZyl0N88AAACJZ7ykhVDjxS9GOACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KCBfxmYX";
    val expectedOwner = address("0:4B2CD7E8FCFA7E0183C09A0121503060127BC4BCD7FBA6619D7170F2EACF3F94");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPoolV2ConstProductBurnNotificationExt.fromCell(body);

    expect(decoded.queryId).toEqual(590150935685);
    expect(decoded.jettonAmount).toEqual(61141611619);
    expect(decoded.fromAddress).toEqual(expectedOwner);
    expect(decoded.responseAddress).toBeNull();
    expect(decoded.maybeCustomPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_POOL_V2_CP_BURN_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi pool v2 constant product decodes toncenter pay to body`() {
    val txHash = "x1vUisjbkkYsidXgIuNkWhHv87B2D1uptWOAvW9uXVs=";
    val txLt = "81508026000007";
    val bodyBoc = "te6cckEBAgEAwgAB6WV7VPVUuhIc3Ezz9IAPTqaL2cS/TF55wRrV08oPB6y652iwk7ZiHOvWrnTTOZAB6dTReziX6YvPOCNaunlB4PWXXO0WEnbMQ5161c6aZzIAPTqaL2cS/TF55wRrV08oPB6y652iwk7ZiHOvWrnTTOZjIbhyoAEAjwPf7z6AEkWsT6+x23oBycR3thipTt3Lw+jK50NeiC8K/0fEfSPhACSIMGBps/qzRG3uPYhON8bucyCtu0mYdL1+u4gSz77IIC81EVg=";
    val expectedUser = address("0:7A75345ECE25FA62F3CE08D6AE9E50783D65D73B45849DB310E75EB573A699CC");
    val expectedToken0 = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedToken1 = address("0:9220C181A6CFEACD11B7B8F62138DF1BB9CC82B6ED2661D2F5FAEE204B3EFB20");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPoolV2ConstProductPayTo.fromCell(body);
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

    println("STONFI_POOL_V2_CP_PAY_TO_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi pool v2 constant product decodes toncenter pay vault body`() {
    val txHash = "x1vUisjbkkYsidXgIuNkWhHv87B2D1uptWOAvW9uXVs=";
    val txLt = "81508026000007";
    val bodyBoc = "te6cckEBAgEAmwABnWM4FjJUuhIc3Ezz9IAESA57kPoiAGwkTbNDmdVROjcEk3s3NkWMAnZrpC4faXAB6dTReziX6YvPOCNaunlB4PWXXO0WEnbMQ5161c6aZzIBAI0wEgKoASRaxPr7HbegHJxHe2GKlO3cvD6MrnQ16ILwr/R8R9I+EAJIgwYGmz+rNEbe49iE43xu5zIK27SZh0vX67iBLPvsgitZldw=";
    val expectedOwner = address("0:224073DC87D1100361226D9A1CCEAA89D1B8249BD9B9B22C6013B35D2170FB4B");
    val expectedExcesses = address("0:7A75345ECE25FA62F3CE08D6AE9E50783D65D73B45849DB310E75EB573A699CC");
    val expectedToken0 = address("0:922D627D7D8EDBD00E4E23BDB0C54A76EE5E1F46573A1AF4417857FA3E23E91F");
    val expectedToken1 = address("0:9220C181A6CFEACD11B7B8F62138DF1BB9CC82B6ED2661D2F5FAEE204B3EFB20");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiPoolV2ConstProductPayVault.fromCell(body);
    val additionalInfo = decoded.additionalInfo.load();

    expect(decoded.queryId).toEqual(6105212160018543604);
    expect(decoded.owner).toEqual(expectedOwner);
    expect(decoded.excessesAddress).toEqual(expectedExcesses);
    expect(additionalInfo.amount0Out).toEqual(73770);
    expect(additionalInfo.token0Address).toEqual(expectedToken0);
    expect(additionalInfo.amount1Out).toEqual(0);
    expect(additionalInfo.token1Address).toEqual(expectedToken1);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_POOL_V2_CP_PAY_VAULT_TX={} LT={}", txHash, txLt);
}
