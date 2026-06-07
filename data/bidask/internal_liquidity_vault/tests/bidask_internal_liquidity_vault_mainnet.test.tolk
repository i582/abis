import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/bidask_internal_liquidity_vault.types"
import "../wrappers/BidaskInternalLiquidityVault.gen"

const FIXTURE_BOC_PATH = "data/bidask/internal_liquidity_vault/testdata/BidaskInternalLiquidityVault.boc"
const EXPECTED_CODE_HASH = 0x5b80fb2241c901e8288d1b72c9720366daca00f7daf019a49fa6995bb630d495
const EXPECTED_DATA_HASH = 0x8ec6b5e2951fa39dfaec5cdd760cf6133146d73a5620927d1fb72034b5852398
const PINNED_MAINNET_BLOCK = 71186170

const MAINNET_BIDASK_INTERNAL_LIQUIDITY_VAULT_ADDRESS = "EQDW_6A6NcARhuLMhP419XpPDCTqlx_dzaZ_lBcdwp4YHjYQ"

fun mainnetBidaskInternalLiquidityVault(): BidaskInternalLiquidityVault {
    return BidaskInternalLiquidityVault.fromAddress(
        address(MAINNET_BIDASK_INTERNAL_LIQUIDITY_VAULT_ADDRESS),
    );
}

fun loadBidaskInternalLiquidityVaultStorageFromFork(
    vault: BidaskInternalLiquidityVault,
): BidaskInternalLiquidityVaultStorage {
    val account = testing.getAccountState(vault.address);
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
                build("BidaskInternalLiquidityVault", FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return BidaskInternalLiquidityVaultStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Bidask internal liquidity vault mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Bidask internal liquidity vault mainnet fixture account is frozen");
        }
    }
}

get fun `test bidask internal liquidity vault mainnet getter matches fork storage`() {
    val vault = mainnetBidaskInternalLiquidityVault();
    val storage = loadBidaskInternalLiquidityVaultStorageFromFork(vault);
    val liquidityData = vault.getLiquidityData();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(liquidityData.userAddress).toEqual(storage.userAddress);
    expect(liquidityData.poolAddress).toEqual(storage.poolAddress);
    expect(liquidityData.amountX).toEqual(storage.amountX);
    expect(liquidityData.amountY).toEqual(storage.amountY);

    println("BIDASK_INTERNAL_LIQUIDITY_VAULT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("BIDASK_INTERNAL_LIQUIDITY_VAULT_ADDRESS={}", vault.address);
    println("BIDASK_INTERNAL_LIQUIDITY_VAULT_STORAGE={}", storage);
    println("BIDASK_INTERNAL_LIQUIDITY_VAULT_GET_LIQUIDITY_DATA={}", liquidityData);
}
