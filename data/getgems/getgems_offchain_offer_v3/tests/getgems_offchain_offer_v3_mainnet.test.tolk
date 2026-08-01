import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_offchain_offer_v3.types"
import "../wrappers/GetgemsOffchainOfferV3.gen"

const TOLK_100_ADDRESS = "EQAGdZASbt82oe8iSb76Thv89EeH12Ja8tsCC6vicCxrJXWt"
const TOLK_130_ADDRESS = "EQAGGhOkRVO4F-pn9Yojfs68cz1OueV5CzUChx4HrGEyv70L"
const TOLK_100_CODE_HASH = 0x0285e0ba8e03b38a80a5baf9198ad840510ac835af1e3bfe2ceac7eceba592c5
const TOLK_100_DATA_HASH = 0xab9ddf6735f3f525a305c8c19a4d5455453d3c08400b457e335847d1e7ddf586
const TOLK_130_CODE_HASH = 0xf0449dca7dd58b13607508839087668196aaef2c7df9ef5fe5b73e0a9177255e
const TOLK_130_DATA_HASH = 0x5be269bbb792a336f138407687804e2ba4972b86fdbd59cce4862c1aeb2e3456

struct LoadedOffchainOfferV3 {
    code: cell
    storage: GetgemsOffchainOfferV3Storage
}

fun loadOffer(
    address: address,
    expectedCodeHash: uint256,
    expectedDataHash: uint256,
): LoadedOffchainOfferV3 {
    val account = testing.getAccountState(address);
    expect(account).toBeNotNull();
    val accountInfo = account!;
    val accountState = accountInfo.storage.state;

    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(expectedCodeHash);
            expect(data!.hash()).toEqual(expectedDataHash);
            return LoadedOffchainOfferV3 {
                code: code!,
                storage: GetgemsOffchainOfferV3Storage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems Offchain Offer V3 account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems Offchain Offer V3 account is frozen");
        }
    }
}

fun expectGetterMatchesStorage(
    contract: GetgemsOffchainOfferV3,
    loaded: LoadedOffchainOfferV3,
): void {
    val storage = loaded.storage;
    val fees = storage.fees.load();
    val staticData = storage.staticData.load();
    val data = contract.getOffchainOfferV2();

    expect(data.isComplete).toEqual(storage.lastCleaned == 0 ? true : storage.isComplete);
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.createdAt).toEqual(staticData.createdAt);
    expect(data.finishAt).toEqual(storage.finishAt);
    expect(data.publicKey).toEqual(storage.publicKey);
    expect(data.nftPrice).toEqual(storage.nftPrice);
    expect(data.maxCount).toEqual(storage.maxCount);
    expect(data.boughtCount).toEqual(storage.boughtCount);
    expect(data.marketplaceAddress).toEqual(fees.marketplaceAddress);
    expect(data.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(data.royaltyAddress).toEqual(fees.royaltyAddress);
    expect(data.feeFactor).toEqual(fees.feeFactor);
    expect(data.feeBase).toEqual(fees.feeBase);
    expect(data.royaltyFactor).toEqual(fees.royaltyFactor);
    expect(data.royaltyBase).toEqual(fees.royaltyBase);

    match (staticData.target) {
        GetgemsOffchainOfferV3CollectionTarget => {
            expect(data.collectionAddress).toEqual(staticData.target.collectionAddress);
            expect(data.nftAddress).toBeNull();
            expect(data.attributes.hash()).toEqual(staticData.target.attributes.hash());
        }
        GetgemsOffchainOfferV3NftTarget => {
            expect(data.collectionAddress).toBeNull();
            expect(data.nftAddress).toEqual(staticData.target.nftAddress);
            expect(data.attributes.beginParse().remainingBitsCount()).toEqual(0);
            expect(data.attributes.beginParse().remainingRefsCount()).toEqual(0);
        }
    }
}

get fun `test offchain offer v3 Tolk 1.0.0 pinned mainnet storage and getter`() {
    val contract = GetgemsOffchainOfferV3.fromAddress(address(TOLK_100_ADDRESS));
    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expectGetterMatchesStorage(
        contract,
        loadOffer(contract.address, TOLK_100_CODE_HASH, TOLK_100_DATA_HASH),
    );
}

get fun `test offchain offer v3 Tolk 1.3.0 pinned mainnet storage and getter`() {
    val contract = GetgemsOffchainOfferV3.fromAddress(address(TOLK_130_ADDRESS));
    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expectGetterMatchesStorage(
        contract,
        loadOffer(contract.address, TOLK_130_CODE_HASH, TOLK_130_DATA_HASH),
    );
}
