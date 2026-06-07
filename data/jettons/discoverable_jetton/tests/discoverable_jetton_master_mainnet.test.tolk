import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./master_test_utils"
import "../types/discoverable_jetton_master.types"
import "../wrappers/DiscoverableJettonMaster.gen"

get fun `test discoverable jetton master public getters work on mainnet`() {
    val master = mainnetDiscoverableJettonMaster();
    val owner = mainnetDiscoverableJettonOwner();
    val data = master.getJettonData();
    val walletAddress = master.getWalletAddress(owner);

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.mintable).toBeTrue();
    expect(data.jettonWalletCode.hash()).toEqual(
        loadDiscoverableJettonMasterStorageFromFork(master).jettonWalletCode.hash(),
    );
    expect(walletAddress).toEqual(mainnetDiscoverableJettonWalletAddress());

    println("DISCOVERABLE_JETTON_MASTER_GET_JETTON_DATA={}", data);
    println("DISCOVERABLE_JETTON_MASTER_GET_WALLET_ADDRESS={}", walletAddress);
}

get fun `test discoverable jetton master mainnet getters storage and wallet derivation`() {
    val master = mainnetDiscoverableJettonMaster();
    val storage = loadDiscoverableJettonMasterStorageFromFork(master);
    val data = master.getJettonData();
    val owner = mainnetDiscoverableJettonOwner();
    val expectedWallet = mainnetDiscoverableJettonWalletAddress();

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.mintable).toBeTrue();
    expect(data.adminAddress).toEqual(storage.adminAddress);
    expect(data.jettonContent.hash()).toEqual(storage.jettonContent.hash());
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(master.getWalletAddress(owner)).toEqual(expectedWallet);

    println("DISCOVERABLE_JETTON_MASTER_ADDRESS={}", master.address);
    println("DISCOVERABLE_JETTON_MASTER_STORAGE={}", storage);
    println("DISCOVERABLE_JETTON_MASTER_DATA={}", data);
    println("DISCOVERABLE_JETTON_MASTER_OWNER={}", owner);
    println("DISCOVERABLE_JETTON_MASTER_EXPECTED_WALLET={}", expectedWallet);
}

get fun `test discoverable jetton master accepts provide wallet address`() {
    val master = mainnetDiscoverableJettonMaster();
    val sender = testing.treasury("discoverable-jetton-master-provide-wallet-address");
    val owner = mainnetDiscoverableJettonOwner();

    val txs = master.sendProvideWalletAddress(
        sender.address,
        11,
        owner,
        true,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<ProvideWalletAddress>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });
}

get fun `test discoverable jetton master rejects unauthorized admin change`() {
    val master = mainnetDiscoverableJettonMaster();
    val sender = testing.treasury("discoverable-jetton-master-unauthorized-admin-change");
    val before = master.getJettonData();

    val txs = master.sendJettonChangeAdmin(
        sender.address,
        13,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<JettonChangeAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: DiscoverableJettonMasterErrors.UnauthorizedAdmin,
    });
    expect(master.getJettonData().adminAddress).toEqual(before.adminAddress);
}
