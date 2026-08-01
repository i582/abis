import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/cocoon_proxy.types"
import "../wrappers/CocoonProxy.gen"

const FIXTURE_BOC_PATH = "data/cocoon/proxy/testdata/CocoonProxy.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x279a4a96d50e93018f20fecac379712afd0052597cbe93fffec32be68c9787fd
const EXPECTED_DATA_HASH = 0x04ce83bd5235cfc26fad4c159debdb4f8ca0d447586b2957dc526386e9202170
const PROXY_ADDRESS = "EQDGkQM7RIWp6yGW79i8oV3zJ-vdnpV68pdZ2W8mrpE3cJ2y"
const ROOT_ADDRESS = "EQCns7bYSp0igFvS1wpb5wsZjCKCV19MD5AVzI4EyxsnU73k"
const PINNED_MAINNET_BLOCK = 83377290

fun proxy(): CocoonProxy {
    return CocoonProxy.fromAddress(address(PROXY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadProxyStorage(contract: CocoonProxy): CocoonProxyStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CocoonProxy", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return CocoonProxyStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("COCOON Proxy is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("COCOON Proxy is frozen at the pinned block");
        }
    }
}

get fun `test cocoon proxy code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("CocoonProxy", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test cocoon proxy parses pinned storage and getter`() {
    val contract = proxy();
    val storage = loadProxyStorage(contract);
    val params = storage.params.load();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.rootAddress).toEqual(address(ROOT_ADDRESS));
    expect(storage.state).toEqual(0);
    expect(params.structVersion).toEqual(4);
    expect(params.isTest).toBeFalse();

    val data = contract.getCocoonProxyData();
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.proxyPublicKey).toEqual(storage.proxyPublicKey);
    expect(data.rootAddress).toEqual(storage.rootAddress);
    expect(data.state).toEqual(storage.state);
    expect(data.balance).toEqual(storage.balance);
    expect(data.stake).toEqual(storage.stake);
    expect(data.unlockTs).toEqual(storage.unlockTs);
    expect(data.pricePerToken).toEqual(params.pricePerToken);
    expect(data.workerFeePerToken).toEqual(params.workerFeePerToken);
    expect(data.minProxyStake).toEqual(params.minProxyStake);
    expect(data.minClientStake).toEqual(params.minClientStake);
    expect(data.paramsVersion).toEqual(params.paramsVersion);
    println("COCOON_PROXY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
