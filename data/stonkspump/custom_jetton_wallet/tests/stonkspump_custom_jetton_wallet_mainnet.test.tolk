import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonkspump_custom_jetton_wallet.types"
import "../wrappers/StonksPumpCustomJettonWallet.gen"

const WALLET_ADDRESS = "EQDqO2Hu0l3XjTYJG3frrHw9KJhnTIEMF-gphKPKX8a2X0AA"
const TAX_WALLET_ADDRESS = "EQCh1J0bsHbUvGtRMRdKhMR2wDv5y1cSXcz6vevB6N0N0ET2"
const OWNER_ADDRESS = "0:E64C27985A548DCF2A3E6ADD0B957BE66725528509413E935E29CB845EF92AC9"
const JETTON_MASTER_ADDRESS = "0:2A5F463DA5DA433776D0D094146533AED926DC0BA4E2EF70F52DE5415DF63FC2"
const FIXTURE_BOC_PATH = "data/stonkspump/custom_jetton_wallet/testdata/StonksPumpCustomJettonWallet.boc"
const DATA_FIXTURE_BOC_PATH = "data/stonkspump/custom_jetton_wallet/testdata/StonksPumpCustomJettonWallet.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xf31884376a58f60f280248bba7b3eda78e5e7b4eaf88865f43f895ca43ec3c2d
const EXPECTED_DATA_HASH = 0x7043270e5a7fd7ed681de4a664c434e3ba385d007b795239d083bcea16ec3899
const PINNED_MAINNET_BLOCK = 83402780

fun wallet(): StonksPumpCustomJettonWallet {
    return StonksPumpCustomJettonWallet.fromAddress(address(WALLET_ADDRESS));
}

fun taxWallet(): StonksPumpCustomJettonWallet {
    return StonksPumpCustomJettonWallet.fromAddress(address(TAX_WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadWalletStorage(contract: StonksPumpCustomJettonWallet): StonksPumpCustomJettonWalletStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("StonksPumpCustomJettonWallet", FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(
                build("StonksPumpCustomJettonWalletData", DATA_FIXTURE_BOC_PATH).hash(),
            );
            return StonksPumpCustomJettonWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("sTONks custom Jetton wallet is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("sTONks custom Jetton wallet is frozen at the pinned block");
        }
    }
}

get fun `test sTONks custom Jetton wallet fixture matches live code`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("StonksPumpCustomJettonWallet", FIXTURE_BOC_PATH).hash()).toEqual(
        EXPECTED_CODE_HASH,
    );
}

get fun `test sTONks custom Jetton wallet data fixture matches pinned state`() {
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val data = build("StonksPumpCustomJettonWalletData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = StonksPumpCustomJettonWalletStorage.fromCell(data);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(address(JETTON_MASTER_ADDRESS));
    expect(storage.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test sTONks custom Jetton wallet parses pinned storage and getters`() {
    val contract = wallet();
    val storage = loadWalletStorage(contract);
    val walletData = contract.getWalletData();
    val taxRates = contract.getTax();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.jettonBalance).toEqual(walletData.jettonBalance);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.ownerAddress).toEqual(walletData.ownerAddress.castToInternal());
    expect(storage.jettonMasterAddress).toEqual(address(JETTON_MASTER_ADDRESS));
    expect(storage.jettonMasterAddress).toEqual(
        walletData.jettonMasterAddress.castToInternal(),
    );
    expect(storage.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(walletData.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(taxRates.buyTaxPermille).toEqual(290);
    expect(taxRates.sellTaxPermille).toEqual(290);
    println("STONKSPUMP_CUSTOM_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}

get fun `test sTONks tax receiver is the same pinned custom wallet code`() {
    val contract = taxWallet();
    expect(scripts.isContractDeployed(contract.address)).toBeTrue();

    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);

            val storage = StonksPumpCustomJettonWalletStorage.fromCell(data!);
            val walletData = contract.getWalletData();
            val taxRates = contract.getTax();
            expect(storage.ownerAddress).toEqual(storage.jettonMasterAddress);
            expect(storage.jettonBalance).toEqual(walletData.jettonBalance);
            expect(storage.ownerAddress).toEqual(walletData.ownerAddress.castToInternal());
            expect(storage.jettonMasterAddress).toEqual(
                walletData.jettonMasterAddress.castToInternal(),
            );
            expect(taxRates.buyTaxPermille).toEqual(290);
            expect(taxRates.sellTaxPermille).toEqual(290);
        }
        TlbAccountStateUninit => {
            Assert.fail("sTONks tax receiver is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("sTONks tax receiver is frozen at the pinned block");
        }
    }
}
