import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_vamm.types"

const EXECUTE_ORDER_TRADER_ADDRESS = "0:055A02086A37F850761EF6AA1231D961B3445A549790A76BF759C0919DF8C5FB"
const EXECUTE_ORDER_PREV_ADDRESS = "0:9E7E69CD0D8CA689A61F3EBBA57E5DC855484A4C435D878C58B6ED8522A75F48"
const STORM_VAMM_CHANGE_SETTINGS_REDIRECT = "kQC9f70C9AgkN4llMaPMw6PejjIqYBh5LnJYxtkROVO7Oze8"

fun bodyFromBoc(bodyBoc: string): cell {
    return parseCellFromBase64(bodyBoc);
}

fun expectOpcode(body: cell, expectedOpcode: uint32): void {
    val raw = body.beginParse();
    expect(raw.remainingBitsCount()).toBeGreater(31);
    expect(raw.preloadUint(32)).toEqual(expectedOpcode);
}

get fun `test decodes toncenter storm vamm execute_order body`() {
    val txHash = "Oi0msWhPfQGolv7RNcAak8ph50UzWIKXUBf14qcbKSU=";
    val body = bodyFromBoc("te6cckECBwEAARQAA5feHdvMiAAKtAQQ1G/woOw97VQkY7LDZoi0qS8hTtfus4EjO/GL9wAnn5pzQ2MpommHz67pX5dyFVISkxDXYeMWLbthSKnX0gAAAAAoAQIDADM2okKFeoG/COsAAAAAALLQXgAChf2zttiAQABn//////////////9/jOejHaim/+HRYuPkgGTwAAAAADel4OaAB6EgAAAAAAAAAAA1EgUywAEDAEAEAgAFBgBFRdK5w3BqJCfoAAoAAAAAAAAAAAMJ3CUwmsVQAAAAABMS0AgAgapqlRjWot6B+cGQKe1IC5ACwlp7mJRa/FEfuC56wolAi9KR6JZtmgRdOYGg+Dsjcl12GFqL2rBj9BCSjTquzIBgVRNqeA==");
    val decoded = StormExecuteOrder.fromCell(body);
    val position = decoded.position.load();

    expectOpcode(body, 0xde1ddbcc);
    expect(decoded.direction).toEqual(1);
    expect(decoded.orderIndex).toEqual(0);
    expect(decoded.traderAddr).toEqual(address(EXECUTE_ORDER_TRADER_ADDRESS));
    expect(decoded.prevAddr).toEqual(address(EXECUTE_ORDER_PREV_ADDRESS));
    expect(decoded.refAddr).toBeNull();
    expect(decoded.executorIndex).toEqual(2);
    expect(decoded.order.hash()).toBeGreater(0);
    expect(position.size).toEqual(-551686790371);
    expect(position.direction).toEqual(1);
    expect(position.margin).toEqual(89657195052);
    expect(position.openNotional).toEqual(858070764000);
    expect(decoded.oraclePayload.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_EXECUTE_ORDER_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm complete_order body`() {
    val txHash = "Oi0msWhPfQGolv7RNcAak8ph50UzWIKXUBf14qcbKSU=";
    val body = bodyFromBoc("te6cckEBBAEAkAADJM+Q1hgxpVv5I0XSucN0O5rKAAECAwBn//////////////9yPcfUKKjC4qm4Yu5LZg3wAAAAADem+PeAB6EgAAAAAAAAAAA1EhP0QABdgEI6cXPuL8u0EGPy+XuhZykFms12UDLZZjUbYmot0rChBopa3X3CfGRGh9oZDjgAHwMJ3CUwmsVQAAAAABMS0Ahm5GOW");
    val decoded = StormCompleteOrder.fromCell(body);
    val marketDepth = decoded.marketDepth.load();

    expectOpcode(body, 0xcf90d618);
    expect(decoded.orderType).toEqual(3);
    expect(decoded.orderIndex).toEqual(0);
    expect(decoded.direction).toEqual(1);
    expect(decoded.originOpcode).toEqual(0xa55bf923);
    expect(decoded.indexPrice).toEqual(1563139127);
    expect(decoded.settlementOraclePrice).toEqual(1000000000);
    expect(decoded.position.hash()).toBeGreater(0);
    expect(decoded.amm.hash()).toBeGreater(0);
    expect(marketDepth.vpiCoefficient).toEqual(20000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COMPLETE_ORDER_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm vault_trade body`() {
    val txHash = "Oi0msWhPfQGolv7RNcAak8ph50UzWIKXUBf14qcbKSU=";
    val body = bodyFromBoc("te6cckEBAgEAhwAB8jR1/dIACgAAAAADwU3AAAAAA3eh4wD/////eB+zIAAAAAA6O46pAAAAADvXi2kAAAAAAAAAAIAAq0BBDUb/Cg7D3tVCRjssNmiLSpLyFO1+6zgSM78Yv3ACefmnNDYymiaYfPrulfl3IVUhKTENdh4xYtu2FIqdfSEBABGgCJVEAAAAABTnugoa");
    val decoded = StormVaultTradeNotification.fromCell(body);
    val executorParams = decoded.executorParams!.load();

    expectOpcode(body, 0x3475fdd2);
    expect(decoded.ammIndex).toEqual(10);
    expect(decoded.freeAmount).toEqual(63000000);
    expect(decoded.lockedAmount).toEqual(14892000000);
    expect(decoded.exchangeAmount).toEqual(-2279623904);
    expect(decoded.withdrawLockedAmount).toEqual(976981673);
    expect(decoded.feeToStakers).toEqual(1003981673);
    expect(decoded.withdrawAmount).toEqual(0);
    expect(decoded.traderAddr).toEqual(address(EXECUTE_ORDER_TRADER_ADDRESS));
    expect(decoded.originAddr).toEqual(address(EXECUTE_ORDER_PREV_ADDRESS));
    expect(decoded.referralParams).toBeNull();
    expect(decoded.executorParams).toBeNotNull();
    expect(executorParams.splitExecutorRewards).toBeTrue();
    expect(executorParams.amount).toEqual(18000000);
    expect(executorParams.index).toEqual(2);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_VAULT_TRADE_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm update_position body`() {
    val txHash = "Dyk+hgikqd2dEtnF854hS8n2S3yyFx/m560949lRhjQ=";
    val body = bodyFromBoc("te6cckEBAwEAfQACI2Dfxnf2b2oTIuVdKGIdzWUAQAECAGf//////////////6GCMVfPqFTbJn/iyltAcEKAAAAAN6TKsgAHoSAAAAAAAAAAADUR+ErAAF2AQjpxc+4vy7QQTaLRe6FnKQWazXZRMxNcwiliZzmMGGaWi+R7pO9CZEIJ1WVYiDxwzxQ=");
    val decoded = StormUpdatePosition.fromCell(body);

    expectOpcode(body, 0x60dfc677);
    expect(decoded.direction).toEqual(1);
    expect(decoded.originOpcode).toEqual(0xecded426);
    expect(decoded.indexPrice).toEqual(1554752780);
    expect(decoded.settlementOraclePrice).toEqual(1000000000);
    expect(decoded.position.hash()).toBeGreater(0);
    expect(decoded.amm.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_UPDATE_POSITION_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm change_settings body`() {
    val txHash = "evreSGZkJp0pogHZS3OAqU3uqEPKPQpujwc7FOHKAlM=";
    val body = bodyFromBoc("te6cckEBBgEA6gABS+3NNqaAF6/3oF6BBIbxLKY0eZh0e9HGRUwDDyXOSxjbIicqd2dwAQHZAA9CQAAAAAAAAA4QAmJaAABMS0AATEtAO5rKAAExLQAAJJ8AAtxsAG41+pMaAAEeGjAJXRqUogAO5rKACAAAAAAAST4AAAAAAADDUAf//////kiMAAAAAAADbugAAAAAAWWgvAAAGGoAAAAAVAICASADBAFDv9vxLtlhEK7d/I38OyZUXPAKqHHhoGSyPRq0DRIc1T5iwAUBQ7/PPzTmhsZTRNMPn13Svy7kKqQlJiGuw8YsW3bCkVOvpEAFAAALWq8b");
    val decoded = StormChangeSettings.fromCell(body);
    val settings = decoded.settings.load();

    expectOpcode(body, 0xedcd36a6);
    expect(decoded.redirectAddr).toEqual(address(STORM_VAMM_CHANGE_SETTINGS_REDIRECT));
    expect(settings.fee).toEqual(1000000);
    expect(settings.rolloverFee).toEqual(0);
    expect(settings.fundingPeriod).toEqual(3600);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_CHANGE_SETTINGS_TX={}", txHash);
}
