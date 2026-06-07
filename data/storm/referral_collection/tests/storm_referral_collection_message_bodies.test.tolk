import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_referral_collection.types"

const STORM_REFERRAL_OWNER = "0:0EB482E6AB9E6C5F2055CD97086D3F24FE5951317E1C078FC2A87A0E5C62393E"
const STORM_REFERRAL_CLAIM_VAULT = "kQDynReiCeK8xlKRbYArpp4jyzZuF6-tYfhFM0O5ulOs5MaB"
const STORM_REFERRAL_LOOKUP_VAULT = "kQDpJnZP89Jyxz3euDaXXFUhwCWtaOeRmiUJTi3jGYgF8UJp"
const STORM_REFERRAL_COLLECTION_LOOKUP_ORIGIN = "kQCcRekQSYvr8dvKShk4A1UpB3s56Cjj01Qmcs9NXxhupOqs"
const INITIAL_BALANCE_VAULT_HASH = 0xf29d17a209e2bcc652916d802ba69e23cb366e17afad61f8453343b9ba53ace4
const STORM_REFERRAL_LOOKUP_VAULT_HASH = 0xe926764ff3d272c73ddeb836975c5521c025ad68e7919a25094e2de3198805f1

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectDefaultReferralParameters(parameters: StormReferralParameters): void {
    expect(parameters.discount).toEqual(50000000);
    expect(parameters.rebate).toEqual(100000000);
}

fun expectInitialBalances(balances: map<uint256, coins>): void {
    expect(balances).toHaveLength(1);
    expect(balances.mustGet(INITIAL_BALANCE_VAULT_HASH)).toEqual(0);
}

fun expectVaultWhitelist(whitelist: map<uint256, coins>): void {
    expect(whitelist.isEmpty()).toBeFalse();
    expect(whitelist.mustGet(STORM_REFERRAL_LOOKUP_VAULT_HASH)).toEqual(0);
}

get fun `test storm referral collection decodes toncenter add vault body`() {
    val txHash = "+rhjE2jjFEkKU9BEUvx0Lm5qOqZNzM4Op4DX+1EI+1E=";
    val txLt = "41876455000003";
    val bodyBoc = "te6cckEBAQEAKAAAS8vRJIqAHlOi9EE8V5jKUi2wBXTTxHlmzcL19aw/CKZodzdKdZyQ+U5vcw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralCollectionAddVault.fromCell(body);

    expect(decoded.vaultAddress).toEqual(address(STORM_REFERRAL_CLAIM_VAULT));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_COLLECTION_ADD_VAULT_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral collection decodes toncenter mint request body`() {
    val txHash = "/tOs/T6BC/MSQzO/+d63PMtjD3WVSSAHANB2rRVzqsI=";
    val txLt = "41880023000003";
    val bodyBoc = "te6cckEBAQEAUQAAnuytFcQAAAAAAAAAACAAdaQXNVzzYvkCrmy4Q2n5J/LKiYvw4Dx+FUPQcuMRyfQADrSC5quebF8gVc2XCG0/JP5ZUTF+HAePwqh6DlxiOT6LIBOf";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralCollectionMint.fromCell(body);
    var mintTail = decoded.mintTail;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.refType as int).toEqual(0);
    expect(mintTail.loadAddress()).toEqual(address(STORM_REFERRAL_OWNER));
    expect(mintTail.loadAddress()).toEqual(address(STORM_REFERRAL_OWNER));
    expectNoTail(mutate mintTail);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_COLLECTION_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral collection decodes toncenter item mint body`() {
    val txHash = "/tOs/T6BC/MSQzO/+d63PMtjD3WVSSAHANB2rRVzqsI=";
    val txLt = "41880023000003";
    val bodyBoc = "te6cckEBAwEAegACj8tN3DyAAdaQXNVzzYvkCrmy4Q2n5J/LKiYvw4Dx+FUPQcuMRyfEAA60guarnmxfIFXNlwhtPyT+WVExfhwHj8Koeg5cYjk+wAECABAC+vCABfXhAABDoB5TovRBPFeYylItsAV008R5Zs3C9fWsPwimaHc3SnWcgXklnVc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormMintReferral.fromCell(body);
    val parameters = decoded.parameters.load();

    expect(decoded.nftOwner).toEqual(address(STORM_REFERRAL_OWNER));
    expect(decoded.refType as int).toEqual(0);
    expect(decoded.redirectAddress).toEqual(address(STORM_REFERRAL_OWNER));
    expectDefaultReferralParameters(parameters);
    expectInitialBalances(decoded.balancesDict);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_COLLECTION_ITEM_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral collection decodes toncenter provide vaults body`() {
    val txHash = "qlHLipLJ0WkRPnl3kDboek4osl/l//FbvdgEkcgAknc=";
    val txLt = "44349157000003";
    val bodyBoc = "te6cckEBAQEATQAAld1aq3OAHSTOyf56Tljnu9cG0uuKpDgEta0c8jNEoSnFvGMxAL4mGQSjACcRekQSYvr8dvKShk4A1UpB3s56Cjj01Qmcs9NXxhupIDDpRuk=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralCollectionProvideVaults.fromCell(body);
    var requestTail = decoded.requestTail;

    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_LOOKUP_VAULT));
    expect(requestTail.loadCoins()).toEqual(819793);
    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_COLLECTION_LOOKUP_ORIGIN));
    expectNoTail(mutate requestTail);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_COLLECTION_PROVIDE_VAULTS_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral collection decodes toncenter vaults reply body`() {
    val txHash = "qlHLipLJ0WkRPnl3kDboek4osl/l//FbvdgEkcgAknc=";
    val txLt = "44349157000003";
    val bodyBoc = "te6cckEBBAEAmwABlWmWFY3ADpJnZP89Jyxz3euDaXXFUhwCWtaOeRmiUJTi3jGYgF8TDIJRgBOIvSIJMX1+O3lJQycAaqUg72c9BRx6aoTOWemr4w3UkAECAncCAwBDvySZ2T/PScsc93rg2l1xVIcAlrWjnkZolCU4t4xmIBfEIABDvwp0XognivMZSkW2AK6aeI8s2bhevrWH4RTNDubpTrOQID20A54=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralCollectionVaultsReply.fromCell(body);
    var requestTail = decoded.requestTail;

    expectVaultWhitelist(decoded.vaultsWhitelist);
    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_LOOKUP_VAULT));
    expect(requestTail.loadCoins()).toEqual(819793);
    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_COLLECTION_LOOKUP_ORIGIN));
    expectNoTail(mutate requestTail);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_COLLECTION_VAULTS_REPLY_TX={} LT={}", txHash, txLt);
}
