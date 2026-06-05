import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_damm_lp_wallet.types"
import "../wrappers/BidaskDammLpWallet.gen"

const FIXTURE_BOC_PATH = "data/bidask/damm_lp_wallet/testdata/BidaskDammLpWallet.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/damm_lp_wallet/testdata/BidaskDammLpWallet.data.boc"
const DATA_FIXTURE_BOC = "te6cckEBAgEAtwAB3QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAEAhYACDsPx+h3yxbW1xSFJTqhLKPhYiZ/ozbNULpw4VSoISbADqTVF57qRXQwHnD5Zj+fM1Iy40V8v2DWrV3TQ1SRP3mKVgf0d"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9644004d43aa9f982d99d16cf9677a4bec77bbcec0d1e8e6487b2b76c2261182
const EXPECTED_DATA_HASH = 0xe9b14e732d60778aad55a0a28d815c512d0f936146f48c2863ad3f410ce18821
const HISTORICAL_OWNER_ADDRESS = "0:10761F8FD0EF962DADAE290A4A75425947C2C44CFF466D9AA174E1C2A950424D"
const HISTORICAL_POOL_ADDRESS = "0:EA4D5179EEA4574301E70F9663F9F335232E3457CBF60D6AD5DD34354913F798"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadHistoricalStorageFixture(): BidaskDammLpWalletStorage {
    val data = parseCellFromBase64(DATA_FIXTURE_BOC);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val cursor = data.beginParse();
    expect(cursor.remainingBitsCount()).toEqual(884);
    expect(cursor.remainingRefsCount()).toEqual(1);

    return BidaskDammLpWalletStorage.fromCell(data);
}

get fun `test bidask damm lp wallet local boc fixtures are real and hash verified`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val codeFromFixture = build("BidaskDammLpWallet", FIXTURE_BOC_PATH);
    val codeFromManifest = build("BidaskDammLpWallet");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test bidask damm lp wallet init data fixture parses storage`() {
    val storage = loadHistoricalStorageFixture();
    val addresses = storage.addresses.load();
    val data = storage.toCell();

    expect(storage.balance).toEqual(0);
    expect(storage.feesPerLpXLast).toEqual(0);
    expect(storage.feesPerLpYLast).toEqual(0);
    expect(storage.claimedX).toEqual(0);
    expect(storage.claimedY).toEqual(0);
    expect(addresses.ownerAddress).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(addresses.jettonMasterAddress).toEqual(address(HISTORICAL_POOL_ADDRESS));
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    println("BIDASK_DAMM_LP_WALLET_STORAGE={}", storage);
    println("BIDASK_DAMM_LP_WALLET_STORAGE_ADDRESSES={}", addresses);
}

get fun `test bidask damm lp wallet wrapper builds fixture state init`() {
    val storage = loadHistoricalStorageFixture();
    val wallet = BidaskDammLpWallet.fromStorage(storage);

    expect(wallet.stateInit).toBeNotNull();
    expect(wallet.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(wallet.stateInit!.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(wallet.address.getWorkchain()).toEqual(0);

    println("BIDASK_DAMM_LP_WALLET_FIXTURE_DERIVED_ADDRESS={}", wallet.address);
}
