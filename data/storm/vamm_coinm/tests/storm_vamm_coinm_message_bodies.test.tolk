import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_vamm_coinm.types"

const COINM_TRADER_ADDRESS = "0:615BA705CA21DDDCE4EE70D1CA18ECD346D2C276254B912B97A2AD09EFD9C5A3"
const COINM_PREV_ADDRESS = "0:9E7E69CD0D8CA689A61F3EBBA57E5DC855484A4C435D878C58B6ED8522A75F48"
const COINM_VAMM_ADDRESS = "0:241E480E9ADB0CDF40E2E3EC3BB0CF524FB520CCA02B2E292E734817BC291FFB"
const COINM_TAKE_POSITION_TRADER = "0:2491492572B7FF8827166A1B833698C7EC1C33CF6DF876D04961D0E763E428BA"
const COINM_SMART_ACCOUNT_FACTORY = "0:37E25DB2C2215DBBF91BF8764CA8B9E01550E3C340C9647A35681A2439AA7CC5"
const COINM_NATIVE_VAULT = "0:E926764FF3D272C73DDEB836975C5521C025AD68E7919A25094E2DE3198805F1"
const COINM_CHANGE_SETTINGS_REDIRECT = "kQC9f70C9AgkN4llMaPMw6PejjIqYBh5LnJYxtkROVO7Oze8"
const COINM_TAKE_POSITION_SMART_ACCOUNT = "0:021D96782F8CE9C9A44917F48ACF87EA613D5B0CB06A61E244D9542826CD738E"

fun bodyFromBoc(bodyBoc: string): cell {
    return parseCellFromBase64(bodyBoc);
}

fun expectOpcode(body: cell, expectedOpcode: uint32): void {
    val raw = body.beginParse();
    expect(raw.remainingBitsCount()).toBeGreater(31);
    expect(raw.preloadUint(32)).toEqual(expectedOpcode);
}

