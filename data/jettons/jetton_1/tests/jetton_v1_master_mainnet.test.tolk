import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/jetton_v1_master.types"
import "../wrappers/JettonV1Master.gen"
import "./master_test_utils"

get fun `test jetton v1 master mainnet getters and storage`() {
    val master = mainnetJettonV1Master();
    val storage = loadJettonV1MasterStorageFromFork(master);
    val data = master.getJettonData();
    val adminWallet = master.getWalletAddress(data.adminAddress);

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.mintable).toBeTrue();
    expect(data.adminAddress).toEqual(storage.adminAddress);
    expect(data.jettonContent.hash()).toEqual(storage.jettonContent.hash());
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    println("JETTON_V1_MASTER_ADDRESS={}", master.address);
    println("JETTON_V1_MASTER_STORAGE={}", storage);
    println("JETTON_V1_MASTER_DATA={}", data);
    println("JETTON_V1_MASTER_ADMIN_WALLET={}", adminWallet);
}

get fun `test jetton v1 master rejects unauthorized admin change`() {
    val master = mainnetJettonV1Master();
    val sender = testing.treasury("jetton-v1-master-unauthorized-admin-change");
    val before = master.getJettonData();

    val txs = master.sendJettonV1ChangeAdmin(
        sender.address,
        2,
        sender.address,
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<JettonV1ChangeAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: JettonV1MasterErrors.UnauthorizedAdmin,
    });
    expect(master.getJettonData().adminAddress).toEqual(before.adminAddress);
}
