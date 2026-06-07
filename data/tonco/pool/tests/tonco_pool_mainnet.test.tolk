import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tonco_pool.types"
import "../wrappers/ToncoPool.gen"

const FIXTURE_BOC_PATH = "data/tonco/pool/testdata/ToncoPool.boc"
const ACCOUNT_FIXTURE_BOC_PATH = "data/tonco/account/testdata/ToncoAccount.boc"
const POSITION_NFT_FIXTURE_BOC_PATH = "data/tonco/position_nft_v3/testdata/ToncoPositionNftV3.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xbc947d16346c2fdc845b7a446382f59c86acb075e2a31dbfa956cd0c9e54678e
const EXPECTED_ACCOUNT_CODE_HASH = 0xa820f670f18a3afa05c5acb0f85e248c97b01b4d846aeeac4730622b832a8c20
const EXPECTED_POSITION_NFT_CODE_HASH = 0x23091475641789bbbd415b0396a1f0a7a22701086c99dab178a353fc04ce7983
const EXPECTED_MAX_LIQUIDITY_PER_TICK = 38350317471085141830651933667504588
const PINNED_MAINNET_BLOCK = 71245765

const MAINNET_TONCO_POOL_ADDRESS = "EQBk33mIwYXYAytv4beERPqjfdNHaQuSfpaRY7KmNmHqpVLY"
const MAINNET_TONCO_ROUTER_ADDRESS = "EQC_-t0nCnOFMdp7E7qPxAOCbCWGFz-e3pwxb6tTvFmshjt5"
const MAINNET_TONCO_ACCOUNT_ADDRESS = "EQAZ8g6UM2EXWMFxpFcXtrAFHCY9PFbnbHKoQt7pHH9ps5w4"
const MAINNET_TONCO_POSITION_NFT_ADDRESS = "EQAFaimkHZz_KorlOZ1UbdRGjfZnvHJW2cNZff4GdswrCIHp"
const MAINNET_TONCO_POSITION_OWNER_ADDRESS = "EQAkAnmElEeFWeACUBfmi2q-qQseA00sBInrihCAFmQbkTeH"
const MAX_SQRT_RATIO_MINUS_ONE = 1461446703485210103287273052203988822378723970341

