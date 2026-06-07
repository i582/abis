import "@stdlib/lisp-lists"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v4r1.types"
import "../wrappers/WalletV4r1.gen"

const MAINNET_WALLET_V4R1_ADDRESS = "UQA9Xxv6Ig-SvxM_j_Xde6XTOG3ftJfEYUFFLauvq5wyHMru"
const MAINNET_WALLET_V4R1_SEQNO = 10
const MAINNET_WALLET_V4R1_SUBWALLET_ID = 698983191

fun walletV4r1(): WalletV4r1 {
    return WalletV4r1.fromAddress(address(MAINNET_WALLET_V4R1_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptySimpleSendPayload(): WalletV4r1Payload {
    return WalletV4r1SimpleSend { messages: createEmptyCell().beginParse() };
}

fun loadWalletV4r1StorageFromFork(wallet: WalletV4r1): WalletV4r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV4r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V4 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V4 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v4r1 mainnet getters through wrapper`() {
    val wallet = walletV4r1();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val seqno = wallet.seqno();
    val publicKey = wallet.getPublicKey();
    val subwalletId = wallet.getSubwalletId();
    val plugins = wallet.getPluginList();

    println("WALLET_V4R1_PLUGINS={}", plugins);

    expect(seqno).toEqual(MAINNET_WALLET_V4R1_SEQNO);
    expect(publicKey).toBeGreater(0);
    expect(subwalletId).toEqual(MAINNET_WALLET_V4R1_SUBWALLET_ID);
    expect(plugins.calculateSize()).toBeGreaterOrEqual(0);
    if (!plugins.isEmpty()) {
        val plugin = plugins.getHead();
        expect(wallet.isPluginInstalled(plugin.workchain, plugin.address as int)).toBeTrue();
    }
    expect(wallet.isPluginInstalled(0, 0)).toBeFalse();
}

get fun `test wallet v4r1 mainnet parses persistent storage`() {
    val wallet = walletV4r1();
    val storage = loadWalletV4r1StorageFromFork(wallet);

    println("WALLET_V4R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V4R1_STORAGE={}", storage);
    println("WALLET_V4R1_STORAGE_PLUGINS={}", storage.plugins);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(wallet.getSubwalletId());
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
}

get fun `test wallet v4r1 mainnet accepts plain internal transfer`() {
    val wallet = walletV4r1();
    val sender = testing.treasury("wallet-v4r1-mainnet-plain-transfer");

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

get fun `test wallet v4r1 mainnet ignores plugin destruct from non-plugin`() {
    val wallet = walletV4r1();
    val sender = testing.treasury("wallet-v4r1-mainnet-plugin-destruct");
    val beforeSeqno = wallet.seqno();

    val txs = wallet.sendWalletV4r1PluginDestruct(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<WalletV4r1PluginDestruct>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.seqno()).toEqual(beforeSeqno);
}

get fun `test wallet v4r1 mainnet rejects invalid external signed request`() {
    val wallet = walletV4r1();

    val result = wallet.sendExternalWalletV4r1SignedExternal(
        zeroSignature(),
        wallet.getSubwalletId(),
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptySimpleSendPayload(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
