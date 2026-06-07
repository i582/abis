import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/subscription_v2.types"
import "../wrappers/SubscriptionV2.gen"

const FIXTURE_BOC_PATH = "data/subscriptions/testdata/SubscriptionV2.boc"
const DATA_FIXTURE_BOC_PATH = "data/subscriptions/testdata/SubscriptionV2.data.boc"
const LIVE_DATA_BOC = "te6ccgECDAEAAiYAA70AAAAANSX+TkAAfpABACp9YK4+eu2Fy2kafPbAy+etF14vDbm9h3MkOhjhQSuRDOABF5QKyPfyZE8ZrPPdEtjG+7D6dbgpn18jwfNi3Q2Eh/rF04ZKgNBRd8AAE8aAQAECAwEHMK0YmAQBQ4AWLUDDDBk+cTqd6D+/tU8il4Eiz7c+pu9r1SuKCdrtbvAJAUgBjkYLXcusnvRl4PNzaEgiTFZW19wacVt9rdQd7DFsanBjQHoKAgoOw8htAAkFAWZiAFT6wVx89dsLltI0+e2Bl89aLrxeG3N7DuZIdDHCglciGFaMSAAAAAAAAAAAAAAAAAEGARlleHRuAAAAAAAAAACgBwIKDsPIbUIJCACCYgAJicavrdSz7YUIO9IIf0EFne9klxKlxm24n5+OBTLxVSgNBRd8AAAAAAAAAAAAAAAAAADwbHVnAAAAAAAAAAAAAAH+625PWVm4O0ROFLEdJ+6AgyrAScl4iL0THgmUuPQvhPJoikwr5/tNXjnbObLT882SbJTxnyYau06kGklryPbYYxBB/on9hmuymY7fTE54d0InkyYRk82RGh/woYnidWRp6u5o9ApVdme66VEagUXwHsB/bDwHQfnRwhVwoX3oTQsAnGqnoHZnCXu0CD7XEbRVPPNcGOdK+RAdYVUk3W6iGb6WSr/dp5k4XeUYzzmI7cU6PEBiGIOS53dp+IzkmWze/ii4bKv66ynS2vSiDXoftA=="

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x48942963827c5147fe935cd22e88ba418011fe656eab78b79c5c6343d84d421a
const EXPECTED_DATA_HASH = 0x169bbcfb0e3547797ccb102c612892f455998bb3ea721cc541716add9f836234
const PINNED_MAINNET_BLOCK = 71819864

const MAINNET_SUBSCRIPTION_ADDRESS = "EQATE41fW6ln2woQd6QQ_oILO97JLiVLjNtxPz8cCmXiqglY"

struct LoadedSubscriptionV2Storage {
    data: cell
    storage: SubscriptionV2Storage
}

fun mainnetSubscriptionV2(): SubscriptionV2 {
    return SubscriptionV2.fromAddress(address(MAINNET_SUBSCRIPTION_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDataCell(): cell {
    return parseCellFromBase64(LIVE_DATA_BOC);
}

fun loadSubscriptionStorageFromFork(subscription: SubscriptionV2): LoadedSubscriptionV2Storage {
    val account = testing.getAccountState(subscription.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("SubscriptionV2", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedSubscriptionV2Storage {
                data: data!,
                storage: SubscriptionV2Storage.fromCell(data!),
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

fun expectGettersMatchStorage(
    subscription: SubscriptionV2,
    loaded: LoadedSubscriptionV2Storage,
): void {
    val storage = loaded.storage;
    val withdrawInfo = storage.withdrawInfo.load();
    val subscriptionInfo = subscription.getSubscriptionInfo();
    val paymentInfo = subscription.getPaymentInfo();
    val cronInfo = subscription.getCronInfo();
    val reservedAmount = subscription.getReservedAmount();
    val isActive = subscription.getIsSubscriptionActive();

    expect(scripts.isContractDeployed(subscription.address)).toBeTrue();
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());

    expect(subscriptionInfo.wallet).toEqual(storage.wallet);
    expect(subscriptionInfo.walletVersion).toEqual(storage.walletVersion);
    expect(subscriptionInfo.beneficiary).toEqual(storage.beneficiary);
    expect(subscriptionInfo.subscriptionId).toEqual(storage.subscriptionId);
    expect(subscriptionInfo.withdrawAddress).toEqual(withdrawInfo.withdrawAddress);
    expect(subscriptionInfo.withdrawMsgBody.hash()).toEqual(withdrawInfo.withdrawMsgBody.hash());
    expect(subscriptionInfo.metadata.hash()).toEqual(storage.metadata.hash());

    expect(paymentInfo.subscriptionState).toEqual(storage.subscriptionState);
    expect(paymentInfo.paymentPerPeriod).toEqual(storage.paymentPerPeriod);
    expect(paymentInfo.period).toEqual(storage.period);
    expect(paymentInfo.chargeDate).toEqual(storage.chargeDate);
    expect(paymentInfo.gracePeriod).toEqual(storage.gracePeriod);
    expect(paymentInfo.lastRequestTime).toEqual(storage.lastRequestTime);
    expect(paymentInfo.callerFee).toEqual(storage.callerFee);

    expect(cronInfo.reward).toEqual(storage.callerFee);
    expect(cronInfo.repeatEvery).toEqual(storage.period);
    expect(isActive).toBeFalse();
    expect(reservedAmount).toBeGreater(0);
}

get fun `test subscription v2 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("SubscriptionV2", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test subscription v2 saved data fixture parses storage`() {
    val data = savedDataCell();
    val storage = SubscriptionV2Storage.fromCell(data);
    val withdrawInfo = storage.withdrawInfo.load();
    val precompiled = storage.precompiled.load();

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.subscriptionState).toEqual(2);
    expect(storage.walletVersion).toEqual(51);
    expect(storage.paymentPerPeriod).toEqual(6990000000);
    expect(storage.period).toEqual(2592000);
    expect(storage.gracePeriod).toEqual(259200);
    expect(storage.callerFee).toEqual(0);
    expect(withdrawInfo.withdrawAddress.getWorkchain()).toEqual(0);
    expect(withdrawInfo.withdrawMsgBody.beginParse().remainingBitsCount()).toEqual(0);
    expect(withdrawInfo.withdrawMsgBody.beginParse().remainingRefsCount()).toEqual(0);
    expect(precompiled.forwardAmount).toBeGreater(0);
    expect(precompiled.requestPaymentC5.hash()).toBeGreater(0);

    println("SUBSCRIPTION_V2_STORAGE_FIXTURE={}", storage);
}

get fun `test subscription v2 mainnet storage and getters`() {
    val subscription = mainnetSubscriptionV2();
    val loaded = loadSubscriptionStorageFromFork(subscription);

    expectGettersMatchStorage(subscription, loaded);

    println("SUBSCRIPTION_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("SUBSCRIPTION_V2_MAINNET_ADDRESS={}", subscription.address);
    println("SUBSCRIPTION_V2_DATA_HASH={}", loaded.data.hash());
    println("SUBSCRIPTION_V2_STORAGE={}", loaded.storage);
    println("SUBSCRIPTION_V2_SUBSCRIPTION_INFO={}", subscription.getSubscriptionInfo());
    println("SUBSCRIPTION_V2_PAYMENT_INFO={}", subscription.getPaymentInfo());
    println("SUBSCRIPTION_V2_CRON_INFO={}", subscription.getCronInfo());
}
