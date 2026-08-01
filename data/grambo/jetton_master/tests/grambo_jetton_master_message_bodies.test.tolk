import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/grambo_jetton_master.types"

const MASTER_ADDRESS = "EQBom4slLIetxxKbAMYRD61BQwsxRnR_Tm0AO5ejiXsSYuYT"

get fun `test grambo master decodes real unlock-wallet and activation bodies`() {
    val txHash = "rhLetzbdRG9EMhdqYWOB+EkD4gv4txb2VhgJFj7lJ+4=";
    val txLt = "86018714000012";
    val unlockBodyBoc = "te6cckEBAQEAMAAAW3lmQQ8YvFdBQsMnQ4AREj1jUiWCLPo8m7P+RO9o5mEBAvASZdkh0KewLhDVNRCFXUEK";
    val activationBodyBoc = "te6cckEBAQEADgAAGGt10+IYvFdBQsMnQwLpWAo=";
    val unlock = GramboJettonMasterUnlockWallet.fromCell(parseCellFromBase64(unlockBodyBoc));
    val activation = GramboJettonMasterActivateWallet.fromCell(
        parseCellFromBase64(activationBodyBoc),
    );

    expect(unlock.queryId).toEqual(1782395490336450371);
    expect(activation.queryId).toEqual(unlock.queryId);
    println(
        "GRAMBO_MASTER_UNLOCK_TX={} LT={} MASTER={} OWNER={}",
        txHash,
        txLt,
        MASTER_ADDRESS,
        unlock.owner,
    );
}
