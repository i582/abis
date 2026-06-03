import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/stablecoin_master.types"
import "../types/stablecoin_wallet.types"
import "../wrappers/StablecoinMaster.gen"
import "../wrappers/StablecoinWallet.gen"
import "./master_test_utils"
import "./wallet_test_utils"

get fun `test stablecoin wallet public getters work on mainnet`() {
    val master = mainnetStablecoinMaster();
    val wallet = mainnetStablecoinWallet();
    val data = wallet.getWalletData();
    val status = wallet.getStatus();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.jettonMasterAddress).toEqual(master.address);
    expect(data.ownerAddress).toEqual(mainnetStablecoinOwner());
    expect(data.jettonWalletCode.hash()).toEqual(master.getJettonData().jettonWalletCode.hash());
    expect(status).toEqual(loadStablecoinWalletStorageFromFork(wallet).status);

    println("STABLECOIN_WALLET_GET_WALLET_DATA={}", data);
    println("STABLECOIN_WALLET_GET_STATUS={}", status);
}

get fun `test stablecoin wallet mainnet getters and storage`() {
    val wallet = mainnetStablecoinWallet();
    val storage = loadStablecoinWalletStorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(wallet.getStatus()).toEqual(storage.status);

    println("STABLECOIN_WALLET_ADDRESS={}", wallet.address);
    println("STABLECOIN_WALLET_STORAGE={}", storage);
    println("STABLECOIN_WALLET_DATA={}", data);
}

get fun `test stablecoin wallet accepts top up`() {
    val wallet = mainnetStablecoinWallet();
    val sender = testing.treasury("stablecoin-wallet-top-up");
    val before = wallet.getWalletData();

    val txs = wallet.sendStablecoinWalletTopUp(
        sender.address,
        31,
        { value: ton("0.01"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<StablecoinWalletTopUp>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.getWalletData().balance).toEqual(before.balance);
}

get fun `test stablecoin wallet rejects unauthorized transfer and status update`() {
    val wallet = mainnetStablecoinWallet();
    val sender = testing.treasury("stablecoin-wallet-unauthorized");
    val before = wallet.getWalletData();

    val transferTxs = wallet.sendStablecoinWalletTransfer(
        sender.address,
        41,
        1,
        sender.address,
        sender.address,
        null,
        0,
        emptyStablecoinForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );
    expect(transferTxs).toHaveFailedTx<StablecoinWalletTransfer>({
        from: sender.address,
        to: wallet.address,
        exitCode: StablecoinWalletErrors.UnauthorizedOwnerOrMaster,
    });

    val statusTxs = wallet.sendStablecoinWalletSetStatus(
        sender.address,
        42,
        1,
        { value: ton("0.05"), bounce: false },
    );
    expect(statusTxs).toHaveFailedTx<StablecoinWalletSetStatus>({
        from: sender.address,
        to: wallet.address,
        exitCode: StablecoinWalletErrors.InvalidSender,
    });

    expect(wallet.getWalletData().balance).toEqual(before.balance);
}
