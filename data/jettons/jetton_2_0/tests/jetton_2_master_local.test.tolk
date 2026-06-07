import "@acton/build"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/jetton_2_master.types"
import "../types/jetton_2_wallet.types"
import "../wrappers/Jetton2Master.gen"
import "../wrappers/Jetton2Wallet.gen"

get fun `test jetton v2 master local getters and owner shard wallet address`() {
    val admin = testing.treasury("jetton-2-master-local-admin");
    val owner = testing.treasury("jetton-2-master-local-owner");
    val master = deployLocalJetton2Master(admin.address);
    val storage = loadLocalJetton2MasterStorage(master);
    val data = master.getJettonData();
    val nextAdminAddress = master.getNextAdminAddress();
    val walletAddress = master.getWalletAddress(owner.address);
    val expectedWallet = localJetton2WalletInitial(master, owner.address);

    expect(data.mintable).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.adminAddress).toEqual(admin.address);
    expect(nextAdminAddress).toBeNoneAddress();
    expect(storage.adminAddress).toEqual(admin.address);
    expect(storage.nextAdminAddress).toBeNull();
    expect(data.jettonWalletCode.hash()).toEqual(build("Jetton2Wallet").hash());
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(walletAddress).toEqual(expectedWallet.address);

    println("JETTON_2_MASTER_STORAGE={}", storage);
    println("JETTON_2_MASTER_GET_JETTON_DATA={}", data);
    println("JETTON_2_MASTER_GET_NEXT_ADMIN_ADDRESS={}", nextAdminAddress);
    println("JETTON_2_MASTER_OWNER_SHARD_WALLET_ADDRESS={}", walletAddress);
}

get fun `test jetton v2 master accepts discovery and top up but rejects non admin`() {
    val admin = testing.treasury("jetton-2-master-actions-admin");
    val sender = testing.treasury("jetton-2-master-actions-sender");
    val owner = testing.treasury("jetton-2-master-actions-owner");
    val master = deployLocalJetton2Master(admin.address);

    val provideTxs = master.sendJetton2MasterProvideWalletAddress(
        sender.address,
        11,
        owner.address,
        true,
        { value: ton("0.05"), bounce: false },
    );
    expect(provideTxs).toHaveSuccessfulTx<Jetton2MasterProvideWalletAddress>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });

    val topUpTxs = master.sendJetton2MasterTopUp(
        sender.address,
        12,
        { value: ton("0.01"), bounce: false },
    );
    expect(topUpTxs).toHaveSuccessfulTx<Jetton2MasterTopUp>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });

    val before = master.getJettonData();
    val changeAdminTxs = master.sendJetton2MasterChangeAdmin(
        sender.address,
        13,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );
    expect(changeAdminTxs).toHaveFailedTx<Jetton2MasterChangeAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: Jetton2MasterErrors.UnauthorizedAdmin,
    });
    expect(master.getJettonData().adminAddress).toEqual(before.adminAddress);
}

get fun `test jetton v2 master mint deploys owner shard wallet`() {
    val admin = testing.treasury("jetton-2-master-mint-admin");
    val owner = testing.treasury("jetton-2-master-mint-owner");
    val master = deployLocalJetton2Master(admin.address);
    val expectedWallet = localJetton2WalletInitial(master, owner.address);
    val wallet = mintToLocalJetton2Wallet(master, admin.address, owner.address, 21, 1000);
    val walletStorage = loadLocalJetton2WalletStorage(wallet);
    val walletData = wallet.getWalletData();
    val masterData = master.getJettonData();

    expect(wallet.address).toEqual(expectedWallet.address);
    expect(master.getWalletAddress(owner.address)).toEqual(expectedWallet.address);
    expect(masterData.totalSupply).toEqual(1000);
    expect(walletData.balance).toEqual(1000);
    expect(walletData.ownerAddress).toEqual(owner.address);
    expect(walletData.jettonMasterAddress).toEqual(master.address);
    expect(walletData.jettonWalletCode.hash()).toEqual(build("Jetton2Wallet").hash());
    expect(walletStorage.balance).toEqual(1000);
    expect(walletStorage.ownerAddress).toEqual(owner.address);
    expect(walletStorage.jettonMasterAddress).toEqual(master.address);

    println("JETTON_2_MASTER_MINTED_WALLET_ADDRESS={}", wallet.address);
    println("JETTON_2_MASTER_AFTER_MINT_DATA={}", masterData);
    println("JETTON_2_WALLET_AFTER_MINT_STORAGE={}", walletStorage);
    println("JETTON_2_WALLET_AFTER_MINT_DATA={}", walletData);
}
