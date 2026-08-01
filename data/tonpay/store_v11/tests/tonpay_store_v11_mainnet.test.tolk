import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonpay_store_v11.types"
import "../wrappers/TonpayStoreV11.gen"

const STORE_ADDRESS = "EQCtRWrkfxovf-H02xc5CjHpC4t3VnxAIrCg6LJaaYflj4RY"
const STORE_OWNER = "EQAiybdndsGkvXphCXWLDu76jwETEKP3aTM2PBjJ7nQ_TkjB"
const FIXTURE_BOC_PATH = "data/tonpay/store_v11/testdata/TonpayStoreV11.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x2874029233d8beb6c653424e933c51e235763f64912d49e07cc51d70113cd113
const EXPECTED_DATA_HASH = 0x53f9d54875da07d6966a1e06327b21cd0f9e55cb198c1881309bf992b21ba2b8
const EXPECTED_INVOICE_CODE_HASH = 0xc92f0bd5246f774b4346ee96fd7e950744ca0ca2804ee15163494363ea166892
const PINNED_MAINNET_BLOCK = 43379093

fun store(): TonpayStoreV11 {
    return TonpayStoreV11.fromAddress(address(STORE_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStoreStorage(contract: TonpayStoreV11): TonpayStoreV11Storage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TonpayStoreV11", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return TonpayStoreV11Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TonPay Store v11 is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TonPay Store v11 is frozen at the pinned block");
        }
    }
}

get fun `test tonpay store v11 code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("TonpayStoreV11", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonpay store v11 parses pinned storage and getters`() {
    val contract = store();
    val storage = loadStoreStorage(contract);
    val metadata = storage.metadata.load();
    val getter = contract.getStoreData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.owner).toEqual(address(STORE_OWNER));
    expect(storage.mccCode).toEqual(7372);
    expect(storage.active).toEqual(-1);
    expect(storage.invoiceCode.hash()).toEqual(EXPECTED_INVOICE_CODE_HASH);
    expect(TonpayStoreV11Text.fromCell(storage.name).value.remainingBitsCount()).toEqual(64);
    expect(
        TonpayStoreV11Text.fromCell(storage.description).value.remainingBitsCount(),
    ).toEqual(160);
    expect(TonpayStoreV11Text.fromCell(metadata.webhook).value.remainingBitsCount()).toEqual(0);
    expect(getter.owner).toEqual(storage.owner);
    expect(getter.mccCode).toEqual(storage.mccCode);
    expect(getter.active).toEqual(storage.active);
    expect(getter.invoiceCode.hash()).toEqual(storage.invoiceCode.hash());
    expect(getter.version).toEqual(11);
    expect(contract.getStoreVersion()).toEqual(11);
    println("TONPAY_STORE_V11_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
