import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jvault_pool_factory.types"
import "../wrappers/JVaultPoolFactory.gen"

const FACTORY_ADDRESS = "EQAYS3AO2NaFr5-wl1CU8QMiCxrP0OEXYn82iqnuST9FKo9I"
const POOL_ADDRESS = "EQDaC-uD4Q0GkTnG9lXqPb5HKgyUhlzcQVJOHJDnDyVNUdik"
const ADMIN_ADDRESS = "EQDtZ91HL9fRGJlGyceT2OEVLXfH3qCAaVUgRA6nz5ZuZRSu"
const OWNER_ADDRESS = "EQAPAyUbcOv-r3XTKoAma309Km5RSxkb08zz999OYJl4T6MG"
const FEES_WALLET_ADDRESS = "EQBTHVu0uqX_DgOgskivqyNZFs7CIx4NtgA6znQs3XmKyio6"
const PINNED_MAINNET_BLOCK = 43915595
const EXPECTED_CODE_HASH = 0x7527c9e2128d8e22a20c9ecee14c3b5ba4da1742eb9ac24dfbdc19784e0ab4fb
const EXPECTED_DATA_HASH = 0x93b9ac73f4172aa47a8935054d21a73aae5d27d7001cf4f02980a035863f1b4c
const CODE_BOC_PATH = "data/jvault/pool_factory/testdata/JVaultPoolFactory.boc"
const DATA_BOC_PATH = "data/jvault/pool_factory/testdata/JVaultPoolFactory.data.boc"

fun factory(): JVaultPoolFactory {
    return JVaultPoolFactory.fromAddress(address(FACTORY_ADDRESS));
}

fun loadFactoryStorage(contract: JVaultPoolFactory): JVaultPoolFactoryStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();
    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(code!.hash()).toEqual(build("JVaultPoolFactory", CODE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(build("JVaultPoolFactoryData", DATA_BOC_PATH).hash());
            return JVaultPoolFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("JVault pool factory is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("JVault pool factory is frozen at the pinned block");
        }
    }
}

get fun `test jvault pool factory fixtures match pinned mainnet storage and getters`() {
    expect(fs.readBytes(CODE_BOC_PATH)).toBeNotNull();
    expect(fs.readBytes(DATA_BOC_PATH)).toBeNotNull();

    val contract = factory();
    val storage = loadFactoryStorage(contract);
    val codeState = storage.codeState.load();
    val data = contract.getStorageData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.nextPoolId).toEqual(125);
    expect(storage.minRewardsCommission).toEqual(50);
    expect(storage.unstakeFee).toEqual(300000000);
    expect(storage.creationFee).toEqual(50000000000);
    expect(storage.feesWalletAddress).toEqual(address(FEES_WALLET_ADDRESS));
    expect(codeState.adminAddress).toEqual(address(ADMIN_ADDRESS));
    expect(codeState.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(codeState.version).toEqual(10);
    expect(codeState.poolUninitedCodes.isEmpty()).toBeFalse();
    expect(codeState.poolUninitedCodes.get(0).isFound).toBeTrue();

    expect(data.adminAddress).toEqual(codeState.adminAddress);
    expect(data.ownerAddress).toEqual(codeState.ownerAddress);
    expect(data.nextPoolId).toEqual(storage.nextPoolId as int);
    expect(storage.collectionContent).toBeNotNull();
    expect(data.collectionContent).toBeNotNull();
    expect(data.collectionContent!.hash()).toEqual(storage.collectionContent!.hash());
    expect(data.minRewardsCommission).toEqual(storage.minRewardsCommission as int);
    expect(data.unstakeFee).toEqual(storage.unstakeFee);
    expect(data.feesWalletAddress).toEqual(storage.feesWalletAddress);
    expect(data.creationFee).toEqual(storage.creationFee);
    expect(data.poolUninitedCodes).toBeNotNull();
    expect(data.poolInitedCode.hash()).toEqual(codeState.poolInitedCode.hash());
    expect(data.stakeWalletCode.hash()).toEqual(codeState.stakeWalletCode.hash());
    expect(data.jettonMinterCode.hash()).toEqual(codeState.jettonMinterCode.hash());
    expect(data.version).toEqual(codeState.version as int);
    expect(contract.getNftAddressByIndex(51)).toEqual(address(POOL_ADDRESS));

    val collection = contract.getCollectionData();
    expect(collection.nextItemIndex).toEqual(storage.nextPoolId as int);
    expect(collection.collectionContent).toBeNotNull();
    expect(collection.collectionContent!.hash()).toEqual(storage.collectionContent!.hash());
    expect(collection.ownerAddress).toEqual(codeState.adminAddress);

    val individualContent = beginCell().storeUint(0x12345678, 32).endCell();
    expect(contract.getNftContent(51, individualContent).hash()).toEqual(individualContent.hash());
    println("JVAULT_POOL_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
