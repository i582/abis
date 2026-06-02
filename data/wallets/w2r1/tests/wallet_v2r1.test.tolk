import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v2r1.types"
import "../wrappers/WalletV2r1.gen"

const MAINNET_WALLET_V2R1_ADDRESS = "UQDzNVf3GGi8vgwoKPQFTYxVoHMaZHTxiV1wmKX8QEN93sZo"
const MAINNET_WALLET_V2R1_SEQNO = 8627

fun walletV2r1(): WalletV2r1 {
    return WalletV2r1.fromAddress(address(MAINNET_WALLET_V2R1_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 256)
        .endCell()
        .beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyMessageStream(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadWalletV2r1StorageFromFork(wallet: WalletV2r1): WalletV2r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV2r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V2 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V2 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v2r1 mainnet getters through wrapper`() {
    val wallet = walletV2r1();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(MAINNET_WALLET_V2R1_SEQNO);
}

get fun `test wallet v2r1 mainnet parses persistent storage`() {
    val wallet = walletV2r1();
    val storage = loadWalletV2r1StorageFromFork(wallet);

    println("WALLET_V2R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V2R1_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.publicKey).toBeGreater(0);
}

get fun `test wallet v2r1 mainnet accepts plain internal transfer`() {
    val wallet = walletV2r1();
    val sender = testing.treasury("wallet-v2r1-mainnet-plain-transfer");
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

get fun `test wallet v2r1 mainnet rejects invalid external signed request`() {
    val wallet = walletV2r1();
    testing.topUp(wallet.address, ton("1"));

    val result = wallet.sendExternalWalletV2r1SignedExternal(
        zeroSignature(),
        wallet.seqno(),
        (blockchain.now() + 1000) as uint32,
        emptyMessageStream(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
