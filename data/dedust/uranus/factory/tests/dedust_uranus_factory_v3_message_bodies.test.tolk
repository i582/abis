import "@acton/fmt"
import "@acton/testing/expect"
import "../types/dedust_uranus_factory_v3.types"

const PARTNER_ADDRESS = "0:EEE00893FFF24ABAA4F46678DED11A1721030F723E2E20661999EDD42B884594"

get fun `test dedust uranus factory v3 decodes live deploy meme body`() {
    val txHash = "dvdr9HEnw3KdgPO+87fmZ07yHstHooOowlzgkdnTRNM=";
    val txLt = "82453931000022";
    val bodyBoc = "te6cckEBAgEAWgABJW/0FtwAAAAAAAAAAEUCGHEaACABAIRpcGZzOi8vYmFma3JlaWhnbjVzaDJha3M0M2YyY3FicnlwYm03aGFyM20yeWk2NTVibHp3aGF1Z25rZDZjdW9qY3UHVNF9";
    val decoded = DedustUranusDeployMeme.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(0);
    expect(decoded.presetId).toEqual(4);
    expect(decoded.metadata.uri).toEqual("ipfs://bafkreihgn5sh2aks43f2cqbrypbm7har3m2yi655blzwhaugnkd6cuojcu");
    expect(decoded.initialBuy).toEqual(9000000000);
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}

get fun `test dedust uranus factory v3 decodes live customized deploy body`() {
    val txHash = "8jNEEUz8pai/skyzTUZrHI1jnB+tgrad06kfS9jd+8k=";
    val txLt = "82453926000022";
    val bodyBoc = "te6cckEBAgEAfAABg2MvXRwAAAAAaidXIxNgFdPveYAEuAHdwBEn/+SVdUnozPG9ojQuQgYe5HxcQMwzM9uoVxCLKCcQH0AABigJUC+QAQEAamlwZnM6Ly9RbVNERHQzVEJhNFFrQ1VwTHpRRkE3R3lINzV6UHhaMlVYa0dvenlEd3lOOUxGuNJKAA==";
    val decoded = DedustUranusDeployCustomizedMeme.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(1780963107);
    expect(decoded.totalSupplyPresetId).toEqual(1);
    expect(decoded.baseFeePresetId).toEqual(3);
    expect(decoded.raisingFunds).toEqual(1500000000000);
    expect(decoded.onSellSupplyPercent).toEqual(75);
    expect(decoded.partnerAddress).toEqual(address(PARTNER_ADDRESS));
    expect(decoded.partnerFeeBps).toEqual(5000);
    expect(decoded.poolPartnerFeeBps).toEqual(4000);
    expect(decoded.poolBaseFeePresetId).toEqual(3);
    expect(decoded.poolLiquidityOwnerAddress).toBeNull();
    expect(decoded.metadataUri).toEqual("ipfs://QmSDDt3TBa4QkCUpLzQFA7GyH75zPxZ2UXkGozyDwyN9LF");
    expect(decoded.initialBuy).toEqual(5000000000);
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}

get fun `test dedust uranus factory v3 decodes live init meme body`() {
    val txLt = "82453926000024";
    val bodyBoc = "te6cckEBAQEAFAAAI3lvWgwAAAAAaidXI1ASoF8gApdF25U=";
    val decoded = DedustUranusInitMeme.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(1780963107);
    expect(decoded.initialBuy).toEqual(5000000000);
    expect(decoded.partnerConfig).toBeNull();
    expect(decoded.referrerConfig).toBeNull();
}
