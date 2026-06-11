import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/dedust_liquidity_deposit_v1.types"
import "../wrappers/DedustLiquidityDepositV1.gen"

const FIXTURE_BOC_PATH = "data/dedust/v1/liquidity_deposit/testdata/DedustLiquidityDepositV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x80edc8d7bbbb6526c3b06ccb7c2d02a82c20d8ccdf431bf4088b1f1470cc94cc
const FACTORY_DERIVED_UNINITIALIZED_CANDIDATE = "EQD7_Xc-sOKa_NjiEWNRZYVKnuPxlJKxQilD5uZPx0dASlfZ"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test dedust liquidity deposit v1 code boc fixture hash`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("DedustLiquidityDepositV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust liquidity deposit v1 wrapper references uninitialized candidate`() {
    val candidateAddress = address(FACTORY_DERIVED_UNINITIALIZED_CANDIDATE);
    val deposit = DedustLiquidityDepositV1.fromAddress(candidateAddress);

    expect(deposit.address).toEqual(candidateAddress);
    expect(build("DedustLiquidityDepositV1", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}
