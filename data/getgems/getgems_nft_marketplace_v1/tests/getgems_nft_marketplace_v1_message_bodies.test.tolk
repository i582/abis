import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"

get fun `test getgems marketplace v1 decodes toncenter deploy contract body`() {
    val txHash = "SXSy3gYVTTj7vH7M6YnxgKVfgjDtcLvXj45OHTMJozc=";
    val txLt = "26843615000003";
    val bodyBoc = "te6cckECDwEAAlgAAhEAAAABQC+vCAgBAgIBNAMEAAABFP8A9KQT9LzyyAsFAdGAD9meMITwKBs+NoGchCwDnEfwirXzl3hrwHPMAh60NpLwAPiswjZ6SvzPbXgxBMjJDJEAACeISnlzCvblVc0brOIyAAN/XEZU2hi8Y3no0nek9Hg8wI4xwgrnIGrHqUSK++IRogyFWAQOAgEgBgcCAUgICQAE8jACAs0KCwAvoDhZ2omh9IH0gfSB9AGoYaH0AfSB9ABhAffQDoaYGAuNhJL4JwfSAYdqJofSB9IH0gfQBqGBFrpOEBWccdmRsbKZDjgskvg3AokWOC+XD6AWmPwQgCicbIiV15cPrpn5j9IBggGmQoAueLKAHniwDniwD9AWZk9qpwE2OATJsIGyKZgjh4AnADaY/pn5gQ4ADJL4VwEMDAH11BCB3NZQApKFApGF95cOEB6H0AfSB9ABg4QAhkZYKoBOeLKLnQkNCoWtCKUAr9AQrltWS4/YA4QAhkZYKsZ4soA/0BC2W1ZLj9gDhACGRlgqgC54sA/QEJ5bVkuP2AOBBBCC/mHooQwAxkZYKoAueLEX0BCmW1CeWPikDQC2wAKaMRBHEDZFQBLwBOAyNDQ0NcADjj2CEDuaygATvvLhyXAgghBfzD0UIYAQyMsFUAfPFiL6AhbLahXLHxPLPyHPFgHPFhLKACH6AsoAyYEAoPsA4F8EhA/y8AAqyz8izxZYzxbKACH6AsoAyYEAoPsAAFVAvrwgCADV1iFFQWKtZYcZ/wXXGdFRAq0S7GjD0EZ+dl0xMsOPeoC+vCAQI3IRQA==";
    val expectedMarketplace = address("0:7ECCF184278140D9F1B40CE421601CE23F8455AF9CBBC35E039E6010F5A1B497");
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expect(body.hash()).toEqual(0xa7bea46a65f29884167e1b5a63e363cdc9dbd19278cfc4075a9d4855c36a5290);
    expect(parsed.remainingBitsCount()).toEqual(68);
    expect(parsed.remainingRefsCount()).toEqual(2);
    expect(parsed.loadUint(32)).toEqual(0x00000001);
    expect(parsed.loadCoins()).toEqual(50000000);
    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(2);

    val stateInit = parsed.loadRef();
    val forwardedBody = parsed.loadRef();
    expect(parsed.remainingRefsCount()).toEqual(0);
    expect(
        stateInit.hash(),
    ).toEqual(0xcac1b858c2c2545c0c483d1884a36a8a7348d2f7e1d6d84c10e4f7888f891e80);
    expect(
        forwardedBody.hash(),
    ).toEqual(0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7);

    var stateInitSlice = stateInit.beginParse();
    expect(stateInitSlice.remainingBitsCount()).toEqual(5);
    expect(stateInitSlice.remainingRefsCount()).toEqual(2);
    expect(stateInitSlice.loadUint(5)).toEqual(0x06);
    val deployedCode = stateInitSlice.loadRef();
    val deployedData = stateInitSlice.loadRef();
    expect(stateInitSlice.remainingBitsCount()).toEqual(0);
    expect(stateInitSlice.remainingRefsCount()).toEqual(0);

    expect(
        deployedCode.hash(),
    ).toEqual(0xda3e6c053d289d662dd3bd7856c3a1f26d3a6ed05fb02b8351ceb673194313e7);
    expect(
        deployedData.hash(),
    ).toEqual(0x3e0bc5a3f248b907cee488307a74e6a5585f9835cff3f8e3d668cbd14acafa3b);
    val deployedCodeSlice = deployedCode.beginParse();
    expect(deployedCodeSlice.remainingBitsCount()).toEqual(80);
    expect(deployedCodeSlice.remainingRefsCount()).toEqual(1);
    expect(deployedCodeSlice.preloadUint(16)).toEqual(0xff00);

    var deployedDataSlice = deployedData.beginParse();
    expect(deployedDataSlice.loadAddress()).toEqual(expectedMarketplace);
    expect(deployedDataSlice.remainingBitsCount()).toEqual(570);
    expect(deployedDataSlice.remainingRefsCount()).toEqual(1);

    val forwardedBodySlice = forwardedBody.beginParse();
    expect(forwardedBodySlice.remainingBitsCount()).toEqual(0);
    expect(forwardedBodySlice.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_MARKETPLACE_V1_TONCENTER_DEPLOY_CONTRACT_TX={} LT={}", txHash, txLt);
}

get fun `test getgems marketplace v1 decodes toncenter ignored empty body`() {
    val txHash = "75W2QAfkuCeXmJ03qtWizrvQUvMG8TWvOuteOKHmRzI=";
    val txLt = "26843625000003";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();

    expect(body.hash()).toEqual(0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7);
    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);

    println("GETGEMS_NFT_MARKETPLACE_V1_TONCENTER_IGNORED_EMPTY_TX={} LT={}", txHash, txLt);
}
