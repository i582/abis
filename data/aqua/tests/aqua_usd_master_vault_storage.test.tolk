import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/aqua_usd_master_vault.types"

const CODE_FIXTURE_BOC_PATH = "data/aqua/testdata/AquaUsdMasterVault.boc"
const DATA_FIXTURE_BOC_PATH = "data/aqua/testdata/AquaUsdMasterVault.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe09817bb3befa61cd3930304e82551b047b2af3aa482a226984d43b3d1cb52d4
const EXPECTED_DATA_HASH = 0x8f63863b7c12f0e993d72856e969b195fd81bec9604ab69cb42109b24221366d
const EXPECTED_ADMIN_ADDRESS = "0:DA9575A03C8671066F0AC738A5B79A71DE27B616BD31DD8E7E5EE78A67ACCEF9"
const EXPECTED_TOTAL_SUPPLY = 12141641273

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test aqua usd master vault code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    expect(build("AquaUsdMasterVault", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("AquaUsdMasterVaultData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test aqua usd master vault parses saved mainnet storage fixture`() {
    val data = build("AquaUsdMasterVaultData", DATA_FIXTURE_BOC_PATH);
    val storage = AquaUsdMasterVaultStorage.fromCell(data);
    val admin = storage.adminConfig.load();
    val ledger = storage.assetLedger.load();
    val codes = storage.codeRefs.load();

    expect(admin.adminAddress).toEqual(address(EXPECTED_ADMIN_ADDRESS));
    expect(admin.operationsEnabled).toBeFalse();
    expect(admin.validityWindow).toEqual(120);
    expect(admin.assets).toBeNotNull();
    expect(admin.assetWallets).toBeNotNull();
    expect(admin.settings.hash()).toBeGreater(0);

    expect(ledger.totalSupply).toEqual(EXPECTED_TOTAL_SUPPLY);
    expect(ledger.userAssets).toBeNull();
    expect(ledger.pendingOperations).toBeNotNull();
    expect(ledger.pendingAction.hash()).toEqual(createEmptyCell().hash());

    expect(storage.jettonContent.hash()).toBeGreater(0);
    expect(codes.jettonWalletCode.hash()).toBeGreater(0);
    expect(codes.auxiliaryCode.hash()).toBeGreater(0);
}
