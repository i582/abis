import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/cron.types"
import "../wrappers/Cron.gen"

const FIXTURE_BOC_PATH = "data/cron/testdata/Cron.boc"
const DATA_FIXTURE_BOC_PATH = "data/cron/testdata/Cron.data.boc"
const DATA_FIXTURE_BOC = "te6ccgECEgEABSEAA8kDOOwPp8iPOw6n5bDP127pBVzF3Mbbxoxh/gSd5ugkQYSABmk7uyB6v+Jzvx5+jjCrUNCxvI+b0/MlohF8uLBC3STQAmmSAjc9vkE2UijklobfjA7lUW9rE/VxI20eJRFyKAhEEAECAwHNgBKe0WfsbR5YfhXuhjL0g0PnGlqB+sfZ5RskvGzJ3rTMUALCJFmt9RKUwzR3P4ebgpbUipoXPU/DGDf63SNAO3fqogBYidTKWoElCzjPtInJlHW6ysthxRL6yBRYo39m4bEO/wAZAgQBYTUmXAgB693kwCX0oFbOxGYDg+Hk2Fh9ny3vmbXz4Ns3WnJfq1gAAAAA1AGiBn45LrAFBMgighAGasEAuuMCIoIQf9mkbrrjAjEhghCNnDfUuo4yW+1E0NQx10wg0PoAMfpAMdM/10zQ+COCAMswA7wS8vT6ADHTAAGT0/8x3voAMHBmbwTgIYIQZTsQ/7rjAiGCEF70stO6BwgJCgCXgA5Md+47SCxwaIK+M+HyehDJ1H4+c8lxB6uZI7ohn63xAAAAAAAAAAAAgBKe0WfsbR5YfhXuhjL0g0PnGlqB+sfZ5RskvGzJ3rTMUAEJNSZcAEAGAAwT8cl1AB4B/jJvFdcsI9WDDAzyv9M/MfpAMfoAMAHQ+kDTP/oA0wABktP/km0B4tTRggDLISTDAPL0ggDLIiPDAPL0ggDLJSX6RDDAAPL0INDTA4IAyyQiwQjy9CQCjhj6ANMPIoIAyyMFuxTy9IIAyzMBwgDy9AHkggDLMjLHAPL0+CNQBKALAfBsEu1E0NQx10wg0PoA+kDTP/oA10zQ+gDTAAGS0/+SbQHi+gDU0QpvFdcsI0t9FsTyv9NBMfpA+kAx+gAwggDLJynDAPL0ggDLKCL6RDDAAPL0+CNTB7uOHTBQal8FNoIAyykCxwXy9IIAyypRQ7oU8vRZcG8E4w4MAIhb7UTQ1DHXTCDQ+gAx+kAx0z/XTND4IwH6ADHTAAGT0/8x3voA10zQ0wMBmPoAMdMPBKAD5DABggDLMQO8EvL0cGZvBAGijj9b7UTQ0wfUMddMggCHYyLDApUCwwPDAJIycOIS8vTQ+gAx+kAx0z/XTNDXTNDTAwGY+gAx0w8CoAHkMKQgbwLgAYIJ564vuuMCggDY9PLwEQBWyCb6AiJulGwSz4GVz4MSy//iz4QgE8zJyFAF+gITzss/AfoCzMlwUwBvBAHAOgrQ+gD6ANMAAZmDCNcY10yBAISUMG1tcOInbpNfAzKONIIAyysBwACzmiH5AFQQOPkQwwCSMnDiEvL00NM/+kDRggDLKQXHBRTy9IIAyy9RO7wT8vTiK9DTA1Qgc1KdDQP8jjXtou37BI4nAvoA0w9TQaBTYLuOFVtTMKBSVaFQRaESqAOoEqABqQTbMeAyNGwS5IIAyyzy8NhUeKCphHBUfBa8jhYwMSVUMiqphFPAoVIFvJIxO5IwMuIKlBAtbDLiUUqhggDLLSHC//L0ggDLLlGruxry9CFwKsIA4w/IDg8QAAgzUASgAAhbA6BwAFRQCfoCIm6UbBLPgZXPgxLL/+JQB/oCGMzJyFAF+gITzss/AfoCzMkDbwQA2tDtRNDUMddM0PoAMfpAMdM/+gDXTNAD0wABk9cLP5IwbeIgbrOTMPgj3wPXTNDTA1AzBI417aLt+wSOJwL6ANMPU0GgU2C7jhVbUzCgUlWhUEWhEqgDqBKgAakE2zHgMjRsEuSCAMss8vDYbwE="
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xaab1db63f193a4aecaa3e3a959fc1784f1412b191a66ae870958405ba88114c7
const EXPECTED_DATA_HASH = 0xd38d7a560e30bb93b93069967357031155203ee4cb684c67c0bad58344737dc0
const PINNED_MAINNET_BLOCK = 71819864
const MAINNET_CRON_ADDRESS = "EQAaKWRLpempuPro_iWQLxVMBOmy7xE-wB_THkpF0J9-0bKf"
const EXPECTED_ROOT_ADDRESS_0 = "0:3349DDD903D5FF139DF8F3F471855A86858DE47CDE9F992D108BE5C58216E926"
const EXPECTED_ROOT_ADDRESS_1 = "0:9A64808DCF6F904D948A3925A1B7E303B9545BDAC4FD5C48DB4789445C8A0211"
const EXPECTED_RUNTIME_ADDRESS_0 = "0:94F68B3F6368F2C3F0AF743197A41A1F38D2D40FD63ECF28D925E3664EF5A662"
const EXPECTED_SCHEDULE_ADDRESS_0 = "0:7263BF71DA4163834415F19F0F93D0864EA3F1F39E4B883D5CC91DD10CFD6F88"

