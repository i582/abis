import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./master_test_utils"
import "../types/jetton_notcoin_master.types"
import "../wrappers/JettonNotcoinMaster.gen"

get fun `test jetton notcoin master public getters work on mainnet`() {
    val master = mainnetJettonNotcoinMaster();
    val owner = mainnetJettonNotcoinOwner();
    val storage = loadJettonNotcoinMasterStorageFromFork(master);
    val data = master.getJettonData();
    val nextAdminAddress = master.getNextAdminAddress();
    val walletAddress = master.getWalletAddress(owner);

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.mintable).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(storage.adminAddress).toBeNull();
    expect(storage.nextAdminAddress).toBeNull();
    expect(data.adminAddress).toBeNoneAddress();
    expect(nextAdminAddress).toBeNoneAddress();
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(walletAddress).toEqual(mainnetJettonNotcoinWalletAddress());

    println("JETTON_NOTCOIN_MASTER_GET_JETTON_DATA={}", data);
    println("JETTON_NOTCOIN_MASTER_GET_NEXT_ADMIN_ADDRESS={}", nextAdminAddress);
    println("JETTON_NOTCOIN_MASTER_GET_WALLET_ADDRESS={}", walletAddress);
}

get fun `test jetton notcoin master mainnet storage and dropped admin state`() {
    val master = mainnetJettonNotcoinMaster();
    val storage = loadJettonNotcoinMasterStorageFromFork(master);
    val data = master.getJettonData();

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(storage.adminAddress).toBeNull();
    expect(storage.nextAdminAddress).toBeNull();
    expect(data.adminAddress).toBeNoneAddress();
    expect(master.getNextAdminAddress()).toBeNoneAddress();

    println("JETTON_NOTCOIN_MASTER_ADDRESS={}", master.address);
    println("JETTON_NOTCOIN_MASTER_STORAGE={}", storage);
    println("JETTON_NOTCOIN_MASTER_DATA={}", data);
}

get fun `test jetton notcoin master accepts provide wallet address and top up`() {
    val master = mainnetJettonNotcoinMaster();
    val sender = testing.treasury("jetton-notcoin-master-provide-wallet-address");
    val owner = mainnetJettonNotcoinOwner();

    val provideTxs = master.sendJettonNotcoinMasterProvideWalletAddress(
        sender.address,
        11,
        owner,
        true,
        { value: ton("0.05"), bounce: false },
    );
    expect(provideTxs).toHaveSuccessfulTx<JettonNotcoinMasterProvideWalletAddress>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });

    val topUpTxs = master.sendJettonNotcoinMasterTopUp(
        sender.address,
        12,
        { value: ton("0.01"), bounce: false },
    );
    expect(topUpTxs).toHaveSuccessfulTx<JettonNotcoinMasterTopUp>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });
}

get fun `test jetton notcoin master rejects admin messages after drop admin`() {
    val master = mainnetJettonNotcoinMaster();
    val sender = testing.treasury("jetton-notcoin-master-unauthorized-admin");
    val before = master.getJettonData();

    val changeAdminTxs = master.sendJettonNotcoinMasterChangeAdmin(
        sender.address,
        21,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );
    expect(changeAdminTxs).toHaveFailedTx<JettonNotcoinMasterChangeAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: JettonNotcoinMasterErrors.UnauthorizedAdmin,
    });

    val dropAdminTxs = master.sendJettonNotcoinMasterDropAdmin(
        sender.address,
        22,
        { value: ton("0.05"), bounce: false },
    );
    expect(dropAdminTxs).toHaveFailedTx<JettonNotcoinMasterDropAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: JettonNotcoinMasterErrors.UnauthorizedAdmin,
    });

    val changeMetadataTxs = master.sendJettonNotcoinMasterChangeMetadataUri(
        sender.address,
        23,
        emptyJettonNotcoinMetadataTail(),
        { value: ton("0.05"), bounce: false },
    );
    expect(changeMetadataTxs).toHaveFailedTx<JettonNotcoinMasterChangeMetadataUri>({
        from: sender.address,
        to: master.address,
        exitCode: JettonNotcoinMasterErrors.UnauthorizedAdmin,
    });

    expect(master.getJettonData().adminAddress).toEqual(before.adminAddress);
}
