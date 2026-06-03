import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/jetton_v1_00_master.types"
import "../wrappers/JettonV100Master.gen"

get fun `test jetton v1 00 master local deploy and getter`() {
    val admin = testing.treasury("jetton-v1-00-master-local-admin");
    val master = JettonV100Master.fromStorage({
        totalSupply: 0,
        adminAddress: admin.address,
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    });

    val txs = master.deploy(admin.address, { value: ton("1"), bounce: false });
    expect(txs).toHaveSuccessfulTx({
        from: admin.address,
        to: master.address,
        exitCode: 0,
    });

    val data = master.getJettonData();
    expect(data.totalSupply).toEqual(0);
    expect(data.mintable).toBeTrue();
    expect(data.adminAddress).toEqual(admin.address);
    expect(data.jettonContent.hash()).toEqual(createEmptyCell().hash());
    expect(data.jettonWalletCode.hash()).toEqual(createEmptyCell().hash());

    println("JETTON_V1_00_MASTER_LOCAL_ADDRESS={}", master.address);
    println("JETTON_V1_00_MASTER_LOCAL_DATA={}", data);
}
