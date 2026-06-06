import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_parent.types"

const HIPO_OWNER_MINT = "EQBw5RcWKkYiqkWR0jhRDWr_W8yUbhz95eMuKmZYcjKYBbGz"
const HIPO_OWNER_RESERVE = "EQBF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBL1o"
const HIPO_OWNER_BURN = "EQCk_NSgb3MZTfS1XWqDzaJuugePMlDWi6G0KuEre41DjGVn"

get fun `test hipo parent decodes toncenter proxy_tokens_minted incoming body`() {
    val txHash = "KjgAsC0p5LuoG58iRR0E211GAxRRGQtk7lHZ9y18WdU=";
    val txLt = "81966341000005";
    val bodyBoc = "te6cckEBAQEAPwAAeVvldibJKcxKaLBVUVKZpBDpJS6Q7dAAgA4couLFSMRVSLI6RwohrV/reZKNw5+8vGXFTMsORlMAoAAAABCaRWDK";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoParentProxyTokensMinted.fromCell(body);

    expect(decoded.queryId).toEqual(14495341495624684881);
    expect(decoded.tokens).toEqual(178681613970);
    expect(decoded.coins).toEqual(200000000000);
    expect(decoded.owner).toEqual(address(HIPO_OWNER_MINT));
    expect(decoded.roundSince).toEqual(0);

    println("HIPO_PARENT_PROXY_TOKENS_MINTED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo parent decodes toncenter proxy_reserve_tokens incoming body`() {
    val txHash = "wvMSg+oQtnA1kIeMnnvGu8RIN878irsL/PstOd7hjhY=";
    val txLt = "81945670000001";
    val bodyBoc = "te6cckEBAQEANwAAaWiLAhMgSoiEQ1NWwlBJOHKACACLpOTOQeibKJbSWoC4+1Ds3oR2u/p7YMHJ2IGy80/CCAIDYMomaw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoParentProxyReserveTokens.fromCell(body);

    expect(decoded.queryId).toEqual(2326822259136878274);
    expect(decoded.tokens).toEqual(19654977536);
    expect(decoded.owner).toEqual(address(HIPO_OWNER_RESERVE));
    expect(decoded.mode).toEqual(0);
    expect(decoded.ownershipAssignedAmount).toEqual(1);

    println("HIPO_PARENT_PROXY_RESERVE_TOKENS_TX={} LT={}", txHash, txLt);
}

get fun `test hipo parent decodes toncenter proxy_tokens_burned incoming body`() {
    val txHash = "qASGyCElr142MEVIqCGbOkoHlvl+tTQjb26iqaX/p38=";
    val txLt = "81914237000031";
    val bodyBoc = "te6cckEBAQEAOwAAcUR2/eC0cqIYtygRsFA5E2Z61QP+KtSIgBSfmpQN7mMpvparrVB5tE3XQPHmShrRdDaFXCVvcahxkJujuQA=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoParentProxyTokensBurned.fromCell(body);

    expect(decoded.queryId).toEqual(13002633301207814576);
    expect(decoded.tokens).toEqual(15321163693);
    expect(decoded.coins).toEqual(17149121672);
    expect(decoded.owner).toEqual(address(HIPO_OWNER_BURN));

    println("HIPO_PARENT_PROXY_TOKENS_BURNED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo parent decodes toncenter tokens_minted outgoing body`() {
    val txHash = "KjgAsC0p5LuoG58iRR0E211GAxRRGQtk7lHZ9y18WdU=";
    val txLt = "81966341000005";
    val bodyBoc = "te6cckEBAQEAPwAAeVRF7+7JKcxKaLBVUVKZpBDpJS6Q7dAAgA4couLFSMRVSLI6RwohrV/reZKNw5+8vGXFTMsORlMAoAAAABDB6C0m";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoParentTokensMinted.fromCell(body);

    expect(decoded.queryId).toEqual(14495341495624684881);
    expect(decoded.tokens).toEqual(178681613970);
    expect(decoded.coins).toEqual(200000000000);
    expect(decoded.owner).toEqual(address(HIPO_OWNER_MINT));
    expect(decoded.roundSince).toEqual(0);

    println("HIPO_PARENT_TOKENS_MINTED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo parent decodes toncenter reserve_tokens outgoing body`() {
    val txHash = "wvMSg+oQtnA1kIeMnnvGu8RIN878irsL/PstOd7hjhY=";
    val txLt = "81945670000001";
    val bodyBoc = "te6cckEBAQEANwAAaThqNYsgSoiEQ1NWwlBJOHKACACLpOTOQeibKJbSWoC4+1Ds3oR2u/p7YMHJ2IGy80/CCAIDLCWhzg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoParentReserveTokens.fromCell(body);

    expect(decoded.queryId).toEqual(2326822259136878274);
    expect(decoded.tokens).toEqual(19654977536);
    expect(decoded.owner).toEqual(address(HIPO_OWNER_RESERVE));
    expect(decoded.mode).toEqual(0);
    expect(decoded.ownershipAssignedAmount).toEqual(1);

    println("HIPO_PARENT_RESERVE_TOKENS_TX={} LT={}", txHash, txLt);
}

get fun `test hipo parent decodes toncenter tokens_burned outgoing body`() {
    val txHash = "qASGyCElr142MEVIqCGbOkoHlvl+tTQjb26iqaX/p38=";
    val txLt = "81914237000031";
    val bodyBoc = "te6cckEBAQEAGQAALltRLiW0cqIYtygRsFA5E2Z61QP+KtSI1kLhew==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = HipoParentTokensBurned.fromCell(body);

    expect(decoded.queryId).toEqual(13002633301207814576);
    expect(decoded.tokens).toEqual(15321163693);
    expect(decoded.coins).toEqual(17149121672);

    println("HIPO_PARENT_TOKENS_BURNED_TX={} LT={}", txHash, txLt);
}
