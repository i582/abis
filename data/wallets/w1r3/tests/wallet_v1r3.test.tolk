import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v1r3.types"
import "../wrappers/WalletV1r3.gen"

const MAINNET_WALLET_V1R3_ADDRESS = "UQAHazzNn-Otdsdwm2Xz7-EYwZcehzkz5P0bRlUBiaZBQGmL"

fun walletV1r3(): WalletV1r3 {
    return WalletV1r3.fromAddress(address(MAINNET_WALLET_V1R3_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyOutgoingMessageTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadWalletV1r3StorageFromFork(wallet: WalletV1r3): WalletV1r3Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV1r3Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V1 R3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V1 R3 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v1r3 mainnet getters through wrapper`() {
    val wallet = walletV1r3();
    val storage = loadWalletV1r3StorageFromFork(wallet);

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(storage.seqno);
    expect(wallet.getPublicKey()).toEqual(storage.publicKey);
}

get fun `test wallet v1r3 mainnet parses persistent storage`() {
    val wallet = walletV1r3();
    val storage = loadWalletV1r3StorageFromFork(wallet);

    println("WALLET_V1R3_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V1R3_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
}

get fun `test wallet v1r3 mainnet accepts plain internal transfer`() {
    val wallet = walletV1r3();
    val sender = testing.treasury("wallet-v1r3-mainnet-plain-transfer");
    val beforeSeqno = wallet.seqno();

    val txs = wallet.sendAny(
        sender.address,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.seqno()).toEqual(beforeSeqno);
}

get fun `test wallet v1r3 mainnet rejects invalid external signed request`() {
    val wallet = walletV1r3();
    testing.topUp(wallet.address, ton("1"));

    val result = wallet.sendExternalWalletV1r3SignedExternal(
        zeroSignature(),
        wallet.seqno(),
        emptyOutgoingMessageTail(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
