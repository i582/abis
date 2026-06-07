import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../wrappers/ScaledUiJettonMaster.gen"

const BACX_MASTER_ADDRESS = "EQAlL7fOykivkEefblcB3bkqn4HMwP8jQNDNVzo9-RkKZNJx"
const COINX_MASTER_ADDRESS = "EQCpSKh0bO8zr5M6Qnk5lVUaUKwEsSsjE-X29PxYhhnEj48I"
const FIXTURE_BOC_PATH = "data/jettons/scaled_ui/testdata/ScaledUiJettonMaster.boc"
const EXPECTED_CODE_HASH = 0x33170bf263b90f9f289d66250b8db0b8e0205601ba50713f05e94d506d2ddfe6

fun assertScaledUiMasterCode(master: ScaledUiJettonMaster): void {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("ScaledUiJettonMaster", FIXTURE_BOC_PATH).hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("Scaled UI Jetton master account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Scaled UI Jetton master account is frozen");
        }
    }
}

get fun `test scaled ui jetton master getters work on mainnet`() {
    val bacx = ScaledUiJettonMaster.fromAddress(address(BACX_MASTER_ADDRESS));
    val coinx = ScaledUiJettonMaster.fromAddress(address(COINX_MASTER_ADDRESS));

    expect(scripts.isContractDeployed(bacx.address)).toBeTrue();
    expect(scripts.isContractDeployed(coinx.address)).toBeTrue();
    assertScaledUiMasterCode(bacx);
    assertScaledUiMasterCode(coinx);

    val bacxMultiplier = bacx.getDisplayMultiplier();
    val coinxMultiplier = coinx.getDisplayMultiplier();

    expect(bacxMultiplier.numerator).toEqual(7924461287361);
    expect(bacxMultiplier.denominator).toEqual(7812500000000);
    expect(coinxMultiplier.numerator).toEqual(200247485063);
    expect(coinxMultiplier.denominator).toEqual(200000000000);

    println("SCALED_UI_BACX_MULTIPLIER={}", bacxMultiplier);
    println("SCALED_UI_COINX_MULTIPLIER={}", coinxMultiplier);
}
