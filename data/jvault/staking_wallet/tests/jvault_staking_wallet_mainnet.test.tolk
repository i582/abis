import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jvault_staking_wallet.types"
import "../wrappers/JVaultStakingWallet.gen"

const STAKING_WALLET_ADDRESS = "EQCJXjA_I-dvImmRg9Mm5lhJAJGHZeQ0bEWAAtQAfTtPu-xc"
const POOL_ADDRESS = "EQDaC-uD4Q0GkTnG9lXqPb5HKgyUhlzcQVJOHJDnDyVNUdik"
const OWNER_ADDRESS = "EQDfmsDtWQP5D_YkXX-XlULvs4HivRaKY38ftT2hS5yAANRf"
const MINTER_ADDRESS = "EQC5AstfTny_upAnB55sgtY7D8aoHh4P-OSrYakf2mYnS_zr"
const PINNED_MAINNET_BLOCK = 43915595
const EXPECTED_CODE_HASH = 0xbc09e075b6b44d00c1e0ecd395b2be605630118ed9067a9980ba0c3daea314c1
const EXPECTED_DATA_HASH = 0x39a586f83b847547adf3cdc1ea273068c827927c5848115276def3cb2f145d63
const CODE_BOC_PATH = "data/jvault/staking_wallet/testdata/JVaultStakingWallet.boc"
const DATA_BOC_PATH = "data/jvault/staking_wallet/testdata/JVaultStakingWallet.data.boc"

fun stakingWallet(): JVaultStakingWallet {
    return JVaultStakingWallet.fromAddress(address(STAKING_WALLET_ADDRESS));
}

fun loadStakingWalletStorage(contract: JVaultStakingWallet): JVaultStakingWalletStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();
    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(code!.hash()).toEqual(build("JVaultStakingWallet", CODE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(build("JVaultStakingWalletData", DATA_BOC_PATH).hash());
            return JVaultStakingWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("JVault staking wallet is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("JVault staking wallet is frozen at the pinned block");
        }
    }
}

get fun `test jvault staking wallet fixtures match pinned mainnet storage and getters`() {
    expect(fs.readBytes(CODE_BOC_PATH)).toBeNotNull();
    expect(fs.readBytes(DATA_BOC_PATH)).toBeNotNull();

    val contract = stakingWallet();
    val storage = loadStakingWalletStorage(contract);
    val state = storage.state.load();
    val walletData = contract.getWalletData();
    val storageData = contract.getStorageData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.stakingPoolAddress).toEqual(address(POOL_ADDRESS));
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.minterAddress).toEqual(address(MINTER_ADDRESS));
    expect(state.lockPeriod).toEqual(2592000);
    expect(state.isActive).toBeTrue();
    expect(state.unstakeCommission).toEqual(1000);
    expect(state.unstakeFee).toEqual(150000000);
    expect(state.rewards.isEmpty()).toBeFalse();
    expect(state.unstakeRequests.isEmpty()).toBeTrue();
    expect(state.whitelist.isEmpty()).toBeTrue();

    expect(walletData.balance).toEqual(state.jettonBalance);
    expect(walletData.ownerAddress).toEqual(storage.ownerAddress);
    expect(walletData.minterAddress).toEqual(storage.minterAddress);
    expect(walletData.walletCode.hash()).toEqual(EXPECTED_CODE_HASH);

    expect(storageData.stakingPoolAddress).toEqual(storage.stakingPoolAddress);
    expect(storageData.ownerAddress).toEqual(storage.ownerAddress);
    expect(storageData.lockPeriod).toEqual(state.lockPeriod as int);
    expect(storageData.jettonBalance).toEqual(state.jettonBalance);
    expect(storageData.rewards).toBeNotNull();
    expect(storageData.unstakeRequests).toBeNull();
    expect(storageData.requestsCount).toEqual(state.requestsCount as int);
    expect(storageData.totalRequestedJettons).toEqual(state.totalRequestedJettons);
    expect(storageData.isActive).toEqual(state.isActive);
    expect(storageData.unstakeCommission).toEqual(state.unstakeCommission as int);
    expect(storageData.unstakeFee).toEqual(state.unstakeFee);
    expect(storageData.minDeposit).toEqual(state.minDeposit);
    expect(storageData.maxDeposit).toEqual(state.maxDeposit);
    expect(storageData.whitelist).toBeNull();
    expect(storageData.minterAddress).toEqual(storage.minterAddress);
    println("JVAULT_STAKING_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
