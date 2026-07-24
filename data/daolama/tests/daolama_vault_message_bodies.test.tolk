import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/daolama_vault.types"

const DAOLAMA_VAULT = "0:A4793BCE49307006D3F4E97D815FB4C78FF7655FAECF8606111AE29F8D6B41F4"

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
}

get fun `test daolama vault decodes real signed supply body`() {
    // Toncenter transaction f+Pjk7MCzVIcEqiLRFACmv3ZNjOal9iOht1Hx2H+AOA=,
    // logical time 88620673000017.
    val bodyBoc = "te6cckEBAwEAqQABIVwRrakAAAAAAAAAAEO5rKAIAQGAOn8p1Ky00EV3ne6JePE/GOthMWzwixCEegnmntiH/T93osrNXXkRCBiaHfQCoOUMoYLUoo4z0QU0oZWyXGtyDQIAn4AUjyd5ySYOANp+nS+wK/aY8f7sq/XZ8MDCI1xT8a1oPpAAqMBZdl52NOf5NvIBMJzNcRMaB5zsIH/TSx2QBFvi0B2pNJuhcEa2pQ7msoAgadVE7Q==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DaolamaSupply.fromCell(body);
    val proof = DaolamaSupplyAuthorizationProof.fromCell(decoded.proof);
    val authorization = proof.authorization.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(1000000000);
    expect(authorization.vaultAddress).toEqual(address(DAOLAMA_VAULT));
    expect(authorization.supplierAddress).toEqual(
        address("0:2A30165D979D8D39FE4DBC804C27335C44C681E73B081FF4D2C7640116F8B407"),
    );
    expect(authorization.validUntil).toEqual(1783441128);
    expect(authorization.operation).toEqual(0x5c11ada9);
    expect(authorization.amount).toEqual(1000000000);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test daolama vault decodes real lp burn notification`() {
    // Toncenter transaction +mdi16gNC5xI/3H0avlnO+BecytqJEs/fS+ZHBprM58=,
    // logical time 91822447000005.
    val bodyBoc = "te6cckEBAQEAVwAAqXvdl94AAAAAAAAAAFG+fjJR+ACwJc7mjxumzCwQWv0CfajXIFg2fJSL2OAfpGY7It1tFwAWBLnc0eN02YWCC1+gT7Ua5AsGz5KRexwD9IzHZFutouDgtqCv";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DaolamaLpBurnNotification.fromCell(body);
    val owner = address("0:5812E773478DD36616082D7E813ED46B902C1B3E4A45EC700FD2331D916EB68B");

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(119854540063);
    expect(decoded.senderAddress).toEqual(owner);
    expect(decoded.responseDestination).toEqual(owner);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test daolama vault decodes real lp mint transfer`() {
    // Outgoing body observed in Toncenter transaction
    // pKeSL2D+QQVHTFKP71snqxobMzCGKyi2NpJGgtp+sDE=.
    val bodyBoc = "te6cckEBAQEAVwAAqReNRRkAAAAAAAAAAFC6Q7dACAFI8neckmDgDafp0vsCv2mPH+7Kv12fDAwiNcU/GtaD6QAIu/qt6kVmKbu4QvW728gKWGbPmAWmOULhAacf3I3jrMEK/dT8";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DaolamaLpInternalTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(50000000000);
    expect(decoded.fromAddress).toEqual(address(DAOLAMA_VAULT));
    expect(decoded.responseDestination).toEqual(
        address("0:22EFEAB7A91598A6EEE10BD6EF6F2029619B3E601698E50B84069C7F72378EB3"),
    );
    expect(decoded.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test daolama vault decodes real nft transfer`() {
    // Outgoing body observed in Toncenter transaction
    // 8Iokb2N+vOE+aTl3xr0fYOYxF15Cb/VBJcpCE0B3wUI=.
    val bodyBoc = "te6cckEBAQEAUgAAn1/MPRQAAAAAAAAAAIAex5VtcYGOeus1AJXvNuYn4HJ7bg2EqD1dCSHflGkL7FAAR2ykYVWUerikbAvUJFSorS28YF54pk+SoeJr+8p4T9QIlP2flQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DaolamaNftTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(
        address("0:F63CAB6B8C0C73D759A804AF79B7313F0393DB706C2541EAE8490EFCA3485F62"),
    );
    expect(decoded.responseDestination).toEqual(
        address("0:11DB291855651EAE291B02F509152A2B4B6F18179E2993E4A8789AFEF29E13F5"),
    );
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test daolama vault decodes real excess response`() {
    // Outgoing body observed in Toncenter transaction
    // +mdi16gNC5xI/3H0avlnO+BecytqJEs/fS+ZHBprM58=.
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DaolamaExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
