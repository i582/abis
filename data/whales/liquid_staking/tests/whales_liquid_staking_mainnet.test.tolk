import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/whales_liquid_staking.types"
import "../wrappers/WhalesLiquidStaking.gen"

const CODE_FIXTURE_BOC_PATH = "data/whales/liquid_staking/testdata/WhalesLiquidStaking.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb6e75696f4a86dcfda59c97554131a6b9e58acd395ae7e4add1c450e5dc07483
const PINNED_MAINNET_BLOCK = 41143667

const MAINNET_POOL_ADDRESS = "EQB0SoxuGDx5qjVt0P_bPICFeWdFLBmVopHhjgfs0q-wsTON"

const EXPECTED_DEPOSIT_RATE = 967246009
const EXPECTED_WITHDRAW_RATE = 1033672396
const EXPECTED_ROUND_ID = 412
const EXPECTED_MIN_STAKE = 800000000
const EXPECTED_DEPOSIT_FEE = 100000000
const EXPECTED_WITHDRAW_FEE = 100000000
const EXPECTED_RECEIPT_PRICE = 100000000
const EXPECTED_POOL_FEE = 1950
const EXPECTED_MINTER_TOTAL_SUPPLY = 1123094368405450
const EXPECTED_BALANCE = 1161680300091666
const EXPECTED_BALANCE_SENT = 1161626747676637
const EXPECTED_BALANCE_PENDING_WITHDRAW = 768653312686
const EXPECTED_BALANCE_WITHDRAW = 18842032917654

struct LoadedWhalesLiquidStakingStorage {
    data: cell
    storage: WhalesLiquidStakingStorage
    balances: WhalesLiquidStakingBalances
    minter: WhalesLiquidStakingMinter
    proxies: WhalesLiquidStakingProxies
    params: WhalesLiquidStakingParams
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun mainnetWhalesLiquidStaking(): WhalesLiquidStaking {
    return WhalesLiquidStaking.fromAddress(address(MAINNET_POOL_ADDRESS));
}

fun loadStorage(data: cell): LoadedWhalesLiquidStakingStorage {
    val storage = WhalesLiquidStakingStorage.fromCell(data);
    val balances = storage.balances.load();
    val minter = storage.minter.load();
    val proxies = storage.proxyRegistry.load();
    var paramsTail = storage.paramsTail;
    expect(paramsTail.remainingBitsCount()).toEqual(0);
    expect(paramsTail.remainingRefsCount()).toEqual(1);
    val params = WhalesLiquidStakingParams.fromCell(paramsTail.loadRef());
    expect(paramsTail.remainingBitsCount()).toEqual(0);
    expect(paramsTail.remainingRefsCount()).toEqual(0);
    return LoadedWhalesLiquidStakingStorage { data, storage, balances, minter, proxies, params };
}

fun loadFromFork(pool: WhalesLiquidStaking): LoadedWhalesLiquidStakingStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("WhalesLiquidStaking", CODE_FIXTURE_BOC_PATH).hash(),
            );
            return loadStorage(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Whales liquid-staking account is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Whales liquid-staking account is frozen at the pinned block");
        }
    }
}

fun expectPinnedStatus(
    status: WhalesLiquidStakingPoolStatusReply,
    loaded: LoadedWhalesLiquidStakingStorage,
): void {
    expect(status.depositRate).toEqual(EXPECTED_DEPOSIT_RATE);
    expect(status.withdrawRate).toEqual(EXPECTED_WITHDRAW_RATE);
    expect(status.roundId).toEqual(EXPECTED_ROUND_ID);
    expect(status.enabled).toBeTrue();
    expect(status.updatesEnabled).toBeTrue();
    expect(status.minStake).toEqual(EXPECTED_MIN_STAKE);
    expect(status.depositFee).toEqual(EXPECTED_DEPOSIT_FEE);
    expect(status.withdrawFee).toEqual(EXPECTED_WITHDRAW_FEE);
    expect(status.receiptPrice).toEqual(EXPECTED_RECEIPT_PRICE);
    expect(status.poolFee).toEqual(EXPECTED_POOL_FEE);
    expect(status.minterTotalSupply).toEqual(EXPECTED_MINTER_TOTAL_SUPPLY);
    expect(status.balance).toEqual(EXPECTED_BALANCE);
    expect(status.balanceSent).toEqual(EXPECTED_BALANCE_SENT);
    expect(status.balancePendingWithdraw).toEqual(EXPECTED_BALANCE_PENDING_WITHDRAW);
    expect(status.balanceWithdraw).toEqual(EXPECTED_BALANCE_WITHDRAW);

    expect(loaded.storage.roundId).toEqual(status.roundId);
    expect(loaded.params.enabled).toEqual(status.enabled);
    expect(loaded.params.updatesEnabled).toEqual(status.updatesEnabled);
    expect(loaded.params.minStake).toEqual(status.minStake);
    expect(loaded.params.depositFee).toEqual(status.depositFee);
    expect(loaded.params.withdrawFee).toEqual(status.withdrawFee);
    expect(loaded.params.receiptPrice).toEqual(status.receiptPrice);
    expect(loaded.params.poolFee).toEqual(status.poolFee);
    expect(loaded.minter.totalSupply).toEqual(status.minterTotalSupply);
    expect(loaded.balances.balance).toEqual(status.balance);
    expect(loaded.balances.balanceSent).toEqual(status.balanceSent);
    expect(loaded.balances.balancePendingWithdraw).toEqual(status.balancePendingWithdraw);
    expect(loaded.balances.balanceWithdraw).toEqual(status.balanceWithdraw);
}

