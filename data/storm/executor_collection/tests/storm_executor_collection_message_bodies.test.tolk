import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_executor_collection.types"

const INITIAL_OWNER_ADDRESS = "0:4de480ab6acefd53c158126ef5c2cdf89fe64d210d0b44da5c90e52c215dce79"
const REDIRECT_ADDRESS = "0:afbd6698187ff01747c1d6df0a0443768d182174f5f8323d5748aafce68b1184"
const PROVIDE_VAULT_ADDRESS = "0:fa87bdeb3c237eb2b6daf71b35095011b31fbc7115de332c148af3887d5c73d9"
const PROVIDE_ORIGIN_ADDRESS = "0:763a947d82a6fa9668a29c004b8edd590c68c757a5cef52f83ab312fd8e28832"
const INITIAL_BALANCE_VAULT_HASH = 0xf29d17a209e2bcc652916d802ba69e23cb366e17afad61f8453343b9ba53ace4
const PROVIDE_VAULT_HASH = 0xfa87bdeb3c237eb2b6daf71b35095011b31fbc7115de332c148af3887d5c73d9

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectProvideVaultsTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.loadAddress()).toEqual(address(PROVIDE_VAULT_ADDRESS));
    expect(tail.loadCoins()).toEqual(11976048);
    expect(tail.loadAddress()).toEqual(address(PROVIDE_ORIGIN_ADDRESS));
    expectNoTail(mutate tail);
}

fun expectInitialBalances(balances: map<uint256, coins>): void {
    expect(balances).toHaveLength(1);
    expect(balances.mustGet(INITIAL_BALANCE_VAULT_HASH)).toEqual(0);
}

fun expectVaultWhitelist(whitelist: map<uint256, coins>): void {
    expect(whitelist.isEmpty()).toBeFalse();
    expect(whitelist.mustGet(PROVIDE_VAULT_HASH)).toEqual(0);
}

get fun `test storm executor collection decodes toncenter provide vaults body`() {
    val txHash = "Tu3c8ogJMSwfl6U/WH2kquqqoJ2eaQaWCmMOtbPrN1Q=";
    val txLt = "58521282000001";
    val bodyBoc = "te6cckEBAQEATQAAld1aq3OAH1D3vWeEb9ZW217jZqEqAjZj944iu8ZlgpFecQ+rjnsnbXrhAB2OpR9gqb6lmiinABLjt1ZDGjHV6XO9S+DqzEv2OKIMoNn4+mE=";
    val body = parseCellFromBase64(bodyBoc);
    var decoded = StormExecutorCollectionProvideVaults.fromCell(body);

    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectProvideVaultsTail(mutate decoded.requestTail);

    println("STORM_EXECUTOR_COLLECTION_PROVIDE_VAULTS_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor collection decodes toncenter add vault body`() {
    val txHash = "4/TmFERV3bLXvWCX3pt9wyQ9PikyvmvS5xvFEKt+VcU=";
    val txLt = "58521171000001";
    val bodyBoc = "te6cckEBAQEAKAAAS8vRJIqAH1D3vWeEb9ZW217jZqEqAjZj944iu8ZlgpFecQ+rjnswZR74Yg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormExecutorCollectionAddVault.fromCell(body);

    expect(decoded.vaultAddress).toEqual(address(PROVIDE_VAULT_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_COLLECTION_ADD_VAULT_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor collection decodes toncenter mint item body`() {
    val txHash = "0nYP1kd2iUKafVIypLImxLgJDFY1K/WD1c3swkRwlsg=";
    val txLt = "41881176000003";
    val bodyBoc = "te6cckEBAgEAbgABjU84yuiACbyQFW1Z36p4KwJN3rhZvxP8yaQhoWibS5IcpYQruc8wAr71mmBh/8BdHwdbfCgRDdo0YIXT1+DI9V0iq/OaLEYTAQBDoB5TovRBPFeYylItsAV008R5Zs3C9fWsPwimaHc3SnWcgQD/ZVo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormMintExecutor.fromCell(body);

    expect(decoded.nftOwner).toEqual(address(INITIAL_OWNER_ADDRESS));
    expect(decoded.redirectAddress).toEqual(address(REDIRECT_ADDRESS));
    expectInitialBalances(decoded.balancesDict);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_COLLECTION_MINT_ITEM_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor collection decodes toncenter mint request body`() {
    val txHash = "0nYP1kd2iUKafVIypLImxLgJDFY1K/WD1c3swkRwlsg=";
    val txLt = "41881176000003";
    val bodyBoc = "te6cckEBAQEAUQAAneytFcQAAAAAAAAAAIAJvJAVbVnfqngrAk3euFm/E/zJpCGhaJtLkhylhCu5zzACvvWaYGH/wF0fB1t8KBEN2jRghdPX4Mj1XSKr85osRhKiYOar";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormExecutorCollectionMint.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.nftOwner).toEqual(address(INITIAL_OWNER_ADDRESS));
    expect(decoded.redirectAddress).toEqual(address(REDIRECT_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_EXECUTOR_COLLECTION_MINT_REQUEST_QUERY_TX={} LT={}", txHash, txLt);
}

get fun `test storm executor collection decodes toncenter vaults reply body`() {
    val txHash = "Tu3c8ogJMSwfl6U/WH2kquqqoJ2eaQaWCmMOtbPrN1Q=";
    val txLt = "58521282000001";
    val bodyBoc = "te6cckECDgEAAWgAAZVplhWNwA+oe96zwjfrK22vcbNQlQEbMfvHEV3jMsFIrziH1cc9k7a9cIAOx1KPsFTfUs0UU4AJcdurIY0Y6vS53qXwdWYl+xxRBlABAgEgAgMCASAEBQIBIAgJAgEgBgcAQ7+wfRtqEf3ZzhkeGsmXiC7hzTh1C5zZZzLgDH5VL8gENQgAQ79N5+DnhKtJNU37mRNX6iTHHAyyEWYcguf6ejoDqewPehAAQ79n09Ca+X3/4aR2crDqhBx0PZcFxILSV9E4/UV6TuLW7hAAQ7+f4e6j3p3N5i/uAris16/HRfuQvRFj242swf7JhC0dxwgCAVgKCwBDvySZ2T/PScsc93rg2l1xVIcAlrWjnkZolCU4t4xmIBfEIAIBIAwNAEO+1Oi9EE8V5jKUi2wBXTTxHlmzcL19aw/CKZodzdKdZyBAAEO+1D3vWeEb9ZW217jZqEqAjZj944iu8ZlgpFecQ+rjnshAfPfKKQ==";
    val body = parseCellFromBase64(bodyBoc);
    var decoded = StormExecutorCollectionVaultsReply.fromCell(body);

    expectVaultWhitelist(decoded.vaultsWhitelist);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    expectProvideVaultsTail(mutate decoded.requestTail);

    println("STORM_EXECUTOR_COLLECTION_VAULTS_REPLY_TX={} LT={}", txHash, txLt);
}
