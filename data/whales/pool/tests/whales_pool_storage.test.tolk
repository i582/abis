import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/whales_pool.types"
import "../wrappers/WhalesPool.gen"

const CODE_FIXTURE_BOC_PATH = "data/whales/pool/testdata/WhalesPool.boc"
const DATA_FIXTURE_BOC_PATH = "data/whales/pool/testdata/WhalesPool.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5d6267a6d5a325b1075c0ba80a12a4a03c7f4f674eeaf28ee4165df5352e578d
const EXPECTED_DATA_HASH = 0x1d530cdfcbee52b3eaabadcde4b308c32b564c1f14fe9501351668851d2dab2c
const EXPECTED_BALANCE_HASH = 0x937ecb5f117222e78b1a3bf36c59c6757decffbcc1f9cad5c57564e8a17c9aaf
const EXPECTED_PROXY_STATE_HASH = 0x2046a3cbcfa594ead843c324afc52991d0c4399317d96312a3dd1b2f22d1acd5
const EXPECTED_EXTRAS_HASH = 0x683003cec0376c9a36192175294b053f11f25729e6ae3199654be1f5e02ed32c
const PINNED_MAINNET_BLOCK = 71810991

const MAINNET_WHALES_POOL_ADDRESS = "EQCkR1cGmnsE45N4K0otPl5EnxnRakmGqeJUNua5fkWhales"
const ZERO_BASECHAIN_ADDRESS = "0:0000000000000000000000000000000000000000000000000000000000000000"
const EXPECTED_OWNER_ADDRESS = "EQAWrkA_GfFFkCMsrA1xiRZ7kHZEty8ZCfcl3O8RA_zlx_Ep"
const EXPECTED_CONTROLLER_ADDRESS = "EQChB6mHV_t4zwS6av_c4Nbx66HVi-fEsAAa_UOnN5RxIoif"
const EXPECTED_PROXY_ADDRESS = "Ef8W1vCpA1tr9xr6QSXSxcVSdn1Sm7SYX_PCWQdClaWhales"

const EXPECTED_PROFIT_PER_COIN = 2164018954512
const EXPECTED_BALANCE = 975465112634631
const EXPECTED_BALANCE_SENT = 975465112634631
const EXPECTED_BALANCE_WITHDRAW = 12715274634207
const EXPECTED_STAKE_AT = 1780829960
const EXPECTED_STAKE_UNTIL = 1780928264
const EXPECTED_STAKE_SENT = 975465112634631
const EXPECTED_STAKE_HELD_FOR = 32768
const EXPECTED_MIN_STAKE = 49800000000
const EXPECTED_DEPOSIT_FEE = 100000000
const EXPECTED_WITHDRAW_FEE = 100000000
const EXPECTED_POOL_FEE = 2500
const EXPECTED_RECEIPT_PRICE = 100000000

struct LoadedWhalesPoolStorage {
    data: cell
    storage: WhalesPoolStorage
    balance: WhalesPoolBalance
    proxyState: WhalesPoolProxyState
    extras: WhalesPoolExtras
}

