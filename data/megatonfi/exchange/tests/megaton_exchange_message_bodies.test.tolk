import "@acton/fmt"
import "@acton/testing/expect"
import "../types/megaton_exchange.types"

fun expectExactBody(actual: cell, expected: cell) {
    expect(actual.hash()).toEqual(expected.hash());
}

get fun `test megaton exchange decodes a real add-liquidity callback`() {
    // Toncenter transaction UfzjzATtsOakWsUtqlAN/1K02rCql5wnlZH27kvaiiQ=, lt 37966227000011.
    val body = parseCellFromBase64("te6cckEBAQEARgAAh88+7ekAAAAAAAAAAIAS3c+t7MIqVvPElSEx/5QbyluaAIq+/A/pcd+q5LoIHLB+NSVEzqyAAFhqEHzyDdsoxGAAWCuQPAFyUw==");
    val decoded = MegatonExchangeAddLiquidity.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.tokenAAmount).toEqual(4547108000000000000);
    expect(decoded.tokenBAmount).toEqual(50000);
    expect(decoded.minimumTokenAAmount).toEqual(4501636920000000000);
    expect(decoded.minimumTokenBAmount).toEqual(49500);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP burn request`() {
    // Toncenter transaction QY1qzkmIVnrnYm25wKnBctuGfxXmWz+/LKFJcb+Zn1Q=, lt 53664798000003.
    val body = parseCellFromBase64("te6cckEBAgEAKwABLVlfB7wAAAAAAAAAAKFSd9vGuO6INRl8AQAeoZNWqUQiYIHRMwRg30pOwGlAQA==");
    val decoded = MegatonExchangeBurnLiquidity.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.lpAmount).toEqual(99898179393949115044247);
    expect(decoded.minimumAmounts).toBeNotNull();
    expect(decoded.minimumAmounts!.load().minimumTokenBAmount).toEqual(1625246286);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real swap notification`() {
    // Toncenter transaction XmdFv4Sxg0tMGW8Y1TEVk2xp58qAilYN9U98+xlyABY=, lt 53998527000001.
    val body = parseCellFromBase64("te6cckEBAwEAOwABXnNi0JwAAAAAAAAAABAYAGvTPhfUdIT2eZEjayL1TCbUsw0C3vNqsLxmE7jETaxHAQEIAAAAAAIAAIvlVKU=");
    val decoded = MegatonExchangeSwapNotification.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(1);
    expect(decoded.swapPayload).toBeNotNull();
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real reward claim`() {
    // Toncenter transaction bj/xlge0LNXZf3+tcroWgavEATzxcpjzscYE+LWM3q4=, lt 54305408000003.
    val body = parseCellFromBase64("te6cckEBAQEADgAAGGsUz+EAAAAAAAAAAAH8hH8=");
    val decoded = MegatonExchangeClaimRewards.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real mining-rate update`() {
    // Toncenter transaction lthb0GiS5VVzKYDgh0H4dfCqnqCQQL7+2vp7dyRguMQ=, lt 54301466000001.
    val body = parseCellFromBase64("te6cckEBAQEAGgAAMHCuHzQAAAAAAAAAAAAAAAAAAAAAZ7vgsLOnFLc=");
    val decoded = MegatonExchangeUpdateMiningRate.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.miningRate).toEqual(0);
    expect(decoded.startsAt).toEqual(1740366000);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real mining-amount update`() {
    // Toncenter transaction FKTejpfvRqCi5qt49F4q6ksNKRz6DAXr9/wueqpUyIg=, lt 58924468000001.
    val body = parseCellFromBase64("te6cckEBAQEALgAAWCC4jS4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABDNoC96/mAH6tqTw==");
    val decoded = MegatonExchangeSetMiningAmount.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.miningAmount).toEqual(18918750009686400);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP transfer callback`() {
    // Toncenter transaction xpgsn0NHB9ffGb9yvUCTQ4irztH1e/LbgG1AvCKVc+E=, lt 39276268000005.
    val body = parseCellFromBase64("te6cckEBAgEAhAABuQ+KfqUAAAAAAAAAAILzCGT3IV3FmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAlu59b2YRUreeJKkJj/yg3lLc0ARV9+B/S479VyXQQOUQEAAAAAQEAQ4AS3c+t7MIqVvPElSEx/5QbyluaAIq+/A/pcd+q5LoIHLAGzZWh");
    val decoded = MegatonExchangeLpTransferCallback.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(3400365394439298137);
    expect(decoded.forwardTonAmount).toEqual(1);
    expect(decoded.forwardPayload.remainingRefsCount()).toEqual(0);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real administrator replacement`() {
    // Toncenter transaction AZ2YdO3G3EtI+K09kEC4YRC2MSSx971SdmDCm1KFT9E=, lt 57474681000001.
    val body = parseCellFromBase64("te6cckEBAQEAMAAAW2ZEfa0AAAAAAAAAAIAQnSDh+HGGP7o3NW91AQaSs16J0Njp8kMGKIAEnmuW1fDexv4i");
    val decoded = MegatonExchangeChangeAdmin.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.adminAddress).toEqual(
        address("0:84E9070FC38C31FDD1B9AB7BA80834959AF44E86C74F921831440024F35CB6AF"),
    );
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP metadata replacement`() {
    // Toncenter transaction UQvk860uAgZlFKv7BuV5qXQJIlegI3/R5LdJ5K2QhKU=, lt 41809614000005.
    val body = parseCellFromBase64("te6cckECEAEAAVoAARh0P45YAAAAAAAAAAABAQMAwAICASADBAFDv/CC62Y7V6ABkvSmrEZyiN8t/t252hvuKPZSHIvr0h8ewAUCASAGBwBCAGh0dHBzOi8vbWVnYXRvbi5maS9scC1zeW1ib2wucG5nAgEgCAkCASAMDQFBv0VGpv/ht5z92GutPbh0MT3N4vsF5qdKp/NVLZYXx50TCgFBv27U+UKnhIziywZrd6ESjGof+MQ/Q4otziRhK6n/q4sDCwAsAE1lZ2F0b24gTFAgb0FQTS1vVVNEQwAgAG9BUE0tb1VTREMgTUdMUAFBv1II3vRvWh1Pnc5mqzCfSoUTBfFm+R73nZI+9Y40+aIJDgFBv10B+l48BpAcRQRsay3c6lr3ZP6g7tcqENQE8jEs6yR9DwBSAExpcXVpZGl0eSBQb29sIFRva2VucyBvbiBNZWdhdG9uIEZpbmFuY2UABgAxOBB3gMQ=");
    val decoded = MegatonExchangeChangeContent.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.content.beginParse().remainingRefsCount() > 0).toBeTrue();
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real outgoing jetton transfer`() {
    // Toncenter transaction QY1qzkmIVnrnYm25wKnBctuGfxXmWz+/LKFJcb+Zn1Q=, lt 53664798000003.
    val body = parseCellFromBase64("te6cckEBAQEAXAAAtA+KfqUAAAAAAAAAAKGXaaM35KnidOgIASs/8YQzcGuQjxXQL++VmJBpT+1rtEHaa4Y5GTfAKfoFACVn/jCGbg1yEeK6Bf3ysxINKf2tdog7TXDHIyb4BT9AgBGB3Sc=");
    val decoded = MegatonExchangeJettonTransfer.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(120246989236003456634496);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real swap event`() {
    // Toncenter transaction Tyi/0VtEuIrM1uzTI9gmq1/47nmx6mZV8eQVwlbRupY=, lt 53538819000001.
    val body = parseCellFromBase64("te6cckEBAgEAfQABo3Ni0JyAHDIEwexiRKGdRggVTjd0wpVXbf8NT9ojCBVVqDeGfQEwAZKEYNlBuu7Y/ED6AHxpbW/VZfDy26HxjuhRjAA7gwQGgZChmgnJZ8umSWABAEuAF1qQgjLp/K17zbt3jCRTHizbvtfLqggqLspAmbdeHr4oP7nc8/RIMFM=");
    val decoded = MegatonExchangeSwapEvent.fromCell(body);
    expect(decoded.inputAmount).toEqual(29561369040123899844901);
    expect(decoded.result.load().amount).toEqual(534572665);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real mining update event`() {
    // Toncenter transaction bj/xlge0LNXZf3+tcroWgavEATzxcpjzscYE+LWM3q4=, lt 54305408000003.
    val body = parseCellFromBase64("te6cckEBAgEAqwABy1ao6SCAFQ4u5vb6sHWhtBPV1IHvAT2IbeB8WT6fMLCkMv/SNvAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABWdtPK9rsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE8hl0AEAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAArO2nle12AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACeQy414IGn");
    val decoded = MegatonExchangeMiningUpdateEvent.fromCell(body);
    expect(decoded.lastMined).toEqual(12168750006230400);
    expect(decoded.lastIndex).toEqual(10371886);
    expect(decoded.previous.load().lastMined).toEqual(12168750006230400);
    expect(decoded.previous.load().lastIndex).toEqual(10371886);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real Router reward delivery`() {
    // Toncenter transaction D3Rp/+BbKsyXQ+czucxiLCTydwBp5vyU2ZJBWkC41KY=, lt 53664674000003.
    val body = parseCellFromBase64("te6cckEBAQEANQAAZWsUz+EAAAAAAAAAAIASs/8YQzcGuQjxXQL++VmJBpT+1rtEHaa4Y5GTfAKfoEpVSC8fu1A9h/8=");
    val decoded = MegatonExchangeRouterClaimReward.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.rewardAmount).toEqual(183141634013);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP burn instruction`() {
    // Toncenter transaction QY1qzkmIVnrnYm25wKnBctuGfxXmWz+/LKFJcb+Zn1Q=, lt 53664798000003.
    val body = parseCellFromBase64("te6cckEBAQEAOgAAcFlfB7wAAAAAAAAAAKFSd9vGuO6INRl4ASs/8YQzcGuQjxXQL++VmJBpT+1rtEHaa4Y5GTfAKfoEK+pTWg==");
    val decoded = MegatonExchangeLpBurnInstruction.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(99898179393949115044247);
    expect(decoded.customPayload).toBeNull();
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP burn event`() {
    // External event from transaction QY1qzkmIVnrnYm25wKnBctuGfxXmWz+/LKFJcb+Zn1Q=.
    val body = parseCellFromBase64("te6cckEBAQEATAAAk1lfB7yAErP/GEM3BrkI8V0C/vlZiQaU/ta7RB2muGORk3wCn6BUKlEwhRbE5RAdF0Kk77eNcd0QajL0Mu00ZvyVPE6dAIw7OTiQiW5AYA==");
    val decoded = MegatonExchangeBurnEvent.fromCell(body);
    expect(decoded.supplyBefore).toEqual(99918537388108104076939);
    expect(decoded.lpAmount).toEqual(99898179393949115044247);
    expect(decoded.tokenAAmount).toEqual(120246989236003456634496);
    expect(decoded.tokenBAmount).toEqual(1641662916);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real excess response`() {
    // Toncenter transaction QY1qzkmIVnrnYm25wKnBctuGfxXmWz+/LKFJcb+Zn1Q=, lt 53664798000003.
    val body = parseCellFromBase64("te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=");
    val decoded = MegatonExchangeExcesses.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP-wallet liquidity update`() {
    // Toncenter transaction zjb5rMM8L73i83j8IcOG6JIGBlC856bv1rEYwx11NGk=, lt 37966227000007.
    val body = parseCellFromBase64("te6cckEBAQEAXwAAuXcbHGcAAAAAAAAAAIAS3c+t7MIqVvPElSEx/5QbyluaAIq+/A/pcd+q5LoIHKWGoQAutSEEZdP5Wvebdu8YSKY8Wbd9r5dUEFRdlIEzbrw9fGD55Bu2UYjAALBXIF5+pYY=");
    val decoded = MegatonExchangeLpWalletLiquidityUpdate.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(50000);
    expect(decoded.accountingAmount0).toEqual(4501636920000000000);
    expect(decoded.accountingAmount1).toEqual(49500);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP internal transfer`() {
    // Toncenter transaction xpgsn0NHB9ffGb9yvUCTQ4irztH1e/LbgG1AvCKVc+E=, lt 39276268000005.
    val body = parseCellFromBase64("te6cckEBAQEAXwAAuReNRRkAAAAAAAAAAILzCGT3IV3FmAEt3PrezCKlbzxJUhMf+UG8pbmgCKvvwP6XHfquS6CBywAlu59b2YRUreeJKkJj/yg3lLc0ARV9+B/S479VyXQQOUQEAAAAAb686bQ=");
    val decoded = MegatonExchangeLpInternalTransfer.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(3400365394439298137);
    expect(decoded.forwardTonAmount).toEqual(1);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real LP mint event`() {
    // Toncenter transaction UfzjzATtsOakWsUtqlAN/1K02rCql5wnlZH27kvaiiQ=, lt 37966227000011.
    val body = parseCellFromBase64("te6cckEBAQEARwAAiQAAABWAEt3PrezCKlbzxJUhMf+UG8pbmgCKvvwP6XHfquS6CBy2B8mb6fGlln8RLWsF5hDJ7kK7izB+M+iL4Jqe9FhqEP8BI1Q=");
    val decoded = MegatonExchangeMintEvent.fromCell(body);
    expect(decoded.supplyBefore).toEqual(4707276251563786955691701);
    expect(decoded.lpAmount).toEqual(3400365394439298137);
    expect(decoded.tokenAAmount).toEqual(4546933880028745594);
    expect(decoded.tokenBAmount).toEqual(50000);
    expectExactBody(decoded.toCell(), body);
}

get fun `test megaton exchange decodes a real mining-rate event`() {
    // Toncenter transaction lthb0GiS5VVzKYDgh0H4dfCqnqCQQL7+2vp7dyRguMQ=, lt 54301466000001.
    val body = parseCellFromBase64("te6cckEBAQEAQAAAe3CuHzSAFQ4u5vb6sHWhtBPV1IHvAT2IbeB8WT6fMLCkMv/SNvAAAAGNgAAAAAzYqwYAAAAAAAAAAAz3fBYQYXioaw==");
    val decoded = MegatonExchangeMiningRateEvent.fromCell(body);
    expect(decoded.currentRate).toEqual(3180);
    expect(decoded.currentStartsAt).toEqual(1724209200);
    expect(decoded.nextRate).toEqual(0);
    expect(decoded.nextStartsAt).toEqual(1740366000);
    expectExactBody(decoded.toCell(), body);
}
