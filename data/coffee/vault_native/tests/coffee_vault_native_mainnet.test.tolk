import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"

const FIXTURE_BOC_PATH = "data/coffee/vault_native/testdata/CoffeeVaultNative.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xd143135bc56a2f2b031c58ebc89bb747dfe31f9df98326117c1b547037897895
const PINNED_MAINNET_BLOCK = 71245765

const MAINNET_COFFEE_VAULT_NATIVE_ADDRESS = "EQDbLqT_zhxpERj0EnXG2iqr1g71ODb_Xoc74R8RzUSElKGD"

struct CoffeeVaultNative {
    address: address
}

fun mainnetCoffeeVaultNative(): CoffeeVaultNative {
    return CoffeeVaultNative.fromAddress(address(MAINNET_COFFEE_VAULT_NATIVE_ADDRESS));
}

fun CoffeeVaultNative.fromAddress(address: address): CoffeeVaultNative {
    return CoffeeVaultNative { address };
}

fun CoffeeVaultNative.getAsset(self): slice {
    return net.runGetMethod(self.address, "get_asset");
}

fun CoffeeVaultNative.isActive(self): bool {
    return net.runGetMethod(self.address, "is_active");
}

fun coffeeNativeAssetCell(): cell {
    return beginCell().storeUint(0, 2).endCell();
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadCoffeeVaultNativeCodeFromFork(vault: CoffeeVaultNative): cell {
    val account = testing.getAccountState(vault.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeVaultNative", FIXTURE_BOC_PATH).hash());
            return code!;
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Native Vault mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Native Vault mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee native vault code boc fixture hash`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeVaultNative", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee native vault mainnet code and safe getters`() {
    val vault = mainnetCoffeeVaultNative();
    val code = loadCoffeeVaultNativeCodeFromFork(vault);
    var asset = vault.getAsset();
    val assetCell = asset.toCell();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);

    expect(vault.isActive()).toBeTrue();
    expect(assetCell.hash()).toEqual(coffeeNativeAssetCell().hash());
    expect(asset.loadUint(2)).toEqual(0);
    expectNoTail(mutate asset);

    println("COFFEE_VAULT_NATIVE_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_VAULT_NATIVE_ADDRESS={}", vault.address);
}
