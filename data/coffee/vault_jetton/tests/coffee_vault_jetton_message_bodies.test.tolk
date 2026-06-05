import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_vault_jetton.types"
import "../wrappers/CoffeeVaultJetton.gen"
import "../../factory/types/coffee_factory.types"
import "../../factory/wrappers/CoffeeFactory.gen"

const FIXTURE_BOC_PATH = "data/coffee/vault_jetton/testdata/CoffeeVaultJetton.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x01be8cfa5a62c758fbd7e5602b598cdcbbd1f6bd050397f8b4b959c016e71244
const EXPECTED_FACTORY_ADDRESS = "EQAsf2sDPfoo-0IjnRA7l_gJBB9jyo4zqfCG_1IFCCI_Qbef"
const EXPECTED_CES_MINTER_HASH = 0xa5d12e31be87867851a28d3ce271203c8fa1a28ae826256e73c506d94d49edad
const PINNED_MAINNET_BLOCK = 71349505

const MAINNET_COFFEE_VAULT_JETTON_CES_ADDRESS = "EQDp1qV-qwZ8Fzhi-4k7vRz3BtZWv3OS8aMTuRSauZYxF3fw"

fun mainnetCoffeeVaultJettonCes(): CoffeeVaultJetton {
    return CoffeeVaultJetton.fromAddress(address(MAINNET_COFFEE_VAULT_JETTON_CES_ADDRESS));
}

fun mainnetCoffeeFactory(): CoffeeFactory {
    return CoffeeFactory.fromAddress(address(EXPECTED_FACTORY_ADDRESS));
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

fun cesAssetCell(): cell {
    return beginCell()
        .storeUint(1, 2)
        .storeUint(0, 8)
        .storeUint(EXPECTED_CES_MINTER_HASH, 256)
        .endCell();
}

fun cesFactoryAssetSlice(): slice {
    return cesAssetCell().beginParse();
}

fun expectCesAsset(asset: CoffeeAsset): void {
    match (asset) {
        CoffeeNativeAsset => {
            Assert.fail("Expected CES Coffee vault asset");
        }
        CoffeeJettonAsset => {
            expect(asset.chain).toEqual(0);
            expect(asset.hash).toEqual(EXPECTED_CES_MINTER_HASH);
            expect(asset.toCell().hash()).toEqual(cesAssetCell().hash());
        }
        CoffeeExtraAsset => {
            Assert.fail("Expected CES Coffee vault asset");
        }
    }
}

fun expectCesAssetSlice(mutate asset: slice): void {
    expect(asset.loadUint(2)).toEqual(1);
    expect(asset.loadUint(8)).toEqual(0);
    expect(asset.loadUint(256)).toEqual(EXPECTED_CES_MINTER_HASH);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);
}

fun loadCoffeeVaultJettonActiveStorageFromFork(vault: CoffeeVaultJetton): CoffeeVaultJettonActiveStorage {
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
            expect(code!.hash()).toEqual(build("CoffeeVaultJetton", FIXTURE_BOC_PATH).hash());
            return CoffeeVaultJettonActiveStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Jetton Vault mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Jetton Vault mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee jetton vault code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeVaultJetton", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee jetton vault mainnet storage and getters`() {
    val vault = mainnetCoffeeVaultJettonCes();
    val factory = mainnetCoffeeFactory();
    val storage = loadCoffeeVaultJettonActiveStorageFromFork(vault);
    val initData = storage.initData.load();
    val derivedVault = factory.getVaultAddress(cesFactoryAssetSlice());
    var getterAsset = vault.getAsset();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(derivedVault.address).toEqual(vault.address);
    expectInternalAddress(derivedVault.address);

    expect(storage.initCode.hash()).toBeGreater(0);
    expect(storage.isActive).toBeTrue();
    expectInternalAddress(storage.jettonWalletAddress);
    expect(scripts.isContractDeployed(storage.jettonWalletAddress)).toBeTrue();

    expect(initData.factoryAddress).toEqual(address(EXPECTED_FACTORY_ADDRESS));
    expect(initData.contractType).toEqual(0);
    expectCesAsset(initData.asset);

    expect(vault.isActive()).toBeTrue();
    expectCesAssetSlice(mutate getterAsset);

    println("COFFEE_VAULT_JETTON_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_VAULT_JETTON_ADDRESS={}", vault.address);
    println("COFFEE_VAULT_JETTON_WALLET_ADDRESS={}", storage.jettonWalletAddress);
    println("COFFEE_VAULT_JETTON_STORAGE={}", storage);
    println("COFFEE_VAULT_JETTON_INIT_DATA={}", initData);
}
