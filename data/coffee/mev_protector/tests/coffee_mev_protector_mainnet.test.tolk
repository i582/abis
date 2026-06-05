import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_mev_protector.types"
import "../wrappers/CoffeeMevProtector.gen"

const FIXTURE_BOC_PATH = "data/coffee/mev_protector/testdata/CoffeeMevProtector.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xc8b1c7fe7401cb7c54ffba407816255ea268b806c47fa707fc82d22239e7dddd
const MAINNET_COFFEE_MEV_PROTECTOR_ADDRESS = "EQAFXT5Ps3f27Cdla8NhNd9OzIvsDKxh2NPYzRx9NG1ILOFv"

fun mainnetCoffeeMevProtector(): CoffeeMevProtector {
    return CoffeeMevProtector.fromAddress(address(MAINNET_COFFEE_MEV_PROTECTOR_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectCoffeeMevProtectorCodeHashFromFork(protector: CoffeeMevProtector): void {
    val account = testing.getAccountState(protector.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeMevProtector", FIXTURE_BOC_PATH).hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee MEV Protector mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee MEV Protector mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee mev protector code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeMevProtector", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee mev protector mainnet code hash and safe getters`() {
    val protector = mainnetCoffeeMevProtector();
    val publicKey = protector.getPublicKey();
    val processedAtZero = protector.processed(0);

    expectCoffeeMevProtectorCodeHashFromFork(protector);
    expect(publicKey).toBeGreater(0);
    expect(processedAtZero).toEqual(protector.processed(0));
}
