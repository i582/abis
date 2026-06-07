import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v1r1.types"
import "../wrappers/WalletV1r1.gen"

const MAINNET_WALLET_V1R1_ADDRESS = "UQAgjHOZV_Mc3LR93Zb5LF4fSD0Gyhppj5xvRK-QZPSxvtB4"

fun walletV1r1(): WalletV1r1 {
    return WalletV1r1.fromAddress(address(MAINNET_WALLET_V1R1_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyOutgoingMessageTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadWalletV1r1StorageFromFork(wallet: WalletV1r1): WalletV1r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV1r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V1 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V1 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v1r1 mainnet account is deployed`() {
    val wallet = walletV1r1();
    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
}

get fun `test wallet v1r1 mainnet parses persistent storage`() {
    val wallet = walletV1r1();
    val storage = loadWalletV1r1StorageFromFork(wallet);

    println("WALLET_V1R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V1R1_STORAGE={}", storage);

    expect(storage.seqno).toBeGreaterOrEqual(0);
    expect(storage.publicKey).toBeGreater(0);
}

get fun `test wallet v1r1 mainnet accepts plain internal transfer`() {
    val wallet = walletV1r1();
    val sender = testing.treasury("wallet-v1r1-mainnet-plain-transfer");
    val beforeStorage = loadWalletV1r1StorageFromFork(wallet);

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
    expect(loadWalletV1r1StorageFromFork(wallet).seqno).toEqual(beforeStorage.seqno);
}

get fun `test wallet v1r1 mainnet rejects invalid external signed request`() {
    val wallet = walletV1r1();
    val storage = loadWalletV1r1StorageFromFork(wallet);
    testing.topUp(wallet.address, ton("1"));

    val result = wallet.sendExternalWalletV1r1SignedExternal(
        zeroSignature(),
        storage.seqno,
        emptyOutgoingMessageTail(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
