import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "@acton/testing/assert"
import "@acton/types/transaction"
import "../types/subscription_v1.types"
import "../wrappers/SubscriptionV1.gen"

const CODE_FIXTURE_BOC_PATH = "data/subscriptions/testdata/SubscriptionV1.boc"
const DATA_FIXTURE_BOC_PATH = "data/subscriptions/testdata/SubscriptionV1.data.boc"
const LIVE_DATA_BOC =
    "te6ccgEBAQEAYwAAwYAFp5h9Ay5Oc3Wd9TyLhXRGcBLXiNJCVOmNJh8B0EfMEBADYSZBaCuRRKjT4FmgYDMgfrO+MQonM3FOeljPHw9sQwUdzWUAAAAASxhvfUoAAAqMGG9+NlhvfjZAAAAANCA="

const MAINNET_SUBSCRIPTION_V1_ADDRESS = "EQCYmewN6-iZF_R-g4f-AyRt3RMSEPDAT8wvKgKSMqihei2s"
const EXPECTED_WALLET_ADDRESS = "EQAtPMPoGXJzm6zvqeRcK6IzgJa8RpISp0xpMPgOgj5ggPtQ"
const EXPECTED_BENEFICIARY_ADDRESS = "EQDYSZBaCuRRKjT4FmgYDMgfrO-MQonM3FOeljPHw9sQwYlE"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x52161446bb3e6f811f3ceb163c8be33710fe41086c3a047ee928c2d94743fc2d
const EXPECTED_DATA_HASH = 0xc31807e21cfc9facd1a263e29a713973741f2c0526ad25b1e0a0a2e4e2a84e1d
const EXPECTED_WALLET_HASH = 0x2d3cc3e81972739bacefa9e45c2ba2338096bc469212a74c6930f80e823e6080
const EXPECTED_BENEFICIARY_HASH = 0xd849905a0ae4512a34f81668180cc81facef8c4289ccdc539e9633c7c3db10c1
const EXPECTED_AMOUNT = 2000000000
const EXPECTED_PERIOD = 300
const EXPECTED_START_TIME = 1639839016
const EXPECTED_TIMEOUT = 10800
const EXPECTED_LAST_PAYMENT_TIME = 1639839961
const EXPECTED_LAST_REQUEST_TIME = 1639839961
const EXPECTED_FAILED_ATTEMPTS = 0
const EXPECTED_SUBSCRIPTION_ID = 208
const PINNED_MAINNET_BLOCK = 16895880

struct LoadedSubscriptionV1Storage {
    data: cell
    storage: SubscriptionV1Storage
}

fun mainnetSubscriptionV1(): SubscriptionV1 {
    return SubscriptionV1.fromAddress(address(MAINNET_SUBSCRIPTION_V1_ADDRESS));
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

fun expectStorageMatchesFixture(storage: SubscriptionV1Storage): void {
    expect(storage.wallet).toEqual(address(EXPECTED_WALLET_ADDRESS));
    expect(storage.beneficiary).toEqual(address(EXPECTED_BENEFICIARY_ADDRESS));
    expect(storage.amount).toEqual(EXPECTED_AMOUNT);
    expect(storage.period).toEqual(EXPECTED_PERIOD);
    expect(storage.startTime).toEqual(EXPECTED_START_TIME);
    expect(storage.timeout).toEqual(EXPECTED_TIMEOUT);
    expect(storage.lastPaymentTime).toEqual(EXPECTED_LAST_PAYMENT_TIME);
    expect(storage.lastRequestTime).toEqual(EXPECTED_LAST_REQUEST_TIME);
    expect(storage.failedAttempts).toEqual(EXPECTED_FAILED_ATTEMPTS);
    expect(storage.subscriptionId).toEqual(EXPECTED_SUBSCRIPTION_ID);
}

fun loadSubscriptionV1StorageFromFork(subscription: SubscriptionV1): LoadedSubscriptionV1Storage {
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
            expect(code!.hash()).toEqual(build("SubscriptionV1", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedSubscriptionV1Storage {
                data: data!,
                storage: SubscriptionV1Storage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Subscription V1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Subscription V1 mainnet fixture account is frozen");
        }
    }
}

fun expectGetterMatchesStorage(subscription: SubscriptionV1, storage: SubscriptionV1Storage): void {
    val data = subscription.getSubscriptionData();
    val [walletWorkchain, walletHash] = data.wallet;
    val [beneficiaryWorkchain, beneficiaryHash] = data.beneficiary;

    expect(walletWorkchain).toEqual(storage.wallet.getWorkchain());
    expect(walletHash).toEqual(EXPECTED_WALLET_HASH);
    expect(beneficiaryWorkchain).toEqual(storage.beneficiary.getWorkchain());
    expect(beneficiaryHash).toEqual(EXPECTED_BENEFICIARY_HASH);
    expect(data.amount).toEqual(storage.amount);
    expect(data.period).toEqual(storage.period);
    expect(data.startTime).toEqual(storage.startTime);
    expect(data.timeout).toEqual(storage.timeout);
    expect(data.lastPaymentTime).toEqual(storage.lastPaymentTime);
    expect(data.lastRequestTime).toEqual(storage.lastRequestTime);
    expect(data.failedAttempts).toEqual(storage.failedAttempts);
    expect(data.subscriptionId).toEqual(storage.subscriptionId);
}

get fun `test subscription v1 code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("SubscriptionV1", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test subscription v1 saved data fixture parses storage`() {
    val data = savedDataCell();
    val storage = SubscriptionV1Storage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expectStorageMatchesFixture(storage);

    println("SUBSCRIPTION_V1_STORAGE_FIXTURE={}", storage);
}

get fun `test subscription v1 mainnet storage and getter`() {
    val subscription = mainnetSubscriptionV1();
    val loaded = loadSubscriptionV1StorageFromFork(subscription);

    expect(scripts.isContractDeployed(subscription.address)).toBeTrue();
    expect(loaded.storage.toCell().hash()).toEqual(loaded.data.hash());
    expectStorageMatchesFixture(loaded.storage);
    expectGetterMatchesStorage(subscription, loaded.storage);

    println("SUBSCRIPTION_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("SUBSCRIPTION_V1_MAINNET_ADDRESS={}", subscription.address);
    println("SUBSCRIPTION_V1_DATA_HASH={}", loaded.data.hash());
    println("SUBSCRIPTION_V1_STORAGE={}", loaded.storage);
    println("SUBSCRIPTION_V1_GETTER={}", subscription.getSubscriptionData());
}
