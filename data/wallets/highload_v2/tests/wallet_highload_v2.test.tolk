import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_highload_v2.types"
import "../wrappers/WalletHighloadV2.gen"

const MAINNET_WALLET_HIGHLOAD_V2_ADDRESS = "Ef-WItEX0pfwHyNd06nWHiSXwSzWt35aDaBUmayotxKgKZJu"

fun walletHighloadV2(): WalletHighloadV2 {
    return WalletHighloadV2.fromAddress(address(MAINNET_WALLET_HIGHLOAD_V2_ADDRESS));
}

fun futureQueryId(): uint64 {
    return (((blockchain.now() + 1000) * 4294967296) as uint64);
}

fun loadWalletHighloadV2StorageFromFork(wallet: WalletHighloadV2): WalletHighloadV2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletHighloadV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Highload Wallet V2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Highload Wallet V2 mainnet fixture account is frozen");
        }
    }
}

get fun `test highload wallet v2 mainnet getters through wrapper`() {
    val wallet = walletHighloadV2();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();

    val publicKey = wallet.getPublicKey();
    val processedOld = wallet.processed(0);
    val processedFuture = wallet.processed(futureQueryId() as int);

    println("WALLET_HIGHLOAD_V2_GETTERS_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V2_PUBLIC_KEY={}", publicKey);
    println("WALLET_HIGHLOAD_V2_PROCESSED_0={}", processedOld);
    println("WALLET_HIGHLOAD_V2_PROCESSED_FUTURE={}", processedFuture);

    expect(publicKey).toBeGreater(0);
    expect(processedOld).toBeGreaterOrEqual(-1);
    expect(processedOld).toBeLessOrEqual(1);
    expect(processedFuture).toBeGreaterOrEqual(-1);
    expect(processedFuture).toBeLessOrEqual(1);
}

get fun `test highload wallet v2 mainnet parses persistent storage`() {
    val wallet = walletHighloadV2();
    val storage = loadWalletHighloadV2StorageFromFork(wallet);

    println("WALLET_HIGHLOAD_V2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V2_STORAGE_PUBLIC_KEY={}", storage.publicKey);
    println("WALLET_HIGHLOAD_V2_STORAGE_SUBWALLET_ID={}", storage.subwalletId);
    println("WALLET_HIGHLOAD_V2_STORAGE_LAST_CLEANED={}", storage.lastCleaned);
    println("WALLET_HIGHLOAD_V2_STORAGE_QUERIES_PRESENT={}", storage.queries != null);

    expect(storage.publicKey).toEqual(wallet.getPublicKey());
    expect(storage.subwalletId).toBeGreaterOrEqual(0);
}
