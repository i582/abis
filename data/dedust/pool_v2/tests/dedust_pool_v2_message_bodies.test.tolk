import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/dedust_pool_v2.types"

const DEDUST_FACTORY_V2 = "0:5F0564FB5F604783DB57031CE1CF668A88D4D4D6DA6DE4DB222B4B920D6FD800"
const DEDUST_POOL_V2_VOLATILE_USER = "0:26B5754C35875C92B0E999789CCFB1AEA97B46298DE33459C157AC72F284E76F"
const DEDUST_POOL_V2_USDT_MINTER = 0xb113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe
const DEDUST_POOL_V2_DEDUST_MINTER = 0x53732b598dd67014b8fa4ceec2786be7e1a326a97bdb5fe9ce0e20296ddd35d6
const DEDUST_POOL_V2_PEER_USER = "0:FB0A3D041510869853E647961731C14B77C1D1D926905D46163A0BA8B2CDC2EA"

fun expectNativeAsset(asset: DedustPoolV2Asset): void {
    match (asset) {
        DedustPoolV2NativeAsset => {}
        DedustPoolV2JettonAsset => {
            expect(false).toBeTrue();
        }
    }
}

fun jettonAssetCell(minter: int): cell {
    return beginCell().storeUint(1, 4).storeInt(0, 8).storeUint(minter, 256).endCell();
}

fun expectJettonAsset(asset: DedustPoolV2Asset, expectedMinter: int): void {
    match (asset) {
        DedustPoolV2NativeAsset => {
            expect(false).toBeTrue();
        }
        DedustPoolV2JettonAsset => {
            expect(asset.workchainId).toEqual(0);
            expect(asset.toCell().hash()).toEqual(jettonAssetCell(expectedMinter).hash());
        }
    }
}

fun expectVolatileTonUsdtPoolProof(proof: DedustPoolV2PoolProof): void {
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2));
    match (proof.params.poolType) {
        DedustPoolV2VolatilePool => {}
        DedustPoolV2StablePool => {
            expect(false).toBeTrue();
        }
    }
    expectNativeAsset(proof.params.asset0);
    expectJettonAsset(proof.params.asset1, DEDUST_POOL_V2_USDT_MINTER);
}

