import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/subscription_v2.types"
import "../wrappers/SubscriptionV2.gen"

const CODE_FIXTURE_BOC_PATH = "data/subscriptions/testdata/SubscriptionV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x48942963827c5147fe935cd22e88ba418011fe656eab78b79c5c6343d84d421a
const PINNED_MAINNET_BLOCK = 71629580

const MAINNET_SUBSCRIPTION_V2_ADDRESS = "EQCPpDopkQKPVHTlTDgbIjyFfCU8k9_yuHT_-8osbMGcnDfC"

struct LoadedSubscriptionV2Storage {
    data: cell
    storage: SubscriptionV2Storage
}

fun mainnetSubscriptionV2(): SubscriptionV2 {
    return SubscriptionV2.fromAddress(address(MAINNET_SUBSCRIPTION_V2_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadSubscriptionV2StorageFromFork(contract: SubscriptionV2): LoadedSubscriptionV2Storage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("SubscriptionV2", CODE_FIXTURE_BOC_PATH).hash());
            val storage = SubscriptionV2Storage.fromCell(data!);
            expect(storage.toCell().hash()).toEqual(data!.hash());
            return LoadedSubscriptionV2Storage {
                data: data!,
                storage,
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Subscription V2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Subscription V2 mainnet fixture account is frozen");
        }
    }
}

fun expectSubscriptionInfoMatchesStorage(
    info: SubscriptionV2SubscriptionInfoReply,
    storage: SubscriptionV2Storage,
): void {
    val withdrawInfo = storage.withdrawInfo.load();

    expect(info.wallet).toEqual(storage.wallet);
    expect(info.walletVersion).toEqual(storage.walletVersion);
    expect(info.beneficiary).toEqual(storage.beneficiary);
    expect(info.subscriptionId).toEqual(storage.subscriptionId);
    expect(info.withdrawAddress).toEqual(withdrawInfo.withdrawAddress!);
    expect(info.withdrawMsgBody.hash()).toEqual(withdrawInfo.withdrawMsgBody.hash());
    expect(info.metadata.hash()).toEqual(storage.metadata.hash());
}

fun expectPaymentInfoMatchesStorage(
    payment: SubscriptionV2PaymentInfoReply,
    storage: SubscriptionV2Storage,
): void {
    expect(payment.subscriptionState).toEqual(storage.subscriptionState);
    expect(payment.paymentPerPeriod).toEqual(storage.paymentPerPeriod);
    expect(payment.period).toEqual(storage.period);
    expect(payment.chargeDate).toEqual(storage.chargeDate);
    expect(payment.gracePeriod).toEqual(storage.gracePeriod);
    expect(payment.lastRequestTime).toEqual(storage.lastRequestTime);
    expect(payment.callerFee).toEqual(storage.callerFee);
}

get fun `test subscription v2 code fixture is exact compiled boc`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("SubscriptionV2", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test subscription v2 mainnet storage and getters`() {
    val contract = mainnetSubscriptionV2();
    val loaded = loadSubscriptionV2StorageFromFork(contract);
    val storage = loaded.storage;
    val subscriptionInfo = contract.getSubscriptionInfo();
    val paymentInfo = contract.getPaymentInfo();
    val reservedAmount = contract.getReservedAmount();
    val cronInfo = contract.getCronInfo();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.subscriptionState).toEqual(1);
    expect(storage.paymentPerPeriod).toEqual(6990000000);
    expect(storage.period).toEqual(2592000);
    expect(storage.gracePeriod).toEqual(259200);
    expect(storage.callerFee).toEqual(0);
    expect(storage.rewardAddress).toBeNull();
    expect(storage.lastRequestTime).toEqual(0);
    expect(storage.chargeDate).toBeGreater(0);
    expect(contract.getIsSubscriptionActive()).toBeTrue();
    expect(reservedAmount).toBeGreater(storage.callerFee);
    expect(cronInfo.reward).toEqual(storage.callerFee);
    expect(cronInfo.repeatEvery).toEqual(storage.period);
    expect(cronInfo.nextCallTime).toEqual(storage.chargeDate);

    expectSubscriptionInfoMatchesStorage(subscriptionInfo, storage);
    expectPaymentInfoMatchesStorage(paymentInfo, storage);

    println("SUBSCRIPTION_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("SUBSCRIPTION_V2_MAINNET_ADDRESS={}", contract.address);
    println("SUBSCRIPTION_V2_STORAGE={}", storage);
    println("SUBSCRIPTION_V2_PAYMENT_INFO={}", paymentInfo);
    println("SUBSCRIPTION_V2_CRON_INFO={}", cronInfo);
}
