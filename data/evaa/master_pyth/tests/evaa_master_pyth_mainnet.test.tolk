import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/evaa_master_pyth.types"
import "../wrappers/EvaaMasterPyth.gen"

const CODE_FIXTURE_BOC_PATH = "data/evaa/master_pyth/testdata/EvaaMasterPyth.boc"
const DATA_FIXTURE_BOC_PATH = "data/evaa/master_pyth/testdata/EvaaMasterPyth.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb90881c4dc48b08dd92e51510f80ff93cf789c7bb5f868c65b198838b8f9d6a6
const EXPECTED_DATA_HASH = 0x1471ce9b25a75183fb589658fa16adf349d5bf2bb3a74a7d1e890a3212089a5f
const EXPECTED_MASTER_CODE_VERSION = 10
const EXPECTED_USER_CODE_VERSION = 7
const EXPECTED_TIMEOUT = 60
const EXPECTED_IF_ACTIVE = -1
const EXPECTED_ADMIN = "0:cfc9f49481b5b4e0fe27de38f646e39769db31d72390e25046c75ecf4c2d694c"
const EXPECTED_SUPERVISOR = "0:7737cf8d1fb5fa86dc412d697cb40c92a56ea1a18c2cf5a916e1887bee0c115e"
const EXPECTED_PYTH_ADDRESS = "0:3934fca37d9ced0e6f237130704c053d346b20244930d7dcfad7279c5f44e5b1"
const EXPECTED_FEEDS_HASH = 0x27b84d4ecf5a529a0a5ce1d212dcc136cdae59da00a5ddc1f660ffcd67d0dc1e
const EXPECTED_PRICES_TTL = 180
const EXPECTED_PYTH_COMPUTE_BASE_GAS = 340000
const EXPECTED_PYTH_COMPUTE_PER_UPDATE_GAS = 90000
const EXPECTED_PYTH_SINGLE_UPDATE_FEE = 1
const MAINNET_EVAA_MASTER_PYTH_ADDRESS = "EQC8rUZqR_pWV1BylWUlPNBzyiTYVoBEmQkMIQDZXICfnuRr"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedEvaaMasterPythDataCell(): cell {
    return build("EvaaMasterPyth", DATA_FIXTURE_BOC_PATH);
}

fun loadEvaaMasterPythStorageFixture(): EvaaMasterPythStorage {
    val data = savedEvaaMasterPythDataCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);

    val storage = EvaaMasterPythStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun expectEvaaMasterPythStorageCore(storage: EvaaMasterPythStorage): EvaaMasterPythOraclesInfo {
    val upgradeConfig = storage.upgradeConfig.load();
    val masterConfig = storage.masterConfig.load();
    val oraclesInfo = masterConfig.oraclesInfo.load();

    expect(upgradeConfig.masterCodeVersion).toEqual(EXPECTED_MASTER_CODE_VERSION);
    expect(upgradeConfig.userCodeVersion).toEqual(EXPECTED_USER_CODE_VERSION);
    expect(upgradeConfig.timeout).toEqual(EXPECTED_TIMEOUT);
    expect(upgradeConfig.userCode.hash()).toBeGreater(0);
    expect(upgradeConfig.newMasterCode).toBeNull();
    expect(upgradeConfig.newUserCode).toBeNull();

    expect(masterConfig.ifActive).toEqual(EXPECTED_IF_ACTIVE);
    expect(masterConfig.admin).toEqual(address(EXPECTED_ADMIN));
    expect(masterConfig.supervisor).toEqual(address(EXPECTED_SUPERVISOR));
    expect(masterConfig.assetConfigCollection.isEmpty()).toBeFalse();
    expect(masterConfig.tokensKeys.isEmpty()).toBeFalse();
    expect(storage.assetDynamicsCollection.isEmpty()).toBeFalse();

    expect(oraclesInfo.pythAddress).toEqual(address(EXPECTED_PYTH_ADDRESS));
    expect(oraclesInfo.feedsData.hash()).toEqual(EXPECTED_FEEDS_HASH);
    expect(oraclesInfo.pricesTtl).toEqual(EXPECTED_PRICES_TTL);
    expect(oraclesInfo.pythComputeBaseGas).toEqual(EXPECTED_PYTH_COMPUTE_BASE_GAS);
    expect(oraclesInfo.pythComputePerUpdateGas).toEqual(EXPECTED_PYTH_COMPUTE_PER_UPDATE_GAS);
    expect(oraclesInfo.pythSingleUpdateFee).toEqual(EXPECTED_PYTH_SINGLE_UPDATE_FEE);

    return oraclesInfo;
}

