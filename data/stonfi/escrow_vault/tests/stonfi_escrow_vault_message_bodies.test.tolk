import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_escrow_vault.types"

const EXCESSES_ADDRESS = "0:F5EEF26012FA502B67623301C1F0F26C2C3ECF96F7CCDAF9F06D9BAD392FD5AC"

get fun `test decodes real stonfi escrow vault deposit`() {
    val txHash = "YT8+xNljGhSzBVbc8ev0macbUVwGpbixBmlUXNMndBo=";
    val txLt = "79568540000043";
    val bodyBoc = "te6cckEBAQEAMgAAX1Ve30sAAAAAahW56R2YAevd5MAl9KBWzsRmA4Ph5NhYfZ8t75m18+DbN1pyX6tYCMQE1gY=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowVaultDepositTokens.fromCell(body);

    expect(decoded.queryId).toEqual(1779808745);
    expect(decoded.amount).toEqual(217);
    expect(decoded.excesses).toBeNotNull();
    expect(decoded.excesses!).toEqual(address(EXCESSES_ADDRESS));
    expect(decoded.forwardTonAmount).toEqual(0);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_VAULT_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real excesses emitted by stonfi escrow vault`() {
    val txHash = "YT8+xNljGhSzBVbc8ev0macbUVwGpbixBmlUXNMndBo=";
    val txLt = "79568540000043";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAahW56XFBvAw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowVaultExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(1779808745);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_VAULT_EXCESSES_TX={} LT={}", txHash, txLt);
}
