import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/moon_order_factory.types"
import "../wrappers/MoonOrderFactory.gen"

const FACTORY_ADDRESS = "EQDigIndTzm4FQ8lygizRH869SxW2dVyn4KcyDV7PwfrquZT"
const SAMPLE_ASSET = "0:0000000000000000000000000000000000000000000000000000000000000001"
const CODE_FIXTURE_BOC_PATH = "data/moon/order_factory/testdata/MoonOrderFactory.boc"
const DATA_FIXTURE_BOC_PATH = "data/moon/order_factory/testdata/MoonOrderFactory.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xd04737d6f678103a9e448c22109919d0f9cbe05ef1b1a83c5e7b886683a54704
const EXPECTED_DATA_HASH = 0xee9b0800c814a9da86ce1fc3039d33e0692f2cc47d0e205ea94f90fe1143ea7a
const PINNED_MAINNET_BLOCK = 83400035

fun factory(): MoonOrderFactory {
    return MoonOrderFactory.fromAddress(address(FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadFactoryStorage(data: cell): MoonOrderFactoryStorage {
    val storage = MoonOrderFactoryStorage.fromCell(data);
    expect(storage.toCell().hash()).toEqual(data.hash());
    return storage;
}

fun loadFactoryFromFork(contract: MoonOrderFactory): MoonOrderFactoryStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MoonOrderFactory", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(
                build("MoonOrderFactoryData", DATA_FIXTURE_BOC_PATH).hash(),
            );
            return loadFactoryStorage(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Moon Order Factory is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Moon Order Factory is frozen at the pinned block");
        }
    }
}

get fun `test moon order factory exact code and data fixtures`() {
    val rawCode = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawData = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();
    expect(build("MoonOrderFactory", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("MoonOrderFactoryData", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
    loadFactoryStorage(build("MoonOrderFactoryData", DATA_FIXTURE_BOC_PATH));
}

get fun `test moon order factory pinned storage and public getters`() {
    val contract = factory();
    val storage = loadFactoryFromFork(contract);
    val pipe = contract.getPipe(address(SAMPLE_ASSET));

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(contract.getId()).toEqual(storage.lastOrderId);
    expect((storage.adminAddress as any_address).castToInternal()).toEqual(storage.adminAddress);
    expect((storage.pipeDeploymentAuthority as any_address).castToInternal()).toEqual(
        storage.pipeDeploymentAuthority,
    );
    expect(storage.pipeCode.hash() == storage.orderCode.hash()).toBeFalse();
    expect((pipe as any_address).castToInternal()).toEqual(pipe);
    println("MOON_ORDER_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
