import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v1r2.types"
import "../wrappers/WalletV1r2.gen"

const MAINNET_WALLET_V1R2_ADDRESS = "Uf8nRyI3zRwrD4dnmA_ufSVXTAE9xNUnDXDjaiBzYgllWejm"

fun walletV1r2(): WalletV1r2 {
    return WalletV1r2.fromAddress(address(MAINNET_WALLET_V1R2_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyOutgoingMessageTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadWalletV1r2StorageFromFork(wallet: WalletV1r2): WalletV1r2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV1r2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V1 R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V1 R2 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v1r2 mainnet getters through wrapper`() {
    val wallet = walletV1r2();
    val storage = loadWalletV1r2StorageFromFork(wallet);

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(storage.seqno);
}

get fun `test wallet v1r2 mainnet parses persistent storage`() {
    val wallet = walletV1r2();
    val storage = loadWalletV1r2StorageFromFork(wallet);

    println("WALLET_V1R2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V1R2_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.publicKey).toBeGreater(0);
}

get fun `test wallet v1r2 mainnet rejects invalid external signed request`() {
    val wallet = walletV1r2();

    val result = wallet.sendExternalWalletV1r2SignedExternal(
        zeroSignature(),
        wallet.seqno(),
        emptyOutgoingMessageTail(),
    );

    expect(result).toBeNotAccepted();
}