get fun `test evaa master pyth code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("EvaaMasterPyth", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("EvaaMasterPyth").hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedEvaaMasterPythDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test evaa master pyth saved data fixture parses storage`() {
    val storage = loadEvaaMasterPythStorageFixture();
    val oraclesInfo = expectEvaaMasterPythStorageCore(storage);
    val master = EvaaMasterPyth.fromStorage(storage);

    expect(master.stateInit).toBeNotNull();
    expect(master.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(master.stateInit!.data.hash()).toEqual(EXPECTED_DATA_HASH);

    println("EVAA_MASTER_PYTH_DATA_HASH={}", storage.toCell().hash());
    println("EVAA_MASTER_PYTH_FEEDS_HASH={}", oraclesInfo.feedsData.hash());
}

get fun `test evaa master pyth local wrapper getters match saved storage`() {
    val storage = loadEvaaMasterPythStorageFixture();
    val upgradeConfig = storage.upgradeConfig.load();
    val masterConfig = storage.masterConfig.load();
    val oraclesInfo = masterConfig.oraclesInfo.load();
    val master = EvaaMasterPyth.fromStorage(storage);
    val deployer = testing.treasury("evaa-master-pyth-storage-deployer");

    master.deploy(deployer.address, { value: ton("1"), bounce: false });
    expect(scripts.isContractDeployed(master.address)).toBeTrue();

    val upgradeGetter = master.getUpgradeConfig();
    val oraclesGetter = master.getOraclesInfo();

    expect(master.getStore().hash()).toEqual(storage.toCell().hash());
    expect(master.getActive()).toEqual(masterConfig.ifActive);
    expect(master.getLastUserScVersion()).toEqual(upgradeConfig.userCodeVersion);
    expect(master.getSupervisor()).toEqual(masterConfig.supervisor);

    expect(upgradeGetter.masterCodeVersion).toEqual(upgradeConfig.masterCodeVersion);
    expect(upgradeGetter.userCodeVersion).toEqual(upgradeConfig.userCodeVersion);
    expect(upgradeGetter.timeout).toEqual(upgradeConfig.timeout);
    expect(upgradeGetter.userCode.hash()).toEqual(upgradeConfig.userCode.hash());
    expect(upgradeGetter.newMasterCode).toBeNull();
    expect(upgradeGetter.newUserCode).toBeNull();

    expect(oraclesGetter.pythAddress).toEqual(oraclesInfo.pythAddress);
    expect(oraclesGetter.feedsData.hash()).toEqual(oraclesInfo.feedsData.hash());
    expect(oraclesGetter.pricesTtl).toEqual(oraclesInfo.pricesTtl);
    expect(oraclesGetter.pythComputeBaseGas).toEqual(oraclesInfo.pythComputeBaseGas);
    expect(oraclesGetter.pythComputePerUpdateGas).toEqual(oraclesInfo.pythComputePerUpdateGas);
    expect(oraclesGetter.pythSingleUpdateFee).toEqual(oraclesInfo.pythSingleUpdateFee);

    println("EVAA_MASTER_PYTH_LOCAL_ADDRESS={}", master.address);
}

get fun `test evaa master pyth wrapper compiles from mainnet address`() {
    val master = EvaaMasterPyth.fromAddress(address(MAINNET_EVAA_MASTER_PYTH_ADDRESS));

    expect(master.address).toEqual(address(MAINNET_EVAA_MASTER_PYTH_ADDRESS));
}
