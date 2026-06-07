import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_position_manager.types"

const STORM_PM_TRADER_ADDRESS = "0:D831EDF7B738514F7C7783719E1F3775BA5AF00BD08226F737BB58C63DB945D1"
const STORM_PM_GAS_ADDRESS = "0:9E7E69CD0D8CA689A61F3EBBA57E5DC855484A4C435D878C58B6ED8522A75F48"
const STORM_PM_REFERRAL_ADDRESS = "0:ECC63E6669C64B30B3AF569CE9EB83E8EB6DBE4BD88D821400ED646A0A4BA85B"
const STORM_PM_ORACLE_HASH = 45895090407197082862010981556196325857740760145762662593883461789485102187196

fun bodyFromBoc(bodyBoc: string): cell {
    return parseCellFromBase64(bodyBoc);
}

fun expectOpcode(body: cell, expectedOpcode: uint32): void {
    val raw = body.beginParse();
    expect(raw.remainingBitsCount()).toBeGreater(31);
    expect(raw.preloadUint(32)).toEqual(expectedOpcode);
}

fun expectTakeProfitOrder(orderCell: cell): void {
    val order = TakeProfitOrder.fromCell(orderCell);

    expect(order.expiration).toEqual(0);
    expect(order.direction).toEqual(0);
    expect(order.amount).toEqual(973833015510);
    expect(order.triggerPrice).toEqual(0);
}

fun expectClosedPosition(position: PositionChange): void {
    expect(position.size).toEqual(0);
    expect(position.direction).toEqual(0);
    expect(position.margin).toEqual(0);
    expect(position.openNotional).toEqual(0);
    expect(position.lastUpdatedCumulativePremium).toEqual(0);
    expect(position.fee).toEqual(950000);
    expect(position.discount).toEqual(50000000);
    expect(position.rebate).toEqual(100000000);
    expect(position.lastUpdatedTimestamp).toEqual(0);
}

fun expectExecuteOrderPosition(position: PositionData): void {
    expect(position.size).toEqual(973833015505);
    expect(position.direction).toEqual(0);
    expect(position.margin).toEqual(498275000000);
    expect(position.openNotional).toEqual(1494825000000);
    expect(position.lastUpdatedCumulativePremium).toEqual(1866402663);
    expect(position.fee).toEqual(950000);
    expect(position.discount).toEqual(50000000);
    expect(position.rebate).toEqual(100000000);
    expect(position.lastUpdatedTimestamp).toEqual(1780704438);
}

