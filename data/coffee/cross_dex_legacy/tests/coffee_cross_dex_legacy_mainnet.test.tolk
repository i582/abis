import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_cross_dex_legacy.types"
import "../wrappers/CoffeeCrossDexLegacy.gen"

const CODE_FIXTURE_BOC_PATH = "data/coffee/cross_dex_legacy/testdata/CoffeeCrossDexLegacy.boc"
const DATA_FIXTURE_BOC_PATH = "data/coffee/cross_dex_legacy/testdata/CoffeeCrossDexLegacy.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfea9c6a1ef5eab2c5ca94d6bef1e33994c5786abeb5264760e150da33bfb3677
const EXPECTED_DATA_HASH = 0x310febb481965ca915f817f21529173bd091e2a88b37520d26232f20f060b1a0
const EXPECTED_ADMIN_ADDRESS = "EQAWBrfwIkejZ1A-ZhgbKw05nRVQW8Yl48PYVVloHb0t9nIz"
const EXPECTED_DEPLOYMENT_DISCRIMINATOR = 5
const MAINNET_ADDRESS = "EQA9Jk48tAGwHcfRz8IyRw0YWj66Y9kz5zhhf5lCuSlMTlKm"
const PINNED_MAINNET_BLOCK = 48441113

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDeploymentStorage(): CoffeeCrossDexLegacyDeploymentStorage {
    val data = build("CoffeeCrossDexLegacy", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return CoffeeCrossDexLegacyDeploymentStorage.fromCell(data);
}

fun expectDeploymentStorage(storage: CoffeeCrossDexLegacyDeploymentStorage): void {
    expect(storage.adminAddress).toEqual(address(EXPECTED_ADMIN_ADDRESS));
    expect(storage.deploymentDiscriminator).toEqual(EXPECTED_DEPLOYMENT_DISCRIMINATOR);
}

get fun `test coffee cross dex legacy code and data fixtures are exact`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("CoffeeCrossDexLegacy", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expectDeploymentStorage(savedDeploymentStorage());
}

get fun `test coffee cross dex legacy parses pinned mainnet storage`() {
    val crossDex = CoffeeCrossDexLegacy.fromAddress(address(MAINNET_ADDRESS));
    expect(scripts.isContractDeployed(crossDex.address)).toBeTrue();

    val account = testing.getAccountState(crossDex.address);
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
                build("CoffeeCrossDexLegacy", CODE_FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expectDeploymentStorage(CoffeeCrossDexLegacyDeploymentStorage.fromCell(data!));
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee CrossDex legacy account is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee CrossDex legacy account is frozen at the pinned block");
        }
    }

    println("COFFEE_CROSS_DEX_LEGACY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
