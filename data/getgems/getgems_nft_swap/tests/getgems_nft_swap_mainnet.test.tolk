import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_swap.types"
import "../wrappers/GetgemsNftSwap.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_swap/testdata/GetgemsNftSwap.boc"
const MAINNET_SWAP_ADDRESS = "EQCYG4hVBS9E8qPaCfKWLfSrOUW1ZVCVoJ-kWbcxkJHMri7L"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const REJECTED_NULL_BOC_PREFIX = 0x9ee965
const EXPECTED_CODE_HASH = 0x4a9e4a547710a4a5edcb56369aaab36b0bfc1461914702923d9947f1f1de5c72
const EXPECTED_LEFT_NFT_HASH = 0x4b8ce7d3e23fda6075a333a3a3d1979f47fa9eea3e603db2bfb856c6d67ce9c5
const EXPECTED_RIGHT_NFT_HASH = 0xe6058ece387f96d311636af9d9048ee8d828317beafd40738d7a719fc9a0378e

fun mainnetGetgemsNftSwap(): GetgemsNftSwap {
    return GetgemsNftSwap.fromAddress(address(MAINNET_SWAP_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun hasRejectedNullBocPrefix(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 24) {
        return false;
    }
    return bytes.preloadUint(24) == REJECTED_NULL_BOC_PREFIX;
}

fun loadGetgemsNftSwapStorageFromFork(swap: GetgemsNftSwap): GetgemsNftSwapStorage {
    val account = testing.getAccountState(swap.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return GetgemsNftSwapStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT swap mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT swap mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems nft swap code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();
    expect(hasRejectedNullBocPrefix(rawBoc!)).toBeFalse();

    val code = build("GetgemsNftSwap", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems nft swap rejects three byte null boc`() {
    val threeByteNull = beginCell().storeUint(REJECTED_NULL_BOC_PREFIX, 24).endCell().beginParse();

    expect(hasBocMagic(threeByteNull)).toBeFalse();
    expect(hasRejectedNullBocPrefix(threeByteNull)).toBeTrue();
}

get fun `test getgems nft swap mainnet getters match fork storage`() {
    val swap = mainnetGetgemsNftSwap();
    val storage = loadGetgemsNftSwapStorageFromFork(swap);
    val controls = storage.controls.load();
    val tradeState = swap.getTradeState();

    expect(scripts.isContractDeployed(swap.address)).toBeTrue();

    expect(tradeState.state).toEqual(storage.state);
    expect(tradeState.leftOk).toBeTrue();
    expect(tradeState.rightOk).toBeTrue();
    expect(tradeState.leftTrader).toEqual(storage.leftTrader);
    expect(tradeState.rightTrader).toEqual(storage.rightTrader);
    expect(tradeState.leftNft.isEmpty()).toEqual(storage.leftNft.isEmpty());
    expect(tradeState.rightNft.isEmpty()).toEqual(storage.rightNft.isEmpty());
    expect(tradeState.leftNft).toHaveLength(1);
    expect(tradeState.rightNft).toHaveLength(1);
    expect(tradeState.leftNft.mustGet(EXPECTED_LEFT_NFT_HASH as uint256)).toEqual(1);
    expect(tradeState.rightNft.mustGet(EXPECTED_RIGHT_NFT_HASH as uint256)).toEqual(1);
    expect(tradeState.leftNft.mustGet(EXPECTED_LEFT_NFT_HASH as uint256)).toEqual(
        storage.leftNft.mustGet(EXPECTED_LEFT_NFT_HASH as uint256),
    );
    expect(tradeState.rightNft.mustGet(EXPECTED_RIGHT_NFT_HASH as uint256)).toEqual(
        storage.rightNft.mustGet(EXPECTED_RIGHT_NFT_HASH as uint256),
    );
    expect(tradeState.leftCommission).toEqual(storage.leftCommission);
    expect(tradeState.leftSurcharge).toEqual(storage.leftSurcharge);
    expect(tradeState.leftCoinsGot).toEqual(storage.leftCoinsGot);
    expect(tradeState.rightCommission).toEqual(storage.rightCommission);
    expect(tradeState.rightSurcharge).toEqual(storage.rightSurcharge);
    expect(tradeState.rightCoinsGot).toEqual(storage.rightCoinsGot);
    expect(swap.getSupervisor()).toEqual(controls.supervisor);

    println("GETGEMS_NFT_SWAP_ADDRESS={}", swap.address);
    println("GETGEMS_NFT_SWAP_STORAGE={}", storage);
    println("GETGEMS_NFT_SWAP_TRADE_STATE={}", tradeState);
}
