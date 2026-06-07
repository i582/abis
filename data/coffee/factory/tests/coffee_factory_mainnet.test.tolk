import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_factory.types"
import "../wrappers/CoffeeFactory.gen"

const FIXTURE_BOC_PATH = "data/coffee/factory/testdata/CoffeeFactory.boc"
const INIT_FIXTURE_BOC_PATH = "data/coffee/init/testdata/CoffeeInit.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9a09f156e0aa9c01246c9a27e2ee3859efdef1191e7782652600efa86ed689d0
const EXPECTED_INIT_CODE_HASH = 0x3297d9a5883d6eff2715ee51fed15b7b687e7ae84276795e147bc7b27f5c9bbf

const MAINNET_COFFEE_FACTORY_ADDRESS = "EQAsf2sDPfoo-0IjnRA7l_gJBB9jyo4zqfCG_1IFCCI_Qbef"

fun mainnetCoffeeFactory(): CoffeeFactory {
    return CoffeeFactory.fromAddress(address(MAINNET_COFFEE_FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadCoffeeFactoryStorageFromFork(factory: CoffeeFactory): CoffeeFactoryStorage {
    val account = testing.getAccountState(factory.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeFactory", FIXTURE_BOC_PATH).hash());
            return CoffeeFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Factory mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Factory mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee factory code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeFactory", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee factory mainnet code hash storage and getters`() {
    val factory = mainnetCoffeeFactory();
    val storage = loadCoffeeFactoryStorageFromFork(factory);
    val codeRefs = factory.getCode();
    val codeCells = storage.codeCells.load();
    val getterCodeCells = codeRefs.first.load();

    expect(factory.getAdminAddress()).toEqual(storage.adminAddress);

    expect(codeRefs.first.hash()).toEqual(storage.codeCells.hash());
    expect(codeRefs.second.hash()).toEqual(storage.codeDictionaries.hash());

    expect(getterCodeCells.lpWalletCode.hash()).toEqual(codeCells.lpWalletCode.hash());
    expect(getterCodeCells.initCode.hash()).toEqual(codeCells.initCode.hash());
    expect(getterCodeCells.liquidityDepositoryCode.hash()).toEqual(
        codeCells.liquidityDepositoryCode.hash(),
    );
    expect(getterCodeCells.poolCreatorCode.hash()).toEqual(codeCells.poolCreatorCode.hash());

    expect(codeCells.lpWalletCode.hash()).toBeGreater(0);
    expect(codeCells.initCode.hash()).toEqual(EXPECTED_INIT_CODE_HASH);
    expect(codeCells.initCode.hash()).toEqual(build("CoffeeInit", INIT_FIXTURE_BOC_PATH).hash());
    expect(codeCells.liquidityDepositoryCode.hash()).toBeGreater(0);
    expect(codeCells.poolCreatorCode.hash()).toBeGreater(0);
    expect(storage.codeDictionaries.hash()).toBeGreater(0);
}
