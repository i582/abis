import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_lp_wallet_v2.types"

get fun `test stonfi lp wallet v2 decodes toncenter burn body`() {
    val txHash = "dZ5VbVraQukF+uma7qXpz7UNvvwIHH249OFljum+PB4=";
    val txLt = "53658015000003";
    val bodyBoc = "te6cckEBAQEAFAAAI1lfB7wAAACJZ7ykhVDjxS9GMeCfU0o=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiLpWalletV2Burn.fromCell(body);

    expect(decoded.queryId).toEqual(590150935685);
    expect(decoded.amount).toEqual(61141611619);
    expect(decoded.responseAddress).toBeNull();
    expect(decoded.customPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_LP_WALLET_V2_TONCENTER_BURN_TX={} LT={}", txHash, txLt);
}

get fun `test stonfi lp wallet v2 decodes toncenter burn notification ext body`() {
    val txHash = "dZ5VbVraQukF+uma7qXpz7UNvvwIHH249OFljum+PB4=";
    val txLt = "53658015000003";
    val bodyBoc = "te6cckEBAQEANgAAZyl0N88AAACJZ7ykhVDjxS9GOACWWa/R+fT8AweBNAJCoGDAJPeJea/3TMM64uHl1Z5/KCBfxmYX";
    val expectedOwner = address("0:4B2CD7E8FCFA7E0183C09A0121503060127BC4BCD7FBA6619D7170F2EACF3F94");
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiLpWalletV2BurnNotificationExt.fromCell(body);

    expect(decoded.queryId).toEqual(590150935685);
    expect(decoded.amount).toEqual(61141611619);
    expect(decoded.fromAddress).toEqual(expectedOwner);
    expect(decoded.responseAddress).toBeNull();
    expect(decoded.customPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STONFI_LP_WALLET_V2_TONCENTER_BURN_NOTIFICATION_EXT_TX={} LT={}", txHash, txLt);
}
