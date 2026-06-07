import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/jetton_2_master.types"
import "../types/jetton_2_wallet.types"
import "../wrappers/Jetton2Master.gen"
import "../wrappers/Jetton2Wallet.gen"

get fun `test jetton v2 wallet transfer and burn update balances`() {
    val admin = testing.treasury("jetton-2-wallet-flow-admin");
    val owner = testing.treasury("jetton-2-wallet-flow-owner");
    val recipient = testing.treasury("jetton-2-wallet-flow-recipient");
    val master = deployLocalJetton2Master(admin.address);
    val ownerWallet = mintToLocalJetton2Wallet(master, admin.address, owner.address, 31, 1000);
    val recipientWalletAddress = localJetton2WalletInitial(master, recipient.address).address;

    val transferTxs = ownerWallet.sendJetton2WalletTransfer(
        owner.address,
        32,
        125,
        recipient.address,
        null,
        null,
        0,
        jetton2InlineEmptyForwardPayload(),
        { value: ton("0.5"), bounce: false },
    );
    expect(transferTxs).toHaveSuccessfulTx<Jetton2WalletTransfer>({
        from: owner.address,
        to: ownerWallet.address,
        exitCode: 0,
    });
    expect(transferTxs).toHaveSuccessfulDeploy<Jetton2WalletInternalTransfer>({
        from: ownerWallet.address,
        to: recipientWalletAddress,
        exitCode: 0,
    });

    val recipientWallet = Jetton2Wallet.fromAddress(recipientWalletAddress);
    expect(loadLocalJetton2WalletStorage(ownerWallet).balance).toEqual(875);
    expect(loadLocalJetton2WalletStorage(recipientWallet).balance).toEqual(125);

    val burnTxs = ownerWallet.sendJetton2WalletBurn(
        owner.address,
        33,
        200,
        admin.address,
        null,
        { value: ton("0.3"), bounce: false },
    );
    expect(burnTxs).toHaveSuccessfulTx<Jetton2WalletBurn>({
        from: owner.address,
        to: ownerWallet.address,
        exitCode: 0,
    });
    expect(burnTxs).toHaveSuccessfulTx<Jetton2MasterBurnNotification>({
        from: ownerWallet.address,
        to: master.address,
        exitCode: 0,
    });

    expect(ownerWallet.getWalletData().balance).toEqual(675);
    expect(recipientWallet.getWalletData().balance).toEqual(125);
    expect(master.getJettonData().totalSupply).toEqual(800);

    println("JETTON_2_WALLET_OWNER_AFTER_FLOW={}", ownerWallet.getWalletData());
    println("JETTON_2_WALLET_RECIPIENT_AFTER_FLOW={}", recipientWallet.getWalletData());
    println("JETTON_2_MASTER_AFTER_BURN={}", master.getJettonData());
}

get fun `test jetton v2 wallet top up and rejected messages`() {
    val admin = testing.treasury("jetton-2-wallet-reject-admin");
    val owner = testing.treasury("jetton-2-wallet-reject-owner");
    val attacker = testing.treasury("jetton-2-wallet-reject-attacker");
    val master = deployLocalJetton2Master(admin.address);
    val wallet = mintToLocalJetton2Wallet(master, admin.address, owner.address, 41, 10);

    val topUpTxs = wallet.sendJetton2WalletTopUp(
        attacker.address,
        42,
        { value: ton("0.01"), bounce: false },
    );
    expect(topUpTxs).toHaveSuccessfulTx<Jetton2WalletTopUp>({
        from: attacker.address,
        to: wallet.address,
        exitCode: 0,
    });

    val unauthorizedTransferTxs = wallet.sendJetton2WalletTransfer(
        attacker.address,
        43,
        1,
        attacker.address,
        null,
        null,
        0,
        jetton2InlineEmptyForwardPayload(),
        { value: ton("0.2"), bounce: false },
    );
    expect(unauthorizedTransferTxs).toHaveFailedTx<Jetton2WalletTransfer>({
        from: attacker.address,
        to: wallet.address,
        exitCode: Jetton2WalletErrors.UnauthorizedOwner,
    });

    val unknownBody = beginCell().storeUint(0x12345678, 32).storeUint(44, 64).endCell();
    val unknownTxs = wallet.sendAny(
        attacker.address,
        unknownBody,
        { value: ton("0.01"), bounce: false },
    );
    expect(unknownTxs).toHaveFailedTx({
        from: attacker.address,
        to: wallet.address,
        exitCode: Jetton2WalletErrors.UnsupportedOperation,
    });

    expect(wallet.getWalletData().balance).toEqual(10);
    println("JETTON_2_WALLET_REJECT_STORAGE={}", loadLocalJetton2WalletStorage(wallet));
}
