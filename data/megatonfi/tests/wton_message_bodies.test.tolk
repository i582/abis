import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/wton_minter.types"
import "../types/wton_wallet.types"

const WTON_MINTER = "0:9A8DA514D575D20234C3FB1395EE9138F5F1AD838ABC905DC42C2389B46BD015"
const WTON_OWNER = "0:A186B2888BF01BF9CC177D7C34A45318D4CC041957DBDACEA0C0328DB8665DA2"

get fun `test wton minter decodes real deposit body`() {
    // Toncenter transaction VKw/rJqVen+RlelX/MpxHDXFfTi/X8mquToUohQ/h+8=,
    // logical time 92162575000016.
    val bodyBoc = "te6cckEBAQEAEwAAIXejNSEAAAAAAAAAAU6EH1NYA6bfIA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = WtonDeposit.fromCell(body);

    expect(decoded.queryId).toEqual(1);
    expect(decoded.amount).toEqual(3896636725);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test wton minter decodes real withdraw body`() {
    // Toncenter transaction D51CYMD7F2gpPK4fbIxX9Vh15El2rGwm0PSEdn7wGJU=,
    // logical time 92162575000096.
    val bodyBoc = "te6cckEBAQEAFAAAI0fRiV8AAAAAAAAAAVAREb5UGPTTFjQ=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = WtonWithdraw.fromCell(body);

    expect(decoded.queryId).toEqual(1);
    expect(decoded.amount).toEqual(4582008129);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test wton minter and wallet decode real burn notification`() {
    // Toncenter transaction 9j3p+08mgbMsNW4TNTLtWqZT82/bjkHv3ZW6Fy723CU=,
    // logical time 92162575000100.
    val bodyBoc = "te6cckEBAQEAVwAAqXvdl94AAAAAAAAAAFAREb5UGAFDDWURF+A385gu+vhpSKYxqZgIMq+3tZ1BgGUbcMy7RQAmo2lFNV10gI0w/sTle6ROPXxrYOKvJBdxCwjibRr0BVCtUOp1";
    val body = parseCellFromBase64(bodyBoc);
    val minterBody = WtonBurnNotification.fromCell(body);
    val walletBody = WtonWalletBurnNotification.fromCell(body);

    expect(minterBody.queryId).toEqual(0);
    expect(minterBody.amount).toEqual(4582008129);
    expect(minterBody.ownerAddress).toEqual(address(WTON_OWNER));
    expect(minterBody.responseDestination).toEqual(address(WTON_MINTER));
    expect(minterBody.customPayload).toBeNull();
    expect(walletBody.toCell().hash()).toEqual(body.hash());
}

get fun `test wton minter and wallet decode real mint internal transfer`() {
    // Outgoing body observed in Toncenter transaction
    // VKw/rJqVen+RlelX/MpxHDXFfTi/X8mquToUohQ/h+8=.
    val bodyBoc = "te6cckEBAQEAVgAApxeNRRkAAAAAAAAAAE6EH1NYAUMNZREX4DfzmC76+GlIpjGpmAgyr7e1nUGAZRtwzLtFAChhrKIi/Ab+cwXfXw0pFMY1MwEGVfb2s6gwDKNuGZdogoLLZ2Q=";
    val body = parseCellFromBase64(bodyBoc);
    val minterBody = WtonMintInternalTransfer.fromCell(body);
    val walletBody = WtonWalletInternalTransfer.fromCell(body);
    var forwardPayload = walletBody.forwardPayload;

    expect(minterBody.queryId).toEqual(0);
    expect(minterBody.amount).toEqual(3896636725);
    expect(minterBody.fromAddress).toEqual(address(WTON_OWNER));
    expect(minterBody.responseDestination).toEqual(address(WTON_OWNER));
    expect(minterBody.forwardTonAmount).toEqual(0);
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(minterBody.toCell().hash()).toEqual(body.hash());
}

get fun `test wton minter and wallet decode real burn instruction`() {
    // Outgoing body observed in Toncenter transaction
    // D51CYMD7F2gpPK4fbIxX9Vh15El2rGwm0PSEdn7wGJU=.
    val bodyBoc = "te6cckEBAQEANQAAZllfB7wAAAAAAAAAAFAREb5UGAE1G0opquukBGmH9icr3SJx6+NbBxV5ILuIWEcTaNegKqmVSjE=";
    val body = parseCellFromBase64(bodyBoc);
    val minterBody = WtonBurn.fromCell(body);
    val walletBody = WtonWalletBurn.fromCell(body);

    expect(minterBody.queryId).toEqual(0);
    expect(minterBody.amount).toEqual(4582008129);
    expect(minterBody.responseDestination).toEqual(address(WTON_MINTER));
    expect(minterBody.customPayload).toBeNull();
    expect(walletBody.toCell().hash()).toEqual(body.hash());
}

get fun `test wton minter decodes real excess response`() {
    // Outgoing body observed in Toncenter transaction
    // 9j3p+08mgbMsNW4TNTLtWqZT82/bjkHv3ZW6Fy723CU=.
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = WtonOutgoingExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
