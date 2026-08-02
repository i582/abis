import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jvault_pool.types"
import "../wrappers/JVaultPool.gen"

const POOL_ADDRESS = "EQDaC-uD4Q0GkTnG9lXqPb5HKgyUhlzcQVJOHJDnDyVNUdik"
const FACTORY_ADDRESS = "EQAYS3AO2NaFr5-wl1CU8QMiCxrP0OEXYn82iqnuST9FKo9I"
const CREATOR_ADDRESS = "EQDTc5NdoOV0Jk70VqOGXyeXceLEHtcdbIUKcfbSZJ3Wryit"
const LOCK_WALLET_ADDRESS = "EQBHNDC01MHD4U-3FIHktw6QISBkXgGpjQkFoOhkgVpeldQ5"
const STAKING_WALLET_ADDRESS = "EQCJXjA_I-dvImmRg9Mm5lhJAJGHZeQ0bEWAAtQAfTtPu-xc"
const STAKING_OWNER_ADDRESS = "EQDfmsDtWQP5D_YkXX-XlULvs4HivRaKY38ftT2hS5yAANRf"
const STAKING_LOCK_PERIOD = 2592000
const PINNED_MAINNET_BLOCK = 43915595
const EXPECTED_CODE_HASH = 0x29905cc7fb23a1da60ef69823f71e78e7152a0da226e67c8f83ab34378f5014a
const EXPECTED_DATA_HASH = 0xb36334bbba384fc6e257a8c9789014cd2bc13e39dff418f3abefad6f11154931
const CODE_BOC_PATH = "data/jvault/pool/testdata/JVaultPool.boc"
const DATA_BOC_PATH = "data/jvault/pool/testdata/JVaultPool.data.boc"

fun pool(): JVaultPool {
    return JVaultPool.fromAddress(address(POOL_ADDRESS));
}

fun loadPoolStorage(contract: JVaultPool): JVaultPoolStorage {
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
            expect(code!.hash()).toEqual(build("JVaultPool", CODE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(build("JVaultPoolData", DATA_BOC_PATH).hash());
            return JVaultPoolStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("JVault pool is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("JVault pool is frozen at the pinned block");
        }
    }
}

get fun `test jvault pool fixtures match pinned mainnet storage and getters`() {
    expect(fs.readBytes(CODE_BOC_PATH)).toBeNotNull();
    expect(fs.readBytes(DATA_BOC_PATH)).toBeNotNull();

    val contract = pool();
    val storage = loadPoolStorage(contract);
    val accounting = storage.accounting.load();
    val data = contract.getStorageData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.initialized).toBeTrue();
    expect(storage.poolId).toEqual(51);
    expect(storage.adminAddress).toEqual(address(FACTORY_ADDRESS));
    expect(storage.creatorAddress).toEqual(address(CREATOR_ADDRESS));
    expect(storage.lockWalletAddress).toEqual(address(LOCK_WALLET_ADDRESS));

    expect(data.initialized).toEqual(storage.initialized);
    expect(data.poolId).toEqual(storage.poolId as int);
    expect(data.adminAddress).toEqual(storage.adminAddress);
    expect(data.creatorAddress).toEqual(storage.creatorAddress);
    expect(data.stakeWalletCode.hash()).toEqual(storage.stakeWalletCode.hash());
    expect(data.lockWalletAddress).toEqual(storage.lockWalletAddress);
    expect(data.tvl).toEqual(accounting.tvl);
    expect(data.tvlWithMultipliers).toEqual(accounting.tvlWithMultipliers);
    expect(data.minDeposit).toEqual(accounting.minDeposit);
    expect(data.maxDeposit).toEqual(accounting.maxDeposit);
    expect(data.rewardJettons).toBeNotNull();
    expect(accounting.rewardJettons.isEmpty()).toBeFalse();
    expect(data.rewardJettonsCount).toEqual(accounting.rewardJettonsCount as int);
    expect(data.rewardsDepositsCount).toEqual(accounting.rewardsDepositsCount as int);
    expect(data.lockPeriods).toBeNotNull();
    expect(accounting.lockPeriods.isEmpty()).toBeFalse();
    expect(data.whitelist).toBeNull();
    expect(accounting.whitelist.isEmpty()).toBeTrue();
    expect(data.unstakeFee).toEqual(accounting.unstakeFee);
    expect(data.collectedCommissions).toEqual(accounting.collectedCommissions);
    expect(data.rewardsCommission).toEqual(accounting.rewardsCommission as int);
    expect(data.version).toEqual(accounting.version as int);

    val nftData = contract.getNftData();
    expect(nftData.initialized).toBeTrue();
    expect(nftData.itemIndex).toEqual(storage.poolId as int);
    expect(nftData.collectionAddress.castToInternal()).toEqual(storage.adminAddress);
    expect(nftData.ownerAddress.castToInternal()).toEqual(storage.creatorAddress);
    expect(nftData.content).toBeNotNull();
    expect(contract.getAuthorityAddress()).toBeNoneAddress();
    expect(contract.getRevokedTime()).toEqual(0);

    val stakingWallet = contract.getStakeWalletAddress(
        address(STAKING_OWNER_ADDRESS),
        STAKING_LOCK_PERIOD,
    );
    expect(stakingWallet.castToInternal()).toEqual(address(STAKING_WALLET_ADDRESS));
    expect(
        contract.getStakeWalletAddress(address(STAKING_OWNER_ADDRESS), 1),
    ).toBeNoneAddress();
    println("JVAULT_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
