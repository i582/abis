import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonpay_invoice_v9.types"
import "../wrappers/TonpayInvoiceV9.gen"

const INVOICE_ADDRESS = "EQAPo0i7Xo_ydl1Xn_O-Lq0-5SwAr10HE9oFWZawJ18v2Ohv"
const STORE_ADDRESS = "EQCtRWrkfxovf-H02xc5CjHpC4t3VnxAIrCg6LJaaYflj4RY"
const MERCHANT_ADDRESS = "EQAiybdndsGkvXphCXWLDu76jwETEKP3aTM2PBjJ7nQ_TkjB"
const BENEFICIARY_ADDRESS = "EQD2wz8Rq5QDj9iK2Z_leGQu-Rup__y-Z4wo8Lm7-tSD6Iz2"
const CUSTOMER_ADDRESS = "EQDhWYRKgHU6PgXrPGBq6QB2KLbOXAQe7JbIrmnq9izhkX7a"
const FIXTURE_BOC_PATH = "data/tonpay/invoice_v9/testdata/TonpayInvoiceV9.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xc92f0bd5246f774b4346ee96fd7e950744ca0ca2804ee15163494363ea166892
const EXPECTED_DATA_HASH = 0x8d03fb7e345905106666ee05da043e34972e34e60c8050bb2cca7d11d0a71a65
const PINNED_MAINNET_BLOCK = 43379093

fun invoice(): TonpayInvoiceV9 {
    return TonpayInvoiceV9.fromAddress(address(INVOICE_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadInvoiceStorage(contract: TonpayInvoiceV9): TonpayInvoiceV9Storage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TonpayInvoiceV9", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return TonpayInvoiceV9Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TonPay Invoice v9 is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TonPay Invoice v9 is frozen at the pinned block");
        }
    }
}

get fun `test tonpay invoice v9 code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("TonpayInvoiceV9", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonpay invoice v9 parses pinned storage and getters`() {
    val contract = invoice();
    val storage = loadInvoiceStorage(contract);
    val getter = contract.getInvoiceData();
    var customer = storage.customer.beginParse();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.store).toEqual(address(STORE_ADDRESS));
    expect(storage.merchant).toEqual(address(MERCHANT_ADDRESS));
    expect(storage.beneficiary).toEqual(address(BENEFICIARY_ADDRESS));
    expect(storage.hasCustomer).toEqual(-1);
    expect(customer.loadAddress()).toEqual(address(CUSTOMER_ADDRESS));
    expect(storage.amount).toEqual(105200000);
    expect(storage.paid).toEqual(-1);
    expect(storage.active).toEqual(-1);
    expect(TonpayInvoiceV9Text.fromCell(storage.invoiceId).value.remainingBitsCount()).toEqual(256);
    expect(TonpayInvoiceV9Text.fromCell(storage.metadata).value.remainingBitsCount()).toEqual(0);
    expect(getter.store).toEqual(storage.store);
    expect(getter.merchant).toEqual(storage.merchant);
    expect(getter.beneficiary).toEqual(storage.beneficiary);
    expect(getter.amount).toEqual(storage.amount);
    expect(getter.paid).toEqual(storage.paid);
    expect(getter.active).toEqual(storage.active);
    expect(getter.version).toEqual(9);
    expect(contract.getInvoiceVersion()).toEqual(9);
    println("TONPAY_INVOICE_V9_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
