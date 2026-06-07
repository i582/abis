import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/evaa_master_classic.types"
import "../wrappers/EvaaMasterClassic.gen"

const CODE_FIXTURE_BOC_PATH = "data/evaa/master_classic/testdata/EvaaMasterClassic.boc"
const DATA_FIXTURE_BOC_PATH = "data/evaa/master_classic/testdata/EvaaMasterClassic.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x7789fdc983efa458e1c6ba276a69836dacb70e35a1544df1b5d17ef827725407
const EXPECTED_DATA_HASH = 0x60e61105ecb319b84e34f0be8b711ddba9e31b2de3b018c297b3622b066f35ca
const EXPECTED_ORACLE_DICT_HASH = 0xf7ecaa29795a3ae75ebc475f4e02011afdb22466361c666860578c28b616891a
const EXPECTED_MASTER_CODE_VERSION = 3
const EXPECTED_USER_CODE_VERSION = 1
const EXPECTED_TIMEOUT = 60
const EXPECTED_IF_ACTIVE = -1
const EXPECTED_TOTAL_ORACLES = 4
const EXPECTED_THRESHOLD = 3
const PINNED_MAINNET_BLOCK = 71635640

const MAINNET_EVAA_MASTER_CLASSIC_ADDRESS = "EQCdIdXf1kA_2Hd9mbGzSFDEPA-Px-et8qTWHEXgRGo0K3zd"
const EXPECTED_ADMIN_ADDRESS = "0:cfc9f49481b5b4e0fe27de38f646e39769db31d72390e25046c75ecf4c2d694c"
const EXPECTED_SUPERVISOR_ADDRESS = "0:7737cf8d1fb5fa86dc412d697cb40c92a56ea1a18c2cf5a916e1887bee0c115e"

struct LoadedEvaaMasterClassicStorage {
    data: cell
    storage: EvaaMasterClassicStorage
}

