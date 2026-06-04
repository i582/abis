import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonco_account.types"

get fun `test tonco account decodes representative add liquidity body`() {
    val txHash = "XrhL+eMMIeDwzIM17GsZXvDwkL+tUAv39UVFe+zyOeg=";
    val txLt = "55638781000001";
    val bodyBoc = "te6cckEBAQEANgAAaD6+VDEAAAAAAAAAAIAWNFeF2J/90IAWNFeF2J/90AAAAAAAAAAAAAGIClbyHIf+VjgAG1iFj5Cp";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Accountv3AddLiquidity.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newAmount0).toEqual(99999999999999965);
    expect(decoded.newAmount1).toEqual(0);
    expect(decoded.newEnough0).toEqual(99999999999999965);
    expect(decoded.newEnough1).toEqual(0);
    expect(decoded.liquidity).toEqual(431052966468743);
    expect(decoded.tickLower).toEqual(-109000);
    expect(decoded.tickUpper).toEqual(7000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_ACCOUNT_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}

get fun `test tonco account decodes representative pool mint body`() {
    val txHash = "XrhL+eMMIeDwzIM17GsZXvDwkL+tUAv39UVFe+zyOeg=";
    val txLt = "55638781000001";
    val bodyBoc = "te6cckEBAQEATwAAmYFwLvgAAAAAAAAAAIAWNFeF2J/90IAEgE8wkojwqzwASgL80W1X1SFjwGmlgJE9cUIQAsyDciAAAAAAAAAAAAAxAUreQ5D/yscAA2sQjEGUCw==";
    val expectedRecipient = address("0:2402798494478559E0025017E68B6ABEA90B1E034D2C0489EB8A108016641B91");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3Mint.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount0Funded).toEqual(99999999999999965);
    expect(decoded.amount1Funded).toEqual(0);
    expect(decoded.recipient).toEqual(expectedRecipient);
    expect(decoded.liquidity).toEqual(431052966468743);
    expect(decoded.tickLower).toEqual(-109000);
    expect(decoded.tickUpper).toEqual(7000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_ACCOUNT_POOL_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test tonco account decodes candidate add liquidity body with both enough values`() {
    val txHash = "56mZXAIjYFpktyKGeMzwjEejr3yDknWz1BCkMtpIhY4=";
    val txLt = "50920148000001";
    val bodyBoc = "te6cckEBAQEAMgAAYD6+VDEAAAAAAAAAAEATQ6QAQBMS0AS+PHarAAAAAAAAAAAAAAAAQbr+igC8rADlsGWgCXg=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Accountv3AddLiquidity.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newAmount0).toEqual(20200000);
    expect(decoded.newAmount1).toEqual(0);
    expect(decoded.newEnough0).toEqual(20000000);
    expect(decoded.newEnough1).toEqual(3191633579);
    expect(decoded.liquidity).toEqual(1102773898);
    expect(decoded.tickLower).toEqual(48300);
    expect(decoded.tickUpper).toEqual(58800);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_ACCOUNT_CANDIDATE_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}

get fun `test tonco account decodes candidate pool mint body with both funded amounts`() {
    val txHash = "56mZXAIjYFpktyKGeMzwjEejr3yDknWz1BCkMtpIhY4=";
    val txLt = "50920148000001";
    val bodyBoc = "te6cckEBAQEATwAAmYFwLvgAAAAAAAAAAEATQ6QEvjx2q4ASN2BAdMB4nj8t1ecN7lCPioTq1wTMscbkYAOhCZ+/MEAAAAAAAAAAAAAAAAg3X9FAF5WAHLYQ6rkKwA==";
    val expectedRecipient = address("0:91BB0203A603C4F1F96EAF386F72847C542756B826658E3723001D084CFDF982");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3Mint.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount0Funded).toEqual(20200000);
    expect(decoded.amount1Funded).toEqual(3191633579);
    expect(decoded.recipient).toEqual(expectedRecipient);
    expect(decoded.liquidity).toEqual(1102773898);
    expect(decoded.tickLower).toEqual(48300);
    expect(decoded.tickUpper).toEqual(58800);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_ACCOUNT_CANDIDATE_POOL_MINT_TX={} LT={}", txHash, txLt);
}
