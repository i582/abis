import "@acton/build"
import "@acton/fs"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_staking_item.types"
import "../wrappers/CoffeeStakingItem.gen"

const FIXTURE_BOC_PATH = "data/coffee/staking_item/testdata/CoffeeStakingItem.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x36f19ed73839bf6aaa3b00dfb0ca14ce3c954428a1f4969972c80550be9ab2a2

const MAINNET_COFFEE_STAKING_ITEM_ADDRESS = "EQBBM8rkdB10WgKwVmXfM_8jX-unQQQqamLQixNfHp1uKqWY"
const MAINNET_COFFEE_STAKING_MASTER_ADDRESS = "EQCMtrnKhK82Yw6xHrLm_rJLkMYxeYIilhdmn6BnVGZ1PnBM"

fun mainnetCoffeeStakingItem(): CoffeeStakingItem {
    return CoffeeStakingItem.fromAddress(address(MAINNET_COFFEE_STAKING_ITEM_ADDRESS));
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

fun loadCoffeeStakingItemStorageFromFork(item: CoffeeStakingItem): CoffeeStakingItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CoffeeStakingItem", FIXTURE_BOC_PATH).hash());
            return CoffeeStakingItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee Staking Item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee Staking Item mainnet fixture account is frozen");
        }
    }
}

get fun `test coffee staking item code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("CoffeeStakingItem", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test coffee staking item mainnet code hash storage and getters`() {
    val item = mainnetCoffeeStakingItem();
    val storage = loadCoffeeStakingItemStorageFromFork(item);
    val storedData = item.getStoredData();
    val nftData = item.getNftData();

    expect(scripts.isContractDeployed(item.address)).toBeTrue();
    expect(storage.master).toEqual(address(MAINNET_COFFEE_STAKING_MASTER_ADDRESS));

    expect(storedData.initialized).toEqual(storage.initialized);
    expect(storedData.nftId).toEqual(storage.nftId);
    expect(storedData.master).toEqual(storage.master);
    expect(storedData.owner).toEqual(storage.owner);
    expect(storedData.asset.hash()).toEqual(storage.asset.hash());
    expect(storedData.info.hash()).toEqual(storage.info.hash());
    expectOptionalCellHash(storage.periods, storedData.periods);

    expect(nftData.isInitialized).toEqual(storage.initialized);
    expect(nftData.itemIndex).toEqual(storage.nftId as int);
    expect(nftData.collectionAddress).toEqual(storage.master);
    expect(nftData.ownerAddress).toEqual(storage.owner);
    expect(nftData.content.hash()).toBeGreater(0);
}
