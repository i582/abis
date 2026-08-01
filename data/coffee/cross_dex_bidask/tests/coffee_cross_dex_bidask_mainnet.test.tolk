import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/coffee_cross_dex_bidask.types"
import "../wrappers/CoffeeCrossDexBidask.gen"

const CODE_FIXTURE_BOC_PATH = "data/coffee/cross_dex_bidask/testdata/CoffeeCrossDexBidask.boc"
const DATA_FIXTURE_BOC_PATH = "data/coffee/cross_dex_bidask/testdata/CoffeeCrossDexBidask.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa63cbf47d55370fe2baebb4bf284bd401e717db4a0ab0e49f4b3b3cc7c0f5652
const EXPECTED_DATA_HASH = 0xafd1876db96badcd607decbeb3b88182be70006ccd8074b6a6d22977140f5d1b
const EXPECTED_ADMIN_ADDRESS = "EQCflroppNos8bz1RdFs_tGQUk9qoUZ6kS3bmc7mVoSdnBXI"
const EXPECTED_DEPLOYMENT_DISCRIMINATOR = 1
const MAINNET_ADDRESS = "EQCde_kCc5MIx_yoao6Pv3BsUbpSi4yxMtPSVOrgepmCTCDs"
const PINNED_MAINNET_BLOCK = 50935347

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun savedDeploymentStorage(): CoffeeCrossDexBidaskDeploymentStorage {
    val data = build("CoffeeCrossDexBidask", DATA_FIXTURE_BOC_PATH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    return CoffeeCrossDexBidaskDeploymentStorage.fromCell(data);
}

fun expectDeploymentStorage(storage: CoffeeCrossDexBidaskDeploymentStorage): void {
    expect(storage.adminAddress).toEqual(address(EXPECTED_ADMIN_ADDRESS));
    expect(storage.deploymentDiscriminator).toEqual(EXPECTED_DEPLOYMENT_DISCRIMINATOR);
}

get fun `test coffee cross dex bidask code and data fixtures are exact`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("CoffeeCrossDexBidask", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expectDeploymentStorage(savedDeploymentStorage());
}

get fun `test coffee cross dex bidask parses pinned mainnet storage and getter`() {
    val crossDex = CoffeeCrossDexBidask.fromAddress(address(MAINNET_ADDRESS));
    expect(scripts.isContractDeployed(crossDex.address)).toBeTrue();

    val account = testing.getAccountState(crossDex.address);
    expect(account).toBeNotNull();
    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("CoffeeCrossDexBidask", CODE_FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expectDeploymentStorage(CoffeeCrossDexBidaskDeploymentStorage.fromCell(data!));
        }
        TlbAccountStateUninit => {
            Assert.fail("Coffee CrossDex Bidask account is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Coffee CrossDex Bidask account is frozen at the pinned block");
        }
    }

    expect(crossDex.getAdmin()).toEqual(address(EXPECTED_ADMIN_ADDRESS));
    println("COFFEE_CROSS_DEX_BIDASK_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
