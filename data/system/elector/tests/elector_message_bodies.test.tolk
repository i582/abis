import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/elector.types"

const EXPECTED_NEW_STAKE_VALIDATOR_PUBKEY = 0x4e37d594cf7d002f7cf0be46f55e64c971ff8139f4a93ed807fb4ac64b2c2e05
const EXPECTED_NEW_STAKE_ELECTION_ID = 1780895496
const EXPECTED_NEW_STAKE_MAX_FACTOR = 294912
const EXPECTED_NEW_STAKE_ADNL_ADDRESS = 0x96c7dc17eb2f7e3152f8900af374b45794b2bfa55ad6defaf453117d63a260e2

fun newStakeBody(): cell {
    return parseCellFromBase64(
        "te6cckEBAgEAmQABqE5zdEt7lvtVwikXRU431ZTPfQAvfPC+RvVeZMlx/4E59Kk+2Af7SsZLLC4FaiZPCAAEgACWx9wX6y9+MVL4kArzdLRXlLK/pVrW3vr0UxF9Y6Jg4gEAgGhnYQjv4NKiz2ez9VmxKG51OVdcfp89d0VH2fgxt22s4AqPLPa4D9iJnKu6z60bUJm4ddrgjoP/XLBANvRElACcseoh",
    );
}

fun newStakeConfirmationBody(): cell {
    return parseCellFromBase64("te6cckEBAQEAEgAAIPN0SEx7lvtVwikXRQAAAACTp2qb");
}

fun recoverStakeBody(): cell {
    return parseCellFromBase64("te6cckEBAQEADgAAGEdldCRDyCvTa7b/JGWu64Y=");
}

fun recoverStakeResponseBody(): cell {
    return parseCellFromBase64("te6cckEBAQEADgAAGPlvcyRDyCvTa7b/JD9a07E=");
}

get fun `test elector decodes real new_stake request and confirmation bodies`() {
    val txHash = "Ct/0I2JowpQJmemg7nyI//avFIwK46ht77gKhZ9CPB0=";
    val txLt = "82232809000003";
    val inBody = newStakeBody();
    val outBody = newStakeConfirmationBody();
    val decodedIn = ElectorNewStake.fromCell(inBody);
    val decodedOut = ElectorNewStakeConfirmed.fromCell(outBody);

    expect(decodedIn.queryId).toEqual(decodedOut.queryId);
    expect(decodedIn.validatorPubkey).toEqual(EXPECTED_NEW_STAKE_VALIDATOR_PUBKEY);
    expect(decodedIn.stakeAt).toEqual(EXPECTED_NEW_STAKE_ELECTION_ID);
    expect(decodedIn.maxFactor).toEqual(EXPECTED_NEW_STAKE_MAX_FACTOR);
    expect(decodedIn.adnlAddress).toEqual(EXPECTED_NEW_STAKE_ADNL_ADDRESS);
    expect(decodedIn.signature.hash()).toBeGreater(0);
    expect(decodedOut.comment).toEqual(0);
    expect(decodedIn.toCell().hash()).toEqual(inBody.hash());
    expect(decodedOut.toCell().hash()).toEqual(outBody.hash());

    println("ELECTOR_REAL_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test elector decodes real recover_stake request and response bodies`() {
    val txHash = "wsFzR4GJkn+xDFPIJahTtIZMKBCtAhvE3OpjfuupDEw=";
    val txLt = "82232699000003";
    val inBody = recoverStakeBody();
    val outBody = recoverStakeResponseBody();
    val decodedIn = ElectorRecoverStake.fromCell(inBody);
    val decodedOut = ElectorRecoverStakePaid.fromCell(outBody);

    expect(decodedIn.queryId).toEqual(decodedOut.queryId);
    expect(decodedIn.queryId).toBeGreater(0);
    expect(decodedIn.toCell().hash()).toEqual(inBody.hash());
    expect(decodedOut.toCell().hash()).toEqual(outBody.hash());

    println("ELECTOR_REAL_RECOVER_STAKE_TX={} LT={}", txHash, txLt);
}
