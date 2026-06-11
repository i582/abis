import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/dedust_uranus_meme_v3.types"
import "../wrappers/DedustUranusMemeV3.gen"

const FIXTURE_BOC_PATH = "data/dedust/uranus/meme/testdata/DedustUranusMemeV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x1e4f8fcaabefdbbb9b397372d9f021511c272eda2b492ca2d33b817bc3251afe
const MEME_ADDRESS = "0:3A74678A21C1D45508212869867B57C47F27D8698C8B0B9F783E460EE6E21B12"
const CREATOR_ADDRESS = "0:CA3AFE096538BDE21F9B85B05F4F4034E29AE58614674F47B4797BB286EA76DA"
const CONTROLLER_ADDRESS = "0:33664F9813E0BFD936B1333362EF5BA92DFC0B601591A5608AE8CD6F85B00EB4"
const DATA_BOC_BASE64 = "te6ccgECBAEAARcAAluAGRAfwRcy79N1JrezzahhsBTREg17FgAAIKEBvBbWdOyAAAf4ShaBkhB2AnEQAQIBw4AZR1/BLKcXvEPzcLYL6egGnFNcsMKM6ej2jy92UN1O21AAzZk+YE+C/2TaxMzNi71upLfwLYBWRpWCK6M1vhbAOtGAV0+95gAgDeC2s6dkAAJ/7xJxVKCi3FPruOPkz6vSAwCNgB3cARJ//klXVJ6MzxvaI0LkIGHuR8XEDMMzPbqFcQiygnEADJADKOv4JZTi94h+bhbBfT0A04prlhhRnT0e0eXuyhup22oAamlwZnM6Ly9RbVNERHQzVEJhNFFrQ1VwTHpRRkE3R3lINzV6UHhaMlVYa0dvenlEd3lOOUxG"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust uranus meme v3 code fixture hash matches live account`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("DedustUranusMemeV3", FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustUranusMemeV3");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test dedust uranus meme v3 storage parses saved mainnet data cell`() {
    val data = parseCellFromBase64(DATA_BOC_BASE64);
    val storage = DedustUranusMemeV3Storage.fromCell(data);
    val config = storage.config.load();

    expect(storage.initialized).toBeTrue();
    expect(storage.migrated).toBeFalse();
    expect(storage.baseFeeBps).toEqual(100);
    expect(storage.totalSupply).toEqual(1000000000000000000);
    expect(storage.creatorFee).toEqual(16524555);
    expect(storage.curve.graduated).toBeFalse();
    expect(storage.curve.alpha).toEqual(1144067796610169491);
    expect(storage.curve.beta).toEqual(814406779661);
    expect(storage.curve.onSellSupply).toEqual(750000000000000000);
    expect(storage.curve.raisedFunds).toEqual(5);
    expect(storage.curve.currentSupply).toEqual(0);
    expect(config.creatorAddress).toEqual(address(CREATOR_ADDRESS));
    expect(config.controllerAddress).toEqual(address(CONTROLLER_ADDRESS));
    expect(config.metadata.uri).toEqual("ipfs://QmSDDt3TBa4QkCUpLzQFA7GyH75zPxZ2UXkGozyDwyN9LF");
    expect(config.raisingFunds).toEqual(1500000000000);
    expect(config.liquidityTokens).toEqual(250000000000000000);
    expect(config.seed).toEqual(212654505579524308618630414253971204852);
    expect(storage.v3Tail.remainingBitsCount()).toEqual(52);
    expect(storage.v3Tail.remainingRefsCount()).toEqual(1);
}

get fun `test dedust uranus meme v3 wrapper can target verified address`() {
    val memeAddress = address(MEME_ADDRESS);
    val meme = DedustUranusMemeV3.fromAddress(memeAddress);

    expect(meme.address).toEqual(memeAddress);
    expect(meme.stateInit).toBeNull();
}
