import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storage_contract.types"

const HISTORICAL_TORRENT_HASH = 0x463e4907d70d509a401083037b52b5730462098b76ec2a575ec408f4cb3367c2

get fun `test storage contract decodes toncenter deploy body`() {
    val txHash = "xqaKfGlkfduZePrsg+emjBODcZPORe9iY/8g1ko2ZUg=";
    val txLt = "37528863000005";
    val bodyBoc = "te6cckEBAQEADgAAGOR0jfEAAAAA0V/GO+48Bk8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StorageDeployStorageContract.fromCell(body);

    expect(decoded.queryId).toEqual(3512714811);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORAGE_CONTRACT_DEPLOY_TX={} LT={}", txHash, txLt);
}

get fun `test storage contract decodes toncenter accept body`() {
    val txHash = "uMtNwWrytfCE+EAYfSGPi5xz9Y+1q0N6qCPBxMWvTsw=";
    val txLt = "37528869000003";
    val bodyBoc = "te6cckEBAQEADgAAGHo2FogAAAAAAAAAAG6xQ/c=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StorageAcceptStorageContract.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORAGE_CONTRACT_ACCEPT_TX={} LT={}", txHash, txLt);
}

get fun `test storage contract decodes toncenter proof body`() {
    val txHash = "DezUaou9EUB3cNdqtwX7TyQ1zIhGsbRI5g7fRf3fnCI=";
    val txLt = "37535495000003";
    val bodyBoc = "te6cckECIwEAAygAARhBnV1NAAAAAAAAAAABCUYDzQ9VBWhQjuZsRHmERlQfxEDwo2uExbahMu0gaLHqY9IAEAIiASADBCIBIAUGKEgBAVuRtjvb6QpnTECz9TTJ1DaqLdmFf48t23uPPcHvmNgjAA8iASAHCChIAQG09C+ChC5xSybY3XTCFvcl5FS8Axg/vuzp/AP/JKB9BQAOIgEgCQooSAEBJFrGushVdvatEl3aCv6MTkVeGa3NrhWuVD8n2xkT6mkADSIBIAsMKEgBAeTyP60UY/Sr5SjcSV73on2JcCpFkzzX7rnWVMvNK8DCAAwiASANDihIAQEz7vkLB/uN+Vwq5Rf7hXvVFfo3mmnd0geHeyjsznppjAALIgEgDxAoSAEB3QsKoY/R4RuEmDu76psrEQE5vAbKhHEA3IYVsBt7f38ACiIBIBESKEgBASnCm7NdqxtMOc+X58ejonsCkbxU+Gtu6lG4nDdAYHHXAAkiASATFChIAQHHY065UTtNQ0d3A84it5Inf8ueHS9qA36cJ3YrhzX00wAIIgEgFRYoSAEBWJbUfy48st5f6fNx5pJHRE0oWF9gcWvh6aq1Widt4OMAByIBIBcYKEgBAQtM1Sbdbina8btmlAAX2l86qXasrKvgWzD2te/nmGJjAAYiASAZGihIAQFW0tkTpoHEMYzamNYiVPuVcpq52tHm9UHMQiqZK9kHuQAFIgEgGxwoSAEBihR0ymnBF3k2wHW1QMPpVV7DoE72TL4Ehj+UEVjANKcABCIBIB0eKEgBAWvpOIiJrlIjx2c4IFIgmuwy7csF/Icv6gdCpKiV2qnXAAMiASAfIChIAQEHCNx6hWyQXPhUQE2pxdkLBk7YxtlHENlI1idnBVD+sgACIgEgISIoSAEBaorYJ4GluZF9H0dZLIlarn9IOZ2z1B4cpxPgAZfgk0cAAQCBLeqKJEBAAAAJgAAAAAAAAAAAAAAAAAAAGQZKsgAAAAAJgAAAAAAAABnXCkAAAAAAFJvY2t5IC0gQmlsbCBDb26AoSAEBVUX129yGIEDfgyhKnTAqS+7qcfVS1kuxCVitS3MtxM4AAChkN8o=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StorageProofStorage.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.fileDictProof.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORAGE_CONTRACT_PROOF_TX={} LT={}", txHash, txLt);
}

get fun `test storage contract decodes toncenter close body`() {
    val txHash = "lTRjxZNUEvWfCklOeUpzWcCuRnwBqcgJ68LabvWTiIs=";
    val txLt = "37560515000003";
    val bodyBoc = "te6cckEBAQEADgAAGHn5N+oAAAAAAAAAAGcU6HU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StorageCloseContract.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORAGE_CONTRACT_CLOSE_TX={} LT={}", txHash, txLt);
}

get fun `test storage contract decodes toncenter outgoing confirmations`() {
    val deployTxHash = "xqaKfGlkfduZePrsg+emjBODcZPORe9iY/8g1ko2ZUg=";
    val confirmTxHash = "uMtNwWrytfCE+EAYfSGPi5xz9Y+1q0N6qCPBxMWvTsw=";
    val terminateTxHash = "lTRjxZNUEvWfCklOeUpzWcCuRnwBqcgJ68LabvWTiIs=";
    val deployedBody = parseCellFromBase64("te6cckEBAQEALgAAWL970MEAAAAA0V/GO0Y+SQfXDVCaQBCDA3tStXMEYgmLduwqV17ECPTLM2fCSBjy5A==");
    val confirmedBody = parseCellFromBase64("te6cckEBAQEALgAAWNTK7c0AACIh3ufTQ0Y+SQfXDVCaQBCDA3tStXMEYgmLduwqV17ECPTLM2fCqGpf5g==");
    val terminatedBody = parseCellFromBase64("te6cckEBAQEALgAAWLYjbWMAACIpPSd2w0Y+SQfXDVCaQBCDA3tStXMEYgmLduwqV17ECPTLM2fCJCergg==");
    val deployed = StorageContractDeployed.fromCell(deployedBody);
    val confirmed = StorageContractConfirmed.fromCell(confirmedBody);
    val terminated = StorageContractTerminated.fromCell(terminatedBody);

    expect(deployed.queryId).toEqual(3512714811);
    expect(deployed.torrentHash).toEqual(HISTORICAL_TORRENT_HASH);
    expect(confirmed.curLt).toEqual(37528869000003);
    expect(confirmed.torrentHash).toEqual(HISTORICAL_TORRENT_HASH);
    expect(terminated.curLt).toEqual(37560515000003);
    expect(terminated.torrentHash).toEqual(HISTORICAL_TORRENT_HASH);
    expect(deployed.toCell().hash()).toEqual(deployedBody.hash());
    expect(confirmed.toCell().hash()).toEqual(confirmedBody.hash());
    expect(terminated.toCell().hash()).toEqual(terminatedBody.hash());

    println("STORAGE_CONTRACT_OUT_DEPLOYED_TX={}", deployTxHash);
    println("STORAGE_CONTRACT_OUT_CONFIRMED_TX={}", confirmTxHash);
    println("STORAGE_CONTRACT_OUT_TERMINATED_TX={}", terminateTxHash);
}

get fun `test storage contract toncenter empty outgoing body is truly empty`() {
    val txHash = "DezUaou9EUB3cNdqtwX7TyQ1zIhGsbRI5g7fRf3fnCI=";
    val txLt = "37535495000003";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);
    var tail = body.beginParse();

    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);

    println("STORAGE_CONTRACT_EMPTY_OUT_TX={} LT={}", txHash, txLt);
}
