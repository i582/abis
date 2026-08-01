import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_escrow_position.types"
import "../wrappers/StonfiEscrowPosition.gen"

const FIXTURE_BOC_PATH = "data/stonfi/escrow_position/testdata/StonfiEscrowPosition.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xaab1db63f193a4aecaa3e3a959fc1784f1412b191a66ae870958405ba88114c7
const EXPECTED_DATA_HASH = 0xd38d7a560e30bb93b93069967357031155203ee4cb684c67c0bad58344737dc0
const PINNED_MAINNET_BLOCK = 71167154
const POSITION_ADDRESS = "EQAaKWRLpempuPro_iWQLxVMBOmy7xE-wB_THkpF0J9-0bKf"
const EXPECTED_MINTER = "0:3349DDD903D5FF139DF8F3F471855A86858DE47CDE9F992D108BE5C58216E926"
const EXPECTED_BID_JETTON_WALLET = "0:9A64808DCF6F904D948A3925A1B7E303B9545BDAC4FD5C48DB4789445C8A0211"
const EXPECTED_BID_FROM_USER = "0:94F68B3F6368F2C3F0AF743197A41A1F38D2D40FD63ECF28D925E3664EF5A662"
const EXPECTED_ASK_JETTON_WALLET = "0:7263BF71DA4163834415F19F0F93D0864EA3F1F39E4B883D5CC91DD10CFD6F88"

fun position(): StonfiEscrowPosition {
    return StonfiEscrowPosition.fromAddress(address(POSITION_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStorageFromFork(contract: StonfiEscrowPosition): StonfiEscrowPositionStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiEscrowPosition", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return StonfiEscrowPositionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Escrow Position account is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Escrow Position account is frozen at the pinned block");
        }
    }
}

get fun `test stonfi escrow position code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("StonfiEscrowPosition", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi escrow position parses pinned storage and getter`() {
    val contract = position();
    val storage = loadStorageFromFork(contract);
    val order = StonfiEscrowPositionOrder.fromCell(storage.order);
    val details = StonfiEscrowPositionOrderDetails.fromCell(order.details);
    val getter = contract.getOrderData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.status).toEqual(3);
    expect(storage.minter).toEqual(address(EXPECTED_MINTER));
    expect(storage.bidJettonWallet).toEqual(address(EXPECTED_BID_JETTON_WALLET));
    expect(storage.bidJettonAmount).toEqual(0);
    expect(storage.userUnlockForward).toBeNull();
    expect(order.bidFromUser).toEqual(address(EXPECTED_BID_FROM_USER));
    expect(order.refFeeTier).toEqual(50);
    expect(details.askJettonWallet).toEqual(address(EXPECTED_ASK_JETTON_WALLET));
    expect(details.ownerPublicKey).toBeNull();
    expect(details.pendingUserReceiveAmount).toEqual(0);
    expect(details.safeDepositAndForwardValue).toEqual(0);
    expect(details.excessesReceiver).toEqual(address(EXPECTED_BID_FROM_USER));

    expect(getter.status).toEqual(storage.status);
    expect(getter.quoteId).toEqual(storage.quoteId);
    expect(getter.minter).toEqual(storage.minter);
    expect(getter.bidJettonWallet).toEqual(storage.bidJettonWallet);
    expect(getter.bidJettonAmount).toEqual(storage.bidJettonAmount);
    expect(getter.bidFromUser).toEqual(order.bidFromUser);
    expect(getter.refFee).toEqual(order.refFee);
    expect(getter.refFeeTier).toEqual(order.refFeeTier);
    expect(getter.pendingUserReceiveAmount).toEqual(details.pendingUserReceiveAmount);
    expect(getter.askJettonWallet).toEqual(details.askJettonWallet);
    expect(getter.askJettonMinter).toEqual(order.askJettonMinter);
    expect(getter.conditionState.hash()).toEqual(storage.conditionState.hash());
    expect(getter.conditionCode.hash()).toEqual(storage.conditionCode.hash());
    expect(getter.userUnlockForwardParams).toBeNull();
    expect(getter.userUnlockForwardSuccessPayload).toBeNull();
    expect(getter.userFillToVault).toEqual(order.userFillToVault);
    expect(getter.safeDepositAndForwardValue).toEqual(details.safeDepositAndForwardValue);
    expect(getter.excessesReceiver).toEqual(details.excessesReceiver);

    println("STONFI_ESCROW_POSITION_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