get fun `test decodes toncenter storm vamm coinm execute_order body`() {
    val txHash = "O8JgmWpNomD/m205j7IbABrIBne+8fJVwkr/bTHcN2M=";
    val body = bodyFromBoc("te6cckECDAEAAeEAA5feHdvMiADCt04LlEO7ucnc4aOUMdmmjaWE7EqXIlcvRVoT37OLRwAnn5pzQ2MpommHz67pX5dyFVISkxDXYeMWLbthSKnX0gAAAAAoAQIDAB0AAAAACpBMfwNDovsPBIQAZ///////////////32cB+XmoNCfoYQKZObY7DgAAAAAYkNFrgAehIAAAAAAAAAAANRIHREACAwMgBAUEAAYHCAkCAgAKCwBFRfZhP4BqJCwvAAoAAAAAAAAAAAMK44wwn0nAAAAAABMS0AgAgafUVfLI5fGSpxCicW9ybtqwV4ICWUtjrgzpJid3MeyfeF3tQ1KlGFr+O8LU3io8ljV63kos0YikSN3STy2l7IBgAEVF9hHxgGokLC8ACgAAAAAAAAAAAwrjjDCfScAAAAAAExLQCACBoohsQ3GxiIv7DfmjGyj2lOMTesKlf/i4osAfXeBAzmzSrxMq8XiH7QbcYcht1t2qZAer8OtaqyPwyIUH6y25BeAARUXD/yuwaiQOiAAKAAAAAAAAAAADDDmrMLC7UAAAAAATEtAIAIHe85Q+DBEl3bGX0Y8xbBiNFSqgDJCzooCLlQ5ywNgP4hYBy6WCAd69LGVHjD0F6FcWyd//0udXicPvVODZWQsEYGUC3bw=");
    val decoded = StormExecuteOrder.fromCell(body);

    expectOpcode(body, 0xde1ddbcc);
    expect(decoded.direction).toEqual(1);
    expect(decoded.orderIndex).toEqual(0);
    expect(decoded.traderAddr).toEqual(address(COINM_TRADER_ADDRESS));
    expect(decoded.prevAddr).toEqual(address(COINM_PREV_ADDRESS));
    expect(decoded.refAddr).toBeNull();
    expect(decoded.executorIndex).toEqual(2);
    expect(decoded.order.hash()).toBeGreater(0);
    expect(decoded.position.hash()).toBeGreater(0);
    expect(decoded.oraclePayload.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_EXECUTE_ORDER_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm take_position body`() {
    val txHash = "80dApI+X78iPam8sI5lEZUYdmUzKcvX+178dYnQRT5k=";
    val body = bodyFromBoc("te6cckECDAEAAjIABG0b6lDxAAAAAGokFbEgASDyQHTW2Gb6BxcfYd2GepJ9qQZlAVlxSXOaQL3hSP/YBL68IAAAAAADAQIDBADJgASSKSSuVv/xBOLNQ3Bm0xj9g4Z57b8O2gksOhzsfIUXUADfiXbLCIV27+Rv4dkyoueAVUOPDQMlkejVoGiQ5qnzFgB0kzsn+ek5Y57vXBtLriqQ4BLWtHPIzRKEpxbxjMQC+MAAR9IAdctUsF3RmTy0jETjQ3sIk1nuk6dWFcRGPVzLNj5D6R6yQABjAAAAAAAAAAAAAAAACuYf3SArmH96CHHe3IAAAAAYkNFrgAGGoBfXhAAAAAAANRIFk0ACgQ+K3M3pmJhoOpOu26tha4/GAQoWI+kWCUu6m88FU1V4NQWi9GK16tJpZI97M3HzpAk5cluUlwqFO5tGklPJWIUgBQYBTgAA3NRIK1Zj8vrukaE7hC3xQEXHYLZvU/WdUIjubDdtbbUZpG5voAcBAwFACQGFgASDyQHTW2Gb6BxcfYd2GepJ9qQZlAVlxSXOaQL3hSP/cAAIdlngvjOnJpEkX9IrPh+phPVsMsGph4kTZVCgmzXOOggAExaiQW1yBXMP7oQEAAoLCgsARUW5h7ZgaiQVqwAKAAAAAAAAAAADChxrMKAB8AAAAAATEtAIAIGVS5av5VoPAv0iuD7oz+5sjrdy5r2htS2iTW4tG8mfFvGlk+iUqaJ/36nCQAx7QWJ0AR/H3J/fefAKz7T8j90EYCG7ajg=");
    val decoded = TakePositionV2.fromCell(body);
    val addresses = decoded.addresses.load();

    expectOpcode(body, 0x1bea50f1);
    expect(decoded.queryId).toEqual(1780749745);
    expect(decoded.bundleSenderAddress).toBeNull();
    expect(decoded.ammAddress).toEqual(address(COINM_VAMM_ADDRESS));
    expect(decoded.direction).toEqual(0);
    expect(decoded.spentAmount).toEqual(0);
    expect(addresses.traderAddress).toEqual(address(COINM_TAKE_POSITION_TRADER));
    expect(addresses.smartAccountFactoryAddress).toEqual(address(COINM_SMART_ACCOUNT_FACTORY));
    expect(addresses.vaultAddress).toEqual(address(COINM_NATIVE_VAULT));
    expect(decoded.ref.toCell().hash()).toBeGreater(0);
    expect(decoded.position.hash()).toBeGreater(0);
    expect(decoded.intent.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_TAKE_POSITION_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm complete_order body`() {
    val txHash = "O8JgmWpNomD/m205j7IbABrIBne+8fJVwkr/bTHcN2M=";
    val body = bodyFromBoc("te6cckEBBAEAhgADJM+Q1hgBXMA63UX2HgkEX2EfGAECAwBTAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAHoSAAAAAAAAAAAAAAAABAAF2AHi5p/KZfXZQtyt2Afn1myIFLO5ZoChNPW91inW9msiNWq4nX0DByZIc6JFJa+AAfAwrjjDCfScAAAAAAExLQCFUv89g=");
    val decoded = StormCompleteOrder.fromCell(body);

    expectOpcode(body, 0xcf90d618);
    expect(decoded.orderType).toEqual(0);
    expect(decoded.orderIndex).toEqual(0);
    expect(decoded.direction).toEqual(1);
    expect(decoded.originOpcode).toEqual(0x5cc03add);
    expect(decoded.indexPrice).toEqual(1600250000);
    expect(decoded.settlementOraclePrice).toEqual(1600200472);
    expect(decoded.position.hash()).toBeGreater(0);
    expect(decoded.amm.hash()).toBeGreater(0);
    expect(decoded.marketDepth.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_COMPLETE_ORDER_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm vault_trade body`() {
    val txHash = "O8JgmWpNomD/m205j7IbABrIBne+8fJVwkr/bTHcN2M=";
    val body = bodyFromBoc("te6cckEBAgEAhwAB8jR1/dIACgAAAAAF13gKAAAAAAAAAAD////+7eDBegAAAAVz5mjdAAAAAAKA6k4AAAAFaeK/p4AMK3TguUQ7u5ydzho5Qx2aaNpYTsSpciVy9FWhPfs4tHACefmnNDYymiaYfPrulfl3IVUhKTENdh4xYtu2FIqdfSEBABGgDVo28AAAABS0dvfl");
    val decoded = StormVaultTradeNotification.fromCell(body);
    val executorParams = decoded.executorParams!.load();

    expectOpcode(body, 0x3475fdd2);
    expect(decoded.ammIndex).toEqual(10);
    expect(decoded.freeAmount).toEqual(98007050);
    expect(decoded.lockedAmount).toEqual(0);
    expect(decoded.exchangeAmount).toEqual(-4599004806);
    expect(decoded.withdrawLockedAmount).toEqual(23419316445);
    expect(decoded.feeToStakers).toEqual(42003022);
    expect(decoded.withdrawAmount).toEqual(23251304359);
    expect(decoded.traderAddr).toEqual(address(COINM_TRADER_ADDRESS));
    expect(decoded.originAddr).toEqual(address(COINM_PREV_ADDRESS));
    expect(decoded.referralParams).toBeNull();
    expect(decoded.executorParams).toBeNotNull();
    expect(executorParams.splitExecutorRewards).toBeTrue();
    expect(executorParams.amount).toEqual(28002014);
    expect(executorParams.index).toEqual(2);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_VAULT_TRADE_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm update_position body`() {
    val txHash = "gybBgla3pIWgtc1jEoFpfu08sqzWdoRnPJQkMSUnQ1Y=";
    val body = bodyFromBoc("te6cckEBAwEAfAACI2Dfxnfc9AhxIvjjUvIvjjUvQAECAGX///////////////VXRXnUpUYHQ7KIbUAlBwAAAAAYkcNWAAehIAAAAAAF9eEANRIVusAAXYAeLmn8pl9dlC3B5Oh+fWbIgUs7lmgKE09b3WKjAFsh4uaridfQMHJkj+73u5JI9l6JeA==");
    val decoded = StormUpdatePosition.fromCell(body);

    expectOpcode(body, 0x60dfc677);
    expect(decoded.direction).toEqual(1);
    expect(decoded.originOpcode).toEqual(0xb9e810e2);
    expect(decoded.indexPrice).toEqual(1595697758);
    expect(decoded.settlementOraclePrice).toEqual(1595697758);
    expect(decoded.position.hash()).toBeGreater(0);
    expect(decoded.amm.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_UPDATE_POSITION_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm trade_notification_v2 body`() {
    val txHash = "80dApI+X78iPam8sI5lEZUYdmUzKcvX+178dYnQRT5k=";
    val body = bodyFromBoc("te6cckEBAwEAuwAC0CjTZJEAAAAAaiQVsQAKAAAAAAAAY/8AAAAAAAAAAP////7H8f8bAAAAAIWz6AcAAAAAhbL1LQAAAAAAAI7bAAAAAAAAAAAcAAIdlngvjOnJpEkX9IrPh+phPVsMsGph4kTZVCgmzXOOAQIAR9IAdctUsF3RmTy0jETjQ3sIk1nuk6dWFcRGPVzLNj5D6R6yQABNEBVpCI4AEg8kB01thm+gcXH2HdhnqSfakGZQFZcUlzmkC94Uj/2QqdHlxw==");
    val decoded = StormTradeNotificationV2.fromCell(body);

    expectOpcode(body, 0x28d36491);
    expect(decoded.queryId).toEqual(1780749745);
    expect(decoded.assetId).toEqual(10);
    expect(decoded.freeAmount).toEqual(25599);
    expect(decoded.lockedAmount).toEqual(0);
    expect(decoded.exchangeAmount).toEqual(-5235409125);
    expect(decoded.withdrawLockedAmount).toEqual(2243160071);
    expect(decoded.feeToStakers).toEqual(2243097901);
    expect(decoded.executorAmount).toEqual(36571);
    expect(decoded.totalReferrerAmount).toEqual(0);
    expect(decoded.refCount).toEqual(1);
    expect(decoded.saAddress).toEqual(address(COINM_TAKE_POSITION_SMART_ACCOUNT));
    expect(decoded.notificationPayload.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_TRADE_NOTIFICATION_V2_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm intent_log body`() {
    val txHash = "80dApI+X78iPam8sI5lEZUYdmUzKcvX+178dYnQRT5k=";
    val body = bodyFromBoc("te6cckEBAwEAVwABCYEuj0DAAQGJoAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA///////ogdkAAAAAAAAx8AAAAAAAAAAAAAMNQAADDUAo7aKO2xHhowCAgAJRbmHtmgvD5oh");
    val decoded = IntentLog2.fromCell(body);

    expectOpcode(body, 0x812e8f40);
    expect(decoded.logDict.isEmpty()).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_INTENT_LOG_TX={}", txHash);
}

get fun `test decodes toncenter storm vamm coinm change_settings body`() {
    val txHash = "hXG5wQ6e3P5gpWV2/n1JLg5Uf+LGLS+PzawGPXV3LBs=";
    val body = bodyFromBoc("te6cckEBBgEA6gABS+3NNqaAF6/3oF6BBIbxLKY0eZh0e9HGRUwDDyXOSxjbIicqd2dwAQHZAA9CQAAAAAAAAA4QAmJaAABMS0AATEtAO5rKAAExLQAAST4AAtxsAG41+pMaAAEeGjAJXRqUogAHfO7syAAAAAAAST4AAAAAAADDUAf//////kiMAAAAAAADbugAAAAAAWWgvAAAGGoAAAAAVAICASADBAFDv9vxLtlhEK7d/I38OyZUXPAKqHHhoGSyPRq0DRIc1T5iwAUBQ7/PPzTmhsZTRNMPn13Svy7kKqQlJiGuw8YsW3bCkVOvpEAFAAClg3vX");
    val decoded = StormChangeSettings.fromCell(body);
    val settings = decoded.settings.load();

    expectOpcode(body, 0xedcd36a6);
    expect(decoded.redirectAddr).toEqual(address(COINM_CHANGE_SETTINGS_REDIRECT));
    expect(settings.fee).toEqual(1000000);
    expect(settings.rolloverFee).toEqual(0);
    expect(settings.fundingPeriod).toEqual(3600);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_VAMM_COINM_CHANGE_SETTINGS_TX={}", txHash);
}
