import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonco_position_nft_v3.types"
import "../wrappers/ToncoPositionNftV3.gen"

const FIXTURE_BOC_PATH = "data/tonco/position_nft_v3/testdata/ToncoPositionNftV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x23091475641789bbbd415b0396a1f0a7a22701086c99dab178a353fc04ce7983
const PINNED_MAINNET_BLOCK = 71245765

const MAINNET_TONCO_POSITION_NFT_ADDRESS = "EQAFaimkHZz_KorlOZ1UbdRGjfZnvHJW2cNZff4GdswrCIHp"
const MAINNET_TONCO_POOL_ADDRESS = "EQBk33mIwYXYAytv4beERPqjfdNHaQuSfpaRY7KmNmHqpVLY"
const MAINNET_TONCO_POSITION_OWNER_ADDRESS = "EQAkAnmElEeFWeACUBfmi2q-qQseA00sBInrihCAFmQbkTeH"

fun mainnetToncoPositionNftV3(): ToncoPositionNftV3 {
    return ToncoPositionNftV3.fromAddress(address(MAINNET_TONCO_POSITION_NFT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadToncoPositionNftV3StorageFromFork(position: ToncoPositionNftV3): ToncoPositionNftV3Storage {
    val account = testing.getAccountState(position.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("ToncoPositionNftV3", FIXTURE_BOC_PATH).hash());
            return ToncoPositionNftV3Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TONCO Position NFT V3 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TONCO Position NFT V3 mainnet fixture account is frozen");
        }
    }
}

fun buildExpectedNftDataContent(
    storage: ToncoPositionNftV3Storage,
    feeGrowthInside: ToncoPositionNftV3FeeGrowth,
): cell {
    var contentSlice = storage.content.beginParse();
    contentSlice.loadUint(8);
    val contentSuffix = contentSlice.loadDict();

    return beginCell()
        .storeUint(0, 8)
        .storeDict(contentSuffix)
        .storeUint(storage.liquidity as int, 128)
        .storeInt(storage.tickLower as int, 24)
        .storeInt(storage.tickUpper as int, 24)
        .storeUint(feeGrowthInside.feeGrowthInside0LastX128 as int, 256)
        .storeUint(feeGrowthInside.feeGrowthInside1LastX128 as int, 256)
        .endCell();
}

get fun `test tonco position nft v3 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("ToncoPositionNftV3", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonco position nft v3 mainnet getters match storage`() {
    val position = mainnetToncoPositionNftV3();
    val storage = loadToncoPositionNftV3StorageFromFork(position);
    val feeGrowthInside = storage.feeGrowthInside.load();
    val poolAddress = position.getPoolAddress();
    val userAddress = position.getUserAddress();
    val positionInfo = position.getPositionInfo();
    val nftData = position.getNftData();

    expect(scripts.isContractDeployed(position.address)).toBeTrue();

    expect(storage.index).toEqual(0);
    expect(storage.poolAddress).toEqual(address(MAINNET_TONCO_POOL_ADDRESS));
    expect(storage.userAddress).toEqual(address(MAINNET_TONCO_POSITION_OWNER_ADDRESS));

    expect(poolAddress).toEqual(storage.poolAddress);
    expect(userAddress).toEqual(storage.userAddress);
    expect(positionInfo.liquidity).toEqual(storage.liquidity as int);
    expect(positionInfo.tickLower).toEqual(storage.tickLower as int);
    expect(positionInfo.tickUpper).toEqual(storage.tickUpper as int);
    expect(positionInfo.feeGrowthInside0LastX128).toEqual(feeGrowthInside.feeGrowthInside0LastX128 as int);
    expect(positionInfo.feeGrowthInside1LastX128).toEqual(feeGrowthInside.feeGrowthInside1LastX128 as int);

    expect(nftData.isInitialized).toBeTrue();
    expect(nftData.itemIndex).toEqual(storage.index as int);
    expect(nftData.collectionAddress).toEqual(storage.poolAddress);
    expect(nftData.ownerAddress!).toEqual(storage.userAddress);
    expect(nftData.content).toBeNotNull();
    expect(nftData.content!.hash()).toEqual(buildExpectedNftDataContent(storage, feeGrowthInside).hash());

    println("TONCO_POSITION_NFT_V3_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONCO_POSITION_NFT_V3_ADDRESS={}", position.address);
    println("TONCO_POSITION_NFT_V3_STORAGE={}", storage);
    println("TONCO_POSITION_NFT_V3_INFO={}", positionInfo);
    println("TONCO_POSITION_NFT_V3_NFT_DATA={}", nftData);
}
