import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/ff_vault_position.types"
import "../wrappers/FfVaultPosition.gen"

const FIXTURE_BOC_PATH = "data/ff_vault/position/testdata/FfVaultPosition.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x76d2a7fb965d894f2ba76b09a58a2750219b2d9a8821c87a8504306859a578f5
const EXPECTED_DATA_HASH = 0x404a0aff8b3cbc9aba50daa12e0647d8c5b10f701564525cf8d10dd81a53e566
const EXPECTED_PRICE_STAKED = 222341058504595726115676289921225531382569
const PINNED_MAINNET_BLOCK = 83373780
const POSITION_ADDRESS = "EQAUqDx1sb-zXEk7rDLfD_3aWIOxyOwt0ktjvcwlc_dacqDH"
const COLLECTION_ADDRESS = "EQBMTi0nonch8rj6P5mT4TyWlunXAbL0mPmBKU7OKv3t2koO"
const OWNER_ADDRESS = "EQAY4M45NM2XKC-PY5nLKuAR1eKfGxz-N3SqSEQhDXNKbvit"

fun position(): FfVaultPosition {
    return FfVaultPosition.fromAddress(address(POSITION_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadPositionStorage(contract: FfVaultPosition): FfVaultPositionStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("FfVaultPosition", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return FfVaultPositionStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("FF Vault position is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("FF Vault position is frozen at the pinned block");
        }
    }
}

get fun `test ff vault position code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("FfVaultPosition", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test ff vault position parses pinned storage and all getters`() {
    val contract = position();
    val storage = loadPositionStorage(contract);
    val staticData = storage.staticData.load();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(staticData.itemIndex).toEqual(3);
    expect(staticData.collectionAddress).toEqual(address(COLLECTION_ADDRESS));
    expect(staticData.previousStablePerAssetCollected).toEqual(0);
    expect(storage.ownerAddress).toEqual(address(OWNER_ADDRESS));
    expect(storage.lockedAssetAmount).toEqual(19949);
    expect(storage.assetPriceStaked).toEqual(EXPECTED_PRICE_STAKED);
    expect(storage.amountWantedToUnstake).toEqual(10971);

    val nftData = contract.getNftData();
    expect(nftData.isInitialized).toBeTrue();
    expect(nftData.itemIndex).toEqual(staticData.itemIndex);
    expect(nftData.collectionAddress).toEqual(staticData.collectionAddress);
    expect(nftData.ownerAddress).toEqual(storage.ownerAddress);
    expect(nftData.content).toBeNotNull();
    expect(nftData.content!.beginParse().remainingRefsCount()).toEqual(1);

    val positionInfo = contract.getStakePositionInfo();
    expect(positionInfo.lockedAssetAmount).toEqual(storage.lockedAssetAmount);
    expect(positionInfo.amountWantedToUnstake).toEqual(storage.amountWantedToUnstake);
    expect(positionInfo.previousStablePerAssetCollected).toEqual(
        staticData.previousStablePerAssetCollected,
    );
    expect(positionInfo.assetPriceStaked).toEqual(storage.assetPriceStaked);
    println("FF_VAULT_POSITION_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
