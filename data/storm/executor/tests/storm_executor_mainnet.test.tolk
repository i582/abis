import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_executor.types"
import "../wrappers/StormExecutor.gen"

const PINNED_MAINNET_BLOCK = 71588122
const MAINNET_EXECUTOR_ADDRESS = "EQDeA8aTt-gxy5nNbbqsoXRQtBYj5ND7LLOrODdUsuZm_bWD"
const MAINNET_EXECUTOR_COLLECTION_ADDRESS = "EQAR1cNVy6K6PV2f_kdrjVziJpWZUW7_HWQV9l4pE7YBSvrZ"
const EXPECTED_EXECUTOR_CODE_HASH = 0x3f79c29d69f353bb65ee15930ac143cb244f780f59a3e56ceb9b8c9c3490be24

fun mainnetStormExecutor(): StormExecutor {
    return StormExecutor.fromAddress(address(MAINNET_EXECUTOR_ADDRESS));
}

fun loadStormExecutorStorageFromFork(executor: StormExecutor): StormExecutorStorage {
    val account = testing.getAccountState(executor.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_EXECUTOR_CODE_HASH);
            return StormExecutorStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm executor item account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm executor item account is frozen");
        }
    }
}

get fun `test storm executor item mainnet storage and getters`() {
    val executor = mainnetStormExecutor();
    val storage = loadStormExecutorStorageFromFork(executor);
    val nftData = executor.getNftData();
    val balances = executor.getExecutorBalances();

    expect(scripts.isContractDeployed(executor.address)).toBeTrue();
    expect(storage.collectionAddress).toEqual(address(MAINNET_EXECUTOR_COLLECTION_ADDRESS));
    expect(nftData.isInitialized).toBeTrue();
    expect(nftData.itemIndex).toEqual(storage.itemIndex as int);
    expect(nftData.collectionAddress).toEqual(storage.collectionAddress);
    expect(nftData.ownerAddress).toBeNotNull();
    expect(nftData.ownerAddress!).toEqual(storage.ownerAddress);
    expect(nftData.content).toBeNotNull();
    expect(nftData.content!.hash()).toEqual(createEmptyCell().hash());
    expect(balances).toEqual(storage.balancesDict);

    println("STORM_EXECUTOR_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_EXECUTOR_ADDRESS={}", executor.address);
    println("STORM_EXECUTOR_STORAGE={}", storage);
    println("STORM_EXECUTOR_NFT_DATA={}", nftData);
    println("STORM_EXECUTOR_BALANCES={}", balances);
}
