import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./wallet_test_utils"
import "../types/jetton_v1_wallet.types"
import "../wrappers/JettonV1Wallet.gen"

get fun `test jetton v1 wallet mainnet getters and storage`() {
    val wallet = mainnetJettonV1Wallet();
    val storage = loadJettonV1WalletStorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    println("JETTON_V1_WALLET_ADDRESS={}", wallet.address);
    println("JETTON_V1_WALLET_STORAGE={}", storage);
    println("JETTON_V1_WALLET_DATA={}", data);
    println("JETTON_V1_WALLET_MASTER={}", data.jettonMasterAddress);
}

get fun `test jetton v1 wallet rejects unauthorized transfer`() {
    val wallet = mainnetJettonV1Wallet();
    val sender = testing.treasury("jetton-v1-wallet-unauthorized-transfer");
    val before = wallet.getWalletData();

    val txs = wallet.sendJettonTransfer(
        sender.address,
        1,
        1,
        sender.address,
        sender.address,
        null,
        0,
        emptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<JettonTransfer>({
        from: sender.address,
        to: wallet.address,
        exitCode: JettonV1WalletErrors.UnauthorizedOwner,
    });
    expect(wallet.getWalletData().balance).toEqual(before.balance);
}
