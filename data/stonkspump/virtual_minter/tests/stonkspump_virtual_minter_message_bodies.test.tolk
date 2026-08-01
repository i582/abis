import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonkspump_virtual_minter.types"

get fun `test decodes real stonkspump virtual minter initialization`() {
    val txHash = "TC0TSebEmudnl3KouhxfK1zL+eHJDfawln1ltmPKaRs=";
    val txLt = "89270569000023";
    val bodyBoc = "te6cckECCgEAAVAAAlXMGpgCAAAAAAAAAACwDo1KUQAAQAsaK8LsUAAC9CdIrxu5YnjikGKsYAMkAQICRw+ggBi7g4DeNzKdhIQcrmOtgEvPAzeDBfDcwksOJV1/Xf1R8AMEAFFQb8I6wAgBi7g4DeNzKdhIQcrmOtgEvPAzeDBfDcwksOJV1/Xf1R4gMAhCAmBF5nthfnNIaqxEXPytDb6tbTFczI9K7ePy4jrRTaSwAwUAAEAFBgcCjyAGgH2rjHdQ6MG1to99Q04wWRO5MU9px3UGktDWMsLc3xQAeD4x3JgUWaqEdimEoD6NdcMgQ1wArFtms9tks7s3HHEAMg+g0ggJAAcAAAAgAEOADwfGO5MCizVQjsUwlAfRrrhkCGuAFYts1ntslndm444iAEUCgBoB9q4x3UOjBtbaPfUNOMFkTuTFPacd1BpLQ1jLC3N8UAAMAQAAAAAARKoVYA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpVirtualMinterInit.fromCell(body);
    val devBuy = decoded.devBuy.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.presaleOpen).toBeTrue();
    expect(decoded.migrationTonTarget).toEqual(2000000000000);
    expect(decoded.tonsCollected).toEqual(0);
    expect(decoded.baseJettonReserve).toEqual(100000000000000000);
    expect(decoded.additionalTonReserve).toEqual(997750562359);
    expect(decoded.additionalJettonReserve).toEqual(12471882029487500);
    expect(decoded.maxBuyPercent).toEqual(100);
    expect(devBuy.tonAmount).toEqual(30000000000);
    expect(devBuy.recipient).toEqual(address("EQDF3BwG8bmU7CQg5XMdbAJeeBm8GC-G5hJYcSrr-u_qj-K8"));
    expect(devBuy.minJettonsOut).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_MINTER_INIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real virtual presale buy`() {
    val txHash = "dmZ49NDGxxHFP1YSPwtKIGGUHaDzcySpFrwr9oTioTE=";
    val txLt = "89270642000009";
    val bodyBoc = "te6cckEBAQEAGwAAMswal65QWvUmtKSK5FAlQL5ABwOI9+Eq/OvdXDqu";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpBuyFromPresale.fromCell(body);

    expect(decoded.queryId).toEqual(5790209817526438628);
    expect(decoded.tonAmount).toEqual(10000000000);
    expect(decoded.minJettonsOut).toEqual(995023146122475);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_MINTER_BUY_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real virtual presale sell notification`() {
    val txHash = "SpQWF/ccW4MB4rpb0nR97RQ+YBIy7g3cm+2MpbweyOA=";
    val txLt = "89271097000023";
    val recipient = address("EQBr_McM1LHAyervYATxNcqkGloaZaCmvju730Z80NY8mjci");
    val bodyBoc = "te6cckEBAQEAXgAAt8wal7BEcsTgkF5W+HA5GAddrXhIANf5jhmpY4GT1d7ACeJrlUg0tDTLQU18d3e+jPmhrHk1ABr/McM1LHAyervYATxNcqkGloaZaCmvju730Z80NY8mlAgiHouaiqqyBA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpPresaleSellNotificationForMinter.fromCell(body);

    expect(decoded.queryId).toEqual(4932221010697934584);
    expect(decoded.jettonAmount).toEqual(1004405849249668);
    expect(decoded.sellInitiator).toEqual(recipient);
    expect(decoded.tonsRecipient).toBeNotNull();
    expect(decoded.tonsRecipient!).toEqual(recipient);
    expect(decoded.minTonOut).toEqual(8733041382);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_MINTER_SELL_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real virtual presale trade event`() {
    val txHash = "SpQWF/ccW4MB4rpb0nR97RQ+YBIy7g3cm+2MpbweyOA=";
    val txLt = "89271097000023";
    val bodyBoc = "te6cckEBAQEAPQAAdswal7NEcsTgkF5W+DgcjAOu1rwigQxQeOtABr/McM1LHAyervYATxNcqkGloaZaCmvju730Z80NY8mg5IFIAQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpPresaleTradeEvent.fromCell(body);

    expect(decoded.queryId).toEqual(4932221010697934584);
    expect(decoded.isBuy).toBeFalse();
    expect(decoded.amountIn).toEqual(1004405849249668);
    expect(decoded.amountOut).toEqual(9003135446);
    expect(decoded.recipient).toEqual(address("EQBr_McM1LHAyervYATxNcqkGloaZaCmvju730Z80NY8mjci"));
    expect(decoded.leftover).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_MINTER_TRADE_EVENT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real jetton transfer emitted by virtual presale buy`() {
    val txHash = "dmZ49NDGxxHFP1YSPwtKIGGUHaDzcySpFrwr9oTioTE=";
    val txLt = "89270642000009";
    val bodyBoc = "te6cckEBAwEAhAACsxeNRRlQWvUmtKSK5HA4njl7B5cYAaAfauMd1DowbW2j31DTjBZE7kxT2nHdQaS0NYywtzfFAC2ZGcu1EQ4b88a4Q4bm9mkuOEf6CIF0Av/R/hWnCS3yjmJaAwECAAAAQ4AfnOY8JEuTv/Gse8k9rbdfTk6N+pXjEaiQGtlECPL0QthYoEQl";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpJettonInternalTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(5790209817526438628);
    expect(decoded.amount).toEqual(996035525638513);
    expect(decoded.fromAddress).toBeNotNull();
    expect(decoded.fromAddress!).toEqual(
        address("EQDQD7VxjuodGDa20e-oacYLIncmKe047qDSWhrGWFub4p_1"),
    );
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(
        address("EQC2ZGcu1EQ4b88a4Q4bm9mkuOEf6CIF0Av_R_hWnCS3yhrw"),
    );
    expect(decoded.forwardTonAmount).toEqual(10000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_MINTER_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}
