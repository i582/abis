import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_preprocessed_v2.types"
import "../wrappers/WalletPreprocessedV2.gen"

const MAINNET_WALLET_PREPROCESSED_V2_ADDRESS = "EQAMRL88dnltkH0DNpkt5MsPBYuQ_yagvC75uV5c0poWVMzZ"

fun walletPreprocessedV2(): WalletPreprocessedV2 {
    return WalletPreprocessedV2.fromAddress(address(MAINNET_WALLET_PREPROCESSED_V2_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 256)
        .endCell()
        .beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyOutList(): cell {
    return createEmptyCell();
}

fun invalidSeqNo(seqNo: uint16): uint16 {
    return (seqNo == 65535) ? (0 as uint16) : (((seqNo as int) + 1) as uint16);
}

fun loadWalletPreprocessedV2StorageFromFork(wallet: WalletPreprocessedV2): WalletPreprocessedV2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletPreprocessedV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Preprocessed Wallet V2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Preprocessed Wallet V2 mainnet fixture account is frozen");
        }
    }
}

get fun `test preprocessed wallet v2 mainnet account is deployed`() {
    val wallet = walletPreprocessedV2();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
}

get fun `test preprocessed wallet v2 mainnet parses persistent storage`() {
    val wallet = walletPreprocessedV2();
    val storage = loadWalletPreprocessedV2StorageFromFork(wallet);

    println("WALLET_PREPROCESSED_V2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_PREPROCESSED_V2_STORAGE={}", storage);

    expect(storage.publicKey).toBeGreater(0);
    expect(storage.seqNo).toBeGreaterOrEqual(0);
}

get fun `test preprocessed wallet v2 mainnet accepts plain internal transfer without changing storage`() {
    val wallet = walletPreprocessedV2();
    val sender = testing.treasury("wallet-preprocessed-v2-mainnet-plain-transfer");
    val before = loadWalletPreprocessedV2StorageFromFork(wallet);

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

    val after = loadWalletPreprocessedV2StorageFromFork(wallet);
    expect(after.publicKey).toEqual(before.publicKey);
    expect(after.seqNo).toEqual(before.seqNo);
}

get fun `test preprocessed wallet v2 mainnet rejects invalid external seqno`() {
    val wallet = walletPreprocessedV2();
    val storage = loadWalletPreprocessedV2StorageFromFork(wallet);

    val result = wallet.sendExternalPreprocessedWalletSignedV2(
        zeroSignature(),
        {
            validUntil: (blockchain.now() + 1000) as uint64,
            seqNo: invalidSeqNo(storage.seqNo),
            actions: emptyOutList(),
        },
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSeqno);
}

get fun `test preprocessed wallet v2 mainnet rejects expired external request`() {
    val wallet = walletPreprocessedV2();
    val storage = loadWalletPreprocessedV2StorageFromFork(wallet);

    val result = wallet.sendExternalPreprocessedWalletSignedV2(
        zeroSignature(),
        {
            validUntil: 0,
            seqNo: storage.seqNo,
            actions: emptyOutList(),
        },
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.Expired);
}

get fun `test preprocessed wallet v2 mainnet rejects invalid external signature`() {
    val wallet = walletPreprocessedV2();
    val storage = loadWalletPreprocessedV2StorageFromFork(wallet);

    val result = wallet.sendExternalPreprocessedWalletSignedV2(
        zeroSignature(),
        {
            validUntil: (blockchain.now() + 1000) as uint64,
            seqNo: storage.seqNo,
            actions: emptyOutList(),
        },
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
