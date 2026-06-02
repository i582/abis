import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_highload_v2r2.types"
import "../wrappers/WalletHighloadV2r2.gen"

const MAINNET_WALLET_HIGHLOAD_V2R2_ADDRESS = "EQBYIB9xax6l7ibZhofm5BfiILbz2rH2PMNrSSShSwC5NvaU"

fun walletHighloadV2r2(): WalletHighloadV2r2 {
    return WalletHighloadV2r2.fromAddress(address(MAINNET_WALLET_HIGHLOAD_V2R2_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 256)
        .endCell()
        .beginParse();
    return signature.loadBits(512) as bits512;
}

fun futureQueryId(): uint64 {
    return (((blockchain.now() + 1000) * 4294967296) as uint64);
}

fun emptyPayload(): map<uint16, HighloadV2r2SendMessageAction> {
    return [];
}

fun loadWalletHighloadV2r2StorageFromFork(wallet: WalletHighloadV2r2): WalletHighloadV2r2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletHighloadV2r2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Highload Wallet V2 R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Highload Wallet V2 R2 mainnet fixture account is frozen");
        }
    }
}

get fun `test highload wallet v2r2 mainnet getters through wrapper`() {
    val wallet = walletHighloadV2r2();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val publicKey = wallet.getPublicKey();
    val processedOld = wallet.processed(0);
    val processedFuture = wallet.processed(futureQueryId() as int);

    println("WALLET_HIGHLOAD_V2R2_GETTERS_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V2R2_PUBLIC_KEY={}", publicKey);
    println("WALLET_HIGHLOAD_V2R2_PROCESSED_0={}", processedOld);
    println("WALLET_HIGHLOAD_V2R2_PROCESSED_FUTURE={}", processedFuture);

    expect(publicKey).toBeGreater(0);
    expect(processedOld).toBeGreaterOrEqual(-1);
    expect(processedOld).toBeLessOrEqual(1);
    expect(processedFuture).toBeGreaterOrEqual(-1);
    expect(processedFuture).toBeLessOrEqual(1);
}

get fun `test highload wallet v2r2 mainnet parses persistent storage`() {
    val wallet = walletHighloadV2r2();
    val storage = loadWalletHighloadV2r2StorageFromFork(wallet);

    println("WALLET_HIGHLOAD_V2R2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V2R2_STORAGE_PUBLIC_KEY={}", storage.publicKey);
    println("WALLET_HIGHLOAD_V2R2_STORAGE_SUBWALLET_ID={}", storage.subwalletId);
    println("WALLET_HIGHLOAD_V2R2_STORAGE_LAST_CLEANED={}", storage.lastCleaned);
    println("WALLET_HIGHLOAD_V2R2_STORAGE_QUERIES_PRESENT={}", storage.queries != null);

    expect(storage.publicKey).toEqual(wallet.getPublicKey());
    expect(storage.subwalletId).toBeGreaterOrEqual(0);
}

get fun `test highload wallet v2r2 mainnet accepts plain internal transfer`() {
    val wallet = walletHighloadV2r2();
    val sender = testing.treasury("wallet-highload-v2r2-mainnet-plain-transfer");

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

get fun `test highload wallet v2r2 mainnet does not accept malformed external request`() {
    val wallet = walletHighloadV2r2();
    val storage = loadWalletHighloadV2r2StorageFromFork(wallet);

    val result = wallet.sendExternalHighloadWalletSignedV2r2(
        zeroSignature(),
        storage.subwalletId,
        0,
        emptyPayload(),
    );

    expect(result).toBeNotAccepted();
}
