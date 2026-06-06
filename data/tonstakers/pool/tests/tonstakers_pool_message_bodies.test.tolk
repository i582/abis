import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonstakers_pool.types"

const EXPECTED_DEPOSIT_BODY_HASH = 0x5763206120b7d980c016f3c11edc62848169e0a888e6f95111d6f364a12a94ed
const EXPECTED_PAYOUT_MINT_BODY_HASH = 0x2343bcbec9989d28c7b5f74a509acf9b81109a23be0194aa58cecd9cda0b2649
const EXPECTED_WITHDRAW_BODY_HASH = 0x03f38f01451f45527260be8882574031bc0ee862c65ed9abacd16afb07cd38e2
const EXPECTED_POOL_WITHDRAWAL_BODY_HASH = 0x6e5843553cab606db6b624c3ceeb0a4dece00835a2246a701753daa90c898c47

const DEPOSIT_OWNER = "0:0A2A9F5AFCF4A7F70758CDB62EA64302A8991A6E974C489570133746ADB6135B"
const WITHDRAW_OWNER = "0:411934C491C2D550BB93C8FB7AF942FA96BBEFDA16A15F4EEF2AF872253E2D83"

get fun `test tonstakers pool decodes real toncenter deposit body`() {
    val txHash = "aG0i4qKmceUceyjHcSHAE4797fFOSS9IYRD5k/ZphCU=";
    val txLt = "81983643000005";
    val bodyBoc = "te6cckEBAQEAFgAAKEfVQ5EAAAAAAAAAAQAAAAAAYWNl9N4tyA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPoolDeposit.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_DEPOSIT_BODY_HASH);
    expect(decoded.queryId).toEqual(1);
    expect(decoded.partnerCode).toEqual(0x0000000000616365);

    println("TONSTAKERS_POOL_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test tonstakers pool decodes real toncenter payout mint body`() {
    val txHash = "aG0i4qKmceUceyjHcSHAE4797fFOSS9IYRD5k/ZphCU=";
    val txLt = "81983643000005";
    val bodyBoc = "te6cckEBAQEAOQAAbRZ0sKAAAAAAAAAAAYABRVPrX56U/uDrGbbF1MhgVRMjTdLpiRKuAmbo1bbCa2hqfvSIgL68IAGQKHZ2";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPayoutMint.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_PAYOUT_MINT_BODY_HASH);
    expect(decoded.queryId).toEqual(1);
    expect(decoded.destination).toEqual(address(DEPOSIT_OWNER));
    expect(decoded.amount).toEqual(893352516);
    expect(decoded.notificationTon).toEqual(100000000);
    expect(decoded.forwardTon).toEqual(0);

    println("TONSTAKERS_POOL_PAYOUT_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test tonstakers pool decodes real toncenter withdraw body`() {
    val txHash = "f6vDSYix12GZcYfRBiw0IQErpUHqARmOEBBYpP3nQJU=";
    val txLt = "81978383000011";
    val bodyBoc = "te6cckEBAQEAVwAAqTGbDNwAAAAAAAAAAFBqfvSIiACCMmmJI4WqoXcnkfb18oX1LXfftC1Cvp3eVfDkSnxbBwAQRk0xJHC1VC7k8j7evlC+pa779oWoV9O7yr4ciU+LYNhN3AGm";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPoolWithdraw.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_WITHDRAW_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.jettonAmount).toEqual(28587280520);
    expect(decoded.fromAddress).toEqual(address(WITHDRAW_OWNER));
    expect(decoded.responseAddress).toEqual(address(WITHDRAW_OWNER));
    expect(decoded.waitTillRoundEnd).toBeFalse();
    expect(decoded.fillOrKill).toBeTrue();

    println("TONSTAKERS_POOL_WITHDRAW_TX={} LT={}", txHash, txLt);
}

get fun `test tonstakers pool decodes real toncenter direct withdrawal body`() {
    val txHash = "f6vDSYix12GZcYfRBiw0IQErpUHqARmOEBBYpP3nQJU=";
    val txLt = "81978383000011";
    val bodyBoc = "te6cckEBAQEADgAAGAp3U1wAAAAAAAAAALkbG1U=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = TonstakersPoolWithdrawal.fromCell(body);

    expect(body.hash()).toEqual(EXPECTED_POOL_WITHDRAWAL_BODY_HASH);
    expect(decoded.queryId).toEqual(0);

    println("TONSTAKERS_POOL_DIRECT_WITHDRAWAL_TX={} LT={}", txHash, txLt);
}