fun mainnetWhalesPool(): WhalesPool {
    return WhalesPool.fromAddress(address(MAINNET_WHALES_POOL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadExtras(mutate tail: RemainingBitsAndRefs): WhalesPoolExtras {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(1);
    val extrasCell = tail.loadRef();
    expect(extrasCell.hash()).toEqual(EXPECTED_EXTRAS_HASH);
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
    return WhalesPoolExtras.fromCell(extrasCell);
}

fun loadFromDataCell(data: cell): LoadedWhalesPoolStorage {
    val storage = WhalesPoolStorage.fromCell(data);
    var compatibilityTail = storage.compatibilityTail;
    val balance = storage.balance.load();
    val proxyState = storage.proxyState.load();
    val extras = loadExtras(mutate compatibilityTail);
    return LoadedWhalesPoolStorage { data, storage, balance, proxyState, extras };
}

fun loadFromDataFixture(): LoadedWhalesPoolStorage {
    val rawBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val data = build("WhalesPoolData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return loadFromDataCell(data);
}

fun loadFromFork(pool: WhalesPool): LoadedWhalesPoolStorage {
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
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return loadFromDataCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Whales Pool mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Whales Pool mainnet account is frozen");
        }
    }
}

fun expectProxyStateTail(proxyState: WhalesPoolProxyState): void {
    var tail = proxyState.tail;
    expect(tail.remainingBitsCount()).toEqual(33);
    expect(tail.remainingRefsCount()).toEqual(0);
    expect(tail.loadUint(32)).toEqual(EXPECTED_STAKE_HELD_FOR);
    expect(tail.loadUint(1)).toEqual(0);
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectKnownPoolStorage(loaded: LoadedWhalesPoolStorage): void {
    val storage = loaded.storage;
    val balance = loaded.balance;
    val proxyState = loaded.proxyState;
    val extras = loaded.extras;

    expect(loaded.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.locked).toBeTrue();
    expect(storage.owner).toEqual(address(EXPECTED_OWNER_ADDRESS));
    expect(storage.controller).toEqual(address(EXPECTED_CONTROLLER_ADDRESS));
    expect(storage.proxy).toEqual(address(EXPECTED_PROXY_ADDRESS));
    expect(storage.balance.hash()).toEqual(EXPECTED_BALANCE_HASH);
    expect(storage.proxyState.hash()).toEqual(EXPECTED_PROXY_STATE_HASH);
    expect(storage.nominators.isEmpty()).toBeFalse();
    val ownerMember = storage.nominators.mustGet(0);
    expect(ownerMember.balance).toBeGreaterOrEqual(0);
    expect(ownerMember.pendingDeposit).toBeGreaterOrEqual(0);
    expect(ownerMember.pendingWithdraw).toBeGreaterOrEqual(0);

    expect(balance.profitPerCoin).toEqual(EXPECTED_PROFIT_PER_COIN);
    expect(balance.balance).toEqual(EXPECTED_BALANCE);
    expect(balance.balanceSent).toEqual(EXPECTED_BALANCE_SENT);
    expect(balance.balanceWithdraw).toEqual(EXPECTED_BALANCE_WITHDRAW);
    expect(balance.balancePendingWithdraw).toEqual(0);
    expect(balance.balancePendingDeposits).toEqual(0);

    expect(proxyState.stakeAt).toEqual(EXPECTED_STAKE_AT);
    expect(proxyState.stakeUntil).toEqual(EXPECTED_STAKE_UNTIL);
    expect(proxyState.stakeSent).toEqual(EXPECTED_STAKE_SENT);
    expect(proxyState.storedQueryId).toEqual(0);
    expect(proxyState.storedQueryOp).toEqual(0);
    expect(proxyState.storedQueryStake).toEqual(0);
    expectProxyStateTail(proxyState);

    expect(extras.enabled).toBeTrue();
    expect(extras.updatesEnabled).toBeTrue();
    expect(extras.minStake).toEqual(EXPECTED_MIN_STAKE);
    expect(extras.depositFee).toEqual(EXPECTED_DEPOSIT_FEE);
    expect(extras.withdrawFee).toEqual(EXPECTED_WITHDRAW_FEE);
    expect(extras.poolFee).toEqual(EXPECTED_POOL_FEE);
    expect(extras.receiptPrice).toEqual(EXPECTED_RECEIPT_PRICE);
}

fun expectGettersMatchStorage(pool: WhalesPool, loaded: LoadedWhalesPoolStorage): void {
    val balance = loaded.balance;
    val proxyState = loaded.proxyState;
    val extras = loaded.extras;
    val getterPool = pool.getPoolStatus();
    val getterStaking = pool.getStakingStatus();
    val getterParams = pool.getParams();
    val getterOwnerMember = pool.getMember(address(ZERO_BASECHAIN_ADDRESS));
    val getterOwnerBalance = pool.getMemberBalance(address(ZERO_BASECHAIN_ADDRESS));
    val getterMembersRaw = pool.getMembersRaw();
    val getterSupported = pool.supportedInterfaces();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expect(pool.getProxy()).toEqual(loaded.storage.proxy);
    expect(pool.getOwner()).toEqual(loaded.storage.owner);
    expect(pool.getController()).toEqual(loaded.storage.controller);
    expect(pool.getAvailable()).toEqual(balance.balance - balance.balanceSent);
    expect(pool.getUnowned()).toBeGreaterOrEqual(0);

    expect(getterPool.balance).toEqual(balance.balance);
    expect(getterPool.balanceSent).toEqual(balance.balanceSent);
    expect(getterPool.balancePendingDeposits).toEqual(balance.balancePendingDeposits);
    expect(getterPool.balancePendingWithdraw).toEqual(balance.balancePendingWithdraw);
    expect(getterPool.balanceWithdraw).toEqual(balance.balanceWithdraw);

    expect(getterStaking.stakeAt).toEqual(proxyState.stakeAt);
    expect(getterStaking.stakeSent).toEqual(proxyState.stakeSent);
    expect(getterStaking.querySent).toBeFalse();
    expect(getterStaking.locked).toEqual(loaded.storage.locked);
    expect(getterStaking.stakeLockFinal).toBeFalse();
    expect(getterStaking.stakeUntil).toBeGreaterOrEqual(proxyState.stakeUntil);

    expect(getterParams.enabled).toEqual(extras.enabled);
    expect(getterParams.updatesEnabled).toEqual(extras.updatesEnabled);
    expect(getterParams.minStake).toEqual(extras.minStake);
    expect(getterParams.depositFee).toEqual(extras.depositFee);
    expect(getterParams.withdrawFee).toEqual(extras.withdrawFee);
    expect(getterParams.poolFee).toEqual(extras.poolFee);
    expect(getterParams.receiptPrice).toEqual(extras.receiptPrice);

    val ownerMember = loaded.storage.nominators.mustGet(0);
    expect(getterOwnerMember.balance).toEqual(ownerMember.balance);
    expect(getterOwnerMember.pendingDeposit).toEqual(ownerMember.pendingDeposit);
    expect(getterOwnerMember.pendingWithdraw).toEqual(ownerMember.pendingWithdraw);
    expect(getterOwnerMember.memberWithdraw).toEqual(ownerMember.memberWithdraw);
    expect(getterOwnerBalance.balance).toEqual(ownerMember.balance);
    expect(getterOwnerBalance.pendingDeposit).toEqual(ownerMember.pendingDeposit);
    expect(getterOwnerBalance.pendingWithdraw).toEqual(ownerMember.pendingWithdraw);
    expect(getterOwnerBalance.memberWithdraw).toEqual(ownerMember.memberWithdraw);
    expect(getterMembersRaw.isEmpty()).toBeFalse();
    expect(getterMembersRaw.mustGet(0).balance).toEqual(ownerMember.balance);
    expect(getterSupported.introspection).toEqual(123515602279859691144772641439386770278);
    expect(getterSupported.whalesNominators).toEqual(256184278959413194623484780286929323492);
}

fun expectGetMembersObservedFailure(pool: WhalesPool): void {
    try {
        val members = pool.getMembers();
        Assert.fail(format("Whales get_members unexpectedly returned {}", members));
    } catch (e) {
        expect(e).toEqual(2);
        println("WHALES_POOL_GET_MEMBERS_EXPECTED_FAILURE={}", e);
    }
}

get fun `test whales pool code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("WhalesPool", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("WhalesPoolData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test whales pool saved data fixture parses storage`() {
    val loaded = loadFromDataFixture();
    expectKnownPoolStorage(loaded);

    println("WHALES_POOL_DATA_FIXTURE_DATA_HASH={}", loaded.data.hash());
    println("WHALES_POOL_DATA_FIXTURE_BALANCE={}", loaded.balance);
    println("WHALES_POOL_DATA_FIXTURE_PROXY_STATE={}", loaded.proxyState);
}

get fun `test whales pool mainnet storage and getters`() {
    val pool = mainnetWhalesPool();
    val loaded = loadFromFork(pool);
    expectKnownPoolStorage(loaded);
    expectGettersMatchStorage(pool, loaded);
    expectGetMembersObservedFailure(pool);

    println("WHALES_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("WHALES_POOL_ADDRESS={}", pool.address);
    println("WHALES_POOL_DATA_HASH={}", loaded.data.hash());
    println("WHALES_POOL_BALANCE={}", loaded.balance);
    println("WHALES_POOL_PROXY_STATE={}", loaded.proxyState);
}
