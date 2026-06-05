import "@acton/build"
import "@acton/fs"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_staking_master.types"
import "../wrappers/CoffeeStakingMaster.gen"

const FIXTURE_BOC_PATH = "data/coffee/staking_master/testdata/CoffeeStakingMaster.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xf627c60142e8c2911a4ef99a0830c47ec7e0071b3599e575a483fbbc0c2c6df7

const MAINNET_COFFEE_STAKING_MASTER_ADDRESS = "EQCMtrnKhK82Yw6xHrLm_rJLkMYxeYIilhdmn6BnVGZ1PnBM"
const MAINNET_COFFEE_STAKING_VAULT_ADDRESS = "EQAp-QUzk31pYQWIO5gelCfRrkEe71sI6rg_SvicSV0n31rf"

fun mainnetCoffeeStakingMaster(): CoffeeStakingMaster {
    return CoffeeStakingMaster.fromAddress(address(MAINNET_COFFEE_STAKING_MASTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectOptionalCellHash(expected: cell?, actual: cell): void {
    if (expected == null) {
        expect(actual.hash()).toEqual(createEmptyCell().hash());
    } else {
        expect(actual.hash()).toEqual(expected!.hash());
    }
}

fun loadCoffeeStakingMasterStorageFromFork(master: CoffeeStakingMaster): CoffeeStakingMasterStorage {
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
            expect(code!.hash()).toEqual(build("CoffeeStakingMaster", FIXTURE_BOC_PATH).hash());
            return CoffeeStakingMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Staking Master mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Staking Master mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee staking master code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeStakingMaster", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee staking master mainnet code hash storage and getters`() {
    val master = mainnetCoffeeStakingMaster();
    val storage = loadCoffeeStakingMasterStorageFromFork(master);
    val refs = storage.stateRefs.load();
    val state = refs.state.load();
    val storedData = master.getStoredData();
    val collectionData = master.getCollectionData();

    expect(scripts.isContractDeployed(master.address)).toBeTrue();
    expect(storage.vault).toEqual(address(MAINNET_COFFEE_STAKING_VAULT_ADDRESS));

    expect(storedData.initialized).toEqual(storage.initialized);
    expect(storedData.owner).toEqual(storage.owner);
    expect(storedData.distributor).toEqual(storage.distributor);
    expect(storedData.vault).toEqual(storage.vault);
    expect(storedData.state.hash()).toEqual(refs.state.hash());
    expectOptionalCellHash(refs.rewards, storedData.rewards);
    expectOptionalCellHash(refs.jettons, storedData.jettons);
    expectOptionalCellHash(refs.periods, storedData.periods);

    expect(collectionData.nextItemIndex).toEqual(state.nextItemIndex as int);
    expect(collectionData.ownerAddress).toEqual(storage.owner);
    expect(collectionData.collectionMetadata.hash()).toBeGreater(0);
}
