import "@acton/fmt"
import "@acton/testing/expect"
import "../types/verifier_sources_registry.types"

get fun `test decodes real verifier sources registry admin changes`() {
    val changeAdminBody = parseCellFromBase64(
        "te6ccgEBAQEAMAAAWwAAC7wAAAAAAAAAAIAIFs53vBCiZTZew4YTsnWZZC0O2ao/55+uRaopfYfgbrA=",
    );
    val changeAdmin = VerifierSourcesRegistryChangeAdmin.fromCell(changeAdminBody);
    expect(changeAdmin.queryId).toEqual(0);
    expect(changeAdmin.newAdmin).toEqual(
        address("0:40b673bde0851329b2f61c309d93accb216876cd51ff3cfd722d514bec3f0375"),
    );
    expect(changeAdmin.toCell().hash()).toEqual(changeAdminBody.hash());

    val changeRegistryBody = parseCellFromBase64(
        "te6ccgEBAQEAMAAAWwAAB9MAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA=",
    );
    val changeRegistry = VerifierSourcesRegistryChangeVerifierRegistry.fromCell(changeRegistryBody);
    expect(changeRegistry.queryId).toEqual(0);
    expect(changeRegistry.newVerifierRegistry).toEqual(
        address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    );
    expect(changeRegistry.toCell().hash()).toEqual(changeRegistryBody.hash());
}

get fun `test decodes real verifier sources registry code changes`() {
    val setCodeBody = parseCellFromBase64(
        "te6ccgEBBQEAUAABGAAAE44AAAAAAAAAAAEBFP8A9KQT9LzyyAsCAgFiAwQAStAyIccAkVvg0NMDMHGwkTDg0x/TPzEBgScEupTU0fsE4DDywMsAC6BGewIFzQ==",
    );
    val setCode = VerifierSourcesRegistrySetCode.fromCell(setCodeBody);
    expect(setCode.queryId).toEqual(0);
    expect(setCode.newCode.hash() != 0).toBeTrue();
    expect(setCode.toCell().hash()).toEqual(setCodeBody.hash());

    val setItemCodeBody = parseCellFromBase64(
        "te6ccgEBCQEAlgABGAAAD6UAAAAAAAAAAAEBFP8A9KQT9LzyyAsCAgFiAwQCAs4FBgAJoUEj4AMCASAHCAAdQDyMv/Esv/Ac8WzMntVIAGMbCIgxwCRW+AB0NMDAXGwkVvg+kAw8AEwA7OfUiTHBfLhkchQBM8WyfAC4F8FhA/y8IAA5O1E0NP/0//6QCDXSsIAl38B1DAUQzDgMHBVIG2A=",
    );
    val setItemCode = VerifierSourcesRegistrySetSourceItemCode.fromCell(setItemCodeBody);
    expect(setItemCode.queryId).toEqual(0);
    expect(setItemCode.newSourceItemCode.hash() != 0).toBeTrue();
    expect(setItemCode.toCell().hash()).toEqual(setItemCodeBody.hash());
}

get fun `test decodes real verifier sources registry deployment costs`() {
    val body = parseCellFromBase64(
        "te6ccgEBAQEAFwAAKgAAF3cAAAAAAAAAAEA9/SQEQZCrAA==",
    );
    val decoded = VerifierSourcesRegistrySetDeploymentCosts.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.newMinGram).toEqual(65000000);
    expect(decoded.newMaxGram).toEqual(1100000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test decodes real verifier source item deployment payload`() {
    val body = parseCellFromBase64(
        "te6ccgEBAgEAhwABmAAAA+oAAAAAAAAAAGqvIP7Vi6Xm22kpCeeOXFxlJeKNHPqL0i3CFnKbSEGz/rX/aCDi/w2Ug+fg1iyBfYRniftK5YDIeIZtlZ2r1cABAGwBaXBmczovL1FtV0FFWU42RGRIcm5pNkE2VUdvVWE5djZMUHd4QnBkbjlXTFo4NW5SRW00WkI=",
    );
    val decoded = VerifierSourcesRegistryDeploySourceItemPayload.fromCell(body);
    expect(decoded.queryId).toEqual(0);
    expect(
        decoded.verifierId,
    ).toEqual(0x6aaf20fed58ba5e6db692909e78e5c5c6525e28d1cfa8bd22dc216729b4841b3);
    expect(
        decoded.verifiedCodeCellHash,
    ).toEqual(0xfeb5ff6820e2ff0d9483e7e0d62c817d846789fb4ae580c878866d959dabd5c0);
    val content = decoded.sourceContent.load();
    expect(content.version).toEqual(1);
    expect(content.url.remainingBitsCount()).toEqual(424);
    expect(content.url.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
