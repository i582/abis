import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_wallet_coffee_lp.types"
import "../wrappers/JettonWalletCoffeeLp.gen"
import "../../pool_constant_product/wrappers/CoffeePoolConstantProduct.gen"

const FIXTURE_BOC_PATH = "data/coffee/lp_wallet/testdata/JettonWalletCoffeeLp.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe5ce6005c0b710d9b2cae507dcaf195df8ace3d6869c7d90b17a7bf5a1bbf858
const PINNED_MAINNET_BLOCK = 71349505

const MAINNET_COFFEE_POOL_CONSTANT_PRODUCT_ADDRESS = "EQA5NdnaYUsyg0E7MZuIRdvdCFfstdBr7CQoppfvhqqGkYnJ"
const MAINNET_COFFEE_LP_WALLET_ADDRESS = "EQCqz8MB5IT4u0PsNCM2CvozKPjat8IMLfPqT3tFUAdGd1qW"
const MAINNET_COFFEE_LP_OWNER_ADDRESS = "EQCz79ULW8EogUnE-8vw2AmqYAQbAX3PcdlHV_VQ75zkKjrF"

fun mainnetCoffeeLpWallet(): JettonWalletCoffeeLp {
    return JettonWalletCoffeeLp.fromAddress(address(MAINNET_COFFEE_LP_WALLET_ADDRESS));
}

fun mainnetCoffeePoolConstantProduct(): CoffeePoolConstantProduct {
    return CoffeePoolConstantProduct.fromAddress(
        address(MAINNET_COFFEE_POOL_CONSTANT_PRODUCT_ADDRESS),
    );
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

fun loadJettonWalletCoffeeLpStorageFromFork(
    wallet: JettonWalletCoffeeLp,
): JettonWalletCoffeeLpStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("JettonWalletCoffeeLp", FIXTURE_BOC_PATH).hash());
            return JettonWalletCoffeeLpStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee LP Jetton wallet mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee LP Jetton wallet mainnet fixture account is frozen");
        }
    }
}

get fun `test jetton wallet coffee lp code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("JettonWalletCoffeeLp", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test jetton wallet coffee lp mainnet storage and getter`() {
    val wallet = mainnetCoffeeLpWallet();
    val pool = mainnetCoffeePoolConstantProduct();
    val storage = loadJettonWalletCoffeeLpStorageFromFork(wallet);
    val walletData = wallet.getWalletData();
    val derivedWallet = pool.getWalletAddress(address(MAINNET_COFFEE_LP_OWNER_ADDRESS));

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(derivedWallet).toEqual(wallet.address);

    expect(storage.balance).toEqual(walletData.balance);
    expect(storage.balance).toBeGreater(0);
    expect(storage.ownerAddress).toEqual(address(MAINNET_COFFEE_LP_OWNER_ADDRESS));
    expect(storage.ownerAddress).toEqual(walletData.ownerAddress);
    expect(storage.jettonMasterAddress).toEqual(
        address(MAINNET_COFFEE_POOL_CONSTANT_PRODUCT_ADDRESS),
    );
    expect(storage.jettonMasterAddress).toEqual(walletData.jettonMasterAddress);
    expect(storage.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(storage.jettonWalletCode.hash()).toEqual(walletData.jettonWalletCode.hash());

    expectInternalAddress(storage.ownerAddress);
    expectInternalAddress(storage.jettonMasterAddress);

    println("COFFEE_LP_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("COFFEE_LP_WALLET_ADDRESS={}", wallet.address);
    println("COFFEE_LP_WALLET_STORAGE={}", storage);
    println("COFFEE_LP_WALLET_DATA={}", walletData);
}
