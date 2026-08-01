import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/verifier_source_item.types"
import "../wrappers/VerifierSourceItem.gen"

const FIXTURE_BOC_PATH = "data/verifier/source_item/testdata/VerifierSourceItem.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x5459cb725307a812e6534a2f15b4f06701d2ae6726999f6d513f5747917d325a
const EXPECTED_DATA_HASH = 0xca5032af4348af961ad86843f222c757668f5dfc80e591604c8b0c5bd1017738
const EXPECTED_CONTENT_HASH = 0x1cc5e222996144367f12e07d8c3b6156a0ebc0f4abfcafa1db627ddcce6bd2a4
const PINNED_MAINNET_BLOCK = 83374126
const SOURCE_ITEM_ADDRESS = "EQAH627ToTDvfkjhyhApoL2Zh9m8hKztrXniYKevoWigsCid"
const SOURCES_REGISTRY_ADDRESS = "EQD-BJSVUJviud_Qv7Ymfd3qzXdrmV525e3YDzWQoHIAiInL"
const VERIFIER_TON_ORG_ID = 0x7494b4c0aca9820e02a5024a9009a84321bd379467c8be09c9d25a26f18d0b87
const VERIFIED_CODE_HASH = 0x88db7990749293ec0493a9b04ea5b65203e7152783a0c9702e89b950c28a4fca

fun sourceItem(): VerifierSourceItem {
    return VerifierSourceItem.fromAddress(address(SOURCE_ITEM_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadSourceItemStorage(contract: VerifierSourceItem): VerifierSourceItemStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("VerifierSourceItem", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return VerifierSourceItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Verifier Source Item is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Verifier Source Item is frozen at the pinned block");
        }
    }
}

get fun `test verifier source item code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("VerifierSourceItem", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test verifier source item parses pinned storage and getter`() {
    val contract = sourceItem();
    val storage = loadSourceItemStorage(contract);
    val data = contract.getSourceItemData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.verifierId).toEqual(VERIFIER_TON_ORG_ID);
    expect(storage.verifiedCodeCellHash).toEqual(VERIFIED_CODE_HASH);
    expect(storage.sourceItemRegistry).toEqual(address(SOURCES_REGISTRY_ADDRESS));
    expect(storage.content.hash()).toEqual(EXPECTED_CONTENT_HASH);
    val storedContent = storage.content.load();
    expect(storedContent.version).toEqual(1);
    expect(storedContent.url.remainingBitsCount()).toEqual(528);
    expect(storedContent.url.remainingRefsCount()).toEqual(0);

    expect(data.verifierId).toEqual(storage.verifierId);
    expect(data.verifiedCodeCellHash).toEqual(storage.verifiedCodeCellHash);
    expect(data.sourceItemRegistry).toEqual(storage.sourceItemRegistry);
    expect(data.content.hash()).toEqual(storage.content.hash());

    println("VERIFIER_SOURCE_ITEM_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