get fun `test whales liquid staking code fixture is exact`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("WhalesLiquidStaking", CODE_FIXTURE_BOC_PATH).hash()).toEqual(
        EXPECTED_CODE_HASH,
    );
}

get fun `test whales liquid staking pinned pool status and storage`() {
    val pool = mainnetWhalesLiquidStaking();
    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    val loaded = loadFromFork(pool);
    val status = pool.getPoolStatus();
    expectPinnedStatus(status, loaded);

    println("WHALES_LIQUID_STAKING_PINNED_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("WHALES_LIQUID_STAKING_ADDRESS={}", pool.address);
    println("WHALES_LIQUID_STAKING_DATA_HASH={}", loaded.data.hash());
    println("WHALES_LIQUID_STAKING_STATUS={}", status);
}

get fun `test whales liquid staking pinned public getters`() {
    val pool = mainnetWhalesLiquidStaking();
    val loaded = loadFromFork(pool);
    val status = pool.getPoolStatus();
    val proxies = pool.getProxies();
    val owner = pool.getOwner();
    val controller = pool.getController();
    val available = pool.getAvailable();
    val unowned = pool.getUnowned();
    val ownerWallet = pool.getWalletAddress(owner);
    val tonBalance = pool.getTonBalance(1000000000);
    val jettonData = pool.getJettonData();
    val interfaces = pool.supportedInterfaces();
    val params = pool.getParams();
    val proxyZeroStatus = pool.getStakingStatus(0);
    val proxyOneStatus = pool.getStakingStatus(1);

    expect(proxies.proxyZero).toEqual(loaded.proxies.proxyZero);
    expect(proxies.proxyOne).toEqual(loaded.proxies.proxyOne);
    expect(owner).toEqual(loaded.storage.owner);
    expect(controller).toEqual(loaded.storage.controller);
    expect(available).toEqual(loaded.balances.balance - loaded.balances.balanceSent);
    expect(unowned >= 0).toBeTrue();
    expect(ownerWallet.getWorkchain()).toEqual(0);
    expect(tonBalance).toEqual(status.withdrawRate);
    expect(jettonData.totalSupply).toEqual(loaded.minter.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(owner);
    expect(jettonData.jettonContent.hash()).toEqual(loaded.minter.content.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(loaded.minter.walletCode.hash());
    expect(interfaces.introspection).toEqual(123515602279859691144772641439386770278);
    expect(interfaces.discoverableJettonMaster).toEqual(
        256184278959413194623484780286929323492,
    );
    expect(params.enabled).toEqual(loaded.params.enabled);
    expect(params.updatesEnabled).toEqual(loaded.params.updatesEnabled);
    expect(params.minStake).toEqual(loaded.params.minStake);
    expect(params.depositFee).toEqual(loaded.params.depositFee);
    expect(params.withdrawFee).toEqual(loaded.params.withdrawFee);
    expect(params.poolFee).toEqual(loaded.params.poolFee);
    expect(params.receiptPrice).toEqual(loaded.params.receiptPrice);

    println("WHALES_LIQUID_STAKING_AVAILABLE={}", available);
    println("WHALES_LIQUID_STAKING_UNOWNED={}", unowned);
    println("WHALES_LIQUID_STAKING_OWNER_WALLET={}", ownerWallet);
    println("WHALES_LIQUID_STAKING_PROXY_ZERO={}", proxyZeroStatus);
    println("WHALES_LIQUID_STAKING_PROXY_ONE={}", proxyOneStatus);
}
