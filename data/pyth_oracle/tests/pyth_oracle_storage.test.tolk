import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/pyth_oracle.types"
import "../wrappers/PythOracle.gen"

const CODE_FIXTURE_BOC_PATH = "data/pyth_oracle/testdata/PythOracle.boc"
const DATA_FIXTURE_BOC_PATH = "data/pyth_oracle/testdata/PythOracle.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xf4849f26e6a41931304eb3d7652906825dc632e68ccc7ec61cad4532699c11fe
const EXPECTED_DATA_HASH = 0x77c16d817f865f015f45e6b9283c7b207b3b207cc61fd6ca091b349025cf9929
const EXPECTED_SINGLE_UPDATE_FEE = 1
const EXPECTED_CHAIN_ID = 60069
const EXPECTED_GOVERNANCE_CHAIN_ID = 1
const EXPECTED_CURRENT_GUARDIAN_SET_INDEX = 6
const MAINNET_PYTH_ORACLE_ADDRESS = "EQA5NPyjfZztDm8jcTBwTAU9NGsgJEkw19z61yecX0TlseSB"

struct LoadedPythOracleStorage {
    data: cell
    storage: PythOracleStorage
    priceFeeds: PythPriceFeedsStorage
    dataSources: PythDataSourcesStorage
    guardianSets: PythGuardianSetsStorage
    governance: PythGovernanceStorage
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadPythOracleStorageFixture(): LoadedPythOracleStorage {
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawData!)).toBeTrue();

    val data = build("PythOracleData", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    val storage = PythOracleStorage.fromCell(data);
    return LoadedPythOracleStorage {
        data,
        storage,
        priceFeeds: storage.priceFeeds.load(),
        dataSources: storage.dataSources.load(),
        guardianSets: storage.guardianSets.load(),
        governance: storage.governance.load(),
    };
}

fun expectPythStorageCore(loaded: LoadedPythOracleStorage): void {
    expect(loaded.storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(loaded.priceFeeds.singleUpdateFee).toEqual(EXPECTED_SINGLE_UPDATE_FEE);
    expect(loaded.priceFeeds.latestPriceFeeds.isEmpty()).toBeFalse();
    expect(loaded.dataSources.isValidDataSource.isEmpty()).toBeFalse();
    expect(loaded.guardianSets.currentGuardianSetIndex).toEqual(EXPECTED_CURRENT_GUARDIAN_SET_INDEX);
    expect(loaded.guardianSets.guardianSets.isEmpty()).toBeFalse();
    expect(loaded.governance.chainId).toEqual(EXPECTED_CHAIN_ID);
    expect(loaded.governance.governanceChainId).toEqual(EXPECTED_GOVERNANCE_CHAIN_ID);
    expect(loaded.governance.governanceContract).toBeGreater(0);
    expect(loaded.governance.governanceDataSource.hash()).toBeGreater(0);
}

get fun `test pyth oracle code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("PythOracle", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("PythOracle").hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("PythOracleData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test pyth oracle saved data fixture parses storage`() {
    val loaded = loadPythOracleStorageFixture();
    expectPythStorageCore(loaded);

    println("PYTH_ORACLE_DATA_HASH={}", loaded.storage.toCell().hash());
    println("PYTH_ORACLE_GOVERNANCE_SOURCE_HASH={}", loaded.governance.governanceDataSource.hash());
}

get fun `test pyth oracle local wrapper getters match saved storage`() {
    val loaded = loadPythOracleStorageFixture();
    val oracle = PythOracle.fromStorage(loaded.storage);
    val deployer = testing.treasury("pyth-oracle-storage-deployer");

    oracle.deploy(deployer.address, { value: ton("1"), bounce: false });
    expect(scripts.isContractDeployed(oracle.address)).toBeTrue();

    expect(oracle.getSingleUpdateFee()).toEqual(loaded.priceFeeds.singleUpdateFee);
    expect(oracle.getChainId()).toEqual(loaded.governance.chainId);
    expect(oracle.getGovernanceChainId()).toEqual(loaded.governance.governanceChainId);
    expect(oracle.getCurrentGuardianSetIndex()).toEqual(loaded.guardianSets.currentGuardianSetIndex);
    expect(oracle.getGovernanceDataSource().hash()).toEqual(loaded.governance.governanceDataSource.hash());
    expect(oracle.getGovernanceDataSourceIndex()).toEqual(loaded.governance.governanceDataSourceIndex);
    expect(oracle.getLastExecutedGovernanceSequence()).toEqual(loaded.governance.lastExecutedGovernanceSequence);
}

get fun `test pyth oracle wrapper compiles from mainnet address`() {
    val oracle = PythOracle.fromAddress(address(MAINNET_PYTH_ORACLE_ADDRESS));

    expect(oracle.address).toEqual(address(MAINNET_PYTH_ORACLE_ADDRESS));
}
