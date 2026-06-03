import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/getgems_deployer.types"

const GETGEMS_DEPLOYER_TONCENTER_TX_HASH = "K8SIDGATtjOncKvIRzrmPq/YTZLISGKizxh4r5kTLAc="
const GETGEMS_DEPLOYER_TONCENTER_TX_LT = "81157288000025"
const GETGEMS_DEPLOYER_PREVIOUS_OWNER = "0:2348FBAF2F2EEF11E183BD4A67FA639C74EF9082C314D93C9EA5A390D9FFD6B4"
const GETGEMS_DEPLOYER_DEPLOYED_SALE = "0:80FB0F3A6552DF066E85B70CF8134E8BE8B80DCFBFFF50BF8AC48207D61AD012"
const GETGEMS_DEPLOYER_SALE_STATE_INIT_HASH = 0x80fb0f3a6552df066e85b70cf8134e8be8b80dcfbfff50bf8ac48207d61ad012
const GETGEMS_DEPLOYER_SALE_DEPLOY_BODY_HASH = 0xbaf83886d4d41304bb31f7739fe8519de146524267513a062e8627beccec4a81

get fun `test getgems deployer decodes toncenter ownership assigned do sale body`() {
    val txHash = GETGEMS_DEPLOYER_TONCENTER_TX_HASH;
    val txLt = GETGEMS_DEPLOYER_TONCENTER_TX_LT;
    val bodyBoc = "te6cckECFAEABKQAAmMFE42RAAAAAAAAAACABGkfdeXl3eI8MHepTP9Mc46d8hBYYpsnk9S0chs/+taAH8Hb0AECAgE0AwQAGAAAAAEAAAAAAAAAAAEU/wD0pBP0vPLICwUB8zUPsIxABurhK2ywvnVmuCK+1hFNeAeRD4b69HGwRwTltoLzWQSIAG6HqDef43wJ1EwMRM6rrBZZSlGs8Brac6gQF6oNu6YLAAjSPuvLy7vEeGDvUpn+mOcdO+QgsMU2TyepaOQ2f/WtFIuyyXAAAAAAAAAAAAAAAAACEwIBYgYHAgLNCAkCASAREgL30A6GmBgLjYSS+CcH0gGHaiaGmAaY/9IH0gfSB9AGppj+mfmBg4KYVjgGAASpiFaY+F7xDhgEoYBWmfxwjFsxsLcxsrZBZjgsk5mW8oBfEV4ADJL4dwEuuk4QEWQIEV3RXgAJFZ2Ngp5OOC2HGBFWAA+WjKFkEINjYQQF1AoLAdFmCEAX14QBSYKBSML7y4cIk0PpA+gD6QPoAMFOSoSGhUIehFqBSkCH6RFtwgBDIywVQA88WAfoCy2rJcfsAJcIAJddJwgKwjhtQRSH6RFtwgBDIywVQA88WAfoCy2rJcfsAECOSNDTiWoQAGQwMWyy1DDQ0wchgCCw8tGVIsMAjhSBAlj4I1NBobwE+CMCoLkTsPLRlpEy4gHUMAH7AATwU8fHBbCOXRNfAzI3Nzc3BPoA+gD6ADBTIaEhocEB8tGYBdD6QPoA+kD6ADAwyDICzxZY+gIBzxZQBPoCyXAgEEgQNxBFEDQIyMsAF8sfUAXPFlADzxYBzxYB+gLMyx/LP8ntVOCz4wIwMTcowAPjAijAAOMCCMACDA0ODwCGNTs7U3THBZJfC+BRc8cF8uH0ghAFE42RGLry4fX6QDAQSBA3VTIIyMsAF8sfUAXPFlADzxYBzxYB+gLMyx/LP8ntVADiODmCEAX14QAYvvLhyVNGxwVRUscFFbHy4cpwIIIQX8w9FCGAEMjLBSjPFiH6Astqyx8Vyz8nzxYnzxYUygAj+gITygDJgwb7AHFwVBcAXjMQNBAjCMjLABfLH1AFzxZQA88WAc8WAfoCzMsfyz/J7VQAGDY3EDhHZRRDMHDwBQAgmFVEECQQI/AF4F8KhA/y8ADsIfpEW3CAEMjLBVADzxYB+gLLaslx+wBwIIIQX8w9FMjLH1Iwyz8kzxZQBM8WE8oAggnJw4D6AhLKAMlxgBjIywUnzxZw+gLLaswl+kRbyYMG+wBxVWD4IwEIyMsAF8sfUAXPFlADzxYBzxYB+gLMyx/LP8ntVACHvOFnaiaGmAaY/9IH0gfSB9AGppj+mfmC3ofSB9AH0gfQAYKaFQkNDggPlozJP9Ii2TfSItkf0iLcEIIySsKAVgAKrAQAgb7l72omhpgGmP/SB9IH0gfQBqaY/pn5gBaH0gfQB9IH0AGCmxUJDQ4ID5aM0U/SItlH0iLZH9Ii2F4ACFiBqqiUAJGADdXCVtlhfOrNcEV9rCKa8A8iHw316ONgjgnLbQXmsgkKA34R1gEAG6uErbLC+dWa4Ir7WEU14B5EPhvr0cbBHBOW2gvNZBICZp9Wtw==";
    val expectedPreviousOwner = address(GETGEMS_DEPLOYER_PREVIOUS_OWNER);
    val body = parseCellFromBase64(bodyBoc);
    val parsed = body.beginParse();
    val decoded = GetgemsDeployerOwnershipAssignedDoSale.fromCell(body);
    var saleStateInit = decoded.doSale.saleStateInit.beginParse();
    var saleDeployBody = decoded.doSale.saleDeployBody.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(395);
    expect(parsed.remainingRefsCount()).toEqual(2);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(expectedPreviousOwner);
    expect(decoded.doSale.saleStateInit.hash()).toEqual(GETGEMS_DEPLOYER_SALE_STATE_INIT_HASH);
    expect(decoded.doSale.saleDeployBody.hash()).toEqual(GETGEMS_DEPLOYER_SALE_DEPLOY_BODY_HASH);

    expect(saleStateInit.remainingBitsCount()).toEqual(5);
    expect(saleStateInit.remainingRefsCount()).toEqual(2);
    expect(saleStateInit.loadBool()).toBeFalse();
    expect(saleStateInit.loadBool()).toBeFalse();
    expect(saleStateInit.loadBool()).toBeTrue();
    saleStateInit.loadRef();
    expect(saleStateInit.loadBool()).toBeTrue();
    saleStateInit.loadRef();
    expect(saleStateInit.loadBool()).toBeFalse();
    expect(saleStateInit.remainingBitsCount()).toEqual(0);
    expect(saleStateInit.remainingRefsCount()).toEqual(0);

    expect(saleDeployBody.remainingBitsCount()).toEqual(96);
    expect(saleDeployBody.remainingRefsCount()).toEqual(0);
    expect(saleDeployBody.loadUint(32)).toEqual(1);
    expect(saleDeployBody.loadUint(64)).toEqual(0);
    expect(saleDeployBody.remainingBitsCount()).toEqual(0);
    expect(saleDeployBody.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_DEPLOYER_TONCENTER_OWNERSHIP_ASSIGNED_DO_SALE_TX={} LT={}", txHash, txLt);
}

get fun `test getgems deployer decodes toncenter nft transfer body`() {
    val txHash = GETGEMS_DEPLOYER_TONCENTER_TX_HASH;
    val txLt = GETGEMS_DEPLOYER_TONCENTER_TX_LT;
    val bodyBoc = "te6cckEBAQEAUgAAn1/MPRQAAAAAAAAAAIAQH2HnTKpb4M3QtuGfAmnRfRcBuff/6hfxWJBA+sNaAlAAjSPuvLy7vEeGDvUpn+mOcdO+QgsMU2TyepaOQ2f/WtAIMBJpag==";
    val expectedNewOwner = address(GETGEMS_DEPLOYER_DEPLOYED_SALE);
    val expectedResponseAddress = address(GETGEMS_DEPLOYER_PREVIOUS_OWNER);
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GetgemsDeployerNftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(expectedNewOwner);
    expect(decoded.responseAddress).toEqual(expectedResponseAddress);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("GETGEMS_DEPLOYER_TONCENTER_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}
