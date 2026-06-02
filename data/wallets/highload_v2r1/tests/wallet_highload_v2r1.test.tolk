import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_highload_v2r1.types"
import "../wrappers/WalletHighloadV2r1.gen"

const MAINNET_WALLET_HIGHLOAD_V2R1_ADDRESS = "EQCKGLtpkfSv0K23DH0MgguDcpWi-qUGo-Ro9znr7GT-DWlV"

fun walletHighloadV2r1(): WalletHighloadV2r1 {
    return WalletHighloadV2r1.fromAddress(address(MAINNET_WALLET_HIGHLOAD_V2R1_ADDRESS));
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

fun emptyPayload(): map<uint16, HighloadV2r1SendMessageAction> {
    return [];
}

fun loadWalletHighloadV2r1StorageFromFork(wallet: WalletHighloadV2r1): WalletHighloadV2r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletHighloadV2r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Highload Wallet V2 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Highload Wallet V2 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test highload wallet v2r1 mainnet getters through wrapper`() {
    val wallet = walletHighloadV2r1();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val processedOld = wallet.processed(0);
    val processedFuture = wallet.processed(futureQueryId() as int);

    println("WALLET_HIGHLOAD_V2R1_GETTERS_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V2R1_PROCESSED_0={}", processedOld);
    println("WALLET_HIGHLOAD_V2R1_PROCESSED_FUTURE={}", processedFuture);

    expect(processedOld).toBeGreaterOrEqual(-1);
    expect(processedOld).toBeLessOrEqual(1);
    expect(processedFuture).toBeGreaterOrEqual(-1);
    expect(processedFuture).toBeLessOrEqual(1);
}

get fun `test highload wallet v2r1 mainnet parses persistent storage`() {
    val wallet = walletHighloadV2r1();
    val storage = loadWalletHighloadV2r1StorageFromFork(wallet);

    println("WALLET_HIGHLOAD_V2R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V2R1_STORAGE_PUBLIC_KEY={}", storage.publicKey);
    println("WALLET_HIGHLOAD_V2R1_STORAGE_SUBWALLET_ID={}", storage.subwalletId);
    println("WALLET_HIGHLOAD_V2R1_STORAGE_LAST_CLEANED={}", storage.lastCleaned);
    println("WALLET_HIGHLOAD_V2R1_STORAGE_QUERIES_PRESENT={}", storage.queries != null);

    expect(storage.publicKey).toBeGreater(0);
    expect(storage.subwalletId).toBeGreaterOrEqual(0);
}

get fun `test highload wallet v2r1 mainnet accepts plain internal transfer`() {
    val wallet = walletHighloadV2r1();
    val sender = testing.treasury("wallet-highload-v2r1-mainnet-plain-transfer");

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

get fun `test highload wallet v2r1 mainnet rejects invalid external subwallet id`() {
    val wallet = walletHighloadV2r1();
    val storage = loadWalletHighloadV2r1StorageFromFork(wallet);

    val result = wallet.sendExternalHighloadWalletSignedV2r1(
        zeroSignature(),
        ((storage.subwalletId as int) + 1) as uint32,
        futureQueryId(),
        emptyPayload(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSubwalletId);
}
