import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_farm_nft.types"
import "../wrappers/StonfiFarmNft.gen"

const FIXTURE_BOC_PATH = "data/stonfi/farm_nft/testdata/StonfiFarmNft.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x752c43866175a1f972799ed0c7a3e469f337a0b58c6cf43f82807998b1fc7329
const EXPECTED_DATA_HASH = 0xae3c4d3ce68acd36a419ffcf1d8a7c9fb171533669dd8b69880525d10c84d87f
const PINNED_MAINNET_BLOCK = 41537629
const FARM_NFT_ADDRESS = "EQD4UDBmiTlw3vtGye3MvZDyjcrcDvq8dMgoxHRiL6zyzrMz"
const EXPECTED_OWNER = "0:CC42B7401EB514584287F61E92B3A91FE96D6289239550C68D3B83D87B9DE52E"
const EXPECTED_COLLECTION = "0:D9B15DF447E62205E67E3722134505B8F95B5004994137B3A8C83BE674F0FE7F"

fun farmNft(): StonfiFarmNft {
    return StonfiFarmNft.fromAddress(address(FARM_NFT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStorageFromFork(contract: StonfiFarmNft): StonfiFarmNftStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiFarmNft", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return StonfiFarmNftStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Farm NFT is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Farm NFT is frozen at the pinned block");
        }
    }
}

get fun `test stonfi farm nft code fixture matches pinned mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("StonfiFarmNft", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi farm nft parses pinned storage and getters`() {
    val contract = farmNft();
    val storage = loadStorageFromFork(contract);
    val stakeData = StonfiFarmNftStakeData.fromCell(storage.stakeData);
    val farmingData = contract.getFarmingData();
    val nftData = contract.getNftData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.status).toEqual(1);
    expect(storage.ownerAddress).toEqual(address(EXPECTED_OWNER));
    expect(storage.revokeTime).toEqual(0);
    expect(storage.claimedPerUnit).toHaveLength(4);
    expect(stakeData.stakedTokens).toEqual(2091182291559);
    expect(stakeData.itemIndex).toEqual(13);
    expect(stakeData.collectionAddress).toEqual(address(EXPECTED_COLLECTION));
    expect(stakeData.stakeDate).toEqual(1729169590);

    expect(farmingData.status).toEqual(storage.status);
    expect(farmingData.revokeTime).toEqual(storage.revokeTime);
    expect(farmingData.stakedTokens).toEqual(stakeData.stakedTokens);
    expect(farmingData.stakeDate).toEqual(stakeData.stakeDate);
    expect(farmingData.claimedPerUnit).toHaveLength(4);
    expect(farmingData.ownerAddress.castToInternal()).toEqual(address(EXPECTED_OWNER));

    expect(nftData.isInitialized).toBeTrue();
    expect(nftData.itemIndex).toEqual(stakeData.itemIndex);
    expect(nftData.collectionAddress.castToInternal()).toEqual(address(EXPECTED_COLLECTION));
    expect(nftData.ownerAddress.castToInternal()).toEqual(address(EXPECTED_OWNER));
    expect(
        nftData.content.hash(),
    ).toEqual(0x3d04513392c4da58c15cd81e89c6b3aceedd867f4727aae4bf0f75bf5c7426a1);
    expect(contract.getAuthorityAddress()).toBeNoneAddress();
    expect(contract.getRevokedTime()).toEqual(storage.revokeTime);

    println("STONFI_FARM_NFT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
