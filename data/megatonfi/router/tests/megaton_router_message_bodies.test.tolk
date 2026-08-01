import "@acton/fmt"
import "@acton/testing/expect"
import "../types/megaton_router.types"

get fun `test megaton router decodes real pool creation body`() {
    // Toncenter transaction KeG0rI+A1ObgmijasdkjL2riPnh3Bd6Ueyh8YD0u24M=, LT 35737415000003.
    val bodyBoc = "te6cckEBAgEAnQABqVM3Di4AAAAAAAAAAIAXWpCCMun8rXvNu3eMJFMeLNu+18uqCCouykCZt14evjADtSJyon/pvLOyVFhMkXZi3/VUvl+jCzlA/ye/ZTsVdexCgAATiCABAIWAD+z1iUhvEGcq+DVr0fWL8Z+EnJ3qy2YbRuRsTqTHYcrwARamVRhE7pLB8wtMHUHfm5aY3IL8kB5bEHDG7IC2hLCOvTwb5g==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterCreatePool.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.token0).toEqual(address("kQC61IQRl0_la95t27xhIpjxZt32vl1QQVF2UgTNuvD18dQy"));
    expect(decoded.token1).toEqual(address("kQDtSJyon_pvLOyVFhMkXZi3_VUvl-jCzlA_ye_ZTsVde2xQ"));
    expect(decoded.fee).toEqual(10);
    expect(decoded.parameter).toEqual(20000);
    val addresses = decoded.addresses.load();
    expect(addresses.address0).toEqual(address("kQB_Z6xKQ3iDOVfBq16PrF-M_CTk71ZbMNo3I2J1JjsOV4ll"));
    expect(addresses.address1).toEqual(address("kQBFqZVGETuksHzC0wdQd-blpjcgvyQHlsQcMbsgLaEsI-s3"));
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real pool registration callback`() {
    // Toncenter transaction GHv45SV3xopz5uVkyie1+He6+Twy63616RdZl+1JfN4=, LT 35737415000007.
    val bodyBoc = "te6cckEBAQEAUwAAofLIaCsAAAAAAAAAAIAXWpCCMun8rXvNu3eMJFMeLNu+18uqCCouykCZt14evjADtSJyon/pvLOyVFhMkXZi3/VUvl+jCzlA/ye/ZTsVdexCoJQcrhs=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterPoolCreated.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.token0).toEqual(address("kQC61IQRl0_la95t27xhIpjxZt32vl1QQVF2UgTNuvD18dQy"));
    expect(decoded.token1).toEqual(address("kQDtSJyon_pvLOyVFhMkXZi3_VUvl-jCzlA_ye_ZTsVde2xQ"));
    expect(decoded.poolTonAmount).toEqual(10);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real external pool registration event`() {
    // Outgoing body in Toncenter transaction GHv45SV3xopz5uVkyie1+He6+Twy63616RdZl+1JfN4=.
    val bodyBoc = "te6cckEBAQEAbgAA1/LIaCuADjp4TVkAakG9lX8Jv8wMn8VxU8klAJPOG61ljfM4zC0wAutSEEZdP5Wvebdu8YSKY8Wbd9r5dUEFRdlIEzbrw9fGAHakTlRP/TeWdkqLCZIuzFv+qpfL9GFnKB/k9+ynYq69iFAA1Ly/dP0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterPoolRegisteredEvent.fromCell(body);
    expect(decoded.poolAddress).toEqual(
        address("0:71D3C26AC803520DECABF84DFE6064FE2B8A9E4928049E70DD6B2C6F99C66169"),
    );
    expect(decoded.token0).toEqual(address("kQC61IQRl0_la95t27xhIpjxZt32vl1QQVF2UgTNuvD18dQy"));
    expect(decoded.token1).toEqual(address("kQDtSJyon_pvLOyVFhMkXZi3_VUvl-jCzlA_ye_ZTsVde2xQ"));
    expect(decoded.poolTonAmount).toEqual(10);
    expect(decoded.poolCount).toEqual(26);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real transfer notification`() {
    // Toncenter transaction k1+ZSHtXkfosCpPjoPy6gG/5QofAaDlZ+0t+9LSxQew=, LT 35700853000020.
    val bodyBoc = "te6cckEBAgEAVwABYHNi0JwAAAAAAAAAACU5yAFDOwbge/dwlGce4QmlRUEJl9SI7H94P2w+nFKZ/LpFIAEAQ4AB6hthNgECF3I1PtgocZkovOqhew30mhZlXDKWH5Ir5RBvh+Hz";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterJettonTransferNotification.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(21404);
    expect(decoded.sender).toEqual(address("kQChnYNwPfu4SjOPcITSoqCEy-pEdj-8H7YfTilM_l0ikKlC"));
    expect(decoded.route.remainingBitsCount()).toEqual(1);
    expect(decoded.route.remainingRefsCount()).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real pool address update request`() {
    // Toncenter transaction Pe+dDPCtNHwrXwPR6D4fxfDxGPlNdpJBUCuKY8pVf+4=, LT 35742278000003.
    val bodyBoc = "te6cckEBAQEAUQAAnTNz+gAAAAAAAAAAAIARLNbOMQHmma4TKYiIQ624NyDhwO7kvLO9I2zU5fYhnPAAxC3GzQBgjlvW6CJAwgaHvarTfVxo8p7Be/6RMSjsPkosyCjA";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterSetPoolAddress.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.poolAddress).toEqual(
        address("kQCJZrZxiA80zXCZTERCHW3BuQcOB3cl5Z3pG2anL7EM5_XE"),
    );
    expect(decoded.newAddress).toEqual(address("kQAxC3GzQBgjlvW6CJAwgaHvarTfVxo8p7Be_6RMSjsPkpUm"));
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real direct-transfer flag update`() {
    // Toncenter transaction 0nylXGIwIrp01R76zqAoxKNFywQ/I2xz5E9UTFGJhCc=, LT 35742080000003.
    val bodyBoc = "te6cckEBAQEADwAAGXLuboAAAAAAAAAAAMA7Q36R";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterSetDirectTransfer.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.enabled).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real jetton transfer`() {
    // Outgoing body in Toncenter transaction k1+ZSHtXkfosCpPjoPy6gG/5QofAaDlZ+0t+9LSxQew=.
    val bodyBoc = "te6cckEBAQEAVAAApA+KfqUAAAAAAAAAACU5yAAeobYTYBAhdyNT7YKHGZKLzqoXsN9JoWZVwylh+SK+UQAD1DbCbAIELuRqfbBQ4zJRedVC9hvpNCzKuGUsPyRXygDlo2Ua";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterJettonTransfer.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(21404);
    expect(decoded.destination).toEqual(
        address("kQAPUNsJsAgQu5Gp9sFDjMlF51UL2G-k0LMq4ZSw_JFfKIdi"),
    );
    expect(decoded.responseDestination).toEqual(
        address("kQAPUNsJsAgQu5Gp9sFDjMlF51UL2G-k0LMq4ZSw_JFfKIdi"),
    );
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real routed jetton transfer payload`() {
    // Outgoing body in Toncenter transaction VD8zUZ2m0adRTvdwIvd80QUbyOgLlhCplYtSTepGmOo=.
    val bodyBoc = "te6cckEBAgEAywABsA+KfqUAAAAAAAAAAECPDRgIAODGPvrVqUohxxBNNvG4IpmjwEv5Cxogni3zJY6z30P5AC8shvpRr3h+Eol0KC7fhwg7qaLbmuANitq2iWk48rkWyBfXhAEBANuAF1qQgjLp/K17zbt3jCRTHizbvtfLqggqLspAmbdeHr4wA7KEBUQSrjnvC0ITChCnRBnC3L70gsNLOB+35AnK0s02AF5ZDfSjXvD8JRLoUF2/DhB3U0W3NcAbFbVtEtJx5XItyJM8I0zt3ufPzJGxxHM=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterJettonTransfer.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(150000000);
    expect(decoded.destination).toEqual(
        address("kQBwYx99atSlEOOIJpt43BFM0eAl_IWNEE8W-ZLHWe-h_ODU"),
    );
    expect(decoded.responseDestination).toEqual(
        address("kQC8shvpRr3h-Eol0KC7fhwg7qaLbmuANitq2iWk48rkW7Hh"),
    );
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(200000000);
    expect(decoded.forwardPayload).toBeNotNull();

    val payload = decoded.forwardPayload!.load();
    expect(payload.token0).toEqual(address("kQC61IQRl0_la95t27xhIpjxZt32vl1QQVF2UgTNuvD18dQy"));
    expect(payload.token1).toEqual(address("kQDsoQFRBKuOe8LQhMKEKdEGcLcvvSCw0s4H7fkCcrSzTW35"));
    expect(payload.sender).toEqual(address("kQC8shvpRr3h-Eol0KC7fhwg7qaLbmuANitq2iWk48rkW7Hh"));
    expect(payload.routeAmount).toEqual(339500596335786916345);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real pool address update`() {
    // Outgoing body in Toncenter transaction Pe+dDPCtNHwrXwPR6D4fxfDxGPlNdpJBUCuKY8pVf+4=.
    val bodyBoc = "te6cckEBAQEAMAAAWxQD0noAAAAAAAAAAIAGIW42aAMEct63QRIGEDQ97Vab6uNHlPYL3/SJiUdh8lCQ3LEH";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterPoolSetAddress.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.newAddress).toEqual(address("kQAxC3GzQBgjlvW6CJAwgaHvarTfVxo8p7Be_6RMSjsPkpUm"));
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real pool mining share update`() {
    // Outgoing body in Toncenter transaction 5oGFmpvSPzgevVgzYabx5sOA89pAYeLwTenK7V9HvRw=.
    val bodyBoc = "te6cckEBAQEAGgAAMHCuHzQAAAAAAAAAAAAAAAAAAAAAY/asgOkz9xQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterPoolMiningShare.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.share).toEqual(0);
    expect(decoded.scheduleValue).toEqual(1677110400);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test megaton router decodes real pool content update`() {
    // Outgoing body in Toncenter transaction ddyvBe+67RriYmNHaTDLAlyw3263UU77P6E5JkQ1mYE=.
    val bodyBoc = "te6cckECDQEAAQAAARh0P45YAAAAAAAAAAABAQMAwAICAVgDBAIBIAUGAgEgCQoBQb9FRqb/4bec/dhrrT24dDE9zeL7BeanSqfzVS2WF8edEwcBQb9u1PlCp4SM4ssGa3ehEoxqH/jEP0OKLc4kYSup/6uLAwgAKgBNZWdhdG9uIExQIG9VU0RDLW9FTAAKAE1HTFABQb9SCN70b1odT53OZqswn0qFEwXxZvke952SPvWONPmiCQsBQb9dAfpePAaQHEUEbGst3Opa92T+oO7XKhDUBPIxLOskfQwAUgBMaXF1aWRpdHkgUG9vbCBUb2tlbnMgb24gTWVnYXRvbiBGaW5hbmNlAAQANvyPeA4=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = MegatonRouterPoolChangeContent.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
