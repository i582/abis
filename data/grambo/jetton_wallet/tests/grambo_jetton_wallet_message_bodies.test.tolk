import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/grambo_jetton_wallet.types"

const WALLET_ADDRESS = "EQCI95BVEikEt6g3ksm4W-HEPP8FMUa_Bi3f7r1CPQJlxGdv"

get fun `test grambo wallet decodes real master activation body`() {
    val txHash = "rhLetzbdRG9EMhdqYWOB+EkD4gv4txb2VhgJFj7lJ+4=";
    val txLt = "86018714000012";
    val bodyBoc = "te6cckEBAQEADgAAGGt10+IYvFdBQsMnQwLpWAo=";
    val activation = GramboJettonWalletActivate.fromCell(parseCellFromBase64(bodyBoc));

    expect(activation.queryId).toEqual(1782395490336450371);
    println("GRAMBO_WALLET_ACTIVATION_TX={} LT={} WALLET={}", txHash, txLt, WALLET_ADDRESS);
}
