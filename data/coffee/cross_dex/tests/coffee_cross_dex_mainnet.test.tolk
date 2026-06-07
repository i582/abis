import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../wrappers/CoffeeCrossDex.gen"

const FIXTURE_BOC_PATH = "data/coffee/cross_dex/testdata/CoffeeCrossDex.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xd564938fd0b2a18d39b5c7b0f9453418536885b3fa52533b66795e7f372322a9
const MAINNET_COFFEE_CROSS_DEX_ADDRESS = "EQA9Jk48tAGwHcfRz8IyRw0YWj66Y9kz5zhhf5lCuSlMTlKm"

fun mainnetCoffeeCrossDex(): CoffeeCrossDex {
    return CoffeeCrossDex.fromAddress(address(MAINNET_COFFEE_CROSS_DEX_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectInternalAddress(actual: address): void {
    expect((actual as any_address).castToInternal()).toEqual(actual);
}

fun expectCoffeeCrossDexCodeHashFromFork(crossDex: CoffeeCrossDex): void {
    val account = testing.getAccountState(crossDex.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeCrossDex", FIXTURE_BOC_PATH).hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee CrossDex mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee CrossDex mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee cross dex code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeCrossDex", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee cross dex mainnet code hash and admin getter`() {
    val crossDex = mainnetCoffeeCrossDex();
    val admin = crossDex.getAdmin();

    expectCoffeeCrossDexCodeHashFromFork(crossDex);
    expectInternalAddress(admin);
}
