import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_pool_factory.types"
import "../wrappers/BidaskPoolFactory.gen"

const CODE_FIXTURE_BOC_PATH = "data/bidask/pool_factory/testdata/BidaskPoolFactory.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/pool_factory/testdata/BidaskPoolFactory.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb33092253781e2c698c578ce83e26d254316c495cefaf84fc600278778ae1a49
const EXPECTED_DATA_HASH = 0xc3129801ba3f6ee0400661f52061c10a5db2377f5392c044d6c6621ff77a4c16
const EXPECTED_POOL_CODE_HASH = 0xb1215034b293853339110766cdc83626a147787ec15d0c571cb53a8c8c2e7e12
const EXPECTED_RANGE_CODE_HASH = 0x4bd7191b24823ced9a44089739a58213cd5bc562f8980289855af9626646b91e
const EXPECTED_LP_MULTITOKEN_CODE_HASH = 0xa2ce96a1b2e4985d9070c0bc05b97d3e5cc56edb83f4e15b052a60f0ed235a54
const EXPECTED_INTERNAL_LIQUIDITY_VAULT_CODE_HASH = 0x5b80fb2241c901e8288d1b72c9720366daca00f7daf019a49fa6995bb630d495
const EXPECTED_DAMM_POOL_CODE_HASH = 0x760f60fe228f87c709ec85690bf592904c20386f06cbe4c478faf9453eded124
const EXPECTED_DAMM_LP_WALLET_CODE_HASH = 0x9644004d43aa9f982d99d16cf9677a4bec77bbcec0d1e8e6487b2b76c2261182

const MAINNET_BIDASK_POOL_FACTORY_ADDRESS = "EQAuBZGak9BdkxuCC9gWUsY4Em3jog94BI4eRzX-3_Bidask"
const MAINNET_BIDASK_POOL_FACTORY_OWNER = "EQDrVtib10RwCCDwmlRud1grENNXhTBUKWCMhih5VQyuQ7Q6"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun bidaskPoolFactoryDataFixtureCell(): cell {
    return build("BidaskPoolFactory", DATA_FIXTURE_BOC_PATH);
}

fun loadBidaskPoolFactoryStorageFixture(): BidaskPoolFactoryStorage {
    val data = bidaskPoolFactoryDataFixtureCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = BidaskPoolFactoryStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun assertExpectedPresets(presets: map<int257, int257>): void {
    expect(presets).toHaveLength(14);
    expect(presets.mustGet(1)).toEqual(135);
    expect(presets.mustGet(2)).toEqual(67);
    expect(presets.mustGet(3)).toEqual(63);
    expect(presets.mustGet(4)).toEqual(34);
    expect(presets.mustGet(5)).toEqual(31);
    expect(presets.mustGet(6)).toEqual(31);
    expect(presets.mustGet(8)).toEqual(17);
    expect(presets.mustGet(10)).toEqual(15);
    expect(presets.mustGet(30)).toEqual(5);
    expect(presets.mustGet(60)).toEqual(2);
    expect(presets.mustGet(100)).toEqual(1);
    expect(presets.mustGet(300)).toEqual(0);
    expect(presets.mustGet(400)).toEqual(0);
    expect(presets.mustGet(500)).toEqual(0);
}

get fun `test bidask pool factory code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    expect(build("BidaskPoolFactory", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("BidaskPoolFactory").hash()).toEqual(EXPECTED_CODE_HASH);
    expect(bidaskPoolFactoryDataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test bidask pool factory saved data fixture parses as storage`() {
    val storage = loadBidaskPoolFactoryStorageFixture();
    val bundle = storage.codeBundle.load();
    val extended = bundle.extendedCodes.load();
    val tail = extended.tail.load();

    expect(storage.owner).toEqual(address(MAINNET_BIDASK_POOL_FACTORY_OWNER));
    expect(storage.poolCode.hash()).toEqual(EXPECTED_POOL_CODE_HASH);
    expect(bundle.rangeCode.hash()).toEqual(EXPECTED_RANGE_CODE_HASH);
    expect(bundle.lpMultitokenCode.hash()).toEqual(EXPECTED_LP_MULTITOKEN_CODE_HASH);
    expect(bundle.tradeAccountCode.hash()).toBeGreater(0);
    expect(extended.internalLiquidityVaultCode.hash()).toEqual(
        EXPECTED_INTERNAL_LIQUIDITY_VAULT_CODE_HASH,
    );
    expect(extended.dammLpAccountCode.hash()).toBeGreater(0);
    expect(extended.dammPoolCode.hash()).toEqual(EXPECTED_DAMM_POOL_CODE_HASH);
    expect(tail.dammLpWalletCode.hash()).toEqual(EXPECTED_DAMM_LP_WALLET_CODE_HASH);
    expect(tail.unknownCode0.hash()).toBeGreater(0);
    expect(tail.unknownCode1.hash()).toEqual(bundle.tradeAccountCode.hash());
    expect(tail.protocolFee).toEqual(5);
    expect(tail.refFee).toEqual(5);
    assertExpectedPresets(tail.presets);

    println("BIDASK_POOL_FACTORY_LOCAL_DATA_HASH={}", storage.toCell().hash());
    println("BIDASK_POOL_FACTORY_LOCAL_POOL_CODE_HASH={}", storage.poolCode.hash());
    println("BIDASK_POOL_FACTORY_LOCAL_RANGE_CODE_HASH={}", bundle.rangeCode.hash());
    println("BIDASK_POOL_FACTORY_LOCAL_TAIL_HASH={}", extended.tail.hash());
}

get fun `test bidask pool factory wrapper compiles from storage and address`() {
    val storage = loadBidaskPoolFactoryStorageFixture();
    val fromStorage = BidaskPoolFactory.fromStorage(storage);
    val fromAddress = BidaskPoolFactory.fromAddress(address(MAINNET_BIDASK_POOL_FACTORY_ADDRESS));

    expect(fromStorage.stateInit).toBeNotNull();
    expect(fromStorage.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(fromStorage.stateInit!.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(fromAddress.address).toEqual(address(MAINNET_BIDASK_POOL_FACTORY_ADDRESS));
}
