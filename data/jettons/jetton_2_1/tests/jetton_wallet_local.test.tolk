import "@acton/io"
import "@acton/build"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_wallet.types"
import "../wrappers/JettonWallet.gen"

fun emptyJetton21WalletPayload(): PayloadInline {
    return PayloadInline { value: beginCell().endCell().beginParse() };
}

fun deployJetton21Wallet(owner: address, minter: address, balance: coins): JettonWallet {
    val wallet = JettonWallet.fromStorage({
        jettonBalance: balance,
        ownerAddress: owner,
        minterAddress: minter,
    });
    if (wallet.stateInit == null) {
        Assert.fail("JettonWallet wrapper has no state init");
    }

    val txs = net.send(
        owner,
        createMessage({
            bounce: false,
            value: ton("1"),
            dest: { stateInit: wallet.stateInit! },
            body: TopUpTons {},
        }),
    );
    expect(txs).toHaveSuccessfulDeploy<TopUpTons>({
        from: owner,
        to: wallet.address,
        exitCode: 0,
    });
    return wallet;
}

fun loadJetton21WalletStorage(wallet: JettonWallet): WalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("JettonWallet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("JettonWallet account is frozen");
        }
    }
}

get fun `test jetton 2.1 wallet local getter storage and minter credit`() {
    val owner = testing.treasury("jetton-2-1-wallet-owner");
    val minter = testing.treasury("jetton-2-1-wallet-minter");
    val wallet = deployJetton21Wallet(owner.address, minter.address, 0);
    val before = wallet.getWalletData();

    expect(before.jettonBalance).toEqual(0);
    expect(before.ownerAddress).toEqual(owner.address);
    expect(before.minterAddress).toEqual(minter.address);
    expect(before.jettonWalletCode.hash()).toEqual(build("JettonWallet").hash());

    val creditTxs = wallet.sendInternalTransferStep(
        minter.address,
        31,
        500,
        null,
        null,
        0,
        emptyJetton21WalletPayload(),
        { value: ton("0.3"), bounce: false },
    );
    expect(creditTxs).toHaveSuccessfulTx<InternalTransferStep>({
        from: minter.address,
        to: wallet.address,
        exitCode: 0,
    });

    val storage = loadJetton21WalletStorage(wallet);
    val after = wallet.getWalletData();
    expect(storage.jettonBalance).toEqual(500);
    expect(after.jettonBalance).toEqual(500);
    expect(after.ownerAddress).toEqual(owner.address);
    expect(after.minterAddress).toEqual(minter.address);

    println("JETTON_2_1_WALLET_STORAGE={}", storage);
    println("JETTON_2_1_WALLET_DATA={}", after);
}

get fun `test jetton 2.1 wallet rejects unauthorized transfer and unknown opcode`() {
    val owner = testing.treasury("jetton-2-1-wallet-reject-owner");
    val minter = testing.treasury("jetton-2-1-wallet-reject-minter");
    val attacker = testing.treasury("jetton-2-1-wallet-reject-attacker");
    val wallet = deployJetton21Wallet(owner.address, minter.address, 10);

    val transferTxs = wallet.sendAskToTransfer(
        attacker.address,
        41,
        1,
        attacker.address,
        null,
        null,
        0,
        emptyJetton21WalletPayload(),
        { value: ton("0.3"), bounce: false },
    );
    expect(transferTxs).toHaveFailedTx<AskToTransfer>({
        from: attacker.address,
        to: wallet.address,
        exitCode: JettonWalletErrors.NotOwner,
    });

    val unknownBody = beginCell().storeUint(0x12345678, 32).storeUint(42, 64).endCell();
    val unknownTxs = wallet.sendAny(
        attacker.address,
        unknownBody,
        { value: ton("0.05"), bounce: false },
    );
    expect(unknownTxs).toHaveFailedTx({
        from: attacker.address,
        to: wallet.address,
        exitCode: 0xFFFF,
    });
    expect(wallet.getWalletData().jettonBalance).toEqual(10);
}
