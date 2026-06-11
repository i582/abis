import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_pool_v1.types"
import "../wrappers/StonfiPoolV1.gen"

const FIXTURE_BOC_PATH = "data/stonfi/v1/pool/testdata/StonfiPoolV1.boc"
const MAINNET_POOL_ADDRESS = "EQD8TJ8xEWB1SpnRE4d89YO3jl0W0EiBnNS4IBaHaUmdfizE"
const SAMPLE_OWNER_ADDRESS = "0:DD3DB9A48966047EC491737BF3126D075A51B604105144A7089DF478DAFB0978"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x82566ad72b6568fe7276437d3b0c911aab65ed701c13601941b2917305e81c11
const PINNED_MAINNET_BLOCK = 71819864

fun mainnetStonfiPoolV1(): StonfiPoolV1 {
    return StonfiPoolV1.fromAddress(address(MAINNET_POOL_ADDRESS));
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun loadStonfiPoolV1StorageFromFork(pool: StonfiPoolV1): StonfiPoolV1Storage {
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
            expect(code!.hash()).toEqual(build("StonfiPoolV1", FIXTURE_BOC_PATH).hash());
            return StonfiPoolV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool v1 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi pool v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("StonfiPoolV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi pool v1 mainnet getters match fork storage`() {
    val pool = mainnetStonfiPoolV1();
    val owner = address(SAMPLE_OWNER_ADDRESS);
    val storage = loadStonfiPoolV1StorageFromFork(pool);
    val extra = storage.extra.load();
    val poolData = pool.getPoolData();
    val jettonData = pool.getJettonData();
    val lpAccountAddress = pool.getLpAccountAddress(owner);
    val lpWalletAddress = pool.getWalletAddress(owner);

    val sampleAmount0 = extra.reserve0 / 1000;
    val sampleAmount1 = extra.reserve1 / 1000;
    val sampleLiquidity = storage.totalSupplyLp / 1000;
    val expectedOutputs0 = pool.getExpectedOutputs(sampleAmount0, storage.token0Address);
    val expectedOutputs1 = pool.getExpectedOutputs(sampleAmount1, storage.token1Address);
    val expectedTokens = pool.getExpectedTokens(sampleAmount0, sampleAmount1);
    val expectedLiquidity = pool.getExpectedLiquidity(sampleLiquidity);

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(poolData.reserve0).toEqual(extra.reserve0 as int);
    expect(poolData.reserve1).toEqual(extra.reserve1 as int);
    expect(poolData.token0Address).toEqual(storage.token0Address);
    expect(poolData.token1Address).toEqual(storage.token1Address);
    expect(poolData.lpFee).toEqual(storage.lpFee);
    expect(poolData.protocolFee).toEqual(storage.protocolFee);
    expect(poolData.refFee).toEqual(storage.refFee);
    expect(poolData.protocolFeeAddress).toEqual(extra.protocolFeeAddress);
    expect(poolData.collectedToken0ProtocolFee).toEqual(extra.collectedToken0ProtocolFee as int);
    expect(poolData.collectedToken1ProtocolFee).toEqual(extra.collectedToken1ProtocolFee as int);

    expect(jettonData.totalSupply).toEqual(storage.totalSupplyLp as int);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(storage.routerAddress);
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.jettonLpWalletCode.hash());

    expectInternalAddress(lpAccountAddress);
    expectInternalAddress(lpWalletAddress);

    expect(sampleAmount0).toBeGreater(0);
    expect(sampleAmount1).toBeGreater(0);
    expect(sampleLiquidity).toBeGreater(0);
    expect(expectedOutputs0.out).toBeGreater(0);
    expect(expectedOutputs0.protocolFeeOut).toBeGreaterOrEqual(0);
    expect(expectedOutputs0.refFeeOut).toBeGreaterOrEqual(0);
    expect(expectedOutputs1.out).toBeGreater(0);
    expect(expectedOutputs1.protocolFeeOut).toBeGreaterOrEqual(0);
    expect(expectedOutputs1.refFeeOut).toBeGreaterOrEqual(0);
    expect(expectedTokens).toBeGreater(0);
    expect(expectedLiquidity.amount0Out).toBeGreater(0);
    expect(expectedLiquidity.amount1Out).toBeGreater(0);

    println("STONFI_POOL_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_POOL_V1_ADDRESS={}", pool.address);
    println("STONFI_POOL_V1_STORAGE={}", storage);
    println("STONFI_POOL_V1_POOL_DATA={}", poolData);
    println("STONFI_POOL_V1_JETTON_DATA={}", jettonData);
    println("STONFI_POOL_V1_LP_ACCOUNT={}", lpAccountAddress);
    println("STONFI_POOL_V1_LP_WALLET={}", lpWalletAddress);
}
