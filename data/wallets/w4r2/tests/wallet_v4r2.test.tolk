import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "@stdlib/lisp-lists"
import "../types/wallet_v4r2.types"
import "../wrappers/WalletV4r2.gen"

const MAINNET_WALLET_V4R2_ADDRESS = "UQAtPMPoGXJzm6zvqeRcK6IzgJa8RpISp0xpMPgOgj5ggKaV"
const MAINNET_WALLET_V4R2_SEQNO = 40
const MAINNET_WALLET_V4R2_SUBWALLET_ID = 698983191

fun walletV4r2(): WalletV4r2 {
    return WalletV4r2.fromAddress(address(MAINNET_WALLET_V4R2_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 256)
        .endCell()
        .beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptySimpleSendPayload(): WalletV4r2Payload {
    return WalletV4r2SimpleSend {
        messages: createEmptyCell().beginParse(),
    };
}

fun loadWalletV4r2StorageFromFork(wallet: WalletV4r2): WalletV4r2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV4r2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V4 R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V4 R2 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v4r2 mainnet getters through wrapper`() {
    val wallet = walletV4r2();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val seqno = wallet.seqno();
    val publicKey = wallet.getPublicKey();
    val subwalletId = wallet.getSubwalletId();
    val plugins = wallet.getPluginList();

    println("WALLET_V4R2_PLUGINS={}", plugins);

    expect(seqno).toEqual(MAINNET_WALLET_V4R2_SEQNO);
    expect(publicKey).toBeGreater(0);
    expect(subwalletId).toEqual(MAINNET_WALLET_V4R2_SUBWALLET_ID);
    expect(plugins.calculateSize()).toBeGreaterOrEqual(0);
    if (!plugins.isEmpty()) {
        val plugin = plugins.getHead();
        expect(wallet.isPluginInstalled(plugin.workchain, plugin.address as int)).toBeTrue();
    }
    expect(wallet.isPluginInstalled(0, 0)).toBeFalse();
}

get fun `test wallet v4r2 mainnet parses persistent storage`() {
    val wallet = walletV4r2();
    val storage = loadWalletV4r2StorageFromFork(wallet);

    println("WALLET_V4R2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V4R2_STORAGE={}", storage);
    println("WALLET_V4R2_STORAGE_PLUGINS={}", storage.plugins);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(wallet.getSubwalletId());
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
}

get fun `test wallet v4r2 mainnet accepts plain internal transfer`() {
    val wallet = walletV4r2();
    val sender = testing.treasury("wallet-v4r2-mainnet-plain-transfer");

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

get fun `test wallet v4r2 mainnet ignores plugin destruct from non-plugin`() {
    val wallet = walletV4r2();
    val sender = testing.treasury("wallet-v4r2-mainnet-plugin-destruct");
    val beforeSeqno = wallet.seqno();

    val txs = wallet.sendWalletV4r2PluginDestruct(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<WalletV4r2PluginDestruct>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.seqno()).toEqual(beforeSeqno);
}

get fun `test wallet v4r2 mainnet rejects invalid external signed request`() {
    val wallet = walletV4r2();

    val result = wallet.sendExternalWalletV4r2SignedExternal(
        zeroSignature(),
        wallet.getSubwalletId(),
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptySimpleSendPayload(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
