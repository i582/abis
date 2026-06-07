import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_pool_v2_weighted_const_product.types"
import "../wrappers/StonfiPoolV2WeightedConstProduct.gen"

const FIXTURE_BOC_PATH = "data/stonfi/pool_v2_weighted_const_product/testdata/StonfiPoolV2WeightedConstProduct.boc"
const MAINNET_POOL_ADDRESS = "EQACLNvkL_2D2XBW_XKqGybPRkeb5URZntsEI6vFxzcHC_YK"
const MAINNET_OWNER_ADDRESS = "EQACLNvkL_2D2XBW_XKqGybPRkeb5URZntsEI6vFxzcHC_YK"
const PINNED_MAINNET_BLOCK = 71167154
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xf04a14c3231221056c3499965e4604417e324f8e9121d840120d803288715594

fun mainnetStonfiPoolV2WeightedConstProduct(): StonfiPoolV2WeightedConstProduct {
    return StonfiPoolV2WeightedConstProduct.fromAddress(address(MAINNET_POOL_ADDRESS));
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun expectNonZeroDerivedAddress(actual: address, label: string): void {
    if (actual == address("0:0000000000000000000000000000000000000000000000000000000000000000")) {
        Assert.fail(label);
    }
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun loadStonfiPoolV2WeightedConstProductStorageFromFork(
    pool: StonfiPoolV2WeightedConstProduct,
): StonfiPoolV2WeightedConstProductStorage {
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
                build("StonfiPoolV2WeightedConstProduct", FIXTURE_BOC_PATH).hash(),
            );
            return StonfiPoolV2WeightedConstProductStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool V2 WeightedConstProduct mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool V2 WeightedConstProduct mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi pool v2 weighted const product code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("StonfiPoolV2WeightedConstProduct", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi pool v2 weighted const product mainnet getters match fork storage`() {
    val pool = mainnetStonfiPoolV2WeightedConstProduct();
    val owner = address(MAINNET_OWNER_ADDRESS);
    val storage = loadStonfiPoolV2WeightedConstProductStorageFromFork(pool);
    val staticData = storage.staticData.load();
    val poolType = pool.getPoolType();
    val poolData = pool.getPoolData();
    val lpAccountAddress = pool.getLpAccountAddress(owner);
    val lpWalletAddress = pool.getWalletAddress(owner);
    val jettonData = pool.getJettonData();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expect(poolType).toEqual("weighted_const_product");

    expect(poolData.isLocked).toEqual(storage.isLocked);
    expect(poolData.routerAddress).toEqual(staticData.routerAddress);
    expect(poolData.totalSupply).toEqual(storage.totalSupplyLp as int);
    expect(poolData.reserve0).toEqual(storage.reserve0 as int);
    expect(poolData.reserve1).toEqual(storage.reserve1 as int);
    expect(poolData.token0WalletAddress).toEqual(staticData.token0WalletAddress);
    expect(poolData.token1WalletAddress).toEqual(staticData.token1WalletAddress);
    expect(poolData.lpFee).toEqual(storage.lpFee);
    expect(poolData.protocolFee).toEqual(storage.protocolFee);
    expectAnyAddressEqualsNullable(poolData.protocolFeeAddress, storage.protocolFeeAddress);
    expect(poolData.collectedToken0ProtocolFee).toEqual(storage.collectedToken0ProtocolFee as int);
    expect(poolData.collectedToken1ProtocolFee).toEqual(storage.collectedToken1ProtocolFee as int);
    expect(poolData.w0).toEqual(storage.w0);

    expectNonZeroDerivedAddress(
        lpAccountAddress,
        "Expected non-zero derived WeightedConstProduct LP account address",
    );
    expectNonZeroDerivedAddress(
        lpWalletAddress,
        "Expected non-zero derived WeightedConstProduct LP wallet address",
    );

    expect(jettonData.totalSupply).toEqual(storage.totalSupplyLp as int);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(staticData.routerAddress);
    expect(jettonData.jettonLpWalletCode.hash()).toEqual(staticData.jettonLpWalletCode.hash());

    println("STONFI_POOL_V2_WCP_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_POOL_V2_WCP_ADDRESS={}", pool.address);
    println("STONFI_POOL_V2_WCP_STORAGE={}", storage);
    println("STONFI_POOL_V2_WCP_POOL_DATA={}", poolData);
    println("STONFI_POOL_V2_WCP_JETTON_DATA={}", jettonData);
    println("STONFI_POOL_V2_WCP_LP_ACCOUNT={}", lpAccountAddress);
    println("STONFI_POOL_V2_WCP_LP_WALLET={}", lpWalletAddress);
}
