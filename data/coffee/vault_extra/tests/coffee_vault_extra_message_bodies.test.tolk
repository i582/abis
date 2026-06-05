import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_vault_extra.types"
import "../../factory/types/coffee_factory.types"
import "../../factory/wrappers/CoffeeFactory.gen"

const FIXTURE_BOC_PATH = "data/coffee/vault_extra/testdata/CoffeeVaultExtra.boc"
const FACTORY_FIXTURE_BOC_PATH = "data/coffee/factory/testdata/CoffeeFactory.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xab11a31f0417ded5a87029e5d4dccf5c978d7b41c232d261e43d352f868ade8e
const EXPECTED_FACTORY_CODE_HASH = 0x9a09f156e0aa9c01246c9a27e2ee3859efdef1191e7782652600efa86ed689d0
const EXPECTED_EXTRA_CURRENCY_ID = 239
const PINNED_MAINNET_BLOCK = 71349505

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

fun extraAssetSlice(): slice {
    return beginCell()
        .storeUint(2, 2)
        .storeUint(EXPECTED_EXTRA_CURRENCY_ID, 32)
        .endCell()
        .beginParse();
}

fun expectExtraAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(2)).toEqual(2);
    expect(asset.loadUint(32)).toEqual(EXPECTED_EXTRA_CURRENCY_ID);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
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
            expect(code!.hash()).toEqual(EXPECTED_FACTORY_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeFactory", FACTORY_FIXTURE_BOC_PATH).hash());
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

get fun `test coffee extra vault code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeVaultExtra", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee extra vault code is installed in mainnet factory`() {
    val factory = mainnetCoffeeFactory();
    val factoryStorage = loadCoffeeFactoryStorageFromFork(factory);
    val codeDictionaries = factoryStorage.codeDictionaries.load();
    val extraVaultCodeLookup = codeDictionaries.vaultCodeByAssetType.get(2);
    val derivedFromFactory = factory.getVaultAddress(extraAssetSlice());
    var getterAsset = extraAssetSlice();

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();
    expect(extraVaultCodeLookup.isFound).toBeTrue();
    val extraVaultCode = extraVaultCodeLookup.loadValue();
    expect(extraVaultCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(extraVaultCode.hash()).toEqual(build("CoffeeVaultExtra", FIXTURE_BOC_PATH).hash());

    expect((derivedFromFactory.address as any_address).castToInternal()).toEqual(derivedFromFactory.address);

    expectExtraAssetSlice(mutate getterAsset);

    println("COFFEE_VAULT_EXTRA_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_VAULT_EXTRA_DERIVED_ADDRESS={}", derivedFromFactory.address);
    println("COFFEE_VAULT_EXTRA_CODE_HASH={}", extraVaultCode.hash());
}
