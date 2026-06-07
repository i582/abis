import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_referral.types"

const STORM_REFERRAL_OWNER = "0:0EB482E6AB9E6C5F2055CD97086D3F24FE5951317E1C078FC2A87A0E5C62393E"
const STORM_REFERRAL_ADD_ORIGIN = "kQAFeTwkcYSAG8689epnAsdEXfeaSkUPL03yTQ-4yc-ZbzIn"
const STORM_REFERRAL_CLAIM_VAULT = "kQDynReiCeK8xlKRbYArpp4jyzZuF6-tYfhFM0O5ulOs5MaB"
const STORM_REFERRAL_LOOKUP_VAULT = "kQDpJnZP89Jyxz3euDaXXFUhwCWtaOeRmiUJTi3jGYgF8UJp"
const STORM_REFERRAL_LOOKUP_ORIGIN = "kQB2OpR9gqb6lmiinABLjt1ZDGjHV6XO9S-DqzEv2OKIMqNn"
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

get fun `test storm referral decodes toncenter mint body`() {
    val txHash = "dPSLGIgmuZhCEY90BVvclDFLGLpp9TOhbL8UqCfMWqc=";
    val txLt = "41880023000005";
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

    println("STORM_REFERRAL_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter add amount body`() {
    val txHash = "56TncpwhisDobtMoYq8rYrIHX+x6d3YJvVVfTAoMyow=";
    val txLt = "42027917000019";
    val bodyBoc = "te6cckEBAQEALAAAU4Tc7XpAFUJSSAAK8nhI4wkAN51569TOBY6Iu+80lIoeXpvkmh9xk58y39/T4KA=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormAddReferralAmount.fromCell(body);

    expect(decoded.referralAmount).toEqual(22291748);
    expect(decoded.originAddr).toEqual(address(STORM_REFERRAL_ADD_ORIGIN));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_ADD_AMOUNT_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter provide fees body`() {
    val txHash = "xOc9l4wNXSW1mbaLpRuyhPgAdKK8DijLYxa1hB9jmhY=";
    val txLt = "41877139000011";
    val bodyBoc = "te6cckEBAQEABgAACH5D9fz8vJ0i";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralProvideFees.fromCell(body);
    var parsed = body.beginParse();

    expect(parsed.loadUint(32)).toEqual(0x7e43f5fc);
    expectNoTail(mutate parsed);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_PROVIDE_FEES_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter vaults reply body`() {
    val txHash = "P96LLPVuaK4+sFEfMmaePaQo2Ve/XlQ6ppBrRcpBbCw=";
    val txLt = "52213977000001";
    val bodyBoc = "te6cckECDAEAAT8AAZVplhWNwA6SZ2T/PScsc93rg2l1xVIcAlrWjnkZolCU4t4xmIBfEzh0NoAOx1KPsFTfUs0UU4AJcdurIY0Y6vS53qXwdWYl+xxRBlABAgEgAgMCASAEBQIBIAgJAgEgBgcAQ7+wfRtqEf3ZzhkeGsmXiC7hzTh1C5zZZzLgDH5VL8gENQgAQ79N5+DnhKtJNU37mRNX6iTHHAyyEWYcguf6ejoDqewPehAAQ79n09Ca+X3/4aR2crDqhBx0PZcFxILSV9E4/UV6TuLW7hAAQ7+f4e6j3p3N5i/uAris16/HRfuQvRFj242swf7JhC0dxwgCAVgKCwBDvySZ2T/PScsc93rg2l1xVIcAlrWjnkZolCU4t4xmIBfEIABDvwp0XognivMZSkW2AK6aeI8s2bhevrWH4RTNDubpTrOQIIe109w=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralVaultsReply.fromCell(body);
    var requestTail = decoded.requestTail;

    expectVaultWhitelist(decoded.vaultsWhitelist);
    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_LOOKUP_VAULT));
    expect(requestTail.loadCoins()).toEqual(3699766);
    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_LOOKUP_ORIGIN));
    expectNoTail(mutate requestTail);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_VAULTS_REPLY_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter claim amount body`() {
    val txHash = "7xny8meNnfRvbVv+eb8u5yqKLin4OiNPbGSs+Ug2b/M=";
    val txLt = "42028217000003";
    val bodyBoc = "te6cckEBAQEAKAAAS1VtFiCAHlOi9EE8V5jKUi2wBXTTxHlmzcL19aw/CKZodzdKdZyQW2ULHg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormClaimReferralAmount.fromCell(body);

    expect(decoded.vaultAddress).toEqual(address(STORM_REFERRAL_CLAIM_VAULT));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_CLAIM_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter withdraw amount body`() {
    val txHash = "7xny8meNnfRvbVv+eb8u5yqKLin4OiNPbGSs+Ug2b/M=";
    val txLt = "42028217000003";
    val bodyBoc = "te6cckEBAQEANAAAY/XU61IAAAAAAAAAAEAVQlJIAB1pBc1XPNi+QKubLhDafkn8sqJi/DgPH4VQ9By4xHJ92WNMEw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormWithdrawReferralAmount.fromCell(body);

    expect(decoded.index).toEqual(0);
    expect(decoded.referralAmount).toEqual(22291748);
    expect(decoded.ownerAddr).toEqual(address(STORM_REFERRAL_OWNER));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter take fees body`() {
    val txHash = "7t95JmEergfLSZcWLXFwvQ9BPmhdAaWlrbQPnCy0aek=";
    val txLt = "42027917000011";
    val bodyBoc = "te6cckEBAgEAEQABCBLZYB0BABAC+vCABfXhANoB0PM=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormTakeReferralFees.fromCell(body);
    val fees = decoded.referralFees.load();

    expectDefaultReferralParameters(fees);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_TAKE_FEES_TX={} LT={}", txHash, txLt);
}

get fun `test storm referral decodes toncenter provide vaults request body`() {
    val txHash = "Tp5TXt+QweZL0bS5KsjqlioipIJwfww8A8IEVSWHtxc=";
    val txLt = "52213969000004";
    val bodyBoc = "te6cckEBAQEATQAAld1aq3OAHSTOyf56Tljnu9cG0uuKpDgEta0c8jNEoSnFvGMxAL4mcOhtAB2OpR9gqb6lmiinABLjt1ZDGjHV6XO9S+DqzEv2OKIMoPX2Yxo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormReferralProvideVaultsRequest.fromCell(body);
    var requestTail = decoded.requestTail;

    expect(decoded.vaultAddress).toEqual(address(STORM_REFERRAL_LOOKUP_VAULT));
    expect(requestTail.loadCoins()).toEqual(3699766);
    expect(requestTail.loadAddress()).toEqual(address(STORM_REFERRAL_LOOKUP_ORIGIN));
    expectNoTail(mutate requestTail);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_REFERRAL_PROVIDE_VAULTS_TX={} LT={}", txHash, txLt);
}
