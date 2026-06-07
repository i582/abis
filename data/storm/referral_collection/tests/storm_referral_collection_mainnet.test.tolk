import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_referral_collection.types"
import "../wrappers/StormReferralCollection.gen"

const PINNED_MAINNET_BLOCK = 71588122
const MAINNET_REFERRAL_COLLECTION_ADDRESS = "EQBQwk4uEjMlB54tkmVIuDQZSZivN3AT8ozcoa2ELqf2Im6U"
const MAINNET_REFERRAL_ITEM_0_ADDRESS = "EQDxf_sZ36mzlSCO0nvgAGVno8hUQ8BY5NBq7iVxxlIH9DdY"
const EXPECTED_REFERRAL_COLLECTION_CODE_HASH = 0x0fc0943198f1cbd0dc3128ce70db40dd43cc4135ae533f04294c4e5060619c3c

fun mainnetStormReferralCollection(): StormReferralCollection {
    return StormReferralCollection.fromAddress(address(MAINNET_REFERRAL_COLLECTION_ADDRESS));
}

fun loadStormReferralCollectionStorageFromFork(
    collection: StormReferralCollection,
): StormReferralCollectionStorage {
    val account = testing.getAccountState(collection.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_REFERRAL_COLLECTION_CODE_HASH);
            return StormReferralCollectionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm referral collection account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm referral collection account is frozen");
        }
    }
}

fun stormWrappedCollectionMetadata(content: cell): cell {
    return beginCell().storeUint(1, 8).storeSlice(content.beginParse()).endCell();
}

get fun `test storm referral collection mainnet storage and getters`() {
    val collection = mainnetStormReferralCollection();
    val storage = loadStormReferralCollectionStorageFromFork(collection);
    val content = storage.content.load();
    val config = storage.config.load();
    val defaultFees = config.defaultFees.load();
    val royaltyParams = config.royaltyParams.load();
    val collectionData = collection.getCollectionData();
    val getterDefaultFees = collection.getDefaultReferralFees();
    val getterRoyalty = collection.royaltyParams();
    val getterWhitelist = collection.getReferralVaultsWhitelist();
    val item0 = collection.getNftAddressByIndex(0);

    expect(scripts.isContractDeployed(collection.address)).toBeTrue();
    expect(collectionData.nextItemIndex).toEqual(storage.nextReferralIndex as int);
    expect(collectionData.collectionMetadata.hash()).toEqual(
        stormWrappedCollectionMetadata(content.collectionMetadata).hash(),
    );
    expect(collectionData.adminAddress).toEqual(storage.adminAddress);
    expect(getterDefaultFees.discount).toEqual(defaultFees.discount);
    expect(getterDefaultFees.rebate).toEqual(defaultFees.rebate);
    expect(getterRoyalty.numerator).toEqual(royaltyParams.numerator);
    expect(getterRoyalty.denominator).toEqual(royaltyParams.denominator);
    expect(getterRoyalty.royaltyAddress).toEqual(royaltyParams.royaltyAddress);
    expect(getterWhitelist).toEqual(storage.vaultsWhitelist);
    expect(item0).toEqual(address(MAINNET_REFERRAL_ITEM_0_ADDRESS));

    println("STORM_REFERRAL_COLLECTION_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_REFERRAL_COLLECTION_ADDRESS={}", collection.address);
    println("STORM_REFERRAL_COLLECTION_STORAGE={}", storage);
    println("STORM_REFERRAL_COLLECTION_DATA={}", collectionData);
    println("STORM_REFERRAL_COLLECTION_DEFAULT_FEES={}", getterDefaultFees);
    println("STORM_REFERRAL_COLLECTION_ITEM_0={}", item0);
}
