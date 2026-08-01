import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/cocoon_client.types"
import "../wrappers/CocoonClient.gen"

const FIXTURE_BOC_PATH = "data/cocoon/client/testdata/CocoonClient.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xb81f091aee4e88708650755a859cfa436d2c968726b85b0569911bb734dd77d3
const EXPECTED_DATA_HASH = 0x193bd7bf772cb7e90282b4f68f51bb09bbb0292cb709c40b37af4e58eae2d521
const CLIENT_ADDRESS = "EQBjzlfkW3bNBeA-z9Fw5a_iQrmfwD2SGtJO_Bsqjc84K7tw"
const PROXY_ADDRESS = "EQDGkQM7RIWp6yGW79i8oV3zJ-vdnpV68pdZ2W8mrpE3cJ2y"
const PINNED_MAINNET_BLOCK = 83377290

fun client(): CocoonClient {
    return CocoonClient.fromAddress(address(CLIENT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadClientStorage(contract: CocoonClient): CocoonClientStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CocoonClient", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return CocoonClientStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("COCOON Client is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("COCOON Client is frozen at the pinned block");
        }
    }
}

get fun `test cocoon client code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("CocoonClient", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test cocoon client parses pinned storage and getter`() {
    val contract = client();
    val storage = loadClientStorage(contract);
    val constData = storage.constData.load();
    val params = storage.params.load();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(constData.proxyAddress).toEqual(address(PROXY_ADDRESS));
    expect(storage.state).toEqual(0);
    expect(params.structVersion).toEqual(4);
    expect(params.isTest).toBeFalse();

    val data = contract.getCocoonClientData();
    expect(data.ownerAddress).toEqual(constData.ownerAddress);
    expect(data.proxyAddress).toEqual(constData.proxyAddress);
    expect(data.proxyPublicKey).toEqual(constData.proxyPublicKey);
    expect(data.state).toEqual(storage.state);
    expect(data.balance).toEqual(storage.balance);
    expect(data.stake).toEqual(storage.stake);
    expect(data.tokensUsed).toEqual(storage.tokensUsed);
    expect(data.unlockTs).toEqual(storage.unlockTs);
    expect(data.secretHash).toEqual(storage.secretHash);
    println("COCOON_CLIENT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
