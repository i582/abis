import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/payment_channel.types"
import "../wrappers/AsyncPaymentChannel.gen"

const PAYMENT_CHANNEL_MAINNET_ADDRESS = "EQA4Ntk6B2Sq-LbHoZ-11FFgr43o3dk5hS3w5G3OkOzHhQEG"
const PAYMENT_CHANNEL_CODE_BOC = "data/payment_channels/async/testdata/AsyncPaymentChannel.boc"
const PAYMENT_CHANNEL_CODE_HASH = 0x41f5b77f02d4a96eb465197215ed00923720a6c731fa32934f9c0e80ffb85589
const PAYMENT_CHANNEL_DATA_HASH = 0xf3f4ae36eecc9a939686bba83f36fdbd9b499eca64f5857dac3a249e304f55a0
const PINNED_MAINNET_BLOCK = 58429533

fun mainnetPaymentChannel(): AsyncPaymentChannel {
    return AsyncPaymentChannel.fromAddress(address(PAYMENT_CHANNEL_MAINNET_ADDRESS));
}

fun loadPaymentChannelStorage(channel: AsyncPaymentChannel): AsyncPaymentChannelStorage {
    val account = testing.getAccountState(channel.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(PAYMENT_CHANNEL_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("AsyncPaymentChannel", PAYMENT_CHANNEL_CODE_BOC).hash(),
            );
            expect(data!.hash()).toEqual(PAYMENT_CHANNEL_DATA_HASH);
            return AsyncPaymentChannelStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Expected active payment channel account, got uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Expected active payment channel account, got frozen");
        }
    }
}

get fun `test payment channel mainnet storage and getters`() {
    val channel = mainnetPaymentChannel();
    val storage = loadPaymentChannelStorage(channel);
    val channelState = channel.getChannelState();
    val data = channel.getChannelData();

    expect(scripts.isContractDeployed(channel.address)).toBeTrue();
    expect(channelState).toEqual(0);
    expect(data.get(0) as int).toEqual(channelState);
    val balances = data.get(1) as tuple;
    val keys = data.get(2) as tuple;
    val closingConfigReply = data.get(4) as tuple;
    val committedSeqnos = data.get(5) as tuple;
    val paymentConfigReply = data.get(7) as tuple;

    expect(balances.get(0) as int).toEqual(storage.balanceA);
    expect(balances.get(1) as int).toEqual(storage.balanceB);
    expect(keys.get(0) as int).toEqual(storage.keyA);
    expect(keys.get(1) as int).toEqual(storage.keyB);
    expect(data.get(3) as int).toEqual(storage.channelId);
    expect(committedSeqnos.get(0) as int).toEqual(storage.committedSeqnoA);
    expect(committedSeqnos.get(1) as int).toEqual(storage.committedSeqnoB);
    val closingConfig = AsyncPaymentChannelClosingConfig.fromCell(storage.closingConfig);
    expect(closingConfigReply.get(0) as int).toEqual(closingConfig.quarantineDuration);
    expect(closingConfigReply.get(1) as int).toEqual(closingConfig.misbehaviorFine);
    expect(closingConfigReply.get(2) as int).toEqual(
        closingConfig.conditionalCloseDuration,
    );

    val paymentConfig = AsyncPaymentChannelPaymentConfig.fromCell(storage.paymentConfig);
    expect(paymentConfigReply.get(0) as int).toEqual(paymentConfig.excessFee);
    var destinationA = paymentConfigReply.get(1) as slice;
    var destinationB = paymentConfigReply.get(2) as slice;
    expect(destinationA.loadAddress()).toEqual(paymentConfig.destinationA.castToInternal());
    expect(destinationB.loadAddress()).toEqual(paymentConfig.destinationB.castToInternal());

    println("PAYMENT_CHANNEL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("PAYMENT_CHANNEL_MAINNET_STORAGE={}", storage);
    println("PAYMENT_CHANNEL_MAINNET_GET_DATA={}", data);
}
