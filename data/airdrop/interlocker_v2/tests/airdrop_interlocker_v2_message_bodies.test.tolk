import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/airdrop_interlocker_v2.types"

const LOCK_AND_CLAIM_TX_HASH = "K3pSiJzOSHXycZ0uSMVWicgJpDSNp74CvIrY17SsTxo="
const LOCK_AND_CLAIM_TX_LT = "82025063000003"
const LOCK_AND_CLAIM_BODY_HASH = 0x93007c749b99eb0d084d57b0aa0ecc83d56f572dba386a7ce4ef8c8f74d7ae68
const LOCK_AND_CLAIM_PROOF_HASH = 0xd002f17a14395d77e3b0b623dfa22dccff9c5e6f544acc4eadb4e41398ffc0a1
const CLAIM_NOTIFICATION_BODY_HASH = 0xa5211da647597b7537bee52a82d135fe7c2000e6966fe75bc093e6b8c425c757
const EXPECTED_RECEIVER = "0:5fe623d175df28b2ee3a720fbcb3add5745a8c110629258a3533a481ab040bcd"
const LOCK_AND_CLAIM_BODY_BOC = "te6cckECHwEAArkAARk6hvGgAAAAAAAGy8XAAQlGA5zVPNR8xv5sh76+AwxxGv9RePYUMX9MIigYSXtjFgPuAA4CIgWBcAIDBCIBIAUGKEgBAdgVWcz7Kl4tOBrL8KgMuOETNPopNwYKnYN+5olgd32UAA0oSAEBt/hc0VZtfECzJ/M+RV38w3BkzeuQlStX57IaSR0/UmkADCIBIAcIIgEgCQooSAEBQCX9mu/JRou1F85IieAgSaJU2gGscQNRbn9se3f9gMAACyhIAQFjR6spCri4tMWWOwZpcm08APSUxfPQo94wGaYX0Pr1AgAKIgEgCwwoSAEBx57Y0xWzunb5iOcSoV6Oh/d6QTN1aiRnQidqZt3tVUMACSIBIA0OKEgBAYv2ys8v3OOZtYf6IPYyuquYGxIqX8NY7X6WvBnx3xsZAAciASAPEChIAQEQIPDGug5WLvBDbRh/Ym7c5OJGj4hHl0zeGBa4P1EkCgAGIgEgERIoSAEBgwvsOVVuz91MmfSiXjUx2+AIMj5r4vrh+tybhmwdSdYABSIBIBMUKEgBARllR1OwZ7hMPDRg90mTvMPBcIbVruImFwz0hmvnWe7CAAUiASAVFihIAQHUC+5zXoQV29vg+uALurx2cUtcXHOXHT88isiPHTM+UAADIgEgFxgoSAEB6XGMFiL37tP4tLQckFmJrTTTvuauxVRZusL6pwehi24AAiIBIBkaIgEgGxwoSAEBsF2Lv23I5VbpYYOFfylzX6acnrIG55MmPklIlmH+LzIAACIBIB0eKEgBAUJ7nOb7NMF1w5+OwlaZkMGgRkvH+sFvjLN4KG0UIpBaAAAoSAEBm7TYmim2BcDPaBH/lEnJl2iIcrJ7V0Ddno2jQ7x8b90AAABKvKI9F13yiy7jpyD7yzrdV0WowRBiklijUzpIGrBAvNUEqBfIAOyabkE="
const CLAIM_NOTIFICATION_BODY_BOC = "te6cckEBAQEANQAAZQE6PKYAAAAAAAbLxYAL/MR6LrvlFl3HTkH3lnW6rotRgiDFJLFGpnSQNWCBeaoDYXWeAasw/80="

get fun `test airdrop interlocker v2 decodes toncenter lock and claim body`() {
    val body = parseCellFromBase64(LOCK_AND_CLAIM_BODY_BOC);
    var raw = body.beginParse();
    val decoded = AirdropInterlockerV2LockAndClaim.fromCell(body);

    expect(body.hash()).toEqual(LOCK_AND_CLAIM_BODY_HASH);
    expect(raw.loadUint(32)).toEqual(0x3a86f1a0);
    expect(raw.loadUint(64)).toEqual(445381);
    expect(raw.remainingBitsCount()).toEqual(1);
    expect(raw.remainingRefsCount()).toEqual(1);

    expect(decoded.queryId).toEqual(445381);
    expect(decoded.proof).toBeNotNull();
    expect(decoded.proof!.hash()).toEqual(LOCK_AND_CLAIM_PROOF_HASH);

    println(
        "AIRDROP_INTERLOCKER_V2_LOCK_AND_CLAIM_TX={} LT={}",
        LOCK_AND_CLAIM_TX_HASH,
        LOCK_AND_CLAIM_TX_LT,
    );
}

get fun `test airdrop interlocker v2 decodes toncenter claim notification body`() {
    val body = parseCellFromBase64(CLAIM_NOTIFICATION_BODY_BOC);
    var raw = body.beginParse();
    val decoded = AirdropInterlockerV2ClaimNotification.fromCell(body);

    expect(body.hash()).toEqual(CLAIM_NOTIFICATION_BODY_HASH);
    expect(raw.loadUint(32)).toEqual(0x013a3ca6);
    expect(raw.loadUint(64)).toEqual(445381);
    expect(raw.loadAddress()).toEqual(address(EXPECTED_RECEIVER));
    expect(raw.loadCoins()).toEqual(7260000000);
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);

    expect(decoded.queryId).toEqual(445381);
    expect(decoded.receiver).toEqual(address(EXPECTED_RECEIVER));
    expect(decoded.amount).toEqual(7260000000);

    println(
        "AIRDROP_INTERLOCKER_V2_CLAIM_NOTIFICATION_TX={} LT={}",
        LOCK_AND_CLAIM_TX_HASH,
        LOCK_AND_CLAIM_TX_LT,
    );
}
