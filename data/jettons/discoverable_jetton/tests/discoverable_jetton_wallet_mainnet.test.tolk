import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./wallet_test_utils"
import "../types/discoverable_jetton_wallet.types"
import "../wrappers/DiscoverableJettonWallet.gen"

get fun `test discoverable jetton wallet public getter works on mainnet`() {
    val wallet = mainnetDiscoverableJettonWallet();
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.jettonMasterAddress).toEqual(
        address("EQDOxsDBUkJYfX2musuy4yG-7o6VSMIMdqEsktTjI3HX3vUb"),
    );
    expect(data.ownerAddress).toEqual(address("EQDerEPTIh0O8lBdjWc6aLaJs5HYqlfBN2Ruj1lJQH_6vcaZ"));
    expect(data.jettonWalletCode.hash()).toEqual(
        loadDiscoverableJettonWalletStorageFromFork(wallet).jettonWalletCode.hash(),
    );

    println("DISCOVERABLE_JETTON_WALLET_GET_WALLET_DATA={}", data);
}

get fun `test discoverable jetton wallet mainnet getters and storage`() {
    val wallet = mainnetDiscoverableJettonWallet();
    val storage = loadDiscoverableJettonWalletStorageFromFork(wallet);
    val data = wallet.getWalletData();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(data.balance).toEqual(storage.balance);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.jettonMasterAddress).toEqual(storage.jettonMasterAddress);
    expect(data.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    println("DISCOVERABLE_JETTON_WALLET_ADDRESS={}", wallet.address);
    println("DISCOVERABLE_JETTON_WALLET_STORAGE={}", storage);
    println("DISCOVERABLE_JETTON_WALLET_DATA={}", data);
}

get fun `test discoverable jetton wallet rejects unauthorized transfer`() {
    val wallet = mainnetDiscoverableJettonWallet();
    val sender = testing.treasury("discoverable-jetton-wallet-unauthorized-transfer");
    val before = wallet.getWalletData();

    val txs = wallet.sendJettonTransfer(
        sender.address,
        21,
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
        exitCode: DiscoverableJettonWalletErrors.UnauthorizedOwner,
    });
    expect(wallet.getWalletData().balance).toEqual(before.balance);
}
