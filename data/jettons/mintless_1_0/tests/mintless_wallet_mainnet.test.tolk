import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/mintless_master.types"
import "../types/mintless_wallet.types"
import "../wrappers/MintlessJettonMaster.gen"
import "../wrappers/MintlessJettonWallet.gen"
import "./master_test_utils"
import "./wallet_test_utils"

get fun `test mintless wallet public getters work on mainnet`() {
    val master = mainnetMintlessMaster();
    val wallet = mainnetMintlessWallet();
    val data = wallet.getWalletData();
    val status = wallet.getStatus();
    val claimed = wallet.isClaimed();
    val storage = loadMintlessWalletStorageFromFork(wallet);
    val stateInitAndSalt = master.getWalletStateInitAndSalt(mainnetMintlessOwner());

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.jettonMasterAddress).toEqual(master.address);
    expect(data.ownerAddress).toEqual(mainnetMintlessOwner());
    expect(data.jettonWalletCode.hash()).toEqual(master.getJettonData().jettonWalletCode.hash());
    expect(status).toEqual(storage.status);
    expect(claimed).toEqual(storage.status != 0);
    expect(storage.merkleRoot).toEqual(master.getMintlessAirdropHashmapRoot());
    expect(stateInitAndSalt.salt).toEqual(storage.salt as int);

    println("MINTLESS_WALLET_GET_WALLET_DATA={}", data);
    println("MINTLESS_WALLET_GET_STATUS={}", status);
    println("MINTLESS_WALLET_IS_CLAIMED={}", claimed);
    println("MINTLESS_WALLET_STATE_INIT_AND_SALT={}", stateInitAndSalt);
}

get fun `test mintless wallet mainnet getters and storage`() {
    val master = mainnetMintlessMaster();
    val wallet = mainnetMintlessWallet();
    val storage = loadMintlessWalletStorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(wallet.getStatus()).toEqual(storage.status);
    expect(wallet.isClaimed()).toEqual(storage.status != 0);
    expect(storage.merkleRoot).toEqual(master.getMintlessAirdropHashmapRoot());

    println("MINTLESS_WALLET_ADDRESS={}", wallet.address);
    println("MINTLESS_WALLET_STORAGE={}", storage);
    println("MINTLESS_WALLET_DATA={}", data);
}

get fun `test mintless wallet accepts top up`() {
    val wallet = mainnetMintlessWallet();
    val sender = testing.treasury("mintless-wallet-top-up");
    val before = wallet.getWalletData();

    val txs = wallet.sendMintlessJettonWalletTopUp(
        sender.address,
        31,
        { value: ton("0.01"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<MintlessJettonWalletTopUp>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.getWalletData().balance).toEqual(before.balance);
}

get fun `test mintless wallet rejects unauthorized owner transfer and burn`() {
    val wallet = mainnetMintlessWallet();
    val sender = testing.treasury("mintless-wallet-unauthorized");
    val before = wallet.getWalletData();

    val transferTxs = wallet.sendMintlessJettonWalletTransfer(
        sender.address,
        41,
        1,
        sender.address,
        sender.address,
        null,
        0,
        emptyMintlessForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );
    expect(transferTxs).toHaveFailedTx<MintlessJettonWalletTransfer>({
        from: sender.address,
        to: wallet.address,
        exitCode: MintlessJettonWalletErrors.UnauthorizedOwner,
    });

    val burnTxs = wallet.sendMintlessJettonWalletBurn(
        sender.address,
        42,
        1,
        sender.address,
        null,
        { value: ton("0.05"), bounce: false },
    );
    expect(burnTxs).toHaveFailedTx<MintlessJettonWalletBurn>({
        from: sender.address,
        to: wallet.address,
        exitCode: MintlessJettonWalletErrors.UnauthorizedOwner,
    });

    expect(wallet.getWalletData().balance).toEqual(before.balance);
}

get fun `test mintless wallet rejects unknown opcode`() {
    val wallet = mainnetMintlessWallet();
    val sender = testing.treasury("mintless-wallet-unknown-op");

    val txs = wallet.sendAny(
        sender.address,
        unknownMintlessWalletBody(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx({
        from: sender.address,
        to: wallet.address,
        exitCode: MintlessJettonWalletErrors.UnsupportedOperation,
    });
}
