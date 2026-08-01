import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_escrow_factory.types"
import "../wrappers/StonfiEscrowFactory.gen"
import "../../escrow_position/types/stonfi_escrow_position.types"

const FIXTURE_BOC_PATH = "data/stonfi/escrow_factory/testdata/StonfiEscrowFactory.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x73b47bdad91b206afed4cc55207136992b5ae00f4a244d11b41f639eba6b5e1d
const EXPECTED_DATA_HASH = 0x69cf0547a906b92cf115659489bd0c1cd664c7bb361ea0ea8803f7bc6bd33478
const EXPECTED_POSITION_CODE_HASH = 0xaab1db63f193a4aecaa3e3a959fc1784f1412b191a66ae870958405ba88114c7
const PINNED_MAINNET_BLOCK = 71167154
const FACTORY_ADDRESS = "EQAzSd3ZA9X_E5348_RxhVqGhY3kfN6fmS0Qi-XFghbpJrBn"
const PROTOCOL_ADDRESS = "EQBAj_9iYponyRxQgNurrn4t7UNS0aQeteHY7U-H-F_XTy-Z"
const POSITION_ADDRESS = "EQAaKWRLpempuPro_iWQLxVMBOmy7xE-wB_THkpF0J9-0bKf"
const DERIVED_VAULT_ADDRESS = "EQDrSsJpBn0Mg_DWRiDtcUqGCZEScJ6hZJ8dnTD3hIUl7J9B"

fun factory(): StonfiEscrowFactory {
    return StonfiEscrowFactory.fromAddress(address(FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadFactoryStorage(contract: StonfiEscrowFactory): StonfiEscrowFactoryStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiEscrowFactory", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return StonfiEscrowFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Escrow Factory is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Escrow Factory is frozen at the pinned block");
        }
    }
}

fun loadPositionStorage(): StonfiEscrowPositionStorage {
    val account = testing.getAccountState(address(POSITION_ADDRESS));
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val data = account!.storage.state.stateInit.data;
            expect(data).toBeNotNull();
            return StonfiEscrowPositionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Escrow Position is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Escrow Position is frozen at the pinned block");
        }
    }
}

get fun `test stonfi escrow factory code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("StonfiEscrowFactory", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi escrow factory parses pinned storage getters and derivations`() {
    val contract = factory();
    val storage = loadFactoryStorage(contract);
    val escrowData = contract.getEscrowData();
    val version = contract.getVersion();
    val positionStorage = loadPositionStorage();
    val positionOrder = StonfiEscrowPositionOrder.fromCell(positionStorage.order);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.globalId).toEqual(1);
    expect(storage.protocol).toEqual(address(PROTOCOL_ADDRESS));
    expect(storage.nextProtocol).toBeNull();
    expect(storage.protocolTier).toEqual(1);
    expect(storage.itemCode.hash()).toEqual(EXPECTED_POSITION_CODE_HASH);

    expect(escrowData.globalId).toEqual(storage.globalId);
    expect(escrowData.protocol).toEqual(storage.protocol);
    expect(escrowData.protocolTier).toEqual(storage.protocolTier);
    expect(escrowData.itemCode.hash()).toEqual(storage.itemCode.hash());
    expect(escrowData.vaultCode.hash()).toEqual(storage.vaultCode.hash());

    expect(version.major).toEqual(3);
    expect(version.minor).toEqual(1);
    expect(version.development).toEqual("beta.3");

    expect(contract.getItemAddress(positionStorage.quoteId)).toEqual(address(POSITION_ADDRESS));
    expect(
        contract.getVaultAddress(positionStorage.bidJettonWallet, positionOrder.bidFromUser),
    ).toEqual(
        address(DERIVED_VAULT_ADDRESS),
    );

    println("STONFI_ESCROW_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
