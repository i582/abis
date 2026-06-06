import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_referral.types"
import "../wrappers/StormReferral.gen"

const PINNED_MAINNET_BLOCK = 71588122
const MAINNET_REFERRAL_ADDRESS = "EQDxf_sZ36mzlSCO0nvgAGVno8hUQ8BY5NBq7iVxxlIH9DdY"
const MAINNET_REFERRAL_COLLECTION_ADDRESS = "EQBQwk4uEjMlB54tkmVIuDQZSZivN3AT8ozcoa2ELqf2Im6U"
const EXPECTED_REFERRAL_CODE_HASH =
    0x7e0385a57658333b65697a2caef5d781ad040e89dd5b22b8e9977cdd96730211

fun mainnetStormReferral(): StormReferral {
    return StormReferral.fromAddress(address(MAINNET_REFERRAL_ADDRESS));
}

fun loadStormReferralStorageFromFork(referral: StormReferral): StormReferralStorage {
    val account = testing.getAccountState(referral.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_REFERRAL_CODE_HASH);
            return StormReferralStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm referral item account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm referral item account is frozen");
        }
    }
}

get fun `test storm referral item mainnet storage and getters`() {
    val referral = mainnetStormReferral();
    val storage = loadStormReferralStorageFromFork(referral);
    val parameters = storage.parameters.load();
    val nftData = referral.getNftData();
    val referralData = referral.getReferralData();

    expect(scripts.isContractDeployed(referral.address)).toBeTrue();
    expect(storage.collectionAddress).toEqual(address(MAINNET_REFERRAL_COLLECTION_ADDRESS));
    expect(nftData.isInitialized).toBeTrue();
    expect(nftData.itemIndex).toEqual(storage.itemIndex as int);
    expect(nftData.collectionAddress).toEqual(storage.collectionAddress);
    expect(nftData.ownerAddress).toBeNotNull();
    expect(nftData.ownerAddress!).toEqual(storage.ownerAddress);
    expect(nftData.content).toBeNotNull();
    expect(nftData.content!.hash()).toEqual(createEmptyCell().hash());
    expect(referralData.referralType).toEqual(storage.referralType as int);
    expect(referralData.discount).toEqual(parameters.discount);
    expect(referralData.rebate).toEqual(parameters.rebate);
    expect(referralData.balancesDict).toEqual(storage.balancesDict);

    println("STORM_REFERRAL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_REFERRAL_ADDRESS={}", referral.address);
    println("STORM_REFERRAL_STORAGE={}", storage);
    println("STORM_REFERRAL_NFT_DATA={}", nftData);
    println("STORM_REFERRAL_DATA={}", referralData);
}
