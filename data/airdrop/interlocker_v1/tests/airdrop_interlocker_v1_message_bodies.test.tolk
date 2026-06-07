import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/airdrop_interlocker_v1.types"

const LOCK_AND_CLAIM_TX_HASH = "eYMUmlAgJPk0bV0leBD8jbrKXYz81A1L6DrLiXnH+AA="
const LOCK_AND_CLAIM_TX_LT = "57453075000003"
const LOCK_AND_CLAIM_BODY_HASH = 0xb41dc60ec7071c4c1c2a81f3408045727781fee0f54fe62855cf8ed4403af4f8
const LOCK_AND_CLAIM_PROOF_HASH = 0xd1227a5586b90144c4aeb5b13be54b22e0085ce7e2a4788cec445ddf6323b1d9
const CLAIM_NOTIFICATION_BODY_HASH = 0xc0b523c9ebebd1fb0d6b9c31b7913e1a3fba3686c4c11d749864b2a40725c3ec
const EXPECTED_RECEIVER = "0:15dad65f227da08fdba7c5b640e503d6a5774f50d305b5c37889e28d8e1070ef"
const LOCK_AND_CLAIM_BODY_BOC = "te6cckECEQEAAYwAARg6hvGgAAAAAAAi2xUBCUYDDJKbRbk/Y885TaxLDhmT/zDJjBaovScQNYyjkeLm8DMACQIiBYFwAgMEIgEgBQYoSAEBK+wLdPGt97d+J9xyardP9XLnDbw+tQ8UCuBKEaL83YEACCIBIAcIKEgBARpxXwt6CSLPdy2ZOgjGXgeNwS35eWbNI0ENaqA563C6AAMiASAJCihIAQGo4k3/pGxqCovdS0y7B/9lcYpAN1VP/5fIusy+6ZxhaQAEKEgBAd11Mw6kBvHev+yet4hi5p62tOGt2xghuQ552hJ/0x58AAAiAUgLDChIAQFNtKNfYSGwqtSsm2k3TVei5aAfaTxISh4UC8jlhdBYnQAAIgEgDQ4iASAPEChIAQFhvwMsfM7GZ+5AdNFdvmUVDGuguEQQEIoNxG5f1/cWQQAAKEgBAbjLOWAwnnCNXvT4J0/ucUYgGHySUaiI7t8Sqp8kvsmyAAAAS742tZfIn2gj9unxbZA5QPWpXdPUNMFtcN4ieKNjhBw71AWWgvACMiv2pA=="
const CLAIM_NOTIFICATION_BODY_BOC = "te6cckEBAQEANQAAZQE6PKYAAAAAACLbFYACu1rL5E+0Eft0+LbIHKB61K7p6hpgtrhvETxRscIOHeoCy0F4AQPCQDA="

get fun `test airdrop interlocker v1 decodes toncenter lock and claim body`() {
    val body = parseCellFromBase64(LOCK_AND_CLAIM_BODY_BOC);
    var raw = body.beginParse();
    val decoded = AirdropInterlockerV1LockAndClaim.fromCell(body);

    expect(body.hash()).toEqual(LOCK_AND_CLAIM_BODY_HASH);
    expect(raw.loadUint(32)).toEqual(0x3a86f1a0);
    expect(raw.loadUint(64)).toEqual(2284309);
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(1);

    expect(decoded.queryId).toEqual(2284309);
    expect(decoded.proof.hash()).toEqual(LOCK_AND_CLAIM_PROOF_HASH);

    println(
        "AIRDROP_INTERLOCKER_V1_LOCK_AND_CLAIM_TX={} LT={}",
        LOCK_AND_CLAIM_TX_HASH,
        LOCK_AND_CLAIM_TX_LT,
    );
}

get fun `test airdrop interlocker v1 decodes toncenter claim notification body`() {
    val body = parseCellFromBase64(CLAIM_NOTIFICATION_BODY_BOC);
    var raw = body.beginParse();
    val decoded = AirdropInterlockerV1ClaimNotification.fromCell(body);

    expect(body.hash()).toEqual(CLAIM_NOTIFICATION_BODY_HASH);
    expect(raw.loadUint(32)).toEqual(0x013a3ca6);
    expect(raw.loadUint(64)).toEqual(2284309);
    expect(raw.loadAddress()).toEqual(address(EXPECTED_RECEIVER));
    expect(raw.loadCoins()).toEqual(6000000000);
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);

    expect(decoded.queryId).toEqual(2284309);
    expect(decoded.receiver).toEqual(address(EXPECTED_RECEIVER));
    expect(decoded.amount).toEqual(6000000000);

    println(
        "AIRDROP_INTERLOCKER_V1_CLAIM_NOTIFICATION_TX={} LT={}",
        LOCK_AND_CLAIM_TX_HASH,
        LOCK_AND_CLAIM_TX_LT,
    );
}
