import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_sale_legacy.types"
import "../wrappers/GetgemsNftSaleLegacy.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_sale_legacy/testdata/GetgemsNftSaleLegacy.boc"
const MAINNET_SALE_ADDRESS = "EQCPNbnESQwg0tOQymumgXcPpsGCnxNQuh3e6OVLR0iAWaQE"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xdd24e54caaa1a2b8e70514fc39bfc4cbc4b1543ca74d2cc6fc0eb35429e1b9d5

fun mainnetGetgemsNftSaleLegacy(): GetgemsNftSaleLegacy {
    return GetgemsNftSaleLegacy.fromAddress(address(MAINNET_SALE_ADDRESS));
}

fun expectAnyAddressEqualsNullable(actual: any_address, expected: address?): void {
    if (expected == null) {
        expect(actual).toBeNoneAddress();
    } else {
        expect(actual.castToInternal()).toEqual(expected!);
    }
}

fun loadGetgemsNftSaleLegacyStorageFromFork(
    sale: GetgemsNftSaleLegacy,
): GetgemsNftSaleLegacyStorage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return GetgemsNftSaleLegacyStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems legacy NFT sale mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems legacy NFT sale mainnet fixture account is frozen");
        }
    }
}

fun hasBocMagic(mutate bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.loadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test getgems nft sale legacy code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expect(hasBocMagic(mutate bytes)).toBeTrue();

    val code = build("GetgemsNftSaleLegacy", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems nft sale legacy rejects three byte decoded null boc`() {
    var threeByteNull = beginCell().storeUint(0x9ee965, 24).endCell().beginParse();

    expect(hasBocMagic(mutate threeByteNull)).toBeFalse();
}

get fun `test getgems nft sale legacy mainnet getter matches fork storage`() {
    val sale = mainnetGetgemsNftSaleLegacy();
    val storage = loadGetgemsNftSaleLegacyStorageFromFork(sale);
    val fees = storage.fees.load();
    val saleData = sale.getSaleData();

    expect(scripts.isContractDeployed(sale.address)).toBeTrue();
    expect(saleData.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(saleData.nftAddress).toEqual(storage.nftAddress);
    expectAnyAddressEqualsNullable(saleData.nftOwnerAddress, storage.nftOwnerAddress);
    expect(saleData.fullPrice).toEqual(storage.fullPrice);
    expect(saleData.marketplaceFee).toEqual(fees.marketplaceFee);
    expect(saleData.royaltyAddress).toEqual(fees.royaltyAddress);
    expect(saleData.royaltyAmount).toEqual(fees.royaltyAmount);

    println("GETGEMS_NFT_SALE_LEGACY_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_SALE_LEGACY_STORAGE={}", storage);
    println("GETGEMS_NFT_SALE_LEGACY_SALE_DATA={}", saleData);
}
