import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/testing/expect"
import "../wrappers/JettonV1Master.gen"

const MAINNET_JETTON_V1_RELATION_MASTER_ADDRESS = "EQBlU_tKISgpepeMFT9t3xTDeiVmo25dW_4vUOl6jId_BNIj"
const MAINNET_JETTON_V1_RELATION_OWNER_ADDRESS = "EQCdp7fR_iHcxO8PGuVbV6DgleITPLPebeQmfZdExgxPFj3a"
const MAINNET_JETTON_V1_RELATION_WALLET_ADDRESS = "EQA_wAw2-rhLg-kCypeJW8dcrPKWcHZ9VccrZd_6RPjqYpfR"

get fun `test jetton v1 master derives known wallet address`() {
    val master = JettonV1Master.fromAddress(address(MAINNET_JETTON_V1_RELATION_MASTER_ADDRESS));
    val owner = address(MAINNET_JETTON_V1_RELATION_OWNER_ADDRESS);
    val wallet = address(MAINNET_JETTON_V1_RELATION_WALLET_ADDRESS);

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(master.getWalletAddress(owner)).toEqual(wallet);

    println("JETTON_V1_RELATION_MASTER={}", master.address);
    println("JETTON_V1_RELATION_OWNER={}", owner);
    println("JETTON_V1_RELATION_WALLET={}", wallet);
}
