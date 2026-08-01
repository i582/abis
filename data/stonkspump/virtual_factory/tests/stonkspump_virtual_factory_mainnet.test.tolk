import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonkspump_virtual_factory.types"
import "../wrappers/StonksPumpVirtualFactory.gen"

const STONFI_FIXTURE_BOC_PATH = "data/stonkspump/virtual_factory/testdata/StonksPumpVirtualFactoryStonfi.boc"
const DEDUST_FIXTURE_BOC_PATH = "data/stonkspump/virtual_factory/testdata/StonksPumpVirtualFactoryDedust.boc"
const DEDUST_LEGACY_FIXTURE_BOC_PATH = "data/stonkspump/virtual_factory/testdata/StonksPumpVirtualFactoryDedustLegacy.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const STONFI_CODE_HASH = 0x44903ee5b721b0d191240c5a92ed33b8cd9b6148b59a3b38b74d90dac68e2d2c
const DEDUST_CODE_HASH = 0xbe5990668fddb2c5233c82306fa23bb0628e2ed2181a484fca932ddbced6eca6
const DEDUST_LEGACY_CODE_HASH = 0xbe563231237e067c923158c6f8a79a7c71c6c3f6dd0e73556d1ee350cff7502c
const STONFI_DATA_HASH = 0x064aa177743b2e3c4d3064d9e271d905980e2f1130ba60dbfb5eff3fafbfacde
const DEDUST_DATA_HASH = 0x838c5e52e5942944a6dfaae987ca998b2e45a5bad4e81bd76acde2210c1dae58
const PINNED_MAINNET_BLOCK = 83374121
const STONFI_FACTORY_ADDRESS = "EQDC9EI4cr5mG68Bw3gcErGwSNjRum_11UedLmyLYzBuanXZ"
const DEDUST_FACTORY_ADDRESS = "EQB6LdK8fjkBe-H9oupkUH9xWDouKwwwvW_r-P66kit913n_"

fun stonfiFactory(): StonksPumpVirtualFactoryStonfi {
    return StonksPumpVirtualFactoryStonfi.fromAddress(address(STONFI_FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiStorage(
    contract: StonksPumpVirtualFactoryStonfi,
): StonksPumpVirtualFactoryStonfiStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(STONFI_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("StonksPumpVirtualFactory", STONFI_FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(STONFI_DATA_HASH);
            return StonksPumpVirtualFactoryStonfiStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("StonksPump STON.fi factory is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("StonksPump STON.fi factory is frozen at the pinned block");
        }
    }
}

fun loadDedustStorage(): StonksPumpVirtualFactoryDedustStorage {
    val factoryAddress = address(DEDUST_FACTORY_ADDRESS);
    val account = testing.getAccountState(factoryAddress);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(DEDUST_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("StonksPumpVirtualFactory", DEDUST_FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(DEDUST_DATA_HASH);
            return StonksPumpVirtualFactoryDedustStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("StonksPump DeDust factory is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("StonksPump DeDust factory is frozen at the pinned block");
        }
    }
}

fun getDedustFactoryData(): StonksPumpVirtualFactoryDedustData {
    return net.runGetMethod(address(DEDUST_FACTORY_ADDRESS), "get_factory_data");
}

get fun `test stonkspump virtual factory fixtures match live code variants`() {
    val stonfiBytes = fs.readBytes(STONFI_FIXTURE_BOC_PATH);
    val dedustBytes = fs.readBytes(DEDUST_FIXTURE_BOC_PATH);
    val dedustLegacyBytes = fs.readBytes(DEDUST_LEGACY_FIXTURE_BOC_PATH);
    expect(stonfiBytes).toBeNotNull();
    expect(dedustBytes).toBeNotNull();
    expect(dedustLegacyBytes).toBeNotNull();
    expect(hasBocMagic(stonfiBytes!)).toBeTrue();
    expect(hasBocMagic(dedustBytes!)).toBeTrue();
    expect(hasBocMagic(dedustLegacyBytes!)).toBeTrue();
    expect(build("StonksPumpVirtualFactory", STONFI_FIXTURE_BOC_PATH).hash()).toEqual(
        STONFI_CODE_HASH,
    );
    expect(build("StonksPumpVirtualFactory", DEDUST_FIXTURE_BOC_PATH).hash()).toEqual(
        DEDUST_CODE_HASH,
    );
    expect(build("StonksPumpVirtualFactory", DEDUST_LEGACY_FIXTURE_BOC_PATH).hash()).toEqual(
        DEDUST_LEGACY_CODE_HASH,
    );
}

get fun `test stonkspump factory parses pinned stonfi storage and getter`() {
    val contract = stonfiFactory();
    val storage = loadStonfiStorage(contract);
    val factoryData = contract.getFactoryData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.virtualMinterCode.hash()).toEqual(
        0x5c1fb1799914595411a6230992d4d33be78521b376b007daae6574193a26245d,
    );
    expect(storage.jettonWalletCode.hash()).toEqual(
        0x1e60adb36e654f3b7d3064a0ff66d02bcb6f348bbe04f449036cde1f189da510,
    );
    expect(storage.routerAddress).toEqual(
        address("EQBeGsTkQbK4blB38PLbYlhqG2Xt3BH9IcX4FAS_Dpr6xPJK"),
    );
    expect(storage.disabled).toBeFalse();
    expect(factoryData.virtualMinterCode.hash()).toEqual(storage.virtualMinterCode.hash());
    expect(factoryData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(factoryData.routerAddress).toEqual(storage.routerAddress);
    expect(factoryData.disabled).toBeFalse();
}

get fun `test stonkspump factory parses pinned dedust storage and getter`() {
    val storage = loadDedustStorage();
    val factoryData = getDedustFactoryData();

    expect(scripts.isContractDeployed(address(DEDUST_FACTORY_ADDRESS))).toBeTrue();
    expect(storage.virtualMinterCode.hash()).toEqual(
        0x3353e1472a235ae3d198a9fa80b84127e18bc266ba19f18ef4aa53d18e37a165,
    );
    expect(storage.jettonWalletCode.hash()).toEqual(
        0xbef587765f4818a6fc4b35eb2f44b2b8783daff77151dae340c42fa9328f378d,
    );
    expect(storage.dexConfig.hash()).toEqual(
        0x5851780d2386e989b9ab956da7cec5c69a667b9e525f628dcba5eb02c1ee0367,
    );
    expect(storage.disabled).toBeFalse();
    expect(factoryData.virtualMinterCode.hash()).toEqual(storage.virtualMinterCode.hash());
    expect(factoryData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(factoryData.dexConfig.hash()).toEqual(storage.dexConfig.hash());
    expect(factoryData.disabled).toBeFalse();
    println("STONKSPUMP_VIRTUAL_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
