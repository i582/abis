import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_pool_v2_stableswap.types"
import "../wrappers/StonfiPoolV2Stableswap.gen"

const FIXTURE_BOC_PATH = "data/stonfi/pool_v2_stableswap/testdata/StonfiPoolV2Stableswap.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfbc7e8fcca72c2b9c078b359ffa936f46384491b895b6577b0a6cb3f569040bc
const MAINNET_STONFI_POOL_V2_STABLESWAP_ADDRESS = "EQDmFQFfmQHA2zril2F3yQswZAYc-k1hN6CK0il1izLe2892"

fun mainnetStonfiPoolV2Stableswap(): StonfiPoolV2Stableswap {
    return StonfiPoolV2Stableswap.fromAddress(address(MAINNET_STONFI_POOL_V2_STABLESWAP_ADDRESS));
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun loadStonfiPoolV2StableswapStorageFromFork(pool: StonfiPoolV2Stableswap): StonfiPoolV2StableswapStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return StonfiPoolV2StableswapStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool v2 StableSwap mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool v2 StableSwap mainnet fixture account is frozen");
        }
    }
}

fun expectStonfiPoolV2StableswapCodeFromFork(pool: StonfiPoolV2Stableswap): void {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiPoolV2Stableswap", FIXTURE_BOC_PATH).hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool v2 StableSwap mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool v2 StableSwap mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi pool v2 stableswap code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("StonfiPoolV2Stableswap", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi pool v2 stableswap mainnet getters storage and code`() {
    val pool = mainnetStonfiPoolV2Stableswap();
    val storage = loadStonfiPoolV2StableswapStorageFromFork(pool);
    val staticData = storage.staticData.load();
    val poolType = pool.getPoolType();
    val poolData = pool.getPoolData();
    val jettonData = pool.getJettonData();
    val ownerAddress = pool.address;
    val lpAccountAddress = pool.getLpAccountAddress(ownerAddress);
    val lpWalletAddress = pool.getWalletAddress(ownerAddress);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expectStonfiPoolV2StableswapCodeFromFork(pool);

    expect(poolType).toEqual("stableswap");
    expect(poolData.isLocked).toEqual(storage.isLocked);
    expect(poolData.routerAddress).toEqual(staticData.routerAddress);
    expect(poolData.totalSupply).toEqual(storage.totalSupplyLp);
    expect(poolData.reserve0).toEqual(storage.reserve0);
    expect(poolData.reserve1).toEqual(storage.reserve1);
    expect(poolData.token0WalletAddress).toEqual(staticData.token0WalletAddress);
    expect(poolData.token1WalletAddress).toEqual(staticData.token1WalletAddress);
    expect(poolData.lpFee).toEqual(storage.lpFee);
    expect(poolData.protocolFee).toEqual(storage.protocolFee);
    expectAnyAddressEqualsNullable(poolData.protocolFeeAddress, storage.protocolFeeAddress);
    expect(poolData.collectedToken0ProtocolFee).toEqual(storage.collectedToken0ProtocolFee);
    expect(poolData.collectedToken1ProtocolFee).toEqual(storage.collectedToken1ProtocolFee);
    expect(poolData.amp).toEqual(storage.amp);

    expect(jettonData.totalSupply).toEqual(storage.totalSupplyLp);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(staticData.routerAddress);
    expect(jettonData.jettonWalletCode.hash()).toEqual(staticData.jettonLpWalletCode.hash());

    expectInternalAddress(lpAccountAddress);
    expectInternalAddress(lpWalletAddress);

    println("STONFI_POOL_V2_STABLESWAP_ADDRESS={}", pool.address);
    println("STONFI_POOL_V2_STABLESWAP_STORAGE={}", storage);
    println("STONFI_POOL_V2_STABLESWAP_POOL_DATA={}", poolData);
    println("STONFI_POOL_V2_STABLESWAP_JETTON_DATA={}", jettonData);
    println("STONFI_POOL_V2_STABLESWAP_OWNER={}", ownerAddress);
    println("STONFI_POOL_V2_STABLESWAP_LP_ACCOUNT={}", lpAccountAddress);
    println("STONFI_POOL_V2_STABLESWAP_LP_WALLET={}", lpWalletAddress);
}
