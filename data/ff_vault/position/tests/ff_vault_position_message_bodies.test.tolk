import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/ff_vault_position.types"

const OWNER_ADDRESS = "EQAY4M45NM2XKC-PY5nLKuAR1eKfGxz-N3SqSEQhDXNKbvit"
const EXPECTED_PRICE_STAKED = 222341058504595726115676289921225531382569

get fun `test decodes real ff vault position initialization`() {
    val txHash = "HhtDT80m15nKjdy97clzNbDEAV2CUMSrbRlfbC8OC8M=";
    val txLt = "68399310000013";
    val bodyBoc = "te6cckEBAQEAcgAA3wAAAAEAAAAAAAAAAIADHBnHJpmy5QXx7HM5ZVwCOrxT42Ofxu6VSQiEIa5pTcSb2gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFGs2kfPd3cE7ygWdIpMEptlMMyAI6";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultPositionInit.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(decoded.lockedAssetAmount).toEqual(19949);
    expect(decoded.previousStablePerAssetCollected).toEqual(0);
    expect(decoded.assetPriceStaked).toEqual(EXPECTED_PRICE_STAKED);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_POSITION_INIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes complete real ff vault position unstake request history`() {
    val firstTxHash = "3RbyOIt4BQtJtENpxf5aM4octmhnWmGJRglv2NpWPlM=";
    val firstTxLt = "68435786000003";
    val firstBody = parseCellFromBase64("te6cckEBAQEAEQAAHYp3zzkAAAAAAAAAACA+WMZYWtk=");
    val first = FfVaultPositionUnstakeRequest.fromCell(firstBody);

    val secondTxHash = "9k84fv/nKAMRvouoV5dK29GyDIBIXU8/cu01VYMd97I=";
    val secondTxLt = "68436240000003";
    val secondBody = parseCellFromBase64("te6cckEBAQEAEQAAHYp3zzkAAAAAAAAAACJvaIjspnU=");
    val second = FfVaultPositionUnstakeRequest.fromCell(secondBody);

    expect(first.queryId).toEqual(0);
    expect(second.queryId).toEqual(0);
    expect(first.amountWantedToUnstake > 0).toBeTrue();
    expect(second.amountWantedToUnstake > 0).toBeTrue();
    expect(first.amountWantedToUnstake + second.amountWantedToUnstake).toEqual(10971);
    expect(first.toCell().hash()).toEqual(firstBody.hash());
    expect(second.toCell().hash()).toEqual(secondBody.hash());
    println("FF_VAULT_POSITION_UNSTAKE_TX_1={} LT={}", firstTxHash, firstTxLt);
    println("FF_VAULT_POSITION_UNSTAKE_TX_2={} LT={}", secondTxHash, secondTxLt);
}

get fun `test decodes real ff vault position excesses`() {
    val txHash = "9k84fv/nKAMRvouoV5dK29GyDIBIXU8/cu01VYMd97I=";
    val txLt = "68436240000003";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = FfVaultPositionExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("FF_VAULT_POSITION_EXCESSES_TX={} LT={}", txHash, txLt);
}