fun primaryCron(): Cron {
    return Cron.fromAddress(address(MAINNET_CRON_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun dataFixtureCell(): cell {
    return parseCellFromBase64(DATA_FIXTURE_BOC);
}

fun expectPrimaryStorage(storage: CronStorage): void {
    val runtime = CronRuntimeParameters.fromCell(storage.runtime);
    val schedule = CronScheduleState.fromCell(runtime.schedule);

    expect(storage.state).toEqual(3);
    expect(storage.controlValue).toEqual(
        0x38ec0fa7c88f3b0ea7e5b0cfd76ee9055cc5dcc6dbc68c61fe049de6e8244184 as uint256,
    );
    expect(storage.rootAddress0).toEqual(address(EXPECTED_ROOT_ADDRESS_0));
    expect(storage.rootAddress1).toEqual(address(EXPECTED_ROOT_ADDRESS_1));
    expect(storage.rootAmount).toEqual(0);
    expect(storage.extraState).toBeNull();

    expect(runtime.runtimeAddress0).toEqual(address(EXPECTED_RUNTIME_ADDRESS_0));
    expect(runtime.runtimeUint16).toEqual(50);
    expect(runtime.runtimeAmount).toEqual(0);
    expect(runtime.runtimeFlag).toBeFalse();

    expect(schedule.scheduleAddress0).toEqual(address(EXPECTED_SCHEDULE_ADDRESS_0));
    expect(schedule.optionalValue).toBeNull();
    expect(schedule.scheduleAmount).toEqual(0);
    expect(schedule.scheduleUint64).toEqual(0);
    expect(schedule.scheduleAddress1).toEqual(address(EXPECTED_RUNTIME_ADDRESS_0));
}

fun loadStorageFromFork(cron: Cron): CronStorage {
    val account = testing.getAccountState(cron.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("Cron", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return CronStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Cron primary mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Cron primary mainnet account is frozen");
        }
    }
}

get fun `test cron primary code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("Cron", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test cron primary saved data fixture parses storage`() {
    val data = dataFixtureCell();
    val storage = CronStorage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expectPrimaryStorage(storage);

    println("CRON_PRIMARY_STORAGE_FIXTURE={}", storage);
}

get fun `test cron primary mainnet fork storage`() {
    val cron = primaryCron();
    val storage = loadStorageFromFork(cron);

    expect(scripts.isContractDeployed(cron.address)).toBeTrue();
    expectPrimaryStorage(storage);

    println("CRON_PRIMARY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("CRON_PRIMARY_MAINNET_ADDRESS={}", cron.address);
    println("CRON_PRIMARY_MAINNET_STORAGE={}", storage);
}
