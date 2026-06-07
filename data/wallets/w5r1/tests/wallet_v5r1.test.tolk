import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v5r1.types"
import "../wrappers/WalletV5r1.gen"

const MAINNET_WALLET_V5R1_ADDRESS = "UQBuPuy0bnowA2cukDKw__YVX04CsUpXprpzM39CgFPTmePf"

fun walletV5r1(): WalletV5r1 {
    return WalletV5r1.fromAddress(address(MAINNET_WALLET_V5R1_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun loadWalletV5r1StorageFromFork(wallet: WalletV5r1): WalletV5r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV5r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V5 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V5 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v5r1 mainnet getters through wrapper`() {
    val wallet = walletV5r1();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val seqno = wallet.seqno();
    val publicKey = wallet.getPublicKey();
    val subwalletId = wallet.getSubwalletId();
    val extensions = wallet.getExtensions();

    expect(seqno).toBeGreaterOrEqual(0);
    expect(publicKey).toBeGreater(0);
    expect(subwalletId).toBeGreaterOrEqual(0);
    expect(extensions).toHaveLength(0);
    expect(wallet.isSignatureAllowed()).toBeTrue();
}

get fun `test wallet v5r1 mainnet parses persistent storage`() {
    val wallet = walletV5r1();
    val storage = loadWalletV5r1StorageFromFork(wallet);

    println("WALLET_V5R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V5R1_STORAGE={}", storage);
    println("WALLET_V5R1_STORAGE_EXTENSIONS={}", storage.extensions);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(wallet.getSubwalletId());
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
    expect(storage.extensions).toEqual(wallet.getExtensions());
    expect(storage.isSignatureAllowed).toEqual(wallet.isSignatureAllowed());
}

get fun `test wallet v5r1 mainnet accepts plain internal transfer`() {
    val wallet = walletV5r1();
    val sender = testing.treasury("wallet-v5r1-mainnet-plain-transfer");

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
}

get fun `test wallet v5r1 mainnet ignores invalid internal signed request`() {
    val wallet = walletV5r1();
    val sender = testing.treasury("wallet-v5r1-mainnet-invalid-internal");
    val beforeSeqno = wallet.seqno();

    val txs = wallet.sendWalletSignedInternalV5r1(
        sender.address,
        wallet.getSubwalletId() as uint32,
        (blockchain.now() + 1000) as uint32,
        beforeSeqno as uint32,
        null,
        null,
        zeroSignature(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<WalletSignedInternalV5r1>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.seqno()).toEqual(beforeSeqno);
}

get fun `test wallet v5r1 mainnet rejects invalid external signed request`() {
    val wallet = walletV5r1();

    val result = wallet.sendExternalWalletSignedExternalV5r1(
        wallet.getSubwalletId() as uint32,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno() as uint32,
        null,
        null,
        zeroSignature(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
