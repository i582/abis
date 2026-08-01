import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/grambo_factory.types"
import "../wrappers/GramboFactory.gen"

const FACTORY_ADDRESS = "EQApINKePo4Vq1l_W6ZAvYkJf5ORc9eamxxCtFcb79pfCM-h"
const ADMIN_ADDRESS = "EQBmS7ma5XLi85tL5Dofbr5SqU2YtyEMjPUwHjkf8_3g1_yP"
const FIXTURE_BOC_PATH = "data/grambo/factory/testdata/GramboFactory.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x3833e26240f2a83ffd29ee9b71c5ca600dbc04eddd4e41f588aa7716701689c2
const EXPECTED_DATA_HASH = 0x5b77f757c4efe8024e50c87b6c54190a3dac443de346699571aafa088e1ea0a0
const PINNED_MAINNET_BLOCK = 83374906

fun factory(): GramboFactory {
    return GramboFactory.fromAddress(address(FACTORY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadFactoryStorage(contract: GramboFactory): GramboFactoryStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("GramboFactory", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return GramboFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Grambo Factory is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Grambo Factory is frozen at the pinned block");
        }
    }
}

get fun `test grambo factory code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("GramboFactory", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test grambo factory parses pinned storage and getter`() {
    val contract = factory();
    val storage = loadFactoryStorage(contract);
    val config = storage.deployConfig.load();
    val getter = contract.getDeployConfig();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.admin).toEqual(address(ADMIN_ADDRESS));
    expect(config.deployFee).toEqual(1000000000);
    expect(config.deployFee).toEqual(getter.deployFee);
    expect(config.feeCollector).toEqual(getter.feeCollector);
    expect(config.stonfiRouter).toEqual(getter.stonfiRouter);
    expect(config.stonfiRouterPtonWallet).toEqual(getter.stonfiRouterPtonWallet);
    println("GRAMBO_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