get fun `test storm position manager decodes toncenter take referral fees body`() {
    val txHash = "L3UbhIyXK0yChdl7zjzAxVbw3aOsgV2OB8OafjAPktA=";
    val txLt = "46531685000005";
    val body = bodyFromBoc("te6cckEBAgEAEQABCBLZYB0BABAC+vCABfXhANoB0PM=");
    val decoded = StormTakeReferralFees.fromCell(body);
    val referralFees = decoded.referralFees.load();

    expectOpcode(body, 0x12d9601d);
    expect(referralFees.discount).toEqual(50000000);
    expect(referralFees.rebate).toEqual(100000000);

    println("STORM_PM_TAKE_REFERRAL_FEES_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter cancel order body`() {
    val txHash = "LF20oVBHfzZjrBWrccq6FrcReZYvwi0dZjuvk+Mo3y4=";
    val txLt = "47090784000001";
    val body = bodyFromBoc("te6cckEBAQEACAAAC2cTRikxII0bZVo=");
    val decoded = StormCancelOrder.fromCell(body);

    expectOpcode(body, 0x67134629);
    expect(decoded.orderType).toEqual(3);
    expect(decoded.orderIndex).toEqual(0);
    expect(decoded.direction).toEqual(1);
    expect(decoded.gasToAddress).toBeNull();

    println("STORM_PM_CANCEL_ORDER_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter create order body`() {
    val txHash = "bTfU43/PyK72GnQwHH/wlRfYIAgEMTsoXSBUE7Fqy5w=";
    val txLt = "81933628000017";
    val body = bodyFromBoc("te6cckEBAgEAFQABCaOYQ/QSAQAVEAAAAALxXnxIawRIZRuN");
    val decoded = StormCreateOrder.fromCell(body);

    expectOpcode(body, 0xa39843f4);
    expect(decoded.orderType).toEqual(1);
    expect(decoded.gasToAddress).toBeNull();
    expectTakeProfitOrder(decoded.order);

    println("STORM_PM_CREATE_ORDER_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter complete order body`() {
    val txHash = "4CWSCFA62/QOoDh92t85KttBKlD5oPb7CLa/Vt3aHdY=";
    val txLt = "81933639000008";
    val body = bodyFromBoc("te6cckEBBAEAhgADJM+Q1hgSXMA63UXb0ZeEO5rKAAECAwBTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHP3gBfXhAAvrwgAAAAABAAF2AQjpxc+4vy7QQfbJXe6FnKQWazXZQMtlmNRtiaayd2MZmilrdfcJ8ZEW8l7hGOAAfAwrCOzC8XWAAAAAAExLQCPOHo28=");
    val decoded = StormCompleteOrder.fromCell(body);
    val position = decoded.position.load();
    val amm = decoded.amm.load();
    val marketDepth = decoded.marketDepth.load();

    expectOpcode(body, 0xcf90d618);
    expect(decoded.orderType).toEqual(1);
    expect(decoded.orderIndex).toEqual(1);
    expect(decoded.direction).toEqual(0);
    expect(decoded.originOpcode).toEqual(1556101853);
    expect(decoded.indexPrice).toEqual(1572673912);
    expect(decoded.settlementOraclePrice).toEqual(1000000000);
    expectClosedPosition(position);
    expect(amm.quoteAssetReserve).toEqual(298265718617734331);
    expect(amm.quoteAssetReserveWeight).toEqual(276673111);
    expect(amm.baseAssetReserve).toEqual(52379026972060887);
    expect(amm.totalLongPositionSize).toEqual(88179325941019);
    expect(amm.totalShortPositionSize).toEqual(42446253558886);
    expect(amm.openInterestLong).toEqual(152122867696252);
    expect(amm.openInterestShort).toEqual(75161013027939);
    expect(marketDepth.vpiSpread).toEqual(0);
    expect(marketDepth.vpiMarketDepthLong).toEqual(705083);
    expect(marketDepth.vpiMarketDepthShort).toEqual(771542);
    expect(marketDepth.vpiCoefficient).toEqual(20000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PM_COMPLETE_ORDER_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter update position body`() {
    val txHash = "Ds96gbAuRaFkdJA5LQEXKhUDyohrCUydZOmhKMWdDqc=";
    val txLt = "75366034000023";
    val body = bodyFromBoc("te6cckEBAwEAfQACI2Dfxnfc9AhxJVpDrYIdzWUAQAECAGf//////////////4jhB57jrQ8sU4eC9CXG7IAAAAAANW3YjAAHP3gBfXhAAvrwgDT+HOhAAF2AQjpxc+4vy7QeGOfpe6FnKQWazXYVPEQikC9gcIezge8WMQ273r3cYRypuxikmFrEeE4=");
    val decoded = StormUpdatePosition.fromCell(body);
    val position = decoded.position.load();
    val amm = decoded.amm.load();

    expectOpcode(body, 0x60dfc677);
    expect(decoded.direction).toEqual(1);
    expect(decoded.originOpcode).toEqual(3118993634);
    expect(decoded.indexPrice).toEqual(2873652656);
    expect(decoded.settlementOraclePrice).toEqual(1000000000);
    expect(position.size).toEqual(-511620702493);
    expect(position.direction).toEqual(1);
    expect(position.margin).toEqual(695340790000);
    expect(position.openNotional).toEqual(997700000000);
    expect(position.lastUpdatedCumulativePremium).toEqual(1792782616);
    expect(position.fee).toEqual(950000);
    expect(position.discount).toEqual(50000000);
    expect(position.rebate).toEqual(100000000);
    expect(position.lastUpdatedTimestamp).toEqual(1778137552);
    expect(amm.quoteAssetReserve).toEqual(298265718617734331);
    expect(amm.quoteAssetReserveWeight).toEqual(504948713);
    expect(amm.baseAssetReserve).toEqual(52379026972060887);
    expect(amm.totalLongPositionSize).toEqual(23348585336879);
    expect(amm.totalShortPositionSize).toEqual(7733008408305);
    expect(amm.openInterestLong).toEqual(53935056272860);
    expect(amm.openInterestShort).toEqual(19561893169737);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_PM_UPDATE_POSITION_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter provide position body`() {
    val txHash = "LU6vs3KCA4kkGyVg5lJ9Ir/j5Ev9x2cHzHI3oKbFs44=";
    val txLt = "75366034000018";
    val body = bodyFromBoc("te6cckEBBQEAggABGxMHZnCXPQIcSlt/hwjhAQEDAEACAgADBABFSrSHWwBp/DnQAAoAAAAAAAAAAAMNDnow1DyAAAAAABMS0AgAgYgqu4dUYCfkRPh/vTe8Z7m2CpF2vworV8G+xiXUCzxUefewKcq8NCPyVFoZAhmCesmGUungpBEOoTkqEeeT+gbgXC4HUA==");
    val decoded = StormProvidePosition.fromCell(body);

    expectOpcode(body, 0x13076670);
    expect(decoded.direction).toEqual(1);
    expect(decoded.gasToAddress).toBeNull();
    expect(decoded.originOpcode).toEqual(3118993634);
    expect(decoded.amount).toEqual(196490790000);
    expect(
        decoded.oraclePayload.hash(),
    ).toEqual(61045562962740894906395299002492927231807835105386931801520770094655276827100);

    println("STORM_PM_PROVIDE_POSITION_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter provide order body`() {
    val txHash = "mwzvhyHs+RPTZIcSxLGmfkWa1gkrhlCZh+V3Ru8TfHQ=";
    val txLt = "81933639000003";
    val body = bodyFromBoc("te6cckEBBQEAfQABEohltAISAAAAAgEBAwBAAgIAAwQARUXb0ZeAaiQfEgAKAAAAAAAAAAADCsI7MLxdYAAAAAATEtAIAIHnVyyX4TwiKaskfquJW+WNQQYxPCRwd4ct4xeBe+/rsXBsegLGcHXZayP2zaNpDMvnAs3BfHkoKOLqBRAyOK6AYNWuZKg=");
    val decoded = StormProvideOrder.fromCell(body);

    expectOpcode(body, 0x8865b402);
    expect(decoded.orderType).toEqual(1);
    expect(decoded.orderIndex).toEqual(1);
    expect(decoded.direction).toEqual(0);
    expect(decoded.executorIndex).toEqual(2);
    expect(decoded.oraclePayload.hash()).toEqual(STORM_PM_ORACLE_HASH);

    println("STORM_PM_PROVIDE_ORDER_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter order created body`() {
    val txHash = "bTfU43/PyK72GnQwHH/wlRfYIAgEMTsoXSBUE7Fqy5w=";
    val txLt = "81933628000017";
    val body = bodyFromBoc("te6cckEBAQEABwAACoD0xVsSNyz+sA==");
    val decoded = StormOrderCreated.fromCell(body);

    expectOpcode(body, 0x80f4c55b);
    expect(decoded.orderType).toEqual(1);
    expect(decoded.orderIndex).toEqual(1);
    expect(decoded.direction).toEqual(0);

    println("STORM_PM_ORDER_CREATED_TX={} LT={}", txHash, txLt);
}

get fun `test storm position manager decodes toncenter execute order to vamm body`() {
    val txHash = "mwzvhyHs+RPTZIcSxLGmfkWa1gkrhlCZh+V3Ru8TfHQ=";
    val txLt = "81933639000003";
    val body = bodyFromBoc("te6cckECBwEAAScAA9neHdvMGAGwY9vvbnCinvjvBuM8Pm7rdLXgF6EETe5vdrGMe3KLowAnn5pzQ2MpommHz67pX5dyFVISkxDXYeMWLbthSKnX0iAHZjHzM04yWYWderTnT1wfR1tt8l7EbBCgB2sjUFJdQtgAAAAUAQIDABUQAAAAAvFefEhrBABpAAAAAAAAAAAAAADivPiQ0SugHAj2AwCuBUGuIAAAAAA3n4WzgAc/eAF9eEAC+vCANRGyW0ABAwBABAIABQYARUXb0ZeAaiQfEgAKAAAAAAAAAAADCsI7MLxdYAAAAAATEtAIAIHnVyyX4TwiKaskfquJW+WNQQYxPCRwd4ct4xeBe+/rsXBsegLGcHXZayP2zaNpDMvnAs3BfHkoKOLqBRAyOK6AYLA68a8=");
    val decoded = StormExecuteOrderToVamm.fromCell(body);

    expectOpcode(body, 0xde1ddbcc);
    expect(decoded.direction).toEqual(0);
    expect(decoded.orderIndex).toEqual(1);
    expect(decoded.traderAddress).toEqual(address(STORM_PM_TRADER_ADDRESS));
    expect(decoded.previousAddress).toEqual(address(STORM_PM_GAS_ADDRESS));
    expect(decoded.referralAddress).toBeNotNull();
    expect(decoded.referralAddress!).toEqual(address(STORM_PM_REFERRAL_ADDRESS));
    expect(decoded.executorIndex).toEqual(2);
    expectTakeProfitOrder(decoded.order);
    expectExecuteOrderPosition(decoded.position.load());
    expect(decoded.oraclePayload.hash()).toEqual(STORM_PM_ORACLE_HASH);

    println("STORM_PM_EXECUTE_ORDER_TO_VAMM_TX={} LT={}", txHash, txLt);
}
