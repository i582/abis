import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonkspump_virtual_minter.types"
import "../wrappers/StonksPumpVirtualMinter.gen"

const FIXTURE_BOC_PATH = "data/stonkspump/virtual_minter/testdata/StonksPumpVirtualMinterStonfi.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x3353e1472a235ae3d198a9fa80b84127e18bc266ba19f18ef4aa53d18e37a165
const EXPECTED_DATA_HASH = 0x2389249dbe28000f0dedd51956a0bb0ee7b6a0a40763108b27955ca1fb09ffb9
const PINNED_MAINNET_BLOCK = 83374121
const MINTER_ADDRESS = "EQDQD7VxjuodGDa20e-oacYLIncmKe047qDSWhrGWFub4p_1"
const ZERO_ADDRESS = "0:0000000000000000000000000000000000000000000000000000000000000000"

fun minter(): StonksPumpVirtualMinterStonfi {
    return StonksPumpVirtualMinterStonfi.fromAddress(address(MINTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadMinterStorage(contract: StonksPumpVirtualMinterStonfi): StonksPumpVirtualMinterStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonksPumpVirtualMinter", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return StonksPumpVirtualMinterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("StonksPump virtual minter is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("StonksPump virtual minter is frozen at the pinned block");
        }
    }
}

get fun `test stonkspump virtual minter fixtures match live code variants`() {
    val stonfiBytes = fs.readBytes(FIXTURE_BOC_PATH);
    val dedustBytes = fs.readBytes("data/stonkspump/virtual_minter/testdata/StonksPumpVirtualMinterDedust.boc");
    expect(stonfiBytes).toBeNotNull();
    expect(dedustBytes).toBeNotNull();
    expect(hasBocMagic(stonfiBytes!)).toBeTrue();
    expect(hasBocMagic(dedustBytes!)).toBeTrue();
    expect(build("StonksPumpVirtualMinter", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(
        build(
            "StonksPumpVirtualMinter",
            "data/stonkspump/virtual_minter/testdata/StonksPumpVirtualMinterDedust.boc",
        ).hash(),
    ).toEqual(
        0xc6f6ff1f075b48837d4b1235c6d0782b5f0c87260a953a9e798b78994ba6d3f3,
    );
}

get fun `test stonkspump virtual minter parses pinned storage and getters`() {
    val contract = minter();
    val storage = loadMinterStorage(contract);
    val bondingState = storage.bondingState;
    val jettonData = contract.getJettonData();
    val bondingData = contract.getBondingData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.totalSupply).toEqual(100000000000000000);
    expect(storage.adminAddress).toEqual(address(ZERO_ADDRESS));
    expect(bondingState).toBeNotNull();
    expect(bondingState!.load().presaleOpen).toBeTrue();
    expect(bondingState!.load().migrationTonTarget).toEqual(2000000000000);
    expect(bondingState!.load().maxBuyPercent).toEqual(100);
    expect(bondingState!.load().tokensSold).toEqual(302702492835024);

    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeFalse();
    expect(jettonData.adminAddress).toEqual(storage.adminAddress);
    expect(jettonData.jettonContent.hash()).toEqual(storage.jettonContent.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(contract.getVersion()).toEqual(7);

    expect(bondingData.progressBps).toEqual(13);
    expect(bondingData.migrationTonTarget).toEqual(2000000000000);
    expect(bondingData.cumulativeTonReserve).toEqual(1000443116449);
    expect(bondingData.cumulativeJettonReserve).toEqual(112169179536652476);
    expect(bondingData.tonsCollected).toEqual(2692554090);
    expect(bondingData.maxBuyPercent).toEqual(100);
    expect(bondingData.tokensSold).toEqual(302702492835024);
    expect(bondingData.presaleOpen).toEqual(1);
    println("STONKSPUMP_VIRTUAL_MINTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
