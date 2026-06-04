import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_pool_v2_weighted_stableswap.types"
import "../wrappers/StonfiPoolV2WeightedStableswap.gen"

const MAINNET_STONFI_POOL_V2_WEIGHTED_STABLESWAP_ADDRESS = "EQBjiBVhFLQVCMS8mKMA3gS823m9Xeu9aXiZUYD4TP8GDvui"
const MAINNET_STONFI_POOL_V2_WEIGHTED_STABLESWAP_ROUTER_ADDRESS = "EQBjK_kjY5R_DoyTRff109VzFrSlKFCC_gOOWIMtyEvCcv2J"
const STONFI_POOL_V2_WEIGHTED_STABLESWAP_BOC = "data/stonfi/pool_v2_weighted_stableswap/testdata/StonfiPoolV2WeightedStableswap.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xdac47636ae899081ebd4f47dc90ef9de98456b1000591069773f683c6d601fa9

fun mainnetStonfiPoolV2WeightedStableswap(): StonfiPoolV2WeightedStableswap {
    return StonfiPoolV2WeightedStableswap.fromAddress(
        address(MAINNET_STONFI_POOL_V2_WEIGHTED_STABLESWAP_ADDRESS),
    );
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiPoolV2WeightedStableswapStorageFromFork(
    pool: StonfiPoolV2WeightedStableswap,
): StonfiPoolV2WeightedStableswapStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return StonfiPoolV2WeightedStableswapStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool V2 WeightedStableSwap mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool V2 WeightedStableSwap mainnet fixture account is frozen");
        }
    }
}

fun expectStonfiPoolV2WeightedStableswapCodeFromFork(pool: StonfiPoolV2WeightedStableswap): void {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("StonfiPoolV2WeightedStableswap", STONFI_POOL_V2_WEIGHTED_STABLESWAP_BOC).hash(),
            );
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool V2 WeightedStableSwap mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool V2 WeightedStableSwap mainnet fixture account is frozen");
        }
    }
}

fun expectStonfiPoolV2WeightedStableswapDerivedAddresses(
    pool: StonfiPoolV2WeightedStableswap,
    owner: address,
): void {
    val lpAccountAddress = pool.getLpAccountAddress(owner);
    val walletAddress = pool.getWalletAddress(owner);
    val lpAccountAddressAny = lpAccountAddress as any_address;
    val walletAddressAny = walletAddress as any_address;

    expect(lpAccountAddressAny).toBeInternalAddress();
    expect(walletAddressAny).toBeInternalAddress();
    expect(lpAccountAddress.getWorkchain()).toEqual(0);
    expect(walletAddress.getWorkchain()).toEqual(0);

    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_DERIVATION_OWNER={}", owner);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_LP_ACCOUNT_ADDRESS={}", lpAccountAddress);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_LP_WALLET_ADDRESS={}", walletAddress);
}

get fun `test stonfi pool v2 weighted stableswap code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(STONFI_POOL_V2_WEIGHTED_STABLESWAP_BOC);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StonfiPoolV2WeightedStableswap", STONFI_POOL_V2_WEIGHTED_STABLESWAP_BOC);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi pool v2 weighted stableswap mainnet getters match fork storage`() {
    val pool = mainnetStonfiPoolV2WeightedStableswap();
    val storage = loadStonfiPoolV2WeightedStableswapStorageFromFork(pool);
    val weightedParams = storage.weightedParams.load();
    val staticData = storage.staticData.load();
    val poolData = pool.getPoolData();
    val jettonData = pool.getJettonData();
    val routerAddress = address(MAINNET_STONFI_POOL_V2_WEIGHTED_STABLESWAP_ROUTER_ADDRESS);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expectStonfiPoolV2WeightedStableswapCodeFromFork(pool);

    expect(pool.getPoolType()).toEqual("weighted_stableswap");
    expect(staticData.routerAddress).toEqual(routerAddress);

    expect(poolData.isLocked).toEqual(storage.isLocked);
    expect(poolData.routerAddress).toEqual(staticData.routerAddress);
    expect(poolData.totalSupply).toEqual(storage.totalSupply);
    expect(poolData.reserve0).toEqual(storage.reserve0);
    expect(poolData.reserve1).toEqual(storage.reserve1);
    expect(poolData.token0WalletAddress).toEqual(staticData.token0WalletAddress);
    expect(poolData.token1WalletAddress).toEqual(staticData.token1WalletAddress);
    expect(poolData.lpFee).toEqual(storage.lpFee);
    expect(poolData.protocolFee).toEqual(storage.protocolFee);
    expectAnyAddressEqualsNullable(poolData.protocolFeeAddress, storage.protocolFeeAddress);
    expect(poolData.collectedToken0ProtocolFee).toEqual(storage.collectedToken0ProtocolFee);
    expect(poolData.collectedToken1ProtocolFee).toEqual(storage.collectedToken1ProtocolFee);
    expect(poolData.amp).toEqual(weightedParams.amp);
    expect(poolData.rate).toEqual(weightedParams.rate);
    expect(poolData.w0).toEqual(weightedParams.w0);
    expectAnyAddressEqualsNullable(poolData.rateSetter, weightedParams.rateSetterAddress);

    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.routerAddress).toEqual(staticData.routerAddress);
    expect(jettonData.jettonLpWalletCode.hash()).toEqual(staticData.jettonLpWalletCode.hash());

    expectStonfiPoolV2WeightedStableswapDerivedAddresses(pool, routerAddress);

    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_ADDRESS={}", pool.address);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_STORAGE={}", storage);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_WEIGHTED_PARAMS={}", weightedParams);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_STATIC_DATA={}", staticData);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_POOL_DATA={}", poolData);
    println("STONFI_POOL_V2_WEIGHTED_STABLESWAP_JETTON_DATA={}", jettonData);
}
