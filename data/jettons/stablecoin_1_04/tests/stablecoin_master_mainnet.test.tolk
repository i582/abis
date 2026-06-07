import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./master_test_utils"
import "../types/stablecoin_master.types"
import "../wrappers/StablecoinMaster.gen"

get fun `test stablecoin master public getters work on mainnet`() {
    val master = mainnetStablecoinMaster();
    val owner = mainnetStablecoinOwner();
    val data = master.getJettonData();
    val nextAdminAddress = master.getNextAdminAddress();
    val walletAddress = master.getWalletAddress(owner);

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.mintable).toBeTrue();
    expect(data.jettonWalletCode.hash()).toEqual(
        loadStablecoinMasterStorageFromFork(master).jettonWalletCode.hash(),
    );
    expect(loadStablecoinMasterStorageFromFork(master).nextAdminAddress).toBeNull();
    expect(nextAdminAddress).toBeNoneAddress();
    expect(walletAddress).toEqual(mainnetStablecoinWalletAddress());

    println("STABLECOIN_MASTER_GET_JETTON_DATA={}", data);
    println("STABLECOIN_MASTER_GET_NEXT_ADMIN_ADDRESS={}", nextAdminAddress);
    println("STABLECOIN_MASTER_GET_WALLET_ADDRESS={}", walletAddress);
}

get fun `test stablecoin master mainnet getters storage and wallet derivation`() {
    val master = mainnetStablecoinMaster();
    val storage = loadStablecoinMasterStorageFromFork(master);
    val data = master.getJettonData();
    val owner = mainnetStablecoinOwner();
    val expectedWallet = mainnetStablecoinWalletAddress();

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.mintable).toBeTrue();
    expect(data.adminAddress).toEqual(storage.adminAddress);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(storage.nextAdminAddress).toBeNull();
    expect(master.getNextAdminAddress()).toBeNoneAddress();
    expect(master.getWalletAddress(owner)).toEqual(expectedWallet);

    println("STABLECOIN_MASTER_ADDRESS={}", master.address);
    println("STABLECOIN_MASTER_STORAGE={}", storage);
    println("STABLECOIN_MASTER_DATA={}", data);
    println("STABLECOIN_MASTER_OWNER={}", owner);
    println("STABLECOIN_MASTER_EXPECTED_WALLET={}", expectedWallet);
}

get fun `test stablecoin master accepts provide wallet address and top up`() {
    val master = mainnetStablecoinMaster();
    val sender = testing.treasury("stablecoin-master-provide-wallet-address");
    val owner = mainnetStablecoinOwner();

    val provideTxs = master.sendStablecoinMasterProvideWalletAddress(
        sender.address,
        11,
        owner,
        true,
        { value: ton("0.05"), bounce: false },
    );
    expect(provideTxs).toHaveSuccessfulTx<StablecoinMasterProvideWalletAddress>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });

    val topUpTxs = master.sendStablecoinMasterTopUp(
        sender.address,
        12,
        { value: ton("0.01"), bounce: false },
    );
    expect(topUpTxs).toHaveSuccessfulTx<StablecoinMasterTopUp>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });
}

get fun `test stablecoin master rejects unauthorized admin messages`() {
    val master = mainnetStablecoinMaster();
    val sender = testing.treasury("stablecoin-master-unauthorized-admin");
    val before = master.getJettonData();

    val changeAdminTxs = master.sendStablecoinMasterChangeAdmin(
        sender.address,
        21,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );
    expect(changeAdminTxs).toHaveFailedTx<StablecoinMasterChangeAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: StablecoinMasterErrors.UnauthorizedAdmin,
    });

    val changeMetadataTxs = master.sendStablecoinMasterChangeMetadataUri(
        sender.address,
        22,
        emptyStablecoinMetadataTail(),
        { value: ton("0.05"), bounce: false },
    );
    expect(changeMetadataTxs).toHaveFailedTx<StablecoinMasterChangeMetadataUri>({
        from: sender.address,
        to: master.address,
        exitCode: StablecoinMasterErrors.UnauthorizedAdmin,
    });

    expect(master.getJettonData().adminAddress).toEqual(before.adminAddress);
}
