import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/dedust_liquidity_deposit_v1.types"

// Real Toncenter BoCs from `data/dedust/research/liquidity_deposit_message_bodies.md`.
// They are valid v1 ABI evidence because DedustLiquidityDepositV1 and the
// curated V2 Liquidity Deposit fixture use the same installed code hash.
const DEDUST_FACTORY_V2_SAMPLE = "0:5F0564FB5F604783DB57031CE1CF668A88D4D4D6DA6DE4DB222B4B920D6FD800"
const DEDUST_OWNER_SAMPLE = "0:B08690C83977AFB6B4918FA3139D1F9F94F33F1031FE0338B088FE2E009D1EE9"

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

get fun `test dedust liquidity deposit v1 decodes real deposit asset body`() {
    val txHash = "uSLEgY8AC2HQnhthGcbA144AY8cAK8ouI4LRs7f/+Vk=";
    val txLt = "81518798000008";
    val bodyBoc = "te6cckEBAQEAMwAAYlQkD+UAAAAAAAAAABALETqZS1AkoWcZ9pE5Mo63WVlsOKJfWQKLFG/s3DYh3+MNdigEXoUu";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustDepositAsset.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    match (decoded.asset) {
        DedustAssetNative => {
            expect(false).toBeTrue();
        }
        DedustAssetJetton => {
            expect(decoded.asset.workchainId).toEqual(0);
            expect(decoded.asset.address).toEqual(
                bits256FromUint(0xb113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe),
            );
        }
    }
    expect(decoded.amount).toEqual(882216);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_V1_DEPOSIT_ASSET_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit v1 decodes real deposit liquidity all body`() {
    val txHash = "uSLEgY8AC2HQnhthGcbA144AY8cAK8ouI4LRs7f/+Vk=";
    val txLt = "81518798000008";
    val bodyBoc = "te6cckEBBAEAywACXbVrlZgAAAAAAAAAAIAWENIZBy719taSMfRic6Pz8p5n4gY/wGcWER/FwBOj3SBAAQIBRYAL4Kyfa+wI8Htq4GOcOezRURqamttNvJtkRWlyQa37AABwAwBUBB3NZQAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/jDXYoAIeAFhDSGQcu9fbWkjH0YnOj8/KeZ+IGP8BnFhEfxcATo90gEAsROplLUCShZxn2kTkyjrdZWWw4ol9ZAosUb+zcNiHf6KnxeLU=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustDepositLiquidityAll.fromCell(body);
    val proof = decoded.proof.load();
    val proofParams = proof.params.load();
    val assets = decoded.assets.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2_SAMPLE));
    expect(proof.contractType).toEqual(0x03);
    expect(proofParams.ownerAddr).toEqual(address(DEDUST_OWNER_SAMPLE));
    expect(proofParams.poolParams.isStable).toBeFalse();
    expect(decoded.ownerAddr).toEqual(address(DEDUST_OWNER_SAMPLE));
    expect(decoded.minLpAmount).toEqual(0);
    expect(assets.asset0Amount).toEqual(500000000);
    expect(assets.asset1Amount).toEqual(882216);
    expect(decoded.fulfillPayload).toBeNull();
    expect(decoded.rejectPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_V1_DEPOSIT_LIQUIDITY_ALL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit v1 decodes real fulfill deposit body`() {
    val txHash = "LiiKEpvl4W28nEQ4sf1ax5a/YSc2HnrQahVbQGA3wVw=";
    val txLt = "81518798000015";
    val bodyBoc = "te6cckEBAgEAXgABKKrnklYAAAAAAAAAAEHccx+TDXYoAQCJgAvgrJ9r7Ajwe2rgY5w57NFRGpqa2028m2RFaXJBrfsAAEAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/o/coJYg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustFulfillDeposit.fromCell(body);
    val proof = decoded.proof.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2_SAMPLE));
    expect(proof.contractType).toEqual(0x02);
    expect(proof.params.isStable).toBeFalse();
    expect(decoded.asset0Deposit).toEqual(499593721);
    expect(decoded.asset1Deposit).toEqual(882216);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_V1_FULFILL_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test dedust liquidity deposit v1 decodes real pay out from deposit body`() {
    val txHash = "LiiKEpvl4W28nEQ4sf1ax5a/YSc2HnrQahVbQGA3wVw=";
    val txLt = "81518798000015";
    val bodyBoc = "te6cckEBAwEAfwABH2sLeH8AAAAAAAAAADBjMHQBAUWAC+Csn2vsCPB7auBjnDns0VEamprbTbybZEVpckGt+wAAcAIAh4AWENIZBy719taSMfRic6Pz8p5n4gY/wGcWER/FwBOj3SAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/oohzMNQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustPayOutFromDeposit.fromCell(body);
    val proof = decoded.proof.load();
    val proofParams = proof.params.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2_SAMPLE));
    expect(proof.contractType).toEqual(0x03);
    expect(proofParams.ownerAddr).toEqual(address(DEDUST_OWNER_SAMPLE));
    expect(decoded.amount).toEqual(406279);
    expect(decoded.payload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_LIQUIDITY_DEPOSIT_V1_PAY_OUT_FROM_DEPOSIT_TX={} LT={}", txHash, txLt);
}
