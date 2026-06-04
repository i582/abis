import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_vault_jetton_v2.types"
import "../wrappers/DedustVaultJettonV2.gen"

const FIXTURE_BOC_PATH = "data/dedust/vault_jetton/testdata/DedustVaultJettonV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa30f0486b813dfe55f549fa986272349a96335e1e44e7276d4878c870083306f
const EXPECTED_VERSION = 3
const EXPECTED_USDT_ASSET_HASH = 0x633bca35c68f2a74da825a9be65cc928c56b3b0560cc771657a0f463bfd18550
const PINNED_MAINNET_BLOCK = 71186135

const MAINNET_DEDUST_JETTON_VAULT_V2_ADDRESS = "EQAYqo4u7VF0fa4DPAebk4g9lBytj2VFny7pzXR0trjtXQaO"
const MAINNET_DEDUST_FACTORY_V2_ADDRESS = "EQBfBWT7X2BHg9tXAxzhz2aKiNTU1tpt5NsiK0uSDW_YAJ67"
const MAINNET_USDT_MINTER_ADDRESS = "EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs"
const MAINNET_USDT_VAULT_WALLET_ADDRESS = "EQCI2sZ8zq25yub6rHEY8FwPqV3zbCqS5oasOdljENCjh0bs"

fun mainnetDedustVaultJettonV2(): DedustVaultJettonV2 {
    return DedustVaultJettonV2.fromAddress(address(MAINNET_DEDUST_JETTON_VAULT_V2_ADDRESS));
}

fun usdtAssetCell(): cell {
    return beginCell()
        .storeUint(1, 4)
        .storeInt(0, 8)
        .storeUint(0xb113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe, 256)
        .endCell();
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadDedustVaultJettonV2StorageFromFork(vault: DedustVaultJettonV2): DedustVaultJettonV2Storage {
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
            expect(code!.hash()).toEqual(build("DedustVaultJettonV2", FIXTURE_BOC_PATH).hash());
            return DedustVaultJettonV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust Jetton Vault v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust Jetton Vault v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test dedust jetton vault v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("DedustVaultJettonV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust jetton vault v2 mainnet getters and storage`() {
    val vault = mainnetDedustVaultJettonV2();
    val storage = loadDedustVaultJettonV2StorageFromFork(vault);
    val proof = storage.cachedProof.load();
    val expectedAsset = usdtAssetCell();
    var asset = vault.getAsset();
    val walletAddr = vault.getWalletAddr();

    expect(scripts.isContractDeployed(vault.address)).toBeTrue();
    expect(expectedAsset.hash()).toEqual(EXPECTED_USDT_ASSET_HASH);

    expect(storage.version).toEqual(EXPECTED_VERSION);
    expect(storage.isReady).toBeTrue();
    expect(storage.jettonMinterAddr).toEqual(address(MAINNET_USDT_MINTER_ADDRESS));
    expect(storage.jettonWalletAddr).toBeNotNull();
    expect(storage.jettonWalletAddr!).toEqual(address(MAINNET_USDT_VAULT_WALLET_ADDRESS));

    expect(proof.factoryAddr).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(proof.contractType).toEqual(1);
    expect(proof.asset.toCell().hash()).toEqual(expectedAsset.hash());
    expect(storage.blankCode.hash()).toBeGreater(0);

    expect(vault.getVersion()).toEqual(EXPECTED_VERSION);
    expect(vault.isReady()).toBeTrue();
    expect(vault.getFactoryAddr()).toEqual(address(MAINNET_DEDUST_FACTORY_V2_ADDRESS));
    expect(walletAddr).toBeNotNull();
    expect(walletAddr!).toEqual(address(MAINNET_USDT_VAULT_WALLET_ADDRESS));
    expect(asset.loadUint(4)).toEqual(1);
    expect(asset.loadInt(8)).toEqual(0);
    expect(asset.loadUint(256)).toEqual(0xb113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe);
    expect(asset.remainingBitsCount()).toEqual(0);
    expect(asset.remainingRefsCount()).toEqual(0);

    println("DEDUST_JETTON_VAULT_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_JETTON_VAULT_V2_ADDRESS={}", vault.address);
    println("DEDUST_JETTON_VAULT_V2_STORAGE={}", storage);
    println("DEDUST_JETTON_VAULT_V2_PROOF={}", proof);
}
