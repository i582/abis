import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_internal_liquidity_vault.types"
import "../wrappers/BidaskInternalLiquidityVault.gen"

const FIXTURE_BOC_PATH = "data/bidask/internal_liquidity_vault/testdata/BidaskInternalLiquidityVault.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/internal_liquidity_vault/testdata/BidaskInternalLiquidityVault.data.boc"
const DATA_FIXTURE_BOC = "te6ccgEBAQEARgAAh4ACdPKF5H54PT1V+OhN7JoXcfh4Zvkx/Agq7jPL9ptkydADWP1o1Ov+3/URrkoz5XmJ3kUXS9uhAN9L9DKOe3Z/hugC"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5b80fb2241c901e8288d1b72c9720366daca00f7daf019a49fa6995bb630d495
const EXPECTED_DATA_HASH = 0x8ec6b5e2951fa39dfaec5cdd760cf6133146d73a5620927d1fb72034b5852398

const EXPECTED_USER_ADDRESS = "0:13a7942f23f3c1e9eaafc7426f64d0bb8fc3c337c98fe04157719e5fb4db264e"
const EXPECTED_POOL_ADDRESS = "0:d63f5a353affb7fd446b928cf95e62779145d2f6e84037d2fd0ca39edd9fe1ba"
const MAINNET_BIDASK_INTERNAL_LIQUIDITY_VAULT_ADDRESS = "EQDW_6A6NcARhuLMhP419XpPDCTqlx_dzaZ_lBcdwp4YHjYQ"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedStorageCell(): cell {
    return parseCellFromBase64(DATA_FIXTURE_BOC);
}

get fun `test bidask internal liquidity vault code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("BidaskInternalLiquidityVault", FIXTURE_BOC_PATH).hash()).toEqual(
        EXPECTED_CODE_HASH,
    );
    expect(savedStorageCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test bidask internal liquidity vault wrapper compiles from address`() {
    val vault = BidaskInternalLiquidityVault.fromAddress(
        address(MAINNET_BIDASK_INTERNAL_LIQUIDITY_VAULT_ADDRESS),
    );
    expect(vault.address).toEqual(address(MAINNET_BIDASK_INTERNAL_LIQUIDITY_VAULT_ADDRESS));
}

get fun `test bidask internal liquidity vault parses saved storage data`() {
    val storageCell = savedStorageCell();
    val storage = BidaskInternalLiquidityVaultStorage.fromCell(storageCell);
    var raw = storageCell.beginParse();

    expect(storage.userAddress).toEqual(address(EXPECTED_USER_ADDRESS));
    expect(storage.poolAddress).toEqual(address(EXPECTED_POOL_ADDRESS));
    expect(storage.amountX).toEqual(0);
    expect(storage.amountY).toEqual(0);

    raw.loadAddress();
    raw.loadAddress();
    raw.loadCoins();
    raw.loadCoins();
    expect(raw.remainingBitsCount()).toEqual(0);
    expect(raw.remainingRefsCount()).toEqual(0);

    println("BIDASK_INTERNAL_LIQUIDITY_VAULT_STORAGE={}", storage);
}
