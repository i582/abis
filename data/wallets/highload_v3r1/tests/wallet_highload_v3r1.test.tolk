import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_highload_v3r1.types"
import "../wrappers/WalletHighloadV3r1.gen"

const MAINNET_WALLET_HIGHLOAD_V3R1_ADDRESS = "EQDTku4sK8aSw3x8mGogsXSHgbHfZ4Ld781sMYuL1qPJGQc_"

fun walletHighloadV3r1(): WalletHighloadV3r1 {
    return WalletHighloadV3r1.fromAddress(address(MAINNET_WALLET_HIGHLOAD_V3R1_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun invalidSignedInner(wallet: WalletHighloadV3r1): HighloadV3MsgInner {
    return {
        subwalletId: wallet.getSubwalletId(),
        messageToSend: createEmptyCell(),
        sendMode: 0,
        queryId: { shift: 0 as uint13, bitNumber: 0 as uint10 },
        createdAt: blockchain.now() as uint64,
        timeout: wallet.getTimeout() as uint22,
    };
}

fun loadWalletHighloadV3r1StorageFromFork(wallet: WalletHighloadV3r1): WalletHighloadV3r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletHighloadV3r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Highload Wallet V3 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Highload Wallet V3 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test highload wallet v3r1 mainnet getters through wrapper`() {
    val wallet = walletHighloadV3r1();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val publicKey = wallet.getPublicKey();
    val subwalletId = wallet.getSubwalletId();
    val timeout = wallet.getTimeout();
    val lastCleanTime = wallet.getLastCleanTime();
    val processedWithoutClean = wallet.processed(0, 0);
    val processedWithClean = wallet.processed(0, 1);

    println("WALLET_HIGHLOAD_V3R1_GETTERS_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V3R1_PUBLIC_KEY={}", publicKey);
    println("WALLET_HIGHLOAD_V3R1_SUBWALLET_ID={}", subwalletId);
    println("WALLET_HIGHLOAD_V3R1_TIMEOUT={}", timeout);
    println("WALLET_HIGHLOAD_V3R1_LAST_CLEAN_TIME={}", lastCleanTime);
    println("WALLET_HIGHLOAD_V3R1_PROCESSED_0={}", processedWithoutClean);
    println("WALLET_HIGHLOAD_V3R1_PROCESSED_0_NEED_CLEAN={}", processedWithClean);

    expect(publicKey).toBeGreater(0);
    expect(subwalletId).toBeGreaterOrEqual(0);
    expect(timeout).toBeGreater(0);
    expect(lastCleanTime).toBeGreater(0);
}

get fun `test highload wallet v3r1 mainnet parses persistent storage`() {
    val wallet = walletHighloadV3r1();
    val storage = loadWalletHighloadV3r1StorageFromFork(wallet);

    println("WALLET_HIGHLOAD_V3R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V3R1_STORAGE_PUBLIC_KEY={}", storage.publicKey);
    println("WALLET_HIGHLOAD_V3R1_STORAGE_SUBWALLET_ID={}", storage.subwalletId);
    println("WALLET_HIGHLOAD_V3R1_STORAGE_OLD_QUERIES_PRESENT={}", storage.oldQueries != null);
    println("WALLET_HIGHLOAD_V3R1_STORAGE_QUERIES_PRESENT={}", storage.queries != null);
    println("WALLET_HIGHLOAD_V3R1_STORAGE_LAST_CLEAN_TIME={}", storage.lastCleanTime);
    println("WALLET_HIGHLOAD_V3R1_STORAGE_TIMEOUT={}", storage.timeout);

    expect(storage.publicKey).toEqual(wallet.getPublicKey());
    expect(storage.subwalletId).toEqual(wallet.getSubwalletId());
    expect(storage.lastCleanTime).toEqual(wallet.getLastCleanTime());
    expect(storage.timeout as uint32).toEqual(wallet.getTimeout());
}

get fun `test highload wallet v3r1 mainnet accepts plain internal transfer`() {
    val wallet = walletHighloadV3r1();
    val sender = testing.treasury("wallet-highload-v3r1-mainnet-plain-transfer");

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

get fun `test highload wallet v3r1 mainnet ignores internal transfer from non-self`() {
    val wallet = walletHighloadV3r1();
    val sender = testing.treasury("wallet-highload-v3r1-mainnet-non-self-internal-transfer");

    val txs = wallet.sendHighloadV3InternalTransfer(
        sender.address,
        1,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<HighloadV3InternalTransfer>({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
}

get fun `test highload wallet v3r1 mainnet rejects invalid external signature`() {
    val wallet = walletHighloadV3r1();

    val result = wallet.sendExternalHighloadWalletSignedV3(
        zeroSignature(),
        invalidSignedInner(wallet),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
