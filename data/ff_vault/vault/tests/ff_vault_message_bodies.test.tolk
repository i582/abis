import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/ff_vault.types"

const VAULT_ADDRESS = "EQBMTi0nonch8rj6P5mT4TyWlunXAbL0mPmBKU7OKv3t2koO"
const DEPOSITOR_ADDRESS = "EQAY4M45NM2XKC-PY5nLKuAR1eKfGxz-N3SqSEQhDXNKbvit"

fun loadReferencedForwardPayload(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();
    val body = payload.loadRef();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
    return body;
}

get fun `test decodes real ff vault stable deposit notification`() {
    val txHash = "hEFOB75ExVpxsxe/Bvha/NGB3z9QYolTQeItQwavu3E=";
    val txLt = "68546776000007";
    val bodyBoc = "te6cckEBAgEAOwABYnNi0JwAAAAAAAAAADAYaggAMcGccmmbLlBfHsczllXAI6vFPjY5/G7pVJCIQhrmlN0BAAk9Zp23wLbzo1Y=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultJettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val deposit = FfVaultStableDeposit.fromCell(
        loadReferencedForwardPayload(mutate forwardPayload),
    );

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(100000);
    expect(decoded.sender).toEqual(address(DEPOSITOR_ADDRESS));
    expect(deposit.distributeBetweenStakers).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_STABLE_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real ff vault asset deposit notification`() {
    val txHash = "JHmSpjVkC6PX5XgjMLeBWvA/F+UJfPglX7h58UjzBV4=";
    val txLt = "68549865000007";
    val bodyBoc = "te6cckECDQEABXoAAWBzYtCcAAAAAAAAAAAk3tgAMcGccmmbLlBfHsczllXAI6vFPjY5/G7pVJCIQhrmlN0BAQlTSRfDwAIB/lBOQVUBAAAAA7gBAAAABQ0AKLjwtLRGEOEsa2rlMZBEREnv/p9bpCEbAvfluNQSYe0/Pf7pAL03pAkQ+VqrQeHoe+DFO/bmCgTSR4N4H3+J+wECERscceFRdabXeX7+kTSwl2SXEYSPDiwTAYABPcxOBJ4aAQzDfL35Qt73Ei4DAf5I5jspjMGjcyTAZnr24rIEeoVtkAAEWSR/TJl+nN/XeSDHQO9B3UxfsREIDBczGfcozA7r1T1aq0Nw7oO0iIf1LkFAEsIF+ztojxEQEjERN1AooujOgAAGF3jEm9p/0TDmu0d2vOK4MQDksBZQwkt9xfsxk3iWsvkopCLaV+hVBAH+NPEFuggWThZkehg57FF28KDDgjLmQJ9MtgAHfzfWh2vh0ZLE5+IMY0jH0BrdouE6srNpDZBwArWBRQl0+KWcXdBJXkiS8qSdUaXpz9nspHjM6MvZc/o987bgEQEI6uQJ6LJdxRf0JPGj0Gd4z74jQL2hG2TB7Cv8hRQCO5YaowUB/kYXEx2jbYwyjYp7iaj/LJg9eWjQ+UopiyrXfmcnLAEJyqiZZRl3Zzd47wBaOemI/hcz0AXyivwVm2kJgmC/M3BRZmtXHfo7/PNDaEHdfYLjjDUVZbLZ5m6m12MYeYwi4gEKyVxDL4ps0BEaV3IpmnJAYnoPyuGvzDTNEdwGrU4GAf7j6DMc3hdysPxQXiCoxo1EDArDJyz6LJfnh6/LP9u9PIWZSAAMQoKY1qH7vlo3z40QHOpf94Aw/sXcuWFCwqUU+bKN/skyjZCrXdJmn/1FclvpE0Kc16r1w0vyLsG0NeOXPO+WhQENXlUc4aMosVcgdc25mqboJ68jH7xVBmfuBwH+Rk1lnjWBnTwDu1a0VdJSXkz13wlHYUHum71RrynUbpbg2JuFl0xG0wAOdv0M29FSgbu6+CxStWdzqTpMOHap/KdfaB3dSXainyBN0pmC4/Mq4lzGR1R72ygOFwWIohsp9lrzmreXtEHbtwEPIWCtMaWYxtwpzY7ZxdpA/Osq7ggB/u86qAltbbenaKDsVjZQ9xVnQef9e8T52UjEqH7pC7Kj0Ritr3oebNbipS/RXgEQrfx4aUvfwkJkc5sUi+v61yWE1GgTrSmi6ZHiM9/1Di8H6w2hSHsnC6Yz4JkAUkROHIgG27pbPnj9/v5dFQj3pAFpyqXKAAAAAAAa4QH67awJAf5YUeMrmyO1+UEajCusSq4+1N17gR3Rpy6kqnEAAAAAC79XXQFBVVdWAAAAAAAQzQEEAAAnEP1CU17XepRvu3aCtMzWfetj7i3xAQBVACgXt4Q4x2k1cYLAQ0b92q0ReMgvQEiCj+CZfDxkYk4UAAAADtOddIMAAAAAAsAxDf//CgH+//gAAAAAacqlygAAAABpyqXJAAAADtsLwfgAAAAAArcBlg3+QzY/p92OHyELgj0zro3yQL1YNflUwC74tiff+Ux87dOmh6Bjpm5AhmfpOC+XT7CoOYRw9+EgA9CSnQuMPJQPD8idaP3FmjquoGJwp3zZ4oC0WA6YTMWQgmJmbwsB/rnIdwGQ+sYHIoV/FCJn+b0a0RZDtegTLa6ZbP5ZN6mna9g7XMpYGVonZGqIjHhKXWmX2gm4jVJO39Vmz3f3/29sFSnnOhbaKoF8mPj4OPjYKTgeA48wmNO6gvP6vVjB9WuJefHAsCGy4MqSyXk9nke6HcMVfO4Ire/5YIb/u+gMAFK+rCaKIi/Ff0F2BjhK5tWaAYRNAyhnqRf5Gn7Kip8t4/UKYxB7ur34d3e/ecY=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultJettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val deposit = FfVaultAssetDeposit.fromCell(loadReferencedForwardPayload(mutate forwardPayload));

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount > 0).toBeTrue();
    expect(decoded.sender).toEqual(address(DEPOSITOR_ADDRESS));
    expect(deposit.priceUpdateData).toBeNotNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_ASSET_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real pyth success response accepted by ff vault`() {
    val txHash = "ZlO1ZLo2K4I/7ORVZsNSmMxybPDon1QMYQw8Ru5E5hc=";
    val txLt = "68549865000011";
    val bodyBoc = "te6cckEBBgEAwAACTQAAAAUBgAmJxaT0TuQ+Vx9H8zJ8J5LS3TrgNl6THzAlKdnFX727UAECAUAoF7eEOMdpNXGCwENG/dqtEXjIL0BIgo/gmXw8ZGJOFAMAX3opT9wAAAAAAAAAAIADHBnHJpmy5QXx7HM5ZVwCOrxT42Ofxu6VSQiEIa5pTcSb2wIABAUAOAAAAA7TnXSDAAAAAALAMQ3////4AAAAAGnKpcoAOAAAAA7bC8H4AAAAAAK3AZb////4AAAAAGnKpcrBnMZk";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultPythResponseSuccess.fromCell(body);
    val operation = FfVaultStakeOperation.fromCell(decoded.operation);

    expect(decoded.feedsCount).toEqual(1);
    expect(decoded.initialSender).toEqual(address(VAULT_ADDRESS));
    expect(operation.queryId).toEqual(0);
    expect(operation.depositAddress).toEqual(address(DEPOSITOR_ADDRESS));
    expect(operation.assetAmount > 0).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_PYTH_SUCCESS_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real pyth error response accepted by ff vault`() {
    val txHash = "Wg3P58pNiFD82DYpg4hvpryD7CFZE9BwPnFYU3mQN2I=";
    val txLt = "67920047000011";
    val bodyBoc = "te6cckEBAgEAQgABGAABAAIAAAfkAAAABQEAYXopT9wAAAAAAAAwOYAEd9VDjMK97NY10CAICCOBUP0DyGROcbyF6LpiL6M/d+YDDUHNzsza";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultPythErrorResponse.fromCell(body);
    val operation = FfVaultStakeOperation.fromCell(decoded.operation);

    expect(decoded.errorCode).toEqual(2020);
    expect(decoded.operationCode).toEqual(5);
    expect(operation.queryId).toEqual(12345);
    expect(operation.assetAmount > 0).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_PYTH_ERROR_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real ff vault position initialization`() {
    val txHash = "ZlO1ZLo2K4I/7ORVZsNSmMxybPDon1QMYQw8Ru5E5hc=";
    val txLt = "68549865000011";
    val bodyBoc = "te6cckEBAQEAcgAA3wAAAAEAAAAAAAAAAIADHBnHJpmy5QXx7HM5ZVwCOrxT42Ofxu6VSQiEIa5pTcSb2gAAAAAAAAAAAAAAAAAAAAFVoIvEONqEtH7Kn1obGe2CAAAAAAAAAAAAAAAAAAAE+ZjZ1yFkfq+zYWvVp8+aVc9vngia";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultPositionInit.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.owner).toEqual(address(DEPOSITOR_ADDRESS));
    expect(decoded.assetAmount).toEqual(19949);
    expect(decoded.distributedStables).toEqual(227050174430635989259679729521900975809);
    expect(decoded.assetPriceStaked > 0).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_POSITION_INIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real pyth request emitted by ff vault`() {
    val txHash = "JHmSpjVkC6PX5XgjMLeBWvA/F+UJfPglX7h58UjzBV4=";
    val txLt = "68549865000007";
    val bodyBoc = "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";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultPythParsePriceFeedUpdates.fromCell(body);
    val operation = FfVaultStakeOperation.fromCell(decoded.operation);

    expect(decoded.minPublishTime < decoded.maxPublishTime).toBeTrue();
    expect(decoded.targetAddress.castToInternal()).toEqual(address(VAULT_ADDRESS));
    expect(operation.queryId).toEqual(0);
    expect(operation.depositAddress).toEqual(address(DEPOSITOR_ADDRESS));
    expect(operation.assetAmount > 0).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_PYTH_REQUEST_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real jetton internal transfer emitted by ff vault`() {
    val txHash = "i5HHzkj5TIzWCcRH36H7op6f5NX4mM+dckg9+eVZ0JI=";
    val txLt = "68546727000009";
    val bodyBoc = "te6cckEBAQEAVQAApg+KfqUAAAAAAAAAADAYaggAMcGccmmbLlBfHsczllXAI6vFPjY5/G7pVJCIQhrmlN0ABjgzjk0zZcoL49jmcsq4BHV4p8bHP43dKpIRCENc0puARGn1eQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultJettonInternalTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(100000);
    expect(decoded.fromAddress).toEqual(address(DEPOSITOR_ADDRESS));
    expect(decoded.responseAddress).toEqual(address(DEPOSITOR_ADDRESS));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_JETTON_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real excesses emitted by ff vault`() {
    val txHash = "hEFOB75ExVpxsxe/Bvha/NGB3z9QYolTQeItQwavu3E=";
    val txLt = "68546776000007";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_EXCESSES_TX={} LT={}", txHash, txLt);
}
