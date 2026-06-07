import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_pool_v2_const_product.types"
import "../wrappers/StonfiPoolV2ConstProduct.gen"

const FIXTURE_BOC_PATH = "data/stonfi/pool_v2_const_product/testdata/StonfiPoolV2ConstProduct.boc"
const MAINNET_POOL_ADDRESS = "EQCGScrZe1xbyWqWDvdI6mzP-GAcAWFv6ZXuaJOuSqemxku4"
const MAINNET_OWNER_ADDRESS = "EQBLLNfo_Pp-AYPAmgEhUDBgEnvEvNf7pmGdcXDy6s8_lJwy"
const EXPECTED_LP_ACCOUNT_ADDRESS = "EQB6ICmCZGUoNAte6mzEirxP9ws5MHsPJQlMDpuZygrrxfZQ"
const EXPECTED_LP_WALLET_ADDRESS = "EQBtRf9VN6DK5IDOejdA53RhahjLCpAL5lwE_riSiCVymAEU"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xec614ea4aaea3f7768606f1c1632b3374d3de096a1e7c4ba43c8009c487fee9d

fun mainnetStonfiPoolV2ConstProduct(): StonfiPoolV2ConstProduct {
    return StonfiPoolV2ConstProduct.fromAddress(address(MAINNET_POOL_ADDRESS));
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun loadStonfiPoolV2ConstProductStorageFromFork(
    pool: StonfiPoolV2ConstProduct,
): StonfiPoolV2ConstProductStorage {
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
                build("StonfiPoolV2ConstProduct", FIXTURE_BOC_PATH).hash(),
            );
            return StonfiPoolV2ConstProductStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Pool V2 ConstantProduct mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Pool V2 ConstantProduct mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi pool v2 constant product code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("StonfiPoolV2ConstProduct", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi pool v2 constant product mainnet getters match fork storage`() {
    val pool = mainnetStonfiPoolV2ConstProduct();
    val owner = address(MAINNET_OWNER_ADDRESS);
    val storage = loadStonfiPoolV2ConstProductStorageFromFork(pool);
    val staticData = storage.staticData.load();
    val poolType = pool.getPoolType();
    val poolData = pool.getPoolData();
    val lpAccountAddress = pool.getLpAccountAddress(owner);
    val lpWalletAddress = pool.getWalletAddress(owner);
    val jettonData = pool.getJettonData();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();
    expect(poolType).toEqual("constant_product");

    expect(poolData.isLocked).toEqual(storage.isLocked);
    expect(poolData.routerAddress).toEqual(staticData.routerAddress);
    expect(poolData.totalSupply).toEqual(storage.totalSupplyLp as int);
    expect(poolData.reserve0).toEqual(storage.reserve0 as int);
    expect(poolData.reserve1).toEqual(storage.reserve1 as int);
    expect(poolData.token0WalletAddress).toEqual(staticData.token0Address);
    expect(poolData.token1WalletAddress).toEqual(staticData.token1Address);
    expect(poolData.lpFee).toEqual(storage.lpFee);
    expect(poolData.protocolFee).toEqual(storage.protocolFee);
    expect(poolData.protocolFeeAddress).toEqual(storage.protocolFeeAddress);
    expect(poolData.collectedToken0ProtocolFee).toEqual(storage.collectedToken0ProtocolFee as int);
    expect(poolData.collectedToken1ProtocolFee).toEqual(storage.collectedToken1ProtocolFee as int);

    expect(lpAccountAddress).toEqual(address(EXPECTED_LP_ACCOUNT_ADDRESS));
    expect(lpWalletAddress).toEqual(address(EXPECTED_LP_WALLET_ADDRESS));

    expect(jettonData.totalSupply).toEqual(storage.totalSupplyLp as int);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(staticData.routerAddress);
    expect(jettonData.jettonWalletCode.hash()).toEqual(staticData.jettonLpWalletCode.hash());

    println("STONFI_POOL_V2_CP_ADDRESS={}", pool.address);
    println("STONFI_POOL_V2_CP_STORAGE={}", storage);
    println("STONFI_POOL_V2_CP_POOL_DATA={}", poolData);
    println("STONFI_POOL_V2_CP_JETTON_DATA={}", jettonData);
    println("STONFI_POOL_V2_CP_LP_ACCOUNT={}", lpAccountAddress);
    println("STONFI_POOL_V2_CP_LP_WALLET={}", lpWalletAddress);
}
