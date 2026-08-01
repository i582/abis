import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_mev_protector_legacy.types"
import "../wrappers/CoffeeMevProtectorLegacy.gen"

const FIXTURE_BOC_PATH = "data/coffee/mev_protector/testdata/CoffeeMevProtectorLegacy.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x58fbc2dba2684d38b80bfce3dc5a9ffce00af9b464c7b4dc21cf57e3aae11f1c
const PINNED_MAINNET_BLOCK = 46383851
const MAINNET_COFFEE_MEV_PROTECTOR_ADDRESS = "EQCtOvKAjx29tqdz7aRtvcB9X3pvzMdZIStY6SaaXOPnBtys"

fun legacyCoffeeMevProtector(): CoffeeMevProtectorLegacy {
    return CoffeeMevProtectorLegacy.fromAddress(address(MAINNET_COFFEE_MEV_PROTECTOR_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadLegacyCoffeeMevProtectorStorageFromFork(
    protector: CoffeeMevProtectorLegacy,
): CoffeeMevProtectorLegacyStorage {
    val account = testing.getAccountState(protector.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("CoffeeMevProtectorLegacy", FIXTURE_BOC_PATH).hash(),
            );
            return CoffeeMevProtectorLegacyStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Legacy Coffee MEV Protector mainnet fixture is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Legacy Coffee MEV Protector mainnet fixture is frozen");
        }
    }
}

get fun `test legacy coffee mev protector code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeMevProtectorLegacy", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test legacy coffee mev protector pinned storage and getters`() {
    val protector = legacyCoffeeMevProtector();
    val storage = loadLegacyCoffeeMevProtectorStorageFromFork(protector);

    expect(scripts.isContractDeployed(protector.address)).toBeTrue();
    expect(storage.publicKey).toEqual(protector.getPublicKey());
    expect(storage.publicKey).toBeGreater(0);
    expect(storage.adminAddress.getWorkchain()).toEqual(0);
    expect(storage.subwalletId).toEqual(27);
    expect(storage.processedUntil).toEqual(0);
    expect(protector.processed(0)).toBeTrue();
    expect(protector.processed(1)).toBeFalse();

    println("COFFEE_MEV_PROTECTOR_LEGACY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_MEV_PROTECTOR_LEGACY_ADDRESS={}", protector.address);
    println("COFFEE_MEV_PROTECTOR_LEGACY_STORAGE={}", storage);
}
