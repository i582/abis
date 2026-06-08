import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/aqua_usd_master_vault.types"

const AQUA_ADMIN = "0:DA9575A03C8671066F0AC738A5B79A71DE27B616BD31DD8E7E5EE78A67ACCEF9"
const WALLET_DISCOVERY_OWNER = "0:A3D82563D28E4C5AB79D019CCF9A30B8F4DD4348D78B3FC272B298F3FA7D6E1C"
const JETTON_NOTIFY_SENDER = "0:528C97541FF6192C46BCCFC06D67BBEFD94AA3FFA54E41A7CF580483E01EDB1C"
const NFT_NEW_OWNER = "0:969D0E08E3F426FFA746CC15C011C6BF3BD22DF5E8F5635C3C2A437F9BC2DFFB"

get fun `test aqua decodes real provide wallet address body`() {
    val txHash = "S2ANix2Rzay1+/G2IvaHBtZnnQT9bosRdqLz0Z6g0Fs=";
    val txLt = "66165686000005";
    val bodyBoc = "te6cckEBAQEAMAAAWyx2uXOBM/KwwnuuToAUewSselHJi1bzoDOZ80YXHpuoaRrxZ/hOVlMef0+tw4im9Lxi";
    val decoded = AquaProvideWalletAddress.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(9310051695695998542);
    expect(decoded.ownerAddress).toEqual(address(WALLET_DISCOVERY_OWNER));
    expect(decoded.includeAddress).toBeFalse();

    println("AQUA_PROVIDE_WALLET_ADDRESS_TX={} LT={}", txHash, txLt);
}

get fun `test aqua decodes real take wallet address response body`() {
    val txHash = "S2ANix2Rzay1+/G2IvaHBtZnnQT9bosRdqLz0Z6g0Fs=";
    val txLt = "66165686000005";
    val bodyBoc = "te6cckEBAQEAMAAAW9FzVACBM/KwwnuuToAIUSOtpyn2+vYIaKqYi0TC2zbdcohGa0tqB0BRnOS+fAjEuB0R";
    val decoded = AquaTakeWalletAddress.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(9310051695695998542);
    expect(decoded.walletAddress).toBeNotNull();
    expect(decoded.ownerAddress).toBeNull();

    println("AQUA_TAKE_WALLET_ADDRESS_TX={} LT={}", txHash, txLt);
}

get fun `test aqua decodes real jetton transfer notification body`() {
    val txHash = "KUIncj9UlM6g7qZmYdZEGwBkc+WoUa6t46OtT2EB0Is=";
    val txLt = "67588881000006";
    val bodyBoc = "te6cckEBAgEAUQABZnNi0JxUbeTvAg5R4VgTiT7gCAClGS6oP+wyWI15n4Daz3ffspVH/0qcg0+esAkHwD22OQEAMgAAAABCT09TVCDQuNGJ0Lgg0LIgRXh0b27O8/f5";
    val decoded = AquaJettonTransferNotification.fromCell(parseCellFromBase64(bodyBoc));
    var payload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(6083770386830217697);
    expect(decoded.amount).toEqual(555000000000);
    expect(decoded.sender).toEqual(address(JETTON_NOTIFY_SENDER));
    expect(payload.remainingBitsCount()).toBeGreater(0);
    expect(payload.remainingRefsCount()).toEqual(1);

    println("AQUA_JETTON_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test aqua decodes real asset operation envelope body`() {
    val txHash = "xEUv/uUQjLQh38vOBZ9y1ek5zyJFar1lFP56o8Q479g=";
    val txLt = "59209945000016";
    val bodyBoc = "te6cckEBAwEAlgABGgKq7Rx5YH2JfQuEoUABAWBCACg9wwUepG4riIN6TDM2ftzLb7bTkvF7IQCQk0zmqFmbAAAAAAAAAAAAAAAAAAECAKFfzD0UAAAAAAAAAACAEtOhwRx+hN/06NmCuAI41+d6Rb69Hqxrh4VIb/N4W/9wA2pV1oDyGcQZvCsc4pbeacd4ntha9Md2Ofl7nimeszvkICidoowk";
    val decoded = AquaExecuteAssetOperation.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.queryId).toEqual(8746128505815401633);
    expect(decoded.operation.remainingBitsCount()).toBeGreater(0);
    expect(decoded.operation.remainingRefsCount()).toBeGreater(0);

    println("AQUA_ASSET_OPERATION_TX={} LT={}", txHash, txLt);
}

get fun `test aqua decodes real nft transfer body`() {
    val txHash = "xEUv/uUQjLQh38vOBZ9y1ek5zyJFar1lFP56o8Q479g=";
    val txLt = "59209945000016";
    val bodyBoc = "te6cckEBAQEAUwAAoV/MPRQAAAAAAAAAAIAS06HBHH6E3/To2YK4AjjX53pFvr0erGuHhUhv83hb/3ADalXWgPIZxBm8Kxzilt5px3ie2Fr0x3Y5+XueKZ6zO+QgKCr4lms=";
    val decoded = AquaNftTransfer.fromCell(parseCellFromBase64(bodyBoc));
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(address(NFT_NEW_OWNER));
    expect(decoded.responseDestination).toEqual(address(AQUA_ADMIN));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardAmount).toEqual(1);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();

    println("AQUA_NFT_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test aqua decodes real jetton transfer body`() {
    val txHash = "da70z4+64gtx8vsupJ9JMST3Gp2xBf0gY8M/IK1JyQE=";
    val txLt = "59183583000026";
    val bodyBoc = "te6cckEBAgEAWwACqg+KfqV8jCTDYKLco10LyL+qyAG1KutAeQziDN4VjnFLbzTjvE9sLXpjuxz8vc8Uz1md8wA2pV1oDyGcQZvCsc4pbeacd4ntha9Md2Ofl7nimeszvmEBAQAA7REG+w==";
    val decoded = AquaJettonTransfer.fromCell(parseCellFromBase64(bodyBoc));
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(8974588579001064611);
    expect(decoded.amount).toEqual(896516487852);
    expect(decoded.destination).toEqual(address(AQUA_ADMIN));
    expect(decoded.responseDestination).toEqual(address(AQUA_ADMIN));
    expect(decoded.customPayload).toBeNotNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(1);
    expect(forwardPayload.loadBool()).toBeTrue();

    println("AQUA_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test aqua decodes real payout finalization and excess body`() {
    val txHash = "klUYS9PpV8v19eLvMm43t7md4toIFi5GHfpwwCw/urw=";
    val txLt = "59184400000008";
    val requestBoc = "te6cckEBAQEADwAAGdlvCwgJ8pDyOHjSWED+5gaS";
    val excessBoc = "te6cckEBAQEADgAAGNUydtsJ8pDyOHjSWJUjYCk=";
    val request = AquaFinalizePayout.fromCell(parseCellFromBase64(requestBoc));
    val excess = AquaExcesses.fromCell(parseCellFromBase64(excessBoc));

    expect(request.queryId).toEqual(716794660709257816);
    expect(request.operationsEnabled).toBeFalse();
    expect(excess.queryId).toEqual(716794660709257816);

    println("AQUA_PAYOUT_FINALIZATION_TX={} LT={}", txHash, txLt);
}