get fun `test dedust pool v2 decodes toncenter swap external body`() {
    val txHash = "54yU/L+K9nysjaX0lUDfdUn5CuLMHabYFlvg+igvy88=";
    val txLt = "81520978000013";
    val bodyBoc = "te6cckEBAwEAiAACbWHuVC0AAAAAAAAAAFAXXdPxaABNauqYaw65JWHTMvE5n2NdUvaMUxvGaLOCr1jl5QnO3jqfjJQBAgBFgAvgrJ9r7Ajwe2rgY5w57NFRGpqa2028m2RFaXJBrfsAACEAS2ohsk+ABNauqYaw65JWHTMvE5n2NdUvaMUxvGaLOCr1jl5QnO3hJw4gVA==";
    val expectedUser = address(DEDUST_POOL_V2_VOLATILE_USER);
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustPoolV2SwapExternal.fromCell(body);
    val proof = decoded.proof.load();
    val swapParams = decoded.swapParams.load();

    expect(decoded.queryId).toEqual(0);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2));
    expectNativeAsset(proof.params);
    expect(decoded.amount).toEqual(6272401174);
    expect(decoded.senderAddr).toEqual(expectedUser);
    expect(decoded.current.limit).toEqual(11139273);
    expect(decoded.current.next).toBeNull();
    expect(swapParams.deadline).toEqual(1780593231);
    expect(swapParams.recipientAddr).toBeNotNull();
    expect(swapParams.recipientAddr!).toEqual(expectedUser);
    expect(swapParams.referralAddr).toBeNull();
    expect(swapParams.fulfillPayload).toBeNull();
    expect(swapParams.rejectPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_POOL_V2_SWAP_EXTERNAL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust pool v2 decodes toncenter pay out from pool body`() {
    val txHash = "54yU/L+K9nysjaX0lUDfdUn5CuLMHabYFlvg+igvy88=";
    val txLt = "81520978000013";
    val bodyBoc = "te6cckEBAgEAewABYq1OtvUAAAAAAAAAADqfoSgATWrqmGsOuSVh0zLxOZ9jXVL2jFMbxmizgq9Y5eUJzt4BAImAC+Csn2vsCPB7auBjnDns0VEamprbTbybZEVpckGt+wAAQBALETqZS1AkoWcZ9pE5Mo63WVlsOKJfWQKLFG/s3DYh3+jZQHs2";
    val expectedUser = address(DEDUST_POOL_V2_VOLATILE_USER);
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustPoolV2PayOutFromPool.fromCell(body);
    val proof = decoded.proof.load();

    expect(decoded.queryId).toEqual(0);
    expectVolatileTonUsdtPoolProof(proof);
    expect(decoded.amount).toEqual(11139602);
    expect(decoded.recipientAddr).toBeNotNull();
    expect(decoded.recipientAddr!).toEqual(expectedUser);
    expect(decoded.payload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_POOL_V2_PAY_OUT_FROM_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust pool v2 decodes toncenter swap event body`() {
    val txHash = "54yU/L+K9nysjaX0lUDfdUn5CuLMHabYFlvg+igvy88=";
    val txLt = "81520978000013";
    val bodyBoc = "te6cckEBAgEAYgABXpxhDeMBALETqZS1AkoWcZ9pE5Mo63WVlsOKJfWQKLFG/s3DYh3+UBdd0/FjqfoSAQBbgATWrqmGsOuSVh0zLxOZ9jXVL2jFMbxmizgq9Y5eUJzt41MbY8PG4apdIs6bBFp5+Sc=";
    val expectedUser = address(DEDUST_POOL_V2_VOLATILE_USER);
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustPoolV2SwapEvent.fromCell(body);
    val details = decoded.details.load();

    expectNativeAsset(decoded.assetIn);
    expectJettonAsset(decoded.assetOut, DEDUST_POOL_V2_USDT_MINTER);
    expect(decoded.amountIn).toEqual(6272401174);
    expect(decoded.amountOut).toEqual(11139602);
    expect(details.senderAddr).toEqual(expectedUser);
    expect(details.referralAddr).toBeNull();
    expect(details.reserve0).toBeGreater(0);
    expect(details.reserve1).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_POOL_V2_SWAP_EVENT_TX={} LT={}", txHash, txLt);
}

get fun `test dedust pool v2 decodes toncenter swap peer body`() {
    val txHash = "a2Ao4Q2xTcvybi4UEnUosq4Al2bGlBnT5hAurPE/CJU=";
    val txLt = "81520678000026";
    val bodyBoc = "te6cckEBAwEA6QACqXKsqKpqIZW7AAAAABALETqZS1AkoWcZ9pE5Mo63WVlsOKJfWQKLFG/s3DYh3+MMB/SAH2FHoIKiENMKfMjywuY4KW74Ojsk0guowsdBdRZZuF1BAUABAgDLgAvgrJ9r7Ajwe2rgY5w57NFRGpqa2028m2RFaXJBrfsAAEEAU3MrWY3WcBS4+kzuwnhr5+GjJql721/pzg4gKW3dNdYQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/oAEtqIZXZgB9hR6CCohDTCnzI8sLmOClu+Do7JNILqMLHQXUWWbhdQbYGPvg=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustPoolV2SwapPeer.fromCell(body);
    val proof = decoded.proof.load();
    val swapParams = decoded.swapParams.load();

    expect(decoded.queryId).toEqual(7647558272643235840);
    expect(proof.factoryAddr).toEqual(address(DEDUST_FACTORY_V2));
    match (proof.params.poolType) {
        DedustPoolV2VolatilePool => {}
        DedustPoolV2StablePool => {
            expect(false).toBeTrue();
        }
    }
    expectJettonAsset(proof.params.asset0, DEDUST_POOL_V2_DEDUST_MINTER);
    expectJettonAsset(proof.params.asset1, DEDUST_POOL_V2_USDT_MINTER);
    expectJettonAsset(decoded.asset, DEDUST_POOL_V2_USDT_MINTER);
    expect(decoded.amount).toEqual(788468);
    expect(decoded.senderAddr).toEqual(address(DEDUST_POOL_V2_PEER_USER));
    expect(decoded.current.limit).toBeGreater(0);
    expect(decoded.current.next).toBeNull();
    expect(swapParams.deadline).toBeGreater(0);
    expect(swapParams.recipientAddr).toBeNotNull();
    expect(swapParams.referralAddr).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_POOL_V2_SWAP_PEER_TX={} LT={}", txHash, txLt);
}