fun mainnetToncoPool(): ToncoPool {
    return ToncoPool.fromAddress(address(MAINNET_TONCO_POOL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadToncoPoolStorageFromFork(pool: ToncoPool): ToncoPoolStorage {
    val account = testing.getAccountState(pool.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("ToncoPool", FIXTURE_BOC_PATH).hash());
            return ToncoPoolStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TONCO Pool mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TONCO Pool mainnet fixture account is frozen");
        }
    }
}

get fun `test tonco pool code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("ToncoPool", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tonco pool mainnet storage getters children and derived accounts`() {
    val pool = mainnetToncoPool();
    val storage = loadToncoPoolStorageFromFork(pool);
    val feesAndReserves = storage.feesAndReserves.load();
    val state = storage.state.load();
    val minters = state.minters.load();
    val childContracts = storage.childContracts.load();
    val poolData = pool.getPoolStateAndConfiguration();
    val childReply = pool.getChildContracts();
    val collectionData = pool.getCollectionData();
    val positionNftAddress = pool.getNftAddressByIndex(0);
    val positionNftContent = pool.getNftContent(0, childContracts.nftv3itemContent);
    val accountAddress = pool.getUserAccountAddress(address(MAINNET_TONCO_POSITION_OWNER_ADDRESS));
    val allTicks = pool.getAllTickInfos();
    val tickInfosForward = pool.getTickInfosFrom(-887200, 4, 0, 1);
    val tickInfosBackward = pool.getTickInfosFrom(887200, 4, 1, 0);
    val maxLiquidityPerTick = pool.getMaxLiquidityPerTick();

    expect(scripts.isContractDeployed(pool.address)).toBeTrue();

    expect(storage.routerAddress).toEqual(address(MAINNET_TONCO_ROUTER_ADDRESS));
    expect(pool.getIsActive()).toEqual(state.poolActive);
    expect(poolData.routerAddress).toEqual(storage.routerAddress);
    expect(poolData.adminAddress).toEqual(state.adminAddress);
    expect(poolData.controllerAddress).toEqual(state.controllerAddress);
    expect(poolData.jettonWallet0).toEqual(storage.jetton0Wallet);
    expect(poolData.jettonWallet1).toEqual(storage.jetton1Wallet);
    expect(poolData.jettonMinter0).toEqual(minters.jetton0Minter);
    expect(poolData.jettonMinter1).toEqual(minters.jetton1Minter);
    expect(poolData.isActive).toEqual(state.poolActive);
    expect(poolData.tickSpacing).toEqual(storage.tickSpacing as int);
    expect(poolData.baseFee).toEqual(storage.lpFeeBase as int);
    expect(poolData.protocolFee).toEqual(storage.protocolFee as int);
    expect(poolData.activeFee).toEqual(storage.lpFeeCurrent as int);
    expect(poolData.currentTick).toEqual(state.tick as int);
    expect(poolData.currentPrice).toEqual(state.priceSqrt as int);
    expect(poolData.currentLiquidity).toEqual(state.liquidity as int);
    expect(poolData.feeGrowsGlobal0).toEqual(feesAndReserves.feeGrowthGlobal0X128 as int);
    expect(poolData.feeGrowsGlobal1).toEqual(feesAndReserves.feeGrowthGlobal1X128 as int);
    expect(poolData.collectedToken0ProtocolFee).toEqual(
        feesAndReserves.collectedProtocolFee0 as int,
    );
    expect(poolData.collectedToken1ProtocolFee).toEqual(
        feesAndReserves.collectedProtocolFee1 as int,
    );
    expect(poolData.mintedNftPositions).toEqual(state.nftv3itemCounter as int);
    expect(poolData.reserve0).toEqual(feesAndReserves.reserve0 as int);
    expect(poolData.reserve1).toEqual(feesAndReserves.reserve1 as int);
    expect(poolData.activeNftPositions).toEqual(state.nftv3itemsActive as int);
    expect(poolData.occupiedTicks).toEqual(state.occupiedTicks as int);
    expect(poolData.operationsSinceDeploy).toEqual(storage.seqno as int);

    expect(childReply.accountCode.hash()).toEqual(childContracts.accountv3Code.hash());
    expect(childReply.positionNftCode.hash()).toEqual(childContracts.positionNftv3Code.hash());
    expect(childReply.nftCollectionMetadata.hash()).toEqual(childContracts.nftv3Content.hash());
    expect(childReply.nftItemMetadata.hash()).toEqual(childContracts.nftv3itemContent.hash());
    expect(childReply.accountCode.hash()).toEqual(EXPECTED_ACCOUNT_CODE_HASH);
    expect(childReply.positionNftCode.hash()).toEqual(EXPECTED_POSITION_NFT_CODE_HASH);
    expect(childReply.accountCode.hash()).toEqual(
        build("ToncoAccount", ACCOUNT_FIXTURE_BOC_PATH).hash(),
    );
    expect(childReply.positionNftCode.hash()).toEqual(
        build("ToncoPositionNftV3", POSITION_NFT_FIXTURE_BOC_PATH).hash(),
    );

    expect(collectionData.nextItemIndex).toEqual(state.nftv3itemCounter as int);
    expect(collectionData.collectionContent.hash()).toEqual(childContracts.nftv3Content.hash());
    expect(collectionData.ownerAddress).toEqual(storage.routerAddress);
    expect(positionNftAddress).toEqual(address(MAINNET_TONCO_POSITION_NFT_ADDRESS));
    expect(positionNftContent.hash()).toBeGreater(0);
    expect(accountAddress).toEqual(address(MAINNET_TONCO_ACCOUNT_ADDRESS));
    expect(allTicks.hash()).toBeGreater(0);
    val forwardChunk = tickInfosForward.get(0) as tuple;
    val forwardTicks = forwardChunk.get(0) as tuple;
    val forwardFirstTick = forwardTicks.get(0) as tuple;
    val forwardSecondTick = forwardTicks.get(1) as tuple;
    val forwardThirdTick = forwardTicks.get(2) as tuple;
    expect(forwardFirstTick.get(0) as int).toEqual(-109000);
    expect(forwardFirstTick.get(1) as int).toEqual(431052966468743);
    expect(forwardFirstTick.get(2) as int).toEqual(431052966468743);
    expect(forwardFirstTick.get(3) as int).toEqual(0);
    expect(forwardFirstTick.get(4) as int).toEqual(96918007578586474235746516106546);
    expect(forwardSecondTick.get(0) as int).toEqual(7000);
    expect(forwardSecondTick.get(2) as int).toEqual(-431052966468743);
    expect(forwardThirdTick.get(0) as int).toEqual(887200);
    expect(forwardThirdTick.get(2) as int).toEqual(-234403615468);

    val backwardChunk = tickInfosBackward.get(0) as tuple;
    val backwardTicks = backwardChunk.get(0) as tuple;
    val backwardFirstTick = backwardTicks.get(0) as tuple;
    val backwardSecondTick = backwardTicks.get(1) as tuple;
    val backwardThirdTick = backwardTicks.get(2) as tuple;
    expect(backwardFirstTick.get(0) as int).toEqual(7000);
    expect(backwardFirstTick.get(1) as int).toEqual(431052966468743);
    expect(backwardFirstTick.get(2) as int).toEqual(-431052966468743);
    expect(backwardSecondTick.get(0) as int).toEqual(-109000);
    expect(backwardSecondTick.get(2) as int).toEqual(431052966468743);
    expect(backwardThirdTick.get(0) as int).toEqual(-887200);
    expect(backwardThirdTick.get(1) as int).toEqual(234403615468);
    expect(backwardThirdTick.get(2) as int).toEqual(234403615468);
    expect(maxLiquidityPerTick).toEqual(EXPECTED_MAX_LIQUIDITY_PER_TICK);

    println("TONCO_POOL_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TONCO_POOL_ADDRESS={}", pool.address);
    println("TONCO_POOL_STORAGE={}", storage);
    println("TONCO_POOL_STATE_AND_CONFIGURATION={}", poolData);
    println("TONCO_POOL_DERIVED_ACCOUNT={}", accountAddress);
    println("TONCO_POOL_POSITION_NFT_0={}", positionNftAddress);
    println("TONCO_POOL_TICK_INFOS_FORWARD={}", tickInfosForward);
    println("TONCO_POOL_TICK_INFOS_BACKWARD={}", tickInfosBackward);
    println("TONCO_POOL_MAX_LIQUIDITY_PER_TICK={}", maxLiquidityPerTick);
}

get fun `test tonco pool mainnet estimate getters`() {
    val pool = mainnetToncoPool();
    val storage = loadToncoPoolStorageFromFork(pool);
    val feesAndReserves = storage.feesAndReserves.load();
    val state = storage.state.load();
    val feeGrowthInside = pool.getFeeGrowthInside(
        -887200,
        887200,
        state.tick as int,
        feesAndReserves.feeGrowthGlobal0X128 as int,
        feesAndReserves.feeGrowthGlobal1X128 as int,
    );
    val collectedFees = pool.getCollectedFees(-887200, 887200, 234403615468, 0, 0);
    val mintEstimate = pool.getMintEstimate(-887200, 887200, 1);
    val swapEstimate = pool.getSwapEstimate(0, 1000000, MAX_SQRT_RATIO_MINUS_ONE);
    val swapEstimateGas = pool.getSwapEstimateGas(
        0,
        1000000,
        MAX_SQRT_RATIO_MINUS_ONE,
        0,
        1000000000,
    );

    expect(feeGrowthInside.feeGrowthInside0X128).toEqual(
        feesAndReserves.feeGrowthGlobal0X128 as int,
    );
    expect(feeGrowthInside.feeGrowthInside1X128).toEqual(
        feesAndReserves.feeGrowthGlobal1X128 as int,
    );
    expect(collectedFees.amount0).toBeGreater(0);
    expect(collectedFees.amount1).toBeGreater(0);
    expect(mintEstimate.amount0).toEqual(230);
    expect(mintEstimate.amount1).toEqual(1);
    expect(mintEstimate.mintErrors).toEqual(0);
    expect(swapEstimate.amount0).toBeLess(0);
    expect(swapEstimate.amount1).toEqual(1000000);
    expect(swapEstimateGas.amount0).toEqual(swapEstimate.amount0);
    expect(swapEstimateGas.amount1).toEqual(swapEstimate.amount1);

    println("TONCO_POOL_FEE_GROWTH_INSIDE={}", feeGrowthInside);
    println("TONCO_POOL_COLLECTED_FEES={}", collectedFees);
    println("TONCO_POOL_MINT_ESTIMATE={}", mintEstimate);
    println("TONCO_POOL_SWAP_ESTIMATE={}", swapEstimate);
}
