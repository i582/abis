import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/mintless_master.types"
import "../wrappers/MintlessJettonMaster.gen"
import "./master_test_utils"
import "./wallet_test_utils"

get fun `test mintless master public getters work on mainnet`() {
    val master = mainnetMintlessMaster();
    val owner = mainnetMintlessOwner();
    val storage = loadMintlessMasterStorageFromFork(master);
    val walletStorage = loadMintlessWalletStorageFromFork(mainnetMintlessWallet());
    val data = master.getJettonData();
    val nextAdminAddress = master.getNextAdminAddress();
    val walletAddress = master.getWalletAddress(owner);
    val stateInitAndSalt = master.getWalletStateInitAndSalt(owner);
    val merkleRoot = master.getMintlessAirdropHashmapRoot();

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.mintable).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(merkleRoot).toEqual(storage.merkleRoot);
    expect(walletAddress).toEqual(mainnetMintlessWalletAddress());
    expect(walletStorage.merkleRoot).toEqual(storage.merkleRoot);
    expect(stateInitAndSalt.salt).toEqual(walletStorage.salt as int);

    if (storage.adminAddress == null) {
        expect(data.adminAddress).toBeNoneAddress();
    } else {
        expect(data.adminAddress.castToInternal()).toEqual(storage.adminAddress!);
    }

    if (storage.nextAdminAddress == null) {
        expect(nextAdminAddress).toBeNoneAddress();
    } else {
        expect(nextAdminAddress.castToInternal()).toEqual(storage.nextAdminAddress!);
    }

    println("MINTLESS_MASTER_GET_JETTON_DATA={}", data);
    println("MINTLESS_MASTER_GET_NEXT_ADMIN_ADDRESS={}", nextAdminAddress);
    println("MINTLESS_MASTER_GET_WALLET_ADDRESS={}", walletAddress);
    println("MINTLESS_MASTER_GET_WALLET_STATE_INIT_AND_SALT={}", stateInitAndSalt);
    println("MINTLESS_MASTER_GET_AIRDROP_ROOT={}", merkleRoot);
}

get fun `test mintless master mainnet storage and salted wallet derivation`() {
    val master = mainnetMintlessMaster();
    val owner = mainnetMintlessOwner();
    val storage = loadMintlessMasterStorageFromFork(master);
    val walletStorage = loadMintlessWalletStorageFromFork(mainnetMintlessWallet());
    val data = master.getJettonData();
    val stateInitAndSalt = master.getWalletStateInitAndSalt(owner);

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(master.getMintlessAirdropHashmapRoot()).toEqual(storage.merkleRoot);
    expect(master.getWalletAddress(owner)).toEqual(mainnetMintlessWalletAddress());
    expect(stateInitAndSalt.salt).toEqual(walletStorage.salt as int);

    println("MINTLESS_MASTER_ADDRESS={}", master.address);
    println("MINTLESS_MASTER_STORAGE={}", storage);
    println("MINTLESS_MASTER_DATA={}", data);
    println("MINTLESS_MASTER_OWNER={}", owner);
    println("MINTLESS_MASTER_EXPECTED_WALLET={}", mainnetMintlessWalletAddress());
    println("MINTLESS_MASTER_WALLET_STORAGE={}", walletStorage);
}

get fun `test mintless master accepts provide wallet address and top up`() {
    val master = mainnetMintlessMaster();
    val sender = testing.treasury("mintless-master-provide-wallet-address");
    val owner = mainnetMintlessOwner();

    val provideTxs = master.sendMintlessJettonMasterProvideWalletAddress(
        sender.address,
        11,
        owner,
        true,
        { value: ton("0.05"), bounce: false },
    );
    expect(provideTxs).toHaveSuccessfulTx<MintlessJettonMasterProvideWalletAddress>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });

    val topUpTxs = master.sendMintlessJettonMasterTopUp(
        sender.address,
        12,
        { value: ton("0.01"), bounce: false },
    );
    expect(topUpTxs).toHaveSuccessfulTx<MintlessJettonMasterTopUp>({
        from: sender.address,
        to: master.address,
        exitCode: 0,
    });
}

get fun `test mintless master rejects unauthorized admin messages`() {
    val master = mainnetMintlessMaster();
    val sender = testing.treasury("mintless-master-unauthorized-admin");
    val before = master.getJettonData();

    val changeAdminTxs = master.sendMintlessJettonMasterChangeAdmin(
        sender.address,
        21,
        sender.address,
        { value: ton("0.05"), bounce: false },
    );
    expect(changeAdminTxs).toHaveFailedTx<MintlessJettonMasterChangeAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: MintlessJettonMasterErrors.UnauthorizedAdmin,
    });

    val dropAdminTxs = master.sendMintlessJettonMasterDropAdmin(
        sender.address,
        22,
        { value: ton("0.05"), bounce: false },
    );
    expect(dropAdminTxs).toHaveFailedTx<MintlessJettonMasterDropAdmin>({
        from: sender.address,
        to: master.address,
        exitCode: MintlessJettonMasterErrors.UnauthorizedAdmin,
    });

    val changeMetadataTxs = master.sendMintlessJettonMasterChangeMetadataUri(
        sender.address,
        23,
        emptyMintlessMetadataTail(),
        { value: ton("0.05"), bounce: false },
    );
    expect(changeMetadataTxs).toHaveFailedTx<MintlessJettonMasterChangeMetadataUri>({
        from: sender.address,
        to: master.address,
        exitCode: MintlessJettonMasterErrors.UnauthorizedAdmin,
    });

    expect(master.getJettonData().totalSupply).toEqual(before.totalSupply);
}
