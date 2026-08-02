import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_farm_collection.types"
import "../wrappers/StonfiFarmCollection.gen"

const FIXTURE_BOC_PATH = "data/stonfi/farm_collection/testdata/StonfiFarmCollection.boc"
const FARM_NFT_FIXTURE_BOC_PATH = "data/stonfi/farm_nft/testdata/StonfiFarmNft.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9b94ca12bff3dee0201ec84d859c56a2b1078fb4aa559df679dce35a9e02ee6c
const EXPECTED_DATA_HASH = 0x7f0aa5b5ebe09ca484ad7c224770f202b2f1a71a60fe2dfd22e652cb1fb00488
const EXPECTED_FARM_NFT_CODE_HASH = 0x752c43866175a1f972799ed0c7a3e469f337a0b58c6cf43f82807998b1fc7329
const EXPECTED_COLLECTION_CONTENT_HASH = 0xc02b15e639151211b38f43491232e00e63233122ba8e5060d3d85fbdb428d510
const PINNED_MAINNET_BLOCK = 41537629
const FARM_COLLECTION_ADDRESS = "EQDZsV30R-YiBeZ-NyITRQW4-VtQBJlBN7OoyDvmdPD-f2Mh"
const EXPECTED_STAKING_TOKEN_WALLET = "0:94B74ED9E2247B8C84EBFCC75195BA5AA8E72BC274800C16849FD3A850680AC5"
const EXPECTED_CUSTODIAN = "0:9AAE24E8B91A2AC5EA81F6B56C5E548AE4C2F55D05BE40DC73CE3E155E2425F5"

fun farmCollection(): StonfiFarmCollection {
    return StonfiFarmCollection.fromAddress(address(FARM_COLLECTION_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStorageFromFork(contract: StonfiFarmCollection): StonfiFarmCollectionStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiFarmCollection", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return StonfiFarmCollectionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Farm Collection is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Farm Collection is frozen at the pinned block");
        }
    }
}

get fun `test stonfi farm collection code fixture matches pinned mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("StonfiFarmCollection", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi farm collection parses pinned storage and getters`() {
    val contract = farmCollection();
    val storage = loadStorageFromFork(contract);
    val staticData = StonfiFarmCollectionStaticData.fromCell(storage.collectionData);
    val pendingData = StonfiFarmCollectionPendingData.fromCell(storage.pendingData);
    val farmingData = contract.getFarmingMinterData();
    val version = contract.getVersion();
    val collectionData = contract.getCollectionData();
    val pendingDataReply = contract.getPendingData();
    val nftItemCode = contract.getNftItemCode();
    val itemAddress = contract.getNftAddressByIndex(13);
    val nftContent = contract.getNftContent(13, createEmptyCell());

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.contractUniqueId).toEqual(1183670627);
    expect(storage.poolCount).toEqual(4);
    expect(storage.status).toEqual(1);
    expect(storage.nextItemIndex).toEqual(456);
    expect(storage.minStakeTime).toEqual(2419200);
    expect(storage.currentStakedTokens).toEqual(222741488197587);
    expect(storage.canUpgradeCode).toBeTrue();
    expect(storage.canSendRawMsg).toBeTrue();
    expect(storage.stakingTokenWallet).toEqual(address(EXPECTED_STAKING_TOKEN_WALLET));
    expect(storage.canChangeCustodian).toBeTrue();
    expect(storage.custodianAddress).toEqual(address(EXPECTED_CUSTODIAN));
    expect(storage.farmDataAccrued).toHaveLength(4);
    expect(storage.farmDataParameters).toHaveLength(4);
    expect(staticData.nftItemCode.hash()).toEqual(EXPECTED_FARM_NFT_CODE_HASH);
    expect(staticData.nftItemCode.hash()).toEqual(
        build("StonfiFarmNft", FARM_NFT_FIXTURE_BOC_PATH).hash(),
    );
    expect(pendingData.changeCustodianTime).toEqual(0);
    expect(pendingData.sendRawMessageTime).toEqual(0);
    expect(pendingData.codeUpgradeTime).toEqual(0);
    expect(pendingData.newCustodianAddress).toBeNull();

    expect(farmingData.nextItemIndex).toEqual(storage.nextItemIndex);
    expect(farmingData.status).toEqual(storage.status);
    expect(farmingData.poolCount).toEqual(storage.poolCount);
    expect(farmingData.currentStakedTokens).toEqual(storage.currentStakedTokens);
    expect(farmingData.contractUniqueId).toEqual(storage.contractUniqueId);
    expect(farmingData.minStakeTime).toEqual(storage.minStakeTime);
    expect(farmingData.stakingTokenWallet.castToInternal()).toEqual(storage.stakingTokenWallet);
    expect(farmingData.custodianAddress.castToInternal()).toEqual(storage.custodianAddress);
    expect(farmingData.canChangeCustodian).toEqual(storage.canChangeCustodian);
    expect(farmingData.canSendRawMsg).toEqual(storage.canSendRawMsg);
    expect(farmingData.farmDataAccrued).toHaveLength(storage.poolCount);
    expect(farmingData.farmDataParameters).toHaveLength(storage.poolCount);
    expect(farmingData.farmDataAccrued.mustGet(0).hash()).toEqual(
        storage.farmDataAccrued.mustGet(0).hash(),
    );
    expect(farmingData.farmDataParameters.mustGet(0).hash()).toEqual(
        storage.farmDataParameters.mustGet(0).hash(),
    );

    expect(version.major).toEqual(3);
    expect(version.minor).toEqual(1);
    expect(version.development).toEqual("release");

    expect(collectionData.nextItemIndex).toEqual(storage.nextItemIndex);
    expect(collectionData.collectionContent.hash()).toEqual(EXPECTED_COLLECTION_CONTENT_HASH);
    expect(collectionData.ownerAddress.castToInternal()).toEqual(staticData.ownerAddress);
    expect(pendingDataReply.changeCustodianTime).toEqual(pendingData.changeCustodianTime);
    expect(pendingDataReply.sendRawMessageTime).toEqual(pendingData.sendRawMessageTime);
    expect(pendingDataReply.codeUpgradeTime).toEqual(pendingData.codeUpgradeTime);
    expect(pendingDataReply.newCustodianAddress).toBeNoneAddress();
    expect(pendingDataReply.pendingMessage.hash()).toEqual(pendingData.pendingMessage.hash());
    expect(pendingDataReply.newCode.hash()).toEqual(pendingData.newCode.hash());
    expect(pendingDataReply.newStorage.hash()).toEqual(pendingData.newStorage.hash());
    expect(nftItemCode.hash()).toEqual(EXPECTED_FARM_NFT_CODE_HASH);
    expect(itemAddress).toEqual(
        address("0:F8503066893970DEFB46C9EDCCBD90F28DCADC0EFABC74C828C474622FACF2CE"),
    );
    expect(nftContent.beginParse().remainingBitsCount() > 0).toBeTrue();

    println("STONFI_FARM_COLLECTION_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
