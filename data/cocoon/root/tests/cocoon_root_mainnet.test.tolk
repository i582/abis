import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/cocoon_root.types"
import "../wrappers/CocoonRoot.gen"

const FIXTURE_BOC_PATH = "data/cocoon/root/testdata/CocoonRoot.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfb89a08fc6ce8ada74d067a0c2f62793f868e7cd5e8e01b5ed0247c568642908
const EXPECTED_DATA_HASH = 0x829574fa4f91aa99bceda04378f36821dc03a6b81d2d2d9705957675347636da
const ROOT_ADDRESS = "EQCns7bYSp0igFvS1wpb5wsZjCKCV19MD5AVzI4EyxsnU73k"
const PINNED_MAINNET_BLOCK = 83377290

fun root(): CocoonRoot {
    return CocoonRoot.fromAddress(address(ROOT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadRootStorage(contract: CocoonRoot): CocoonRootStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CocoonRoot", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return CocoonRootStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("COCOON Root is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("COCOON Root is frozen at the pinned block");
        }
    }
}

get fun `test cocoon root code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("CocoonRoot", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test cocoon root parses pinned storage and getters`() {
    val contract = root();
    val storage = loadRootStorage(contract);
    val data = storage.data.load();
    val params = storage.params.load();
    val publicKeysManager = storage.publicKeysManager.load();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(params.structVersion).toEqual(4);
    expect(params.isTest).toBeFalse();
    expect(params.proxyCode).toBeNotNull();
    expect(params.workerCode).toBeNotNull();
    expect(params.clientCode).toBeNotNull();
    expect(publicKeysManager.managerNetworkAddress.remainingBitsCount() > 0).toBeTrue();

    val compact = contract.getCocoonData();
    expect(compact.version).toEqual(storage.version);
    expect(compact.lastProxySeqno).toEqual(data.lastProxySeqno);
    expect(compact.paramsVersion).toEqual(params.paramsVersion);
    expect(compact.uniqueId).toEqual(params.uniqueId);
    expect(compact.isTest).toEqual(params.isTest);
    expect(compact.pricePerToken).toEqual(params.pricePerToken);
    expect(compact.workerFeePerToken).toEqual(params.workerFeePerToken);
    expect(compact.minProxyStake).toEqual(params.minProxyStake);
    expect(compact.minClientStake).toEqual(params.minClientStake);
    expect(compact.ownerAddress).toEqual(storage.ownerAddress);
    expect(contract.lastProxySeqno()).toEqual(data.lastProxySeqno);

    val current = contract.getCurParams();
    expect(current.paramsVersion).toEqual(params.paramsVersion);
    expect(current.uniqueId).toEqual(params.uniqueId);
    expect(current.isTest).toEqual(params.isTest);
    expect(current.pricePerToken).toEqual(params.pricePerToken);
    expect(current.workerFeePerToken).toEqual(params.workerFeePerToken);
    expect(current.cachedTokensPriceMultiplier).toEqual(params.cachedTokensPriceMultiplier);
    expect(current.reasoningTokensPriceMultiplier).toEqual(params.reasoningTokensPriceMultiplier);
    expect(current.proxyDelayBeforeClose).toEqual(params.proxyDelayBeforeClose);
    expect(current.clientDelayBeforeClose).toEqual(params.clientDelayBeforeClose);
    expect(current.minProxyStake).toEqual(params.minProxyStake);
    expect(current.minClientStake).toEqual(params.minClientStake);
    expect(current.proxyCodeHash).toEqual(params.proxyCode!.hash());
    expect(current.workerCodeHash).toEqual(params.workerCode!.hash());
    expect(current.clientCodeHash).toEqual(params.clientCode!.hash());
    expect(contract.proxyHashIsValid(0)).toEqual(0);
    expect(contract.workerHashIsValid(0)).toEqual(0);
    expect(contract.modelHashIsValid(0)).toEqual(0);
    expect(contract.publicKeyIsValid(0)).toEqual(0);
    println("COCOON_ROOT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
