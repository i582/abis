import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/stakeed_wallet.types"

const CODE_FIXTURE_BOC_PATH = "data/stakee/stakeed_wallet/testdata/StakeedWallet.boc"
const DATA_FIXTURE_BOC_PATH = "data/stakee/stakeed_wallet/testdata/StakeedWallet.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x35a67cc6c2ccc122c47397a21a7d65e9a63098968d5777b600da63b41d54c064
const EXPECTED_OWNER = "0:F6FF877DD4CE1355B101572045F09D54C29309737EB52CA542CFA6C195F7CC5B"
const EXPECTED_MINTER = "0:AA0BA121449FEDA569E02B12FA755D24E834A7454AECF4649590B6DF742AAC8F"
const EXPECTED_WALLET_CODE_HASH = 0x89621dd77e0a9a4ae44279e592f13d6ab5c55decd60cc9ec36b7c2ae40d1595

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test stakeed wallet code and data fixtures are real BoCs`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("StakeedWalletData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test stakeed wallet parses saved mainnet storage fixture`() {
    val data = build("StakeedWalletData", DATA_FIXTURE_BOC_PATH);
    val storage = StakeedWalletStorage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.balance).toEqual(502418887452);
    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER));
    expect(storage.jettonMasterAddress).toEqual(address(EXPECTED_MINTER));
    expect(storage.jettonWalletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
    expect(storage.locked).toEqual(0);
    expect(storage.lockExpiration).toEqual(0);
}
