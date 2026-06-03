import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/jetton_notcoin_master.types"
import "../types/jetton_notcoin_wallet.types"
import "../wrappers/JettonNotcoinMaster.gen"
import "../wrappers/JettonNotcoinWallet.gen"
import "./master_test_utils"
import "./wallet_test_utils"

get fun `test jetton notcoin wallet public getters work on mainnet`() {
    val master = mainnetJettonNotcoinMaster();
    val wallet = mainnetJettonNotcoinWallet();
    val data = wallet.getWalletData();
    val status = wallet.getStatus();
    val storage = loadJettonNotcoinWalletStorageFromFork(wallet);

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.jettonMasterAddress).toEqual(master.address);
    expect(data.ownerAddress).toEqual(mainnetJettonNotcoinOwner());
    expect(data.jettonWalletCode.hash()).toEqual(master.getJettonData().jettonWalletCode.hash());
    expect(status).toEqual(storage.status);
    expect(status).toEqual(0);

    println("JETTON_NOTCOIN_WALLET_GET_WALLET_DATA={}", data);
    println("JETTON_NOTCOIN_WALLET_GET_STATUS={}", status);
}

get fun `test jetton notcoin wallet mainnet getters and storage`() {
    val wallet = mainnetJettonNotcoinWallet();
    val storage = loadJettonNotcoinWalletStorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(wallet.getStatus()).toEqual(storage.status);

    println("JETTON_NOTCOIN_WALLET_ADDRESS={}", wallet.address);
    println("JETTON_NOTCOIN_WALLET_STORAGE={}", storage);
    println("JETTON_NOTCOIN_WALLET_DATA={}", data);
}

get fun `test jetton notcoin wallet accepts top up`() {
    val wallet = mainnetJettonNotcoinWallet();
    val sender = testing.treasury("jetton-notcoin-wallet-top-up");
    val before = wallet.getWalletData();

    val txs = wallet.sendJettonNotcoinWalletTopUp(
        sender.address,
        31,
        { value: ton("0.01"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<JettonNotcoinWalletTopUp>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.getWalletData().balance).toEqual(before.balance);
}

get fun `test jetton notcoin wallet rejects unauthorized owner transfer and burn`() {
    val wallet = mainnetJettonNotcoinWallet();
    val sender = testing.treasury("jetton-notcoin-wallet-unauthorized");
    val before = wallet.getWalletData();

    val transferTxs = wallet.sendJettonNotcoinWalletTransfer(
        sender.address,
        41,
        1,
        sender.address,
        sender.address,
        null,
        0,
        emptyJettonNotcoinForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );
    expect(transferTxs).toHaveFailedTx<JettonNotcoinWalletTransfer>({
        from: sender.address,
        to: wallet.address,
        exitCode: JettonNotcoinWalletErrors.UnauthorizedOwner,
    });

    val burnTxs = wallet.sendJettonNotcoinWalletBurn(
        sender.address,
        42,
        1,
        sender.address,
        null,
        { value: ton("0.05"), bounce: false },
    );
    expect(burnTxs).toHaveFailedTx<JettonNotcoinWalletBurn>({
        from: sender.address,
        to: wallet.address,
        exitCode: JettonNotcoinWalletErrors.UnauthorizedOwner,
    });

    expect(wallet.getWalletData().balance).toEqual(before.balance);
}