fun mainnetEvaaMasterClassic(): EvaaMasterClassic {
    return EvaaMasterClassic.fromAddress(address(MAINNET_EVAA_MASTER_CLASSIC_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDataCell(): cell {
    return build("EvaaMasterClassic", DATA_FIXTURE_BOC_PATH);
}

fun loadSavedStorage(): LoadedEvaaMasterClassicStorage {
    val data = savedDataCell();
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return LoadedEvaaMasterClassicStorage {
        data,
        storage: EvaaMasterClassicStorage.fromCell(data),
    };
}

fun loadForkStorage(master: EvaaMasterClassic): LoadedEvaaMasterClassicStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("EvaaMasterClassic", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedEvaaMasterClassicStorage {
                data: data!,
                storage: EvaaMasterClassicStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("EVAA Master Classic mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("EVAA Master Classic mainnet fixture account is frozen");
        }
    }
}

fun expectStorageCore(loaded: LoadedEvaaMasterClassicStorage): void {
    val storage = loaded.storage;
    val upgrade = storage.upgradeConfig.load();
    val config = storage.masterConfig.load();
    val oraclesInfo = config.oraclesInfo.load();

    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.meta.hash()).toBeGreater(0);
    expect(storage.upgradeConfig.hash()).toBeGreater(0);
    expect(storage.masterConfig.hash()).toBeGreater(0);
    expect(upgrade.masterCodeVersion).toEqual(EXPECTED_MASTER_CODE_VERSION);
    expect(upgrade.userCodeVersion).toEqual(EXPECTED_USER_CODE_VERSION);
    expect(upgrade.timeout).toEqual(EXPECTED_TIMEOUT);
    expect(upgrade.userCode.hash()).toBeGreater(0);
    expect(config.ifActive).toEqual(EXPECTED_IF_ACTIVE);
    expect(config.admin).toEqual(address(EXPECTED_ADMIN_ADDRESS));
    expect(config.supervisor).toEqual(address(EXPECTED_SUPERVISOR_ADDRESS));
    expect(oraclesInfo.totalOracles).toEqual(EXPECTED_TOTAL_ORACLES);
    expect(oraclesInfo.threshold).toEqual(EXPECTED_THRESHOLD);
    expect(oraclesInfo.oracles).toBeNotNull();
    expect(oraclesInfo.oracles!.hash()).toEqual(EXPECTED_ORACLE_DICT_HASH);
}

fun expectGettersMatchStorage(
    master: EvaaMasterClassic,
    loaded: LoadedEvaaMasterClassicStorage,
): void {
    val storage = loaded.storage;
    val upgrade = storage.upgradeConfig.load();
    val config = storage.masterConfig.load();
    val oraclesInfo = config.oraclesInfo.load();
    val getterUpgrade = master.getUpgradeConfig();
    val getterOracles = master.getOraclesInfo();
    val getterConfig = EvaaMasterClassicGetConfigReply.fromCell(master.getConfig());

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(master.getStore().hash()).toEqual(loaded.data.hash());
    expect(master.getActive()).toEqual(config.ifActive as int);
    expect(master.getSupervisor()).toEqual(config.supervisor);
    expect(master.getLastUserScVersion()).toEqual(upgrade.userCodeVersion as int);

    expect(getterUpgrade.masterCodeVersion).toEqual(upgrade.masterCodeVersion as int);
    expect(getterUpgrade.userCodeVersion).toEqual(upgrade.userCodeVersion as int);
    expect(getterUpgrade.timeout).toEqual(upgrade.timeout as int);
    expect(getterUpgrade.userCode.hash()).toEqual(upgrade.userCode.hash());
    expect(getterUpgrade.newMasterCode).toEqual(upgrade.newMasterCode);
    expect(getterUpgrade.newUserCode).toEqual(upgrade.newUserCode);

    expect(getterOracles.totalOracles).toEqual(oraclesInfo.totalOracles as int);
    expect(getterOracles.threshold).toEqual(oraclesInfo.threshold as int);
    expect(getterOracles.oracles.hash()).toEqual(oraclesInfo.oracles!.hash());
    expect(getterOracles.oracles.hash()).toEqual(EXPECTED_ORACLE_DICT_HASH);

    expect(getterConfig.meta.hash()).toEqual(storage.meta.hash());
    expect(getterConfig.upgradeConfig.hash()).toEqual(storage.upgradeConfig.hash());
    expect(getterConfig.masterConfig.hash()).toEqual(storage.masterConfig.hash());
}

get fun `test evaa master classic code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("EvaaMasterClassic", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("EvaaMasterClassic").hash()).toEqual(EXPECTED_CODE_HASH);
    expect(savedDataCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test evaa master classic saved data fixture parses storage`() {
    val loaded = loadSavedStorage();
    val master = EvaaMasterClassic.fromStorage(loaded.storage);

    expectStorageCore(loaded);
    expect(master.stateInit).toBeNotNull();
    expect(master.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(master.stateInit!.data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(master.address).toNotEqual(address(MAINNET_EVAA_MASTER_CLASSIC_ADDRESS));

    println("EVAA_MASTER_CLASSIC_SAVED_DATA_HASH={}", loaded.data.hash());
    println("EVAA_MASTER_CLASSIC_DERIVED_ADDRESS={}", master.address);
}

get fun `test evaa master classic local getters match saved storage`() {
    val loaded = loadSavedStorage();
    val master = EvaaMasterClassic.fromStorage(loaded.storage);
    val deployer = testing.treasury("evaa-master-classic-local-deployer");

    master.deploy(deployer.address, { value: ton("1"), bounce: false });
    expectGettersMatchStorage(master, loaded);
}

get fun `test evaa master classic mainnet storage and getters`() {
    val master = mainnetEvaaMasterClassic();
    val loaded = loadForkStorage(master);

    expectStorageCore(loaded);
    expectGettersMatchStorage(master, loaded);

    println("EVAA_MASTER_CLASSIC_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("EVAA_MASTER_CLASSIC_ADDRESS={}", master.address);
    println("EVAA_MASTER_CLASSIC_DATA_HASH={}", loaded.data.hash());
}
