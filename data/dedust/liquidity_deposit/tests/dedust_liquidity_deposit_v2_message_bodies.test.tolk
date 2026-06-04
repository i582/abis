import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/dedust_liquidity_deposit_v2.types"

const FIXTURE_BOC_PATH = "data/dedust/liquidity_deposit/testdata/DedustLiquidityDepositV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x80edc8d7bbbb6526c3b06ccb7c2d02a82c20d8ccdf431bf4088b1f1470cc94cc
const EXPECTED_BLANK_CODE_HASH = 0xb0c7b8d5323cc9ba90fef98f9220fd86bee9382a8910b84f2926c4c9c986ebaf
const DEDUST_FACTORY_V2 = "0:5F0564FB5F604783DB57031CE1CF668A88D4D4D6DA6DE4DB222B4B920D6FD800"
const DEDUST_OWNER = "0:B08690C83977AFB6B4918FA3139D1F9F94F33F1031FE0338B088FE2E009D1EE9"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust liquidity deposit v2 code boc fixture hash`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();
    expect(build("DedustLiquidityDepositV2", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust liquidity deposit decodes toncenter install body`() {
    val txHash = "toqpPP0/qfDlpDjNWUEKteY5HkFTB0Xpv2s+cQU8JVc=";
    val txLt = "81518798000007";
    val bodyBoc = "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";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustLiquidityDepositInstall.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.blankCode.hash()).toEqual(EXPECTED_BLANK_CODE_HASH);
    expect(decoded.codeVersion).toEqual(1);
    expect(decoded.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(decoded.extraParams.remainingBitsCount()).toEqual(70);
    expect(decoded.extraParams.remainingRefsCount()).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_INSTALL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit decodes toncenter deposit asset body`() {
    val txHash = "uSLEgY8AC2HQnhthGcbA144AY8cAK8ouI4LRs7f/+Vk=";
    val txLt = "81518798000008";
    val bodyBoc = "te6cckEBAQEAMwAAYlQkD+UAAAAAAAAAABALETqZS1AkoWcZ9pE5Mo63WVlsOKJfWQKLFG/s3DYh3+MNdigEXoUu";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustDepositAsset.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(882216);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_DEPOSIT_ASSET_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit decodes toncenter deposit liquidity all body`() {
    val txHash = "uSLEgY8AC2HQnhthGcbA144AY8cAK8ouI4LRs7f/+Vk=";
    val txLt = "81518798000008";
    val bodyBoc = "te6cckEBBAEAywACXbVrlZgAAAAAAAAAAIAWENIZBy719taSMfRic6Pz8p5n4gY/wGcWER/FwBOj3SBAAQIBRYAL4Kyfa+wI8Htq4GOcOezRURqamttNvJtkRWlyQa37AABwAwBUBB3NZQAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/jDXYoAIeAFhDSGQcu9fbWkjH0YnOj8/KeZ+IGP8BnFhEfxcATo90gEAsROplLUCShZxn2kTkyjrdZWWw4ol9ZAosUb+zcNiHf6KnxeLU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustDepositLiquidityAll.fromCell(body);
    val proof = decoded.proof.load();
    val proofParams = proof.params.load();
    val assets = decoded.assets.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2));
    expect(proof.contractType).toEqual(0x03);
    expect(proofParams.ownerAddr).toEqual(address(DEDUST_OWNER));
    expect(proofParams.poolParams.isStable).toBeFalse();
    expect(decoded.ownerAddr).toEqual(address(DEDUST_OWNER));
    expect(decoded.minLpAmount).toEqual(0);
    expect(assets.asset0Amount).toEqual(500000000);
    expect(assets.asset1Amount).toEqual(882216);
    expect(decoded.fulfillPayload).toBeNull();
    expect(decoded.rejectPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_DEPOSIT_LIQUIDITY_ALL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit decodes toncenter fulfill deposit body`() {
    val txHash = "LiiKEpvl4W28nEQ4sf1ax5a/YSc2HnrQahVbQGA3wVw=";
    val txLt = "81518798000015";
    val bodyBoc = "te6cckEBAgEAXgABKKrnklYAAAAAAAAAAEHccx+TDXYoAQCJgAvgrJ9r7Ajwe2rgY5w57NFRGpqa2028m2RFaXJBrfsAAEAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/o/coJYg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustFulfillDeposit.fromCell(body);
    val proof = decoded.proof.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2));
    expect(proof.contractType).toEqual(0x02);
    expect(proof.params.isStable).toBeFalse();
    expect(decoded.asset0Deposit).toEqual(499593721);
    expect(decoded.asset1Deposit).toEqual(882216);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_FULFILL_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit decodes toncenter pay out from deposit body`() {
    val txHash = "LiiKEpvl4W28nEQ4sf1ax5a/YSc2HnrQahVbQGA3wVw=";
    val txLt = "81518798000015";
    val bodyBoc = "te6cckEBAwEAfwABH2sLeH8AAAAAAAAAADBjMHQBAUWAC+Csn2vsCPB7auBjnDns0VEamprbTbybZEVpckGt+wAAcAIAh4AWENIZBy719taSMfRic6Pz8p5n4gY/wGcWER/FwBOj3SAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/oohzMNQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustPayOutFromDeposit.fromCell(body);
    val proof = decoded.proof.load();
    val proofParams = proof.params.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2));
    expect(proof.contractType).toEqual(0x03);
    expect(proofParams.ownerAddr).toEqual(address(DEDUST_OWNER));
    expect(decoded.amount).toEqual(406279);
    expect(decoded.payload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_PAY_OUT_FROM_DEPOSIT_TX={} LT={}", txHash, txLt);
}
