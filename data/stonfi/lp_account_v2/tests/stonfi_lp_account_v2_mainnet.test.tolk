import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_lp_account_v2.types"
import "../wrappers/StonfiLpAccountV2.gen"

const FIXTURE_BOC_PATH = "data/stonfi/lp_account_v2/testdata/StonfiLpAccountV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x3f1bb3192caaaa1ab7ae7474de50e2e3625fe2757aed4be4f4e9c3fc85ac0b9a
const TRACE_DERIVED_UNINITIALIZED_ADDRESS = "EQB6ICmCZGUoNAte6mzEirxP9ws5MHsPJQlMDpuZygrrxfZQ"
const CATALOG_NONEXISTENT_ADDRESS = "EQAN0vfAtJDeblkwQkFXZbKnSLhqJvQZ0keBXfEmjNxjRYiW"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun fixtureStorage(): StonfiLpAccountV2Storage {
    return {
        userAddress: address("0:4B2CD7E8FCFA7E0183C09A0121503060127BC4BCD7FBA6619D7170F2EACF3F94"),
        poolAddress: address("0:86292AD97B5C5BC96A960EF748EA6CCFF8601C01616FE995EE6893AE4AA7A6C6"),
        amount0: 260000000,
        amount1: 50000000000,
    };
}

get fun `test stonfi lp account v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("StonfiLpAccountV2", FIXTURE_BOC_PATH);
    val codeFromManifest = build("StonfiLpAccountV2");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test stonfi lp account v2 generated wrapper builds from storage fixture`() {
    val storage = fixtureStorage();
    val contract = StonfiLpAccountV2.fromStorage(storage);
    val byAddress = StonfiLpAccountV2.fromAddress(address(TRACE_DERIVED_UNINITIALIZED_ADDRESS));

    expect(contract.stateInit).toBeNotNull();
    expect(contract.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(contract.stateInit!.data.hash()).toEqual(storage.toCell().hash());
    expect(byAddress.address).toEqual(address(TRACE_DERIVED_UNINITIALIZED_ADDRESS));
    expect(byAddress.stateInit).toBeNull();

    println("STONFI_LP_ACCOUNT_V2_CODE_HASH={}", EXPECTED_CODE_HASH);
    println(
        "STONFI_LP_ACCOUNT_V2_TRACE_DERIVED_UNINITIALIZED_ADDRESS={}",
        TRACE_DERIVED_UNINITIALIZED_ADDRESS,
    );
    println("STONFI_LP_ACCOUNT_V2_CATALOG_NONEXISTENT_ADDRESS={}", CATALOG_NONEXISTENT_ADDRESS);
}
